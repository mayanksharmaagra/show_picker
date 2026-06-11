import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../ai/tmdb_service.dart';
import '../data/Suggestion.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SuggestionScreen
//
// Displays AI-recommended movies/shows as swipeable full-screen cards.
// Each card shows:
//   • Full-screen TMDB poster as background
//   • Top bar: back button, page dots, bookmark icon
//   • Sparkle icon (AI indicator)
//   • Bottom info card: mood tag, title, rating/runtime/language, AI reason
//   • Skip (red) and Save (green) action buttons
//
// Progressive loading:
//   • Starts with first 5 enriched items (passed from HomeScreen)
//   • When user reaches index (loadedCount - 2), fetches next 5 from TMDB
//   • Continues until all 20 items are enriched
// ─────────────────────────────────────────────────────────────────────────────

class SuggestionScreen extends StatefulWidget {
  /// First 5 items already enriched with TMDB data — ready to display
  final List<Suggestion> loaded;

  /// Remaining 15 raw items from Claude — waiting for TMDB enrichment
  final List<Suggestion> remaining;

  /// TMDB API key needed for enriching remaining batches
  final String tmdbKey;

  /// The mood user selected (shown as tag on card)
  final String? mood;

  const SuggestionScreen({
    super.key,
    required this.loaded,
    required this.remaining,
    required this.tmdbKey,
    required this.mood,
  });

  @override
  State<SuggestionScreen> createState() => _SuggestionScreenState();
}

class _SuggestionScreenState extends State<SuggestionScreen> {
  // ── Services ───────────────────────────────────────────────────────────────
  final TmdbService _tmdbService = TmdbService();

  // ── Page controller for horizontal swipe ──────────────────────────────────
  late final PageController _pageController;

  // ── State ──────────────────────────────────────────────────────────────────

  /// All items that have been enriched and are ready to display
  late List<Suggestion> _loaded;

  /// Items still waiting to be enriched with TMDB data
  late List<Suggestion> _remaining;

  /// Current visible card index
  int _currentIndex = 0;

  /// True while background TMDB batch is being fetched
  bool _isFetchingMore = false;

  // ── Mood emoji map ─────────────────────────────────────────────────────────
  final Map<String, String> _moodEmojis = {
    'Happy': '😄',
    'Thrilling': '😱',
    'Romantic': '💕',
    'Scary': '👻',
    'Funny': '😂',
    'Emotional': '😢',
    'Mind-bending': '🤯',
    'Chill': '😴',
    'Inspired': '🤩',
    'Action-packed': '😤',
    'Curious': '🧐',
    'Celebratory': '🥳',
  };

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loaded = List.from(widget.loaded);
    _remaining = List.from(widget.remaining);

    // Make status bar transparent so poster shows through
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Page change handler ────────────────────────────────────────────────────

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);

    // Prefetch next batch when user is 2 cards from end of loaded list
    // e.g. if 5 loaded and user is on index 3 → fetch items 6–10 now
    final nearEnd = index >= _loaded.length - 2;
    final hasMore = _remaining.isNotEmpty;

    if (nearEnd && hasMore && !_isFetchingMore) {
      _fetchNextBatch();
    }
  }

  // ── Fetch next TMDB batch silently in background ───────────────────────────

  Future<void> _fetchNextBatch() async {
    setState(() => _isFetchingMore = true);

    // Take next 5 items from remaining queue
    final batch = _remaining.take(5).toList();
    _remaining = _remaining.skip(5).toList();

    // Enrich all 5 with TMDB in parallel
    final enriched = await Future.wait(
      batch.map((s) => _tmdbService.enrichSuggestion(s, widget.tmdbKey)),
    );

    if (mounted) {
      setState(() {
        _loaded.addAll(enriched); // append to visible list
        _isFetchingMore = false;
      });
    }
  }

  // ── Save action ────────────────────────────────────────────────────────────

  void _onSave() {
    final current = _loaded[_currentIndex];
    // TODO: call SavedShowsRepository.save(current)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('💚 "${current.title}" saved to your picks!'),
        backgroundColor: const Color(0xFF166534),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    _goToNext();
  }

  // ── Skip action ────────────────────────────────────────────────────────────

  void _onSkip() => _goToNext();

  // ── Move to next card ──────────────────────────────────────────────────────

  void _goToNext() {
    if (_currentIndex < _loaded.length - 1) {
      // Animate to next card
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else if (_remaining.isNotEmpty) {
      // Still fetching — show brief loading snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loading more suggestions...'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      // All done — go back to home
      context.go('/mood');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Full-screen swipeable poster cards ──────────────────────────
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _loaded.length,
            itemBuilder: (context, index) {
              return _buildCard(_loaded[index]);
            },
          ),

          // ── Top bar (back + dots + bookmark) ────────────────────────────
          _buildTopBar(),

          // ── Sparkle AI icon (top-right) ──────────────────────────────────
          _buildSparkleIcon(),

          // ── Bottom action buttons (Skip + Save) ──────────────────────────
          _buildActionButtons(),

          // ── Background loading indicator (subtle, bottom-center) ─────────
          if (_isFetchingMore) _buildLoadingIndicator(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CARD — full screen poster + info overlay
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildCard(Suggestion suggestion) {
    return Stack(
      children: [
        // ── Poster image (full screen background) ───────────────────────
        _buildPosterBackground(suggestion),

        // ── Dark gradient overlay (bottom half darkens for readability) ──
        _buildGradientOverlay(),

        // ── Bottom info card ─────────────────────────────────────────────
        _buildInfoCard(suggestion),
      ],
    );
  }

  // ── Poster ────────────────────────────────────────────────────────────────

  Widget _buildPosterBackground(Suggestion suggestion) {
    return Positioned.fill(
      child: suggestion.poster_path != null
          ? CachedNetworkImage(
              imageUrl: suggestion.poster_path!,
              fit: BoxFit.cover,
              // Shimmer while loading
              placeholder: (_, __) => const ColoredBox(
                color: Color(0xFF1E293B),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF3B82F6),
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: (_, __, ___) => _buildNoPosterFallback(suggestion),
            )
          // Fallback if TMDB has no poster
          : _buildNoPosterFallback(suggestion),
    );
  }

  /// Dark placeholder shown when poster is unavailable
  Widget _buildNoPosterFallback(Suggestion suggestion) {
    return Container(
      color: const Color(0xFF0F172A),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎬', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              suggestion.title,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Gradient overlay ──────────────────────────────────────────────────────

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.45, 0.75, 1.0],
            colors: [
              Colors.transparent, // top — poster visible
              Colors.transparent, // middle — poster visible
              Color(0xCC000000), // lower — starts darkening
              Color(0xFF000000), // bottom — fully dark
            ],
          ),
        ),
      ),
    );
  }

  // ── Info card ─────────────────────────────────────────────────────────────

  Widget _buildInfoCard(Suggestion suggestion) {
    final moodEmoji = _moodEmojis[widget.mood] ?? '✨';

    return Positioned(
      left: 16,
      right: 16,
      // Sits above the action buttons
      bottom: 100,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              // Semi-transparent dark card — matches screenshot
              color: const Color(0xFF1E293B).withOpacity(0.65),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Mood tag pill ──────────────────────────────────────────
                _buildMoodTag(moodEmoji),

                const SizedBox(height: 12),

                // ── Movie/show title ───────────────────────────────────────
                Text(
                  suggestion.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 10),

                // ── Rating · Runtime · Language row ───────────────────────
                _buildMetaRow(suggestion),

                const Divider(
                  color: Color(0xFF2D3748),
                  height: 24,
                  thickness: 0.5,
                ),

                // ── "Why Claude picked this" section ──────────────────────
                if (suggestion.overview != null)
                  _buildClaudeReason(suggestion.overview!),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Mood emoji + label pill (e.g. "😱 Thrilling")
  Widget _buildMoodTag(String moodEmoji) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xffADC6FF).withOpacity(.5),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: Color(0xffADC6FF).withOpacity(0.40),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xffADC6FF).withOpacity(0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        '$moodEmoji ${widget.mood}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// ⭐ 8.4 · 2h 22m · Hindi
  Widget _buildMetaRow(Suggestion suggestion) {
    return Row(
      children: [
        // Rating
        if (suggestion.vote_average != null) ...[
          const Text('⭐', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            suggestion.vote_average!.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          _buildDot(),
        ],

        // Runtime
        if (suggestion.runtime != null) ...[
          Text(
            _formatRuntime(suggestion.runtime!),
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          ),
          _buildDot(),
        ],

        // Language
        if (widget.mood != null) ...[
          Text(
            widget.mood!, // Replace with suggestion.language when available
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          ),
        ],
      ],
    );
  }

  /// Small separator dot between meta items
  Widget _buildDot() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        '•',
        style: TextStyle(color: Color(0xFF475569), fontSize: 14),
      ),
    );
  }

  /// "✦ Why Claude picked this" + reason text
  Widget _buildClaudeReason(String reason) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Image.asset("assets/images/sparkle.png", width: 12, height: 12),
            SizedBox(width: 3),
            const Text(
              'Why Claude picked this',
              style: TextStyle(
                color: Color(0xFFADC6FF),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Reason text
        Text(
          reason,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            height: 1.6,
            letterSpacing: 0.1,
          ),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TOP BAR — back button + page dots + bookmark
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    // Total count = loaded + remaining (gives user sense of progress)
    final totalCount = _loaded.length + _remaining.length;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      right: 16,
      child: Row(
        children: [
          // ── Back button ───────────────────────────────────────────────
          GestureDetector(
            onTap: () => context.go('/mood'),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          // ── Page progress dots ────────────────────────────────────────
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                // Show max 5 dots to avoid overflow
                totalCount.clamp(1, 5),
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentIndex == index ? 18 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),
          ),

          // ── Bookmark button ───────────────────────────────────────────
          GestureDetector(
            onTap: _onSave, // Save without navigating (alternative to Save btn)
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bookmark_border_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SPARKLE ICON — AI indicator top-right area
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSparkleIcon() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 80,
      right: 20,
      child: Image.asset(
        "assets/images/sparkle.png",
        width: 40,
        height: 40,
        opacity: const AlwaysStoppedAnimation(.55),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ACTION BUTTONS — Skip (red) + Save (green)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildActionButtons() {
    return Positioned(
      bottom: 24 + MediaQuery.of(context).padding.bottom,
      left: 16,
      right: 16,
      child: Row(
        children: [
          // ── Skip button (red) ──────────────────────────────────────────
          Expanded(
            child: GestureDetector(
              onTap: _onSkip,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.close_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ── Save button (green) ────────────────────────────────────────
          Expanded(
            child: GestureDetector(
              onTap: _onSave,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF22C55E).withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LOADING MORE INDICATOR — shown while fetching next TMDB batch
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildLoadingIndicator() {
    return Positioned(
      bottom: 110,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(99),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF3B82F6),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Loading more...',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  /// Converts minutes to "2h 22m" format
  String _formatRuntime(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }
}

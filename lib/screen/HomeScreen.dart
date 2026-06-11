import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:show_picker/screen/SuggestionScreen.dart';

import '../ai/Claude_Service.dart';
import '../ai/gemini_service.dart';
import '../ai/tmdb_service.dart';
import '../data/Suggestion.dart';
import 'AppUtils.dart';

// ─── Mood Model ──────────────────────────────────────────────────────────────

class MoodItem {
  final String emoji;
  final String label;
  final String subtitle;

  const MoodItem({
    required this.emoji,
    required this.label,
    required this.subtitle,
  });
}


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedLabel;
  String? _selectedGenre;
  String? _selectedLanguage;
  double _duration = 120; // default 120 mins
  final _claudeService = ClaudeService();
  final _geminiService = GeminiService();
  final _tmdbService = TmdbService();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F172A),
      body: Column(
        children: [
          _toolBar(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _titleBar(),
                  _showMoodsTypes(),
                  _genreType(),
                  _languageSelector(),
                  _buildDurationSlider(),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  _buildFindButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolBar() {
    return Container(
      color: Color(0xff10131A),
      child: Padding(
        padding: EdgeInsets.only(left: 10, top: 60, bottom: 10, right: 15),
        // all sides
        child: Row(
          children: [
            const Text(
              'Show Picker',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1.5,
                height: 1.0,
              ),
            ),
            SizedBox(width: 8),
            Image.asset(
              "assets/images/flicker_star.png",
              width: 15,
              height: 15,
            ),
            const Spacer(),
            IconButton(
              onPressed: () => context.push('/saved'),
              icon: const Icon(
                Icons.bookmarks_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _titleBar() {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How are you feeling tonight?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1.5,
                height: 1.0,
              ),
            ),
            SizedBox(height: 10),
            const Text(
              'We\'ll find the perfect watch for you',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xff94A3B8),
                letterSpacing: 1.5,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _showMoodsTypes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          child: Text(
            "Your Mood",
            style: TextStyle(
              fontSize: 16,
              color: Color(0xff94A3B8),
              letterSpacing: 0.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.45,
          ),
          itemCount: kMoods.length,
          itemBuilder: (context, idx) {
            final mood = kMoods[idx];
            var isSelected = _selectedLabel == mood.label;
            return _MoodCard(
              mood: mood,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  if (_selectedLabel == mood.label) {
                    _selectedLabel = null;
                  } else {
                    _selectedLabel = mood.label;
                  }
                });
              },
            );
          },
        ),
      ],
    );
  }

  Widget _languageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: const Text(
            "Language",
            style: TextStyle(
              fontSize: 16,
              color: Color(0xff94A3B8),
              letterSpacing: 0.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8, // horizontal gap between chips
            runSpacing: 10, // vertical gap between rows
            children: kLanguages.map((language) {
              final isSelected = _selectedLanguage == language;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedLanguage = _selectedLanguage == language
                      ? null
                      : language;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xff3B82F6)
                        : const Color(0xff1E293B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xff3B82F6)
                          : const Color(0xff334155),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    language,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xff94A3B8),
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _genreType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: const Text(
            "Genre",
            style: TextStyle(
              fontSize: 16,
              color: Color(0xff94A3B8),
              letterSpacing: 0.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8, // horizontal gap between chips
            runSpacing: 10, // vertical gap between rows
            children: kGenres.map((genre) {
              final isSelected = _selectedGenre == genre;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedGenre = _selectedGenre == genre ? null : genre;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xff3B82F6)
                        : const Color(0xff1E293B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xff3B82F6)
                          : const Color(0xff334155),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    genre,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xff94A3B8),
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildFindButton() {
    final bool canSearch =
        _selectedLabel != null ||
        _selectedGenre != null ||
        _selectedLanguage != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: canSearch ? 1.0 : 0.5, // dims when disabled
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: canSearch
                  ? [const Color(0xFF3B82F6), const Color(0xFF7C3AED)]
                  : [const Color(0xFF1E293B), const Color(0xFF1E293B)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: canSearch
                ? [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Material(
            color: Colors.transparent, // keeps gradient visible
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: canSearch && !_isLoading ? _onFindTapped : null,
              borderRadius: BorderRadius.circular(16),
              // ripple clips to border
              splashColor: Colors.white.withOpacity(0.15),
              highlightColor: Colors.white.withOpacity(0.08),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          '✨ Find Me Something!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: canSearch ? Colors.white : const Color(0xFF94A3B8),
                            letterSpacing: 1.1,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDurationSlider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'MAX DURATION',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'Under ${_duration.toInt()} mins',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B82F6),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Slider ──────────────────────────────────────────────
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              // Track
              trackHeight: 3,
              activeTrackColor: const Color(0xFF3B82F6),
              inactiveTrackColor: const Color(0xFF1E293B),

              // Thumb — glowing blue circle like screenshot
              thumbColor: Colors.white,
              thumbShape: _GlowingThumbShape(),
              overlayShape: SliderComponentShape.noOverlay,

              // No tick marks
              showValueIndicator: ShowValueIndicator.never,
            ),
            child: Slider(
              value: _duration,
              min: 30,
              max: 180,
              onChanged: (val) => setState(() => _duration = val),
            ),
          ),

          // ── Min / Max labels ─────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '30m',
                  style: TextStyle(fontSize: 11, color: Color(0xFF475569)),
                ),
                Text(
                  '180m',
                  style: TextStyle(fontSize: 11, color: Color(0xFF475569)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onFindTapped() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Read API keys
      const geminiKey = ""; // Replace with your actual Gemini Key
      const tmdbKey = "";

      // 2. Gemini returns 20 suggestions
      final allSuggestions = await _geminiService.getSuggestionsDummy(
        apiKey: geminiKey,
        mood: _selectedLabel ?? 'Happy',
        genre: _selectedGenre ?? 'Any',
        language: _selectedLanguage ?? 'Any',
        maxDuration: _duration.toInt(),
      );

      // 3. TMDB enrichment for the first 5 items
      final firstBatch = await Future.wait(
        allSuggestions.take(5).map((s) =>
            _tmdbService.enrichSuggestion(s, tmdbKey)),
      );
      //i want to print poster url in log
      for(int i=0;i<firstBatch.length;i++){
        print("${firstBatch[i].poster_path} ====== ${firstBatch[i].title}");
      }

      // 4. Navigate with all results
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SuggestionScreen(
              loaded: firstBatch, // enriched, show now
              remaining: allSuggestions.skip(5).toList(), // raw, enrich later
              tmdbKey: tmdbKey,
              mood: _selectedLabel,
            ),
          ),
        );
      }
    } catch (e) {
      log("Error fetching suggestions: $e");
      setState(() => _errorMessage = "Oops! Something went wrong. Please try again.");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Enriches suggestions in batches to avoid TMDB rate limits
  Future<List<Suggestion>> _enrichInBatches(
    List<Suggestion> suggestions,
    String tmdbKey, {
    int batchSize = 5,
  }) async {
    final results = <Suggestion>[];

    for (int i = 0; i < suggestions.length; i += batchSize) {
      final batch = suggestions.sublist(
        i,
        (i + batchSize).clamp(0, suggestions.length),
      );

      // Run batch in parallel
      final batchResults = await Future.wait(
        batch.map((s) => _tmdbService.enrichSuggestion(s, tmdbKey)),
      );

      results.addAll(batchResults);

      // Small delay between batches — prevents TMDB 429 rate limit
      if (i + batchSize < suggestions.length) {
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }

    return results;
  }
}

class _MoodCard extends StatelessWidget {
  final MoodItem mood;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodCard({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Color(0xff1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Color(0xff3B82F6)
                : Color(0xff3B82F6).withOpacity(0.0),
            width: isSelected ? 1.8 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Color(0xff3B82F6).withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(3, 3),
                  ),
                ]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ── Bottom: label + subtitle ──
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(mood.emoji, style: const TextStyle(fontSize: 30)),
                  const SizedBox(height: 2),
                  Text(
                    mood.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Color(0xff3B82F6) : Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    mood.subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xff94A3B8).withOpacity(0.65),
                      letterSpacing: 0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlowingThumbShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(20, 20);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    // Outer glow ring (blue)
    canvas.drawCircle(
      center,
      16,
      Paint()
        ..color = const Color(0xFF3B82F6).withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Mid glow (stronger)
    canvas.drawCircle(
      center,
      10,
      Paint()
        ..color = const Color(0xFF3B82F6).withOpacity(0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // White center circle
    canvas.drawCircle(center, 9, Paint()..color = Colors.white);

    // Blue inner dot
    canvas.drawCircle(center, 4, Paint()..color = const Color(0xFF3B82F6));
  }
}

import 'package:flutter/material.dart';

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

// ─── Moods Data ──────────────────────────────────────────────────────────────

const List<MoodItem> kMoods = [
  MoodItem(
    emoji: '😄',
    // Big smile — genuinely happy/cheerful
    label: 'Happy',
    subtitle: 'Feel-good & fun',
  ),
  MoodItem(
    emoji: '😱',
    // Screaming face — edge-of-seat thrilling
    label: 'Thrilling',
    subtitle: 'Edge of your seat',
  ),
  MoodItem(
    emoji: '💕',
    // Two hearts — romantic mood
    label: 'Romantic',
    subtitle: 'Love is in the air',
  ),
  MoodItem(
    emoji: '👻',
    // Ghost — scary/horror mood
    label: 'Scary',
    subtitle: 'Spine-chilling horror',
  ),
  MoodItem(
    emoji: '😂',
    // Laughing tears — genuinely funny
    label: 'Funny',
    subtitle: 'Laugh out loud',
  ),
  MoodItem(
    emoji: '😢',
    // Crying face — emotional/sad mood
    label: 'Emotional',
    subtitle: 'Touch your heart',
  ),
  MoodItem(
    emoji: '🤯',
    // Mind blown — thought-provoking, twists
    label: 'Mind-bending',
    subtitle: 'Plot twists & mystery',
  ),
  MoodItem(
    emoji: '😴',
    // Sleepy — light, easy background watch
    label: 'Chill',
    subtitle: 'Easy background watch',
  ),
  MoodItem(
    emoji: '🤩',
    // Star eyes — inspired, uplifting content
    label: 'Inspired',
    subtitle: 'Motivating & uplifting',
  ),
  MoodItem(
    emoji: '😤',
    // Determined face — action-packed, intense
    label: 'Action-packed',
    subtitle: 'High-octane energy',
  ),
  MoodItem(
    emoji: '🧐',
    // Monocle — curious, documentary, learn
    label: 'Curious',
    subtitle: 'Documentaries & facts',
  ),
  MoodItem(
    emoji: '🥳',
    // Party face — celebratory, festive mood
    label: 'Celebratory',
    subtitle: 'Party & festive vibes',
  ),
];

const List<String> kGenres = [
  'Action',
  'Comedy',
  'Drama',
  'Sci-Fi',
  'Horror',
  'Romance',
  'Documentary',
  'Animation',
  'Thriller',
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedLabel;
  String? _selectedGenre;
  double _duration = 120; // default 120 mins

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
                  _buildDurationSlider(),
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
        padding: EdgeInsets.only(left: 10, top: 60, bottom: 10, right: 5),
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
    final bool canSearch = _selectedLabel != null || _selectedGenre != null;
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
              onTap: canSearch
                  ? () {
                      print("${_selectedLabel!}, ${_selectedGenre!}");
                    }
                  : null,
              borderRadius: BorderRadius.circular(16),
              // ripple clips to border
              splashColor: Colors.white.withOpacity(0.15),
              highlightColor: Colors.white.withOpacity(0.08),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: Center(
                  child: Text(
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
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF475569),
                  ),
                ),
                Text(
                  '180m',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
    canvas.drawCircle(
      center,
      9,
      Paint()..color = Colors.white,
    );

    // Blue inner dot
    canvas.drawCircle(
      center,
      4,
      Paint()..color = const Color(0xFF3B82F6),
    );
  }
}

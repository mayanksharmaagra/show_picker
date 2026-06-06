import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'HomeScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  //------------Animation Controller ----------------
  late final AnimationController _taglineController;
  late final AnimationController _glowController;
  late final AnimationController _nameController;
  late final AnimationController _logoController;
  late final AnimationController _dot1Controller;
  late final AnimationController _dot2Controller;
  late final AnimationController _dot3Controller;

  //-----------Animation-----------------------------
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _nameFade;
  late final Animation<Offset> _nameSlide;
  late final Animation<double> _taglineFade;
  late final Animation<double> _dot1;
  late final Animation<double> _dot1Opacity;
  late final Animation<double> _dot2;
  late final Animation<double> _dot2Opacity;
  late final Animation<double> _dot3;
  late final Animation<double> _dot3Opacity;

  late final Animation<double> _glowPulse;

  //------------Life cycle------------
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _setUpController();
    _setUpAnimation();
    _runSequence();
    // Navigate after 5 seconds
    // Future.delayed(const Duration(seconds: 5), () {
    //   if (mounted) {
    //     SystemChrome.setEnabledSystemUIMode(
    //       SystemUiMode.edgeToEdge,
    //     );
    //
    //     context.go('/home'); // or '/home'
    //   }
    // });
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    });
  }

  void _setUpController() {
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _nameController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    // dot-jump: 1500 ms loop each
    _dot1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _dot2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _dot3Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  void _setUpAnimation() {
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _logoScale = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 1.0, curve: Curves.elasticOut),
      ),
    );

    // ── App Name ──
    _nameFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _nameController, curve: Curves.easeOut));

    _nameSlide = Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _nameController, curve: Curves.easeOutCubic),
        );

    // ── Tagline ──
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeIn),
    );

    // ── Loading Dots (staggered bounce) ──
    _dot1 = _buildDotScaleAnim(_dot1Controller);
    _dot1Opacity = _buildDotOpacityAnim(_dot1Controller);
    _dot2 = _buildDotScaleAnim(_dot2Controller);
    _dot2Opacity = _buildDotOpacityAnim(_dot2Controller);
    _dot3 = _buildDotScaleAnim(_dot3Controller);
    _dot3Opacity = _buildDotOpacityAnim(_dot3Controller);

    // ── Glow Pulse ──
    _glowPulse = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }
  Animation<double> _buildDotScaleAnim(AnimationController ctrl) {
    return TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.5)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.5, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(ctrl);
  }

  Animation<double> _buildDotOpacityAnim(AnimationController ctrl) {
    return TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.3, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.3)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(ctrl);
  }

  Future<void> _runSequence() async {
    // Step 1: Logo fade + scale
    await _logoController.forward();

    // Step 2: Glow starts pulsing (infinite)
    _glowController.repeat(reverse: true);

    // Step 3: App name slides up (200ms after logo)
    await Future.delayed(const Duration(milliseconds: 200));
    await _nameController.forward();

    // Step 4: Tagline fades in (100ms after name)
    await Future.delayed(const Duration(milliseconds: 100));
    _taglineController.forward();

    // Step 5: Dots start with staggered delays matching HTML (0s, 0.2s, 0.4s)
    await Future.delayed(const Duration(milliseconds: 200));
    _dot1Controller.repeat();
    await Future.delayed(const Duration(milliseconds: 200));
    _dot2Controller.repeat();
    await Future.delayed(const Duration(milliseconds: 200));
    _dot3Controller.repeat();

    // Step 6: Navigate after total ~2800ms from app start
    await Future.delayed(const Duration(milliseconds: 900));

  }

  @override
  void dispose() {
    _logoController.dispose();
    _nameController.dispose();
    _taglineController.dispose();
    _dot1Controller.dispose();
    _dot2Controller.dispose();
    _dot3Controller.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: Stack(
        children: [
          _buildBackgroundGlow(),
          _logoWithAppTitle(),
          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _logoWithAppTitle() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo icon with glow ring
          _buildLogoSection(),
          const SizedBox(height: 24),

          // App name
          _buildAppName(),

          const SizedBox(height: 10),

          // Tagline
          _buildTagline(),
        ],
      ),
    );
  }

  Widget _buildBackgroundGlow() {
    return Positioned.fill(child: CustomPaint(painter: _RadialGlowPainter()));
  }

  Widget _buildLogoSection() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoController, _glowController]),
      builder: (context, _) {
        return FadeTransition(
          opacity: _logoFade,
          child: ScaleTransition(
            scale: _logoScale,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow ring (pulsing)
                Container(
                  width: 106 + (_glowPulse.value * 12),
                  height: 106 + (_glowPulse.value * 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0xFF3B82F6,
                        ).withOpacity(0.15 + _glowPulse.value * 0.2),
                        blurRadius: 28 + _glowPulse.value * 14,
                        spreadRadius: 4 + _glowPulse.value * 6,
                      ),
                    ],
                  ),
                ),

                // Icon container
                Image.asset(
                  "assets/images/app_icon.png",
                  width: 120,
                  height: 120,
                ),
                // Container(
                //   width: 90,
                //   height: 90,
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(24),
                //     gradient: const LinearGradient(
                //       begin: Alignment.topLeft,
                //       end: Alignment.bottomRight,
                //       colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)],
                //     ),
                //     boxShadow: [
                //       BoxShadow(
                //         color: const Color(0xFF3B82F6).withOpacity(0.45),
                //         blurRadius: 24,
                //         offset: const Offset(0, 8),
                //       ),
                //       BoxShadow(
                //         color: const Color(0xFF7C3AED).withOpacity(0.3),
                //         blurRadius: 16,
                //         offset: const Offset(0, 4),
                //       ),
                //     ],
                //   ),
                //   child: const Center(
                //     child: Text(
                //       '✨',
                //       style: TextStyle(fontSize: 40),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppName() {
    return AnimatedBuilder(
      animation: _nameController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _nameFade,
          child: SlideTransition(position: _nameSlide, child: child),
        );
      },
      child: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFCBD5E1)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(bounds),
        child: const Text(
          'Show Picker',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 1.5,
            height: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildTagline() {
    return FadeTransition(
      opacity: _taglineFade,
      child: const Text(
        'Find your perfect watch tonight',
        style: TextStyle(
          fontSize: 15,
          fontStyle: FontStyle.italic,
          color: Color(0xFF94A3B8),
          letterSpacing: 0.3,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 48,
      child: Column(
        children: [
          AnimatedBuilder(
            animation:
            Listenable.merge([_dot1Controller, _dot2Controller, _dot3Controller]),
            builder: (context, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDot(_dot1, _dot1Opacity),
                  const SizedBox(width: 12),
                  _buildDot(_dot2, _dot2Opacity),
                  const SizedBox(width: 12),
                  _buildDot(_dot3, _dot3Opacity),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          FadeTransition(
            opacity: _taglineFade,
            child: const Text(
              'Powered by Claude AI',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF475569),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(Animation<double> scaleAnim, Animation<double> opacityAnim) {
    return Transform.scale(
      scale: scaleAnim.value,
      child: Opacity(
        opacity: opacityAnim.value,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF3B82F6),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.5 * opacityAnim.value),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadialGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.55,
        colors: [
          const Color(0xFF1E3A5F).withOpacity(0.18),
          const Color(0xFF0F172A).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_RadialGlowPainter oldDelegate) => false;
}

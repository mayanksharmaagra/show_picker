import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: Stack(children: [_logoWithAppTitle(), _dotsWithTagline()]),
    );
  }

  Widget _logoWithAppTitle() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/app_icon.png", width: 200, height: 200),
          Text(
            "SHOW PICKER",
            style: TextStyle(color: Colors.white, fontSize: 35),
          ),
          Text(
            "Find your perfect watch tonight",
            style: TextStyle(color: Color(0xff94A3B8), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _dotsWithTagline() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 35,
      child: Column(
        children: [
          _dotsCreate(),
          const SizedBox(height: 18),
          Text(
            'Powered by Claude AI',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF475569),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dotsCreate() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDot(),
        const SizedBox(width: 8),
        _buildDot(),
        const SizedBox(width: 8),
        _buildDot(),
      ],
    );
  }

  Widget _buildDot() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF334155),
        boxShadow: null,
      ),
    );
  }
}

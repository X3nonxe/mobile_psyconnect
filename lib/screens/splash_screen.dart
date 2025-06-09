import 'dart:async';
import 'package:flutter/material.dart';
import 'package:psyconnect/config/color_pallate.dart';
import 'package:psyconnect/screens/onboarding/on_boarding.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToOnBoarding();
  }

  Future<void> _navigateToOnBoarding() async {
    await Future.delayed(const Duration(seconds: 3));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OnBoardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: bluePrimaryColor,
      body: Center(
        child: Container(
          height: screenHeight * 0.2,
          width: screenHeight * 1,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/logo-test.png"),
            ),
          ),
        ),
      ),
    );
  }
}

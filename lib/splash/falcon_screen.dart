import 'package:flutter/material.dart';
import 'splash_screen.dart';

// FalconScreen delegates directly to high-clarity SplashScreen
class FalconScreen extends StatelessWidget {
  const FalconScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}

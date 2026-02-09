import 'package:flutter/material.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate to HomeScreen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // CRITICAL: Set background to Black
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or splash image
            Image.asset(
              'assets/images/cover.png',
              width: 150, // Slightly reduced logo size
              height: 150,
              fit: BoxFit.contain,
              // Optional: You might need to adjust the actual image file 
              // to ensure it looks good on a black background.
            ),
            const SizedBox(height: 20),
            
            // Loading indicator (White)
            const CircularProgressIndicator(color: Colors.white), 
            const SizedBox(height: 30),
            
            // App Name (White Text)
            const Text(
              'Dagbani Hymn App', // Corrected name
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold, 
                color: Colors.white, // CRITICAL: White text for black background
              ),
            ),
            const SizedBox(height: 8),

            // Attribution Text (White Text)
            const Text(
              'Powered by Nasara congregation, Kootingli',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14, 
                color: Colors.white70, // Slightly dimmer white for attribution
              ),
            ),
          ],
        ),
      ),
    );
  }
}
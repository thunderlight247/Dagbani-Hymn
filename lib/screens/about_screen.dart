import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About This App')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Dagbani Hymn Book App',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "This app was developed and is managed by Light Tech Company. "
              "It has been officially acknowledged and approved by the Northern Presbyterian Chairman "
              "together with other notable Presbyterian leaders.\n\n"
              "The Dagbani Hymn Book App is designed to provide an offline-first hymn experience, "
              "making worship accessible anytime and anywhere.\n\n"
              "For inquiries or support, you can reach us at:\n"
              "📧 info@lighttechcompany.com\n"
              "📱 WhatsApp: 0594273358\n\n"
              "Thank you for using the Dagbani Hymn Book App.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 24),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Northern Presbyterian Church History'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Intro Section ---
            Text(
              'A Gentle Heritage',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "This section warmly shares the story of the Northern Presbyterian Church — "
              "its beginnings, growth, and the faithful communities that shaped its journey. "
              "The content will be stored offline so readers can enjoy it anytime, even without internet.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 12),
            const Text(
              "Note: This is just an example placeholder. Future updates will include the full historical narrative, "
              "organized chronologically with detailed accounts of the church’s journey.",
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, height: 1.4),
            ),

            const SizedBox(height: 24),

            // --- Section 1 ---
            Text(
              '1. Early Foundations (1828 - 1884)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Here we will gently narrate the arrival of missionaries, the first congregations, "
              "and the seeds of faith planted in Northern Ghana. This period highlights the courage "
              "and dedication of early believers who laid the foundation for the church’s presence.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 24),

            // --- Section 2 ---
            Text(
              '2. Growth and Expansion (1885 - 1950)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Stories of new congregations, schools, and community impact will be placed here, "
              "showing how the church expanded its reach and became a trusted partner in education, "
              "health, and social transformation across the Northern Region.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 24),

            // --- Section 3 ---
            Text(
              '3. Modern Developments (1951 - Present)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "This section will highlight the modern era — leadership, new congregations, "
              "and the evolving role of the Northern Presbyterian Church in Ghana’s spiritual "
              "and social life. It will celebrate the resilience and faith of communities "
              "that continue to grow and serve.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 24),

            // --- Closing ---
            Text(
              'Looking Ahead',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "The Northern Presbyterian Church history is not just about the past — "
              "it is a living story of faith, service, and community. This section will continue "
              "to grow as new chapters are written by today’s congregations and tomorrow’s leaders.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Northern Presbytery History'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Hero Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.church_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Northern Presbytery',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Presbyterian Church of Ghana',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Languages Note Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.translate_rounded, color: Colors.amber.shade900, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hymn Languages & Vision',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'This hymn application comprises many languages to celebrate worship across our diverse congregations. '
                          'The development team is actively focusing on Dagbani for this release, and will feature additional languages '
                          'in upcoming future updates.',
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.45,
                            color: Colors.amber.shade900.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- Intro Section ---
            Text(
              'A Gentle Heritage',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "This section warmly shares the story of the Northern Presbytery — "
              "its beginnings, growth, and the faithful communities that shaped its journey. "
              "The content will be stored offline so readers can enjoy it anytime, even without internet.",
              style: TextStyle(fontSize: 15.5, height: 1.5),
            ),
            const SizedBox(height: 10),
            const Text(
              "Note: This is an introductory overview. Future updates will include the full chronological narrative "
              "with detailed accounts of the presbytery's journey and ministries.",
              style: TextStyle(fontSize: 13.5, fontStyle: FontStyle.italic, color: Colors.grey, height: 1.4),
            ),

            const SizedBox(height: 24),

            // --- Section 1 ---
            Text(
              '1. Early Foundations (1828 - 1884)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Here we narrate the arrival of missionaries, the first congregations, "
              "and the seeds of faith planted in Northern Ghana. This period highlights the courage "
              "and dedication of early believers who laid the foundation for the presbytery's presence.",
              style: TextStyle(fontSize: 15, height: 1.5),
            ),

            const SizedBox(height: 24),

            // --- Section 2 ---
            Text(
              '2. Growth and Expansion (1885 - 1950)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Stories of new congregations, schools, and community impact will be placed here, "
              "showing how the church expanded its reach and became a trusted partner in education, "
              "health, and social transformation across the Northern Presbytery.",
              style: TextStyle(fontSize: 15, height: 1.5),
            ),

            const SizedBox(height: 24),

            // --- Section 3 ---
            Text(
              '3. Modern Developments (1951 - Present)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "This section highlights the modern era — leadership, new congregations, "
              "and the evolving role of the Northern Presbytery in Ghana’s spiritual "
              "and social life. It celebrates the resilience and faith of communities "
              "that continue to grow and serve.",
              style: TextStyle(fontSize: 15, height: 1.5),
            ),

            const SizedBox(height: 24),

            // --- Closing ---
            Text(
              'Looking Ahead',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "The Northern Presbytery history is not just about the past — "
              "it is a living story of faith, service, and community. This section will continue "
              "to grow as new chapters are written by today’s congregations and tomorrow’s leaders.",
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/*import 'package:flutter/material.dart';
import '../models/hymn.dart';
import 'hymn_detail.dart';

class ContentPage extends StatelessWidget {
  final List<Hymn> hymns;

  const ContentPage({super.key, required this.hymns});

  @override
  Widget build(BuildContext context) {
    if (hymns == null || hymns.isEmpty) {
      return const Center(child: Text('No hymns found.'));
    }
    return ListView.builder(
      itemCount: hymns.length,
      itemBuilder: (context, index) {
        final hymn = hymns[index];
        return ListTile(
          title: Text('${hymn.number} - ${hymn.title} (Page ${hymn.page ?? 'N/A'})'),
          onTap: () {
            if (hymn != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HymnDetail(hymn: hymn)),
              );
            }
          },
        );
      },
    );
  }
}*/
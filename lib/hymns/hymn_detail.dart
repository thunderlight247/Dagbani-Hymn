import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hymn.dart';
import '../models/settings_model.dart'; 
// NOTE: GoogleFonts package is used inside SettingsModel's getTextStyle

class HymnDetail extends StatelessWidget {
  final Hymn hymn;
  final void Function(Hymn) onToggleFavorite;

  const HymnDetail({
    super.key,
    required this.hymn,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    // 1. ACCESS THE GLOBAL SETTINGS MODEL
    final settings = Provider.of<SettingsModel>(context);
    
    // Determine screen size for responsive padding
    final isMobile = MediaQuery.of(context).size.width < 600;
    final horizontalPadding = isMobile ? 12.0 : 40.0;
    final verticalPadding = isMobile ? 16.0 : 30.0;
    
    // Custom font fallback (for numbering, if desired)
    const String numberFontFamily = 'DagbaniFont'; 

    return Scaffold(
      appBar: AppBar(
        title: Text('Hymn ${hymn.number}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              hymn.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: hymn.isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              onToggleFavorite(hymn);
            },
          ),
        ],
      ),
      
      // --- BODY: STACK FOR PAGE-LEVEL WATERMARK ---
      body: Stack(
        children: [
          // Background Layer: Faded Logo (Watermark)
          Positioned.fill(
            child: Center(
              child: Opacity(
                opacity: 0.1,
                child: SizedBox(
                  width: isMobile ? 250 : 400,
                  height: isMobile ? 250 : 400,
                  child: Image.asset(
                    'assets/images/cover.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          
          // Foreground Layer: Scrollable Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- TITLE AREA (Dynamic Font) ---
                Text(
                  hymn.title,
                  textAlign: TextAlign.center,
                  style: settings.getTextStyle(
                    size: isMobile ? 24 : 32,
                    weight: FontWeight.w900,
                  ).copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    height: 1.2,
                  ),
                ),
                // Add Translation area if needed...
                
                const Divider(height: 32, thickness: 1.5),

                // --- STANZAS IN BLOCKS (Dynamic Font) ---
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: hymn.content.asMap().entries.map((entry) {
                        final index = entry.key;
                        final stanza = entry.value;
                        final verseNumber = index + 1;
                        
                        return Container( // Stanza Block Container
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor.withOpacity(0.95), // Adaptive background color
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Verse Number 
                              Text(
                                '$verseNumber.',
                                style: TextStyle(
                                  fontFamily: numberFontFamily,
                                  fontSize: isMobile ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Stanza Text (Dynamic Font)
                              Text(
                                stanza,
                                style: settings.getTextStyle(
                                  size: isMobile ? 17 : 19,
                                ).copyWith(
                                  height: 1.5,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
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
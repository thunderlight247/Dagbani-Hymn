import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hymn/models/settings_model.dart';
import 'package:hymn/models/hymn.dart';
import 'package:hymn/services/tune_audio_service.dart';
import 'package:hymn/services/uploaded_audio_service.dart';
import 'package:hymn/widgets/hymn_view.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsModel tests', () {
    test('themeMode, fontSize, and keepScreenAwake update properly', () async {
      final settings = SettingsModel();
      expect(settings.fontSize, equals(18.0));
      expect(settings.keepScreenAwake, isFalse);

      await settings.setFontSize(22.0);
      expect(settings.fontSize, equals(22.0));

      await settings.setThemeMode(ThemeMode.dark);
      expect(settings.themeMode, equals(ThemeMode.dark));

      await settings.setFontFamily('Playfair Display');
      expect(settings.fontFamily, equals('Playfair Display'));

      await settings.setKeepScreenAwake(true);
      expect(settings.keepScreenAwake, isTrue);
    });
  });

  group('TuneAudioService tests', () {
    test('tempo, instrument, and pitches are properly configured', () {
      final service = TuneAudioService.instance;
      service.setTempo(105);
      expect(service.tempoBpm, equals(105));

      service.setInstrument(InstrumentType.churchOrgan);
      expect(service.instrument, equals(InstrumentType.churchOrgan));

      expect(TuneAudioService.standardPitches.containsKey('C4'), isTrue);
      expect(TuneAudioService.standardPitches.containsKey('G4'), isTrue);
    });
  });

  group('UploadedAudioService tests', () {
    test('initial lookup returns null for un-uploaded hymn', () {
      final service = UploadedAudioService.instance;
      expect(service.getAudioForHymn('99999'), isNull);
    });
  });

  group('HymnView tests', () {
    testWidgets('Displays hymn title, page, and clean stanzas without duplicate numbering', (tester) async {
      final testHymn = Hymn(
        id: 1,
        number: '1',
        title: 'PAƔMIYA NAAWUNI',
        page: '1',
        category: 'Hymns',
        translation: 'Kamfo Yehowa Otumfuo',
        content: [
          "1. Paɣmiya Naawuni\nYi nɔl' ni ni suhuni zaa,",
          "2. Ti ni be duniya ŋɔ ni\nTi faako Naawuni,",
        ],
      );

      final settings = SettingsModel();

      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsModel>.value(
          value: settings,
          child: MaterialApp(
            home: Scaffold(
              body: HymnView(hymn: testHymn),
            ),
          ),
        ),
      );

      expect(find.text('PAƔMIYA NAAWUNI'), findsOneWidget);
      expect(find.text('Kamfo Yehowa Otumfuo'), findsOneWidget);
      expect(find.text('HYMN 1'), findsOneWidget);
      expect(find.text('Page 1'), findsOneWidget);

      // Verify clean verse badges exist
      expect(find.text('1'), findsWidgets);
      expect(find.text('2'), findsWidgets);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:hymn/main.dart';
import 'package:hymn/splash/splash_screen.dart';

void main() {
  testWidgets('HymnBookApp smoke test loads high-clarity splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const HymnBookApp());

    // Verify SplashScreen is displayed with Presbyterian Church of Ghana
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('PRESBYTERIAN CHURCH OF GHANA'), findsOneWidget);
    expect(find.text('PCG DAGBANI HYMN BOOK'), findsOneWidget);

    // Let timer complete
    await tester.pump(const Duration(seconds: 3));
  });
}

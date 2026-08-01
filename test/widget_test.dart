import 'package:flutter_test/flutter_test.dart';

import 'package:kirisiyo_app/main.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const KirisiyoApp());
    // Şimdilik sadece uygulamanın çökmeden başladığını doğruluyoruz.
    // Gerçek ekranlar yazıldıkça buraya anlamlı testler eklenecek.
    expect(find.byType(KirisiyoApp), findsOneWidget);
  });
}
import 'package:flutter_test/flutter_test.dart';

import 'package:lara_demo/main.dart';
import 'package:lara_demo/shared/daily_bonus_dialog.dart';

void main() {
  setUp(DailyBonusDialog.suppressForTest);

  testWidgets('App boots and shows the home greeting', (tester) async {
    await tester.pumpWidget(const AmigosDeLaraApp());
    await tester.pump();
    expect(find.text('¡Hola Amiguitos!'), findsOneWidget);
  });
}

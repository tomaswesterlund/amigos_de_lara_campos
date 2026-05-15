import 'package:flutter_test/flutter_test.dart';

import 'package:lara_demo/main.dart';

void main() {
  testWidgets('App boots and shows the home greeting', (tester) async {
    await tester.pumpWidget(const LaraDemoApp());
    await tester.pump();
    expect(find.text('¡Hola Amiguitos!'), findsOneWidget);
  });
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homestay_app/widgets/section_pager.dart';

void main() {
  testWidgets('wheel changes section, buttons return, swipe changes section',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: SectionPager(
      labels: ['First', 'Second'],
      children: [Text('First content'), Text('Second content')],
    ))));
    await tester.sendEventToBinding(const PointerScrollEvent(
        position: Offset(400, 250), scrollDelta: Offset(0, 100)));
    await tester.pumpAndSettle();
    expect(find.text('2/2 · Second'), findsOneWidget);
    await tester.tap(find.byTooltip('Phần trước'));
    await tester.pumpAndSettle();
    expect(find.text('1/2 · First'), findsOneWidget);
    await tester.drag(find.text('First content'), const Offset(0, -220));
    await tester.pumpAndSettle();
    expect(find.text('2/2 · Second'), findsOneWidget);
  });

  testWidgets('long sections scroll before advancing', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: SectionPager(
      labels: ['Long', 'Next'],
      children: [
        SizedBox(height: 1500, child: Text('Long content')),
        Text('Next content')
      ],
    ))));
    await tester.sendEventToBinding(const PointerScrollEvent(
        position: Offset(400, 250), scrollDelta: Offset(0, 200)));
    await tester.pumpAndSettle();
    expect(find.text('1/2 · Long'), findsOneWidget);
    final scroll = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView).first);
    expect(scroll.controller!.offset, 200);
    expect(tester.takeException(), isNull);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homestay_app/main.dart';
import 'package:homestay_app/widgets/galaxy_header.dart';
import 'package:homestay_app/screens/customer/rooms_screen.dart';

void main() {
  for (final width in [390.0, 1440.0]) {
    testWidgets('persistent galaxy navigation at $width', (tester) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const HomestayApp());
      await tester.pumpAndSettle();
      final header = tester.element(find.byType(GalaxyHeader));
      if (width < 1180) {
        await tester.tap(find.byKey(const ValueKey('galaxy-menu')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Phòng').last);
      } else {
        await tester.tap(find.text('Phòng').first);
      }
      await tester.pumpAndSettle();
      expect(find.byType(RoomsScreen), findsOneWidget);
      expect(tester.element(find.byType(GalaxyHeader)), same(header));
      HomestayApp.navigatorKey.currentState!.pushNamed('/login');
      await tester.pumpAndSettle();
      expect(tester.element(find.byType(GalaxyHeader)), same(header));
      expect(tester.takeException(), isNull);
    });
  }
}


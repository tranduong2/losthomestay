import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:homestay_app/providers/app_provider.dart';
import 'package:homestay_app/screens/customer/rooms_screen.dart';

void main() {
  for (final width in [390.0, 1400.0]) {
    testWidgets('rooms route fits $width', (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(ChangeNotifierProvider(
          create: (_) => AppProvider(),
          child: MaterialApp(
              home: const Scaffold(),
              routes: {'/rooms': (_) => const RoomsScreen()})));
      tester
          .state<NavigatorState>(find.byType(Navigator).first)
          .pushNamed('/rooms');
      await tester.pumpAndSettle();
      expect(find.byType(RoomsScreen), findsOneWidget);
      expect(find.text('Danh sách phòng'), findsOneWidget);
      expect(tester.takeException(), isNull);
      tester.state<NavigatorState>(find.byType(Navigator).first).pop();
      await tester.pumpAndSettle();
      expect(find.byType(RoomsScreen), findsNothing);
    });
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homestay_app/main.dart';
import 'package:homestay_app/widgets/galaxy_header.dart';
import 'package:homestay_app/providers/app_provider.dart';
import 'package:provider/provider.dart';
import 'package:homestay_app/screens/customer/rooms_screen.dart';
import 'package:homestay_app/screens/customer/profile_screen.dart';

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

  testWidgets('shows customer icon and name after login', (tester) async {
    final provider = AppProvider();
    await provider.login('khach@gmail.com', '123456');
    String? route;
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: provider,
      child: MaterialApp(
          home: Scaffold(
              body: GalaxyHeader(
        onNavigate: (value) => route = value,
      ))),
    ));

    expect(find.byIcon(Icons.account_circle), findsOneWidget);
    expect(find.text('Nguyễn Văn A'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsNothing);
    expect(find.text('Đăng ký'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('customer-account')));
    expect(route, '/profile');
  });

  testWidgets('account icon opens only one profile route', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const HomestayApp());
    final provider =
        tester.element(find.byType(GalaxyHeader)).read<AppProvider>();
    await provider.login('khach@gmail.com', '123456');
    await tester.pump();

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byKey(const ValueKey('customer-account')));
    }
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);

    HomestayApp.navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsNothing);
  });
}

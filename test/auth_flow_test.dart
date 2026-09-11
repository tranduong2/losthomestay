import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:homestay_app/providers/app_provider.dart';
import 'package:homestay_app/screens/auth/register_screen.dart';
import 'package:homestay_app/screens/auth/login_screen.dart';
import 'package:homestay_app/screens/customer/main_navigation.dart';

void main() {
  testWidgets('registration requires login, then opens customer home', (tester) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final provider = AppProvider();
    await tester.pumpWidget(ChangeNotifierProvider.value(value: provider,
      child: const MaterialApp(home: RegisterScreen())));
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Khách kiểm thử');
    await tester.enterText(fields.at(1), 'flow@example.com');
    await tester.enterText(fields.at(2), '0901234567');
    await tester.enterText(fields.at(3), 'secret123');
    await tester.tap(find.text('Đăng ký'));
    await tester.pumpAndSettle();
    expect(provider.isLoggedIn, isFalse);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Đăng ký thành công! Vui lòng đăng nhập để tiếp tục.'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'flow@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng nhập'));
    await tester.pumpAndSettle();
    expect(provider.isLoggedIn, isTrue);
    expect(find.byType(MainNavigation), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });
}

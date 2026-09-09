import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:homestay_app/providers/app_provider.dart';
import 'package:homestay_app/screens/customer/booking_screen.dart';
import 'package:homestay_app/screens/customer/payment_screen.dart';

void main() {
  for (final width in [390.0, 1400.0]) {
    testWidgets('booking form validates and passes contact at $width',
        (tester) async {
      tester.view.physicalSize = Size(width, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final provider = AppProvider();
      await tester.pumpWidget(ChangeNotifierProvider.value(
          value: provider,
          child: MaterialApp(
              home: BookingScreen(
                  room: provider.rooms.first,
                  initialCheckIn: DateTime.now().add(const Duration(days: 1)),
                  initialCheckOut:
                      DateTime.now().add(const Duration(days: 3))))));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final button = find.text('Xác nhận đặt phòng');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.text('Vui lòng nhập họ và tên'), findsOneWidget);
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Nguyễn An');
      await tester.enterText(fields.at(1), '0901234567');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      final payment = tester.widget<PaymentScreen>(find.byType(PaymentScreen));
      expect(payment.contactName, 'Nguyễn An');
      expect(payment.contactPhone, '0901234567');
      expect(payment.total, provider.rooms.first.pricePerNight * 2);
      expect(tester.takeException(), isNull);
    });
  }
}

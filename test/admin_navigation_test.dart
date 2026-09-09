import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:homestay_app/providers/app_provider.dart';
import 'package:homestay_app/models/booking_model.dart';
import 'package:homestay_app/screens/admin/admin_main_navigation.dart';
import 'package:homestay_app/utils/app_theme.dart';

void main() {
  for (final width in [390.0, 1440.0]) {
    testWidgets('admin pages and booking search work at $width',
        (tester) async {
      tester.view.physicalSize = Size(width, width >= 1000 ? 768 : 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final p = AppProvider()..login('admin@homestay.com', 'admin123');
      await tester.pumpWidget(ChangeNotifierProvider.value(
          value: p,
          child: MaterialApp(
              theme: AppTheme.dark(), home: const AdminMainNavigation())));
      await tester.pumpAndSettle();
      expect(find.text('Tổng quan vận hành'), findsOneWidget);
      expect(tester.takeException(), isNull);
      for (final i in [1, 3, 4, 2]) {
        final finder = width >= 1000
            ? find.widgetWithText(
                ListTile,
                const [
                  'Tổng quan',
                  'Quản lý phòng',
                  'Đơn đặt phòng',
                  'Dọn phòng',
                  'Lịch lưu trú'
                ][i])
            : find.byType(NavigationDestination).at(i);
        await tester.tap(finder);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      final pending =
          p.bookings.firstWhere((b) => b.status == BookingStatus.pending);
      await tester.enterText(find.byType(TextField).first, pending.id);
      await tester.pumpAndSettle();
      expect(find.text(pending.roomName), findsOneWidget);
      final confirm = find.widgetWithText(FilledButton, 'Xác nhận');
      await tester.ensureVisible(confirm);
      await tester.tap(confirm);
      await tester.pumpAndSettle();
      expect(pending.status, BookingStatus.confirmed);
      expect(tester.takeException(), isNull);
    });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homestay_app/data/mock_data.dart';
import 'package:homestay_app/widgets/rooms_catalog.dart';

void main() {
  testWidgets('catalog filters by category, guests and price and resets',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
      child: RoomsCatalog(
          rooms: MockData.rooms.take(5).toList(), onDetails: (_) {}, onBook: (_) {}),
    ))));
    expect(find.text('Tìm thấy 5 phòng'), findsOneWidget);
    expect(find.text('Villa Riêng Tư'), findsNothing);
    await tester.ensureVisible(find.byTooltip('Trang sau'));
    await tester.tap(find.byTooltip('Trang sau'));
    await tester.pumpAndSettle();
    expect(find.text('Villa Riêng Tư'), findsOneWidget);
    expect(find.text('Phòng Garden View'), findsNothing);
    await tester.ensureVisible(find.widgetWithText(ChoiceChip, 'Suite'));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Suite'));
    await tester.pumpAndSettle();
    expect(find.text('Tìm thấy 1 phòng'), findsOneWidget);
    expect(find.text('Villa Riêng Tư'), findsOneWidget);
    await tester.tap(find.text('Đặt lại bộ lọc'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Tăng số khách'));
    await tester.pumpAndSettle();
    expect(find.text('Tìm thấy 4 phòng'), findsOneWidget);
    final slider = tester.widget<Slider>(find.byType(Slider));
    slider.onChanged!(0);
    await tester.pumpAndSettle();
    expect(find.text('Chưa tìm thấy phòng phù hợp'), findsOneWidget);
    await tester.tap(find.text('Xóa bộ lọc'));
    await tester.pumpAndSettle();
    expect(find.text('Tìm thấy 5 phòng'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('catalog fits a mobile viewport', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
      child: RoomsCatalog(
          rooms: MockData.rooms.take(5).toList(), onDetails: (_) {}, onBook: (_) {}),
    ))));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}


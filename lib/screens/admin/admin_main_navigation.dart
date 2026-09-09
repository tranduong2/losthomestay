import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../utils/app_theme.dart';
import '../auth/login_screen.dart';
import 'admin_ui.dart';
import 'admin_dashboard_screen.dart';
import 'admin_rooms_screen.dart';
import 'admin_cleaning_screen.dart';
import 'admin_schedule_screen.dart';
import 'admin_bookings_screen.dart';

class AdminMainNavigation extends StatefulWidget {
  const AdminMainNavigation({super.key});
  @override
  State<AdminMainNavigation> createState() => _AdminMainNavigationState();
}

class _AdminMainNavigationState extends State<AdminMainNavigation> {
  int _index = 0;
  static const labels = [
    'Tổng quan',
    'Quản lý phòng',
    'Đơn đặt phòng',
    'Dọn phòng',
    'Lịch lưu trú'
  ];
  static const icons = [
    Icons.space_dashboard_outlined,
    Icons.bed_outlined,
    Icons.receipt_long_outlined,
    Icons.cleaning_services_outlined,
    Icons.calendar_month_outlined
  ];
  void _select(int i) => setState(() => _index = i);
  void _logout() {
    context.read<AppProvider>().logout();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    final screens = [
      AdminDashboardScreen(onNavigate: _select),
      const AdminRoomsScreen(),
      const AdminBookingsScreen(),
      const AdminCleaningScreen(),
      const AdminScheduleScreen()
    ];
    return Theme(
        data: AppTheme.dark().copyWith(
          scaffoldBackgroundColor: adminBg,
          cardTheme: CardThemeData(
              color: adminPanel,
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(color: adminLine))),
          dividerTheme: const DividerThemeData(color: adminLine),
        ),
        child: Scaffold(
          backgroundColor: adminBg,
          body: SafeArea(
              child: Row(children: [
            if (wide)
              SizedBox(
                  width: 246,
                  child: Material(
                      color: adminPanel,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                                padding: EdgeInsets.all(26),
                                child: Row(children: [
                                  Icon(Icons.blur_on,
                                      color: adminBlue, size: 34),
                                  SizedBox(width: 12),
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('LOST',
                                            style: TextStyle(
                                                fontSize: 26,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 5)),
                                        Text('HOMESTAY MANAGER',
                                            style: TextStyle(
                                                fontSize: 8,
                                                color: AppTheme.muted,
                                                letterSpacing: .8))
                                      ])
                                ])),
                            const Padding(
                                padding: EdgeInsets.fromLTRB(26, 20, 26, 12),
                                child: Text('KHÔNG GIAN QUẢN TRỊ',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: AppTheme.muted,
                                        letterSpacing: 1.3))),
                            ...List.generate(
                                labels.length,
                                (i) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 4),
                                    child: ListTile(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        selected: _index == i,
                                        selectedTileColor:
                                            const Color(0xFF1B3958),
                                        selectedColor: adminBlue,
                                        leading: Icon(icons[i], size: 21),
                                        title: Text(labels[i],
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600)),
                                        onTap: () => _select(i)))),
                            const Spacer(),
                            if (MediaQuery.sizeOf(context).height >= 800)
                              Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: AdminPanel(
                                      padding: const EdgeInsets.all(14),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.nightlight_round,
                                                color: adminBlue),
                                            const SizedBox(height: 10),
                                            const Text('Một kỳ nghỉ đáng nhớ',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w700)),
                                            const SizedBox(height: 6),
                                            Text(
                                                '${provider.rooms.length} phòng · LOST Đà Lạt',
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppTheme.muted)),
                                          ]))),
                            const Divider(height: 1),
                            ListTile(
                                leading: const CircleAvatar(
                                    radius: 17,
                                    child:
                                        Icon(Icons.person_outline, size: 19)),
                                title: Text(
                                    provider.currentUser?.name ??
                                        'Quản trị viên',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13)),
                                subtitle: const Text('Quản trị viên',
                                    style: TextStyle(fontSize: 11)),
                                trailing: IconButton(
                                    tooltip: 'Đăng xuất',
                                    onPressed: _logout,
                                    icon: const Icon(Icons.logout, size: 18))),
                            const SizedBox(height: 12),
                          ]))),
            Expanded(
                child: Column(children: [
              Container(
                  height: 58,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: adminLine))),
                  child: Row(children: [
                    const Icon(Icons.blur_on, size: 20, color: adminBlue),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(
                            wide
                                ? 'LOST Đà Lạt  /  ${labels[_index]}'
                                : 'LOST · Quản trị',
                            style: const TextStyle(
                                color: AppTheme.muted, fontSize: 13))),
                    if (wide)
                      const Text('Dữ liệu demo',
                          style:
                              TextStyle(color: AppTheme.muted, fontSize: 12)),
                    if (!wide)
                      IconButton(
                          tooltip: 'Đăng xuất',
                          onPressed: _logout,
                          icon: const Icon(Icons.logout, size: 20)),
                  ])),
              Expanded(child: IndexedStack(index: _index, children: screens)),
            ])),
          ])),
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: _index,
                  onDestinationSelected: _select,
                  destinations: List.generate(
                      labels.length,
                      (i) => NavigationDestination(
                          icon: Icon(icons[i]),
                          label: const [
                            'Tổng quan',
                            'Phòng',
                            'Đơn đặt',
                            'Dọn phòng',
                            'Lịch'
                          ][i]))),
        ));
  }
}

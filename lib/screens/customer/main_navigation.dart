import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'my_bookings_screen.dart';
import 'about_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    MyBookingsScreen(),
    AboutScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) => Scaffold(
              body: IndexedStack(index: _index, children: _screens),
              bottomNavigationBar: constraints.maxWidth >= 900
                  ? null
                  : NavigationBar(
                      selectedIndex: _index,
                      onDestinationSelected: (i) => setState(() => _index = i),
                      destinations: const [
                        NavigationDestination(
                            icon: Icon(Icons.home_outlined),
                            selectedIcon: Icon(Icons.home_rounded),
                            label: 'Khám phá'),
                        NavigationDestination(
                            icon: Icon(Icons.calendar_month_outlined),
                            selectedIcon: Icon(Icons.calendar_month),
                            label: 'Chuyến đi'),
                        NavigationDestination(
                            icon: Icon(Icons.info_outline),
                            selectedIcon: Icon(Icons.info),
                            label: 'Về chúng tôi'),
                        NavigationDestination(
                            icon: Icon(Icons.person_outline),
                            selectedIcon: Icon(Icons.person),
                            label: 'Tài khoản'),
                      ],
                    ),
            ));
  }
}


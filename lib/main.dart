import 'widgets/galaxy_header.dart';
import 'screens/customer/home_screen.dart';
import 'screens/customer/about_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/customer/rooms_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'utils/app_theme.dart';
import 'screens/customer/main_navigation.dart';

void main() {
  runApp(const HomestayApp());
}

class HomestayApp extends StatelessWidget {
  const HomestayApp({super.key});

  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        builder: (context, child) => Column(children: [
          GalaxyHeader(onNavigate: (route) {
            final nav = navigatorKey.currentState!;
            if (route == '/menu') {
              showModalBottomSheet(
                  context: nav.overlay!.context,
                  builder: (sheetContext) => SafeArea(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: GalaxyHeader.links.entries
                              .map((e) => ListTile(
                                  title: Text(e.key),
                                  onTap: () {
                                    Navigator.pop(sheetContext);
                                    if (e.value == '/') {
                                      nav.popUntil((r) => r.isFirst);
                                    } else {
                                      nav.pushNamed(e.value);
                                    }
                                  }))
                              .toList())));
            } else if (route == '/') {
              nav.popUntil((r) => r.isFirst);
            } else {
              nav.pushNamed(route);
            }
          }),
          Expanded(child: child!),
        ]),
        title: 'LOST Đà Lạt — Boutique Hotel giữa ngàn thông',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: const MainNavigation(),
        routes: {
          '/rooms': (_) => const RoomsScreen(),
          '/about': (_) => const AboutScreen(),
          '/services': (_) => const HomeScreen(initialSection: 3),
          '/contact': (_) => const HomeScreen(initialSection: 7),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
        },
      ),
    );
  }
}

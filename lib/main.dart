import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';
import 'providers/firebase_app_provider.dart';
import 'widgets/galaxy_header.dart';
import 'screens/customer/home_screen.dart';
import 'screens/customer/about_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/customer/rooms_screen.dart';
import 'screens/customer/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'utils/app_theme.dart';
import 'screens/customer/main_navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: firebaseWebOptions);
    if (kIsWeb) {
      // Keep the signed-in customer across refreshes and browser restarts.
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    }
    runApp(const HomestayApp(live: true));
  } catch (_) {
    runApp(const MaterialApp(
        home: Scaffold(
            body: Center(
                child: Text(
                    'Không thể kết nối Firebase. Kiểm tra mạng và tải lại trang.')))));
  }
}

class AppRouteObserver extends NavigatorObserver {
  String? currentRouteName;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    currentRouteName = route.settings.name;
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    currentRouteName = previousRoute?.settings.name;
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    currentRouteName = newRoute?.settings.name;
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

class HomestayApp extends StatelessWidget {
  const HomestayApp({super.key, this.live = false});
  final bool live;

  static final navigatorKey = GlobalKey<NavigatorState>();
  static final routeObserver = AppRouteObserver();

  static void pushNamedOnce(NavigatorState navigator, String route) {
    if (routeObserver.currentRouteName == route) return;
    navigator.pushNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => live ? FirebaseAppProvider() : AppProvider(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        builder: (context, child) => Column(children: [
          if (context.watch<AppProvider>().loading)
            const LinearProgressIndicator(),
          if (context.watch<AppProvider>().lastError != null)
            Material(
                color: Colors.red.shade900,
                child: SafeArea(
                    bottom: false,
                    child: Row(children: [
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                  context.watch<AppProvider>().lastError!,
                                  style:
                                      const TextStyle(color: Colors.white)))),
                      IconButton(
                          onPressed: context.read<AppProvider>().clearError,
                          icon: const Icon(Icons.close, color: Colors.white))
                    ]))),
          if (!context.watch<AppProvider>().isAdmin)
            GalaxyHeader(onNavigate: (route) {
              final nav = navigatorKey.currentState!;
              if (route == '/menu') {
                showModalBottomSheet(
                    context: nav.overlay!.context,
                    builder: (sheetContext) => SafeArea(
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: GalaxyHeader.visibleLinks(
                                    context.read<AppProvider>().isLoggedIn)
                                .entries
                                .map((e) => ListTile(
                                    title: Text(e.key),
                                    onTap: () {
                                      Navigator.pop(sheetContext);
                                      if (e.value == '/') {
                                        nav.popUntil((r) => r.isFirst);
                                      } else {
                                        pushNamedOnce(nav, e.value);
                                      }
                                    }))
                                .toList())));
              } else if (route == '/') {
                nav.popUntil((r) => r.isFirst);
              } else {
                pushNamedOnce(nav, route);
              }
            }),
          Expanded(child: child!),
        ]),
        title: 'LOST Đà Lạt — Boutique Hotel giữa ngàn thông',
        navigatorObservers: [routeObserver],
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
          '/profile': (_) => const ProfileScreen(),
        },
      ),
    );
  }
}

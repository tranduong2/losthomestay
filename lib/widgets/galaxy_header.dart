import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class GalaxyHeader extends StatelessWidget {
  const GalaxyHeader({super.key, required this.onNavigate});
  final ValueChanged<String> onNavigate;
  static const links = {
    'Trang chủ': '/',
    'Phòng': '/rooms',
    'Giới thiệu': '/about',
    'Dịch vụ': '/services',
    'Liên hệ': '/contact',
    'Đăng nhập': '/login',
    'Đăng ký': '/register'
  };

  static Map<String, String> visibleLinks(bool isLoggedIn) => {
        for (final entry in links.entries)
          if (!isLoggedIn ||
              (entry.value != '/login' && entry.value != '/register'))
            entry.key: entry.value,
      };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;
    final navigationLinks = visibleLinks(provider.isLoggedIn);
    return Material(
      child: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
              Color(0xFF101D42),
              Color(0xFF164576),
              Color(0xFF182D59)
            ]),
            border: Border(bottom: BorderSide(color: Color(0xFF386698)))),
        child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LayoutBuilder(builder: (context, c) {
                final wide = c.maxWidth >= 1180;
                return SizedBox(
                    height: wide ? 88 : 72,
                    child: Row(children: [
                      Expanded(
                          flex: wide ? 2 : 1,
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: InkWell(
                                  onTap: () => onNavigate('/'),
                                  child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: const Row(children: [
                                        CircleAvatar(
                                            backgroundColor: Color(0xFF2875B5),
                                            child: Icon(Icons.park_rounded,
                                                color: Colors.white)),
                                        SizedBox(width: 12),
                                        Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('LOST ĐÀ LẠT',
                                                  style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white)),
                                              Text(
                                                  'B O U T I Q U E   H O T E L',
                                                  style: TextStyle(
                                                      fontSize: 9,
                                                      color:
                                                          Color(0xFFBEDAF5))),
                                            ]),
                                      ]))))),
                      if (wide)
                        Expanded(
                            flex: 6,
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: navigationLinks.entries
                                    .map((e) => Flexible(
                                        child: TextButton(
                                            onPressed: () =>
                                                onNavigate(e.value),
                                            child: Text(e.key,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    color: Color(0xFFF0F7FF),
                                                    fontSize: 14)))))
                                    .toList())),
                      const SizedBox(width: 12),
                      if (user != null) ...[
                        Semantics(
                          label: 'Tài khoản của ${user.name}',
                          button: true,
                          child: InkWell(
                            key: const ValueKey('customer-account'),
                            borderRadius: BorderRadius.circular(24),
                            onTap: () => onNavigate('/profile'),
                            child: Container(
                              constraints:
                                  BoxConstraints(maxWidth: wide ? 190 : 130),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .12),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: .25)),
                              ),
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.account_circle,
                                        color: Colors.white, size: 24),
                                    const SizedBox(width: 7),
                                    Flexible(
                                      child: Text(user.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ]),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      FilledButton(
                          onPressed: () => onNavigate('/rooms'),
                          style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF7DD3FC),
                              foregroundColor: const Color(0xFF08233D)),
                          child: Text(wide ? 'Đặt phòng ngay' : 'Đặt phòng')),
                      if (!wide)
                        IconButton(
                            key: const ValueKey('galaxy-menu'),
                            onPressed: () => onNavigate('/menu'),
                            icon: const Icon(Icons.menu)),
                    ]));
              }),
            )),
      ),
    );
  }
}

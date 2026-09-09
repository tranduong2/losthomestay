import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../utils/app_theme.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cá nhân')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 44,
                  backgroundColor: AppTheme.primary,
                  child:
                      Icon(Icons.person_outline, size: 48, color: Colors.white),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Đăng nhập để quản lý đặt phòng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bạn vẫn có thể khám phá các phòng ngay bây giờ.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  icon: const Icon(Icons.login),
                  label: const Text('Đăng nhập'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Cá nhân')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 44,
                  backgroundColor: AppTheme.primary,
                  child: Icon(Icons.person, size: 48, color: Colors.white),
                ),
                const SizedBox(height: 14),
                Text(user.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                Text(user.email, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading:
                      const Icon(Icons.phone_outlined, color: AppTheme.primary),
                  title: const Text('Số điện thoại'),
                  subtitle:
                      Text(user.phone.isEmpty ? 'Chưa cập nhật' : user.phone),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.event_note_outlined,
                      color: AppTheme.primary),
                  title: const Text('Số lượt đặt phòng'),
                  subtitle: Text('${provider.myBookings.length} lượt'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title:
                  const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Đăng xuất'),
                    content: const Text('Bạn có chắc muốn đăng xuất không?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Hủy')),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          provider.logout();
                        },
                        child: const Text('Đăng xuất',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


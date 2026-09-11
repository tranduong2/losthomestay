import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../customer/main_navigation.dart';
import '../admin/admin_main_navigation.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  void _submit() async {
    if (_loading) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    final provider = context.read<AppProvider>();
    final error = await provider.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Đăng nhập thành công!'), backgroundColor: Colors.green));
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (_) => provider.isAdmin
                ? const AdminMainNavigation()
                : const MainNavigation()),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Icon(Icons.holiday_village,
                    size: 56, color: AppTheme.primary),
                const SizedBox(height: 16),
                const Text('Đăng nhập',
                    style:
                        TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Chào mừng quay lại Cozy Homestay',
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined)),
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'Email không hợp lệ'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Mật khẩu tối thiểu 6 ký tự'
                      : null,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                    text: 'Đăng nhập', onPressed: _submit, loading: _loading),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen())),
                    child: const Text('Chưa có tài khoản? Đăng ký ngay'),
                  ),
                ),
                const Divider(height: 32),
                if (!context.watch<AppProvider>().isLive)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Tài khoản demo:\n• Khách: khach@gmail.com / 123456\n• Admin: admin@homestay.com / admin123',
                      style: TextStyle(fontSize: 12.5),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

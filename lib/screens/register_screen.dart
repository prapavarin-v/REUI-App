import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_text_field.dart';
import 'home_screen.dart';

/// หน้าสมัครสมาชิก — เพิ่มเข้ามาเสริมจากสโคปเดิม เพราะ Login ต้องมีบัญชี
/// ให้ทดสอบจริงได้ ไม่งั้นจะ login ไม่ได้เลย
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _handleRegister(AuthProvider auth) async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรอกชื่อ อีเมล และรหัสผ่านอย่างน้อย 6 ตัวอักษร'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final success = await auth.signUp(
      _emailController.text,
      _passwordController.text,
      _nameController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (auth.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(auth.errorMessage!),
            backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('สมัครสมาชิก')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _nameController,
                hintText: 'ชื่อที่แสดง',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _emailController,
                hintText: 'อีเมลของคุณ',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _passwordController,
                hintText: 'รหัสผ่าน (อย่างน้อย 6 ตัวอักษร)',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed:
                    auth.isLoading ? null : () => _handleRegister(auth),
                child: auth.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.white,
                        ),
                      )
                    : const Text('สมัครสมาชิก'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

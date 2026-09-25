import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/common_inputs.dart';
import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _authService = AuthService();
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _facultyController = TextEditingController();
  final _majorController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  String? _error;

  Future<void> _register() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.length < 6) {
      setState(() => _error = 'กรอกข้อมูลให้ครบ และรหัสผ่านอย่างน้อย 6 ตัวอักษร');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _authService.register(
        name: _nameController.text.trim(),
        studentId: _studentIdController.text.trim(),
        faculty: _facultyController.text.trim(),
        major: _majorController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      setState(() => _error = 'สมัครสมาชิกไม่สำเร็จ: กรุณาลองอีกครั้ง');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('สมัครสมาชิก')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('สร้างบัญชี REUNI', style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.lg),
              ReuniTextField(label: 'ชื่อ-นามสกุล', controller: _nameController),
              const SizedBox(height: AppSpacing.md),
              ReuniTextField(
                  label: 'รหัสนักศึกษา',
                  controller: _studentIdController,
                  keyboardType: TextInputType.number),
              const SizedBox(height: AppSpacing.md),
              ReuniTextField(label: 'คณะ', controller: _facultyController),
              const SizedBox(height: AppSpacing.md),
              ReuniTextField(label: 'สาขา', controller: _majorController),
              const SizedBox(height: AppSpacing.md),
              ReuniTextField(
                  label: 'University Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: AppSpacing.md),
              ReuniTextField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: true),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(_error!, style: const TextStyle(color: AppColors.error)),
              ],
              const SizedBox(height: AppSpacing.lg),
              ReuniPrimaryButton(
                  label: 'สมัครสมาชิก', onPressed: _register, loading: _loading),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

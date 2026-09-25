import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/common_inputs.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      setState(() => _error = 'เข้าสู่ระบบไม่สำเร็จ ตรวจสอบอีเมล/รหัสผ่านอีกครั้ง');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() => _error = 'กรอกอีเมลเพื่อรีเซ็ตรหัสผ่านก่อน');
      return;
    }
    await _authService.resetPassword(_emailController.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ส่งลิงก์รีเซ็ตรหัสผ่านไปที่อีเมลแล้ว')));
  }

  Future<void> _loginWithGoogle() async {
    // TODO: ผูก google_sign_in package แล้วส่ง AuthCredential เข้า
    // _authService.loginWithGoogle(credential)
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('เชื่อมต่อ Google Student Mail (ต้องตั้งค่า google_sign_in)')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Text('เข้าสู่ระบบ', style: AppTextStyles.h1),
              const SizedBox(height: 4),
              Text('ยินดีต้อนรับกลับสู่ REUNI', style: AppTextStyles.body),
              const SizedBox(height: AppSpacing.xl),
              ReuniTextField(
                label: 'University Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSpacing.md),
              ReuniTextField(
                label: 'Password',
                controller: _passwordController,
                obscureText: true,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _forgotPassword,
                  child: const Text('ลืมรหัสผ่าน?'),
                ),
              ),
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: AppColors.error)),
                const SizedBox(height: AppSpacing.sm),
              ],
              const SizedBox(height: AppSpacing.sm),
              ReuniPrimaryButton(
                  label: 'Login', onPressed: _login, loading: _loading),
              const SizedBox(height: AppSpacing.md),
              Row(children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('หรือ', style: AppTextStyles.caption),
                ),
                const Expanded(child: Divider()),
              ]),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: _loginWithGoogle,
                icon: const Icon(Icons.g_mobiledata, size: 28),
                label: const Text('เข้าสู่ระบบด้วย Google Student Mail'),
              ),
              const SizedBox(height: AppSpacing.xl),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.body,
                      children: [
                        const TextSpan(text: 'ยังไม่มีบัญชี? '),
                        TextSpan(
                            text: 'สมัครสมาชิก',
                            style: AppTextStyles.bodyBold
                                .copyWith(color: AppColors.primary)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

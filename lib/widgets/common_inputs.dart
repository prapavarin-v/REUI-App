import 'package:flutter/material.dart';
import '../core/theme.dart';

class ReuniTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;
  final Widget? suffixIcon;

  const ReuniTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyBold),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: AppTextStyles.body,
          decoration: InputDecoration(suffixIcon: suffixIcon),
        ),
      ],
    );
  }
}

class ReuniPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final Color? color;

  const ReuniPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: color != null
          ? ElevatedButton.styleFrom(backgroundColor: color)
          : null,
      child: loading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.white))
          : Text(label),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const SectionTitle({super.key, required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.h3),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text('ดูทั้งหมด'),
            ),
        ],
      ),
    );
  }
}

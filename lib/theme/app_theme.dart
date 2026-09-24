import 'package:flutter/material.dart';

/// สีและธีมหลักของแอป REGI (โทนเขียว ตามดีไซน์ต้นฉบับ)
class AppColors {
  static const primary = Color(0xFF2E9E5B);
  static const primaryDark = Color(0xFF1F7A44);
  static const primaryLight = Color(0xFFE8F5EC);
  // พื้นหลังโทนครีม ตามดีไซน์ล่าสุด (ไม่ใช่ขาว/เทาล้วน)
  static const background = Color(0xFFF7F3EC);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF8A8A8A);
  static const border = Color(0xFFE5E0D8);
  static const white = Color(0xFFFFFFFF);
  static const danger = Color(0xFFE05757);

  /// พาเลตสีพื้นวงกลมไอคอนหมวดหมู่ วนใช้ตามลำดับ index
  /// (เสื้อผ้า=เหลือง, อุปกรณ์ไอที=ฟ้า, กระเป๋า=ชมพู, หนังสือ=เขียว,
  ///  รองเท้า=ครีมเข้ม, เครื่องสำอาง=ม่วง, ของใช้ในห้อง=ส้ม, อื่นๆ=เทา)
  static const List<Color> categoryColors = [
    Color(0xFFFFE9A8), // เหลือง
    Color(0xFFBFE3F5), // ฟ้า
    Color(0xFFF7CFE0), // ชมพู
    Color(0xFFCDEBD3), // เขียวอ่อน
    Color(0xFFE6DCCB), // ครีมเข้ม
    Color(0xFFE3D6F0), // ม่วง
    Color(0xFFFBD9B8), // ส้ม
    Color(0xFFDCDCDC), // เทา
  ];

  static const List<Color> categoryIconColors = [
    Color(0xFFB8860B),
    Color(0xFF2E7BA6),
    Color(0xFFB5407A),
    Color(0xFF2E9E5B),
    Color(0xFF7A5C2E),
    Color(0xFF7B4FA6),
    Color(0xFFB8631A),
    Color(0xFF6B6B6B),
  ];
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        background: AppColors.background,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      fontFamily: 'Sarabun', // เพิ่มฟอนต์ไทยเองภายหลังได้ใน pubspec assets
    );
  }
}

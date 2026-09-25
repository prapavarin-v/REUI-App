import 'package:flutter/material.dart';
import '../core/theme.dart';

/// 🧭 Bottom Navigation — ใช้เหมือนกันทุกหน้าหลัก
/// 🏠 Home | 🔍 Explore | ＋ Sell | 💬 Chat | 👤 Profile
class ReuniBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const ReuniBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.secondary,
      showUnselectedLabels: true,
      selectedLabelStyle: AppTextStyles.caption.copyWith(
          color: AppColors.primary, fontWeight: FontWeight.w600),
      unselectedLabelStyle: AppTextStyles.caption,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined), label: 'Explore'),
        BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline), label: 'Sell'),
        BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}

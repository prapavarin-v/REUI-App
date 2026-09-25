import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// Screen 15: สมาชิกกลุ่ม 3 คน — รูป / ชื่อ-นามสกุล / รหัสนักศึกษา / คณะ-สาขา / หน้าที่ในโปรเจกต์
/// แก้ไขรายชื่อสมาชิกจริงในลิสต์ [_members] ด้านล่าง
class GroupMembersScreen extends StatelessWidget {
  const GroupMembersScreen({super.key});

  static const List<Map<String, String>> _members = [
    {
      'name': 'ชื่อ-นามสกุล สมาชิกคนที่ 1',
      'studentId': '6XXXXXXXX',
      'facultyMajor': 'คณะ... / สาขา...',
      'role': 'UX/UI Designer & Frontend Developer',
    },
    {
      'name': 'ชื่อ-นามสกุล สมาชิกคนที่ 2',
      'studentId': '6XXXXXXXX',
      'facultyMajor': 'คณะ... / สาขา...',
      'role': 'Backend & Firebase Developer',
    },
    {
      'name': 'ชื่อ-นามสกุล สมาชิกคนที่ 3',
      'studentId': '6XXXXXXXX',
      'facultyMajor': 'คณะ... / สาขา...',
      'role': 'AI Integration & QA',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('สมาชิกกลุ่ม')),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: _members.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final m = _members[index];
          return Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Row(
              children: [
                const CircleAvatar(radius: 28, child: Icon(Icons.person)),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m['name']!, style: AppTextStyles.bodyBold),
                      Text('รหัส ${m['studentId']}', style: AppTextStyles.caption),
                      Text(m['facultyMajor']!, style: AppTextStyles.caption),
                      const SizedBox(height: 4),
                      Text(m['role']!,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../theme/app_theme.dart';

class CategoryGridItem extends StatelessWidget {
  final CategoryModel category;
  final int colorIndex;
  final VoidCallback? onTap;

  const CategoryGridItem({
    super.key,
    required this.category,
    this.colorIndex = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = AppColors
        .categoryColors[colorIndex % AppColors.categoryColors.length];
    final iconColor = AppColors
        .categoryIconColors[colorIndex % AppColors.categoryIconColors.length];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: category.icon.isNotEmpty
                ? Text(category.icon, style: const TextStyle(fontSize: 22))
                : Icon(Icons.sell_outlined, color: iconColor, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            category.name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          if (category.productCount > 0)
            Text(
              '(${category.productCount})',
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

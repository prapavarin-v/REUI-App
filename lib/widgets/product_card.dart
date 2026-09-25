import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onFavoriteTap,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: product.images.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: product.images.first,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: AppColors.background),
                          errorWidget: (_, __, ___) => Container(
                              color: AppColors.background,
                              child: const Icon(Icons.image_not_supported)),
                        )
                      : Container(
                          color: AppColors.background,
                          child: const Icon(Icons.image, size: 40)),
                ),
                if (product.status != ProductStatus.available)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.45),
                      alignment: Alignment.center,
                      child: Text(
                        ProductStatus.label(product.status),
                        style: AppTextStyles.bodyBold
                            .copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
                if (onFavoriteTap != null)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: onFavoriteTap,
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: AppColors.white.withOpacity(0.9),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: isFavorite ? AppColors.pink : AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyBold,
                  ),
                  const SizedBox(height: 4),
                  Text('฿${product.price}', style: AppTextStyles.price),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

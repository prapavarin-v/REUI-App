import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../services/firestore_service.dart';
import '../../models/product_model.dart';
import '../../models/user_model.dart';
import '../../models/misc_models.dart';
import '../../services/auth_service.dart';
import '../chat/chat_room_screen.dart';
import '../chat/reservation_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  int _imageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      body: FutureBuilder<ProductModel?>(
        future: _firestoreService.getProduct(widget.productId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final product = snapshot.data;
          if (product == null) {
            return const Center(child: Text('ไม่พบสินค้านี้'));
          }
          final isOwner = product.sellerId == uid;

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: product.images.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: product.images[_imageIndex],
                                      fit: BoxFit.cover)
                                  : Container(color: AppColors.background),
                            ),
                            Positioned(
                              top: AppSpacing.sm,
                              left: AppSpacing.sm,
                              child: CircleAvatar(
                                backgroundColor: AppColors.white.withOpacity(0.9),
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back, size: 18),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            ),
                            if (product.images.length > 1)
                              Positioned(
                                bottom: AppSpacing.sm,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    product.images.length,
                                    (i) => Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 3),
                                      width: 7,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: i == _imageIndex
                                            ? AppColors.primary
                                            : AppColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(product.title,
                                        style: AppTextStyles.h2),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.yellow.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(product.condition,
                                        style: AppTextStyles.caption),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text('฿${product.price}', style: AppTextStyles.price.copyWith(fontSize: 24)),
                              const SizedBox(height: 4),
                              Text(ProductStatus.label(product.status),
                                  style: AppTextStyles.caption.copyWith(
                                      color: product.status ==
                                              ProductStatus.available
                                          ? AppColors.primary
                                          : AppColors.error)),
                              const Divider(height: AppSpacing.xl),
                              Text('รายละเอียดสินค้า', style: AppTextStyles.h3),
                              const SizedBox(height: 6),
                              Text(product.description, style: AppTextStyles.body),
                              const Divider(height: AppSpacing.xl),
                              Text('ผู้ขาย', style: AppTextStyles.h3),
                              const SizedBox(height: 8),
                              FutureBuilder<UserModel?>(
                                future:
                                    _authService.getUserProfile(product.sellerId),
                                builder: (context, sellerSnap) {
                                  final seller = sellerSnap.data;
                                  return Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 22,
                                        backgroundImage: seller?.photoUrl.isNotEmpty == true
                                            ? NetworkImage(seller!.photoUrl)
                                            : null,
                                        child: seller?.photoUrl.isNotEmpty != true
                                            ? const Icon(Icons.person)
                                            : null,
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(seller?.name ?? '-',
                                                style: AppTextStyles.bodyBold),
                                            Text(
                                                '${seller?.faculty ?? ''} ${product.faculty.isNotEmpty ? "· ${product.faculty}" : ""}',
                                                style: AppTextStyles.caption),
                                          ],
                                        ),
                                      ),
                                      if (seller != null)
                                        RatingBarIndicator(
                                          rating: seller.rating,
                                          itemBuilder: (context, _) => const Icon(
                                              Icons.star,
                                              color: AppColors.yellow),
                                          itemCount: 5,
                                          itemSize: 16,
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isOwner)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.chat_bubble_outline),
                            label: const Text('Chat'),
                            onPressed: () async {
                              final chatId =
                                  await _firestoreService.getOrCreateChat(
                                buyerId: uid,
                                sellerId: product.sellerId,
                                product: product,
                              );
                              if (!context.mounted) return;
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => ChatRoomScreen(
                                      chatId: chatId,
                                      otherUserName: 'ผู้ขาย',
                                      productTitle: product.title)));
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.bookmark_add_outlined),
                            label: const Text('Reserve'),
                            onPressed: product.status != ProductStatus.available
                                ? null
                                : () async {
                                    final reservationId =
                                        await _firestoreService.createReservation(
                                      ReservationModel(
                                        id: '',
                                        productId: product.id,
                                        productTitle: product.title,
                                        buyerId: uid,
                                        sellerId: product.sellerId,
                                        status: ReservationStatus.requested,
                                        createdAt: DateTime.now(),
                                      ),
                                    );
                                    if (!context.mounted) return;
                                    Navigator.of(context).push(MaterialPageRoute(
                                        builder: (_) => ReservationScreen(
                                            reservationId: reservationId)));
                                  },
                          ),
                        ),
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

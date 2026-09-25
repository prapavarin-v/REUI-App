import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme.dart';
import '../../services/firestore_service.dart';
import '../../models/misc_models.dart';
import '../../models/product_model.dart';
import '../../widgets/product_card.dart';
import '../product/product_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('รายการที่ถูกใจ')),
      body: StreamBuilder<List<FavoriteModel>>(
        stream: firestoreService.streamFavorites(uid),
        builder: (context, favSnapshot) {
          if (!favSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final favorites = favSnapshot.data!;
          if (favorites.isEmpty) {
            return const Center(child: Text('ยังไม่มีสินค้าที่กด ❤️'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 0.68,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final fav = favorites[index];
              return FutureBuilder<ProductModel?>(
                future: firestoreService.getProduct(fav.productId),
                builder: (context, prodSnapshot) {
                  if (!prodSnapshot.hasData || prodSnapshot.data == null) {
                    return const SizedBox();
                  }
                  final product = prodSnapshot.data!;
                  return ProductCard(
                    product: product,
                    isFavorite: true,
                    onFavoriteTap: () =>
                        firestoreService.toggleFavorite(uid, product.id),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            ProductDetailScreen(productId: product.id))),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../services/firestore_service.dart';
import '../../models/product_model.dart';
import '../../widgets/product_card.dart';
import '../product/product_detail_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String? initialCategoryId;
  const CategoryScreen({super.key, this.initialCategoryId});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    final categories = DefaultCategories.items;
    final initialIndex = widget.initialCategoryId == null
        ? 0
        : categories.indexWhere((c) => c['id'] == widget.initialCategoryId).clamp(0, categories.length - 1);
    _tabController = TabController(
        length: categories.length, vsync: this, initialIndex: initialIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = DefaultCategories.items;
    return Scaffold(
      appBar: AppBar(
        title: const Text('หมวดหมู่สินค้า'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.secondary,
          indicatorColor: AppColors.primary,
          tabs: categories
              .map((c) => Tab(text: '${c['icon']} ${c['name']}'))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: categories.map((c) {
          return StreamBuilder<List<ProductModel>>(
            stream: _firestoreService.streamProducts(categoryId: c['id']),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final products = snapshot.data!;
              if (products.isEmpty) {
                return const Center(child: Text('ยังไม่มีสินค้าในหมวดนี้'));
              }
              return GridView.builder(
                padding: const EdgeInsets.all(AppSpacing.lg),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 0.68,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final p = products[index];
                  return ProductCard(
                    product: p,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(productId: p.id))),
                  );
                },
              );
            },
          );
        }).toList(),
      ),
    );
  }
}

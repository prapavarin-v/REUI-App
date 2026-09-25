import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme.dart';
import '../../services/firestore_service.dart';
import '../../models/product_model.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/product_card.dart';
import '../../widgets/common_inputs.dart';
import '../product/product_detail_screen.dart';
import '../product/upload_product_screen.dart';
import 'search_screen.dart';
import 'category_screen.dart';
import '../chat/chat_list_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  final List<Widget> _pages = const [
    _HomeTab(),
    SearchScreen(),
    UploadProductScreen(),
    ChatListScreen(),
    ProfileScreen(),
  ];

  void _onNavTap(int index) {
    if (index == 2) {
      // ＋ Sell เปิดเป็นหน้าถัดไปแทนการสลับแท็บ เพื่อให้กลับมาแท็บเดิมได้หลังโพสต์เสร็จ
      Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const UploadProductScreen()));
      return;
    }
    setState(() => _navIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _navIndex,
        children: [_pages[0], _pages[1], const SizedBox(), _pages[3], _pages[4]],
      ),
      bottomNavigationBar:
          ReuniBottomNav(currentIndex: _navIndex, onTap: _onNavTap),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('REUNI', style: AppTextStyles.h1),
                      IconButton(
                        icon: const Icon(Icons.notifications_none),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SearchScreen())),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppRadius.input),
                      ),
                      child: Row(children: [
                        const Icon(Icons.search, color: AppColors.secondary),
                        const SizedBox(width: 8),
                        Text('ค้นหาสินค้ามือสอง...', style: AppTextStyles.caption),
                      ]),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SectionTitle(
                      title: 'หมวดหมู่',
                      onSeeAll: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CategoryScreen()))),
                  const _CategoryRow(),
                  SectionTitle(title: 'สินค้ามาใหม่'),
                ],
              ),
            ),
          ),
          StreamBuilder<List<ProductModel>>(
            stream: firestoreService.streamProducts(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }
              final products = snapshot.data!;
              if (products.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('ยังไม่มีสินค้าในระบบ')),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 0.68,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final p = products[index];
                      return StreamBuilder<bool>(
                        stream: firestoreService.isFavorite(uid, p.id),
                        builder: (context, favSnap) {
                          return ProductCard(
                            product: p,
                            isFavorite: favSnap.data ?? false,
                            onFavoriteTap: () =>
                                firestoreService.toggleFavorite(uid, p.id),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProductDetailScreen(productId: p.id),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: products.length,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow();

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    return SizedBox(
      height: 88,
      child: StreamBuilder(
        stream: firestoreService.streamCategories(),
        builder: (context, snapshot) {
          final categories = snapshot.data ?? [];
          if (categories.isEmpty) {
            return const SizedBox();
          }
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final c = categories[index];
              return GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => CategoryScreen(initialCategoryId: c.id))),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.white,
                      child: Text(c.icon, style: const TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                        width: 64,
                        child: Text(c.name,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

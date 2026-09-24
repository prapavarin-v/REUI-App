import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../models/product_model.dart';
import '../theme/app_theme.dart';
import '../widgets/category_grid_item.dart';
import '../widgets/product_card.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _firestoreService = FirestoreService();
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final uid = auth.user?.uid;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildAppBar(uid)),
              SliverToBoxAdapter(child: _buildSearchBar()),
              SliverToBoxAdapter(child: _buildPromoBanner()),
              SliverToBoxAdapter(child: _buildCategorySection()),
              SliverToBoxAdapter(child: _buildProductSectionHeader()),
              _buildProductGrid(),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          // TODO: ไปหน้า create-1 (ลงขายสินค้า) เมื่อสร้างหน้านั้นแล้ว
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ไปหน้าลงขายสินค้า (ยังไม่ได้สร้าง)')),
          );
        },
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ---------- Header ----------
  Widget _buildAppBar(String? uid) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'REGI',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.person, color: AppColors.primary, size: 20),
            ),
            onSelected: (value) async {
              if (value == 'logout') {
                await context.read<AuthProvider>().signOut();
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'logout', child: Text('ออกจากระบบ')),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Search ----------
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'ค้นหาสินค้า/ประเภทสินค้า',
          hintStyle: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: AppColors.border),
          ),
        ),
      ),
    );
  }

  // ---------- Promo banner ----------
  Widget _buildPromoBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'product',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ซื้อ-ขาย แลกเปลี่ยน ใน KPS',
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Categories ----------
  Widget _buildCategorySection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: StreamBuilder<List<CategoryModel>>(
        stream: _firestoreService.categoriesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return Text('โหลดหมวดหมู่ไม่สำเร็จ: ${snapshot.error}');
          }
          final categories = snapshot.data ?? [];
          if (categories.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('ยังไม่มีหมวดหมู่สินค้า',
                  style: TextStyle(color: AppColors.textSecondary)),
            );
          }
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 8,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              final category = categories[index];
              return CategoryGridItem(
                category: category,
                colorIndex: index,
                onTap: () {
                  // TODO: ไปหน้า product-list กรองตาม category.id
                },
              );
            },
          );
        },
      ),
    );
  }

  // ---------- Product section header ----------
  Widget _buildProductSectionHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('สินค้าใหม่',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          Row(
            children: [
              Text('ดูทั้งหมด',
                  style: TextStyle(fontSize: 13, color: AppColors.primary)),
              Icon(Icons.chevron_right, size: 16, color: AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Product grid ----------
  Widget _buildProductGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: StreamBuilder<List<ProductModel>>(
        stream: _firestoreService.latestProductsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }
          if (snapshot.hasError) {
            return SliverToBoxAdapter(
              child: Text('โหลดสินค้าไม่สำเร็จ: ${snapshot.error}'),
            );
          }
          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('ยังไม่มีสินค้าลงขาย',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
              ),
            );
          }
          return SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => ProductCard(
                product: products[index],
                onTap: () {
                  // TODO: ไปหน้า product-detail ด้วย products[index].id
                },
              ),
              childCount: products.length,
            ),
          );
        },
      ),
    );
  }

  // ---------- Bottom nav ----------
  Widget _buildBottomNav() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: AppColors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_rounded, 'หน้าแรก', 0),
          _navItem(Icons.grid_view_rounded, 'หมวดหมู่', 1),
          const SizedBox(width: 40), // เว้นที่ให้ FAB
          _navItem(Icons.chat_bubble_outline_rounded, 'แชท', 2),
          _navItem(Icons.person_outline_rounded, 'โปรไฟล์', 3),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isActive = _currentNavIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentNavIndex = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

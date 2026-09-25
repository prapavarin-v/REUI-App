import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import '../../models/product_model.dart';
import '../../widgets/product_card.dart';
import '../product/edit_product_screen.dart';
import '../home/wishlist_screen.dart';
import 'group_members_screen.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('โปรไฟล์'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_outlined),
            tooltip: 'สมาชิกกลุ่ม',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const GroupMembersScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false);
            },
          ),
        ],
      ),
      body: FutureBuilder<UserModel?>(
        future: _authService.getUserProfile(uid),
        builder: (context, snapshot) {
          final profile = snapshot.data;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.background,
                      backgroundImage: profile?.photoUrl.isNotEmpty == true
                          ? NetworkImage(profile!.photoUrl)
                          : null,
                      child: profile?.photoUrl.isNotEmpty != true
                          ? const Icon(Icons.person, size: 32)
                          : null,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(profile?.name ?? '-', style: AppTextStyles.h3),
                          Text('รหัส ${profile?.studentId ?? '-'}',
                              style: AppTextStyles.caption),
                          Text('${profile?.faculty ?? ''} · ${profile?.major ?? ''}',
                              style: AppTextStyles.caption),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              RatingBarIndicator(
                                rating: profile?.rating ?? 0,
                                itemBuilder: (context, _) =>
                                    const Icon(Icons.star, color: AppColors.yellow),
                                itemCount: 5,
                                itemSize: 16,
                              ),
                              const SizedBox(width: 4),
                              Text('(${profile?.reviewCount ?? 0})',
                                  style: AppTextStyles.caption),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite_border),
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const WishlistScreen())),
                    ),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.secondary,
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(text: 'สินค้าของฉัน'),
                  Tab(text: 'ขายแล้ว'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _MyProductsGrid(
                        uid: uid,
                        statusFilter: null,
                        firestoreService: _firestoreService),
                    _MyProductsGrid(
                        uid: uid,
                        statusFilter: ProductStatus.sold,
                        firestoreService: _firestoreService),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MyProductsGrid extends StatelessWidget {
  final String uid;
  final String? statusFilter;
  final FirestoreService firestoreService;

  const _MyProductsGrid({
    required this.uid,
    required this.statusFilter,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ProductModel>>(
      stream: firestoreService.streamMyProducts(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var products = snapshot.data!;
        if (statusFilter != null) {
          products = products.where((p) => p.status == statusFilter).toList();
        }
        if (products.isEmpty) {
          return const Center(child: Text('ยังไม่มีสินค้า'));
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
                  builder: (_) => EditProductScreen(product: p))),
            );
          },
        );
      },
    );
  }
}

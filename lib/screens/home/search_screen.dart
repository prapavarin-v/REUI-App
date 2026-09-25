import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/firestore_service.dart';
import '../../models/product_model.dart';
import '../../widgets/product_card.dart';
import '../product/product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _firestoreService = FirestoreService();
  final _searchController = TextEditingController();

  List<ProductModel> _results = [];
  bool _loading = false;

  RangeValues _priceRange = const RangeValues(0, 5000);
  String? _faculty;
  String? _condition;
  String _sortBy = 'createdAt';

  Future<void> _search() async {
    setState(() => _loading = true);
    final keyword = _searchController.text.trim();
    List<ProductModel> results = keyword.isEmpty
        ? await _firestoreService.streamProducts().first
        : await _firestoreService.searchProducts(keyword);

    results = _firestoreService.filterByPriceRange(
        results, _priceRange.start.toInt(), _priceRange.end.toInt());

    if (_faculty != null && _faculty!.isNotEmpty) {
      results = results.where((p) => p.faculty == _faculty).toList();
    }
    if (_condition != null && _condition!.isNotEmpty) {
      results = results.where((p) => p.condition == _condition).toList();
    }
    if (_sortBy == 'price') {
      results.sort((a, b) => a.price.compareTo(b.price));
    } else {
      results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    setState(() {
      _results = results;
      _loading = false;
    });
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Filter', style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.md),
                Text('ช่วงราคา: ฿${_priceRange.start.toInt()} - ฿${_priceRange.end.toInt()}',
                    style: AppTextStyles.bodyBold),
                RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: 20000,
                  divisions: 40,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setModalState(() => _priceRange = v),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text('คณะ', style: AppTextStyles.bodyBold),
                Wrap(
                  spacing: 8,
                  children: ['วิศวกรรมศาสตร์', 'วิทยาศาสตร์', 'บริหารธุรกิจ', 'ศิลปศาสตร์']
                      .map((f) => ChoiceChip(
                            label: Text(f),
                            selected: _faculty == f,
                            onSelected: (sel) =>
                                setModalState(() => _faculty = sel ? f : null),
                          ))
                      .toList(),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text('สภาพสินค้า', style: AppTextStyles.bodyBold),
                Wrap(
                  spacing: 8,
                  children: ['ใหม่มาก', 'ดี', 'พอใช้']
                      .map((c) => ChoiceChip(
                            label: Text(c),
                            selected: _condition == c,
                            onSelected: (sel) =>
                                setModalState(() => _condition = sel ? c : null),
                          ))
                      .toList(),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text('เรียงตาม', style: AppTextStyles.bodyBold),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('ล่าสุด'),
                      selected: _sortBy == 'createdAt',
                      onSelected: (_) =>
                          setModalState(() => _sortBy = 'createdAt'),
                    ),
                    ChoiceChip(
                      label: const Text('ราคา'),
                      selected: _sortBy == 'price',
                      onSelected: (_) => setModalState(() => _sortBy = 'price'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _search();
                  },
                  child: const Text('ใช้ตัวกรอง'),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _search();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          onSubmitted: (_) => _search(),
          decoration: const InputDecoration(
              hintText: 'ค้นหาสินค้า...', border: InputBorder.none),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: _search),
          IconButton(
              icon: const Icon(Icons.tune), onPressed: _openFilterSheet),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
              ? const Center(child: Text('ไม่พบสินค้าที่ค้นหา'))
              : GridView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 0.68,
                  ),
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final p = _results[index];
                    return ProductCard(
                      product: p,
                      onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailScreen(productId: p.id))),
                    );
                  },
                ),
    );
  }
}

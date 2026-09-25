import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../services/ai_service.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import '../../models/product_model.dart';
import '../../widgets/common_inputs.dart';
import '../home/home_screen.dart';

/// Screen 12: ✨ AI วิเคราะห์ราคา + ✨ AI เขียนแคปชัน ก่อน Preview / Confirm / Post
/// สีของฟีเจอร์ AI: Teal #3BAFA3
class AiSmartListingScreen extends StatefulWidget {
  final List<File> images;
  const AiSmartListingScreen({super.key, required this.images});

  @override
  State<AiSmartListingScreen> createState() => _AiSmartListingScreenState();
}

class _AiSmartListingScreenState extends State<AiSmartListingScreen> {
  final _aiService = AiService();
  final _firestoreService = FirestoreService();
  final _storageService = StorageService();
  final _authService = AuthService();

  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _categoryId = DefaultCategories.items.first['id']!;
  String _condition = 'ดี';

  bool _analyzingPrice = false;
  bool _generatingCaption = false;
  bool _posting = false;
  AiPriceSuggestion? _priceSuggestion;

  Future<void> _analyzePrice() async {
    if (_titleController.text.trim().isEmpty) return;
    setState(() => _analyzingPrice = true);
    try {
      final suggestion = await _aiService.analyzePrice(
        title: _titleController.text.trim(),
        category: _categoryId,
        condition: _condition,
        description: _descriptionController.text.trim(),
      );
      setState(() => _priceSuggestion = suggestion);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('วิเคราะห์ราคาไม่สำเร็จ ลองอีกครั้ง')));
      }
    } finally {
      if (mounted) setState(() => _analyzingPrice = false);
    }
  }

  Future<void> _generateCaption() async {
    if (_titleController.text.trim().isEmpty) return;
    setState(() => _generatingCaption = true);
    try {
      final caption = await _aiService.generateCaption(
        title: _titleController.text.trim(),
        category: _categoryId,
        condition: _condition,
        price: int.tryParse(_priceController.text),
      );
      setState(() => _descriptionController.text = caption);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('เขียนแคปชันไม่สำเร็จ ลองอีกครั้ง')));
      }
    } finally {
      if (mounted) setState(() => _generatingCaption = false);
    }
  }

  Future<void> _confirmPost() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    if (_titleController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('กรอกชื่อสินค้าและราคาก่อนโพสต์')));
      return;
    }

    setState(() => _posting = true);
    try {
      final profile = await _authService.getUserProfile(uid);
      final imageUrls =
          await _storageService.uploadProductImages(widget.images, uid);

      await _firestoreService.createProduct(ProductModel(
        id: '',
        sellerId: uid,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: int.parse(_priceController.text.trim()),
        categoryId: _categoryId,
        condition: _condition,
        images: imageUrls,
        status: ProductStatus.available,
        faculty: profile?.faculty ?? '',
        aiGenerated: _descriptionController.text.trim().isNotEmpty,
        createdAt: DateTime.now(),
      ));

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false);
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Smart Listing')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: widget.images
                    .map((f) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.input),
                            child: Image.file(f,
                                width: 90, height: 90, fit: BoxFit.cover),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ReuniTextField(label: 'ชื่อสินค้า', controller: _titleController),
            const SizedBox(height: AppSpacing.md),
            Text('หมวดหมู่', style: AppTextStyles.bodyBold),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              value: _categoryId,
              items: DefaultCategories.items
                  .map((c) => DropdownMenuItem(
                      value: c['id'], child: Text('${c['icon']} ${c['name']}')))
                  .toList(),
              onChanged: (v) => setState(() => _categoryId = v!),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('สภาพสินค้า', style: AppTextStyles.bodyBold),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: ['ใหม่มาก', 'ดี', 'พอใช้']
                  .map((c) => ChoiceChip(
                        label: Text(c),
                        selected: _condition == c,
                        onSelected: (_) => setState(() => _condition = c),
                      ))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            ReuniTextField(
              label: 'ราคา (บาท)',
              controller: _priceController,
              keyboardType: TextInputType.number,
              suffixIcon: TextButton(
                onPressed: _analyzingPrice ? null : _analyzePrice,
                child: _analyzingPrice
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.ai))
                    : const Text('✨ AI', style: TextStyle(color: AppColors.ai)),
              ),
            ),
            if (_priceSuggestion != null) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.ai.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  border: Border.all(color: AppColors.ai.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        '✨ ราคาแนะนำ: ฿${_priceSuggestion!.suggestedMin} - ฿${_priceSuggestion!.suggestedMax}',
                        style: AppTextStyles.bodyBold.copyWith(color: AppColors.ai)),
                    const SizedBox(height: 2),
                    Text(_priceSuggestion!.reasoning, style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('รายละเอียดสินค้า', style: AppTextStyles.bodyBold),
                TextButton.icon(
                  onPressed: _generatingCaption ? null : _generateCaption,
                  icon: _generatingCaption
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.ai))
                      : const Icon(Icons.auto_awesome, size: 16, color: AppColors.ai),
                  label: const Text('AI เขียนแคปชัน',
                      style: TextStyle(color: AppColors.ai)),
                ),
              ],
            ),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                  hintText: 'รายละเอียดสินค้า หรือให้ AI ช่วยเขียนให้'),
            ),
            const SizedBox(height: AppSpacing.xl),
            ReuniPrimaryButton(
              label: 'Confirm & Post',
              loading: _posting,
              onPressed: _confirmPost,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

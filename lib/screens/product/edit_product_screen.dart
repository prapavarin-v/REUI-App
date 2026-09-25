import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../services/firestore_service.dart';
import '../../models/product_model.dart';
import '../../widgets/common_inputs.dart';

/// Screen 14: แก้ชื่อ / แก้ราคา / แก้รายละเอียด / แก้รูป / แก้สถานะ / Save / Delete
class EditProductScreen extends StatefulWidget {
  final ProductModel product;
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _firestoreService = FirestoreService();
  late final TextEditingController _titleController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  late String _status;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product.title);
    _priceController =
        TextEditingController(text: widget.product.price.toString());
    _descriptionController =
        TextEditingController(text: widget.product.description);
    _status = widget.product.status;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _firestoreService.updateProduct(widget.product.id, {
        'title': _titleController.text.trim(),
        'price': int.tryParse(_priceController.text.trim()) ?? widget.product.price,
        'description': _descriptionController.text.trim(),
        'status': _status,
      });
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบสินค้า'),
        content: const Text('ยืนยันลบสินค้านี้ออกจาก REUNI ใช่หรือไม่?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('ยกเลิก')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('ลบ', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirm == true) {
      await _firestoreService.deleteProduct(widget.product.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขสินค้า'),
        actions: [
          IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: _delete),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: widget.product.images
                    .map((url) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.input),
                            child: Image.network(url,
                                width: 90, height: 90, fit: BoxFit.cover),
                          ),
                        ))
                    .toList(),
              ),
            ),
            // หมายเหตุ: การแก้รูป (เพิ่ม/ลบ/อัปโหลดใหม่) ใช้ StorageService.uploadProductImage
            // ร่วมกับ image_picker เช่นเดียวกับหน้า Upload Product
            const SizedBox(height: AppSpacing.lg),
            ReuniTextField(label: 'ชื่อสินค้า', controller: _titleController),
            const SizedBox(height: AppSpacing.md),
            ReuniTextField(
                label: 'ราคา (บาท)',
                controller: _priceController,
                keyboardType: TextInputType.number),
            const SizedBox(height: AppSpacing.md),
            ReuniTextField(
                label: 'รายละเอียดสินค้า',
                controller: _descriptionController,
                maxLines: 5),
            const SizedBox(height: AppSpacing.md),
            Text('สถานะสินค้า', style: AppTextStyles.bodyBold),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                ProductStatus.available,
                ProductStatus.reserved,
                ProductStatus.sold
              ]
                  .map((s) => ChoiceChip(
                        label: Text(ProductStatus.label(s)),
                        selected: _status == s,
                        onSelected: (_) => setState(() => _status = s),
                      ))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
            ReuniPrimaryButton(label: 'Save', onPressed: _save, loading: _saving),
          ],
        ),
      ),
    );
  }
}

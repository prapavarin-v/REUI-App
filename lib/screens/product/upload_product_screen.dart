import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme.dart';
import 'ai_smart_listing_screen.dart';

/// Screen 11: ถ่ายรูป / เลือกรูปจาก Gallery / Preview / ลบ-เพิ่มรูป
/// จากนั้นไปต่อที่หน้า AI Smart Listing (Screen 12)
class UploadProductScreen extends StatefulWidget {
  const UploadProductScreen({super.key});

  @override
  State<UploadProductScreen> createState() => _UploadProductScreenState();
}

class _UploadProductScreenState extends State<UploadProductScreen> {
  final _picker = ImagePicker();
  final List<File> _images = [];

  Future<void> _takePhoto() async {
    final photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (photo != null) setState(() => _images.add(File(photo.path)));
  }

  Future<void> _pickFromGallery() async {
    final photos = await _picker.pickMultiImage(imageQuality: 85);
    if (photos.isNotEmpty) {
      setState(() => _images.addAll(photos.map((x) => File(x.path))));
    }
  }

  void _removeImage(int index) => setState(() => _images.removeAt(index));

  void _next() {
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('กรุณาเลือกรูปสินค้าอย่างน้อย 1 รูป')));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => AiSmartListingScreen(images: _images)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ลงขายสินค้า')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('เพิ่มรูปสินค้า', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('ถ่ายรูป'),
                    onPressed: _takePhoto,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('เลือกรูป'),
                    onPressed: _pickFromGallery,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: _images.isEmpty
                  ? Center(
                      child: Text('ยังไม่มีรูปสินค้า', style: AppTextStyles.caption))
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: AppSpacing.sm,
                        crossAxisSpacing: AppSpacing.sm,
                      ),
                      itemCount: _images.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.input),
                              child: Image.file(_images[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: const CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.black54,
                                  child: Icon(Icons.close,
                                      size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(onPressed: _next, child: const Text('ถัดไป')),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// StorageService — อัปโหลดรูปภาพผ่าน **Cloudinary** (unsigned upload)
/// แทน Firebase Storage เพื่อไม่ต้องผูกบัตรเครดิต / อัปเกรดเป็น Blaze plan
///
/// วิธีตั้งค่า (ทำครั้งเดียว, ไม่มีค่าใช้จ่าย):
/// 1. สมัครฟรีที่ https://cloudinary.com (ไม่ต้องกรอกบัตรเครดิต)
/// 2. ไปที่ Dashboard แล้วคัดลอกค่า "Cloud name" มาใส่ที่ [_cloudName] ด้านล่าง
/// 3. ไปที่ Settings > Upload > Upload presets > Add upload preset
///    - ตั้งชื่อ preset (เช่น "reuni_unsigned") แล้วเปลี่ยน Signing Mode เป็น **Unsigned**
///    - (แนะนำ) ตั้ง Folder เป็นค่าเริ่มต้น เช่น "reuni" เพื่อจัดระเบียบรูปทั้งหมด
///    - บันทึก แล้วเอาชื่อ preset มาใส่ที่ [_uploadPreset] ด้านล่าง
/// 4. ไม่ต้องใช้ API key/secret ฝั่งแอปเลย เพราะ unsigned preset ออกแบบมาให้อัปโหลด
///    ตรงจาก client ได้อย่างปลอดภัย (จำกัดสิทธิ์แค่ "อัปโหลด" เท่านั้น ลบไฟล์ไม่ได้)
class StorageService {
  // TODO: แทนที่ด้วยค่าจริงจาก Cloudinary Dashboard ของคุณ
  static const String sl4m026f = 'REPLACE_WITH_YOUR_CLOUD_NAME';
  static const String reuni_app = 'REPLACE_WITH_YOUR_UPLOAD_PRESET';

  static Uri get _uploadUrl =>
      Uri.parse('https://api.cloudinary.com/v1_1/$sl4m026f/image/upload');

  /// อัปโหลดรูป 1 ไฟล์ไปยัง Cloudinary ภายใต้ "โฟลเดอร์เสมือน" [folder]
  /// (โฟลเดอร์ใน Cloudinary เป็นแค่ส่วนหนึ่งของชื่อไฟล์ ไม่ใช่ระบบโฟลเดอร์จริง
  /// แต่ใช้แยกหมวดรูปได้เหมือน Firebase Storage เดิม)
  Future<String> _uploadFile(File file, String folder) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

    final request = http.MultipartRequest('POST', _uploadUrl)
      ..fields['upload_preset'] = reuni_app
      ..fields['public_id'] = '$folder/$fileName'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('อัปโหลดรูปไป Cloudinary ไม่สำเร็จ: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    // secure_url คือลิงก์ https ที่ใช้แสดงรูปได้ทันที เก็บค่านี้ลง Firestore เหมือนเดิม
    return data['secure_url'] as String;
  }

  /// อัปโหลดรูปสินค้า -> โฟลเดอร์ products/{ownerId}
  Future<String> uploadProductImage(File file, String ownerId) {
    return _uploadFile(file, 'products/$ownerId');
  }

  Future<List<String>> uploadProductImages(
      List<File> files, String ownerId) async {
    final urls = <String>[];
    for (final f in files) {
      urls.add(await uploadProductImage(f, ownerId));
    }
    return urls;
  }

  /// อัปโหลดรูปโปรไฟล์ -> โฟลเดอร์ profiles
  Future<String> uploadProfileImage(File file, String uid) {
    return _uploadFile(file, 'profiles/$uid');
  }

  /// อัปโหลดรูปที่ส่งในแชท -> โฟลเดอร์ chats/{chatId}
  Future<String> uploadChatImage(File file, String chatId) {
    return _uploadFile(file, 'chats/$chatId');
  }

  /// หมายเหตุ: unsigned upload preset ของ Cloudinary "ลบไฟล์ไม่ได้" ด้วยเหตุผล
  /// ด้านความปลอดภัย (กันคนอื่นยิง request ลบรูปของคนอื่นได้) การลบไฟล์จริง
  /// ต้องทำผ่าน Admin API ที่มี API secret ซึ่งควรเรียกจาก backend/Cloud Function
  /// เท่านั้น ห้ามใส่ API secret ไว้ในแอป — ที่นี่จึงทำเป็นฟังก์ชันเปล่าไว้ก่อน
  /// เพื่อให้โค้ดส่วนอื่นที่เรียก deleteFile() ยังทำงานได้โดยไม่ error
  Future<void> deleteFile(String downloadUrl) async {
    // TODO (ถ้าต้องการลบไฟล์จริง): สร้าง Cloud Function เช่น `deleteCloudinaryImage`
    // ที่รับ public_id แล้วเรียก Cloudinary Admin API (cloudinary.uploader.destroy)
    // ด้วย API secret ที่เก็บไว้ฝั่ง server เท่านั้น แล้วให้แอปเรียก Cloud Function นี้แทน
  }
}

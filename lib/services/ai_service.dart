import 'dart:convert';
import 'package:http/http.dart' as http;

/// ผลลัพธ์จากการวิเคราะห์ราคาโดย AI
class AiPriceSuggestion {
  final int suggestedMin;
  final int suggestedMax;
  final String reasoning;

  AiPriceSuggestion({
    required this.suggestedMin,
    required this.suggestedMax,
    required this.reasoning,
  });

  factory AiPriceSuggestion.fromJson(Map<String, dynamic> json) {
    return AiPriceSuggestion(
      suggestedMin: json['suggestedMin'] ?? 0,
      suggestedMax: json['suggestedMax'] ?? 0,
      reasoning: json['reasoning'] ?? '',
    );
  }
}

/// AiService เรียกไปยัง Cloud Function ของโปรเจกต์ตัวเอง (ไม่เรียก AI API ตรงจากแอป
/// เพื่อไม่ให้ API key หลุดไปอยู่ในไฟล์ apk/ipa)
///
/// ตั้งค่า Cloud Function เช่น:
///   functions/index.js -> exports.aiAnalyzePrice, exports.aiGenerateCaption
/// แล้วเปลี่ยน [baseUrl] เป็น URL ของ Cloud Function จริงของโปรเจกต์
class AiService {
  static const String baseUrl =
      'https://REGION-PROJECT_ID.cloudfunctions.net';

  /// ✨ AI วิเคราะห์ราคา: ส่งชื่อสินค้า, หมวดหมู่, สภาพ -> ได้ช่วงราคาที่แนะนำ
  Future<AiPriceSuggestion> analyzePrice({
    required String title,
    required String category,
    required String condition,
    String? description,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/aiAnalyzePrice'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'category': category,
        'condition': condition,
        'description': description ?? '',
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('AI price analysis failed: ${res.body}');
    }
    return AiPriceSuggestion.fromJson(jsonDecode(res.body));
  }

  /// ✨ AI เขียนแคปชัน/รายละเอียดสินค้าให้อัตโนมัติจากข้อมูลที่ผู้ขายกรอก
  Future<String> generateCaption({
    required String title,
    required String category,
    required String condition,
    int? price,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/aiGenerateCaption'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'category': category,
        'condition': condition,
        'price': price,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('AI caption generation failed: ${res.body}');
    }
    final data = jsonDecode(res.body);
    return data['caption'] as String;
  }
}

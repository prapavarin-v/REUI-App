/// ค่าคงที่ที่ใช้ทั่วทั้งแอป REUNI

class ProductStatus {
  ProductStatus._();
  static const String available = 'available'; // ยังไม่ขาย
  static const String reserved = 'reserved'; // ถูกจองแล้ว
  static const String sold = 'sold'; // ขายแล้ว

  static String label(String status) {
    switch (status) {
      case reserved:
        return 'ถูกจองแล้ว';
      case sold:
        return 'ขายแล้ว';
      default:
        return 'พร้อมขาย';
    }
  }
}

/// สถานะการจอง ตาม Timeline: จอง → รอนัดรับ → นัดรับ → สำเร็จ
class ReservationStatus {
  ReservationStatus._();
  static const String requested = 'requested'; // จอง
  static const String waiting = 'waiting'; // รอนัดรับ
  static const String meetup = 'meetup'; // นัดรับ
  static const String completed = 'completed'; // สำเร็จ
  static const String cancelled = 'cancelled'; // ยกเลิก

  static const List<String> timelineOrder = [
    requested,
    waiting,
    meetup,
    completed,
  ];

  static String label(String status) {
    switch (status) {
      case requested:
        return 'จอง';
      case waiting:
        return 'รอนัดรับ';
      case meetup:
        return 'นัดรับ';
      case completed:
        return 'สำเร็จ';
      case cancelled:
        return 'ยกเลิก';
      default:
        return status;
    }
  }
}

class DefaultCategories {
  DefaultCategories._();

  static const List<Map<String, String>> items = [
    {'id': 'books', 'name': 'หนังสือ', 'icon': '📚'},
    {'id': 'it', 'name': 'IT / อุปกรณ์อิเล็กทรอนิกส์', 'icon': '💻'},
    {'id': 'clothes', 'name': 'เสื้อผ้า', 'icon': '👕'},
    {'id': 'bags', 'name': 'กระเป๋า', 'icon': '🎒'},
    {'id': 'dorm', 'name': 'ของใช้ในหอ', 'icon': '🛏️'},
    {'id': 'other', 'name': 'อื่น ๆ', 'icon': '📦'},
  ];
}

class FirestoreCollections {
  FirestoreCollections._();
  static const String users = 'users';
  static const String products = 'products';
  static const String categories = 'categories';
  static const String favorites = 'favorites';
  static const String chats = 'chats';
  static const String messages = 'messages'; // subcollection ของ chats
  static const String reservations = 'reservations';
}

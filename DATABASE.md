# REUNI — โครงสร้าง Database บน Firebase (Cloud Firestore)

Firebase ที่ใช้ 3 ตัว:
- **Firebase Authentication** — สมัคร/ล็อกอินด้วย University Email (+ Google Student Mail)
- **Cloud Firestore** — เก็บข้อมูลหลักทั้งหมด (NoSQL, เอกสารแบบ collection/document)
- **Firebase Storage** — เก็บรูปสินค้า, รูปโปรไฟล์, รูปที่ส่งในแชท

---

## 1. users/{uid}
เอกสาร id = uid ของ Firebase Auth (เชื่อมกันตรง ๆ ไม่ต้องมีฟิลด์ uid ซ้ำ)

| ฟิลด์ | ชนิด | คำอธิบาย |
|---|---|---|
| name | string | ชื่อ-นามสกุล |
| studentId | string | รหัสนักศึกษา |
| faculty | string | คณะ |
| major | string | สาขา |
| email | string | University Email |
| photoUrl | string | ลิงก์รูปโปรไฟล์ (Storage) |
| rating | number | คะแนนเฉลี่ย 0-5 |
| reviewCount | number | จำนวนรีวิวที่ได้รับ |
| createdAt | timestamp | วันที่สมัคร |

## 2. products/{productId}
| ฟิลด์ | ชนิด | คำอธิบาย |
|---|---|---|
| sellerId | string | uid ผู้ขาย (ref → users) |
| title | string | ชื่อสินค้า |
| description | string | รายละเอียด (คน หรือ AI เขียน) |
| price | number | ราคา (บาท) |
| categoryId | string | ref → categories |
| condition | string | ใหม่มาก / ดี / พอใช้ |
| images | array<string> | ลิงก์รูปสินค้า (Storage) |
| status | string | available / reserved / sold |
| faculty | string | คณะของผู้ขาย (denormalize ไว้เพื่อ filter เร็ว) |
| aiCaption | string? | แคปชันที่ AI เขียน (ถ้ามี) |
| aiGenerated | boolean | true ถ้ารายละเอียดมาจาก AI |
| createdAt | timestamp | วันที่ลงขาย |

Index ที่ต้องสร้าง (composite):
- `status` (==) + `categoryId` (==) + `createdAt` (desc)
- `status` (==) + `faculty` (==) + `createdAt` (desc)
- `sellerId` (==) + `createdAt` (desc)

## 3. categories/{categoryId}
| ฟิลด์ | ชนิด |
|---|---|
| name | string |
| icon | string (emoji) |

Seed เริ่มต้น: หนังสือ, IT, เสื้อผ้า, กระเป๋า, ของใช้ในหอ, อื่น ๆ
(ดู `FirestoreService.seedDefaultCategories()` ในโค้ด)

## 4. favorites/{userId_productId}
ตั้ง document id = `"${userId}_${productId}"` เพื่อกันการกด ❤️ ซ้ำ และ toggle ได้ในคำสั่งเดียว

| ฟิลด์ | ชนิด |
|---|---|
| userId | string |
| productId | string |
| createdAt | timestamp |

## 5. chats/{chatId}
1 ห้องแชท = คู่ (ผู้ซื้อ, สินค้า) เดียว → ตั้ง document id = `"${productId}_${buyerId}"`

| ฟิลด์ | ชนิด |
|---|---|
| participants | array<string> | [buyerId, sellerId] — ใช้ query ด้วย `arrayContains` |
| productId | string |
| productTitle | string (denormalize) |
| productImage | string (denormalize) |
| lastMessage | string |
| lastMessageAt | timestamp |
| unreadCount | map<uid, number> |

### subcollection: chats/{chatId}/messages/{messageId}
| ฟิลด์ | ชนิด |
|---|---|
| chatId | string |
| senderId | string |
| text | string |
| imageUrl | string? |
| createdAt | timestamp |

## 6. reservations/{reservationId}
| ฟิลด์ | ชนิด |
|---|---|
| productId | string |
| productTitle | string |
| buyerId | string |
| sellerId | string |
| status | string | requested → waiting → meetup → completed (หรือ cancelled) |
| meetupLocation | string |
| meetupTime | timestamp? |
| createdAt | timestamp |

Timeline ที่ใช้แสดงผล: **จอง (requested) → รอนัดรับ (waiting) → นัดรับ (meetup) → สำเร็จ (completed)**

---

## ความสัมพันธ์ระหว่าง Collection

```
users (1) ──< products (N)          # ผู้ใช้ 1 คนขายได้หลายชิ้น
users (1) ──< favorites (N)         # ผู้ใช้กด wishlist ได้หลายชิ้น
users (1) ──< reservations (N)      # เป็นได้ทั้ง buyer/seller
users (1) ──< chats (N)             # ผ่าน participants array

products (1) ──< favorites (N)
products (1) ──< reservations (N)   # ปกติ 1 สินค้าไม่ควรมีมากกว่า 1 reservation ที่ active
products (1) ──< chats (N)          # ผู้ซื้อหลายคนคุยกับผู้ขายคนเดียวกันได้ (คนละห้อง)
categories (1) ──< products (N)
chats (1) ──< messages (N)          # subcollection
```

## เหตุผลที่ออกแบบแบบ denormalize บางฟิลด์
Firestore ไม่มี JOIN เหมือน SQL การ query ข้อมูลที่ต้องแสดงผลบ่อย (เช่น productTitle,
productImage ในหน้าแชท) จึงถูกคัดลอก (denormalize) เก็บไว้ในเอกสารที่ใช้แสดงผลโดยตรง
เพื่อลดจำนวนการอ่าน (read) และทำให้ UI โหลดเร็วขึ้น แลกกับการต้องอัปเดตหลายที่เวลาแก้ไขต้นทาง
(ในระบบนี้แทบไม่มีผลเพราะ title/image ของสินค้าที่แชทอยู่แล้วมักไม่ถูกแก้ระหว่างคุย)

## รูปภาพ — เก็บผ่าน Cloudinary (ไม่ใช้ Firebase Storage)

Firebase Storage ตั้งแต่ราวเดือนกันยายน 2024 ต้องอัปเกรดโปรเจกต์เป็นแผน **Blaze**
(ต้องผูกบัตรเครดิต) ถึงจะเปิดใช้ได้ แม้ใช้ไม่เกินโควตาฟรีก็ตาม โปรเจกต์นี้จึงเปลี่ยนไป
อัปโหลดรูปผ่าน **Cloudinary** แทน (ฟรี 25GB ไม่ต้องผูกบัตร) แล้วเก็บแค่ "ลิงก์รูป" (URL)
ไว้ในฟิลด์ `images` / `photoUrl` / `imageUrl` ของ Firestore เหมือนเดิมทุกประการ —
Firestore/Auth ทั้งระบบยังคงอยู่บนแผน Spark (ฟรี) ตามเดิม ไม่กระทบ

ดูโค้ดที่ `lib/services/storage_service.dart` และคอมเมนต์ในไฟล์สำหรับขั้นตอนสมัคร/ตั้งค่า
Cloudinary (สมัคร cloud name + สร้าง unsigned upload preset)

โครงสร้าง "โฟลเดอร์เสมือน" ใน Cloudinary ที่ใช้:
```
/products/{sellerId}/{timestamp}_{filename}.jpg
/profiles/{uid}/{timestamp}_{filename}.jpg
/chats/{chatId}/{timestamp}_{filename}.jpg
```

## ขั้นตอนตั้งค่า Firebase + Cloudinary (สรุป)
1. สร้างโปรเจกต์ที่ https://console.firebase.google.com
2. เปิดใช้ **Authentication** → Sign-in method → Email/Password (และ Google ถ้าต้องการ Google Student Mail)
3. สร้าง **Cloud Firestore** (โหมด production) แล้วนำ `firestore.rules` ในโปรเจกต์นี้ไปวางใน Rules tab
4. รัน `flutterfire configure` ที่ root โปรเจกต์ Flutter เพื่อสร้าง `lib/firebase_options.dart` จริง
5. เรียก `FirestoreService().seedDefaultCategories()` ครั้งเดียว (เช่นจากปุ่ม debug ชั่วคราว) เพื่อสร้างหมวดหมู่เริ่มต้น
6. สมัคร Cloudinary ฟรีที่ https://cloudinary.com (ไม่ต้องผูกบัตร) → คัดลอก Cloud name
   และสร้าง Unsigned upload preset ตามขั้นตอนในคอมเมนต์ของ `storage_service.dart`
   แล้วนำค่าไปแทนที่ `_cloudName` และ `_uploadPreset` ในไฟล์นั้น
7. (ทางเลือก) สร้าง Cloud Functions `aiAnalyzePrice` และ `aiGenerateCaption` ที่เรียก AI API จริงฝั่ง backend
   แล้วแก้ `AiService.baseUrl` ในโค้ดให้ตรงกับ URL ของโปรเจกต์

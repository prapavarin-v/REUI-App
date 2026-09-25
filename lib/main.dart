import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme.dart';
import 'firebase_options.dart';
// import 'services/firestore_service.dart';
import 'screens/auth/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // TODO(ชั่วคราว): รันแอป 1 ครั้งเพื่อสร้างหมวดหมู่เริ่มต้นใน Firestore
  // แล้วให้ "ลบบรรทัดนี้ออก" ก่อน build จริง — ไม่งั้นแอปจะเขียนทับ
  // collection "categories" ทุกครั้งที่เปิดแอป (ไม่พัง แต่เปลือง write quota)


  runApp(const ReuniApp());
}

class ReuniApp extends StatelessWidget {
  const ReuniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'REUNI',
      debugShowCheckedModeBanner: false,
      theme: buildReuniTheme(),
      home: const SplashScreen(),
    );
  }
}

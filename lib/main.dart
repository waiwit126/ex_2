// lib/main.dart

// นำเข้าไลบรารีหลักของ Flutter สำหรับสร้าง UI แบบ Material Design
import 'package:flutter/material.dart';

// นำเข้าไฟล์หน้าจอ HomeScreen ที่อยู่ในโปรเจกต์ (package ชื่อ ex124)
// นี่คือหน้าจอแรกที่จะแสดงเมื่อเปิดแอป
import 'package:ex124/screens/home_screen.dart';

// ฟังก์ชัน main() คือจุดเริ่มต้นการทำงานของโปรแกรม Dart/Flutter ทุกตัว
// runApp() จะสั่งให้ Flutter นำ widget ที่ส่งเข้าไป (MyApp) มาวาดเป็นแอปทั้งหน้าจอ
void main() => runApp(const MyApp());

// MyApp คือ widget รากของแอปทั้งหมด (root widget)
// เป็น StatelessWidget เพราะตัวมันเองไม่มีข้อมูลที่เปลี่ยนแปลงได้ (ไม่มี state)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp คือ widget ที่ครอบแอปทั้งหมด กำหนดค่าตั้งต้นระดับแอป เช่น
    // ธีม, ชื่อแอป, หน้าแรกที่แสดง ฯลฯ
    return MaterialApp(
      // ซ่อนป้าย "DEBUG" มุมขวาบนตอนรันโหมด debug
      debugShowCheckedModeBanner: false,

      // ชื่อแอป (ใช้ในบาง context เช่น task switcher ของ OS)
      title: 'สมุดบันทึกคำศัพท์',

      // กำหนดธีม (สี, สไตล์) ที่ใช้ทั่วทั้งแอป
      theme: ThemeData(
        useMaterial3: true, // เปิดใช้ดีไซน์ Material Design เวอร์ชัน 3

        // ปรับแต่ง AppBar (แถบด้านบนของแต่ละหน้าจอ) ให้ใช้ค่าเดียวกันทุกหน้า
        appBarTheme: const AppBarTheme(
          centerTitle: true, // จัดชื่อหน้าให้อยู่กึ่งกลาง AppBar
          backgroundColor: Color.fromARGB(255, 146, 127, 127), // สีพื้นหลัง AppBar (สีน้ำตาลอมเทา)
          foregroundColor: Color.fromARGB(255, 0, 0, 0),       // สีตัวอักษร/ไอคอนบน AppBar (สีดำ)
        ),
      ),

      // หน้าจอแรกที่จะแสดงเมื่อเปิดแอป
      home: const HomeScreen(),
    );
  }
}
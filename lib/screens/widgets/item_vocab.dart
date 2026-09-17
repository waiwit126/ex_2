// lib/screens/widgets/item_vocab.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ใช้จัดรูปแบบวันที่ให้อ่านง่าย

import '../../models/vocab.dart'; // โมเดลข้อมูลคำศัพท์

// StatelessWidget เพราะ widget นี้แค่ "รับข้อมูลมาแสดงผล"
// ไม่มี state ภายในของตัวเอง ทุกอย่างส่งเข้ามาจากภายนอก
class ItemVocab extends StatelessWidget {
  final Vocab vocab;          // ข้อมูลคำศัพท์ที่จะแสดง
  final VoidCallback onTap;   // ฟังก์ชันที่เรียกเมื่อแตะที่การ์ด (ส่งมาจาก HomeScreen)
  final VoidCallback onDelete; // ฟังก์ชันที่เรียกเมื่อสั่งลบ (ยังไม่ได้เรียกใช้จริงในตัวนี้)

  const ItemVocab({
    super.key,
    required this.vocab,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // รูปแบบวันที่: เช่น "5 Jan 2025, 14:30"
    final dateFormat = DateFormat('d MMM yyyy, HH:mm');

    // ครอบทั้งการ์ดด้วย GestureDetector เพื่อดักจับการแตะ (tap) ทั้งใบ
    return GestureDetector(
      onTap: onTap, // เมื่อแตะการ์ด -> เรียกฟังก์ชันที่ HomeScreen ส่งมา (เปิด dialog ตัวเลือก)
      child: Card(
        margin: const EdgeInsets.only(bottom: 12), // เว้นระยะห่างระหว่างการ์ดแต่ละใบ
        color: const Color.fromARGB(226, 199, 195, 183), // สีพื้นหลังการ์ด (เบจ/เทาอ่อน)
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            // จัดให้เนื้อหาชิดด้านบนของแถว (เผื่อบางฝั่งข้อความยาวกว่า)
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ฝั่งซ้าย: คำศัพท์ + ชนิดคำ + วันที่สร้าง (กินพื้นที่ 2 ส่วน)
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // คำศัพท์ (ตัวหนา ตัวใหญ่สุด)
                    Text(
                      vocab.word,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, // ยาวเกินไปให้ตัดแล้วใส่ "..."
                    ),
                    const SizedBox(height: 4),

                    // ชนิดของคำ (เช่น noun, verb) แสดงในวงเล็บ
                    Text(
                      '(${vocab.wordType})',
                      style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                    ),
                    const SizedBox(height: 4),

                    // วันที่สร้างรายการนี้ (แปลงเป็น DateTime ที่จัดรูปแบบแล้ว)
                    Text(
                      dateFormat.format(vocab.createdAt),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8), // ช่องว่างระหว่างฝั่งซ้าย-ขวา

              // ฝั่งขวา: คำแปล (กินพื้นที่ 3 ส่วน = กว้างกว่าฝั่งซ้าย)
              Expanded(
                flex: 3,
                child: Text(
                  vocab.translation,
                  maxLines: 3,                     // แสดงได้สูงสุด 3 บรรทัด
                  overflow: TextOverflow.ellipsis, // ยาวเกินตัดแล้วใส่ "..."
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
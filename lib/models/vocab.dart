// lib/models/vocab.dart

/// โมเดลข้อมูลสำหรับ "คำศัพท์" หนึ่งรายการ
/// ใช้แทนข้อมูล 1 แถวในตาราง vocab ของฐานข้อมูล
class Vocab {
  final int? id; // รหัสอ้างอิงของคำศัพท์ (nullable เพราะตอนสร้างใหม่ยังไม่มี id, ฐานข้อมูลจะ auto-increment ให้)
  final String word; // คำศัพท์
  final String translation; // คำแปลของคำศัพท์
  final String wordType; // ประเภทของคำ เช่น noun, verb, adjective
  final DateTime createdAt; // วันเวลาที่สร้าง/เพิ่มคำศัพท์นี้

  /// Constructor สำหรับสร้าง object Vocab
  /// id เป็นตัวเลือก (optional) ส่วนฟิลด์อื่นๆ จำเป็นต้องระบุทุกครั้ง
  Vocab({
    this.id,
    required this.word,
    required this.translation,
    required this.wordType,
    required this.createdAt,
  });

  /// แปลง object Vocab ให้เป็น Map<String, dynamic>
  /// ใช้สำหรับบันทึก/อัปเดตข้อมูลลงฐานข้อมูล (sqflite ต้องการข้อมูลในรูป Map)
  Map<String, dynamic> toMap() => {
        'id': id,
        'word': word,
        'translation': translation,
        'wordType': wordType,
        // แปลง DateTime เป็น String รูปแบบ ISO 8601 เพราะ SQLite ไม่มีชนิดข้อมูล DateTime โดยตรง
        'createdAt': createdAt.toIso8601String(),
      };

  /// factory constructor สำหรับแปลงข้อมูลจากฐานข้อมูล (Map) กลับมาเป็น object Vocab
  /// ใช้ตอนดึงข้อมูล (query) ออกมาจากตาราง vocab
  factory Vocab.fromMap(Map<String, dynamic> map) => Vocab(
        id: map['id'] as int?,
        word: map['word'] as String,
        translation: map['translation'] as String,
        wordType: map['wordType'] as String,
        // แปลง String กลับเป็น DateTime
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}
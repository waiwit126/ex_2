import 'package:flutter/material.dart';
import '../../models/vocab.dart';
import '../../repository/database_repository.dart';

class AddVocabScreen extends StatefulWidget {
  final Vocab? vocab; // ถ้าส่งค่ามา = โหมด "แก้ไข", ถ้าเป็น null = โหมด "เพิ่มใหม่"

  const AddVocabScreen({super.key, this.vocab});

  @override
  State<AddVocabScreen> createState() => _AddVocabScreenState();
}

class _AddVocabScreenState extends State<AddVocabScreen> {
  final _formKey = GlobalKey<FormState>();           // ใช้ควบคุม/ตรวจสอบความถูกต้องของฟอร์มทั้งหมด
  final _wordController = TextEditingController();   // ควบคุมช่องกรอก "คำศัพท์"
  final _translationController = TextEditingController(); // ควบคุมช่องกรอก "คำแปล"

  String? _wordType;                                  // ชนิดของคำที่เลือกใน dropdown
  final _wordTypes = ['Noun', 'Verb', 'Adjective'];   // ตัวเลือกชนิดคำที่มีให้เลือก
  bool _isSaving = false;                              // ใช้ล็อกปุ่มบันทึกระหว่างกำลังบันทึก (กันกดซ้ำ)

  // getter ช่วยเช็คสั้นๆ ว่าตอนนี้อยู่โหมดแก้ไขหรือเพิ่มใหม่
  bool get isEdit => widget.vocab != null;

  @override
  void initState() {
    super.initState();
    // ถ้าเป็นโหมดแก้ไข -> เอาข้อมูลเดิมมาใส่ในช่องกรอกและ dropdown ล่วงหน้า
    if (isEdit) {
      _wordController.text = widget.vocab!.word;
      _translationController.text = widget.vocab!.translation;
      _wordType = widget.vocab!.wordType;
    }
  }

  @override
  void dispose() {
    // คืนหน่วยความจำของ TextEditingController เมื่อออกจากหน้านี้ (ป้องกัน memory leak)
    _wordController.dispose();
    _translationController.dispose();
    super.dispose();
  }

  // เมื่อกดปุ่ม "บันทึก"
  Future<void> _save() async {
    // ตรวจสอบความถูกต้องของฟอร์มก่อน (validator ในแต่ละช่อง) ถ้าไม่ผ่านให้หยุด
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true); // ล็อกปุ่มไว้กันกดซ้ำระหว่างบันทึก

    try {
      if (isEdit) {
        // โหมดแก้ไข: สร้างข้อมูลใหม่โดยคง id และวันที่สร้างเดิมไว้ (แก้แค่เนื้อหา)
        final data = Vocab(
          id: widget.vocab!.id,
          word: _wordController.text.trim(),
          translation: _translationController.text.trim(),
          wordType: _wordType!,
          createdAt: widget.vocab!.createdAt,
        );
        await DatabaseRepository.instance.update(data);
      } else {
        // โหมดเพิ่มใหม่: ไม่มี id (ให้ฐานข้อมูล gen เอง), createdAt = เวลาปัจจุบัน
        final data = Vocab(
          word: _wordController.text.trim(),
          translation: _translationController.text.trim(),
          wordType: _wordType!,
          createdAt: DateTime.now(),
        );
        await DatabaseRepository.instance.insert(data);
      }

      if (!mounted) return; // เช็คว่า widget ยังอยู่บนหน้าจอไหม (กัน error ถ้าผู้ใช้ปิดหน้าไปแล้ว)
      Navigator.pop(context); // บันทึกเสร็จ -> กลับไปหน้า HomeScreen
    } catch (e) {
      // ถ้าบันทึกล้มเหลว -> แสดง SnackBar แจ้ง error แทนที่จะแอปพัง
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('บันทึกไม่สำเร็จ: $e')),
      );
    } finally {
      // ไม่ว่าสำเร็จหรือพลาด ก็ปลดล็อกปุ่มบันทึกเสมอ (ถ้า widget ยังอยู่)
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // เมื่อกดปุ่มถังขยะ (มีเฉพาะตอนแก้ไข)
  Future<void> _delete() async {
    // เปิด dialog ถามยืนยันก่อนลบ แล้วรอผล (true = ยืนยันลบ, false/null = ยกเลิก)
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยัน'),
        content: const Text('ต้องการลบคำนี้ใช่ไหม?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (ok != true) return; // ผู้ใช้ไม่ได้กดยืนยันลบ -> หยุด ไม่ทำอะไรต่อ

    await DatabaseRepository.instance.delete(widget.vocab!.id!);
    if (!mounted) return;
    Navigator.pop(context); // ลบเสร็จ -> กลับไปหน้า HomeScreen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // เปลี่ยนหัวข้อ AppBar ตามโหมด: แก้ไข หรือ เพิ่ม
        title: Text(isEdit ? 'แก้ไขคำศัพท์' : 'เพิ่มคำศัพท์'),
        actions: [
          // แสดงปุ่มลบ (ถังขยะ) เฉพาะตอนอยู่โหมดแก้ไขเท่านั้น
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _delete,
            ),
        ],
      ),
      body: SingleChildScrollView( // กันจอล้นเวลาคีย์บอร์ดเด้งขึ้นมา
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey, // ผูกฟอร์มกับ key เพื่อเรียก validate() ได้
          child: Column(
            children: [
              // --- ช่องกรอกคำศัพท์ ---
              TextFormField(
                controller: _wordController,
                decoration: const InputDecoration(
                  labelText: 'คำศัพท์',
                  border: OutlineInputBorder(),
                ),
                // validator: ถ้าเว้นว่างไว้ ให้ขึ้นข้อความแจ้งเตือน
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณากรอกคำศัพท์';
                  }
                  return null; // null = ผ่าน ไม่มี error
                },
              ),
              const SizedBox(height: 16),

              // --- ช่องกรอกคำแปล (พิมพ์ได้หลายบรรทัด) ---
              TextFormField(
                controller: _translationController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'คำแปล',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณากรอกคำแปล';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // --- Dropdown เลือกชนิดของคำ (Noun/Verb/Adjective) ---
              DropdownButtonFormField<String>(
                value: _wordType, // ค่าที่เลือกอยู่ปัจจุบัน
                decoration: const InputDecoration(
                  labelText: 'ชนิดของคำ',
                  border: OutlineInputBorder(),
                ),
                // สร้างรายการตัวเลือกจาก _wordTypes
                items: _wordTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => _wordType = value); // อัปเดตค่าที่เลือก + rebuild UI
                },
                validator: (value) {
                  if (value == null) return 'กรุณาเลือกชนิดของคำ';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // --- ปุ่มบันทึก ---
              ElevatedButton(
                // ถ้ากำลังบันทึกอยู่ (_isSaving = true) ให้ปิดปุ่ม (onPressed: null) กันกดซ้ำ
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 207, 104, 0),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 48), // ปุ่มยาวเต็มความกว้างจอ
                ),
                // ข้อความบนปุ่มเปลี่ยนตามโหมด
                child: Text(isEdit ? 'บันทึกการแก้ไข' : 'บันทึกคำศัพท์'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../models/vocab.dart';
import '../../repository/database_repository.dart';

class AddVocabScreen extends StatefulWidget {
  final Vocab? vocab; // ถ้ามีค่า = โหมดแก้ไข

  const AddVocabScreen({super.key, this.vocab});

  @override
  State<AddVocabScreen> createState() => _AddVocabScreenState();
}

class _AddVocabScreenState extends State<AddVocabScreen> {
  final _formKey = GlobalKey<FormState>();
  final _wordController = TextEditingController();
  final _translationController = TextEditingController();

  String? _wordType;
  final _wordTypes = ['Noun', 'Verb', 'Adjective'];
  bool _isSaving = false;

  // เช็คว่าเป็นโหมดแก้ไขไหม
  bool get isEdit => widget.vocab != null;

  @override
  void initState() {
    super.initState();
    // ถ้าเป็นโหมดแก้ไข ให้ใส่ข้อมูลเดิมลงไป
    if (isEdit) {
      _wordController.text = widget.vocab!.word;
      _translationController.text = widget.vocab!.translation;
      _wordType = widget.vocab!.wordType;
    }
  }

  @override
  void dispose() {
    _wordController.dispose();
    _translationController.dispose();
    super.dispose();
  }

  // กดปุ่มบันทึก
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      if (isEdit) {
        // แก้ไข
        final data = Vocab(
          id: widget.vocab!.id,
          word: _wordController.text.trim(),
          translation: _translationController.text.trim(),
          wordType: _wordType!,
          createdAt: widget.vocab!.createdAt,
        );
        await DatabaseRepository.instance.update(data);
      } else {
        // เพิ่มใหม่
        final data = Vocab(
          word: _wordController.text.trim(),
          translation: _translationController.text.trim(),
          wordType: _wordType!,
          createdAt: DateTime.now(),
        );
        await DatabaseRepository.instance.insert(data);
      }

      if (!mounted) return;
      Navigator.pop(context); // กลับหน้าหลัก
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('บันทึกไม่สำเร็จ: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // กดปุ่มลบ
  Future<void> _delete() async {
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

    if (ok != true) return;

    await DatabaseRepository.instance.delete(widget.vocab!.id!);
    if (!mounted) return;
    Navigator.pop(context); // กลับหน้าหลัก
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'แก้ไขคำศัพท์' : 'เพิ่มคำศัพท์'),
        actions: [
          // แสดงปุ่มลบเฉพาะตอนแก้ไข
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _delete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ช่องคำศัพท์
              TextFormField(
                controller: _wordController,
                decoration: const InputDecoration(
                  labelText: 'คำศัพท์',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณากรอกคำศัพท์';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ช่องคำแปล
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

              // เลือกชนิดคำ
              DropdownButtonFormField<String>(
                value: _wordType,
                decoration: const InputDecoration(
                  labelText: 'ชนิดของคำ',
                  border: OutlineInputBorder(),
                ),
                items: _wordTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => _wordType = value);
                },
                validator: (value) {
                  if (value == null) return 'กรุณาเลือกชนิดของคำ';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // ปุ่มบันทึก
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 207, 104, 0),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text(isEdit ? 'บันทึกการแก้ไข' : 'บันทึกคำศัพท์'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
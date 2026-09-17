import 'package:flutter/material.dart';
import '../models/vocab.dart';                      // โมเดลข้อมูลคำศัพท์ (Vocab)
import '../repository/database_repository.dart';    // ตัวจัดการฐานข้อมูล (CRUD)
import 'add-vocab/add_vocab_screen.dart';            // หน้าจอสำหรับเพิ่ม/แก้ไขคำศัพท์
import 'widgets/item_vocab.dart';                    // widget การ์ดแสดงคำศัพท์แต่ละรายการ

// เป็น StatefulWidget เพราะหน้านี้ต้อง "จำ" และอัปเดตรายการคำศัพท์ที่โหลดมาได้
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // เก็บ Future ของรายการคำศัพท์ไว้ ใช้กับ FutureBuilder ตอน build UI
  late Future<List<Vocab>> _vocabFuture;

  @override
  void initState() {
    super.initState();
    _loadData(); // โหลดข้อมูลทันทีที่หน้าจอถูกสร้างขึ้นครั้งแรก
  }

  // ดึงรายการคำศัพท์ทั้งหมดจากฐานข้อมูล (asynchronous)
  void _loadData() {
    _vocabFuture = DatabaseRepository.instance.get();
  }

  // เปิดหน้า "เพิ่มคำศัพท์" แล้วรอผลจนผู้ใช้กลับมา
  // เมื่อกลับมาแล้ว เรียก _loadData() ใหม่ + setState เพื่อรีเฟรชรายการ
  Future<void> _goToAdd() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddVocabScreen()),
    );
    setState(() => _loadData());
  }

  // เปิดหน้าเดียวกัน แต่ส่ง vocab เดิมเข้าไปด้วย = โหมดแก้ไขข้อมูลที่มีอยู่แล้ว
  Future<void> _goToEdit(Vocab vocab) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddVocabScreen(vocab: vocab)),
    );
    setState(() => _loadData());
  }

  // ลบคำศัพท์ออกจากฐานข้อมูลโดยใช้ id แล้วรีเฟรชรายการ
  Future<void> _delete(Vocab vocab) async {
    await DatabaseRepository.instance.delete(vocab.id!);
    setState(() => _loadData());
  }

  // แสดง popup ถามว่าจะ "ยกเลิก / ลบ / แก้ไข" คำศัพท์ที่เลือก
  void _showOptions(Vocab vocab) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(vocab.word), // แสดงคำศัพท์ที่เลือกเป็นหัวข้อ
        content: const Text('จำคำนี้ได้แล้วใช่หรือไม่? (ลบ/ยกเลิก)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // ปิด dialog เฉยๆ
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // ปิด dialog ก่อน
              _delete(vocab);          // แล้วค่อยลบ
            },
            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // ปิด dialog ก่อน
              _goToEdit(vocab);        // แล้วไปหน้าแก้ไข
            },
            child: const Text('แก้ไข'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('สมุดบันทึกคำศัพท์')),

      // FutureBuilder = widget ที่รอผลจาก Future แล้วเปลี่ยนหน้าตาตามสถานะ
      body: FutureBuilder<List<Vocab>>(
        future: _vocabFuture,
        builder: (context, snapshot) {
          // 1) กำลังโหลดข้อมูลอยู่ -> แสดง loading spinner
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2) โหลดผิดพลาด -> แสดงข้อความ error
          if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          }

          // 3) โหลดสำเร็จ -> เอาข้อมูลมาใช้ (ถ้าเป็น null ให้ใช้ list ว่างแทน)
          final list = snapshot.data ?? [];

          // 3.1) ไม่มีคำศัพท์เลย -> แสดงข้อความชวนให้กดเพิ่ม
          if (list.isEmpty) {
            return const Center(
              child: Text(
                'ยังไม่มีคำศัพท์ กด + เพื่อเพิ่ม',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          // 3.2) มีข้อมูล -> แสดงเป็นรายการ (ListView) โดยใช้ widget ItemVocab
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return ItemVocab(
                vocab: item,
                onTap: () => _showOptions(item), // แตะการ์ด -> เปิด dialog ตัวเลือก
                onDelete: () {},                 // (ยังไม่ได้ใช้งานจริง - ปล่อยว่างไว้)
              );
            },
          );
        },
      ),

      // ปุ่มลอย (+) มุมล่างขวา สำหรับไปหน้าเพิ่มคำศัพท์
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAdd,
        backgroundColor: const Color.fromARGB(255, 214, 143, 102),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../models/vocab.dart';
import '../repository/database_repository.dart';
import 'add-vocab/add_vocab_screen.dart';
import 'widgets/item_vocab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Vocab>> _vocabFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _vocabFuture = DatabaseRepository.instance.get();
  }

  // ไปหน้าเพิ่มคำศัพท์
  Future<void> _goToAdd() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddVocabScreen()),
    );
    setState(() => _loadData());
  }

  // ไปหน้าแก้ไข
  Future<void> _goToEdit(Vocab vocab) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddVocabScreen(vocab: vocab)),
    );
    setState(() => _loadData());
  }

  // ลบคำศัพท์
  Future<void> _delete(Vocab vocab) async {
    await DatabaseRepository.instance.delete(vocab.id!);
    setState(() => _loadData());
  }

  // แสดง Dialog เลือก ยกเลิก / ลบ / แก้ไข
  void _showOptions(Vocab vocab) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(vocab.word),
        content: const Text('จำคำนี้ได้แล้วใช่หรือไม่? (ลบ/ยกเลิก)'),
        actions: [
          // ปุ่มยกเลิก
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          // ปุ่มลบ
          TextButton(
            onPressed: () {
              Navigator.pop(context); // ปิด dialog
              _delete(vocab);
            },
            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
          // ปุ่มแก้ไข
          TextButton(
            onPressed: () {
              Navigator.pop(context); // ปิด dialog
              _goToEdit(vocab);
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
      body: FutureBuilder<List<Vocab>>(
        future: _vocabFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          }

          final list = snapshot.data ?? [];

          if (list.isEmpty) {
            return const Center(
              child: Text(
                'ยังไม่มีคำศัพท์ กด + เพื่อเพิ่ม',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return ItemVocab(
                vocab: item,
                onTap: () => _showOptions(item), // กดแล้วขึ้นตัวเลือก
                onDelete: () {},
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAdd,
        backgroundColor: const Color.fromARGB(255, 214, 143, 102),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
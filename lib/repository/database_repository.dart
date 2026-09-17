// lib/repository/database_repository.dart
import 'package:flutter/foundation.dart' show kIsWeb; // เช็คว่ารันบน Web หรือไม่
import 'package:path/path.dart'; // ใช้ join() สำหรับรวม path ของไฟล์ฐานข้อมูล
import 'package:sqflite/sqflite.dart'; // ไลบรารีหลักสำหรับจัดการฐานข้อมูล SQLite
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'; // รองรับ sqflite บน Web
import '../models/vocab.dart'; // โมเดลข้อมูลคำศัพท์ (Vocab)

/// คลาสสำหรับจัดการฐานข้อมูล SQLite ของแอป (เก็บข้อมูลคำศัพท์)
/// ใช้รูปแบบ Singleton เพื่อให้มี instance เดียวตลอดการทำงานของแอป
class DatabaseRepository {
  // Constructor แบบ private เพื่อป้องกันการสร้าง instance จากภายนอก
  DatabaseRepository._internal();

  // instance เดียวที่ใช้ร่วมกันทั้งแอป (Singleton pattern)
  static final DatabaseRepository instance = DatabaseRepository._internal();

  // ตัวแปรเก็บ object ฐานข้อมูล (nullable เพราะยังไม่ถูกเปิดตอนเริ่มต้น)
  static Database? _database;

  /// getter สำหรับเรียกใช้งานฐานข้อมูล
  /// ถ้ายังไม่เคยเปิดฐานข้อมูล จะทำการเปิด (init) ก่อน แล้วเก็บไว้ใช้ซ้ำ
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // แก้ไขข้อมูล
  /// อัปเดตข้อมูลคำศัพท์ที่มีอยู่แล้ว โดยอ้างอิงจาก id
  /// คืนค่าจำนวนแถวที่ถูกแก้ไข (ปกติควรเป็น 1 ถ้าสำเร็จ)
  Future<int> update(Vocab vocab) async {
    final db = await database;
    return await db.update(
      'vocab',
      vocab.toMap()..remove('id'), // เอา id ออกจากข้อมูลที่จะอัปเดต เพราะใช้แค่เป็นเงื่อนไข where
      where: 'id = ?',
      whereArgs: [vocab.id],
    );
  }

  /// ฟังก์ชันสำหรับเปิด/สร้างฐานข้อมูล (เรียกใช้ครั้งแรกครั้งเดียว)
  Future<Database> _initDatabase() async {
    // ถ้าเป็น Web ให้ใช้ factory ของ sqflite_common_ffi_web
    // เพราะ sqflite ปกติใช้ native SQLite ซึ่งไม่รองรับบน Web
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }

    // หา path ของโฟลเดอร์เก็บฐานข้อมูลของอุปกรณ์
    final dbPath = await getDatabasesPath();
    // รวม path กับชื่อไฟล์ฐานข้อมูล
    final path = join(dbPath, 'vocab_book.db');

    // เปิดฐานข้อมูล ถ้ายังไม่มีไฟล์จะสร้างใหม่ตาม onCreate
    return await openDatabase(
      path,
      version: 1, // เวอร์ชันของโครงสร้างฐานข้อมูล (ใช้สำหรับ migration ในอนาคต)
      onCreate: (db, version) async {
        // สร้างตาราง vocab ตอนเปิดฐานข้อมูลครั้งแรก
        await db.execute('''
          CREATE TABLE vocab (
            id INTEGER PRIMARY KEY AUTOINCREMENT, -- รหัสอ้างอิงอัตโนมัติของแต่ละคำศัพท์
            word TEXT NOT NULL,                   -- คำศัพท์
            translation TEXT NOT NULL,             -- คำแปล
            wordType TEXT NOT NULL,                -- ประเภทของคำ (เช่น noun, verb)
            createdAt TEXT NOT NULL                -- วันเวลาที่เพิ่มข้อมูล
          )
        ''');
      },
    );
  }

  /// เพิ่มคำศัพท์ใหม่ คืนค่า id ของแถวที่เพิ่ม
  /// ถ้ามี id ซ้ำ จะใช้ ConflictAlgorithm.replace (เขียนทับข้อมูลเดิม)
  Future<int> insert(Vocab vocab) async {
    final db = await database;
    return await db.insert(
      'vocab',
      vocab.toMap()..remove('id'), // เอา id ออก เพื่อให้ฐานข้อมูล auto-increment ให้เอง
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// ดึงคำศัพท์ทั้งหมด เรียงจากใหม่ไปเก่า (ตามวันที่สร้างล่าสุดก่อน)
  Future<List<Vocab>> get() async {
    final db = await database;
    final maps = await db.query('vocab', orderBy: 'createdAt DESC');
    // แปลงผลลัพธ์ (List<Map>) ให้เป็น List<Vocab> โดยใช้ Vocab.fromMap
    return maps.map((map) => Vocab.fromMap(map)).toList();
  }

  /// ลบคำศัพท์ตาม id ที่ระบุ คืนค่าจำนวนแถวที่ถูกลบ
  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete('vocab', where: 'id = ?', whereArgs: [id]);
  }
}
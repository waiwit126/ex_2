// lib/repository/database_repository.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import '../models/vocab.dart';

class DatabaseRepository {
  DatabaseRepository._internal();
  static final DatabaseRepository instance = DatabaseRepository._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  // แก้ไขข้อมูล
Future<int> update(Vocab vocab) async {
  final db = await database;
  return await db.update(
    'vocab',
    vocab.toMap()..remove('id'),
    where: 'id = ?',
    whereArgs: [vocab.id],
  );
}
  Future<Database> _initDatabase() async {
    // ถ้าเป็น Web ให้ใช้ factory ของ sqflite_common_ffi_web
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'vocab_book.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE vocab (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            word TEXT NOT NULL,
            translation TEXT NOT NULL,
            wordType TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// เพิ่มคำศัพท์ใหม่ คืนค่า id ของแถวที่เพิ่ม
  Future<int> insert(Vocab vocab) async {
    final db = await database;
    return await db.insert(
      'vocab',
      vocab.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// ดึงคำศัพท์ทั้งหมด เรียงจากใหม่ไปเก่า
  Future<List<Vocab>> get() async {
    final db = await database;
    final maps = await db.query('vocab', orderBy: 'createdAt DESC');
    return maps.map((map) => Vocab.fromMap(map)).toList();
  }

  /// ลบคำศัพท์ตาม id
  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete('vocab', where: 'id = ?', whereArgs: [id]);
  }
}
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._();
  // Define a constructor
  DatabaseHelper();
  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  get databaseHelper => null;

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = '${documentsDirectory.path}/dapen_13062024.db';

    return await openDatabase(
      path,
      version: 2, // Update the version number
      onCreate: (db, version) async {
        await _createTables(db, version); // Call the updated _createTables function
      },
      onUpgrade: (db, oldVersion, newVersion) {
        // Handle database migration if needed
      },
    );

  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY,
      id_group INTEGER,
      id_company INTEGER,
      id_cabang INTEGER,
      nama_lengkap TEXT,
      nik TEXT,
      tgl_masuk_kerja TEXT,
      no_ktp TEXT,
      tmp_lahir TEXT,
      tgl_lahir TEXT,
      email TEXT,
      no_telepon TEXT,
      alamat TEXT,
      nama_user TEXT,
      password TEXT,
      foto TEXT,
      aktif TEXT,
      UNIQUE (id, id_group)
    )
    ''');
  }

  Future<void> closeDatabase() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }

  Future<void> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    await db.insert('users', user);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }

  Future<void> updateUser(int id, String name) async {
    final db = await database;
    await db.update('users', {'name': name}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> initDatabase() async {
    _database = await database;
  }

  Future<List<Map<String, dynamic>>> queryUsers() async {
    final db = await database;
    return await db.query('users');
  }

  Future<void> clearUsersTable() async {
    try {
      final db = await database;
      await db.execute('DELETE FROM users'); // Menggunakan perintah SQL untuk menghapus semua data dari tabel
      print('All users deleted successfully.');
    } catch (e) {
      print('Failed to clear users table: $e');
    }
  }


}


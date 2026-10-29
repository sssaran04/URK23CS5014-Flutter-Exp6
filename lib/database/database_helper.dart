import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/student.dart';

/// Thrown when a register number is already present in the table.
class DuplicateRegNoException implements Exception {
  final String message = 'Register number already exists';

  @override
  String toString() => message;
}

/// Singleton that owns the connection to students.db.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static const String _dbName = 'students.db';
  static const String table = 'students';

  /// Overridable path, used by tests (e.g. inMemoryDatabasePath).
  String? databasePathOverride;

  Database? _database;

  Future<Database> get database async {
    return _database ??= await _openDatabase();
  }

  Future<Database> _openDatabase() async {
    final path =
        databasePathOverride ?? join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $table(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            regNo TEXT UNIQUE NOT NULL,
            name TEXT NOT NULL,
            department TEXT,
            year INTEGER,
            email TEXT,
            phone TEXT,
            cgpa REAL,
            createdAt TEXT
          )
        ''');
      },
    );
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  // CREATE: insert a new student row and return its id.
  Future<int> insertStudent(Student student) async {
    final db = await database;
    final map = student.toMap()..remove('id');
    try {
      return await db.insert(
        table,
        map,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) throw DuplicateRegNoException();
      rethrow;
    }
  }

  // READ: all students, newest first.
  Future<List<Student>> getAllStudents() async {
    final db = await database;
    final rows = await db.query(table, orderBy: 'id DESC');
    return rows.map(Student.fromMap).toList();
  }

  // READ: one student by register number.
  Future<Student?> getStudentByRegNo(String regNo) async {
    final db = await database;
    final rows = await db.query(
      table,
      where: 'regNo = ?',
      whereArgs: [regNo],
      limit: 1,
    );
    return rows.isEmpty ? null : Student.fromMap(rows.first);
  }

  // READ: students whose name, regNo or department matches the query.
  Future<List<Student>> searchStudents(String query) async {
    final db = await database;
    final pattern = '%${query.trim()}%';
    final rows = await db.query(
      table,
      where: 'name LIKE ? OR regNo LIKE ? OR department LIKE ?',
      whereArgs: [pattern, pattern, pattern],
      orderBy: 'id DESC',
    );
    return rows.map(Student.fromMap).toList();
  }

  // READ: total number of rows in the table.
  Future<int> getStudentCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) AS total FROM $table');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Inserts three sample students only when the table is empty
  /// (i.e. on the very first launch).
  Future<void> seedIfEmpty() async {
    if (await getStudentCount() > 0) return;
    final samples = [
      Student(
        regNo: 'URK23CS1001',
        name: 'Asha Kumar',
        department: 'CSE',
        year: 3,
        email: 'asha.kumar@karunya.edu.in',
        phone: '9876543210',
        cgpa: 8.7,
      ),
      Student(
        regNo: 'URK23EC1002',
        name: 'Rahul Menon',
        department: 'ECE',
        year: 2,
        email: 'rahul.menon@karunya.edu.in',
        phone: '9123456780',
        cgpa: 7.9,
      ),
      Student(
        regNo: 'URK23ME1003',
        name: 'Priya Das',
        department: 'MECH',
        year: 4,
        email: 'priya.das@karunya.edu.in',
        phone: '9988776655',
        cgpa: 9.1,
      ),
    ];
    for (final s in samples) {
      await insertStudent(s);
    }
  }
}

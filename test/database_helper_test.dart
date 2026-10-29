import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:student_records_sqlite/database/database_helper.dart';
import 'package:student_records_sqlite/models/student.dart';

Student _student(String regNo, String name, {String dept = 'CSE'}) => Student(
  regNo: regNo,
  name: name,
  department: dept,
  year: 2,
  email: '${name.split(' ').first.toLowerCase()}@test.com',
  phone: '9876543210',
  cgpa: 8.25,
);

void main() {
  final db = DatabaseHelper.instance;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    db.databasePathOverride = inMemoryDatabasePath;
  });

  setUp(() async => db.close()); // fresh in-memory database for each test

  tearDownAll(() async => db.close());

  test('insert then read back by regNo', () async {
    final id = await db.insertStudent(_student('URK23CS0001', 'Asha Kumar'));
    expect(id, greaterThan(0));

    final s = await db.getStudentByRegNo('URK23CS0001');
    expect(s, isNotNull);
    expect(s!.name, 'Asha Kumar');
    expect(s.cgpa, 8.25);
    expect(s.year, 2);

    final all = await db.getAllStudents();
    expect(all.length, 1);
  });

  test('getStudentCount returns number of rows', () async {
    expect(await db.getStudentCount(), 0);
    await db.insertStudent(_student('R1', 'Asha Kumar'));
    await db.insertStudent(_student('R2', 'Rahul Menon'));
    expect(await db.getStudentCount(), 2);
  });

  test('searchStudents matches name, regNo and department', () async {
    await db.insertStudent(_student('URK23CS0001', 'Asha Kumar'));
    await db.insertStudent(_student('URK23EC0002', 'Rahul Menon', dept: 'ECE'));

    expect((await db.searchStudents('asha')).single.regNo, 'URK23CS0001');
    expect((await db.searchStudents('EC0002')).single.name, 'Rahul Menon');
    expect((await db.searchStudents('ECE')).length, 1);
    expect(await db.searchStudents('zzz'), isEmpty);
  });

  test('duplicate regNo is rejected', () async {
    await db.insertStudent(_student('URK23CS0001', 'Asha Kumar'));
    expect(
      () => db.insertStudent(_student('URK23CS0001', 'Other Person')),
      throwsA(isA<DuplicateRegNoException>()),
    );
    expect(await db.getStudentCount(), 1);
  });

  test('seedIfEmpty inserts 3 samples only once', () async {
    await db.seedIfEmpty();
    await db.seedIfEmpty();
    expect(await db.getStudentCount(), 3);
  });
}

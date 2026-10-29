import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/student.dart';
import '../widgets/empty_state.dart';
import '../widgets/student_card.dart';
import 'add_student_screen.dart';
import 'student_detail_screen.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final _db = DatabaseHelper.instance;
  final _searchController = TextEditingController();
  late Future<List<Student>> _studentsFuture;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _studentsFuture = _init();
  }

  // CREATE: insert 3 sample students on the very first launch only.
  Future<List<Student>> _init() async {
    await _db.seedIfEmpty();
    return _loadStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // READ: load (or search) records and the total count from SQLite.
  Future<List<Student>> _loadStudents() async {
    final query = _searchController.text.trim();
    final students = query.isEmpty
        ? await _db.getAllStudents()
        : await _db.searchStudents(query);
    final total = await _db.getStudentCount();
    if (mounted) setState(() => _total = total);
    return students;
  }

  Future<void> _refresh() async {
    final future = _loadStudents();
    setState(() => _studentsFuture = future);
    await future;
  }

  Future<void> _openAddScreen() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddStudentScreen()),
    );
    if (saved == true) await _refresh();
  }

  void _openDetail(Student s) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StudentDetailScreen(regNo: s.regNo)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Records'),
        backgroundColor: scheme.primaryContainer,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, reg no or department',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _refresh();
                        },
                      ),
              ),
              onChanged: (_) => _refresh(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Icon(Icons.storage, size: 18, color: scheme.primary),
                const SizedBox(width: 6),
                Text(
                  'Total students: $_total',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<List<Student>>(
                future: _studentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final students = snapshot.data ?? [];
                  if (students.isEmpty) {
                    return EmptyState(
                      message: _searchController.text.isEmpty
                          ? 'No student records yet'
                          : 'No students match your search',
                    );
                  }
                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: students.length,
                    itemBuilder: (_, i) => StudentCard(
                      student: students[i],
                      onTap: () => _openDetail(students[i]),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddScreen,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Student'),
      ),
    );
  }
}

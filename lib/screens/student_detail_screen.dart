import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/student.dart';

class StudentDetailScreen extends StatelessWidget {
  final String regNo;

  const StudentDetailScreen({super.key, required this.regNo});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Details'),
        backgroundColor: scheme.primaryContainer,
      ),
      // READ: fetch a single record by its register number.
      body: FutureBuilder<Student?>(
        future: DatabaseHelper.instance.getStudentByRegNo(regNo),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final s = snapshot.data;
          if (s == null) {
            return const Center(child: Text('Student not found'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: scheme.primaryContainer,
                  child: Text(
                    s.initials,
                    style: TextStyle(
                      fontSize: 28,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                s.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    _row(Icons.tag, 'Record ID', '${s.id}'),
                    _row(Icons.badge, 'Register No', s.regNo),
                    _row(Icons.apartment, 'Department', s.department),
                    _row(Icons.calendar_today, 'Year', 'Year ${s.year}'),
                    _row(Icons.email, 'Email', s.email),
                    _row(Icons.phone, 'Phone', s.phone),
                    _row(Icons.grade, 'CGPA', s.cgpa.toStringAsFixed(2)),
                    _row(
                      Icons.access_time,
                      'Created',
                      DateFormat('dd-MM-yyyy hh:mm a').format(s.createdAt),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return ListTile(
      dense: true,
      leading: Icon(icon),
      title: Text(label, style: const TextStyle(fontSize: 12)),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
    );
  }
}

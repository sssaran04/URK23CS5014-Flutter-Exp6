import 'package:flutter/material.dart';

/// Shown when the students table has no matching records.
class EmptyState extends StatelessWidget {
  final String message;

  const EmptyState({super.key, this.message = 'No student records yet'});

  @override
  Widget build(BuildContext context) {
    return ListView(
      // ListView keeps pull-to-refresh working on an empty screen.
      children: [
        const SizedBox(height: 120),
        Icon(Icons.school_outlined, size: 72, color: Colors.grey.shade400),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        const Text(
          'Tap "Add Student" to create one.',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

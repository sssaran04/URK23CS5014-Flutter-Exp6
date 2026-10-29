import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/student.dart';
import '../widgets/student_form_field.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  static const departments = [
    'CSE',
    'ECE',
    'EEE',
    'MECH',
    'CIVIL',
    'IT',
    'AIDS',
  ];

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _regNo = TextEditingController();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _cgpa = TextEditingController();
  String? _department;
  int? _year;
  bool _saving = false;
  bool _submitted = false;
  String? _regNoError;

  @override
  void dispose() {
    for (final c in [_regNo, _name, _email, _phone, _cgpa]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _required(String? v, String field) =>
      (v == null || v.trim().isEmpty) ? '$field is required' : null;

  String? _validateRegNo(String? v) {
    if (_regNoError != null) return _regNoError;
    return _required(v, 'Register number');
  }

  String? _validateName(String? v) {
    final err = _required(v, 'Name');
    if (err != null) return err;
    if (!RegExp(r'^[A-Za-z ]+$').hasMatch(v!.trim())) {
      return 'Name can contain only letters and spaces';
    }
    return null;
  }

  String? _validateEmail(String? v) {
    final err = _required(v, 'Email');
    if (err != null) return err;
    if (!RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$').hasMatch(v!.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePhone(String? v) {
    final err = _required(v, 'Phone');
    if (err != null) return err;
    if (!RegExp(r'^\d{10}$').hasMatch(v!.trim())) {
      return 'Phone must be exactly 10 digits';
    }
    return null;
  }

  String? _validateCgpa(String? v) {
    final err = _required(v, 'CGPA');
    if (err != null) return err;
    final value = double.tryParse(v!.trim());
    if (value == null || value < 0 || value > 10) {
      return 'CGPA must be between 0.0 and 10.0';
    }
    return null;
  }

  // CREATE: validate the form and insert the record into SQLite.
  Future<void> _save() async {
    setState(() {
      _regNoError = null;
      _submitted = true; // re-validate as the user corrects fields
    });
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final student = Student(
      regNo: _regNo.text.trim().toUpperCase(),
      name: _name.text.trim(),
      department: _department!,
      year: _year!,
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      cgpa: double.parse(_cgpa.text.trim()),
    );

    try {
      await DatabaseHelper.instance.insertStudent(student);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${student.name} saved successfully')),
      );
      Navigator.pop(context, true);
    } on DuplicateRegNoException catch (e) {
      setState(() {
        _saving = false;
        _regNoError = e.message;
      });
      _formKey.currentState!.validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Student'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: _submitted
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            StudentFormField(
              controller: _regNo,
              label: 'Register Number',
              icon: Icons.badge,
              hint: 'e.g. URK23CS5014',
              validator: _validateRegNo,
            ),
            StudentFormField(
              controller: _name,
              label: 'Full Name',
              icon: Icons.person,
              validator: _validateName,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DropdownButtonFormField<String>(
                initialValue: _department,
                decoration: const InputDecoration(
                  labelText: 'Department',
                  prefixIcon: Icon(Icons.apartment),
                ),
                items: AddStudentScreen.departments
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => _department = v),
                validator: (v) => v == null ? 'Select a department' : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DropdownButtonFormField<int>(
                initialValue: _year,
                decoration: const InputDecoration(
                  labelText: 'Year',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                items: [1, 2, 3, 4]
                    .map(
                      (y) => DropdownMenuItem(value: y, child: Text('Year $y')),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _year = v),
                validator: (v) => (v == null || v < 1 || v > 4)
                    ? 'Select a year (1-4)'
                    : null,
              ),
            ),
            StudentFormField(
              controller: _email,
              label: 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            StudentFormField(
              controller: _phone,
              label: 'Phone',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: _validatePhone,
            ),
            StudentFormField(
              controller: _cgpa,
              label: 'CGPA',
              icon: Icons.grade,
              hint: '0.0 - 10.0',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: _validateCgpa,
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('Save Student'),
            ),
          ],
        ),
      ),
    );
  }
}

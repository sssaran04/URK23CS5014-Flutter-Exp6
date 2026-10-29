/// A single student record stored in the `students` table.
class Student {
  final int? id;
  final String regNo;
  final String name;
  final String department;
  final int year;
  final String email;
  final String phone;
  final double cgpa;
  final DateTime createdAt;

  Student({
    this.id,
    required this.regNo,
    required this.name,
    required this.department,
    required this.year,
    required this.email,
    required this.phone,
    required this.cgpa,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Initials used in the list avatar, e.g. "Asha Kumar" -> "AK".
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  /// Converts the object into a map for sqflite's insert().
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'regNo': regNo,
      'name': name,
      'department': department,
      'year': year,
      'email': email,
      'phone': phone,
      'cgpa': cgpa,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Builds a Student from a row returned by query().
  factory Student.fromMap(Map<String, Object?> map) {
    return Student(
      id: map['id'] as int?,
      regNo: map['regNo'] as String,
      name: map['name'] as String,
      department: map['department'] as String? ?? '',
      year: map['year'] as int? ?? 1,
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      cgpa: (map['cgpa'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? ''),
    );
  }
}

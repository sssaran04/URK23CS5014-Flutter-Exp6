import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_records_sqlite/screens/add_student_screen.dart';

void main() {
  Future<void> pumpForm(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: AddStudentScreen()));
  }

  testWidgets('empty form shows required errors', (tester) async {
    await pumpForm(tester);
    await tester.tap(find.text('Save Student'));
    await tester.pump();

    expect(find.text('Register number is required'), findsOneWidget);
    expect(find.text('Name is required'), findsOneWidget);
    expect(find.text('Select a department'), findsOneWidget);
    expect(find.text('Select a year (1-4)'), findsOneWidget);
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Phone is required'), findsOneWidget);
    expect(find.text('CGPA is required'), findsOneWidget);
  });

  testWidgets('invalid values show format errors', (tester) async {
    await pumpForm(tester);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'URK23CS9999');
    await tester.enterText(fields.at(1), 'Asha123');
    await tester.enterText(fields.at(2), 'not-an-email');
    await tester.enterText(fields.at(3), '12345');
    await tester.enterText(fields.at(4), '11.5');
    await tester.tap(find.text('Save Student'));
    await tester.pump();

    expect(find.text('Register number is required'), findsNothing);
    expect(
      find.text('Name can contain only letters and spaces'),
      findsOneWidget,
    );
    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(find.text('Phone must be exactly 10 digits'), findsOneWidget);
    expect(find.text('CGPA must be between 0.0 and 10.0'), findsOneWidget);
  });
}

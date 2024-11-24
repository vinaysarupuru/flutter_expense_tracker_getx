import 'package:flutter_expense_tracker_getx/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:get/get.dart';

void main() {
  testWidgets('Initial app test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ExpenseTrackerApp());

    // Verify that the app builds without crashing
    expect(find.byType(GetMaterialApp), findsOneWidget);
  });
}

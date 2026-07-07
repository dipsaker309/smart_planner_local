import 'package:flutter_test/flutter_test.dart';
import 'package:smart_planner_local/app.dart';

void main() {
  testWidgets('shows the offline app shell', (tester) async {
    await tester.pumpWidget(const SmartPlannerApp());

    expect(find.text('Planner'), findsWidgets);
    expect(find.text('Calories'), findsWidgets);
  });
}

import 'package:flutter_adaptive_scaffold_example/adaptive_scaffold_demo.dart'
    as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Test if animation ends at declared duration.',
      (WidgetTester tester) async {
    app.main();
    await tester.pumpWidget(
        const app.MyApp(), const Duration(milliseconds: 500));
  });
}

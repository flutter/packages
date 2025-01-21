import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:video_player_example/main.dart' as app;

@pragma('vm:entry-point')
void integrationTestMain() {
  enableFlutterDriverExtension();

  app.main();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Since this test is lacking integration tests, this test ensures the example
  // app can be launched on an emulator/device.
  testWidgets('Launch Test', (WidgetTester tester) async {});
}

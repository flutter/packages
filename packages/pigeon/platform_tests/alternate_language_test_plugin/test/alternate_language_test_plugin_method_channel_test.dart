import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alternate_language_test_plugin/alternate_language_test_plugin_method_channel.dart';

void main() {
  MethodChannelAlternateLanguageTestPlugin platform = MethodChannelAlternateLanguageTestPlugin();
  const MethodChannel channel = MethodChannel('alternate_language_test_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cross_file_web/cross_file_web_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelCrossFileWeb platform = MethodChannelCrossFileWeb();
  const MethodChannel channel = MethodChannel('cross_file_web');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return '42';
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}

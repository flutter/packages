import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer_interceptor_platform_interface/pointer_interceptor_platform_interface_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelPointerInterceptorPlatformInterface platform = MethodChannelPointerInterceptorPlatformInterface();
  const MethodChannel channel = MethodChannel('pointer_interceptor_platform_interface');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}

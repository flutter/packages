import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer_interceptor_ios/pointer_interceptor_ios_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelPointerInterceptorIos platform = MethodChannelPointerInterceptorIos();
  const MethodChannel channel = MethodChannel('pointer_interceptor_ios');

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

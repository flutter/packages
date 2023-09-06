import 'package:flutter_test/flutter_test.dart';
import 'package:pointer_interceptor_ios/pointer_interceptor_ios.dart';
import 'package:pointer_interceptor_ios/pointer_interceptor_ios_platform_interface.dart';
import 'package:pointer_interceptor_ios/pointer_interceptor_ios_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPointerInterceptorIosPlatform
    with MockPlatformInterfaceMixin
    implements PointerInterceptorIosPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PointerInterceptorIosPlatform initialPlatform = PointerInterceptorIosPlatform.instance;

  test('$MethodChannelPointerInterceptorIos is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPointerInterceptorIos>());
  });

  test('getPlatformVersion', () async {
    PointerInterceptorIos pointerInterceptorIosPlugin = PointerInterceptorIos();
    MockPointerInterceptorIosPlatform fakePlatform = MockPointerInterceptorIosPlatform();
    PointerInterceptorIosPlatform.instance = fakePlatform;

    expect(await pointerInterceptorIosPlugin.getPlatformVersion(), '42');
  });
}

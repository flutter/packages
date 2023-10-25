import 'package:flutter_test/flutter_test.dart';
import 'package:pointer_interceptor_platform_interface/pointer_interceptor_platform_interface.dart';
import 'package:pointer_interceptor_platform_interface/pointer_interceptor_platform_interface_platform_interface.dart';
import 'package:pointer_interceptor_platform_interface/pointer_interceptor_platform_interface_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPointerInterceptorPlatformInterfacePlatform
    with MockPlatformInterfaceMixin
    implements PointerInterceptorPlatformInterfacePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PointerInterceptorPlatformInterfacePlatform initialPlatform = PointerInterceptorPlatformInterfacePlatform.instance;

  test('$MethodChannelPointerInterceptorPlatformInterface is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPointerInterceptorPlatformInterface>());
  });

  test('getPlatformVersion', () async {
    PointerInterceptorPlatformInterface pointerInterceptorPlatformInterfacePlugin = PointerInterceptorPlatformInterface();
    MockPointerInterceptorPlatformInterfacePlatform fakePlatform = MockPointerInterceptorPlatformInterfacePlatform();
    PointerInterceptorPlatformInterfacePlatform.instance = fakePlatform;

    expect(await pointerInterceptorPlatformInterfacePlugin.getPlatformVersion(), '42');
  });
}

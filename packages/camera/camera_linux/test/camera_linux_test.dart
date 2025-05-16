import 'package:flutter_test/flutter_test.dart';
import 'package:camera_linux/camera_linux.dart';
import 'package:camera_linux/camera_linux_platform_interface.dart';
import 'package:camera_linux/camera_linux_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCameraLinuxPlatform
    with MockPlatformInterfaceMixin
    implements CameraLinuxPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final CameraLinuxPlatform initialPlatform = CameraLinuxPlatform.instance;

  test('$MethodChannelCameraLinux is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelCameraLinux>());
  });

  test('getPlatformVersion', () async {
    CameraLinux cameraLinuxPlugin = CameraLinux();
    MockCameraLinuxPlatform fakePlatform = MockCameraLinuxPlatform();
    CameraLinuxPlatform.instance = fakePlatform;

    expect(await cameraLinuxPlugin.getPlatformVersion(), '42');
  });
}

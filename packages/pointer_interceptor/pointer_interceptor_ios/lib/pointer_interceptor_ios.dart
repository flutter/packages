
import 'pointer_interceptor_ios_platform_interface.dart';

class PointerInterceptorIos {
  Future<String?> getPlatformVersion() {
    return PointerInterceptorIosPlatform.instance.getPlatformVersion();
  }
}

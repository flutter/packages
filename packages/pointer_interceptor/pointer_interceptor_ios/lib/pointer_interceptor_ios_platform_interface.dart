import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'pointer_interceptor_ios_method_channel.dart';

abstract class PointerInterceptorIosPlatform extends PlatformInterface {
  /// Constructs a PointerInterceptorIosPlatform.
  PointerInterceptorIosPlatform() : super(token: _token);

  static final Object _token = Object();

  static PointerInterceptorIosPlatform _instance = MethodChannelPointerInterceptorIos();

  /// The default instance of [PointerInterceptorIosPlatform] to use.
  ///
  /// Defaults to [MethodChannelPointerInterceptorIos].
  static PointerInterceptorIosPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PointerInterceptorIosPlatform] when
  /// they register themselves.
  static set instance(PointerInterceptorIosPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}

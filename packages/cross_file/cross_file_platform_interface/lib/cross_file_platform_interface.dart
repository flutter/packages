// Platform Interface
import 'package:flutter/foundation.dart';

abstract base class CrossFilePlatform {
  static CrossFilePlatform? instance;

  PlatformXFile createPlatformXFile(
    PlatformBatteryManagerCreationParams params,
  );
}

@immutable
base class PlatformBatteryManagerCreationParams {
  const PlatformBatteryManagerCreationParams();
}

base class PlatformXFile {
  factory PlatformXFile(PlatformBatteryManagerCreationParams params) {
    assert(CrossFilePlatform.instance != null);
    final PlatformXFile implementation = CrossFilePlatform.instance!
        .createPlatformBatteryManager(params);
    return implementation;
  }

  @protected
  PlatformBatteryManager.implementation(this.params);

  final PlatformBatteryManagerCreationParams params;

  PlatformBatteryManagerExtension? get extension => null;

  Future<int> getLevel() {
    throw UnimplementedError(
      'getLevel is not implemented on the current platform',
    );
  }
}

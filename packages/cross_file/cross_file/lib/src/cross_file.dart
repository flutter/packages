import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';

@immutable
class XFile {
  XFile(String path) : this.fromPlatformCreationParams(Pl);

  XFile.fromPlatformCreationParams(PlatformXFileCreationParams params)
    : this.fromPlatform(PlatformXFile(params));

  XFile.fromPlatform(this.platform);

  final PlatformXFile platform;
}

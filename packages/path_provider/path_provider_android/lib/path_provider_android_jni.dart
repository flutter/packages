import 'package:jni/jni.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'src/third_party/path_provider.g.dart';

class PathProviderAndroidJni extends PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async {
    final Context context = Context.fromReference(
      Jni.getCachedApplicationContext(),
    );
    final JObject? object = context.getCacheDir();
    return object?.toString();
  }
}

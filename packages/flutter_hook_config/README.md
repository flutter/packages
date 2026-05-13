# flutter_hook_config

A [`package:hooks`](https://pub.dev/packages/hooks) protocol extension that lets
the Flutter SDK pass Flutter-specific configuration to build and link hooks in a
typed way.

Today it exposes the absolute paths of the engine host tools a hook might need:

* `impellerc`, the offline shader compiler (used, for example, by
  `flutter_gpu_shaders` to compile `.shaderbundle.json` files).
* `libtessellator`, the tessellation library.

The Flutter SDK (`flutter_tools`) resolves these through the same artifact
lookup it uses for its own build steps, so under `--local-engine` a hook gets
the locally built tools, matching the engine the app is being built against,
instead of the ones in the SDK cache.

## For hook authors

Add `flutter_hook_config` to your hook's dependencies and read the config from
the `BuildInput` / `LinkInput` via `input.config.flutter`. Always check
`input.config.buildForFlutter` first: a hook may also be invoked by a plain
`dart` build, or by a Flutter SDK that predates this extension, in which case no
Flutter-specific config is available and you should fall back to your own tool
discovery.

See the [library documentation](https://pub.dev/documentation/flutter_hook_config/latest/)
for a usage example.

## For the Flutter SDK

`flutter_tools` constructs a `FlutterExtension` (populated from
`Artifacts.getHostArtifact(...)`) and passes it to the hook runner alongside the
other protocol extensions (`CodeAssetExtension`, `DataAssetsExtension`), so the
configuration above becomes available to every build and link hook.

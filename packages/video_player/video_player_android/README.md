# video\_player\_android

The Android implementation of [`video_player`][1].

## Usage

This package is [endorsed][2], which means you can simply use `video_player`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

## External Native API

The plugin also provides a native API accessible by the native code of Android applications or
packages. This API follows the convention of breaking changes of the Dart API, which means that any
changes to the class that are not backwards compatible will only be made with a major version change
of the plugin. Native code other than this external API does not follow breaking change conventions,
so app or plugin clients should not use any other native APIs.

The API can be accessed by importing the native class `VideoPlayerAndroidExternalApi`. A package
that uses it must list `video_player_android` as a dependency in its own `pubspec.yaml`, since
depending on `video_player` alone does not make this plugin's native classes available to the
package's Android code.

Kotlin:

```kotlin
import io.flutter.plugins.videoplayer.VideoPlayerAndroidExternalApi
```

### Supplying the media configuration

A `MediaConfigProvider` can supply the Media3 `MediaItem` and `MediaSource.Factory` used for a
player, for example to play a download from a Media3 cache. It is consulted whenever a player is
created in the engine it was registered for, and returning `null` lets the plugin handle the player
as usual. Only one provider is supported per engine.

A returned configuration replaces all of the plugin's own loading setup, so a provider should:

* Apply the request's `httpHeaders` and `userAgent`, and allow cross-protocol redirects, in any data
  source that can reach the network.
* Set the request's `mimeType`, which comes from the app's format hint, on the `MediaItem` if the
  item does not already have one.
* Return a new `MediaSource.Factory` for each request. Factories hold per-player state, and sharing
  one breaks DRM playback in every player after the first. Data source factories and caches can be
  shared.
* Keep anything the factory reads, such as a cache, usable until the players created from it are
  disposed. Removing the provider only affects players created afterwards.

Media3's download and cache APIs are marked `@UnstableApi`, so code using them needs
`@OptIn(UnstableApi::class)`:

```kotlin
@OptIn(UnstableApi::class)
override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
  VideoPlayerAndroidExternalApi.setMediaConfigProvider(binding) { request ->
    val downloadRequest =
        downloadTracker.getDownloadRequest(Uri.parse(request.uri))
            ?: return@setMediaConfigProvider null
    val upstreamFactory =
        DefaultHttpDataSource.Factory()
            .setUserAgent(request.userAgent)
            .setAllowCrossProtocolRedirects(true)
            .setDefaultRequestProperties(request.httpHeaders)
    VideoPlayerAndroidExternalApi.MediaConfig(
        mediaItem = downloadRequest.toMediaItem(),
        mediaSourceFactory =
            DefaultMediaSourceFactory(request.context)
                .setDataSourceFactory(
                    CacheDataSource.Factory()
                        .setCache(downloadCache)
                        .setUpstreamDataSourceFactory(upstreamFactory)
                        .setCacheWriteDataSinkFactory(null)),
    )
  }
}

override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
  VideoPlayerAndroidExternalApi.setMediaConfigProvider(binding, null)
}
```

Here `downloadTracker` and `downloadCache` stand for the package's own download index and the
Media3 cache it downloads into.

The provider can be set before or after `video_player_android` is attached to the engine. It stays
registered until it is removed, so remove it when the package detaches from the engine.

## Known issues

Using `VideoViewType.platformView` is not currently recommended on Android due to a known [issue][3] affecting platform views on Android.

[1]: https://pub.dev/packages/video_player
[2]: https://flutter.dev/to/endorsed-federated-plugin
[3]: https://github.com/flutter/flutter/issues/164899

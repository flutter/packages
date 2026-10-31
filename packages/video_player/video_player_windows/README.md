# video_player_windows

Windows implementation of `video_player` using the Media Foundation components
and codecs installed with Windows. No third-party playback engine or codec bundle
is included. Windows 10 or later is required. Windows N editions need the Media
Feature Pack installed.

This package is part of the `mbfakourii/packages` fork. The fork's `video_player`
selects it automatically; applications keep using `VideoPlayerController` and
`VideoPlayer` without manual registration.

## Use the local fork

```yaml
dependencies:
  video_player:
    path: ../packages/packages/video_player/video_player
```

The relative dependency on `video_player_windows` is intentional for this
unpublished fork. Both packages use `publish_to: none` for local/Git consumption.
Publishing these packages to pub.dev would require publishing
the Windows implementation first and replacing the path dependency with its
published version. This change does not publish either package.

## Behavior and limitations

- Supports bundled assets, package assets, local files (including Unicode paths),
  and HTTP/HTTPS URLs supported by Media Foundation.
- Supports play/pause, seeking, looping, volume, positive playback rates,
  initialization/error/completion events, buffering ranges, and preventing display
  sleep while playing. Accepted playback rates depend on the media and decoder.
- Uses hardware decoding when available, with a software D3D device fallback.
  Frames are copied through immutable RGBA pixel buffers into Flutter textures.
  This is not a zero-copy renderer; high-resolution/high-frame-rate workloads
  need performance testing on the target hardware.
- `platformView` requests use a Flutter texture, matching `video_player`'s fallback
  contract for unsupported view types.
- Formats and codecs depend on Windows installations. An MP4 extension does not
  guarantee support for the codecs inside it. DRM playback is not supported.
  HLS/DASH use Windows `AdaptiveMediaSource`; supported manifest features and
  codecs depend on Windows.
- Custom HTTP headers are supported for progressive and adaptive HTTP/HTTPS media through a
  streaming loopback relay using Dart's `HttpClient`. Every decoder range request
  carries the supplied headers. Media is not downloaded in full or stored on disk.
  The relay binds only to `127.0.0.1`, uses a random per-player path, and closes
  active connections on disposal, reset or source failure. Invalid header syntax
  and transport-controlled headers (`Host`, `Content-Length`, hop-by-hop headers)
  are rejected. Decoder `Range`/`If-Range` values override caller values when seeking.
  Same-origin redirects retain headers; crossing an origin drops all caller headers
  for the remainder of that redirect chain. HTTPS downgrades are rejected and
  redirects are limited to five. Idle upstream connections time out after 30 seconds.
  Adaptive manifests, child playlists, initialization/media segments and HLS keys
  use the same relay, including requests made while opening the manifest. Resources
  on another origin do not receive caller headers. Redirected playlists resolve
  relative resource URLs against their final upstream URL.
  Android content URIs remain unsupported.
- Windows audio uses the shared system mixer. `mixWithOthers` does not request
  exclusive audio focus. `VideoPlayerController` manages background pausing via
  the Flutter app lifecycle; Windows does not need a separate background audio mode.
- Audio/video track capability queries return `true`. The track APIs enumerate
  Media Foundation's in-band streams and select one stream of the requested type
  while preserving the other type. IDs are source-local stream indices; invalid
  IDs or IDs of the wrong type fail without changing selection. Optional metadata
  is absent when Windows does not provide it. Video dimensions account for pixel
  aspect ratio; controller dimensions refresh after selection.
  For progressive media, `selectVideoTrack(null)` restores the original video stream.
  For HLS/DASH, video tracks represent the bitrates exposed by Windows, with
  source-local bitrate IDs and kbps labels. Selecting one constrains future downloads
  to that bitrate; already buffered media can continue until it is consumed.
  `selectVideoTrack(null)` restores automatic bitrate adaptation. `isSelected`
  identifies an explicit bitrate choice; all adaptive tracks are unselected in
  automatic mode. Resolution metadata is omitted when Windows does not expose it.
  Subtitle-track APIs remain unsupported.
- Assets use the standard Windows runner's `data/flutter_assets` directory next
  to the executable. Custom embedders with a different asset layout must adapt
  asset resolution.

## Development and verification

From this directory:

```powershell
flutter pub get
dart run pigeon --input pigeons/messages.dart
dart format lib/src/messages.g.dart
clang-format -i windows/messages.g.h windows/messages.g.cpp
flutter analyze
flutter test
```

The `example` application includes a Windows runner and tests using the public
controller API:

```powershell
cd example
flutter pub get
flutter build windows --debug
flutter test integration_test/video_player_test.dart -d windows
```

The example enables native tests and exposes the repository's `unit_tests` target.
From the repository root, run the same commands used by CI:

```powershell
dart run script/tool/bin/flutter_plugin_tools.dart build-examples --windows --packages=video_player_windows --exact-match-only
dart run script/tool/bin/flutter_plugin_tools.dart native-test --windows --no-integration --packages=video_player_windows --exact-match-only
dart run script/tool/bin/flutter_plugin_tools.dart drive-examples --windows --packages=video_player_windows --exact-match-only
```

GoogleTest is downloaded only when the example's native tests are enabled.
Applications using the plugin link only Flutter and Windows SDK libraries.
The native plugin uses C++20 and the Windows SDK's C++/WinRT headers.

Native tests cover pending-event ordering, immutable frame ownership and time/path
conversion. Windows
integration tests exercise real rendering, playback controls, source errors,
disposal during initialization, Unicode files, a local HTTP server, looping and
independent simultaneous players. They do
not establish codec support or performance on other machines.

The additional Windows suite exercises authenticated HTTP, same-origin redirects,
range requests, seeking, 401 errors, stalled-source disposal, audio selection and
visible video changes between two differently shaped tracks. `assets/windows_tracks.mp4`
in the example is an original synthetic six-second fixture: red 160x120
H.264 with 2:1 sample aspect ratio, blue 320x180 H.264 with square pixels, and
440/880 Hz AAC audio streams tagged `eng`/`fas`. It contains no third-party content.
It was generated with an existing FFmpeg executable for testing; FFmpeg is not a
plugin or test-runtime dependency. Regenerate from the example directory with:

```powershell
ffmpeg -f lavfi -i "color=c=red:s=160x120:r=10:d=6" -f lavfi -i "color=c=blue:s=320x180:r=10:d=6" -f lavfi -i "sine=frequency=440:sample_rate=44100:duration=6" -f lavfi -i "sine=frequency=880:sample_rate=44100:duration=6" -map 0:v -map 1:v -map 2:a -map 3:a -filter:v:0 "setsar=2/1" -c:v libx264 -pix_fmt yuv420p -g 10 -c:a aac -b:a 32k -metadata:s:a:0 language=eng -metadata:s:a:1 language=fas -disposition:v:0 default -disposition:v:1 0 -disposition:a:0 default -disposition:a:1 0 -movflags +faststart assets/windows_tracks.mp4
```

The adaptive suite serves synthetic red/blue H.264 qualities and AAC audio from
an authenticated local server. It checks rendered quality changes, automatic mode,
redirected/nested playlists, AES-128 HLS keys, DASH template/init segments,
initial seeks, authentication errors and cancellation. Its compressed fixture
contains no third-party media. Regenerate it from the package directory with an
existing FFmpeg executable (not a runtime dependency):

```powershell
dart run tool/generate_adaptive_fixture.dart path/to/ffmpeg.exe
```

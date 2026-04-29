# android_local_network

A Flutter package to handle the Android 17 Local Area Permission (`ACCESS_LOCAL_NETWORK`) for Dart sockets.

## Usage

Instead of using `Socket.connect` directly on Android 17+, use `AndroidLocalAreaSocket.connect`:

```dart
import 'package:android_local_network/android_local_network.dart';

final socket = await AndroidLocalAreaSocket.connect('192.168.1.1', 8080);
```

Or check and request the permission manually:

```dart
import 'package:android_local_network/android_local_network.dart';

if (await AndroidLocalNetwork.requestPermission()) {
  // Permission granted
}
```

## Implementation Details

This package uses `jnigen` to interact with Android's permission system via FFI. This avoids the need for MethodChannels in the framework and provides a more direct way to handle permissions from Dart.

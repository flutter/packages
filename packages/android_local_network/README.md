# android_local_network

A Flutter package to handle the Android 15 Local Area Permission (`ACCESS_LOCAL_NETWORK`) for Dart sockets.

## Usage

### Automatic Permission Handling (Recommended)

To automatically handle the permission whenever a socket is used, call `AndroidLocalNetwork.initialize()` early in your application's lifecycle (e.g., in `main()`):

```dart
import 'package:android_local_network/android_local_network.dart';

void main() {
  AndroidLocalNetwork.initialize();
  runApp(const MyApp());
}
```

Once initialized, any use of `Socket.connect`, `ServerSocket.bind`, `RawSocket.connect`, `RawServerSocket.bind`, or `RawDatagramSocket.bind` will automatically check for and request the `ACCESS_LOCAL_NETWORK` permission on Android if it hasn't been granted.

### Manual Permission Handling

Instead of using `Socket.connect` directly, you can use `AndroidLocalAreaSocket.connect`:

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


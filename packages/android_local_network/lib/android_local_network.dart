// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'src/android_local_network.g.dart';

/// Provides access to Android Local Area Network permission.
class AndroidLocalNetwork {
  static Future<bool>? _pendingRequest;
  static bool _hasRequestedOnce = false;

  /// Checks if the local area permission is granted.
  /// Returns true on non-Android platforms.
  static Future<bool> checkPermission() async {
    if (!Platform.isAndroid) {
      return true;
    }
    final AndroidLocalNetworkPlugin? plugin =
        AndroidLocalNetworkPlugin.instance;
    if (plugin == null) {
      return false;
    }
    final bool result = plugin.checkPermission();
    plugin.release();
    return result;
  }

  /// Requests the local area permission.
  /// Returns true if granted, false otherwise.
  /// Returns true on non-Android platforms.
  ///
  /// Multiple concurrent calls will wait for the same request to complete.
  static Future<bool> requestPermission() async {
    if (!Platform.isAndroid) {
      return true;
    }

    if (_pendingRequest != null) {
      return _pendingRequest!;
    }

    // Check if already granted.
    if (await checkPermission()) {
      return true;
    }

    // Re-check pending request after async checkPermission.
    if (_pendingRequest != null) {
      return _pendingRequest!;
    }

    final completer = Completer<bool>();
    _pendingRequest = completer.future;
    _hasRequestedOnce = true;

    try {
      final AndroidLocalNetworkPlugin? plugin =
          AndroidLocalNetworkPlugin.instance;
      if (plugin == null) {
        completer.complete(false);
        return false;
      }

      final callback = AndroidLocalNetworkPlugin$PermissionCallback.implement(
        $AndroidLocalNetworkPlugin$PermissionCallback(
          onResult: (bool granted) {
            if (!completer.isCompleted) {
              completer.complete(granted);
            }
          },
        ),
      );

      plugin.requestPermission(callback);
      final bool result = await completer.future;

      callback.release();
      plugin.release();
      return result;
    } catch (e) {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
      return false;
    } finally {
      _pendingRequest = null;
    }
  }

  /// Internal method to check and potentially request permission automatically.
  static Future<bool> _checkAndRequestPermission() async {
    // If a request is already in progress, wait for it.
    if (_pendingRequest != null) {
      return _pendingRequest!;
    }

    // Check if we already have the permission.
    if (await checkPermission()) {
      return true;
    }

    // After the async checkPermission, a request might have started from another call.
    if (_pendingRequest != null) {
      return _pendingRequest!;
    }

    // If we haven't requested yet, start a new request.
    if (!_hasRequestedOnce) {
      return requestPermission();
    }

    return false;
  }
}

/// A wrapper around [Socket] that ensures the local area permission is granted on Android.
class AndroidLocalAreaSocket {
  /// Connects to a socket, requesting permission first on Android if necessary.
  ///
  /// On Android, it will automatically request the ACCESS_LOCAL_NETWORK
  /// permission on the first call to [connect] if it hasn't been granted.
  /// Subsequent calls will only check if the permission is currently granted.
  static Future<Socket> connect(
    Object host,
    int port, {
    Object? sourceAddress,
    int sourcePort = 0,
    Duration? timeout,
  }) async {
    if (Platform.isAndroid) {
      final bool granted =
          await AndroidLocalNetwork._checkAndRequestPermission();
      if (!granted) {
        throw const SocketException('ACCESS_LOCAL_NETWORK permission denied');
      }
    }
    return Socket.connect(
      host,
      port,
      sourceAddress: sourceAddress,
      sourcePort: sourcePort,
      timeout: timeout,
    );
  }
}

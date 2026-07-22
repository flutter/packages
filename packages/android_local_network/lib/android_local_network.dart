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
  static bool _isLocalAddress(InternetAddress address) {
    if (address.type == InternetAddressType.IPv4) {
      final List<int> bytes = address.rawAddress;
      // 10.0.0.0/8
      if (bytes[0] == 10) {
        return true;
      }
      // 172.16.0.0/12
      if (bytes[0] == 172 && (bytes[1] >= 16 && bytes[1] <= 31)) {
        return true;
      }
      // 192.168.0.0/16
      if (bytes[0] == 192 && bytes[1] == 168) {
        return true;
      }
      // 169.254.0.0/16 (Link Local)
      if (bytes[0] == 169 && bytes[1] == 254) {
        return true;
      }
    } else if (address.type == InternetAddressType.IPv6) {
      if (address.isLinkLocal || address.isMulticast) {
        return true;
      }
      // Unique Local Addresses (ULA): fc00::/7
      final List<int> bytes = address.rawAddress;
      if (bytes[0] >= 0xfc && bytes[0] <= 0xfd) {
        return true;
      }
    }
    return false;
  }

  static Future<bool> _isLocalNetworkHost(Object host) async {
    if (host is InternetAddress) {
      return _isLocalAddress(host);
    } else if (host is String) {
      if (host.endsWith('.local')) {
        return true;
      }
      final InternetAddress? parsed = InternetAddress.tryParse(host);
      if (parsed != null) {
        return _isLocalAddress(parsed);
      }
      try {
        final List<InternetAddress> addresses = await InternetAddress.lookup(
          host,
        );
        return addresses.any(_isLocalAddress);
      } catch (_) {
        // DNS lookup failed, let Socket.connect handle the error.
        return false;
      }
    }
    return false;
  }

  /// Connects to a socket, requesting permission first on Android if necessary.
  ///
  /// On Android, it will automatically request the ACCESS_LOCAL_NETWORK
  /// permission on the first call to [connect] if it hasn't been granted
  /// AND the target host is a local area network address.
  /// Subsequent calls will only check if the permission is currently granted.
  static Future<Socket> connect(
    Object host,
    int port, {
    Object? sourceAddress,
    int sourcePort = 0,
    Duration? timeout,
  }) async {
    if (Platform.isAndroid && await _isLocalNetworkHost(host)) {
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

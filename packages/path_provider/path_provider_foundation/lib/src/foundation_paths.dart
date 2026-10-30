// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';

import 'ffi_bindings.g.dart';

/// Reads a user's folder paths and the main bundle's identifier from Foundation.
///
/// Exists so that answering a path never loads `package:objective_c`. That
/// package opens its native library the first time any of its types is used,
/// which blocks the calling isolate for several milliseconds. Plain FFI calls
/// into Foundation and CoreFoundation avoid that: an `NSArray` is also a
/// `CFArray` and an `NSString` a `CFString` (they are toll-free bridged), so
/// the CoreFoundation functions in this file can read what Foundation returns.
///
/// Used for the folder lookups of `PathProviderFoundation`, which takes one as
/// an argument so tests can replace it. Code that needs other Objective-C
/// objects should use `package:objective_c` instead.
///
/// Works on any isolate, not only the root one: it uses no platform channel and
/// holds no state. Every call is synchronous.
class FoundationPaths {
  /// Creates a reader; this opens nothing, because the frameworks open on the first method call.
  const FoundationPaths();

  /// Returns the path of the current user's folder of the given kind, or `null` if
  /// Foundation lists none.
  ///
  /// The path is absolute and has no trailing slash. For an iOS app, or a macOS
  /// app with the App Sandbox, it points into the app's own container.
  ///
  /// Does not create the folder, check that it exists, or append the bundle
  /// identifier; a caller that needs any of these does it, using
  /// [mainBundleIdentifier] for the last.
  String? userDirectory(NSSearchPathDirectory directory) {
    // Foundation autoreleases the array. It is read before this method returns,
    // so it is never retained or released here.
    final _CFRef paths = _searchPathForDirectories(
      directory.value,
      NSSearchPathDomainMask.NSUserDomainMask,
      true,
    );
    if (paths == ffi.nullptr || _arrayCount(paths) == 0) {
      return null;
    }
    return _toDartString(_arrayValueAtIndex(paths, 0));
  }

  /// The main bundle's identifier, such as `com.example.app`, or `null` if the
  /// running executable has none.
  ///
  /// Read from the `CFBundleIdentifier` entry of the app's `Info.plist`. A
  /// command-line tool has no such entry.
  String? get mainBundleIdentifier {
    final _CFRef bundle = _mainBundle();
    if (bundle == ffi.nullptr) {
      return null;
    }
    return _toDartString(_bundleIdentifier(bundle));
  }
}

/// A CoreFoundation object reference.
///
/// None used in this file is owned by it: Foundation autoreleases the array
/// and the other objects are borrowed from the array or from the bundle, so
/// nothing is retained or released.
typedef _CFRef = ffi.Pointer<ffi.Void>;

/// `kCFStringEncodingUTF8`, as defined in CoreFoundation's `CFString.h`.
const int _utf8Encoding = 0x08000100;

/// Copies the `CFString` [string] into a Dart string.
///
/// Returns `null` if [string] is null, empty, or cannot be written as UTF-8.
String? _toDartString(_CFRef string) {
  if (string == ffi.nullptr) {
    return null;
  }
  final int maxBytes = _maximumSizeForEncoding(_stringLength(string), _utf8Encoding);
  if (maxBytes <= 0) {
    return null;
  }
  // One more byte for the terminating zero that CFStringGetCString writes.
  final int bufferSize = maxBytes + 1;
  final ffi.Pointer<ffi.Char> buffer = malloc<ffi.Char>(bufferSize);
  try {
    if (_copyCString(string, buffer, bufferSize, _utf8Encoding) == 0) {
      return null;
    }
    return buffer.cast<Utf8>().toDartString();
  } finally {
    malloc.free(buffer);
  }
}

/// Foundation, opened on first use rather than on import.
///
/// Any app that uses AppKit or UIKit has already loaded it, so this returns
/// the handle of that copy.
final ffi.DynamicLibrary _foundation = ffi.DynamicLibrary.open(
  '/System/Library/Frameworks/Foundation.framework/Foundation',
);

/// CoreFoundation, opened on first use rather than on import, with the same
/// handle as the copy that Foundation already loaded.
final ffi.DynamicLibrary _coreFoundation = ffi.DynamicLibrary.open(
  '/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation',
);

// Each lookup runs on first use and follows the types of the C headers:
// `CFIndex` is a signed long, `Boolean` an unsigned char and
// `CFStringEncoding` an unsigned int.

final _CFRef Function(int, int, bool) _searchPathForDirectories = _foundation
    .lookupFunction<
      _CFRef Function(ffi.UnsignedLong, ffi.UnsignedLong, ffi.Bool),
      _CFRef Function(int, int, bool)
    >('NSSearchPathForDirectoriesInDomains');

final int Function(_CFRef) _arrayCount = _coreFoundation
    .lookupFunction<ffi.Long Function(_CFRef), int Function(_CFRef)>('CFArrayGetCount');

final _CFRef Function(_CFRef, int) _arrayValueAtIndex = _coreFoundation
    .lookupFunction<_CFRef Function(_CFRef, ffi.Long), _CFRef Function(_CFRef, int)>(
      'CFArrayGetValueAtIndex',
    );

final int Function(_CFRef) _stringLength = _coreFoundation
    .lookupFunction<ffi.Long Function(_CFRef), int Function(_CFRef)>('CFStringGetLength');

final int Function(int, int) _maximumSizeForEncoding = _coreFoundation
    .lookupFunction<ffi.Long Function(ffi.Long, ffi.UnsignedInt), int Function(int, int)>(
      'CFStringGetMaximumSizeForEncoding',
    );

final int Function(_CFRef, ffi.Pointer<ffi.Char>, int, int) _copyCString = _coreFoundation
    .lookupFunction<
      ffi.Uint8 Function(_CFRef, ffi.Pointer<ffi.Char>, ffi.Long, ffi.UnsignedInt),
      int Function(_CFRef, ffi.Pointer<ffi.Char>, int, int)
    >('CFStringGetCString');

final _CFRef Function() _mainBundle = _coreFoundation
    .lookupFunction<_CFRef Function(), _CFRef Function()>('CFBundleGetMainBundle');

final _CFRef Function(_CFRef) _bundleIdentifier = _coreFoundation
    .lookupFunction<_CFRef Function(_CFRef), _CFRef Function(_CFRef)>('CFBundleGetIdentifier');

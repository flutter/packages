// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#endif

/// A protocol that wraps FlutterMethodChannel.
@objc public protocol FLTMethodChannelProtocol: NSObjectProtocol {
  /// Invokes the specified Flutter method with the specified arguments, expecting
  /// an asynchronous result.
  func invokeMethod(_ method: String, arguments: Any?)

  /// Invokes the specified Flutter method with the specified arguments and specified callback
  func invokeMethod(_ method: String, arguments: Any?, result: FlutterResult?)
}

/// The default method channel that wraps FlutterMethodChannel
public class DefaultMethodChannel: NSObject, FLTMethodChannelProtocol {
  /// The wrapped FlutterMethodChannel
  private let channel: FlutterMethodChannel

  /// Initialize this wrapper with a FlutterMethodChannel
  public init(channel: FlutterMethodChannel) {
    self.channel = channel
  }

  public func invokeMethod(_ method: String, arguments: Any?) {
    channel.invokeMethod(method, arguments: arguments)
  }

  public func invokeMethod(_ method: String, arguments: Any?, result: FlutterResult?) {
    channel.invokeMethod(method, arguments: arguments, result: result)
  }
}

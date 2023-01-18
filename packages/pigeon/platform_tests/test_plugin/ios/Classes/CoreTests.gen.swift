// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// 
// Autogenerated from Pigeon (v6.0.2), do not edit directly.
// See also: https://pub.dev/packages/pigeon

import Foundation
#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#else
#error("Unsupported platform.")
#endif



private func wrapResult(_ result: Any?) -> [Any?] {
  return [result]
}

private func wrapError(_ error: FlutterError) -> [Any?] {
  return [
    error.code,
    error.message,
    error.details
  ]
}

enum AnEnum: Int {
  case one = 0
  case two = 1
  case three = 2
}

/// Generated class from Pigeon that represents data sent in messages.
struct AllTypes {
  var aBool: Bool
  var anInt: Int32
  var aDouble: Double
  var aString: String
  var aByteArray: FlutterStandardTypedData
  var a4ByteArray: FlutterStandardTypedData
  var a8ByteArray: FlutterStandardTypedData
  var aFloatArray: FlutterStandardTypedData
  var aList: [Any?]
  var aMap: [AnyHashable: Any?]
  var anEnum: AnEnum

  static func fromList(_ list: [Any?]) -> AllTypes? {
    let aBool = list[0] as! Bool
    let anInt = list[1] as! Int32
    let aDouble = list[2] as! Double
    let aString = list[3] as! String
    let aByteArray = list[4] as! FlutterStandardTypedData
    let a4ByteArray = list[5] as! FlutterStandardTypedData
    let a8ByteArray = list[6] as! FlutterStandardTypedData
    let aFloatArray = list[7] as! FlutterStandardTypedData
    let aList = list[8] as! [Any?]
    let aMap = list[9] as! [AnyHashable: Any?]
    let anEnum = AnEnum(rawValue: list[10] as! Int)!

    return AllTypes(
      aBool: aBool,
      anInt: anInt,
      aDouble: aDouble,
      aString: aString,
      aByteArray: aByteArray,
      a4ByteArray: a4ByteArray,
      a8ByteArray: a8ByteArray,
      aFloatArray: aFloatArray,
      aList: aList,
      aMap: aMap,
      anEnum: anEnum
    )
  }
  func toList() -> [Any?] {
    return [
      aBool,
      anInt,
      aDouble,
      aString,
      aByteArray,
      a4ByteArray,
      a8ByteArray,
      aFloatArray,
      aList,
      aMap,
      anEnum.rawValue,
    ]
  }
}

/// Generated class from Pigeon that represents data sent in messages.
struct AllNullableTypes {
  var aNullableBool: Bool? = nil
  var aNullableInt: Int32? = nil
  var aNullableDouble: Double? = nil
  var aNullableString: String? = nil
  var aNullableByteArray: FlutterStandardTypedData? = nil
  var aNullable4ByteArray: FlutterStandardTypedData? = nil
  var aNullable8ByteArray: FlutterStandardTypedData? = nil
  var aNullableFloatArray: FlutterStandardTypedData? = nil
  var aNullableList: [Any?]? = nil
  var aNullableMap: [AnyHashable: Any?]? = nil
  var nullableNestedList: [[Bool?]?]? = nil
  var nullableMapWithAnnotations: [String?: String?]? = nil
  var nullableMapWithObject: [String?: Any?]? = nil
  var aNullableEnum: AnEnum? = nil

  static func fromList(_ list: [Any?]) -> AllNullableTypes? {
    let aNullableBool = list[0] as? Bool 
    let aNullableInt = list[1] as? Int32 
    let aNullableDouble = list[2] as? Double 
    let aNullableString = list[3] as? String 
    let aNullableByteArray = list[4] as? FlutterStandardTypedData 
    let aNullable4ByteArray = list[5] as? FlutterStandardTypedData 
    let aNullable8ByteArray = list[6] as? FlutterStandardTypedData 
    let aNullableFloatArray = list[7] as? FlutterStandardTypedData 
    let aNullableList = list[8] as? [Any?] 
    let aNullableMap = list[9] as? [AnyHashable: Any?] 
    let nullableNestedList = list[10] as? [[Bool?]?] 
    let nullableMapWithAnnotations = list[11] as? [String?: String?] 
    let nullableMapWithObject = list[12] as? [String?: Any?] 
    var aNullableEnum: AnEnum? = nil
    if let aNullableEnumRawValue = list[13] as? Int {
      aNullableEnum = AnEnum(rawValue: aNullableEnumRawValue)
    }

    return AllNullableTypes(
      aNullableBool: aNullableBool,
      aNullableInt: aNullableInt,
      aNullableDouble: aNullableDouble,
      aNullableString: aNullableString,
      aNullableByteArray: aNullableByteArray,
      aNullable4ByteArray: aNullable4ByteArray,
      aNullable8ByteArray: aNullable8ByteArray,
      aNullableFloatArray: aNullableFloatArray,
      aNullableList: aNullableList,
      aNullableMap: aNullableMap,
      nullableNestedList: nullableNestedList,
      nullableMapWithAnnotations: nullableMapWithAnnotations,
      nullableMapWithObject: nullableMapWithObject,
      aNullableEnum: aNullableEnum
    )
  }
  func toList() -> [Any?] {
    return [
      aNullableBool,
      aNullableInt,
      aNullableDouble,
      aNullableString,
      aNullableByteArray,
      aNullable4ByteArray,
      aNullable8ByteArray,
      aNullableFloatArray,
      aNullableList,
      aNullableMap,
      nullableNestedList,
      nullableMapWithAnnotations,
      nullableMapWithObject,
      aNullableEnum?.rawValue,
    ]
  }
}

/// Generated class from Pigeon that represents data sent in messages.
struct AllNullableTypesWrapper {
  var values: AllNullableTypes

  static func fromList(_ list: [Any?]) -> AllNullableTypesWrapper? {
    let values = AllNullableTypes.fromList(list[0] as! [Any?])!

    return AllNullableTypesWrapper(
      values: values
    )
  }
  func toList() -> [Any?] {
    return [
      values.toList(),
    ]
  }
}

private class HostIntegrationCoreApiCodecReader: FlutterStandardReader {
  override func readValue(ofType type: UInt8) -> Any? {
    switch type {
      case 128:
        return AllNullableTypes.fromList(self.readValue() as! [Any])      
      case 129:
        return AllNullableTypesWrapper.fromList(self.readValue() as! [Any])      
      case 130:
        return AllTypes.fromList(self.readValue() as! [Any])      
      default:
        return super.readValue(ofType: type)
      
    }
  }
}
private class HostIntegrationCoreApiCodecWriter: FlutterStandardWriter {
  override func writeValue(_ value: Any) {
    if let value = value as? AllNullableTypes {
      super.writeByte(128)
      super.writeValue(value.toList())
    } else if let value = value as? AllNullableTypesWrapper {
      super.writeByte(129)
      super.writeValue(value.toList())
    } else if let value = value as? AllTypes {
      super.writeByte(130)
      super.writeValue(value.toList())
    } else {
      super.writeValue(value)
    }
  }
}

private class HostIntegrationCoreApiCodecReaderWriter: FlutterStandardReaderWriter {
  override func reader(with data: Data) -> FlutterStandardReader {
    return HostIntegrationCoreApiCodecReader(data: data)
  }

  override func writer(with data: NSMutableData) -> FlutterStandardWriter {
    return HostIntegrationCoreApiCodecWriter(data: data)
  }
}

class HostIntegrationCoreApiCodec: FlutterStandardMessageCodec {
  static let shared = HostIntegrationCoreApiCodec(readerWriter: HostIntegrationCoreApiCodecReaderWriter())
}

/// The core interface that each host language plugin must implement in
/// platform_test integration tests.
///
/// Generated protocol from Pigeon that represents a handler of messages from Flutter.
protocol HostIntegrationCoreApi {
  /// A no-op function taking no arguments and returning no value, to sanity
  /// test basic calling.
  func noop()
  /// Returns the passed object, to test serialization and deserialization.
  func echo(allTypes everything: AllTypes) -> AllTypes
  /// Returns the passed object, to test serialization and deserialization.
  func echo(allNullableTypes everything: AllNullableTypes?) -> AllNullableTypes?
  /// Returns an error, to test error handling.
  func throwError()
  /// Returns passed in int.
  func echo(int anInt: Int32) -> Int32
  /// Returns passed in double.
  func echo(double aDouble: Double) -> Double
  /// Returns the passed in boolean.
  func echo(bool aBool: Bool) -> Bool
  /// Returns the passed in string.
  func echo(string aString: String) -> String
  /// Returns the passed in Uint8List.
  func echo(uint8List aUint8List: FlutterStandardTypedData) -> FlutterStandardTypedData
  /// Returns the passed in generic Object.
  func echo(object anObject: Any) -> Any
  /// Returns the inner `aString` value from the wrapped object, to test
  /// sending of nested objects.
  func extractNestedNullableString(from wrapper: AllNullableTypesWrapper) -> String?
  /// Returns the inner `aString` value from the wrapped object, to test
  /// sending of nested objects.
  func createNestedObject(with nullableString: String?) -> AllNullableTypesWrapper
  /// Returns passed in arguments of multiple types.
  func sendMultipleNullableTypes(aBool aNullableBool: Bool?, anInt aNullableInt: Int32?, aString aNullableString: String?) -> AllNullableTypes
  /// Returns passed in int.
  func echo(nullableInt aNullableInt: Int32?) -> Int32?
  /// Returns passed in double.
  func echo(nullableDouble aNullableDouble: Double?) -> Double?
  /// Returns the passed in boolean.
  func echo(nullableBool aNullableBool: Bool?) -> Bool?
  /// Returns the passed in string.
  func echo(nullableString aNullableString: String?) -> String?
  /// Returns the passed in Uint8List.
  func echo(nullableUint8List aNullableUint8List: FlutterStandardTypedData?) -> FlutterStandardTypedData?
  /// Returns the passed in generic Object.
  func echo(nullableObject aNullableObject: Any?) -> Any?
  /// A no-op function taking no arguments and returning no value, to sanity
  /// test basic asynchronous calling.
  func noopAsync(completion: @escaping () -> Void)
  /// Returns the passed string asynchronously.
  func echoAsync(string aString: String, completion: @escaping (String) -> Void)
  func callFlutterNoop(completion: @escaping () -> Void)
  func callFlutterEcho(string aString: String, completion: @escaping (String) -> Void)
}

/// Generated setup class from Pigeon to handle messages through the `binaryMessenger`.
class HostIntegrationCoreApiSetup {
  /// The codec used by HostIntegrationCoreApi.
  static var codec: FlutterStandardMessageCodec { HostIntegrationCoreApiCodec.shared }
  /// Sets up an instance of `HostIntegrationCoreApi` to handle messages through the `binaryMessenger`.
  static func setUp(binaryMessenger: FlutterBinaryMessenger, api: HostIntegrationCoreApi?) {
    /// A no-op function taking no arguments and returning no value, to sanity
    /// test basic calling.
    let noopChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.HostIntegrationCoreApi.noop", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      noopChannel.setMessageHandler { _, reply in
        api.noop()
        reply(wrapResult(nil))
      }
    } else {
      noopChannel.setMessageHandler(nil)
    }
    /// Returns the passed object, to test serialization and deserialization.
    let echoAllTypesChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.HostIntegrationCoreApi.echoAllTypes", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      echoAllTypesChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let everythingArg = args[0] as! AllTypes
        let result = api.echo(allTypes: everythingArg)
        reply(wrapResult(result))
      }
    } else {
      echoAllTypesChannel.setMessageHandler(nil)
    }
    /// Returns the passed object, to test serialization and deserialization.
    let echoAllNullableTypesChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.HostIntegrationCoreApi.echoAllNullableTypes", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      echoAllNullableTypesChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let everythingArg = args[0] as? AllNullableTypes
        let result = api.echo(allNullableTypes: everythingArg)
        reply(wrapResult(result))
      }
    } else {
      echoAllNullableTypesChannel.setMessageHandler(nil)
    }
    /// Returns an error, to test error handling.
    let throwErrorChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.HostIntegrationCoreApi.throwError", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      throwErrorChannel.setMessageHandler { _, reply in
        api.throwError()
        reply(wrapResult(nil))
      }
    } else {
      throwErrorChannel.setMessageHandler(nil)
    }
    /// Returns passed in int.
    let echoIntChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.HostIntegrationCoreApi.echoInt", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      echoIntChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let anIntArg = args[0] as! Int32
        let result = api.echo(int: anIntArg)
        reply(wrapResult(result))
      }
    } else {
      echoIntChannel.setMessageHandler(nil)
    }
    /// Returns passed in double.
    let echoDoubleChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.HostIntegrationCoreApi.echoDouble", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      echoDoubleChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let aDoubleArg = args[0] as! Double
        let result = api.echo(double: aDoubleArg)
        reply(wrapResult(result))
      }
    } else {
      echoDoubleChannel.setMessageHandler(nil)
    }
    /// Returns the passed in boolean.
    let echoBoolChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.HostIntegrationCoreApi.echoBool", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      echoBoolChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let aBoolArg = args[0] as! Bool
        let result = api.echo(bool: aBoolArg)
        reply(wrapResult(result))
      }
    } else {
      echoBoolChannel.setMessageHandler(nil)
    }
    /// Returns the passed in string.
    let echoStringChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.HostIntegrationCoreApi.echoString", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      echoStringChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let aStringArg = args[0] as! String
        let result = api.echo(string: aStringArg)
        reply(wrapResult(result))
      }
    } else {
      echoStringChannel.setMessageHandler(nil)
    }
    /// Returns the passed in Uint8List.
    let echoUint8ListChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.HostIntegrationCoreApi.echoUint8List", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      echoUint8ListChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let aUint8ListArg = args[0] as! FlutterStandardTypedData
        let result = api.echo(uint8List: aUint8ListArg)
        reply(wrapResult(result))
      }
    } else {
      echoUint8ListChannel.setMessageHandler(nil)
    }
    /// Returns the passed in generic Object.
    let echoObjectChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.HostIntegrationCoreApi.echoObject", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      echoObjectChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let anObjectArg = args[0]!
        let result = api.echo(object: anObjectArg)
        reply(wrapResult(result))
      }
    } else {
      echoObjectChannel.setMessageHandler(nil)
    }
    /// Returns the inner `aString` value from the wrapped object, to test
    /// sending of nested objects.
    let extractNestedNullableStringChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.HostIntegrationCoreApi.extractNestedNullableString", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      extractNestedNullableStringChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let wrapperArg = args[0] as! AllNullableTypesWrapper
        let result = api.extractNestedNullableString(from: wrapperArg)
        reply(wrapResult(result))
      }
    } else {
      extractNestedNullableStringChannel.setMessageHandler(nil)
    }
    /// Returns the inner `aString` value from the wrapped object, to test
    /// sending of nested objects.
    let createNestedNullableStringChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.HostIntegrationCoreApi.createNestedNullableString", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      createNestedNullableStringChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let nullableStringArg = args[0] as? String
        let result = api.createNestedObject(with: nullableStringArg)
        reply(wrapResult(result))
      }
    } else {
      createNestedNullableStringChannel.setMessageHandler(nil)
    }
    /// Returns passed in arguments of multiple types.
    let sendMultipleNullableTypesChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.HostIntegrationCoreApi.sendMultipleNullableTypes", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      sendMultipleNullableTypesChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let aNullableBoolArg = args[0] as? Bool
        let aNullableIntArg = args[1] as? Int32
        let aNullableStringArg = args[2] as? String
        let result = api.sendMultipleNullableTypes(aBool: aNullableBoolArg, anInt: aNullableIntArg, aString: aNullableStringArg)
        reply(wrapResult(result))
      }
    } else {
      sendMultipleNullableTypesChannel.setMessageHandler(nil)
    }
    /// Returns passed in int.
    let echoNullableIntChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.HostIntegrationCoreApi.echoNullableInt", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      echoNullableIntChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let aNullableIntArg = args[0] as? Int32
        let result = api.echo(nullableInt: aNullableIntArg)
        reply(wrapResult(result))
      }
    } else {
      echoNullableIntChannel.setMessageHandler(nil)
    }
    /// Returns passed in double.
    let echoNullableDoubleChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.HostIntegrationCoreApi.echoNullableDouble", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      echoNullableDoubleChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let aNullableDoubleArg = args[0] as? Double
        let result = api.echo(nullableDouble: aNullableDoubleArg)
        reply(wrapResult(result))
      }
    } else {
      echoNullableDoubleChannel.setMessageHandler(nil)
    }
    /// Returns the passed in boolean.
    let echoNullableBoolChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.HostIntegrationCoreApi.echoNullableBool", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      echoNullableBoolChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let aNullableBoolArg = args[0] as? Bool
        let result = api.echo(nullableBool: aNullableBoolArg)
        reply(wrapResult(result))
      }
    } else {
      echoNullableBoolChannel.setMessageHandler(nil)
    }
    /// Returns the passed in string.
    let echoNullableStringChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.HostIntegrationCoreApi.echoNullableString", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      echoNullableStringChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let aNullableStringArg = args[0] as? String
        let result = api.echo(nullableString: aNullableStringArg)
        reply(wrapResult(result))
      }
    } else {
      echoNullableStringChannel.setMessageHandler(nil)
    }
    /// Returns the passed in Uint8List.
    let echoNullableUint8ListChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.HostIntegrationCoreApi.echoNullableUint8List", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      echoNullableUint8ListChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let aNullableUint8ListArg = args[0] as? FlutterStandardTypedData
        let result = api.echo(nullableUint8List: aNullableUint8ListArg)
        reply(wrapResult(result))
      }
    } else {
      echoNullableUint8ListChannel.setMessageHandler(nil)
    }
    /// Returns the passed in generic Object.
    let echoNullableObjectChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.HostIntegrationCoreApi.echoNullableObject", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      echoNullableObjectChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let aNullableObjectArg = args[0]
        let result = api.echo(nullableObject: aNullableObjectArg)
        reply(wrapResult(result))
      }
    } else {
      echoNullableObjectChannel.setMessageHandler(nil)
    }
    /// A no-op function taking no arguments and returning no value, to sanity
    /// test basic asynchronous calling.
    let noopAsyncChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.HostIntegrationCoreApi.noopAsync", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      noopAsyncChannel.setMessageHandler { _, reply in
        api.noopAsync() {
          reply(wrapResult(nil))
        }
      }
    } else {
      noopAsyncChannel.setMessageHandler(nil)
    }
    /// Returns the passed string asynchronously.
    let echoAsyncStringChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.HostIntegrationCoreApi.echoAsyncString", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      echoAsyncStringChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let aStringArg = args[0] as! String
        api.echoAsync(string: aStringArg) { result in
          reply(wrapResult(result))
        }
      }
    } else {
      echoAsyncStringChannel.setMessageHandler(nil)
    }
    let callFlutterNoopChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.HostIntegrationCoreApi.callFlutterNoop", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      callFlutterNoopChannel.setMessageHandler { _, reply in
        api.callFlutterNoop() {
          reply(wrapResult(nil))
        }
      }
    } else {
      callFlutterNoopChannel.setMessageHandler(nil)
    }
    let callFlutterEchoStringChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.HostIntegrationCoreApi.callFlutterEchoString", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      callFlutterEchoStringChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let aStringArg = args[0] as! String
        api.callFlutterEcho(string: aStringArg) { result in
          reply(wrapResult(result))
        }
      }
    } else {
      callFlutterEchoStringChannel.setMessageHandler(nil)
    }
  }
}
private class FlutterIntegrationCoreApiCodecReader: FlutterStandardReader {
  override func readValue(ofType type: UInt8) -> Any? {
    switch type {
      case 128:
        return AllNullableTypes.fromList(self.readValue() as! [Any])      
      case 129:
        return AllNullableTypesWrapper.fromList(self.readValue() as! [Any])      
      case 130:
        return AllTypes.fromList(self.readValue() as! [Any])      
      default:
        return super.readValue(ofType: type)
      
    }
  }
}
private class FlutterIntegrationCoreApiCodecWriter: FlutterStandardWriter {
  override func writeValue(_ value: Any) {
    if let value = value as? AllNullableTypes {
      super.writeByte(128)
      super.writeValue(value.toList())
    } else if let value = value as? AllNullableTypesWrapper {
      super.writeByte(129)
      super.writeValue(value.toList())
    } else if let value = value as? AllTypes {
      super.writeByte(130)
      super.writeValue(value.toList())
    } else {
      super.writeValue(value)
    }
  }
}

private class FlutterIntegrationCoreApiCodecReaderWriter: FlutterStandardReaderWriter {
  override func reader(with data: Data) -> FlutterStandardReader {
    return FlutterIntegrationCoreApiCodecReader(data: data)
  }

  override func writer(with data: NSMutableData) -> FlutterStandardWriter {
    return FlutterIntegrationCoreApiCodecWriter(data: data)
  }
}

class FlutterIntegrationCoreApiCodec: FlutterStandardMessageCodec {
  static let shared = FlutterIntegrationCoreApiCodec(readerWriter: FlutterIntegrationCoreApiCodecReaderWriter())
}

/// The core interface that the Dart platform_test code implements for host
/// integration tests to call into.
///
/// Generated class from Pigeon that represents Flutter messages that can be called from Swift.
class FlutterIntegrationCoreApi {
  private let binaryMessenger: FlutterBinaryMessenger
  init(binaryMessenger: FlutterBinaryMessenger){
    self.binaryMessenger = binaryMessenger
  }
  var codec: FlutterStandardMessageCodec {
    return FlutterIntegrationCoreApiCodec.shared
  }
  /// A no-op function taking no arguments and returning no value, to sanity
  /// test basic calling.
  func noop(completion: @escaping () -> Void) {
    let channel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.FlutterIntegrationCoreApi.noop", binaryMessenger: binaryMessenger, codec: codec)
    channel.sendMessage(nil) { _ in
      completion()
    }
  }
  /// Returns the passed object, to test serialization and deserialization.
  func echo(allTypes everythingArg: AllTypes, completion: @escaping (AllTypes) -> Void) {
    let channel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.FlutterIntegrationCoreApi.echoAllTypes", binaryMessenger: binaryMessenger, codec: codec)
    channel.sendMessage([everythingArg] as [Any?]) { response in
      let result = response as! AllTypes
      completion(result)
    }
  }
  /// Returns the passed object, to test serialization and deserialization.
  func echo(allNullableTypes everythingArg: AllNullableTypes, completion: @escaping (AllNullableTypes) -> Void) {
    let channel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.FlutterIntegrationCoreApi.echoAllNullableTypes", binaryMessenger: binaryMessenger, codec: codec)
    channel.sendMessage([everythingArg] as [Any?]) { response in
      let result = response as! AllNullableTypes
      completion(result)
    }
  }
  /// Returns passed in arguments of multiple types.
  ///
  /// Tests multiple-arity FlutterApi handling.
  func sendMultipleNullableTypes(aBool aNullableBoolArg: Bool?, anInt aNullableIntArg: Int32?, aString aNullableStringArg: String?, completion: @escaping (AllNullableTypes) -> Void) {
    let channel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.FlutterIntegrationCoreApi.sendMultipleNullableTypes", binaryMessenger: binaryMessenger, codec: codec)
    channel.sendMessage([aNullableBoolArg, aNullableIntArg, aNullableStringArg] as [Any?]) { response in
      let result = response as! AllNullableTypes
      completion(result)
    }
  }
  /// Returns the passed boolean, to test serialization and deserialization.
  func echo(bool aBoolArg: Bool, completion: @escaping (Bool) -> Void) {
    let channel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.FlutterIntegrationCoreApi.echoBool", binaryMessenger: binaryMessenger, codec: codec)
    channel.sendMessage([aBoolArg] as [Any?]) { response in
      let result = response as! Bool
      completion(result)
    }
  }
  /// Returns the passed int, to test serialization and deserialization.
  func echo(int anIntArg: Int32, completion: @escaping (Int32) -> Void) {
    let channel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.FlutterIntegrationCoreApi.echoInt", binaryMessenger: binaryMessenger, codec: codec)
    channel.sendMessage([anIntArg] as [Any?]) { response in
      let result = response as! Int32
      completion(result)
    }
  }
  /// Returns the passed double, to test serialization and deserialization.
  func echo(double aDoubleArg: Double, completion: @escaping (Double) -> Void) {
    let channel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.FlutterIntegrationCoreApi.echoDouble", binaryMessenger: binaryMessenger, codec: codec)
    channel.sendMessage([aDoubleArg] as [Any?]) { response in
      let result = response as! Double
      completion(result)
    }
  }
  /// Returns the passed string, to test serialization and deserialization.
  func echo(string aStringArg: String, completion: @escaping (String) -> Void) {
    let channel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.FlutterIntegrationCoreApi.echoString", binaryMessenger: binaryMessenger, codec: codec)
    channel.sendMessage([aStringArg] as [Any?]) { response in
      let result = response as! String
      completion(result)
    }
  }
  /// Returns the passed byte list, to test serialization and deserialization.
  func echo(uint8List aListArg: FlutterStandardTypedData, completion: @escaping (FlutterStandardTypedData) -> Void) {
    let channel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.FlutterIntegrationCoreApi.echoUint8List", binaryMessenger: binaryMessenger, codec: codec)
    channel.sendMessage([aListArg] as [Any?]) { response in
      let result = response as! FlutterStandardTypedData
      completion(result)
    }
  }
  /// Returns the passed list, to test serialization and deserialization.
  func echo(list aListArg: [Any?], completion: @escaping ([Any?]) -> Void) {
    let channel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.FlutterIntegrationCoreApi.echoList", binaryMessenger: binaryMessenger, codec: codec)
    channel.sendMessage([aListArg] as [Any?]) { response in
      let result = response as! [Any?]
      completion(result)
    }
  }
  /// Returns the passed map, to test serialization and deserialization.
  func echoMap(aMap aMapArg: [String?: Any?], completion: @escaping ([String?: Any?]) -> Void) {
    let channel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.FlutterIntegrationCoreApi.echoMap", binaryMessenger: binaryMessenger, codec: codec)
    channel.sendMessage([aMapArg] as [Any?]) { response in
      let result = response as! [String?: Any?]
      completion(result)
    }
  }
  /// Returns the passed boolean, to test serialization and deserialization.
  func echo(nullableBool aBoolArg: Bool?, completion: @escaping (Bool?) -> Void) {
    let channel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.FlutterIntegrationCoreApi.echoNullableBool", binaryMessenger: binaryMessenger, codec: codec)
    channel.sendMessage([aBoolArg] as [Any?]) { response in
      let result = response as? Bool
      completion(result)
    }
  }
  /// Returns the passed int, to test serialization and deserialization.
  func echo(nullableInt anIntArg: Int32?, completion: @escaping (Int32?) -> Void) {
    let channel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.FlutterIntegrationCoreApi.echoNullableInt", binaryMessenger: binaryMessenger, codec: codec)
    channel.sendMessage([anIntArg] as [Any?]) { response in
      let result = response as? Int32
      completion(result)
    }
  }
  /// Returns the passed double, to test serialization and deserialization.
  func echo(nullableDouble aDoubleArg: Double?, completion: @escaping (Double?) -> Void) {
    let channel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.FlutterIntegrationCoreApi.echoNullableDouble", binaryMessenger: binaryMessenger, codec: codec)
    channel.sendMessage([aDoubleArg] as [Any?]) { response in
      let result = response as? Double
      completion(result)
    }
  }
  /// Returns the passed string, to test serialization and deserialization.
  func echo(nullableString aStringArg: String?, completion: @escaping (String?) -> Void) {
    let channel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.FlutterIntegrationCoreApi.echoNullableString", binaryMessenger: binaryMessenger, codec: codec)
    channel.sendMessage([aStringArg] as [Any?]) { response in
      let result = response as? String
      completion(result)
    }
  }
  /// Returns the passed byte list, to test serialization and deserialization.
  func echo(nullableUint8List aListArg: FlutterStandardTypedData?, completion: @escaping (FlutterStandardTypedData?) -> Void) {
    let channel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.FlutterIntegrationCoreApi.echoNullableUint8List", binaryMessenger: binaryMessenger, codec: codec)
    channel.sendMessage([aListArg] as [Any?]) { response in
      let result = response as? FlutterStandardTypedData
      completion(result)
    }
  }
  /// Returns the passed list, to test serialization and deserialization.
  func echo(nullableList aListArg: [Any?]?, completion: @escaping ([Any?]?) -> Void) {
    let channel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.FlutterIntegrationCoreApi.echoNullableList", binaryMessenger: binaryMessenger, codec: codec)
    channel.sendMessage([aListArg] as [Any?]) { response in
      let result = response as? [Any?]
      completion(result)
    }
  }
  /// Returns the passed map, to test serialization and deserialization.
  func echo(nullableMap aMapArg: [String?: Any?], completion: @escaping ([String?: Any?]) -> Void) {
    let channel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.FlutterIntegrationCoreApi.echoNullableMap", binaryMessenger: binaryMessenger, codec: codec)
    channel.sendMessage([aMapArg] as [Any?]) { response in
      let result = response as! [String?: Any?]
      completion(result)
    }
  }
}
/// An API that can be implemented for minimal, compile-only tests.
///
/// Generated protocol from Pigeon that represents a handler of messages from Flutter.
protocol HostTrivialApi {
  func noop()
}

/// Generated setup class from Pigeon to handle messages through the `binaryMessenger`.
class HostTrivialApiSetup {
  /// The codec used by HostTrivialApi.
  /// Sets up an instance of `HostTrivialApi` to handle messages through the `binaryMessenger`.
  static func setUp(binaryMessenger: FlutterBinaryMessenger, api: HostTrivialApi?) {
    let noopChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.HostTrivialApi.noop", binaryMessenger: binaryMessenger)
    if let api = api {
      noopChannel.setMessageHandler { _, reply in
        api.noop()
        reply(wrapResult(nil))
      }
    } else {
      noopChannel.setMessageHandler(nil)
    }
  }
}

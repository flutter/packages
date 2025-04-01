// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// Autogenerated from Pigeon, do not edit directly.
// See also: https://pub.dev/packages/pigeon

import Foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

/// Error class for passing custom error details to Dart side.
final class EventChannelTestsError: Error {
  let code: String
  let message: String?
  let details: Sendable?

  init(code: String, message: String?, details: Sendable?) {
    self.code = code
    self.message = message
    self.details = details
  }

  var localizedDescription: String {
    return
      "EventChannelTestsError(code: \(code), message: \(message ?? "<nil>"), details: \(details ?? "<nil>")"
  }
}

private func isNullish(_ value: Any?) -> Bool {
  return value is NSNull || value == nil
}

private func nilOrValue<T>(_ value: Any?) -> T? {
  if value is NSNull { return nil }
  return value as! T?
}

func deepEqualsEventChannelTests(_ lhs: Any?, _ rhs: Any?) -> Bool {
  let cleanLhs = nilOrValue(lhs) as Any?
  let cleanRhs = nilOrValue(rhs) as Any?
  switch (cleanLhs, cleanRhs) {
  case (nil, nil):
    return true

  case (nil, _), (_, nil):
    return false

  case is (Void, Void):
    return true

  case let (cleanLhsHashable, cleanRhsHashable) as (AnyHashable, AnyHashable):
    return cleanLhsHashable == cleanRhsHashable

  case let (cleanLhsArray, cleanRhsArray) as ([Any?], [Any?]):
    guard cleanLhsArray.count == cleanRhsArray.count else { return false }
    for (index, element) in cleanLhsArray.enumerated() {
      if !deepEqualsEventChannelTests(element, cleanRhsArray[index]) {
        return false
      }
    }
    return true

  case let (cleanLhsDictionary, cleanRhsDictionary) as ([AnyHashable: Any?], [AnyHashable: Any?]):
    guard cleanLhsDictionary.count == cleanRhsDictionary.count else { return false }
    for (key, cleanLhsValue) in cleanLhsDictionary {
      guard let cleanRhsValue = cleanRhsDictionary[key] else { return false }
      if !deepEqualsEventChannelTests(cleanLhsValue, cleanRhsValue) {
        return false
      }
    }
    return true

  default:
    return String(describing: cleanLhs) == String(describing: cleanRhs)
  }
}

func deepHashEventChannelTests(value: Any?, hasher: inout Hasher) {
  if let valueList = value as? [AnyHashable] {
    for item in valueList { deepHashEventChannelTests(value: item, hasher: &hasher) }
    return
  }

  if let valueDict = value as? [AnyHashable: AnyHashable] {
    for key in valueDict.keys {
      hasher.combine(key)
      deepHashEventChannelTests(value: valueDict[key]!, hasher: &hasher)
    }
    return
  }

  if let hashableValue = value as? AnyHashable {
    hasher.combine(hashableValue.hashValue)
  }

  return hasher.combine(String(describing: value))
}

enum EventEnum: Int {
  case one = 0
  case two = 1
  case three = 2
  case fortyTwo = 3
  case fourHundredTwentyTwo = 4
}

enum AnotherEventEnum: Int {
  case justInCase = 0
}

/// A class containing all supported nullable types.
///
/// Generated class from Pigeon that represents data sent in messages.
class EventAllNullableTypes: Hashable {
  init(
    aNullableBool: Bool? = nil,
    aNullableInt: Int64? = nil,
    aNullableInt64: Int64? = nil,
    aNullableDouble: Double? = nil,
    aNullableByteArray: FlutterStandardTypedData? = nil,
    aNullable4ByteArray: FlutterStandardTypedData? = nil,
    aNullable8ByteArray: FlutterStandardTypedData? = nil,
    aNullableFloatArray: FlutterStandardTypedData? = nil,
    aNullableEnum: EventEnum? = nil,
    anotherNullableEnum: AnotherEventEnum? = nil,
    aNullableString: String? = nil,
    aNullableObject: Any? = nil,
    allNullableTypes: EventAllNullableTypes? = nil,
    list: [Any?]? = nil,
    stringList: [String?]? = nil,
    intList: [Int64?]? = nil,
    doubleList: [Double?]? = nil,
    boolList: [Bool?]? = nil,
    enumList: [EventEnum?]? = nil,
    objectList: [Any?]? = nil,
    listList: [[Any?]?]? = nil,
    mapList: [[AnyHashable?: Any?]?]? = nil,
    recursiveClassList: [EventAllNullableTypes?]? = nil,
    map: [AnyHashable?: Any?]? = nil,
    stringMap: [String?: String?]? = nil,
    intMap: [Int64?: Int64?]? = nil,
    enumMap: [EventEnum?: EventEnum?]? = nil,
    objectMap: [AnyHashable?: Any?]? = nil,
    listMap: [Int64?: [Any?]?]? = nil,
    mapMap: [Int64?: [AnyHashable?: Any?]?]? = nil,
    recursiveClassMap: [Int64?: EventAllNullableTypes?]? = nil
  ) {
    self.aNullableBool = aNullableBool
    self.aNullableInt = aNullableInt
    self.aNullableInt64 = aNullableInt64
    self.aNullableDouble = aNullableDouble
    self.aNullableByteArray = aNullableByteArray
    self.aNullable4ByteArray = aNullable4ByteArray
    self.aNullable8ByteArray = aNullable8ByteArray
    self.aNullableFloatArray = aNullableFloatArray
    self.aNullableEnum = aNullableEnum
    self.anotherNullableEnum = anotherNullableEnum
    self.aNullableString = aNullableString
    self.aNullableObject = aNullableObject
    self.allNullableTypes = allNullableTypes
    self.list = list
    self.stringList = stringList
    self.intList = intList
    self.doubleList = doubleList
    self.boolList = boolList
    self.enumList = enumList
    self.objectList = objectList
    self.listList = listList
    self.mapList = mapList
    self.recursiveClassList = recursiveClassList
    self.map = map
    self.stringMap = stringMap
    self.intMap = intMap
    self.enumMap = enumMap
    self.objectMap = objectMap
    self.listMap = listMap
    self.mapMap = mapMap
    self.recursiveClassMap = recursiveClassMap
  }
  var aNullableBool: Bool?
  var aNullableInt: Int64?
  var aNullableInt64: Int64?
  var aNullableDouble: Double?
  var aNullableByteArray: FlutterStandardTypedData?
  var aNullable4ByteArray: FlutterStandardTypedData?
  var aNullable8ByteArray: FlutterStandardTypedData?
  var aNullableFloatArray: FlutterStandardTypedData?
  var aNullableEnum: EventEnum?
  var anotherNullableEnum: AnotherEventEnum?
  var aNullableString: String?
  var aNullableObject: Any?
  var allNullableTypes: EventAllNullableTypes?
  var list: [Any?]?
  var stringList: [String?]?
  var intList: [Int64?]?
  var doubleList: [Double?]?
  var boolList: [Bool?]?
  var enumList: [EventEnum?]?
  var objectList: [Any?]?
  var listList: [[Any?]?]?
  var mapList: [[AnyHashable?: Any?]?]?
  var recursiveClassList: [EventAllNullableTypes?]?
  var map: [AnyHashable?: Any?]?
  var stringMap: [String?: String?]?
  var intMap: [Int64?: Int64?]?
  var enumMap: [EventEnum?: EventEnum?]?
  var objectMap: [AnyHashable?: Any?]?
  var listMap: [Int64?: [Any?]?]?
  var mapMap: [Int64?: [AnyHashable?: Any?]?]?
  var recursiveClassMap: [Int64?: EventAllNullableTypes?]?

  // swift-format-ignore: AlwaysUseLowerCamelCase
  static func fromList(_ pigeonVar_list: [Any?]) -> EventAllNullableTypes? {
    let aNullableBool: Bool? = nilOrValue(pigeonVar_list[0])
    let aNullableInt: Int64? = nilOrValue(pigeonVar_list[1])
    let aNullableInt64: Int64? = nilOrValue(pigeonVar_list[2])
    let aNullableDouble: Double? = nilOrValue(pigeonVar_list[3])
    let aNullableByteArray: FlutterStandardTypedData? = nilOrValue(pigeonVar_list[4])
    let aNullable4ByteArray: FlutterStandardTypedData? = nilOrValue(pigeonVar_list[5])
    let aNullable8ByteArray: FlutterStandardTypedData? = nilOrValue(pigeonVar_list[6])
    let aNullableFloatArray: FlutterStandardTypedData? = nilOrValue(pigeonVar_list[7])
    let aNullableEnum: EventEnum? = nilOrValue(pigeonVar_list[8])
    let anotherNullableEnum: AnotherEventEnum? = nilOrValue(pigeonVar_list[9])
    let aNullableString: String? = nilOrValue(pigeonVar_list[10])
    let aNullableObject: Any? = pigeonVar_list[11]
    let allNullableTypes: EventAllNullableTypes? = nilOrValue(pigeonVar_list[12])
    let list: [Any?]? = nilOrValue(pigeonVar_list[13])
    let stringList: [String?]? = nilOrValue(pigeonVar_list[14])
    let intList: [Int64?]? = nilOrValue(pigeonVar_list[15])
    let doubleList: [Double?]? = nilOrValue(pigeonVar_list[16])
    let boolList: [Bool?]? = nilOrValue(pigeonVar_list[17])
    let enumList: [EventEnum?]? = nilOrValue(pigeonVar_list[18])
    let objectList: [Any?]? = nilOrValue(pigeonVar_list[19])
    let listList: [[Any?]?]? = nilOrValue(pigeonVar_list[20])
    let mapList: [[AnyHashable?: Any?]?]? = nilOrValue(pigeonVar_list[21])
    let recursiveClassList: [EventAllNullableTypes?]? = nilOrValue(pigeonVar_list[22])
    let map: [AnyHashable?: Any?]? = nilOrValue(pigeonVar_list[23])
    let stringMap: [String?: String?]? = nilOrValue(pigeonVar_list[24])
    let intMap: [Int64?: Int64?]? = nilOrValue(pigeonVar_list[25])
    let enumMap: [EventEnum?: EventEnum?]? = pigeonVar_list[26] as? [EventEnum?: EventEnum?]
    let objectMap: [AnyHashable?: Any?]? = nilOrValue(pigeonVar_list[27])
    let listMap: [Int64?: [Any?]?]? = nilOrValue(pigeonVar_list[28])
    let mapMap: [Int64?: [AnyHashable?: Any?]?]? = nilOrValue(pigeonVar_list[29])
    let recursiveClassMap: [Int64?: EventAllNullableTypes?]? = nilOrValue(pigeonVar_list[30])

    return EventAllNullableTypes(
      aNullableBool: aNullableBool,
      aNullableInt: aNullableInt,
      aNullableInt64: aNullableInt64,
      aNullableDouble: aNullableDouble,
      aNullableByteArray: aNullableByteArray,
      aNullable4ByteArray: aNullable4ByteArray,
      aNullable8ByteArray: aNullable8ByteArray,
      aNullableFloatArray: aNullableFloatArray,
      aNullableEnum: aNullableEnum,
      anotherNullableEnum: anotherNullableEnum,
      aNullableString: aNullableString,
      aNullableObject: aNullableObject,
      allNullableTypes: allNullableTypes,
      list: list,
      stringList: stringList,
      intList: intList,
      doubleList: doubleList,
      boolList: boolList,
      enumList: enumList,
      objectList: objectList,
      listList: listList,
      mapList: mapList,
      recursiveClassList: recursiveClassList,
      map: map,
      stringMap: stringMap,
      intMap: intMap,
      enumMap: enumMap,
      objectMap: objectMap,
      listMap: listMap,
      mapMap: mapMap,
      recursiveClassMap: recursiveClassMap
    )
  }
  func toList() -> [Any?] {
    return [
      aNullableBool,
      aNullableInt,
      aNullableInt64,
      aNullableDouble,
      aNullableByteArray,
      aNullable4ByteArray,
      aNullable8ByteArray,
      aNullableFloatArray,
      aNullableEnum,
      anotherNullableEnum,
      aNullableString,
      aNullableObject,
      allNullableTypes,
      list,
      stringList,
      intList,
      doubleList,
      boolList,
      enumList,
      objectList,
      listList,
      mapList,
      recursiveClassList,
      map,
      stringMap,
      intMap,
      enumMap,
      objectMap,
      listMap,
      mapMap,
      recursiveClassMap,
    ]
  }
  static func == (lhs: EventAllNullableTypes, rhs: EventAllNullableTypes) -> Bool {
    if lhs === rhs {
      return true
    }
    return deepEqualsEventChannelTests(lhs.aNullableBool, rhs.aNullableBool)
      && deepEqualsEventChannelTests(lhs.aNullableInt, rhs.aNullableInt)
      && deepEqualsEventChannelTests(lhs.aNullableInt64, rhs.aNullableInt64)
      && deepEqualsEventChannelTests(lhs.aNullableDouble, rhs.aNullableDouble)
      && deepEqualsEventChannelTests(lhs.aNullableByteArray, rhs.aNullableByteArray)
      && deepEqualsEventChannelTests(lhs.aNullable4ByteArray, rhs.aNullable4ByteArray)
      && deepEqualsEventChannelTests(lhs.aNullable8ByteArray, rhs.aNullable8ByteArray)
      && deepEqualsEventChannelTests(lhs.aNullableFloatArray, rhs.aNullableFloatArray)
      && deepEqualsEventChannelTests(lhs.aNullableEnum, rhs.aNullableEnum)
      && deepEqualsEventChannelTests(lhs.anotherNullableEnum, rhs.anotherNullableEnum)
      && deepEqualsEventChannelTests(lhs.aNullableString, rhs.aNullableString)
      && deepEqualsEventChannelTests(lhs.aNullableObject, rhs.aNullableObject)
      && deepEqualsEventChannelTests(lhs.allNullableTypes, rhs.allNullableTypes)
      && deepEqualsEventChannelTests(lhs.list, rhs.list)
      && deepEqualsEventChannelTests(lhs.stringList, rhs.stringList)
      && deepEqualsEventChannelTests(lhs.intList, rhs.intList)
      && deepEqualsEventChannelTests(lhs.doubleList, rhs.doubleList)
      && deepEqualsEventChannelTests(lhs.boolList, rhs.boolList)
      && deepEqualsEventChannelTests(lhs.enumList, rhs.enumList)
      && deepEqualsEventChannelTests(lhs.objectList, rhs.objectList)
      && deepEqualsEventChannelTests(lhs.listList, rhs.listList)
      && deepEqualsEventChannelTests(lhs.mapList, rhs.mapList)
      && deepEqualsEventChannelTests(lhs.recursiveClassList, rhs.recursiveClassList)
      && deepEqualsEventChannelTests(lhs.map, rhs.map)
      && deepEqualsEventChannelTests(lhs.stringMap, rhs.stringMap)
      && deepEqualsEventChannelTests(lhs.intMap, rhs.intMap)
      && deepEqualsEventChannelTests(lhs.enumMap, rhs.enumMap)
      && deepEqualsEventChannelTests(lhs.objectMap, rhs.objectMap)
      && deepEqualsEventChannelTests(lhs.listMap, rhs.listMap)
      && deepEqualsEventChannelTests(lhs.mapMap, rhs.mapMap)
      && deepEqualsEventChannelTests(lhs.recursiveClassMap, rhs.recursiveClassMap)
  }
  func hash(into hasher: inout Hasher) {
    deepHashEventChannelTests(value: aNullableBool, hasher: &hasher)
    deepHashEventChannelTests(value: aNullableInt, hasher: &hasher)
    deepHashEventChannelTests(value: aNullableInt64, hasher: &hasher)
    deepHashEventChannelTests(value: aNullableDouble, hasher: &hasher)
    deepHashEventChannelTests(value: aNullableByteArray, hasher: &hasher)
    deepHashEventChannelTests(value: aNullable4ByteArray, hasher: &hasher)
    deepHashEventChannelTests(value: aNullable8ByteArray, hasher: &hasher)
    deepHashEventChannelTests(value: aNullableFloatArray, hasher: &hasher)
    deepHashEventChannelTests(value: aNullableEnum, hasher: &hasher)
    deepHashEventChannelTests(value: anotherNullableEnum, hasher: &hasher)
    deepHashEventChannelTests(value: aNullableString, hasher: &hasher)
    deepHashEventChannelTests(value: aNullableObject, hasher: &hasher)
    deepHashEventChannelTests(value: allNullableTypes, hasher: &hasher)
    deepHashEventChannelTests(value: list, hasher: &hasher)
    deepHashEventChannelTests(value: stringList, hasher: &hasher)
    deepHashEventChannelTests(value: intList, hasher: &hasher)
    deepHashEventChannelTests(value: doubleList, hasher: &hasher)
    deepHashEventChannelTests(value: boolList, hasher: &hasher)
    deepHashEventChannelTests(value: enumList, hasher: &hasher)
    deepHashEventChannelTests(value: objectList, hasher: &hasher)
    deepHashEventChannelTests(value: listList, hasher: &hasher)
    deepHashEventChannelTests(value: mapList, hasher: &hasher)
    deepHashEventChannelTests(value: recursiveClassList, hasher: &hasher)
    deepHashEventChannelTests(value: map, hasher: &hasher)
    deepHashEventChannelTests(value: stringMap, hasher: &hasher)
    deepHashEventChannelTests(value: intMap, hasher: &hasher)
    deepHashEventChannelTests(value: enumMap, hasher: &hasher)
    deepHashEventChannelTests(value: objectMap, hasher: &hasher)
    deepHashEventChannelTests(value: listMap, hasher: &hasher)
    deepHashEventChannelTests(value: mapMap, hasher: &hasher)
    deepHashEventChannelTests(value: recursiveClassMap, hasher: &hasher)
  }
}

/// Generated class from Pigeon that represents data sent in messages.
/// This protocol should not be extended by any user class outside of the generated file.
protocol PlatformEvent {

}

/// Generated class from Pigeon that represents data sent in messages.
struct IntEvent: PlatformEvent {
  var value: Int64

  // swift-format-ignore: AlwaysUseLowerCamelCase
  static func fromList(_ pigeonVar_list: [Any?]) -> IntEvent? {
    let value = pigeonVar_list[0] as! Int64

    return IntEvent(
      value: value
    )
  }
  func toList() -> [Any?] {
    return [
      value
    ]
  }
  static func == (lhs: IntEvent, rhs: IntEvent) -> Bool {
    return deepEqualsEventChannelTests(lhs.value, rhs.value)
  }
  func hash(into hasher: inout Hasher) {
    deepHashEventChannelTests(value: value, hasher: &hasher)
  }
}

/// Generated class from Pigeon that represents data sent in messages.
struct StringEvent: PlatformEvent {
  var value: String

  // swift-format-ignore: AlwaysUseLowerCamelCase
  static func fromList(_ pigeonVar_list: [Any?]) -> StringEvent? {
    let value = pigeonVar_list[0] as! String

    return StringEvent(
      value: value
    )
  }
  func toList() -> [Any?] {
    return [
      value
    ]
  }
  static func == (lhs: StringEvent, rhs: StringEvent) -> Bool {
    return deepEqualsEventChannelTests(lhs.value, rhs.value)
  }
  func hash(into hasher: inout Hasher) {
    deepHashEventChannelTests(value: value, hasher: &hasher)
  }
}

/// Generated class from Pigeon that represents data sent in messages.
struct BoolEvent: PlatformEvent {
  var value: Bool

  // swift-format-ignore: AlwaysUseLowerCamelCase
  static func fromList(_ pigeonVar_list: [Any?]) -> BoolEvent? {
    let value = pigeonVar_list[0] as! Bool

    return BoolEvent(
      value: value
    )
  }
  func toList() -> [Any?] {
    return [
      value
    ]
  }
  static func == (lhs: BoolEvent, rhs: BoolEvent) -> Bool {
    return deepEqualsEventChannelTests(lhs.value, rhs.value)
  }
  func hash(into hasher: inout Hasher) {
    deepHashEventChannelTests(value: value, hasher: &hasher)
  }
}

/// Generated class from Pigeon that represents data sent in messages.
struct DoubleEvent: PlatformEvent {
  var value: Double

  // swift-format-ignore: AlwaysUseLowerCamelCase
  static func fromList(_ pigeonVar_list: [Any?]) -> DoubleEvent? {
    let value = pigeonVar_list[0] as! Double

    return DoubleEvent(
      value: value
    )
  }
  func toList() -> [Any?] {
    return [
      value
    ]
  }
  static func == (lhs: DoubleEvent, rhs: DoubleEvent) -> Bool {
    return deepEqualsEventChannelTests(lhs.value, rhs.value)
  }
  func hash(into hasher: inout Hasher) {
    deepHashEventChannelTests(value: value, hasher: &hasher)
  }
}

/// Generated class from Pigeon that represents data sent in messages.
struct ObjectsEvent: PlatformEvent {
  var value: Any

  // swift-format-ignore: AlwaysUseLowerCamelCase
  static func fromList(_ pigeonVar_list: [Any?]) -> ObjectsEvent? {
    let value = pigeonVar_list[0]!

    return ObjectsEvent(
      value: value
    )
  }
  func toList() -> [Any?] {
    return [
      value
    ]
  }
  static func == (lhs: ObjectsEvent, rhs: ObjectsEvent) -> Bool {
    return deepEqualsEventChannelTests(lhs.value, rhs.value)
  }
  func hash(into hasher: inout Hasher) {
    deepHashEventChannelTests(value: value, hasher: &hasher)
  }
}

/// Generated class from Pigeon that represents data sent in messages.
struct EnumEvent: PlatformEvent {
  var value: EventEnum

  // swift-format-ignore: AlwaysUseLowerCamelCase
  static func fromList(_ pigeonVar_list: [Any?]) -> EnumEvent? {
    let value = pigeonVar_list[0] as! EventEnum

    return EnumEvent(
      value: value
    )
  }
  func toList() -> [Any?] {
    return [
      value
    ]
  }
  static func == (lhs: EnumEvent, rhs: EnumEvent) -> Bool {
    return deepEqualsEventChannelTests(lhs.value, rhs.value)
  }
  func hash(into hasher: inout Hasher) {
    deepHashEventChannelTests(value: value, hasher: &hasher)
  }
}

/// Generated class from Pigeon that represents data sent in messages.
struct ClassEvent: PlatformEvent {
  var value: EventAllNullableTypes

  // swift-format-ignore: AlwaysUseLowerCamelCase
  static func fromList(_ pigeonVar_list: [Any?]) -> ClassEvent? {
    let value = pigeonVar_list[0] as! EventAllNullableTypes

    return ClassEvent(
      value: value
    )
  }
  func toList() -> [Any?] {
    return [
      value
    ]
  }
  static func == (lhs: ClassEvent, rhs: ClassEvent) -> Bool {
    return deepEqualsEventChannelTests(lhs.value, rhs.value)
  }
  func hash(into hasher: inout Hasher) {
    deepHashEventChannelTests(value: value, hasher: &hasher)
  }
}

private class EventChannelTestsPigeonCodecReader: FlutterStandardReader {
  override func readValue(ofType type: UInt8) -> Any? {
    switch type {
    case 129:
      let enumResultAsInt: Int? = nilOrValue(self.readValue() as! Int?)
      if let enumResultAsInt = enumResultAsInt {
        return EventEnum(rawValue: enumResultAsInt)
      }
      return nil
    case 130:
      let enumResultAsInt: Int? = nilOrValue(self.readValue() as! Int?)
      if let enumResultAsInt = enumResultAsInt {
        return AnotherEventEnum(rawValue: enumResultAsInt)
      }
      return nil
    case 131:
      return EventAllNullableTypes.fromList(self.readValue() as! [Any?])
    case 132:
      return IntEvent.fromList(self.readValue() as! [Any?])
    case 133:
      return StringEvent.fromList(self.readValue() as! [Any?])
    case 134:
      return BoolEvent.fromList(self.readValue() as! [Any?])
    case 135:
      return DoubleEvent.fromList(self.readValue() as! [Any?])
    case 136:
      return ObjectsEvent.fromList(self.readValue() as! [Any?])
    case 137:
      return EnumEvent.fromList(self.readValue() as! [Any?])
    case 138:
      return ClassEvent.fromList(self.readValue() as! [Any?])
    default:
      return super.readValue(ofType: type)
    }
  }
}

private class EventChannelTestsPigeonCodecWriter: FlutterStandardWriter {
  override func writeValue(_ value: Any) {
    if let value = value as? EventEnum {
      super.writeByte(129)
      super.writeValue(value.rawValue)
    } else if let value = value as? AnotherEventEnum {
      super.writeByte(130)
      super.writeValue(value.rawValue)
    } else if let value = value as? EventAllNullableTypes {
      super.writeByte(131)
      super.writeValue(value.toList())
    } else if let value = value as? IntEvent {
      super.writeByte(132)
      super.writeValue(value.toList())
    } else if let value = value as? StringEvent {
      super.writeByte(133)
      super.writeValue(value.toList())
    } else if let value = value as? BoolEvent {
      super.writeByte(134)
      super.writeValue(value.toList())
    } else if let value = value as? DoubleEvent {
      super.writeByte(135)
      super.writeValue(value.toList())
    } else if let value = value as? ObjectsEvent {
      super.writeByte(136)
      super.writeValue(value.toList())
    } else if let value = value as? EnumEvent {
      super.writeByte(137)
      super.writeValue(value.toList())
    } else if let value = value as? ClassEvent {
      super.writeByte(138)
      super.writeValue(value.toList())
    } else {
      super.writeValue(value)
    }
  }
}

private class EventChannelTestsPigeonCodecReaderWriter: FlutterStandardReaderWriter {
  override func reader(with data: Data) -> FlutterStandardReader {
    return EventChannelTestsPigeonCodecReader(data: data)
  }

  override func writer(with data: NSMutableData) -> FlutterStandardWriter {
    return EventChannelTestsPigeonCodecWriter(data: data)
  }
}

class EventChannelTestsPigeonCodec: FlutterStandardMessageCodec, @unchecked Sendable {
  static let shared = EventChannelTestsPigeonCodec(
    readerWriter: EventChannelTestsPigeonCodecReaderWriter())
}

var eventChannelTestsPigeonMethodCodec = FlutterStandardMethodCodec(
  readerWriter: EventChannelTestsPigeonCodecReaderWriter())

private class PigeonStreamHandler<ReturnType>: NSObject, FlutterStreamHandler {
  private let wrapper: PigeonEventChannelWrapper<ReturnType>
  private var pigeonSink: PigeonEventSink<ReturnType>? = nil

  init(wrapper: PigeonEventChannelWrapper<ReturnType>) {
    self.wrapper = wrapper
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    pigeonSink = PigeonEventSink<ReturnType>(events)
    wrapper.onListen(withArguments: arguments, sink: pigeonSink!)
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    pigeonSink = nil
    wrapper.onCancel(withArguments: arguments)
    return nil
  }
}

class PigeonEventChannelWrapper<ReturnType> {
  func onListen(withArguments arguments: Any?, sink: PigeonEventSink<ReturnType>) {}
  func onCancel(withArguments arguments: Any?) {}
}

class PigeonEventSink<ReturnType> {
  private let sink: FlutterEventSink

  init(_ sink: @escaping FlutterEventSink) {
    self.sink = sink
  }

  func success(_ value: ReturnType) {
    sink(value)
  }

  func error(code: String, message: String?, details: Any?) {
    sink(FlutterError(code: code, message: message, details: details))
  }

  func endOfStream() {
    sink(FlutterEndOfEventStream)
  }

}

class StreamIntsStreamHandler: PigeonEventChannelWrapper<Int64> {
  static func register(
    with messenger: FlutterBinaryMessenger,
    instanceName: String = "",
    streamHandler: StreamIntsStreamHandler
  ) {
    var channelName = "dev.flutter.pigeon.pigeon_integration_tests.EventChannelMethods.streamInts"
    if !instanceName.isEmpty {
      channelName += ".\(instanceName)"
    }
    let internalStreamHandler = PigeonStreamHandler<Int64>(wrapper: streamHandler)
    let channel = FlutterEventChannel(
      name: channelName, binaryMessenger: messenger, codec: eventChannelTestsPigeonMethodCodec)
    channel.setStreamHandler(internalStreamHandler)
  }
}

class StreamEventsStreamHandler: PigeonEventChannelWrapper<PlatformEvent> {
  static func register(
    with messenger: FlutterBinaryMessenger,
    instanceName: String = "",
    streamHandler: StreamEventsStreamHandler
  ) {
    var channelName = "dev.flutter.pigeon.pigeon_integration_tests.EventChannelMethods.streamEvents"
    if !instanceName.isEmpty {
      channelName += ".\(instanceName)"
    }
    let internalStreamHandler = PigeonStreamHandler<PlatformEvent>(wrapper: streamHandler)
    let channel = FlutterEventChannel(
      name: channelName, binaryMessenger: messenger, codec: eventChannelTestsPigeonMethodCodec)
    channel.setStreamHandler(internalStreamHandler)
  }
}

class StreamConsistentNumbersStreamHandler: PigeonEventChannelWrapper<Int64> {
  static func register(
    with messenger: FlutterBinaryMessenger,
    instanceName: String = "",
    streamHandler: StreamConsistentNumbersStreamHandler
  ) {
    var channelName =
      "dev.flutter.pigeon.pigeon_integration_tests.EventChannelMethods.streamConsistentNumbers"
    if !instanceName.isEmpty {
      channelName += ".\(instanceName)"
    }
    let internalStreamHandler = PigeonStreamHandler<Int64>(wrapper: streamHandler)
    let channel = FlutterEventChannel(
      name: channelName, binaryMessenger: messenger, codec: eventChannelTestsPigeonMethodCodec)
    channel.setStreamHandler(internalStreamHandler)
  }
}

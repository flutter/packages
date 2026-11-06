// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Testing

@testable import test_plugin

class MyApi: HostTrivialApi {
  func noop() {}
}

final class FakeClassReservedApi: NativeInteropReservedNamesHostApi {
  let label: String
  init(_ label: String) { self.label = label }
  func release(value: String) throws -> String { "\(label):\(value)" }
  func use(value: Int64) throws -> Int64 { value }
  func type() throws -> String { label }
  func isNull() throws -> Bool { false }
  func isNullable() throws -> Bool? { nil }
  func isOpen() throws -> Bool { true }
  func getReference() throws -> String { label }
  func setReference(value: String) throws {}
  func getDefault() throws -> String { label }
  func getValueAsync() async throws -> String { label }
  func register(value: String) throws -> String { "\(label):\(value)" }
  func unregister(value: String) throws -> String { "\(label):\(value)" }
  func getGetInstance() throws -> String { label }
  func echoReservedNames(names: NativeInteropReservedNames) throws -> NativeInteropReservedNames {
    names
  }
  func callFlutterRelease(value: String) throws -> String { value }
  func callFlutterType() throws -> String { label }
  func callFlutterImplementIn(value: String) throws -> String { value }
  func callFlutterIsNull() throws -> Bool { false }
  func callFlutterGetReference() throws -> String { label }
  func callFlutterRegister(value: String) throws -> String { value }
  func callFlutterDartApi() throws -> String { label }
}

// Tests macOS compilation and Native Interop HostApi multi-instance registration/deregistration.
@Suite(.serialized)
struct BasicCompileTest {
  @Test
  func makeApi() {
    let api = MyApi()
    #expect(api as Any? != nil)
  }

  @Test
  func classUnregisterRemovesSpecificInstanceOutOfOrder() throws {
    let name = "macosOutOfOrderClass"
    let api1 = FakeClassReservedApi("engine1")
    let api2 = FakeClassReservedApi("engine2")

    NativeInteropReservedNamesHostApiSetup.register(api: api1, name: name)
    let setup1 = try #require(NativeInteropReservedNamesHostApiSetup.getInstance(name: name))
    NativeInteropReservedNamesHostApiSetup.register(api: api2, name: name)
    #expect(
      NativeInteropReservedNamesHostApiSetup.getInstance(name: name)?.release(
        value: "ping", wrappedError: NativeInteropTestsError()) == "engine2:ping")

    // Unregistering api1 out-of-order keeps api2 registered while detached setup1 reports an error
    // instead of trapping.
    NativeInteropReservedNamesHostApiSetup.unregister(api: api1, name: name)
    let staleError = NativeInteropTestsError()
    #expect(setup1.release(value: "ping", wrappedError: staleError) == nil)
    #expect(staleError.code == "unregistered-instance")
    #expect(
      NativeInteropReservedNamesHostApiSetup.getInstance(name: name)?.release(
        value: "ping", wrappedError: NativeInteropTestsError()) == "engine2:ping")

    NativeInteropReservedNamesHostApiSetup.unregister(api: api2, name: name)
    #expect(NativeInteropReservedNamesHostApiSetup.getInstance(name: name) == nil)
  }

  @Test
  func defaultNilNameAndExplicitEmptyStringNameAreDistinct() throws {
    let preexistingDefault = NativeInteropReservedNamesHostApiSetup.getInstance()
    let defaultApi = FakeClassReservedApi("defaultEngine")
    let emptyNameApi = FakeClassReservedApi("emptyStringEngine")

    NativeInteropReservedNamesHostApiSetup.register(api: defaultApi)
    #expect(NativeInteropReservedNamesHostApiSetup.getInstance(name: "") == nil)

    NativeInteropReservedNamesHostApiSetup.register(api: emptyNameApi, name: "")
    #expect(
      NativeInteropReservedNamesHostApiSetup.getInstance()?.release(
        value: "ping", wrappedError: NativeInteropTestsError()) == "defaultEngine:ping")
    #expect(
      NativeInteropReservedNamesHostApiSetup.getInstance(name: "")?.release(
        value: "ping", wrappedError: NativeInteropTestsError()) == "emptyStringEngine:ping")

    NativeInteropReservedNamesHostApiSetup.unregister(api: emptyNameApi, name: "")
    #expect(NativeInteropReservedNamesHostApiSetup.getInstance(name: "") == nil)
    #expect(
      NativeInteropReservedNamesHostApiSetup.getInstance()?.release(
        value: "ping", wrappedError: NativeInteropTestsError()) == "defaultEngine:ping")

    NativeInteropReservedNamesHostApiSetup.unregister(api: defaultApi)
    #expect(NativeInteropReservedNamesHostApiSetup.getInstance() === preexistingDefault)
  }

  @Test
  func pluginDetachPreservesOtherEngineRegistrations() {
    let preexistingSetup = NativeInteropHostIntegrationCoreApiSetup.getInstance()
    let registrar1 = StubPluginRegistrar()
    let registrar2 = StubPluginRegistrar()
    TestPlugin.register(with: registrar1)
    let setup1 = NativeInteropHostIntegrationCoreApiSetup.getInstance()
    #expect(setup1 != nil)
    #expect(setup1 !== preexistingSetup)

    TestPlugin.register(with: registrar2)
    let setup2 = NativeInteropHostIntegrationCoreApiSetup.getInstance()
    #expect(setup2 != nil)
    #expect(setup2 !== setup1)

    let plugin1 = registrar1.published as? TestPlugin
    let plugin2 = registrar2.published as? TestPlugin
    #expect(plugin1 != nil)
    #expect(plugin2 != nil)

    // Detaching plugin1 out-of-order leaves plugin2's registration active at top of stack.
    plugin1?.detachFromEngine(for: registrar1)
    #expect(NativeInteropHostIntegrationCoreApiSetup.getInstance() === setup2)

    // Detaching plugin2 restores whatever state existed prior to registrar1/registrar2.
    plugin2?.detachFromEngine(for: registrar2)
    #expect(NativeInteropHostIntegrationCoreApiSetup.getInstance() === preexistingSetup)
  }

  @Test
  @MainActor
  func realFlutterEnginesOutOfOrderTeardownPreservesRegistrations() {
    #expect(SecondaryEngineTestRunner.verifyRealSecondaryEnginesOnMain())
  }

  @Test
  @MainActor
  func liveSecondaryEnginesExecuteDartIsolatesAcrossOutOfOrderTeardown() async {
    #expect(await SecondaryEngineTestRunner.verifyMacOSLiveSecondaryEnginesWithEntrypoint())
  }

  @Test
  func flutterApiRegistrarOutOfOrderUnregisterPreservesOtherEngineRegistrations() throws {
    let name = "unitTestFlutterApiStack"
    let bridge1 = FakeReservedNamesFlutterApiBridge("engine1")
    let bridge2 = FakeReservedNamesFlutterApiBridge("engine2")
    let neverRegistered = FakeReservedNamesFlutterApiBridge("never")

    NativeInteropReservedNamesFlutterApiRegistrar.register(api: bridge1, name: name)
    NativeInteropReservedNamesFlutterApiRegistrar.register(api: bridge2, name: name)
    #expect(
      try NativeInteropReservedNamesFlutterApi.getInstance(name: name)?.release(value: "ping")
        == "engine2:ping")

    // Out-of-order unregister of bridge1 leaves bridge2 active.
    NativeInteropReservedNamesFlutterApiRegistrar.unregister(api: bridge1, name: name)
    // Duplicate unregister and never-registered unregister must be safe no-ops.
    NativeInteropReservedNamesFlutterApiRegistrar.unregister(api: bridge1, name: name)
    NativeInteropReservedNamesFlutterApiRegistrar.unregister(
      api: neverRegistered, name: name)
    #expect(
      try NativeInteropReservedNamesFlutterApi.getInstance(name: name)?.release(value: "ping")
        == "engine2:ping")

    NativeInteropReservedNamesFlutterApiRegistrar.unregister(api: bridge2, name: name)
    #expect(NativeInteropReservedNamesFlutterApi.getInstance(name: name) == nil)
  }

  @Test
  func flutterApiReRegisteringSameInstanceDeduplicatesAndMovesToTop() throws {
    let name = "unitTestFlutterApiDeduplicate"
    let bridge1 = FakeReservedNamesFlutterApiBridge("engine1")
    let bridge2 = FakeReservedNamesFlutterApiBridge("engine2")

    NativeInteropReservedNamesFlutterApiRegistrar.register(api: bridge1, name: name)
    NativeInteropReservedNamesFlutterApiRegistrar.register(api: bridge2, name: name)
    NativeInteropReservedNamesFlutterApiRegistrar.register(api: bridge1, name: name)

    #expect(
      try NativeInteropReservedNamesFlutterApi.getInstance(name: name)?.release(value: "ping")
        == "engine1:ping")

    // Since bridge1 was deduplicated, unregistering bridge1 once leaves only bridge2.
    NativeInteropReservedNamesFlutterApiRegistrar.unregister(api: bridge1, name: name)
    #expect(
      try NativeInteropReservedNamesFlutterApi.getInstance(name: name)?.release(value: "ping")
        == "engine2:ping")

    NativeInteropReservedNamesFlutterApiRegistrar.unregister(api: bridge2, name: name)
    #expect(NativeInteropReservedNamesFlutterApi.getInstance(name: name) == nil)
  }

  @Test
  func flutterApiDefaultNilNameAndExplicitEmptyStringNameAreDistinct() throws {
    let preexistingDefault = NativeInteropReservedNamesFlutterApiRegistrar.getInstance()
    let defaultBridge = FakeReservedNamesFlutterApiBridge("defaultFlutter")
    let emptyNameBridge = FakeReservedNamesFlutterApiBridge("emptyStringFlutter")

    NativeInteropReservedNamesFlutterApiRegistrar.register(api: defaultBridge)
    #expect(NativeInteropReservedNamesFlutterApi.getInstance(name: "") == nil)

    NativeInteropReservedNamesFlutterApiRegistrar.register(api: emptyNameBridge, name: "")
    #expect(
      try NativeInteropReservedNamesFlutterApi.getInstance()?.release(value: "ping")
        == "defaultFlutter:ping")
    #expect(
      try NativeInteropReservedNamesFlutterApi.getInstance(name: "")?.release(value: "ping")
        == "emptyStringFlutter:ping")

    NativeInteropReservedNamesFlutterApiRegistrar.unregister(api: emptyNameBridge, name: "")
    #expect(NativeInteropReservedNamesFlutterApi.getInstance(name: "") == nil)
    #expect(
      try NativeInteropReservedNamesFlutterApi.getInstance()?.release(value: "ping")
        == "defaultFlutter:ping")

    NativeInteropReservedNamesFlutterApiRegistrar.unregister(api: defaultBridge)
    #expect(NativeInteropReservedNamesFlutterApiRegistrar.getInstance() === preexistingDefault)
  }
}

@objc
final class FakeReservedNamesFlutterApiBridge: NSObject,
  NativeInteropReservedNamesFlutterApiBridge
{
  let label: String
  init(_ label: String) { self.label = label }
  func release(value valueArg: NSString?, error: NativeInteropTestsError) -> NSString? {
    "\(label):\(valueArg ?? "")" as NSString
  }
  func type(error: NativeInteropTestsError) -> NSString? { label as NSString }
  func implementIn(value valueArg: NSString?, error: NativeInteropTestsError) -> NSString? {
    "\(label):\(valueArg ?? "")" as NSString
  }
  func isNull(error: NativeInteropTestsError) -> NSNumber? { NSNumber(value: false) }
  func getReference(error: NativeInteropTestsError) -> NSString? { label as NSString }
  func register(value valueArg: NSString?, error: NativeInteropTestsError) -> NSString? {
    "\(label):\(valueArg ?? "")" as NSString
  }
  func dartApi(error: NativeInteropTestsError) -> NSString? { label as NSString }
}

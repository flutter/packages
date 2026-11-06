// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
  func echoReservedNames(names: NativeInteropReservedNames) throws -> NativeInteropReservedNames {
    names
  }
  func callFlutterRelease(value: String) throws -> String { value }
  func callFlutterType() throws -> String { label }
  func callFlutterImplementIn(value: String) throws -> String { value }
  func callFlutterIsNull() throws -> Bool { false }
  func callFlutterGetReference() throws -> String { label }
}

struct FakeStructReservedApi: NativeInteropReservedNamesHostApi {
  let label: String
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
  func echoReservedNames(names: NativeInteropReservedNames) throws -> NativeInteropReservedNames {
    names
  }
  func callFlutterRelease(value: String) throws -> String { value }
  func callFlutterType() throws -> String { label }
  func callFlutterImplementIn(value: String) throws -> String { value }
  func callFlutterIsNull() throws -> Bool { false }
  func callFlutterGetReference() throws -> String { label }
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
  func classUnregisterRemovesSpecificInstanceOutOfOrder() {
    let name = "macosOutOfOrderClass"
    let api1 = FakeClassReservedApi("engine1")
    let api2 = FakeClassReservedApi("engine2")

    let setup1 = NativeInteropReservedNamesHostApiSetup.register(api: api1, name: name)!
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
  func setupHandleUnregisterWorksForValueTypes() {
    let name = "macosStructSetupHandle"
    let setup1 = NativeInteropReservedNamesHostApiSetup.register(
      api: FakeStructReservedApi(label: "struct1"), name: name)!
    let setup2 = NativeInteropReservedNamesHostApiSetup.register(
      api: FakeStructReservedApi(label: "struct2"), name: name)!

    NativeInteropReservedNamesHostApiSetup.unregister(setup: setup1, name: name)
    #expect(
      NativeInteropReservedNamesHostApiSetup.getInstance(name: name)?.release(
        value: "ping", wrappedError: NativeInteropTestsError()) == "struct2:ping")

    NativeInteropReservedNamesHostApiSetup.unregister(setup: setup2, name: name)
    #expect(NativeInteropReservedNamesHostApiSetup.getInstance(name: name) == nil)
  }

  @Test
  func registerNilPopsLastInstanceWithoutClearingEarlierEngines() {
    let name = "macosLifoNil"
    let api1 = FakeClassReservedApi("engine1")
    let api2 = FakeClassReservedApi("engine2")

    NativeInteropReservedNamesHostApiSetup.register(api: api1, name: name)
    NativeInteropReservedNamesHostApiSetup.register(api: api2, name: name)

    NativeInteropReservedNamesHostApiSetup.register(api: nil, name: name)
    #expect(
      NativeInteropReservedNamesHostApiSetup.getInstance(name: name)?.release(
        value: "ping", wrappedError: NativeInteropTestsError()) == "engine1:ping")

    NativeInteropReservedNamesHostApiSetup.register(api: nil, name: name)
    #expect(NativeInteropReservedNamesHostApiSetup.getInstance(name: name) == nil)
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
}

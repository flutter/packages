// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FlutterMacOS
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
    let stub = StubPluginRegistrar()
    let name = "macosOutOfOrderClass"
    let api1 = FakeClassReservedApi("engine1")
    let api2 = FakeClassReservedApi("engine2")

    NativeInteropReservedNamesHostApiSetup.register(api: api1, registrar: stub, name: name)
    let setup1 = try #require(NativeInteropReservedNamesHostApiSetup.getInstance(name: name))
    NativeInteropReservedNamesHostApiSetup.register(api: api2, registrar: stub, name: name)
    #expect(
      NativeInteropReservedNamesHostApiSetup.getInstance(name: name)?.release(
        value: "ping", wrappedError: NativeInteropTestsError()) == "engine2:ping")

    // Unregistering api1 out-of-order keeps api2 registered while detached setup1 reports an error
    // instead of trapping.
    NativeInteropReservedNamesHostApiSetup.unregister(api: api1, registrar: stub, name: name)
    let staleError = NativeInteropTestsError()
    #expect(setup1.release(value: "ping", wrappedError: staleError) == nil)
    #expect(staleError.code == "unregistered-instance")
    #expect(
      NativeInteropReservedNamesHostApiSetup.getInstance(name: name)?.release(
        value: "ping", wrappedError: NativeInteropTestsError()) == "engine2:ping")

    NativeInteropReservedNamesHostApiSetup.unregister(api: api2, registrar: stub, name: name)
    #expect(NativeInteropReservedNamesHostApiSetup.getInstance(name: name) == nil)
  }

  @Test
  func reRegisteringSameApiMovesExistingSetupToTop() throws {
    let stub = StubPluginRegistrar()
    let name = "macosReRegisterClass"
    let api1 = FakeClassReservedApi("engine1")
    let api2 = FakeClassReservedApi("engine2")

    NativeInteropReservedNamesHostApiSetup.register(api: api1, registrar: stub, name: name)
    let setup1 = try #require(NativeInteropReservedNamesHostApiSetup.getInstance(name: name))
    NativeInteropReservedNamesHostApiSetup.register(api: api2, registrar: stub, name: name)
    let setup2 = try #require(NativeInteropReservedNamesHostApiSetup.getInstance(name: name))
    #expect(setup2 !== setup1)

    // Re-registering api1 reuses its existing setup, so handles that already resolved it keep
    // working.
    NativeInteropReservedNamesHostApiSetup.register(api: api1, registrar: stub, name: name)
    #expect(NativeInteropReservedNamesHostApiSetup.getInstance(name: name) === setup1)
    let error = NativeInteropTestsError()
    #expect(setup1.release(value: "ping", wrappedError: error) == "engine1:ping")
    #expect(error.code == nil)

    // api1 is only registered once, so a single unregister falls back to api2.
    NativeInteropReservedNamesHostApiSetup.unregister(api: api1, registrar: stub, name: name)
    #expect(NativeInteropReservedNamesHostApiSetup.getInstance(name: name) === setup2)

    NativeInteropReservedNamesHostApiSetup.unregister(api: api2, registrar: stub, name: name)
    #expect(NativeInteropReservedNamesHostApiSetup.getInstance(name: name) == nil)
  }

  @Test
  func defaultNameAndExplicitEmptyStringNameAreDistinct() throws {
    let stub = StubPluginRegistrar()
    let preexistingDefault = NativeInteropReservedNamesHostApiSetup.getInstance()
    let defaultApi = FakeClassReservedApi("defaultEngine")
    let emptyNameApi = FakeClassReservedApi("emptyStringEngine")

    NativeInteropReservedNamesHostApiSetup.register(api: defaultApi, registrar: stub)
    #expect(NativeInteropReservedNamesHostApiSetup.getInstance(name: "") == nil)

    NativeInteropReservedNamesHostApiSetup.register(api: emptyNameApi, registrar: stub, name: "")
    #expect(
      NativeInteropReservedNamesHostApiSetup.getInstance()?.release(
        value: "ping", wrappedError: NativeInteropTestsError()) == "defaultEngine:ping")
    #expect(
      NativeInteropReservedNamesHostApiSetup.getInstance(name: "")?.release(
        value: "ping", wrappedError: NativeInteropTestsError()) == "emptyStringEngine:ping")

    NativeInteropReservedNamesHostApiSetup.unregister(api: emptyNameApi, registrar: stub, name: "")
    #expect(NativeInteropReservedNamesHostApiSetup.getInstance(name: "") == nil)
    #expect(
      NativeInteropReservedNamesHostApiSetup.getInstance()?.release(
        value: "ping", wrappedError: NativeInteropTestsError()) == "defaultEngine:ping")

    NativeInteropReservedNamesHostApiSetup.unregister(api: defaultApi, registrar: stub)
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
    let stub = StubPluginRegistrar()
    let name = "unitTestFlutterApiStack"
    let bridge1 = FakeReservedNamesFlutterApiBridge("engine1")
    let bridge2 = FakeReservedNamesFlutterApiBridge("engine2")
    let neverRegistered = FakeReservedNamesFlutterApiBridge("never")

    NativeInteropReservedNamesFlutterApiRegistrar.registerInstance(
      api: bridge1, engineId: stub.engineIdentifier, affinityKey: Int64.min, name: name)
    NativeInteropReservedNamesFlutterApiRegistrar.registerInstance(
      api: bridge2, engineId: stub.engineIdentifier, affinityKey: Int64.min, name: name)
    #expect(
      try NativeInteropReservedNamesFlutterApiRegistrar.getInstance(registrar: stub, name: name)?
        .release(value: "ping")
        == "engine2:ping")

    // Out-of-order unregister of bridge1 leaves bridge2 active.
    NativeInteropReservedNamesFlutterApiRegistrar.unregisterInstance(api: bridge1, name: name)
    // Duplicate unregister and never-registered unregister must be safe no-ops.
    NativeInteropReservedNamesFlutterApiRegistrar.unregisterInstance(api: bridge1, name: name)
    NativeInteropReservedNamesFlutterApiRegistrar.unregisterInstance(
      api: neverRegistered, name: name)
    #expect(
      try NativeInteropReservedNamesFlutterApiRegistrar.getInstance(registrar: stub, name: name)?
        .release(value: "ping")
        == "engine2:ping")

    NativeInteropReservedNamesFlutterApiRegistrar.unregisterInstance(api: bridge2, name: name)
    #expect(
      NativeInteropReservedNamesFlutterApiRegistrar.getInstance(registrar: stub, name: name) == nil)
  }

  @Test
  func flutterApiReRegisteringSameInstanceUpdatesKeysInPlace() throws {
    let stub = StubPluginRegistrar()
    let other = StubPluginRegistrar()
    let name = "unitTestFlutterApiDeduplicate"
    let bridge1 = FakeReservedNamesFlutterApiBridge("engine1")
    let bridge2 = FakeReservedNamesFlutterApiBridge("engine2")

    NativeInteropReservedNamesFlutterApiRegistrar.registerInstance(
      api: bridge1, engineId: Int64.min, affinityKey: Int64.min, name: name)
    NativeInteropReservedNamesFlutterApiRegistrar.registerInstance(
      api: bridge2, engineId: Int64.min, affinityKey: Int64.min, name: name)
    // Re-sending bridge1 with a newly learned affinity updates it without moving it.
    NativeInteropReservedNamesFlutterApiRegistrar.registerInstance(
      api: bridge1, engineId: Int64.min, affinityKey: stub.engineIdentifier, name: name)

    #expect(
      try NativeInteropReservedNamesFlutterApiRegistrar.getInstance(registrar: stub, name: name)?
        .release(value: "ping")
        == "engine1:ping")
    #expect(
      try NativeInteropReservedNamesFlutterApiRegistrar.getInstance(registrar: other, name: name)?
        .release(value: "ping")
        == "engine2:ping")

    // Since bridge1 was updated rather than duplicated, unregistering it once leaves only bridge2.
    NativeInteropReservedNamesFlutterApiRegistrar.unregisterInstance(api: bridge1, name: name)
    #expect(
      try NativeInteropReservedNamesFlutterApiRegistrar.getInstance(registrar: stub, name: name)?
        .release(value: "ping")
        == "engine2:ping")

    NativeInteropReservedNamesFlutterApiRegistrar.unregisterInstance(api: bridge2, name: name)
    #expect(
      NativeInteropReservedNamesFlutterApiRegistrar.getInstance(registrar: stub, name: name) == nil)
  }

  @Test
  func flutterApiDefaultNameAndExplicitEmptyStringNameAreDistinct() throws {
    let stub = StubPluginRegistrar()
    let preexistingDefault = NativeInteropReservedNamesFlutterApiRegistrar.getInstance(
      registrar: stub)
    let defaultBridge = FakeReservedNamesFlutterApiBridge("defaultFlutter")
    let emptyNameBridge = FakeReservedNamesFlutterApiBridge("emptyStringFlutter")

    NativeInteropReservedNamesFlutterApiRegistrar.registerInstance(
      api: defaultBridge, engineId: stub.engineIdentifier, affinityKey: Int64.min)
    #expect(
      NativeInteropReservedNamesFlutterApiRegistrar.getInstance(registrar: stub, name: "") == nil)

    NativeInteropReservedNamesFlutterApiRegistrar.registerInstance(
      api: emptyNameBridge, engineId: stub.engineIdentifier, affinityKey: Int64.min, name: "")
    #expect(
      try NativeInteropReservedNamesFlutterApiRegistrar.getInstance(registrar: stub)?.release(
        value: "ping")
        == "defaultFlutter:ping")
    #expect(
      try NativeInteropReservedNamesFlutterApiRegistrar.getInstance(registrar: stub, name: "")?
        .release(value: "ping")
        == "emptyStringFlutter:ping")

    NativeInteropReservedNamesFlutterApiRegistrar.unregisterInstance(api: emptyNameBridge, name: "")
    #expect(
      NativeInteropReservedNamesFlutterApiRegistrar.getInstance(registrar: stub, name: "") == nil)
    #expect(
      try NativeInteropReservedNamesFlutterApiRegistrar.getInstance(registrar: stub)?.release(
        value: "ping")
        == "defaultFlutter:ping")

    NativeInteropReservedNamesFlutterApiRegistrar.unregisterInstance(api: defaultBridge)
    #expect(
      NativeInteropReservedNamesFlutterApiRegistrar.getInstance(registrar: stub)
        === preexistingDefault)
  }

  @Test
  func sameHostApiOnTwoRegistrarsIsTrackedPerEngine() throws {
    let name = "macosSameApiTwoEngines"
    let registrar1 = StubPluginRegistrar()
    let registrar2 = StubPluginRegistrar()
    let api = FakeClassReservedApi("shared")
    NativeInteropReservedNamesHostApiSetup.register(api: api, registrar: registrar1, name: name)
    let setup1 = try #require(NativeInteropReservedNamesHostApiSetup.getInstance(name: name))
    NativeInteropReservedNamesHostApiSetup.register(api: api, registrar: registrar2, name: name)
    let setup2 = try #require(NativeInteropReservedNamesHostApiSetup.getInstance(name: name))
    #expect(setup1 !== setup2)
    #expect(
      NativeInteropReservedNamesHostApiSetup.pigeonEngineKey(of: setup1)
        == registrar1.engineIdentifier)
    #expect(
      NativeInteropReservedNamesHostApiSetup.pigeonEngineKey(of: setup2)
        == registrar2.engineIdentifier)

    // Re-registering from the same engine reuses its wrapper.
    NativeInteropReservedNamesHostApiSetup.register(api: api, registrar: registrar1, name: name)
    #expect(NativeInteropReservedNamesHostApiSetup.getInstance(name: name) === setup1)

    // Out-of-order unregister removes only the entry for that engine.
    NativeInteropReservedNamesHostApiSetup.unregister(api: api, registrar: registrar1, name: name)
    #expect(NativeInteropReservedNamesHostApiSetup.getInstance(name: name) === setup2)
    NativeInteropReservedNamesHostApiSetup.unregister(api: api, registrar: registrar2, name: name)
    #expect(NativeInteropReservedNamesHostApiSetup.getInstance(name: name) == nil)
  }

  @Test
  func hostApiUnregisterFromUnknownEngineFallsBackToIdentity() throws {
    let name = "macosUnregisterFallback"
    let registrar = StubPluginRegistrar()
    let otherRegistrar = StubPluginRegistrar()
    let api = FakeClassReservedApi("shared")
    NativeInteropReservedNamesHostApiSetup.register(api: api, registrar: registrar, name: name)
    NativeInteropReservedNamesHostApiSetup.unregister(
      api: api, registrar: otherRegistrar, name: name)
    #expect(NativeInteropReservedNamesHostApiSetup.getInstance(name: name) == nil)
  }

  @Test
  func pigeonResolveInstancePrefersEngineIdThenAffinityThenTop() throws {
    let name = "macosResolveOrder"
    let noKey = Int64.min
    let registrar1 = StubPluginRegistrar()
    let registrar2 = StubPluginRegistrar()
    let unrelated = StubPluginRegistrar()
    let engine1 = registrar1.engineIdentifier
    let engine2 = registrar2.engineIdentifier
    let api1 = FakeClassReservedApi("shared")
    let api2 = FakeClassReservedApi("other")
    NativeInteropReservedNamesHostApiSetup.register(api: api1, registrar: registrar1, name: name)
    let setup1 = try #require(NativeInteropReservedNamesHostApiSetup.getInstance(name: name))
    NativeInteropReservedNamesHostApiSetup.register(api: api2, registrar: registrar2, name: name)
    let setup2 = try #require(NativeInteropReservedNamesHostApiSetup.getInstance(name: name))
    defer {
      NativeInteropReservedNamesHostApiSetup.unregister(
        api: api1, registrar: registrar1, name: name)
      NativeInteropReservedNamesHostApiSetup.unregister(
        api: api2, registrar: registrar2, name: name)
    }

    #expect(
      NativeInteropReservedNamesHostApiSetup.pigeonResolveInstance(
        engineId: engine1, affinityKey: engine2, name: name) === setup1)
    #expect(
      NativeInteropReservedNamesHostApiSetup.pigeonResolveInstance(
        engineId: noKey, affinityKey: engine1, name: name) === setup1)
    #expect(
      NativeInteropReservedNamesHostApiSetup.pigeonResolveInstance(
        engineId: unrelated.engineIdentifier, affinityKey: engine1, name: name) === setup1)
    #expect(
      NativeInteropReservedNamesHostApiSetup.pigeonResolveInstance(
        engineId: unrelated.engineIdentifier, affinityKey: noKey, name: name) === setup2)
    #expect(
      NativeInteropReservedNamesHostApiSetup.pigeonResolveInstance(
        engineId: noKey, affinityKey: noKey, name: name)
        === setup2)
    #expect(
      NativeInteropReservedNamesHostApiSetup.pigeonResolveInstance(
        engineId: engine1, affinityKey: engine2, name: "macosUnregistered") == nil)
  }

  @Test
  func flutterApiLookupByRegistrarPrefersThatEngine() throws {
    let name = "macosFlutterLookupByEngine"
    let noKey = Int64.min
    let registrar1 = StubPluginRegistrar()
    let registrar2 = StubPluginRegistrar()
    let unrelated = StubPluginRegistrar()
    let bridge1 = FakeReservedNamesFlutterApiBridge("engine1")
    let bridge2 = FakeReservedNamesFlutterApiBridge("engine2")
    let affinityBridge = FakeReservedNamesFlutterApiBridge("affinity")
    defer {
      for bridge in [bridge1, bridge2, affinityBridge] {
        NativeInteropReservedNamesFlutterApiRegistrar.unregisterInstance(api: bridge, name: name)
      }
    }
    func release(_ registrar: FlutterPluginRegistrar) throws -> String? {
      return try NativeInteropReservedNamesFlutterApiRegistrar.getInstance(
        registrar: registrar, name: name)?.release(value: "ping")
    }

    NativeInteropReservedNamesFlutterApiRegistrar.registerInstance(
      api: bridge1, engineId: registrar1.engineIdentifier, affinityKey: noKey, name: name)
    NativeInteropReservedNamesFlutterApiRegistrar.registerInstance(
      api: bridge2, engineId: registrar2.engineIdentifier, affinityKey: noKey, name: name)
    #expect(try release(registrar1) == "engine1:ping")
    #expect(try release(registrar2) == "engine2:ping")
    #expect(try release(unrelated) == "engine2:ping")

    // A later registration that only has an affinity for engine1 doesn't override the
    // registration made from engine1 itself, but is used once that one is gone.
    NativeInteropReservedNamesFlutterApiRegistrar.registerInstance(
      api: affinityBridge, engineId: noKey, affinityKey: registrar1.engineIdentifier, name: name)
    #expect(try release(registrar1) == "engine1:ping")
    NativeInteropReservedNamesFlutterApiRegistrar.unregisterInstance(api: bridge1, name: name)
    #expect(try release(registrar1) == "affinity:ping")
    #expect(try release(registrar2) == "engine2:ping")
  }

  @Test
  func hostApiUnregisterFromUnknownEngineKeepsApiRegisteredForSeveralEngines() throws {
    let name = "macosUnregisterFallbackMultiEngine"
    let registrar1 = StubPluginRegistrar()
    let registrar2 = StubPluginRegistrar()
    let unrelated = StubPluginRegistrar()
    let api = NativeInteropTestsClass()
    NativeInteropHostIntegrationCoreApiSetup.register(api: api, registrar: registrar1, name: name)
    NativeInteropHostIntegrationCoreApiSetup.register(api: api, registrar: registrar2, name: name)
    defer {
      NativeInteropHostIntegrationCoreApiSetup.unregister(
        api: api, registrar: registrar1, name: name)
      NativeInteropHostIntegrationCoreApiSetup.unregister(
        api: api, registrar: registrar2, name: name)
    }
    let setup1 = try #require(
      NativeInteropHostIntegrationCoreApiSetup.pigeonResolveInstance(
        engineId: registrar1.engineIdentifier, affinityKey: Int64.min, name: name))
    let setup2 = try #require(
      NativeInteropHostIntegrationCoreApiSetup.pigeonResolveInstance(
        engineId: registrar2.engineIdentifier, affinityKey: Int64.min, name: name))
    #expect(setup1 !== setup2)

    // api is held by two engines and neither matches, so nothing is removed.
    NativeInteropHostIntegrationCoreApiSetup.unregister(api: api, registrar: unrelated, name: name)
    #expect(
      NativeInteropHostIntegrationCoreApiSetup.pigeonResolveInstance(
        engineId: registrar1.engineIdentifier, affinityKey: Int64.min, name: name) === setup1)
    #expect(
      NativeInteropHostIntegrationCoreApiSetup.pigeonResolveInstance(
        engineId: registrar2.engineIdentifier, affinityKey: Int64.min, name: name) === setup2)
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

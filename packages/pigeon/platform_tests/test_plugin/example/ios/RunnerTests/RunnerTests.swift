// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import Foundation
import Testing

@testable import test_plugin

@Suite(.serialized)
@MainActor
struct RunnerTests {

  @Test
  func toListAndBack() throws {
    let reply = MessageSearchReply(result: "foobar")
    let dict = reply.toList()
    let copy = MessageSearchReply.fromList(dict)
    #expect(reply.result == copy?.result)
  }

  @Test
  func handlesNull() throws {
    let reply = MessageSearchReply()
    let dict = reply.toList()
    let copy = MessageSearchReply.fromList(dict)
    #expect(copy?.result == nil)
  }

  @Test
  func handlesNullFirst() throws {
    let reply = MessageSearchReply(error: "foobar")
    let dict = reply.toList()
    let copy = MessageSearchReply.fromList(dict)
    #expect(reply.error == copy?.error)
  }

  /// This validates that pigeon clients can easily write tests that mock out Flutter API
  /// calls using a pigeon-generated protocol.
  @Test
  func echoStringFromProtocol() async throws {
    let api: FlutterApiFromProtocol = FlutterApiFromProtocol()
    let aString = "aString"
    let res = try await api.echo(string: aString)
    #expect(aString == res)
  }

  @Test
  func multiEngineHostApiRegistrationAndUnregister() throws {
    let stub = StubPluginRegistrar()
    let name = "iosMultiEngineTest"
    let api1 = NativeInteropTestsClass()
    let api2 = NativeInteropTestsClass()
    NativeInteropHostIntegrationCoreApiSetup.register(api: api1, registrar: stub, name: name)
    let setup1 = try #require(NativeInteropHostIntegrationCoreApiSetup.getInstance(name: name))
    NativeInteropHostIntegrationCoreApiSetup.register(api: api2, registrar: stub, name: name)
    let setup2 = try #require(NativeInteropHostIntegrationCoreApiSetup.getInstance(name: name))
    #expect(setup2 !== setup1)

    NativeInteropHostIntegrationCoreApiSetup.unregister(api: api1, registrar: stub, name: name)
    let staleError = NativeInteropTestsError()
    #expect(setup1.echoString(aString: "ping", wrappedError: staleError) == nil)
    #expect(staleError.code == "unregistered-instance")
    #expect(NativeInteropHostIntegrationCoreApiSetup.getInstance(name: name) === setup2)

    NativeInteropHostIntegrationCoreApiSetup.unregister(api: api2, registrar: stub, name: name)
    #expect(NativeInteropHostIntegrationCoreApiSetup.getInstance(name: name) == nil)
  }

  @Test
  func reRegisteringHostApiMovesExistingSetupToTop() throws {
    let stub = StubPluginRegistrar()
    let name = "iosReRegisterTest"
    let api1 = NativeInteropTestsClass()
    let api2 = NativeInteropTestsClass()
    NativeInteropHostIntegrationCoreApiSetup.register(api: api1, registrar: stub, name: name)
    let setup1 = try #require(NativeInteropHostIntegrationCoreApiSetup.getInstance(name: name))
    NativeInteropHostIntegrationCoreApiSetup.register(api: api2, registrar: stub, name: name)
    let setup2 = try #require(NativeInteropHostIntegrationCoreApiSetup.getInstance(name: name))

    NativeInteropHostIntegrationCoreApiSetup.register(api: api1, registrar: stub, name: name)
    #expect(NativeInteropHostIntegrationCoreApiSetup.getInstance(name: name) === setup1)
    let error = NativeInteropTestsError()
    #expect(setup1.echoString(aString: "ping", wrappedError: error) == "ping")
    #expect(error.code == nil)

    NativeInteropHostIntegrationCoreApiSetup.unregister(api: api1, registrar: stub, name: name)
    #expect(NativeInteropHostIntegrationCoreApiSetup.getInstance(name: name) === setup2)
    NativeInteropHostIntegrationCoreApiSetup.unregister(api: api2, registrar: stub, name: name)
    #expect(NativeInteropHostIntegrationCoreApiSetup.getInstance(name: name) == nil)
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

    plugin1?.detachFromEngine(for: registrar1)
    #expect(NativeInteropHostIntegrationCoreApiSetup.getInstance() === setup2)

    plugin2?.detachFromEngine(for: registrar2)
    #expect(NativeInteropHostIntegrationCoreApiSetup.getInstance() === preexistingSetup)
  }

  @Test
  func realFlutterEnginesOutOfOrderDestroyInvokesDetachAndPreservesRegistrations() async {
    #expect(await SecondaryEngineTestRunner.verifyRealSecondaryEnginesIOS())
  }

  @Test
  func liveSecondaryEnginesExecuteDartIsolatesAcrossOutOfOrderDestroy() async {
    #expect(await SecondaryEngineTestRunner.verifyIOSLiveSecondaryEngineExecution())
  }

  @Test
  func flutterApiRegistrarOutOfOrderUnregisterPreservesOtherEngineRegistrations() throws {
    let stub = StubPluginRegistrar()
    let name = "unitTestFlutterApiStack"
    let bridge1 = FakeReservedNamesFlutterApiBridge("engine1")
    let bridge2 = FakeReservedNamesFlutterApiBridge("engine2")
    let neverRegistered = FakeReservedNamesFlutterApiBridge("never")

    NativeInteropReservedNamesFlutterApiRegistrar.register(
      api: bridge1, engineId: stub.engineIdentifier, affinityKey: Int64.min, name: name)
    NativeInteropReservedNamesFlutterApiRegistrar.register(
      api: bridge2, engineId: stub.engineIdentifier, affinityKey: Int64.min, name: name)
    #expect(
      try NativeInteropReservedNamesFlutterApiRegistrar.getInstance(registrar: stub, name: name)?
        .release(value: "ping")
        == "engine2:ping")

    NativeInteropReservedNamesFlutterApiRegistrar.unregister(api: bridge1, name: name)
    // Duplicate unregister and never-registered unregister must be no-ops.
    NativeInteropReservedNamesFlutterApiRegistrar.unregister(api: bridge1, name: name)
    NativeInteropReservedNamesFlutterApiRegistrar.unregister(
      api: neverRegistered, name: name)
    #expect(
      try NativeInteropReservedNamesFlutterApiRegistrar.getInstance(registrar: stub, name: name)?
        .release(value: "ping")
        == "engine2:ping")

    NativeInteropReservedNamesFlutterApiRegistrar.unregister(api: bridge2, name: name)
    #expect(
      NativeInteropReservedNamesFlutterApiRegistrar.getInstance(registrar: stub, name: name) == nil)
  }

  @Test
  func flutterApiReRegisteringSameInstanceDeduplicatesAndMovesToTop() throws {
    let stub = StubPluginRegistrar()
    let name = "unitTestFlutterApiDeduplicate"
    let bridge1 = FakeReservedNamesFlutterApiBridge("engine1")
    let bridge2 = FakeReservedNamesFlutterApiBridge("engine2")

    NativeInteropReservedNamesFlutterApiRegistrar.register(
      api: bridge1, engineId: stub.engineIdentifier, affinityKey: Int64.min, name: name)
    NativeInteropReservedNamesFlutterApiRegistrar.register(
      api: bridge2, engineId: stub.engineIdentifier, affinityKey: Int64.min, name: name)
    NativeInteropReservedNamesFlutterApiRegistrar.register(
      api: bridge1, engineId: stub.engineIdentifier, affinityKey: Int64.min, name: name)

    #expect(
      try NativeInteropReservedNamesFlutterApiRegistrar.getInstance(registrar: stub, name: name)?
        .release(value: "ping")
        == "engine1:ping")

    NativeInteropReservedNamesFlutterApiRegistrar.unregister(api: bridge1, name: name)
    #expect(
      try NativeInteropReservedNamesFlutterApiRegistrar.getInstance(registrar: stub, name: name)?
        .release(value: "ping")
        == "engine2:ping")

    NativeInteropReservedNamesFlutterApiRegistrar.unregister(api: bridge2, name: name)
    #expect(
      NativeInteropReservedNamesFlutterApiRegistrar.getInstance(registrar: stub, name: name) == nil)
  }

  @Test
  func sameHostApiOnTwoRegistrarsIsTrackedPerEngine() throws {
    let name = "iosSameApiTwoEngines"
    let registrar1 = StubPluginRegistrar()
    let registrar2 = StubPluginRegistrar()
    let api = NativeInteropTestsClass()
    NativeInteropHostIntegrationCoreApiSetup.register(api: api, registrar: registrar1, name: name)
    let setup1 = try #require(NativeInteropHostIntegrationCoreApiSetup.getInstance(name: name))
    NativeInteropHostIntegrationCoreApiSetup.register(api: api, registrar: registrar2, name: name)
    let setup2 = try #require(NativeInteropHostIntegrationCoreApiSetup.getInstance(name: name))
    #expect(setup1 !== setup2)
    #expect(
      NativeInteropHostIntegrationCoreApiSetup.pigeonEngineKey(of: setup1)
        == registrar1.engineIdentifier)
    #expect(
      NativeInteropHostIntegrationCoreApiSetup.pigeonEngineKey(of: setup2)
        == registrar2.engineIdentifier)

    // Re-registering from the same engine reuses its wrapper.
    NativeInteropHostIntegrationCoreApiSetup.register(api: api, registrar: registrar1, name: name)
    #expect(NativeInteropHostIntegrationCoreApiSetup.getInstance(name: name) === setup1)

    // Out-of-order unregister removes only the entry for that engine.
    NativeInteropHostIntegrationCoreApiSetup.unregister(api: api, registrar: registrar1, name: name)
    #expect(NativeInteropHostIntegrationCoreApiSetup.getInstance(name: name) === setup2)
    NativeInteropHostIntegrationCoreApiSetup.unregister(api: api, registrar: registrar2, name: name)
    #expect(NativeInteropHostIntegrationCoreApiSetup.getInstance(name: name) == nil)
  }

  @Test
  func hostApiUnregisterFromUnknownEngineFallsBackToIdentity() throws {
    let name = "iosUnregisterFallback"
    let registrar = StubPluginRegistrar()
    let otherRegistrar = StubPluginRegistrar()
    let api = NativeInteropTestsClass()
    NativeInteropHostIntegrationCoreApiSetup.register(api: api, registrar: registrar, name: name)
    NativeInteropHostIntegrationCoreApiSetup.unregister(
      api: api, registrar: otherRegistrar, name: name)
    #expect(NativeInteropHostIntegrationCoreApiSetup.getInstance(name: name) == nil)
  }

  @Test
  func pigeonResolveInstancePrefersEngineIdThenAffinityThenTop() throws {
    let name = "iosResolveOrder"
    let noKey = Int64.min
    let registrar1 = StubPluginRegistrar()
    let registrar2 = StubPluginRegistrar()
    let unrelated = StubPluginRegistrar()
    let engine1 = registrar1.engineIdentifier
    let engine2 = registrar2.engineIdentifier
    let api1 = NativeInteropTestsClass()
    let api2 = NativeInteropTestsClass()
    NativeInteropHostIntegrationCoreApiSetup.register(api: api1, registrar: registrar1, name: name)
    let setup1 = try #require(NativeInteropHostIntegrationCoreApiSetup.getInstance(name: name))
    NativeInteropHostIntegrationCoreApiSetup.register(api: api2, registrar: registrar2, name: name)
    let setup2 = try #require(NativeInteropHostIntegrationCoreApiSetup.getInstance(name: name))
    defer {
      NativeInteropHostIntegrationCoreApiSetup.unregister(
        api: api1, registrar: registrar1, name: name)
      NativeInteropHostIntegrationCoreApiSetup.unregister(
        api: api2, registrar: registrar2, name: name)
    }

    #expect(
      NativeInteropHostIntegrationCoreApiSetup.pigeonResolveInstance(
        engineId: engine1, affinityKey: engine2, name: name) === setup1)
    #expect(
      NativeInteropHostIntegrationCoreApiSetup.pigeonResolveInstance(
        engineId: noKey, affinityKey: engine1, name: name) === setup1)
    #expect(
      NativeInteropHostIntegrationCoreApiSetup.pigeonResolveInstance(
        engineId: unrelated.engineIdentifier, affinityKey: engine1, name: name) === setup1)
    #expect(
      NativeInteropHostIntegrationCoreApiSetup.pigeonResolveInstance(
        engineId: unrelated.engineIdentifier, affinityKey: noKey, name: name) === setup2)
    #expect(
      NativeInteropHostIntegrationCoreApiSetup.pigeonResolveInstance(
        engineId: noKey, affinityKey: noKey, name: name)
        === setup2)
    #expect(
      NativeInteropHostIntegrationCoreApiSetup.pigeonResolveInstance(
        engineId: engine1, affinityKey: engine2, name: "iosUnregistered") == nil)
  }

  @Test
  func flutterApiLookupByRegistrarPrefersThatEngine() throws {
    let name = "iosFlutterLookupByEngine"
    let noKey = Int64.min
    let registrar1 = StubPluginRegistrar()
    let registrar2 = StubPluginRegistrar()
    let unrelated = StubPluginRegistrar()
    let bridge1 = FakeReservedNamesFlutterApiBridge("engine1")
    let bridge2 = FakeReservedNamesFlutterApiBridge("engine2")
    let affinityBridge = FakeReservedNamesFlutterApiBridge("affinity")
    defer {
      for bridge in [bridge1, bridge2, affinityBridge] {
        NativeInteropReservedNamesFlutterApiRegistrar.unregister(api: bridge, name: name)
      }
    }
    func release(_ registrar: FlutterPluginRegistrar) throws -> String? {
      return try NativeInteropReservedNamesFlutterApiRegistrar.getInstance(
        registrar: registrar, name: name)?.release(value: "ping")
    }

    NativeInteropReservedNamesFlutterApiRegistrar.register(
      api: bridge1, engineId: registrar1.engineIdentifier, affinityKey: noKey, name: name)
    NativeInteropReservedNamesFlutterApiRegistrar.register(
      api: bridge2, engineId: registrar2.engineIdentifier, affinityKey: noKey, name: name)
    #expect(try release(registrar1) == "engine1:ping")
    #expect(try release(registrar2) == "engine2:ping")
    #expect(try release(unrelated) == "engine2:ping")

    // A registration with an unknown Dart engine id matches by affinity key.
    NativeInteropReservedNamesFlutterApiRegistrar.register(
      api: affinityBridge, engineId: noKey, affinityKey: registrar1.engineIdentifier, name: name)
    NativeInteropReservedNamesFlutterApiRegistrar.unregister(api: bridge1, name: name)
    #expect(try release(registrar1) == "affinity:ping")
    #expect(try release(registrar2) == "engine2:ping")
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

final class FlutterApiFromProtocol: FlutterSmallApiProtocol {
  func echo(string aStringArg: String) async throws -> String {
    return aStringArg
  }

  func echo(_ msgArg: test_plugin.TestMessage) async throws -> test_plugin.TestMessage {
    return msgArg
  }
}

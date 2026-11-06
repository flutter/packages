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
    let name = "iosMultiEngineTest"
    let api1 = NativeInteropTestsClass()
    let api2 = NativeInteropTestsClass()
    NativeInteropHostIntegrationCoreApiSetup.register(api: api1, name: name)
    let setup1 = try #require(NativeInteropHostIntegrationCoreApiSetup.getInstance(name: name))
    NativeInteropHostIntegrationCoreApiSetup.register(api: api2, name: name)
    let setup2 = try #require(NativeInteropHostIntegrationCoreApiSetup.getInstance(name: name))
    #expect(setup2 !== setup1)

    NativeInteropHostIntegrationCoreApiSetup.unregister(api: api1, name: name)
    let staleError = NativeInteropTestsError()
    #expect(setup1.echoString(aString: "ping", wrappedError: staleError) == nil)
    #expect(staleError.code == "unregistered-instance")
    #expect(NativeInteropHostIntegrationCoreApiSetup.getInstance(name: name) === setup2)

    NativeInteropHostIntegrationCoreApiSetup.unregister(api: api2, name: name)
    #expect(NativeInteropHostIntegrationCoreApiSetup.getInstance(name: name) == nil)
  }

  @Test
  func reRegisteringHostApiMovesExistingSetupToTop() throws {
    let name = "iosReRegisterTest"
    let api1 = NativeInteropTestsClass()
    let api2 = NativeInteropTestsClass()
    NativeInteropHostIntegrationCoreApiSetup.register(api: api1, name: name)
    let setup1 = try #require(NativeInteropHostIntegrationCoreApiSetup.getInstance(name: name))
    NativeInteropHostIntegrationCoreApiSetup.register(api: api2, name: name)
    let setup2 = try #require(NativeInteropHostIntegrationCoreApiSetup.getInstance(name: name))

    NativeInteropHostIntegrationCoreApiSetup.register(api: api1, name: name)
    #expect(NativeInteropHostIntegrationCoreApiSetup.getInstance(name: name) === setup1)
    let error = NativeInteropTestsError()
    #expect(setup1.echoString(aString: "ping", wrappedError: error) == "ping")
    #expect(error.code == nil)

    NativeInteropHostIntegrationCoreApiSetup.unregister(api: api1, name: name)
    #expect(NativeInteropHostIntegrationCoreApiSetup.getInstance(name: name) === setup2)
    NativeInteropHostIntegrationCoreApiSetup.unregister(api: api2, name: name)
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
    let name = "unitTestFlutterApiStack"
    let bridge1 = FakeReservedNamesFlutterApiBridge("engine1")
    let bridge2 = FakeReservedNamesFlutterApiBridge("engine2")
    let neverRegistered = FakeReservedNamesFlutterApiBridge("never")

    NativeInteropReservedNamesFlutterApiRegistrar.register(api: bridge1, name: name)
    NativeInteropReservedNamesFlutterApiRegistrar.register(api: bridge2, name: name)
    #expect(
      try NativeInteropReservedNamesFlutterApi.getInstance(name: name)?.release(value: "ping")
        == "engine2:ping")

    NativeInteropReservedNamesFlutterApiRegistrar.unregister(api: bridge1, name: name)
    // Duplicate unregister and never-registered unregister must be no-ops.
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

    NativeInteropReservedNamesFlutterApiRegistrar.unregister(api: bridge1, name: name)
    #expect(
      try NativeInteropReservedNamesFlutterApi.getInstance(name: name)?.release(value: "ping")
        == "engine2:ping")

    NativeInteropReservedNamesFlutterApiRegistrar.unregister(api: bridge2, name: name)
    #expect(NativeInteropReservedNamesFlutterApi.getInstance(name: name) == nil)
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

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
  func multiEngineHostApiRegistrationAndUnregister() {
    let name = "iosMultiEngineTest"
    let api1 = NativeInteropTestsClass()
    let api2 = NativeInteropTestsClass()
    let setup1 = NativeInteropHostIntegrationCoreApiSetup.register(api: api1, name: name)!
    NativeInteropHostIntegrationCoreApiSetup.register(api: api2, name: name)
    #expect(NativeInteropHostIntegrationCoreApiSetup.getInstance(name: name) != nil)

    NativeInteropHostIntegrationCoreApiSetup.unregister(api: api1, name: name)
    let staleError = NativeInteropTestsError()
    #expect(setup1.echoString(aString: "ping", wrappedError: staleError) == nil)
    #expect(staleError.code == "unregistered-instance")
    #expect(NativeInteropHostIntegrationCoreApiSetup.getInstance(name: name) != nil)

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
}

final class FlutterApiFromProtocol: FlutterSmallApiProtocol {
  func echo(string aStringArg: String) async throws -> String {
    return aStringArg
  }

  func echo(_ msgArg: test_plugin.TestMessage) async throws -> test_plugin.TestMessage {
    return msgArg
  }
}

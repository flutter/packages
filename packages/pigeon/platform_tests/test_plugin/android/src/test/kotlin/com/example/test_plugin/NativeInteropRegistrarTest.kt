// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.test_plugin

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.mockk.every
import io.mockk.mockk
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNotSame
import org.junit.Assert.assertNull
import org.junit.Assert.assertSame
import org.junit.Assert.assertThrows
import org.junit.Assert.assertTrue
import org.junit.Test

/** The generated "no engine key" sentinel. */
private const val NO_KEY = Long.MIN_VALUE

private class FakeReservedNamesHostApi(private val label: String) :
    NativeInteropReservedNamesHostApi {
  override fun release(value: String): String = "$label:$value"

  override fun use(value: Long): Long = value

  override fun type(): String = label

  override fun isNull(): Boolean = false

  override fun isNullable(): Boolean? = null

  override fun isOpen(): Boolean = true

  override fun getReference(): String = label

  override fun setReference(value: String) {}

  override fun getDefault(): String = label

  override suspend fun getValueAsync(): String = label

  override fun register(value: String): String = "$label:$value"

  override fun unregister(value: String): String = "$label:$value"

  override fun getGetInstance(): String = label

  override fun echoReservedNames(names: NativeInteropReservedNames): NativeInteropReservedNames =
      names

  override fun callFlutterRelease(value: String): String = value

  override fun callFlutterType(): String = label

  override fun callFlutterImplementIn(value: String): String = value

  override fun callFlutterIsNull(): Boolean = false

  override fun callFlutterGetReference(): String = label
}

/** Returns a mock engine with the exact engine id [id] and its own Dart executor. */
private fun mockEngine(id: Long): FlutterEngine {
  val executor = mockk<DartExecutor>()
  val engine = mockk<FlutterEngine>()
  every { engine.engineId } returns id
  every { engine.dartExecutor } returns executor
  return engine
}

/**
 * Returns a mock plugin binding that exposes [messenger].
 *
 * `getEngineId` is not stubbed, so the generated code cannot read an exact engine id from it and
 * falls back to a key for [messenger].
 */
private fun mockBinding(messenger: BinaryMessenger = mockk<DartExecutor>()): FlutterPluginBinding {
  val binding = mockk<FlutterPluginBinding>()
  every { binding.binaryMessenger } returns messenger
  return binding
}

private fun releasePing(registrar: NativeInteropReservedNamesHostApiRegistrar?): String? =
    registrar?.release("ping")

class NativeInteropRegistrarTest {
  @Test
  fun sameApiOnTwoEnginesIsTrackedSeparately() {
    val name = "unitTestSameApiTwoEngines"
    val api = FakeReservedNamesHostApi("shared")
    val engineA = mockEngine(101L)
    val engineB = mockEngine(102L)

    NativeInteropReservedNamesHostApiRegistrar().register(api, engineA, name)
    NativeInteropReservedNamesHostApiRegistrar().register(api, engineB, name)

    val wrapperA =
        NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(101L, NO_KEY, name)!!
    val wrapperB =
        NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(102L, NO_KEY, name)!!
    assertNotSame(wrapperA, wrapperB)
    assertEquals(101L, NativeInteropReservedNamesHostApiRegistrar.pigeonEngineKeyOf(wrapperA))
    assertEquals(102L, NativeInteropReservedNamesHostApiRegistrar.pigeonEngineKeyOf(wrapperB))

    // Unregistering for engine A leaves the registration for engine B in place.
    NativeInteropReservedNamesHostApiRegistrar().unregister(api, engineA, name)
    val error = assertThrows(NativeInteropTestsError::class.java) { wrapperA.release("ping") }
    assertEquals("unregistered-instance", error.code)
    assertEquals("shared:ping", wrapperB.release("ping"))
    assertSame(
        wrapperB,
        NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(101L, NO_KEY, name))

    NativeInteropReservedNamesHostApiRegistrar().unregister(api, engineB, name)
    assertNull(
        NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(NO_KEY, NO_KEY, name))
  }

  @Test
  fun unregisterRemovesSpecificInstanceInAndOutOfOrder() {
    val name = "unitTestOutOfOrder"
    val api1 = FakeReservedNamesHostApi("engine1")
    val api2 = FakeReservedNamesHostApi("engine2")
    val engine1 = mockEngine(201L)
    val engine2 = mockEngine(202L)

    NativeInteropReservedNamesHostApiRegistrar().register(api1, engine1, name)
    val registrar1 =
        NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(NO_KEY, NO_KEY, name)
    assertNotNull(registrar1)
    NativeInteropReservedNamesHostApiRegistrar().register(api2, engine2, name)
    assertEquals(
        "engine2:ping",
        releasePing(
            NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(NO_KEY, NO_KEY, name)))

    // Unregistering engine1 out-of-order leaves engine2 active.
    NativeInteropReservedNamesHostApiRegistrar().unregister(api1, engine1, name)
    assertEquals(
        "engine2:ping",
        releasePing(
            NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(NO_KEY, NO_KEY, name)))
    // Stale registrar1 reference has its internal api cleared.
    val error = assertThrows(NativeInteropTestsError::class.java) { registrar1!!.release("ping") }
    assertEquals("unregistered-instance", error.code)
    assertEquals("NativeInteropReservedNamesHostApi has not been registered.", error.message)

    NativeInteropReservedNamesHostApiRegistrar().unregister(api2, engine2, name)
    assertNull(
        NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(NO_KEY, NO_KEY, name))
  }

  @Test
  fun unregisterWithUnmatchedEngineFallsBackToIdentity() {
    val name = "unitTestUnregisterFallback"
    val api = FakeReservedNamesHostApi("engine")
    val other = FakeReservedNamesHostApi("other")
    val engine = mockEngine(301L)

    NativeInteropReservedNamesHostApiRegistrar().register(other, engine, name)
    NativeInteropReservedNamesHostApiRegistrar().register(api, engine, name)
    // No entry for api has the key of this binding, so api's entries are removed by identity.
    NativeInteropReservedNamesHostApiRegistrar().unregister(api, mockBinding(), name)
    assertEquals(
        "other:ping",
        releasePing(
            NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(NO_KEY, NO_KEY, name)))

    NativeInteropReservedNamesHostApiRegistrar().unregister(other, engine, name)
    assertNull(
        NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(NO_KEY, NO_KEY, name))
  }

  @Test
  fun duplicateAndUnregisteredUnregisterCallsAreNoOps() {
    val name = "unitTestIdempotentUnregister"
    val api1 = FakeReservedNamesHostApi("engine1")
    val api2 = FakeReservedNamesHostApi("engine2")
    val neverRegistered = FakeReservedNamesHostApi("never")
    val engine = mockEngine(401L)

    NativeInteropReservedNamesHostApiRegistrar().register(api1, engine, name)
    NativeInteropReservedNamesHostApiRegistrar().register(api2, engine, name)

    NativeInteropReservedNamesHostApiRegistrar().unregister(api1, engine, name)
    // Calling unregister again on api1 or on a never-registered instance must not pop api2.
    NativeInteropReservedNamesHostApiRegistrar().unregister(api1, engine, name)
    NativeInteropReservedNamesHostApiRegistrar().unregister(neverRegistered, engine, name)
    assertEquals(
        "engine2:ping",
        releasePing(
            NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(NO_KEY, NO_KEY, name)))

    NativeInteropReservedNamesHostApiRegistrar().unregister(api2, engine, name)
    assertNull(
        NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(NO_KEY, NO_KEY, name))
  }

  @Test
  fun bindingsWithoutEngineIdGetSyntheticKeysPerMessenger() {
    val name = "unitTestSyntheticKeys"
    val api = FakeReservedNamesHostApi("synthetic")
    val messenger = mockk<DartExecutor>()
    val binding1 = mockBinding(messenger)
    val binding2 = mockBinding(messenger)
    val otherBinding = mockBinding()

    NativeInteropReservedNamesHostApiRegistrar().register(api, binding1, name)
    val wrapper =
        NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(NO_KEY, NO_KEY, name)!!
    val key = NativeInteropReservedNamesHostApiRegistrar.pigeonEngineKeyOf(wrapper)
    assertTrue(key < 0)
    assertNotEquals(NO_KEY, key)

    // A binding with the same messenger belongs to the same engine, so it reuses the wrapper.
    NativeInteropReservedNamesHostApiRegistrar().register(api, binding2, name)
    assertSame(
        wrapper,
        NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(NO_KEY, NO_KEY, name))

    // A binding with another messenger gets a different key.
    NativeInteropReservedNamesHostApiRegistrar().register(api, otherBinding, name)
    val otherWrapper =
        NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(NO_KEY, NO_KEY, name)!!
    assertNotSame(wrapper, otherWrapper)
    val otherKey = NativeInteropReservedNamesHostApiRegistrar.pigeonEngineKeyOf(otherWrapper)
    assertTrue(otherKey < 0)
    assertNotEquals(key, otherKey)
    assertNotEquals(NO_KEY, otherKey)

    NativeInteropReservedNamesHostApiRegistrar().unregister(api, binding1, name)
    assertSame(
        otherWrapper,
        NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(NO_KEY, NO_KEY, name))
    NativeInteropReservedNamesHostApiRegistrar().unregister(api, otherBinding, name)
    assertNull(
        NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(NO_KEY, NO_KEY, name))
  }

  @Test
  fun engineKeysAreExactAndApplyToBindingsForTheSameEngine() {
    val name = "unitTestExactKeys"
    val api = FakeReservedNamesHostApi("exact")
    val engine = mockEngine(501L)

    NativeInteropReservedNamesHostApiRegistrar().register(api, engine, name)
    val wrapper =
        NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(NO_KEY, NO_KEY, name)!!
    assertEquals(501L, NativeInteropReservedNamesHostApiRegistrar.pigeonEngineKeyOf(wrapper))

    // The binding for the same engine exposes the engine's Dart executor as its messenger, so it
    // maps to the exact key recorded through the engine.
    val binding = mockBinding(engine.dartExecutor)
    NativeInteropReservedNamesHostApiRegistrar().register(api, binding, name)
    assertSame(
        wrapper,
        NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(NO_KEY, NO_KEY, name))

    NativeInteropReservedNamesHostApiRegistrar().unregister(api, binding, name)
    assertNull(
        NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(NO_KEY, NO_KEY, name))
  }

  @Test
  fun bindingKeyIsStableWhenItsEngineIsLaterKeyedExactly() {
    val name = "unitTestBindingThenEngine"
    val api = FakeReservedNamesHostApi("shared")
    val engineA = mockEngine(1301L)
    val bindingA = mockBinding(engineA.dartExecutor)
    val bindingB = mockBinding()

    NativeInteropReservedNamesHostApiRegistrar().register(api, bindingA, name)
    NativeInteropReservedNamesHostApiRegistrar().register(api, bindingB, name)
    val wrapperB =
        NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(NO_KEY, NO_KEY, name)!!

    // Keying engine A exactly afterwards must not change the key that bindingA registered with.
    NativeInteropReservedNamesHostApiRegistrar().register(api, engineA, "${name}Other")
    NativeInteropReservedNamesHostApiRegistrar().unregister(api, engineA, "${name}Other")

    // Unregistering through bindingA removes only engine A's registration.
    NativeInteropReservedNamesHostApiRegistrar().unregister(api, bindingA, name)
    assertEquals("shared:ping", wrapperB.release("ping"))
    assertSame(
        wrapperB,
        NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(NO_KEY, NO_KEY, name))

    NativeInteropReservedNamesHostApiRegistrar().unregister(api, bindingB, name)
    assertNull(
        NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(NO_KEY, NO_KEY, name))
  }

  @Test
  fun unmatchedUnregisterDoesNotRemoveApiRegisteredForSeveralEngines() {
    val name = "unitTestUnmatchedMultiEngine"
    val api = FakeReservedNamesHostApi("shared")
    val engine1 = mockEngine(1401L)
    val engine2 = mockEngine(1402L)

    NativeInteropReservedNamesHostApiRegistrar().register(api, engine1, name)
    NativeInteropReservedNamesHostApiRegistrar().register(api, engine2, name)
    val wrapper1 =
        NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(1401L, NO_KEY, name)!!
    val wrapper2 =
        NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(1402L, NO_KEY, name)!!

    // The binding's key matches neither engine, and api is held by two engines, so nothing is
    // removed rather than guessing which registration to drop.
    NativeInteropReservedNamesHostApiRegistrar().unregister(api, mockBinding(), name)
    assertEquals("shared:ping", wrapper1.release("ping"))
    assertEquals("shared:ping", wrapper2.release("ping"))

    NativeInteropReservedNamesHostApiRegistrar().unregister(api, engine1, name)
    NativeInteropReservedNamesHostApiRegistrar().unregister(api, engine2, name)
    assertNull(
        NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(NO_KEY, NO_KEY, name))
  }

  @Test
  fun resolveInstancePrefersEngineIdThenAffinityThenTopOfStack() {
    val name = "unitTestResolveOrder"
    val api1 = FakeReservedNamesHostApi("engine1")
    val api2 = FakeReservedNamesHostApi("engine2")
    val api3 = FakeReservedNamesHostApi("engine3")
    val engine1 = mockEngine(601L)
    val engine2 = mockEngine(602L)
    val engine3 = mockEngine(603L)

    assertNull(NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(601L, 602L, name))

    NativeInteropReservedNamesHostApiRegistrar().register(api1, engine1, name)
    NativeInteropReservedNamesHostApiRegistrar().register(api2, engine2, name)
    NativeInteropReservedNamesHostApiRegistrar().register(api3, engine3, name)

    fun resolve(engineId: Long, affinityKey: Long): String? =
        releasePing(
            NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(
                engineId, affinityKey, name))

    assertEquals("engine1:ping", resolve(601L, 602L))
    assertEquals("engine2:ping", resolve(NO_KEY, 602L))
    assertEquals("engine2:ping", resolve(699L, 602L))
    assertEquals("engine3:ping", resolve(699L, 698L))
    assertEquals("engine3:ping", resolve(NO_KEY, NO_KEY))

    NativeInteropReservedNamesHostApiRegistrar().unregister(api1, engine1, name)
    NativeInteropReservedNamesHostApiRegistrar().unregister(api2, engine2, name)
    NativeInteropReservedNamesHostApiRegistrar().unregister(api3, engine3, name)
    assertNull(NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(601L, 602L, name))
  }

  @Test
  fun defaultNameAndExplicitEmptyStringNameAreDistinct() {
    val defaultApi = FakeReservedNamesHostApi("defaultEngine")
    val emptyNameApi = FakeReservedNamesHostApi("emptyStringEngine")
    val engine = mockEngine(701L)

    NativeInteropReservedNamesHostApiRegistrar().register(defaultApi, engine)
    assertNull(NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(NO_KEY, NO_KEY, ""))

    NativeInteropReservedNamesHostApiRegistrar().register(emptyNameApi, engine, "")
    assertEquals(
        "defaultEngine:ping",
        releasePing(
            NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(NO_KEY, NO_KEY)))
    assertEquals(
        "emptyStringEngine:ping",
        releasePing(
            NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(NO_KEY, NO_KEY, "")))

    NativeInteropReservedNamesHostApiRegistrar().unregister(emptyNameApi, engine, "")
    assertNull(NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(NO_KEY, NO_KEY, ""))
    assertEquals(
        "defaultEngine:ping",
        releasePing(
            NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(NO_KEY, NO_KEY)))

    NativeInteropReservedNamesHostApiRegistrar().unregister(defaultApi, engine)
    assertNull(NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(NO_KEY, NO_KEY))
  }

  @Test
  fun reRegisteringSameApiDeduplicatesAndMovesToTop() {
    val name = "unitTestDeduplicate"
    val api1 = FakeReservedNamesHostApi("engine1")
    val api2 = FakeReservedNamesHostApi("engine2")
    val engine = mockEngine(801L)

    NativeInteropReservedNamesHostApiRegistrar().register(api1, engine, name)
    val reg1 =
        NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(NO_KEY, NO_KEY, name)!!
    NativeInteropReservedNamesHostApiRegistrar().register(api2, engine, name)
    val reg2 =
        NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(NO_KEY, NO_KEY, name)!!
    NativeInteropReservedNamesHostApiRegistrar().register(api1, engine, name)

    // Re-registering api1 reuses its existing wrapper, so handles that already resolved it keep
    // working.
    assertSame(
        reg1,
        NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(NO_KEY, NO_KEY, name))
    assertEquals("engine1:ping", reg1.release("ping"))

    // Since api1 was deduplicated rather than duplicated, unregistering api1 once leaves only api2.
    NativeInteropReservedNamesHostApiRegistrar().unregister(api1, engine, name)
    assertSame(
        reg2,
        NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(NO_KEY, NO_KEY, name))
    NativeInteropReservedNamesHostApiRegistrar().unregister(api2, engine, name)
    assertNull(
        NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(NO_KEY, NO_KEY, name))
  }

  @Test
  fun flutterApiLookupByEngineUsesEngineIdThenAffinityThenTopOfStack() {
    val name = "unitTestFlutterApiByEngine"
    val api1 = FakeReservedNamesFlutterApi("engine1")
    val api2 = FakeReservedNamesFlutterApi("engine2")
    val affineApi = FakeReservedNamesFlutterApi("affine")
    val engine1 = mockEngine(901L)
    val engine2 = mockEngine(902L)
    val engine3 = mockEngine(903L)

    assertNull(NativeInteropReservedNamesFlutterApiRegistrar().getInstance(engine1, name))

    NativeInteropReservedNamesFlutterApiRegistrar().registerInstance(api1, 901L, NO_KEY, name)
    NativeInteropReservedNamesFlutterApiRegistrar().registerInstance(api2, 902L, NO_KEY, name)
    assertEquals(
        "engine1:ping",
        NativeInteropReservedNamesFlutterApiRegistrar().getInstance(engine1, name)?.release("ping"))
    assertEquals(
        "engine2:ping",
        NativeInteropReservedNamesFlutterApiRegistrar().getInstance(engine2, name)?.release("ping"))
    // No registration for engine3, so the top of the stack is used.
    assertEquals(
        "engine2:ping",
        NativeInteropReservedNamesFlutterApiRegistrar().getInstance(engine3, name)?.release("ping"))

    // A binding for engine1 resolves to the same registration as engine1 itself.
    val binding1 = mockBinding(engine1.dartExecutor)
    assertEquals(
        "engine1:ping",
        NativeInteropReservedNamesFlutterApiRegistrar()
            .getInstance(binding1, name)
            ?.release("ping"))

    // A later registration that only has an affinity for engine1 doesn't override the
    // registration made by the isolate running on engine1.
    NativeInteropReservedNamesFlutterApiRegistrar().registerInstance(affineApi, NO_KEY, 901L, name)
    assertEquals(
        "engine1:ping",
        NativeInteropReservedNamesFlutterApiRegistrar().getInstance(engine1, name)?.release("ping"))

    // Without an exact match, the affine registration wins over the top of the stack.
    NativeInteropReservedNamesFlutterApiRegistrar().unregisterInstance(api1, name)
    NativeInteropReservedNamesFlutterApiRegistrar().registerInstance(api2, 902L, NO_KEY, name)
    assertEquals(
        "affine:ping",
        NativeInteropReservedNamesFlutterApiRegistrar().getInstance(engine1, name)?.release("ping"))

    NativeInteropReservedNamesFlutterApiRegistrar().unregisterInstance(affineApi, name)
    NativeInteropReservedNamesFlutterApiRegistrar().unregisterInstance(api2, name)
    assertNull(NativeInteropReservedNamesFlutterApiRegistrar().getInstance(engine1, name))
  }

  @Test
  fun flutterApiRegistrarOutOfOrderAndIdempotentUnregisterPreservesStack() {
    val name = "unitTestFlutterApiStack"
    val api1 = FakeReservedNamesFlutterApi("engine1")
    val api2 = FakeReservedNamesFlutterApi("engine2")
    val neverRegistered = FakeReservedNamesFlutterApi("never")
    val engine = mockEngine(1001L)

    NativeInteropReservedNamesFlutterApiRegistrar().registerInstance(api1, NO_KEY, NO_KEY, name)
    NativeInteropReservedNamesFlutterApiRegistrar().registerInstance(api2, NO_KEY, NO_KEY, name)
    assertEquals(
        "engine2:ping",
        NativeInteropReservedNamesFlutterApiRegistrar().getInstance(engine, name)?.release("ping"))

    // Out-of-order unregister of api1 leaves api2 active.
    NativeInteropReservedNamesFlutterApiRegistrar().unregisterInstance(api1, name)
    // Duplicate unregister of api1 and unregister of a never-registered instance are safe no-ops.
    NativeInteropReservedNamesFlutterApiRegistrar().unregisterInstance(api1, name)
    NativeInteropReservedNamesFlutterApiRegistrar().unregisterInstance(neverRegistered, name)
    assertEquals(
        "engine2:ping",
        NativeInteropReservedNamesFlutterApiRegistrar().getInstance(engine, name)?.release("ping"))

    NativeInteropReservedNamesFlutterApiRegistrar().unregisterInstance(api2, name)
    assertNull(NativeInteropReservedNamesFlutterApiRegistrar().getInstance(engine, name))
  }

  @Test
  fun flutterApiReRegisteringSameInstanceUpdatesKeysInPlace() {
    val name = "unitTestFlutterApiDeduplicate"
    val api1 = FakeReservedNamesFlutterApi("engine1")
    val api2 = FakeReservedNamesFlutterApi("engine2")
    val engine1 = mockEngine(1101L)
    val binding1 = mockBinding(mockk<DartExecutor>())

    // api1 registers before its isolate knows its engine affinity.
    NativeInteropReservedNamesFlutterApiRegistrar().registerInstance(api1, NO_KEY, NO_KEY, name)
    NativeInteropReservedNamesFlutterApiRegistrar().registerInstance(api2, NO_KEY, NO_KEY, name)
    assertEquals(
        "engine2:ping",
        NativeInteropReservedNamesFlutterApiRegistrar()
            .getInstance(binding1, name)
            ?.release("ping"))

    // Dart re-sends api1 once it learns the affinity, which is binding1's key. The registration is
    // updated without moving, so it is found by key while api2 stays the most recent.
    val binding1Key =
        NativeInteropReservedNamesHostApiRegistrar.run {
          val host = FakeReservedNamesHostApi("probe")
          NativeInteropReservedNamesHostApiRegistrar().register(host, binding1, "${name}Probe")
          val key =
              pigeonEngineKeyOf(
                  NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(
                      NO_KEY, NO_KEY, "${name}Probe")!!)
          NativeInteropReservedNamesHostApiRegistrar().unregister(host, binding1, "${name}Probe")
          key
        }
    NativeInteropReservedNamesFlutterApiRegistrar()
        .registerInstance(api1, NO_KEY, binding1Key, name)
    assertEquals(
        "engine1:ping",
        NativeInteropReservedNamesFlutterApiRegistrar()
            .getInstance(binding1, name)
            ?.release("ping"))
    assertEquals(
        "engine2:ping",
        NativeInteropReservedNamesFlutterApiRegistrar().getInstance(engine1, name)?.release("ping"))

    // Since api1 was updated rather than duplicated, unregistering api1 once leaves only api2.
    NativeInteropReservedNamesFlutterApiRegistrar().unregisterInstance(api1, name)
    assertEquals(
        "engine2:ping",
        NativeInteropReservedNamesFlutterApiRegistrar()
            .getInstance(binding1, name)
            ?.release("ping"))
    NativeInteropReservedNamesFlutterApiRegistrar().unregisterInstance(api2, name)
    assertNull(NativeInteropReservedNamesFlutterApiRegistrar().getInstance(engine1, name))
  }

  @Test
  fun flutterApiDefaultNameAndExplicitEmptyStringNameAreDistinct() {
    val defaultApi = FakeReservedNamesFlutterApi("defaultFlutter")
    val emptyNameApi = FakeReservedNamesFlutterApi("emptyStringFlutter")
    val engine = mockEngine(1201L)

    NativeInteropReservedNamesFlutterApiRegistrar().registerInstance(defaultApi, NO_KEY, NO_KEY)
    assertNull(NativeInteropReservedNamesFlutterApiRegistrar().getInstance(engine, ""))

    NativeInteropReservedNamesFlutterApiRegistrar()
        .registerInstance(emptyNameApi, NO_KEY, NO_KEY, "")
    assertEquals(
        "defaultFlutter:ping",
        NativeInteropReservedNamesFlutterApiRegistrar().getInstance(engine)?.release("ping"))
    assertEquals(
        "emptyStringFlutter:ping",
        NativeInteropReservedNamesFlutterApiRegistrar().getInstance(engine, "")?.release("ping"))

    NativeInteropReservedNamesFlutterApiRegistrar().unregisterInstance(emptyNameApi, "")
    assertNull(NativeInteropReservedNamesFlutterApiRegistrar().getInstance(engine, ""))
    assertEquals(
        "defaultFlutter:ping",
        NativeInteropReservedNamesFlutterApiRegistrar().getInstance(engine)?.release("ping"))

    NativeInteropReservedNamesFlutterApiRegistrar().unregisterInstance(defaultApi)
    assertNull(NativeInteropReservedNamesFlutterApiRegistrar().getInstance(engine))
  }
}

private class FakeReservedNamesFlutterApi(private val label: String) :
    NativeInteropReservedNamesFlutterApi {
  override fun release(value: String): String = "$label:$value"

  override fun type(): String = label

  override fun implementIn(value: String): String = "$label:$value"

  override fun isNull(): Boolean = false

  override fun getReference(): String = label
}

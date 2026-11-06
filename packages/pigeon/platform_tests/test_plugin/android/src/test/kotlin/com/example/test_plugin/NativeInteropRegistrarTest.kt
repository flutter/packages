// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.test_plugin

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertSame
import org.junit.Assert.assertThrows
import org.junit.Test

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

  override fun callFlutterRegister(value: String): String = value

  override fun callFlutterDartApi(): String = label
}

class NativeInteropRegistrarTest {
  @Test
  fun unregisterRemovesSpecificInstanceInAndOutOfOrder() {
    val name = "unitTestOutOfOrder"
    val api1 = FakeReservedNamesHostApi("engine1")
    val api2 = FakeReservedNamesHostApi("engine2")

    NativeInteropReservedNamesHostApiRegistrar.register(api1, name)
    val registrar1 = NativeInteropReservedNamesHostApiRegistrar.getInstance(name)
    assertNotNull(registrar1)
    NativeInteropReservedNamesHostApiRegistrar.register(api2, name)

    assertEquals(
        "engine2:ping",
        NativeInteropReservedNamesHostApiRegistrar.getInstance(name)?.release("ping"),
    )

    // Unregistering engine1 out-of-order leaves engine2 active.
    NativeInteropReservedNamesHostApiRegistrar.unregister(api1, name)
    assertEquals(
        "engine2:ping",
        NativeInteropReservedNamesHostApiRegistrar.getInstance(name)?.release("ping"),
    )
    // Stale registrar1 reference has its internal api cleared.
    val error = assertThrows(NativeInteropTestsError::class.java) { registrar1!!.release("ping") }
    assertEquals("unregistered-instance", error.code)
    assertEquals("NativeInteropReservedNamesHostApi has not been registered.", error.message)

    // Unregistering engine2 clears the registration list completely.
    NativeInteropReservedNamesHostApiRegistrar.unregister(api2, name)
    assertNull(NativeInteropReservedNamesHostApiRegistrar.getInstance(name))
  }

  @Test
  fun duplicateAndUnregisteredUnregisterCallsAreNoOps() {
    val name = "unitTestIdempotentUnregister"
    val api1 = FakeReservedNamesHostApi("engine1")
    val api2 = FakeReservedNamesHostApi("engine2")
    val neverRegistered = FakeReservedNamesHostApi("never")

    NativeInteropReservedNamesHostApiRegistrar.register(api1, name)
    NativeInteropReservedNamesHostApiRegistrar.register(api2, name)

    NativeInteropReservedNamesHostApiRegistrar.unregister(api1, name)
    // Calling unregister again on api1 or on a never-registered instance must not pop api2.
    NativeInteropReservedNamesHostApiRegistrar.unregister(api1, name)
    NativeInteropReservedNamesHostApiRegistrar.unregister(neverRegistered, name)
    assertEquals(
        "engine2:ping",
        NativeInteropReservedNamesHostApiRegistrar.getInstance(name)?.release("ping"),
    )

    NativeInteropReservedNamesHostApiRegistrar.unregister(api2, name)
    assertNull(NativeInteropReservedNamesHostApiRegistrar.getInstance(name))
  }

  @Test
  fun defaultNullNameAndExplicitEmptyStringNameAreDistinct() {
    val defaultApi = FakeReservedNamesHostApi("defaultEngine")
    val emptyNameApi = FakeReservedNamesHostApi("emptyStringEngine")

    NativeInteropReservedNamesHostApiRegistrar.register(defaultApi)
    assertNull(NativeInteropReservedNamesHostApiRegistrar.getInstance(""))

    NativeInteropReservedNamesHostApiRegistrar.register(emptyNameApi, "")
    assertEquals(
        "defaultEngine:ping",
        NativeInteropReservedNamesHostApiRegistrar.getInstance()?.release("ping"),
    )
    assertEquals(
        "emptyStringEngine:ping",
        NativeInteropReservedNamesHostApiRegistrar.getInstance("")?.release("ping"),
    )

    NativeInteropReservedNamesHostApiRegistrar.unregister(emptyNameApi, "")
    assertNull(NativeInteropReservedNamesHostApiRegistrar.getInstance(""))
    assertEquals(
        "defaultEngine:ping",
        NativeInteropReservedNamesHostApiRegistrar.getInstance()?.release("ping"),
    )

    NativeInteropReservedNamesHostApiRegistrar.unregister(defaultApi)
    assertNull(NativeInteropReservedNamesHostApiRegistrar.getInstance())
  }

  @Test
  fun reRegisteringSameApiDeduplicatesAndMovesToTop() {
    val name = "unitTestDeduplicate"
    val api1 = FakeReservedNamesHostApi("engine1")
    val api2 = FakeReservedNamesHostApi("engine2")

    NativeInteropReservedNamesHostApiRegistrar.register(api1, name)
    val reg1 = NativeInteropReservedNamesHostApiRegistrar.getInstance(name)!!
    NativeInteropReservedNamesHostApiRegistrar.register(api2, name)
    val reg2 = NativeInteropReservedNamesHostApiRegistrar.getInstance(name)!!
    NativeInteropReservedNamesHostApiRegistrar.register(api1, name)

    // Re-registering api1 reuses its existing wrapper, so handles that already resolved it keep
    // working.
    assertSame(reg1, NativeInteropReservedNamesHostApiRegistrar.getInstance(name))
    assertEquals("engine1:ping", reg1.release("ping"))

    // Since api1 was deduplicated rather than duplicated, unregistering api1 once leaves only api2.
    NativeInteropReservedNamesHostApiRegistrar.unregister(api1, name)
    assertSame(reg2, NativeInteropReservedNamesHostApiRegistrar.getInstance(name))
    NativeInteropReservedNamesHostApiRegistrar.unregister(api2, name)
    assertNull(NativeInteropReservedNamesHostApiRegistrar.getInstance(name))
  }

  @Test
  fun flutterApiRegistrarOutOfOrderAndIdempotentUnregisterPreservesStack() {
    val name = "unitTestFlutterApiStack"
    val api1 = FakeReservedNamesFlutterApi("engine1")
    val api2 = FakeReservedNamesFlutterApi("engine2")
    val neverRegistered = FakeReservedNamesFlutterApi("never")

    NativeInteropReservedNamesFlutterApiRegistrar.register(api1, name)
    NativeInteropReservedNamesFlutterApiRegistrar.register(api2, name)
    assertEquals(
        "engine2:ping",
        NativeInteropReservedNamesFlutterApiRegistrar.getInstance(name)?.release("ping"),
    )

    // Out-of-order unregister of api1 leaves api2 active.
    NativeInteropReservedNamesFlutterApiRegistrar.unregister(api1, name)
    // Duplicate unregister of api1 and unregister of a never-registered instance are safe no-ops.
    NativeInteropReservedNamesFlutterApiRegistrar.unregister(api1, name)
    NativeInteropReservedNamesFlutterApiRegistrar.unregister(neverRegistered, name)
    assertEquals(
        "engine2:ping",
        NativeInteropReservedNamesFlutterApiRegistrar.getInstance(name)?.release("ping"),
    )

    NativeInteropReservedNamesFlutterApiRegistrar.unregister(api2, name)
    assertNull(NativeInteropReservedNamesFlutterApiRegistrar.getInstance(name))
  }

  @Test
  fun flutterApiReRegisteringSameInstanceDeduplicatesAndMovesToTop() {
    val name = "unitTestFlutterApiDeduplicate"
    val api1 = FakeReservedNamesFlutterApi("engine1")
    val api2 = FakeReservedNamesFlutterApi("engine2")

    NativeInteropReservedNamesFlutterApiRegistrar.register(api1, name)
    NativeInteropReservedNamesFlutterApiRegistrar.register(api2, name)
    NativeInteropReservedNamesFlutterApiRegistrar.register(api1, name)

    assertEquals(
        "engine1:ping",
        NativeInteropReservedNamesFlutterApiRegistrar.getInstance(name)?.release("ping"),
    )

    // Since api1 was deduplicated rather than duplicated, unregistering api1 once leaves only api2.
    NativeInteropReservedNamesFlutterApiRegistrar.unregister(api1, name)
    assertEquals(
        "engine2:ping",
        NativeInteropReservedNamesFlutterApiRegistrar.getInstance(name)?.release("ping"),
    )
    NativeInteropReservedNamesFlutterApiRegistrar.unregister(api2, name)
    assertNull(NativeInteropReservedNamesFlutterApiRegistrar.getInstance(name))
  }

  @Test
  fun flutterApiDefaultNullNameAndExplicitEmptyStringNameAreDistinct() {
    val defaultApi = FakeReservedNamesFlutterApi("defaultFlutter")
    val emptyNameApi = FakeReservedNamesFlutterApi("emptyStringFlutter")

    NativeInteropReservedNamesFlutterApiRegistrar.register(defaultApi)
    assertNull(NativeInteropReservedNamesFlutterApiRegistrar.getInstance(""))

    NativeInteropReservedNamesFlutterApiRegistrar.register(emptyNameApi, "")
    assertEquals(
        "defaultFlutter:ping",
        NativeInteropReservedNamesFlutterApiRegistrar.getInstance()?.release("ping"),
    )
    assertEquals(
        "emptyStringFlutter:ping",
        NativeInteropReservedNamesFlutterApiRegistrar.getInstance("")?.release("ping"),
    )

    NativeInteropReservedNamesFlutterApiRegistrar.unregister(emptyNameApi, "")
    assertNull(NativeInteropReservedNamesFlutterApiRegistrar.getInstance(""))
    assertEquals(
        "defaultFlutter:ping",
        NativeInteropReservedNamesFlutterApiRegistrar.getInstance()?.release("ping"),
    )

    NativeInteropReservedNamesFlutterApiRegistrar.unregister(defaultApi)
    assertNull(NativeInteropReservedNamesFlutterApiRegistrar.getInstance())
  }
}

private class FakeReservedNamesFlutterApi(private val label: String) :
    NativeInteropReservedNamesFlutterApi {
  override fun release(value: String): String = "$label:$value"

  override fun type(): String = label

  override fun implementIn(value: String): String = "$label:$value"

  override fun isNull(): Boolean = false

  override fun getReference(): String = label

  override fun register(value: String): String = "$label:$value"

  override fun dartApi(): String = label
}

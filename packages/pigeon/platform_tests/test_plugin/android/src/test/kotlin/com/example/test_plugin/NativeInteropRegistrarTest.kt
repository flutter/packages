// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.test_plugin

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
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

  override fun echoReservedNames(names: NativeInteropReservedNames): NativeInteropReservedNames =
      names

  override fun callFlutterRelease(value: String): String = value

  override fun callFlutterType(): String = label

  override fun callFlutterImplementIn(value: String): String = value

  override fun callFlutterIsNull(): Boolean = false

  override fun callFlutterGetReference(): String = label
}

class NativeInteropRegistrarTest {
  @Test
  fun unregisterRemovesSpecificInstanceInAndOutOfOrder() {
    val name = "unitTestOutOfOrder"
    val api1 = FakeReservedNamesHostApi("engine1")
    val api2 = FakeReservedNamesHostApi("engine2")

    val registrar1 = NativeInteropReservedNamesHostApiRegistrar().register(api1, name)
    NativeInteropReservedNamesHostApiRegistrar().register(api2, name)

    assertEquals(
        "engine2:ping",
        NativeInteropReservedNamesHostApiRegistrar().getInstance(name)?.release("ping"),
    )

    // Unregistering engine1 out-of-order leaves engine2 active.
    NativeInteropReservedNamesHostApiRegistrar().unregister(api1, name)
    assertEquals(
        "engine2:ping",
        NativeInteropReservedNamesHostApiRegistrar().getInstance(name)?.release("ping"),
    )
    // Stale registrar1 reference has its internal api cleared.
    assertThrows(IllegalStateException::class.java) { registrar1.release("ping") }

    // Unregistering engine2 clears the registration list completely.
    NativeInteropReservedNamesHostApiRegistrar().unregister(api2, name)
    assertNull(NativeInteropReservedNamesHostApiRegistrar().getInstance(name))
  }

  @Test
  fun registerNullPopsLatestInstanceWithoutClearingEarlierEngines() {
    val name = "unitTestLifoNull"
    val api1 = FakeReservedNamesHostApi("engine1")
    val api2 = FakeReservedNamesHostApi("engine2")

    NativeInteropReservedNamesHostApiRegistrar().register(api1, name)
    val registrar2 = NativeInteropReservedNamesHostApiRegistrar().register(api2, name)

    // Legacy `Registrar().register(null, name)` pops engine2 and preserves engine1.
    NativeInteropReservedNamesHostApiRegistrar().register(null, name)
    assertThrows(IllegalStateException::class.java) { registrar2.release("ping") }
    assertEquals(
        "engine1:ping",
        NativeInteropReservedNamesHostApiRegistrar().getInstance(name)?.release("ping"),
    )

    NativeInteropReservedNamesHostApiRegistrar().register(null, name)
    assertNull(NativeInteropReservedNamesHostApiRegistrar().getInstance(name))
  }

  @Test
  fun registrarHandleRegisterNullRemovesThatHandleOutOfOrder() {
    val name = "unitTestHandleNull"
    val api1 = FakeReservedNamesHostApi("engine1")
    val api2 = FakeReservedNamesHostApi("engine2")

    val registrar1 = NativeInteropReservedNamesHostApiRegistrar().register(api1, name)
    val registrar2 = NativeInteropReservedNamesHostApiRegistrar().register(api2, name)

    // Calling register(null) on registrar1 removes specifically registrar1 even though registrar2
    // was registered more recently.
    registrar1.register(null, name)
    assertThrows(IllegalStateException::class.java) { registrar1.release("ping") }
    val active = NativeInteropReservedNamesHostApiRegistrar().getInstance(name)
    assertNotNull(active)
    assertEquals("engine2:ping", active!!.release("ping"))

    registrar2.register(null, name)
    assertNull(NativeInteropReservedNamesHostApiRegistrar().getInstance(name))
  }

  @Test
  fun reRegisteringSameApiDeduplicatesAndMovesToTop() {
    val name = "unitTestDeduplicate"
    val api1 = FakeReservedNamesHostApi("engine1")
    val api2 = FakeReservedNamesHostApi("engine2")

    NativeInteropReservedNamesHostApiRegistrar().register(api1, name)
    NativeInteropReservedNamesHostApiRegistrar().register(api2, name)
    NativeInteropReservedNamesHostApiRegistrar().register(api1, name)

    assertEquals(
        "engine1:ping",
        NativeInteropReservedNamesHostApiRegistrar().getInstance(name)?.release("ping"),
    )

    // Since api1 was deduplicated rather than duplicated, unregistering api1 once leaves only api2.
    NativeInteropReservedNamesHostApiRegistrar().unregister(api1, name)
    assertEquals(
        "engine2:ping",
        NativeInteropReservedNamesHostApiRegistrar().getInstance(name)?.release("ping"),
    )
    NativeInteropReservedNamesHostApiRegistrar().unregister(api2, name)
    assertNull(NativeInteropReservedNamesHostApiRegistrar().getInstance(name))
  }
}

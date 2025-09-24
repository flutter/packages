// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.test_plugin

import junit.framework.TestCase.assertEquals
import junit.framework.TestCase.assertFalse
import junit.framework.TestCase.assertNotNull
import junit.framework.TestCase.assertNull
import junit.framework.TestCase.assertTrue
import org.junit.Test

class InstanceManagerTest {
  @Test
  fun addDartCreatedInstance() {
    val instanceManager: ProxyApiTestsPigeonInstanceManager = createInstanceManager()
    val testObject = Any()
    instanceManager.addDartCreatedInstance(testObject, 0)

    assertEquals(testObject, instanceManager.getInstance(0))
    assertEquals(0L, instanceManager.getIdentifierForStrongReference(testObject))
    assertTrue(instanceManager.containsInstance(testObject))

    instanceManager.stopFinalizationListener()
  }

  @Test
  fun addHostCreatedInstance() {
    val instanceManager: ProxyApiTestsPigeonInstanceManager = createInstanceManager()
    val testObject = Any()
    val identifier: Long = instanceManager.addHostCreatedInstance(testObject)

    assertNotNull(instanceManager.getInstance(identifier))
    assertEquals(testObject, instanceManager.getInstance(identifier))
    assertTrue(instanceManager.containsInstance(testObject))

    instanceManager.stopFinalizationListener()
  }

  @Test
  fun remove() {
    val instanceManager: ProxyApiTestsPigeonInstanceManager = createInstanceManager()
    var testObject: Any? = Any()
    instanceManager.addDartCreatedInstance(testObject!!, 0)
    assertEquals(testObject, instanceManager.remove(0))

    // To allow for object to be garbage collected.
    @Suppress("UNUSED_VALUE")
    testObject = null
    Runtime.getRuntime().gc()
    assertNull(instanceManager.getInstance(0))

    instanceManager.stopFinalizationListener()
  }

  @Test
  fun clear() {
    val instanceManager: ProxyApiTestsPigeonInstanceManager = createInstanceManager()
    val instance = Any()
    instanceManager.addDartCreatedInstance(instance, 0)

    assertTrue(instanceManager.containsInstance(instance))
    instanceManager.clear()
    assertFalse(instanceManager.containsInstance(instance))

    instanceManager.stopFinalizationListener()
  }

  @Test
  fun canAddSameObjectWithAddDartCreatedInstance() {
    val instanceManager: ProxyApiTestsPigeonInstanceManager = createInstanceManager()
    val instance = Any()
    instanceManager.addDartCreatedInstance(instance, 0)
    instanceManager.addDartCreatedInstance(instance, 1)

    assertTrue(instanceManager.containsInstance(instance))
    assertEquals(instanceManager.getInstance(0), instance)
    assertEquals(instanceManager.getInstance(1), instance)

    instanceManager.stopFinalizationListener()
  }

  @Test(expected = IllegalArgumentException::class)
  fun cannotAddSameObjectsWithAddHostCreatedInstance() {
    val instanceManager: ProxyApiTestsPigeonInstanceManager = createInstanceManager()
    val instance = Any()
    instanceManager.addHostCreatedInstance(instance)
    instanceManager.addHostCreatedInstance(instance)

    instanceManager.stopFinalizationListener()
  }

  @Test(expected = IllegalArgumentException::class)
  fun cannotUseIdentifierLessThanZero() {
    val instanceManager: ProxyApiTestsPigeonInstanceManager = createInstanceManager()
    instanceManager.addDartCreatedInstance(Any(), -1)
    instanceManager.stopFinalizationListener()
  }

  @Test(expected = IllegalArgumentException::class)
  fun identifiersMustBeUnique() {
    val instanceManager: ProxyApiTestsPigeonInstanceManager = createInstanceManager()
    instanceManager.addDartCreatedInstance(Any(), 0)
    instanceManager.addDartCreatedInstance(Any(), 0)

    instanceManager.stopFinalizationListener()
  }

  @Test
  fun managerIsUsableWhileListenerHasStopped() {
    val instanceManager: ProxyApiTestsPigeonInstanceManager = createInstanceManager()
    instanceManager.stopFinalizationListener()
    val instance = Any()
    val identifier: Long = 0
    instanceManager.addDartCreatedInstance(instance, identifier)

    assertEquals(instanceManager.getInstance(identifier), instance)
    assertEquals(instanceManager.getIdentifierForStrongReference(instance), identifier)
    assertTrue(instanceManager.containsInstance(instance))
  }

  @Test
  fun clearPreventsFinalizationOfWeakInstances() {
    var finalizerRan = false
    val instanceManager: ProxyApiTestsPigeonInstanceManager =
        ProxyApiTestsPigeonInstanceManager.create(
            object : ProxyApiTestsPigeonInstanceManager.PigeonFinalizationListener {
              override fun onFinalize(identifier: Long) {
                finalizerRan = true
              }
            })

    var testObject: Any? = Any()
    instanceManager.addDartCreatedInstance(testObject!!, 0)
    instanceManager.remove<Any?>(0)
    instanceManager.clear()

    // To allow for object to be garbage collected.
    @Suppress("UNUSED_VALUE")
    testObject = null
    Runtime.getRuntime().gc()

    // Changing this value triggers the callback.
    instanceManager.clearFinalizedWeakReferencesInterval = 1000
    instanceManager.stopFinalizationListener()

    assertNull(instanceManager.getInstance<Any?>(0))
    assertFalse(finalizerRan)
  }

  private fun createInstanceManager(): ProxyApiTestsPigeonInstanceManager {
    return ProxyApiTestsPigeonInstanceManager.create(
        object : ProxyApiTestsPigeonInstanceManager.PigeonFinalizationListener {
          override fun onFinalize(identifier: Long) {}
        })
  }
}

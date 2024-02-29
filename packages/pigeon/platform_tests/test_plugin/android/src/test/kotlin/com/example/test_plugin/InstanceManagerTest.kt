// Copyright 2013 The Flutter Authors. All rights reserved.
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
    val instanceManager: PigeonInstanceManager = createInstanceManager()
    val testObject = Any()
    instanceManager.addDartCreatedInstance(testObject, 0)

    assertEquals(testObject, instanceManager.getInstance(0))
    assertEquals(0L, instanceManager.getIdentifierForStrongReference(testObject))
    assertTrue(instanceManager.containsInstance(testObject))

    instanceManager.stopFinalizationListener()
  }

  @Test
  fun addHostCreatedInstance() {
    val instanceManager: PigeonInstanceManager = createInstanceManager()
    val testObject = Any()
    val identifier: Long = instanceManager.addHostCreatedInstance(testObject)

    assertNotNull(instanceManager.getInstance(identifier))
    assertEquals(testObject, instanceManager.getInstance(identifier))
    assertTrue(instanceManager.containsInstance(testObject))

    instanceManager.stopFinalizationListener()
  }

  @Test
  fun remove() {
    val instanceManager: PigeonInstanceManager = createInstanceManager()
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
    val instanceManager: PigeonInstanceManager = createInstanceManager()
    val instance = Any()
    instanceManager.addDartCreatedInstance(instance, 0)

    assertTrue(instanceManager.containsInstance(instance))
    instanceManager.clear()
    assertFalse(instanceManager.containsInstance(instance))

    instanceManager.stopFinalizationListener()
  }

  @Test
  fun canAddSameObjectWithAddDartCreatedInstance() {
    val instanceManager: PigeonInstanceManager = createInstanceManager()
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
    val instanceManager: PigeonInstanceManager = createInstanceManager()
    val instance = Any()
    instanceManager.addHostCreatedInstance(instance)
    instanceManager.addHostCreatedInstance(instance)

    instanceManager.stopFinalizationListener()
  }

  @Test(expected = IllegalArgumentException::class)
  fun cannotUseIdentifierLessThanZero() {
    val instanceManager: PigeonInstanceManager = createInstanceManager()
    instanceManager.addDartCreatedInstance(Any(), -1)
    instanceManager.stopFinalizationListener()
  }

  @Test(expected = IllegalArgumentException::class)
  fun identifiersMustBeUnique() {
    val instanceManager: PigeonInstanceManager = createInstanceManager()
    instanceManager.addDartCreatedInstance(Any(), 0)
    instanceManager.addDartCreatedInstance(Any(), 0)

    instanceManager.stopFinalizationListener()
  }

  @Test
  fun managerIsUsableWhileListenerHasStopped() {
    val instanceManager: PigeonInstanceManager = createInstanceManager()
    instanceManager.stopFinalizationListener()
    val instance = Any()
    val identifier: Long = 0
    instanceManager.addDartCreatedInstance(instance, identifier)

    assertEquals(instanceManager.getInstance(identifier), instance)
    assertEquals(instanceManager.getIdentifierForStrongReference(instance), identifier)
    assertTrue(instanceManager.containsInstance(instance))
  }

  private fun createInstanceManager(): PigeonInstanceManager {
    return PigeonInstanceManager.create(
      object : PigeonInstanceManager.PigeonFinalizationListener {
        override fun onFinalize(identifier: Long) {}
      })
  }
}
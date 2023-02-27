package com.example.wrapper_example;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import org.junit.Test;

public class InstanceManagerTest {
  @Test
  public void addDartCreatedInstance() {
    final InstanceManager instanceManager = InstanceManager.open(identifier -> {});

    final Object object = new Object();
    instanceManager.addDartCreatedInstance(object, 0);

    assertEquals(object, instanceManager.getInstance(0));
    assertEquals((Long) 0L, instanceManager.getIdentifierForStrongReference(object));
    assertTrue(instanceManager.containsInstance(object));

    instanceManager.close();
  }

  @Test
  public void addHostCreatedInstance() {
    final InstanceManager instanceManager = InstanceManager.open(identifier -> {});

    final Object object = new Object();
    long identifier = instanceManager.addHostCreatedInstance(object);

    assertNotNull(instanceManager.getInstance(identifier));
    assertEquals(object, instanceManager.getInstance(identifier));
    assertTrue(instanceManager.containsInstance(object));

    instanceManager.close();
  }

  @Test
  public void remove() {
    final InstanceManager instanceManager = InstanceManager.open(identifier -> {});

    Object object = new Object();
    instanceManager.addDartCreatedInstance(object, 0);

    assertEquals(object, instanceManager.remove(0));

    // To allow for object to be garbage collected.
    //noinspection UnusedAssignment
    object = null;

    Runtime.getRuntime().gc();

    assertNull(instanceManager.getInstance(0));

    instanceManager.close();
  }

  @Test
  public void removeReturnsNullWhenClosed() {
    final Object object = new Object();
    final InstanceManager instanceManager = InstanceManager.open(identifier -> {});
    instanceManager.addDartCreatedInstance(object, 0);
    instanceManager.close();

    assertNull(instanceManager.remove(0));
  }

  @Test
  public void getIdentifierForStrongReferenceReturnsNullWhenClosed() {
    final Object object = new Object();
    final InstanceManager instanceManager = InstanceManager.open(identifier -> {});
    instanceManager.addDartCreatedInstance(object, 0);
    instanceManager.close();

    assertNull(instanceManager.getIdentifierForStrongReference(object));
  }

  @Test
  public void addHostCreatedInstanceReturnsNegativeOneWhenClosed() {
    final InstanceManager instanceManager = InstanceManager.open(identifier -> {});
    instanceManager.close();

    assertEquals(instanceManager.addHostCreatedInstance(new Object()), -1L);
  }

  @Test
  public void getInstanceReturnsNullWhenClosed() {
    final Object object = new Object();
    final InstanceManager instanceManager = InstanceManager.open(identifier -> {});
    instanceManager.addDartCreatedInstance(object, 0);
    instanceManager.close();

    assertNull(instanceManager.getInstance(0));
  }

  @Test
  public void containsInstanceReturnsFalseWhenClosed() {
    final Object object = new Object();
    final InstanceManager instanceManager = InstanceManager.open(identifier -> {});
    instanceManager.addDartCreatedInstance(object, 0);
    instanceManager.close();

    assertFalse(instanceManager.containsInstance(object));
  }

  @Test
  public void clear() {
    final InstanceManager instanceManager = InstanceManager.open(identifier -> {});

    final Object instance = new Object();

    instanceManager.addDartCreatedInstance(instance, 0);
    assertTrue(instanceManager.containsInstance(instance));

    instanceManager.clear();
    assertFalse(instanceManager.containsInstance(instance));

    instanceManager.close();
  }

  @Test
  public void canAddSameObjectWithAddDartCreatedInstance() {
    final InstanceManager instanceManager = InstanceManager.open(identifier -> {});

    final Object instance = new Object();

    instanceManager.addDartCreatedInstance(instance, 0);
    instanceManager.addDartCreatedInstance(instance, 1);

    assertTrue(instanceManager.containsInstance(instance));

    assertEquals(instanceManager.getInstance(0), instance);
    assertEquals(instanceManager.getInstance(1), instance);

    instanceManager.close();
  }

  @Test(expected = IllegalArgumentException.class)
  public void cannotAddSameObjectsWithAddHostCreatedInstance() {
    final InstanceManager instanceManager = InstanceManager.open(identifier -> {});

    final Object instance = new Object();

    instanceManager.addHostCreatedInstance(instance);
    instanceManager.addHostCreatedInstance(instance);

    instanceManager.close();
  }

  @Test(expected = IllegalArgumentException.class)
  public void cannotUseIdentifierLessThanZero() {
    final InstanceManager instanceManager = InstanceManager.open(identifier -> {});

    instanceManager.addDartCreatedInstance(new Object(), -1);

    instanceManager.close();
  }

  @Test(expected = IllegalArgumentException.class)
  public void identifiersMustBeUnique() {
    final InstanceManager instanceManager = InstanceManager.open(identifier -> {});

    instanceManager.addDartCreatedInstance(new Object(), 0);
    instanceManager.addDartCreatedInstance(new Object(), 0);

    instanceManager.close();
  }
}

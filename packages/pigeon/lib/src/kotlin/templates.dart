// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../generator_tools.dart';
import 'kotlin_generator.dart';

/// Name of the Kotlin `InstanceManager`.
String kotlinInstanceManagerClassName(InternalKotlinOptions options) =>
    '${options.fileSpecificClassNameComponent ?? ''}${proxyApiClassNamePrefix}InstanceManager';

/// The name of the registrar containing all the ProxyApi implementations.
String proxyApiRegistrarName(InternalKotlinOptions options) =>
    '${options.fileSpecificClassNameComponent ?? ''}${proxyApiClassNamePrefix}ProxyApiRegistrar';

/// The name of the codec that handles ProxyApis.
String proxyApiCodecName(InternalKotlinOptions options) =>
    '${options.fileSpecificClassNameComponent ?? ''}${proxyApiClassNamePrefix}ProxyApiBaseCodec';

/// The Kotlin `InstanceManager`.
String instanceManagerTemplate(InternalKotlinOptions options) {
  return '''
/**
 * Maintains instances used to communicate with the corresponding objects in Dart.
 *
 * Objects stored in this container are represented by an object in Dart that is also stored in
 * an InstanceManager with the same identifier.
 *
 * When an instance is added with an identifier, either can be used to retrieve the other.
 *
 * Added instances are added as a weak reference and a strong reference. When the strong
 * reference is removed with [remove] and the weak reference is deallocated, the
 * `finalizationListener.onFinalize` is called with the instance's identifier. However, if the strong
 * reference is removed and then the identifier is retrieved with the intention to pass the identifier
 * to Dart (e.g. calling [getIdentifierForStrongReference]), the strong reference to the instance
 * is recreated. The strong reference will then need to be removed manually again.
 */
@Suppress("UNCHECKED_CAST", "MemberVisibilityCanBePrivate")
class ${kotlinInstanceManagerClassName(options)}(private val finalizationListener: $_finalizationListenerClassName) {
  /** Interface for listening when a weak reference of an instance is removed from the manager.  */
  interface $_finalizationListenerClassName {
    fun onFinalize(identifier: Long)
  }

  private val identifiers = java.util.WeakHashMap<Any, Long>()
  private val weakInstances = HashMap<Long, java.lang.ref.WeakReference<Any>>()
  private val strongInstances = HashMap<Long, Any>()
  private val referenceQueue = java.lang.ref.ReferenceQueue<Any>()
  private val weakReferencesToIdentifiers = HashMap<java.lang.ref.WeakReference<Any>, Long>()
  private val handler = android.os.Handler(android.os.Looper.getMainLooper())
  private val releaseAllFinalizedInstancesRunnable = Runnable {
    this.releaseAllFinalizedInstances()
  }
  private var nextIdentifier: Long = minHostCreatedIdentifier
  private var hasFinalizationListenerStopped = false

  /**
   * Modifies the time interval used to define how often this instance removes garbage collected
   * weak references to native Android objects that this instance was managing.
   */
  var clearFinalizedWeakReferencesInterval: Long = 3000
    set(value) {
      handler.removeCallbacks(releaseAllFinalizedInstancesRunnable)
      field = value
      releaseAllFinalizedInstances()
    }

  init {
    handler.postDelayed(releaseAllFinalizedInstancesRunnable, clearFinalizedWeakReferencesInterval)
  }

  companion object {
    // Identifiers are locked to a specific range to avoid collisions with objects
    // created simultaneously from Dart.
    // Host uses identifiers >= 2^16 and Dart is expected to use values n where,
    // 0 <= n < 2^16.
    private const val minHostCreatedIdentifier: Long = 65536
    private const val tag = "${proxyApiClassNamePrefix}InstanceManager"

    /**
     * Instantiate a new manager with a listener for garbage collected weak
     * references.
     *
     * When the manager is no longer needed, [stopFinalizationListener] must be called.
     */
    fun create(finalizationListener: $_finalizationListenerClassName): ${kotlinInstanceManagerClassName(options)} {
      return ${kotlinInstanceManagerClassName(options)}(finalizationListener)
    }
  }

  /**
   * Removes `identifier` and return its associated strongly referenced instance, if present,
   * from the manager.
   */
  fun <T> remove(identifier: Long): T? {
    logWarningIfFinalizationListenerHasStopped()
    return strongInstances.remove(identifier) as T?
  }

  /**
   * Retrieves the identifier paired with an instance, if present, otherwise `null`.
   *
   *
   * If the manager contains a strong reference to `instance`, it will return the identifier
   * associated with `instance`. If the manager contains only a weak reference to `instance`, a new
   * strong reference to `instance` will be added and will need to be removed again with [remove].
   *
   *
   * If this method returns a nonnull identifier, this method also expects the Dart
   * `${kotlinInstanceManagerClassName(options)}` to have, or recreate, a weak reference to the Dart instance the
   * identifier is associated with.
   */
  fun getIdentifierForStrongReference(instance: Any?): Long? {
    logWarningIfFinalizationListenerHasStopped()
    val identifier = identifiers[instance]
    if (identifier != null) {
      strongInstances[identifier] = instance!!
    }
    return identifier
  }

  /**
   * Adds a new instance that was instantiated from Dart.
   *
   * The same instance can be added multiple times, but each identifier must be unique. This
   * allows two objects that are equivalent (e.g. the `equals` method returns true and their
   * hashcodes are equal) to both be added.
   *
   * [identifier] must be >= 0 and unique.
   */
  fun addDartCreatedInstance(instance: Any, identifier: Long) {
    logWarningIfFinalizationListenerHasStopped()
    addInstance(instance, identifier)
  }

  /**
   * Adds a new unique instance that was instantiated from the host platform.
   *
   * If the manager contains [instance], this returns the corresponding identifier. If the
   * manager does not contain [instance], this adds the instance and returns a unique
   * identifier for that [instance].
   */
  fun addHostCreatedInstance(instance: Any): Long {
    logWarningIfFinalizationListenerHasStopped()
    require(!containsInstance(instance)) { "Instance of \${instance.javaClass} has already been added." }
    val identifier = nextIdentifier++
    addInstance(instance, identifier)
    return identifier
  }

  /** Retrieves the instance associated with identifier, if present, otherwise `null`. */
  fun <T> getInstance(identifier: Long): T? {
    logWarningIfFinalizationListenerHasStopped()
    val instance = weakInstances[identifier] as java.lang.ref.WeakReference<T>?
    return instance?.get()
  }

  /** Returns whether this manager contains the given `instance`. */
  fun containsInstance(instance: Any?): Boolean {
    logWarningIfFinalizationListenerHasStopped()
    return identifiers.containsKey(instance)
  }

  /**
   * Stops the periodic run of the [$_finalizationListenerClassName] for instances that have been garbage
   * collected.
   *
   * The InstanceManager can continue to be used, but the [$_finalizationListenerClassName] will no
   * longer be called and methods will log a warning.
   */
  fun stopFinalizationListener() {
    handler.removeCallbacks(releaseAllFinalizedInstancesRunnable)
    hasFinalizationListenerStopped = true
  }

  /**
   * Removes all of the instances from this manager.
   *
   * The manager will be empty after this call returns.
   */
  fun clear() {
    identifiers.clear()
    weakInstances.clear()
    strongInstances.clear()
    weakReferencesToIdentifiers.clear()
  }

  /**
   * Whether the [$_finalizationListenerClassName] is still being called for instances that are garbage
   * collected.
   *
   * See [stopFinalizationListener].
   */
  fun hasFinalizationListenerStopped(): Boolean {
    return hasFinalizationListenerStopped
  }

  private fun releaseAllFinalizedInstances() {
    if (hasFinalizationListenerStopped()) {
      return
    }
    var reference: java.lang.ref.WeakReference<Any>?
    while ((referenceQueue.poll() as java.lang.ref.WeakReference<Any>?).also { reference = it } != null) {
      val identifier = weakReferencesToIdentifiers.remove(reference)
      if (identifier != null) {
        weakInstances.remove(identifier)
        strongInstances.remove(identifier)
        finalizationListener.onFinalize(identifier)
      }
    }
    handler.postDelayed(releaseAllFinalizedInstancesRunnable, clearFinalizedWeakReferencesInterval)
  }

  private fun addInstance(instance: Any, identifier: Long) {
    require(identifier >= 0) { "Identifier must be >= 0: \$identifier" }
    require(!weakInstances.containsKey(identifier)) {
      "Identifier has already been added: \$identifier"
    }
    val weakReference = java.lang.ref.WeakReference(instance, referenceQueue)
    identifiers[instance] = identifier
    weakInstances[identifier] = weakReference
    weakReferencesToIdentifiers[weakReference] = identifier
    strongInstances[identifier] = instance
  }

  private fun logWarningIfFinalizationListenerHasStopped() {
    if (hasFinalizationListenerStopped()) {
      Log.w(
        tag,
        "The manager was used after calls to the $_finalizationListenerClassName has been stopped."
      )
    }
  }
}
''';
}

const String _finalizationListenerClassName =
    '${proxyApiClassNamePrefix}FinalizationListener';

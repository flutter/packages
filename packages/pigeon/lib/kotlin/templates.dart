// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../generator_tools.dart';

/// The Kotlin `InstanceManager`.
const String instanceManagerTemplate = '''
/**
 * Maintains instances used to communicate with the corresponding objects in Dart.
 *
 * <p>Objects stored in this container are represented by an object in Dart that is also stored in
 * an InstanceManager with the same identifier.
 *
 * <p>When an instance is added with an identifier, either can be used to retrieve the other.
 *
 * <p>Added instances are added as a weak reference and a strong reference. When the strong
 * reference is removed with [remove] and the weak reference is deallocated, the
 * `finalizationListener` is made with the instance's identifier. However, if the strong reference
 * is removed and then the identifier is retrieved with the intention to pass the identifier to Dart
 * (e.g. calling [getIdentifierForStrongReference]), the strong reference to the
 * instance is recreated. The strong reference will then need to be removed manually again.
 */
@Suppress("UNCHECKED_CAST", "MemberVisibilityCanBePrivate", "unused")
class $instanceManagerClassName(private val finalizationListener: $_finalizationListenerClassName) {
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
  private var nextIdentifier: Long = minHostCreatedIdentifier
  private var hasFinalizationListenerStopped = false

  /**
   * Modifies the time interval used to define how often this instance removes garbage collected
   * weak references to native Android objects that this instance was managing.
   */
  var clearFinalizedWeakReferencesInterval: Long = 3000
    set(value) {
      handler.removeCallbacks { this.releaseAllFinalizedInstances() }
      field = value
      releaseAllFinalizedInstances()
    }

  init {
    handler.postDelayed(
      { releaseAllFinalizedInstances() },
      clearFinalizedWeakReferencesInterval
    )
  }

  companion object {
    // Identifiers are locked to a specific range to avoid collisions with objects
    // created simultaneously from Dart.
    // Host uses identifiers >= 2^16 and Dart is expected to use values n where,
    // 0 <= n < 2^16.
    private const val minHostCreatedIdentifier: Long = 65536
    private const val tag = "$instanceManagerClassName"

    /**
     * Instantiate a new manager.
     *
     *
     * When the manager is no longer needed, [stopFinalizationListener] must be called.
     *
     * @param finalizationListener the listener for garbage collected weak references.
     * @return a new `$instanceManagerClassName`.
     */
    fun create(finalizationListener: $_finalizationListenerClassName): $instanceManagerClassName {
      return $instanceManagerClassName(finalizationListener)
    }
  }

  /**
   * Removes `identifier` and its associated strongly referenced instance, if present, from the
   * manager.
   *
   * @param identifier the identifier paired to an instance.
   * @param <T> the expected return type.
   * @return the removed instance if the manager contains the given identifier, otherwise `null` if
   * the manager doesn't contain the value.
  </T> */
  fun <T> remove(identifier: Long): T? {
    logWarningIfFinalizationListenerHasStopped()
    return strongInstances.remove(identifier) as T?
  }

  /**
   * Retrieves the identifier paired with an instance.
   *
   *
   * If the manager contains a strong reference to `instance`, it will return the identifier
   * associated with `instance`. If the manager contains only a weak reference to `instance`, a new
   * strong reference to `instance` will be added and will need to be removed again with [remove].
   *
   *
   * If this method returns a nonnull identifier, this method also expects the Dart
   * `$instanceManagerClassName` to have, or recreate, a weak reference to the Dart instance the
   * identifier is associated with.
   *
   * @param instance an instance that may be stored in the manager.
   * @return the identifier associated with `instance` if the manager contains the value, otherwise
   * `null` if the manager doesn't contain the value.
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
   *
   * The same instance can be added multiple times, but each identifier must be unique. This
   * allows two objects that are equivalent (e.g. the `equals` method returns true and their
   * hashcodes are equal) to both be added.
   *
   * @param instance the instance to be stored.
   * @param identifier the identifier to be paired with instance. This value must be >= 0 and
   * unique.
   */
  fun addDartCreatedInstance(instance: Any, identifier: Long) {
    logWarningIfFinalizationListenerHasStopped()
    addInstance(instance, identifier)
  }

  /**
   * Adds a new instance that was instantiated from the host platform.
   *
   * @param instance the instance to be stored. This must be unique to all other added instances.
   * @return the unique identifier (>= 0) stored with instance.
   */
  fun addHostCreatedInstance(instance: Any): Long {
    logWarningIfFinalizationListenerHasStopped()
    require(!containsInstance(instance)) { "Instance of \${instance.javaClass} has already been added." }
    val identifier = nextIdentifier++
    addInstance(instance, identifier)
    return identifier
  }

  /**
   * Retrieves the instance associated with identifier.
   *
   * @param identifier the identifier associated with an instance.
   * @param <T> the expected return type.
   * @return the instance associated with `identifier` if the manager contains the value, otherwise
   * `null` if the manager doesn't contain the value.
  </T> */
  fun <T> getInstance(identifier: Long): T? {
    logWarningIfFinalizationListenerHasStopped()
    val instance = weakInstances[identifier] as java.lang.ref.WeakReference<T>?
    return instance?.get()
  }

  /**
   * Returns whether this manager contains the given `instance`.
   *
   * @param instance the instance whose presence in this manager is to be tested.
   * @return whether this manager contains the given `instance`.
   */
  fun containsInstance(instance: Any?): Boolean {
    logWarningIfFinalizationListenerHasStopped()
    return identifiers.containsKey(instance)
  }

  /**
   * Stop the periodic run of the [$_finalizationListenerClassName] for instances that have been garbage
   * collected.
   *
   *
   * The InstanceManager can continue to be used, but the [$_finalizationListenerClassName] will no
   * longer be called and methods will log a warning.
   */
  fun stopFinalizationListener() {
    handler.removeCallbacks { this.releaseAllFinalizedInstances() }
    hasFinalizationListenerStopped = true
  }

  /**
   * Removes all of the instances from this manager.
   *
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
    handler.postDelayed(
      { releaseAllFinalizedInstances() },
      clearFinalizedWeakReferencesInterval
    )
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

/// Creates the `InstanceManagerApi` with the passed string values.
String instanceManagerApiTemplate({
  required String dartPackageName,
  required String errorClassName,
}) {
  final String removeStrongReferenceName = makeChannelNameWithStrings(
    apiName: _instanceManagerApiName,
    methodName: 'removeStrongReference',
    dartPackageName: dartPackageName,
  );
  final String clearName = makeChannelNameWithStrings(
    apiName: _instanceManagerApiName,
    methodName: 'clear',
    dartPackageName: dartPackageName,
  );
  return '''
/**
* Generated API for managing the Dart and native `$instanceManagerClassName`s.
*/
private class $_instanceManagerApiName(val binaryMessenger: BinaryMessenger) {
  companion object {
    /** The codec used by $_instanceManagerApiName. */
    val codec: MessageCodec<Any?> by lazy {
      StandardMessageCodec()
    }

    /**
    * Sets up an instance of `$_instanceManagerApiName` to handle messages from the
    * `binaryMessenger`.
    */
    fun setUpMessageHandlers(binaryMessenger: BinaryMessenger, instanceManager: $instanceManagerClassName?) {
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "$removeStrongReferenceName", codec)
        if (instanceManager != null) {
          channel.setMessageHandler { message, reply ->
            val identifier = message as Number
            val wrapped: List<Any?> = try {
              instanceManager.remove<Any?>(identifier.toLong())
              listOf<Any?>(null)
            } catch (exception: Throwable) {
              wrapError(exception)
            }
            reply.reply(wrapped)
          }
        } else {
          channel.setMessageHandler(null)
        }  
      }
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "$clearName", codec)
        if (instanceManager != null) {
          channel.setMessageHandler { _, reply ->
            val wrapped: List<Any?> = try {
              instanceManager.clear()
              listOf<Any?>(null)
            } catch (exception: Throwable) {
              wrapError(exception)
            }
            reply.reply(wrapped)
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
    }
  }

  fun removeStrongReference(identifier: Long, callback: (Result<Unit>) -> Unit) {
    val channelName = "$removeStrongReferenceName"
    val channel = BasicMessageChannel<Any?>(binaryMessenger, channelName, codec)
    channel.send(identifier) {
      if (it is List<*>) {
        if (it.size > 1) {
          callback(Result.failure($errorClassName(it[0] as String, it[1] as String, it[2] as String?)))
        } else {
          callback(Result.success(Unit))
        }
      } else {
        callback(Result.failure(createConnectionError(channelName)))
      }
    }
  }
}
''';
}

const String _instanceManagerApiName = '${instanceManagerClassName}Api';

const String _finalizationListenerClassName =
    '${classNamePrefix}FinalizationListener';

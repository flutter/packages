// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';

import 'ast.dart';
import 'functional.dart';
import 'generator.dart';
import 'generator_tools.dart';
import 'pigeon_lib.dart' show TaskQueueType;

/// Documentation open symbol.
const String _docCommentPrefix = '/**';

/// Documentation continuation symbol.
const String _docCommentContinuation = ' *';

/// Documentation close symbol.
const String _docCommentSuffix = ' */';

/// Documentation comment spec.
const DocumentCommentSpecification _docCommentSpec =
    DocumentCommentSpecification(
  _docCommentPrefix,
  closeCommentToken: _docCommentSuffix,
  blockContinuationToken: _docCommentContinuation,
);

/// Options that control how Kotlin code will be generated.
class KotlinOptions {
  /// Creates a [KotlinOptions] object
  const KotlinOptions({
    this.package,
    this.copyrightHeader,
    this.errorClassName,
  });

  /// The package where the generated class will live.
  final String? package;

  /// A copyright header that will get prepended to generated code.
  final Iterable<String>? copyrightHeader;

  /// The name of the error class used for passing custom error parameters.
  final String? errorClassName;

  /// Creates a [KotlinOptions] from a Map representation where:
  /// `x = KotlinOptions.fromMap(x.toMap())`.
  static KotlinOptions fromMap(Map<String, Object> map) {
    return KotlinOptions(
      package: map['package'] as String?,
      copyrightHeader: map['copyrightHeader'] as Iterable<String>?,
      errorClassName: map['errorClassName'] as String?,
    );
  }

  /// Converts a [KotlinOptions] to a Map representation where:
  /// `x = KotlinOptions.fromMap(x.toMap())`.
  Map<String, Object> toMap() {
    final Map<String, Object> result = <String, Object>{
      if (package != null) 'package': package!,
      if (copyrightHeader != null) 'copyrightHeader': copyrightHeader!,
      if (errorClassName != null) 'errorClassName': errorClassName!,
    };
    return result;
  }

  /// Overrides any non-null parameters from [options] into this to make a new
  /// [KotlinOptions].
  KotlinOptions merge(KotlinOptions options) {
    return KotlinOptions.fromMap(mergeMaps(toMap(), options.toMap()));
  }
}

/// Options that control how Kotlin code will be generated for a specific
/// ProxyApi.
class KotlinProxyApiOptions {
  /// Construct a [KotlinProxyApiOptions].
  const KotlinProxyApiOptions({required this.fullClassName});

  /// The name of the full runtime Kotlin class name (including the package).
  final String fullClassName;
}

/// Class that manages all Kotlin code generation.
class KotlinGenerator extends StructuredGenerator<KotlinOptions> {
  /// Instantiates a Kotlin Generator.
  const KotlinGenerator();

  @override
  void writeFilePrologue(
    KotlinOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    if (generatorOptions.copyrightHeader != null) {
      addLines(indent, generatorOptions.copyrightHeader!, linePrefix: '// ');
    }
    indent.writeln('// ${getGeneratedCodeWarning()}');
    indent.writeln('// $seeAlsoWarning');
  }

  @override
  void writeFileImports(
    KotlinOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.newln();
    if (generatorOptions.package != null) {
      indent.writeln('package ${generatorOptions.package}');
    }
    indent.newln();
    final bool hasProxyApis = root.apis.any((Api api) => api is AstProxyApi);
    if (hasProxyApis) {
      indent.writeln('import android.os.Handler');
      indent.writeln('import android.os.Looper');
    }
    indent.writeln('import android.util.Log');
    indent.writeln('import io.flutter.plugin.common.BasicMessageChannel');
    indent.writeln('import io.flutter.plugin.common.BinaryMessenger');
    indent.writeln('import io.flutter.plugin.common.MessageCodec');
    indent.writeln('import io.flutter.plugin.common.StandardMessageCodec');
    indent.writeln('import java.io.ByteArrayOutputStream');
    if (hasProxyApis) {
      indent.writeln('import java.lang.ref.ReferenceQueue');
      indent.writeln('import java.lang.ref.WeakReference');
    }
    indent.writeln('import java.nio.ByteBuffer');
    if (hasProxyApis) {
      indent.writeln('import java.util.WeakHashMap');
    }
  }

  @override
  void writeEnum(
    KotlinOptions generatorOptions,
    Root root,
    Indent indent,
    Enum anEnum, {
    required String dartPackageName,
  }) {
    indent.newln();
    addDocumentationComments(
        indent, anEnum.documentationComments, _docCommentSpec);
    indent.write('enum class ${anEnum.name}(val raw: Int) ');
    indent.addScoped('{', '}', () {
      anEnum.members.forEachIndexed((int index, final EnumMember member) {
        addDocumentationComments(
            indent, member.documentationComments, _docCommentSpec);
        indent.write('${member.name.toUpperCase()}($index)');
        if (index != anEnum.members.length - 1) {
          indent.addln(',');
        } else {
          indent.addln(';');
        }
      });

      indent.newln();
      indent.write('companion object ');
      indent.addScoped('{', '}', () {
        indent.write('fun ofRaw(raw: Int): ${anEnum.name}? ');
        indent.addScoped('{', '}', () {
          indent.writeln('return values().firstOrNull { it.raw == raw }');
        });
      });
    });
  }

  @override
  void writeDataClass(
    KotlinOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    const List<String> generatedMessages = <String>[
      ' Generated class from Pigeon that represents data sent in messages.'
    ];
    indent.newln();
    addDocumentationComments(
        indent, classDefinition.documentationComments, _docCommentSpec,
        generatorComments: generatedMessages);

    indent.write('data class ${classDefinition.name} ');
    indent.addScoped('(', '', () {
      for (final NamedType element
          in getFieldsInSerializationOrder(classDefinition)) {
        _writeClassField(indent, element);
        if (getFieldsInSerializationOrder(classDefinition).last != element) {
          indent.addln(',');
        } else {
          indent.newln();
        }
      }
    });

    indent.addScoped(') {', '}', () {
      writeClassDecode(
        generatorOptions,
        root,
        indent,
        classDefinition,
        dartPackageName: dartPackageName,
      );
      writeClassEncode(
        generatorOptions,
        root,
        indent,
        classDefinition,
        dartPackageName: dartPackageName,
      );
    });
  }

  @override
  void writeClassEncode(
    KotlinOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    indent.write('fun toList(): List<Any?> ');
    indent.addScoped('{', '}', () {
      indent.write('return listOf<Any?>');
      indent.addScoped('(', ')', () {
        for (final NamedType field
            in getFieldsInSerializationOrder(classDefinition)) {
          final HostDatatype hostDatatype = _getHostDatatype(root, field);
          String toWriteValue = '';
          final String fieldName = field.name;
          final String safeCall = field.type.isNullable ? '?' : '';
          if (field.type.isClass) {
            toWriteValue = '$fieldName$safeCall.toList()';
          } else if (!hostDatatype.isBuiltin && field.type.isEnum) {
            toWriteValue = '$fieldName$safeCall.raw';
          } else {
            toWriteValue = fieldName;
          }
          indent.writeln('$toWriteValue,');
        }
      });
    });
  }

  @override
  void writeClassDecode(
    KotlinOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    final String className = classDefinition.name;

    indent.write('companion object ');
    indent.addScoped('{', '}', () {
      indent.writeln('@Suppress("UNCHECKED_CAST")');
      indent.write('fun fromList(list: List<Any?>): $className ');

      indent.addScoped('{', '}', () {
        getFieldsInSerializationOrder(classDefinition)
            .forEachIndexed((int index, final NamedType field) {
          final String listValue = 'list[$index]';
          final String fieldType = _kotlinTypeForDartType(field.type);

          if (field.type.isNullable) {
            if (field.type.isClass) {
              indent.write('val ${field.name}: $fieldType? = ');
              indent.add('($listValue as List<Any?>?)?.let ');
              indent.addScoped('{', '}', () {
                indent.writeln('$fieldType.fromList(it)');
              });
            } else if (field.type.isEnum) {
              indent.write('val ${field.name}: $fieldType? = ');
              indent.add('($listValue as Int?)?.let ');
              indent.addScoped('{', '}', () {
                indent.writeln('$fieldType.ofRaw(it)');
              });
            } else {
              indent.writeln(
                  'val ${field.name} = ${_cast(indent, listValue, type: field.type)}');
            }
          } else {
            if (field.type.isClass) {
              indent.writeln(
                  'val ${field.name} = $fieldType.fromList($listValue as List<Any?>)');
            } else if (field.type.isEnum) {
              indent.writeln(
                  'val ${field.name} = $fieldType.ofRaw($listValue as Int)!!');
            } else {
              indent.writeln(
                  'val ${field.name} = ${_cast(indent, listValue, type: field.type)}');
            }
          }
        });

        indent.write('return $className(');
        for (final NamedType field
            in getFieldsInSerializationOrder(classDefinition)) {
          final String comma =
              getFieldsInSerializationOrder(classDefinition).last == field
                  ? ''
                  : ', ';
          indent.add('${field.name}$comma');
        }
        indent.addln(')');
      });
    });
  }

  void _writeClassField(Indent indent, NamedType field) {
    addDocumentationComments(
        indent, field.documentationComments, _docCommentSpec);
    indent.write(
        'val ${field.name}: ${_nullsafeKotlinTypeForDartType(field.type)}');
    final String defaultNil = field.type.isNullable ? ' = null' : '';
    indent.add(defaultNil);
  }

  @override
  void writeApis(
    KotlinOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    if (root.apis.any((Api api) =>
        api is AstHostApi &&
        api.methods.any((Method it) => it.isAsynchronous))) {
      indent.newln();
    }
    super.writeApis(generatorOptions, root, indent,
        dartPackageName: dartPackageName);
  }

  /// Writes the code for a flutter [Api], [api].
  /// Example:
  /// class Foo(private val binaryMessenger: BinaryMessenger) {
  ///   fun add(x: Int, y: Int, callback: (Int?) -> Unit) {...}
  /// }
  @override
  void writeFlutterApi(
    KotlinOptions generatorOptions,
    Root root,
    Indent indent,
    AstFlutterApi api, {
    required String dartPackageName,
  }) {
    final bool isCustomCodec = getCodecClasses(api, root).isNotEmpty;
    if (isCustomCodec) {
      _writeCodec(indent, api, root);
    }

    const List<String> generatedMessages = <String>[
      ' Generated class from Pigeon that represents Flutter messages that can be called from Kotlin.'
    ];
    addDocumentationComments(indent, api.documentationComments, _docCommentSpec,
        generatorComments: generatedMessages);

    final String apiName = api.name;
    indent.writeln('@Suppress("UNCHECKED_CAST")');
    indent
        .write('class $apiName(private val binaryMessenger: BinaryMessenger) ');
    indent.addScoped('{', '}', () {
      indent.write('companion object ');
      indent.addScoped('{', '}', () {
        indent.writeln('/** The codec used by $apiName. */');
        indent.write('val codec: MessageCodec<Any?> by lazy ');
        indent.addScoped('{', '}', () {
          if (isCustomCodec) {
            indent.writeln(_getCodecName(api));
          } else {
            indent.writeln('StandardMessageCodec()');
          }
        });
      });

      final String errorClassName = _getErrorClassName(generatorOptions);
      for (final Method method in api.methods) {
        _writeFlutterMethod(
          indent,
          name: method.name,
          parameters: method.parameters,
          returnType: method.returnType,
          channelName: makeChannelName(api, method, dartPackageName),
          documentationComments: method.documentationComments,
          errorClassName: errorClassName,
          dartPackageName: dartPackageName,
        );
      }
    });
  }

  /// Write the kotlin code that represents a host [Api], [api].
  /// Example:
  /// interface Foo {
  ///   Int add(x: Int, y: Int);
  ///   companion object {
  ///     fun setUp(binaryMessenger: BinaryMessenger, api: Api) {...}
  ///   }
  /// }
  ///
  @override
  void writeHostApi(
    KotlinOptions generatorOptions,
    Root root,
    Indent indent,
    AstHostApi api, {
    required String dartPackageName,
  }) {
    final String apiName = api.name;

    final bool isCustomCodec = getCodecClasses(api, root).isNotEmpty;
    if (isCustomCodec) {
      _writeCodec(indent, api, root);
    }

    const List<String> generatedMessages = <String>[
      ' Generated interface from Pigeon that represents a handler of messages from Flutter.'
    ];
    addDocumentationComments(indent, api.documentationComments, _docCommentSpec,
        generatorComments: generatedMessages);

    indent.write('interface $apiName ');
    indent.addScoped('{', '}', () {
      for (final Method method in api.methods) {
        _writeMethodDeclaration(
          indent,
          name: method.name,
          documentationComments: method.documentationComments,
          returnType: method.returnType,
          parameters: method.parameters,
          isAsynchronous: method.isAsynchronous,
        );
      }

      indent.newln();
      indent.write('companion object ');
      indent.addScoped('{', '}', () {
        indent.writeln('/** The codec used by $apiName. */');
        indent.write('val codec: MessageCodec<Any?> by lazy ');
        indent.addScoped('{', '}', () {
          if (isCustomCodec) {
            indent.writeln(_getCodecName(api));
          } else {
            indent.writeln('StandardMessageCodec()');
          }
        });
        indent.writeln(
            '/** Sets up an instance of `$apiName` to handle messages through the `binaryMessenger`. */');
        indent.writeln('@Suppress("UNCHECKED_CAST")');
        indent.write(
            'fun setUp(binaryMessenger: BinaryMessenger, api: $apiName?) ');
        indent.addScoped('{', '}', () {
          for (final Method method in api.methods) {
            _writeHostMethod(
              indent,
              name: method.name,
              channelName: makeChannelName(api, method, dartPackageName),
              taskQueueType: method.taskQueueType,
              parameters: method.parameters,
              returnType: method.returnType,
              isAsynchronous: method.isAsynchronous,
            );
          }
        });
      });
    });
  }

  @override
  void writeInstanceManager(
    KotlinOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    const String finalizationListenerClassName =
        '${classNamePrefix}FinalizationListener';
    indent.writeln('''
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
@Suppress("UNCHECKED_CAST", "MemberVisibilityCanBePrivate", "unused", "ClassName")
class $instanceManagerClassName(private val finalizationListener: $finalizationListenerClassName) {
  /** Interface for listening when a weak reference of an instance is removed from the manager.  */
  interface $finalizationListenerClassName {
    fun onFinalize(identifier: Long)
  }

  private val identifiers = WeakHashMap<Any, Long>()
  private val weakInstances = HashMap<Long, WeakReference<Any>>()
  private val strongInstances = HashMap<Long, Any>()
  private val referenceQueue = ReferenceQueue<Any>()
  private val weakReferencesToIdentifiers = HashMap<WeakReference<Any>, Long>()
  private val handler = Handler(Looper.getMainLooper())
  private var nextIdentifier: Long = minHostCreatedIdentifier
  private var hasFinalizationListenerStopped = false

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
    private const val clearFinalizedWeakReferencesInterval: Long = 3000
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
    fun create(finalizationListener: $finalizationListenerClassName): $instanceManagerClassName {
      return $instanceManagerClassName(finalizationListener)
    }

    /**
     * Instantiate a new manager with an `$instanceManagerClassName`.
     *
     * @param api handles removing garbage collected weak references.
     * @return a new `$instanceManagerClassName`.
     */
    fun create(api: ${instanceManagerClassName}Api): $instanceManagerClassName {
      return create(object : $finalizationListenerClassName {
        override fun onFinalize(identifier: Long) {
          api.removeStrongReference(identifier) {
            if(it.isFailure) {
              Log.e(tag, "Failed to remove Dart strong reference with identifier: \$identifier")
            }
          }
        }
      })
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
    val instance = weakInstances[identifier] as WeakReference<T>?
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
   * Stop the periodic run of the [$finalizationListenerClassName] for instances that have been garbage
   * collected.
   *
   *
   * The InstanceManager can continue to be used, but the [$finalizationListenerClassName] will no
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
   * Whether the [$finalizationListenerClassName] is still being called for instances that are garbage
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
    var reference: WeakReference<Any>?
    while ((referenceQueue.poll() as WeakReference<Any>?).also { reference = it } != null) {
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
    val weakReference = WeakReference(instance, referenceQueue)
    identifiers[instance] = identifier
    weakInstances[identifier] = weakReference
    weakReferencesToIdentifiers[weakReference] = identifier
    strongInstances[identifier] = instance
  }

  private fun logWarningIfFinalizationListenerHasStopped() {
    if (hasFinalizationListenerStopped()) {
      Log.w(
        tag,
        "The manager was used after calls to the $finalizationListenerClassName have been stopped."
      )
    }
  }
}
''');
  }

  @override
  void writeInstanceManagerApi(
    KotlinOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    const String apiName = '${instanceManagerClassName}Api';
    final String removeStrongReferenceName = makeChannelNameWithStrings(
      apiName: apiName,
      methodName: 'removeStrongReference',
      dartPackageName: dartPackageName,
    );
    final String clearName = makeChannelNameWithStrings(
      apiName: apiName,
      methodName: 'clear',
      dartPackageName: dartPackageName,
    );
    final String errorClassName = _getErrorClassName(generatorOptions);
    indent.writeln('''
/**
* Generated API for managing the Dart and native `$instanceManagerClassName`s.
*/
@Suppress("ClassName")
class $apiName(private val binaryMessenger: BinaryMessenger) {
  companion object {
    /** The codec used by $apiName. */
    private val codec: MessageCodec<Any?> by lazy {
      StandardMessageCodec()
    }

    /**
    * Sets up an instance of `$apiName` to handle messages from the
    * `binaryMessenger`.
    */
    fun setUpMessageHandlers(binaryMessenger: BinaryMessenger, instanceManager: $instanceManagerClassName) {
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "$removeStrongReferenceName", codec)
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
      }
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "$clearName", codec)
        channel.setMessageHandler { _, reply ->
          val wrapped: List<Any?> = try {
            instanceManager.clear()
            listOf<Any?>(null)
          } catch (exception: Throwable) {
            wrapError(exception)
          }
          reply.reply(wrapped)
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
''');
  }

  @override
  void writeProxyApiBaseCodec(
    KotlinOptions generatorOptions,
    Root root,
    Indent indent,
  ) {
    const String codecName = '${classNamePrefix}ProxyApiBaseCodec';

    indent.writeln('''
@Suppress("ClassName")
private class $codecName(val instanceManager: $instanceManagerClassName) : StandardMessageCodec() {
  override fun readValueOfType(type: Byte, buffer: ByteBuffer): Any? {
    return when (type) {
      128.toByte() -> {
        return instanceManager.getInstance(readValue(buffer) as Long)
      }
      else -> super.readValueOfType(type, buffer)
    }
  }

  override fun writeValue(stream: ByteArrayOutputStream, value: Any?) {
    when (value) {
      instanceManager.containsInstance(value) -> {
        stream.write(128)
        writeValue(stream, instanceManager.getIdentifierForStrongReference(value))
      }
      else -> super.writeValue(stream, value)
    }
  }
}
''');
  }

  @override
  void writeProxyApi(
    KotlinOptions generatorOptions,
    Root root,
    Indent indent,
    AstProxyApi api, {
    required String dartPackageName,
  }) {
    const String codecName = '${classNamePrefix}ProxyApiBaseCodec';
    final String fullKotlinClassName =
        api.kotlinOptions?.fullClassName ?? api.name;
    final String apiName = '${api.name}_Api';

    addDocumentationComments(
      indent,
      api.documentationComments,
      _docCommentSpec,
    );
    indent.writeln('@Suppress("UNCHECKED_CAST")');
    indent.writeScoped(
      'abstract class $apiName(val binaryMessenger: BinaryMessenger, val ${classMemberNamePrefix}instanceManager: $instanceManagerClassName) {',
      '}',
      () {
        // TODO: check if uses codec variable
        indent.writeln(
          'private val codec: Pigeon_ProxyApiBaseCodec = Pigeon_ProxyApiBaseCodec(${classMemberNamePrefix}instanceManager)',
        );
        indent.newln();

        for (final Constructor constructor in api.constructors) {
          _writeMethodDeclaration(
            indent,
            name: constructor.name.isNotEmpty
                ? constructor.name
                : '${classMemberNamePrefix}defaultConstructor',
            returnType: TypeDeclaration(
              baseName: api.name,
              isNullable: false,
              associatedProxyApi: api,
            ),
            documentationComments: constructor.documentationComments,
            isAbstract: true,
            parameters: <Parameter>[
              ...api.nonAttachedFields.map((Field field) {
                return Parameter(
                  name: field.name,
                  type: field.type,
                );
              }),
              ...constructor.parameters
            ],
          );
          indent.newln();
        }

        for (final Field field in api.nonAttachedFields) {
          _writeMethodDeclaration(
            indent,
            name: field.name,
            documentationComments: api.documentationComments,
            returnType: field.type,
            isAbstract: true,
            parameters: <Parameter>[
              Parameter(
                name: '${classMemberNamePrefix}instance',
                type: TypeDeclaration(
                  baseName: api.name,
                  isNullable: false,
                  associatedProxyApi: api,
                ),
              ),
            ],
          );
          indent.newln();
        }

        for (final Method method in api.hostMethods) {
          _writeMethodDeclaration(
            indent,
            name: method.name,
            returnType: method.returnType,
            documentationComments: method.documentationComments,
            isAsynchronous: method.isAsynchronous,
            isAbstract: true,
            parameters: <Parameter>[
              if (!method.isStatic)
                Parameter(
                  name: '${classMemberNamePrefix}instance',
                  type: TypeDeclaration(
                    baseName: fullKotlinClassName,
                    isNullable: false,
                    associatedProxyApi: api,
                  ),
                ),
              ...method.parameters,
            ],
          );
          indent.newln();
        }

        indent.writeScoped('companion object {', '}', () {
          indent.writeln('@Suppress("LocalVariableName")');
          indent.writeScoped(
            'fun setUpMessageHandlers(binaryMessenger: BinaryMessenger, api: $apiName?) {',
            '}',
            () {
              indent.writeln(
                'val codec = if (api != null) $codecName(api.${classMemberNamePrefix}instanceManager) else StandardMessageCodec()',
              );
              for (final Constructor constructor in api.constructors) {
                final String name = constructor.name.isNotEmpty
                    ? constructor.name
                    : '${classMemberNamePrefix}defaultConstructor';
                _writeHostMethod(
                  indent,
                  name: name,
                  channelName: makeChannelNameWithStrings(
                    apiName: api.name,
                    methodName: name,
                    dartPackageName: dartPackageName,
                  ),
                  taskQueueType: TaskQueueType.serial,
                  returnType: const TypeDeclaration.voidDeclaration(),
                  onCreateCall: (
                    List<String> methodParameters, {
                    required String apiVarName,
                  }) {
                    return '$apiVarName.${classMemberNamePrefix}instanceManager.addDartCreatedInstance('
                        '$apiVarName.$name(${methodParameters.skip(1).join(',')}), ${methodParameters.first})';
                  },
                  parameters: <Parameter>[
                    Parameter(
                      name: '${classMemberNamePrefix}instanceIdentifier',
                      type: const TypeDeclaration(
                        baseName: 'int',
                        isNullable: false,
                      ),
                    ),
                    ...api.nonAttachedFields.map((Field field) {
                      return Parameter(
                        name: field.name,
                        type: field.type,
                      );
                    }),
                    ...constructor.parameters,
                  ],
                );
              }

              for (final Method method in api.hostMethods) {
                _writeHostMethod(
                  indent,
                  name: method.name,
                  channelName: makeChannelName(api, method, dartPackageName),
                  taskQueueType: method.taskQueueType,
                  returnType: method.returnType,
                  isAsynchronous: method.isAsynchronous,
                  parameters: <Parameter>[
                    if (!method.isStatic)
                      Parameter(
                        name: '${classMemberNamePrefix}instance',
                        type: TypeDeclaration(
                          baseName: fullKotlinClassName,
                          isNullable: false,
                          associatedProxyApi: api,
                        ),
                      ),
                    ...method.parameters,
                  ],
                );
              }
            },
          );
        });
        indent.newln();

        final String errorClassName = _getErrorClassName(generatorOptions);

        // TODO: change name for dart generator in PR (detached to newInstance)
        // TODO: Solution is to write method declartion and then have a writeBody(indent)
        // TODO: _writeFlutterMethod should use writeMethodDeclaration
        indent.writeln('@Suppress("LocalVariableName", "FunctionName")');
        const String newInstanceMethodName =
            '${classMemberNamePrefix}newInstance';
        _writeFlutterMethod(
          indent,
          name: newInstanceMethodName,
          returnType: const TypeDeclaration.voidDeclaration(),
          documentationComments: <String>[
            'Creates a Dart instance of $apiName and attaches it to [${classMemberNamePrefix}instanceArg].',
          ],
          channelName: makeChannelNameWithStrings(
            apiName: api.name,
            methodName: newInstanceMethodName,
            dartPackageName: dartPackageName,
          ),
          errorClassName: errorClassName,
          dartPackageName: dartPackageName,
          parameters: <Parameter>[
            Parameter(
              name: '${classMemberNamePrefix}instance',
              type: TypeDeclaration(
                baseName: api.name,
                isNullable: false,
                associatedProxyApi: api,
              ),
            ),
          ],
          onWriteBody: (
            Indent indent, {
            required List<Parameter> parameters,
            required TypeDeclaration returnType,
            required String channelName,
            required String errorClassName,
          }) {
            indent.writeScoped(
              'if (${classMemberNamePrefix}instanceManager.containsInstance(${classMemberNamePrefix}instanceArg)) {',
              '}',
              () {
                indent.writeln('Result.success(Unit)');
                indent.writeln('return');
              },
            );

            indent.writeln(
              'val ${classMemberNamePrefix}identifierArg = ${classMemberNamePrefix}instanceManager.addHostCreatedInstance(${classMemberNamePrefix}instanceArg)',
            );
            api.nonAttachedFields.forEachIndexed((int index, Field field) {
              final String argName = _getSafeArgumentName(index, field);
              indent.writeln(
                'val $argName = ${field.name}(${classMemberNamePrefix}instanceArg)',
              );

              if (field.type.isProxyApi && field.type.isNullable) {
                indent.writeScoped('if ($argName != null) {', '}', () {
                  final String apiAccess = field.type.baseName == api.name
                      ? ''
                      : '${classMemberNamePrefix}get${field.type.baseName}Api().';
                  indent.writeln(
                    '$apiAccess$newInstanceMethodName($argName) { }',
                  );
                });
              }
            });
            _writeFlutterMethodMessageCall(
              indent,
              returnType: returnType,
              channelName: channelName,
              errorClassName: errorClassName,
              parameters: <Parameter>[
                Parameter(
                  name: '${classMemberNamePrefix}identifier',
                  type: const TypeDeclaration(
                    baseName: 'int',
                    isNullable: false,
                  ),
                ),
                ...api.nonAttachedFields.mapIndexed(
                  (int index, Field field) {
                    return Parameter(
                      name: field.name,
                      type: field.type,
                    );
                  },
                ),
              ],
            );
          },
        );
        indent.newln();

        for (final Method method in api.flutterMethods) {
          _writeFlutterMethod(
            indent,
            name: method.name,
            returnType: method.returnType,
            channelName: makeChannelName(api, method, dartPackageName),
            errorClassName: errorClassName,
            dartPackageName: dartPackageName,
            documentationComments: method.documentationComments,
            parameters: <Parameter>[
              Parameter(
                name: '${classMemberNamePrefix}instance',
                type: TypeDeclaration(
                  baseName: api.name,
                  isNullable: false,
                  associatedProxyApi: api,
                ),
              ),
              ...method.parameters,
            ],
          );
          indent.newln();
        }
      },
    );
  }

  /// Writes the codec class that will be used by [api].
  /// Example:
  /// private static class FooCodec extends StandardMessageCodec {...}
  void _writeCodec(Indent indent, Api api, Root root) {
    assert(getCodecClasses(api, root).isNotEmpty);
    final Iterable<EnumeratedClass> codecClasses = getCodecClasses(api, root);
    final String codecName = _getCodecName(api);
    indent.writeln('@Suppress("UNCHECKED_CAST")');
    indent.write('private object $codecName : StandardMessageCodec() ');
    indent.addScoped('{', '}', () {
      indent.write(
          'override fun readValueOfType(type: Byte, buffer: ByteBuffer): Any? ');
      indent.addScoped('{', '}', () {
        indent.write('return when (type) ');
        indent.addScoped('{', '}', () {
          for (final EnumeratedClass customClass in codecClasses) {
            indent.write('${customClass.enumeration}.toByte() -> ');
            indent.addScoped('{', '}', () {
              indent.write('return (readValue(buffer) as? List<Any?>)?.let ');
              indent.addScoped('{', '}', () {
                indent.writeln('${customClass.name}.fromList(it)');
              });
            });
          }
          indent.writeln('else -> super.readValueOfType(type, buffer)');
        });
      });

      indent.write(
          'override fun writeValue(stream: ByteArrayOutputStream, value: Any?) ');
      indent.writeScoped('{', '}', () {
        indent.write('when (value) ');
        indent.addScoped('{', '}', () {
          for (final EnumeratedClass customClass in codecClasses) {
            indent.write('is ${customClass.name} -> ');
            indent.addScoped('{', '}', () {
              indent.writeln('stream.write(${customClass.enumeration})');
              indent.writeln('writeValue(stream, value.toList())');
            });
          }
          indent.writeln('else -> super.writeValue(stream, value)');
        });
      });
    });
    indent.newln();
  }

  void _writeWrapResult(Indent indent) {
    indent.newln();
    indent.write('private fun wrapResult(result: Any?): List<Any?> ');
    indent.addScoped('{', '}', () {
      indent.writeln('return listOf(result)');
    });
  }

  void _writeWrapError(KotlinOptions generatorOptions, Indent indent) {
    indent.newln();
    indent.write('private fun wrapError(exception: Throwable): List<Any?> ');
    indent.addScoped('{', '}', () {
      indent
          .write('if (exception is ${_getErrorClassName(generatorOptions)}) ');
      indent.addScoped('{', '}', () {
        indent.write('return ');
        indent.addScoped('listOf(', ')', () {
          indent.writeln('exception.code,');
          indent.writeln('exception.message,');
          indent.writeln('exception.details');
        });
      }, addTrailingNewline: false);
      indent.addScoped(' else {', '}', () {
        indent.write('return ');
        indent.addScoped('listOf(', ')', () {
          indent.writeln('exception.javaClass.simpleName,');
          indent.writeln('exception.toString(),');
          indent.writeln(
              '"Cause: " + exception.cause + ", Stacktrace: " + Log.getStackTraceString(exception)');
        });
      });
    });
  }

  void _writeErrorClass(KotlinOptions generatorOptions, Indent indent) {
    indent.newln();
    indent.writeln('/**');
    indent.writeln(
        ' * Error class for passing custom error details to Flutter via a thrown PlatformException.');
    indent.writeln(' * @property code The error code.');
    indent.writeln(' * @property message The error message.');
    indent.writeln(
        ' * @property details The error details. Must be a datatype supported by the api codec.');
    indent.writeln(' */');
    indent.write('class ${_getErrorClassName(generatorOptions)} ');
    indent.addScoped('(', ')', () {
      indent.writeln('val code: String,');
      indent.writeln('override val message: String? = null,');
      indent.writeln('val details: Any? = null');
    }, addTrailingNewline: false);
    indent.addln(' : Throwable()');
  }

  void _writeCreateConnectionError(
      KotlinOptions generatorOptions, Indent indent) {
    final String errorClassName = _getErrorClassName(generatorOptions);
    indent.newln();
    indent.write(
        'private fun createConnectionError(channelName: String): $errorClassName ');
    indent.addScoped('{', '}', () {
      indent.write(
          'return $errorClassName("channel-error",  "Unable to establish connection on channel: \'\$channelName\'.", "")');
    });
  }

  @override
  void writeGeneralUtilities(
    KotlinOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    final bool hasHostApi = root.apis
        .whereType<AstHostApi>()
        .any((Api api) => api.methods.isNotEmpty);
    final bool hasFlutterApi = root.apis
        .whereType<AstFlutterApi>()
        .any((Api api) => api.methods.isNotEmpty);
    final bool hasProxyApi = root.apis.any((Api api) => api is AstProxyApi);

    if (hasHostApi || hasProxyApi) {
      _writeWrapResult(indent);
      _writeWrapError(generatorOptions, indent);
    }
    if (hasFlutterApi || hasProxyApi) {
      _writeCreateConnectionError(generatorOptions, indent);
    }
    _writeErrorClass(generatorOptions, indent);
  }

  void _writeMethodDeclaration(
    Indent indent, {
    required String name,
    required TypeDeclaration returnType,
    required List<Parameter> parameters,
    List<String> documentationComments = const <String>[],
    bool isAsynchronous = false,
    bool isAbstract = false,
  }) {
    final List<String> argSignature = <String>[];
    if (parameters.isNotEmpty) {
      final Iterable<String> argTypes = parameters
          .map((NamedType e) => _nullsafeKotlinTypeForDartType(e.type));
      final Iterable<String> argNames = parameters.map((NamedType e) => e.name);
      argSignature.addAll(
        map2(
          argTypes,
          argNames,
          (String argType, String argName) {
            return '$argName: $argType';
          },
        ),
      );
    }

    final String returnTypeString =
        returnType.isVoid ? '' : _nullsafeKotlinTypeForDartType(returnType);

    final String resultType = returnType.isVoid ? 'Unit' : returnTypeString;
    addDocumentationComments(indent, documentationComments, _docCommentSpec);

    final String abstractKeyword = isAbstract ? 'abstract ' : '';

    if (isAsynchronous) {
      argSignature.add('callback: (Result<$resultType>) -> Unit');
      indent.writeln('${abstractKeyword}fun $name(${argSignature.join(', ')})');
    } else if (returnType.isVoid) {
      indent.writeln('${abstractKeyword}fun $name(${argSignature.join(', ')})');
    } else {
      indent.writeln(
        '${abstractKeyword}fun $name(${argSignature.join(', ')}): $returnTypeString',
      );
    }
  }

  void _writeHostMethod(
    Indent indent, {
    required String name,
    required String channelName,
    required TaskQueueType taskQueueType,
    required List<Parameter> parameters,
    required TypeDeclaration returnType,
    bool isAsynchronous = false,
    String Function(
      List<String> methodParameters, {
      required String apiVarName,
    })? onCreateCall,
  }) {
    indent.write('run ');
    indent.addScoped('{', '}', () {
      String? taskQueue;
      if (taskQueueType != TaskQueueType.serial) {
        taskQueue = 'taskQueue';
        indent.writeln(
            'val $taskQueue = binaryMessenger.makeBackgroundTaskQueue()');
      }

      indent.write(
          'val channel = BasicMessageChannel<Any?>(binaryMessenger, "$channelName", codec');

      if (taskQueue != null) {
        indent.addln(', $taskQueue)');
      } else {
        indent.addln(')');
      }

      indent.write('if (api != null) ');
      indent.addScoped('{', '}', () {
        final String messageVarName = parameters.isNotEmpty ? 'message' : '_';

        indent.write('channel.setMessageHandler ');
        indent.addScoped('{ $messageVarName, reply ->', '}', () {
          final List<String> methodArguments = <String>[];
          if (parameters.isNotEmpty) {
            indent.writeln('val args = message as List<Any?>');
            parameters.forEachIndexed((int index, NamedType arg) {
              final String argName = _getSafeArgumentName(index, arg);
              final String argIndex = 'args[$index]';
              indent.writeln(
                  'val $argName = ${_castForceUnwrap(argIndex, arg.type, indent)}');
              methodArguments.add(argName);
            });
          }
          final String call = onCreateCall != null
              ? onCreateCall(methodArguments, apiVarName: 'api')
              : 'api.$name(${methodArguments.join(', ')})';

          if (isAsynchronous) {
            indent.write('$call ');
            final String resultType = returnType.isVoid
                ? 'Unit'
                : _nullsafeKotlinTypeForDartType(returnType);
            indent.addScoped('{ result: Result<$resultType> ->', '}', () {
              indent.writeln('val error = result.exceptionOrNull()');
              indent.writeScoped('if (error != null) {', '}', () {
                indent.writeln('reply.reply(wrapError(error))');
              }, addTrailingNewline: false);
              indent.addScoped(' else {', '}', () {
                final String enumTagNullablePrefix =
                    returnType.isNullable ? '?' : '!!';
                final String enumTag =
                    returnType.isEnum ? '$enumTagNullablePrefix.raw' : '';
                if (returnType.isVoid) {
                  indent.writeln('reply.reply(wrapResult(null))');
                } else {
                  indent.writeln('val data = result.getOrNull()');
                  indent.writeln('reply.reply(wrapResult(data$enumTag))');
                }
              });
            });
          } else {
            indent.writeln('var wrapped: List<Any?>');
            indent.write('try ');
            indent.addScoped('{', '}', () {
              if (returnType.isVoid) {
                indent.writeln(call);
                indent.writeln('wrapped = listOf<Any?>(null)');
              } else {
                String enumTag = '';
                if (returnType.isEnum) {
                  final String safeUnwrap = returnType.isNullable ? '?' : '';
                  enumTag = '$safeUnwrap.raw';
                }
                indent.writeln('wrapped = listOf<Any?>($call$enumTag)');
              }
            }, addTrailingNewline: false);
            indent.add(' catch (exception: Throwable) ');
            indent.addScoped('{', '}', () {
              indent.writeln('wrapped = wrapError(exception)');
            });
            indent.writeln('reply.reply(wrapped)');
          }
        });
      }, addTrailingNewline: false);
      indent.addScoped(' else {', '}', () {
        indent.writeln('channel.setMessageHandler(null)');
      });
    });
  }

  void _writeFlutterMethod(
    Indent indent, {
    required String name,
    required List<Parameter> parameters,
    required TypeDeclaration returnType,
    required String channelName,
    required String errorClassName,
    required String dartPackageName,
    List<String> documentationComments = const <String>[],
    void Function(
      Indent indent, {
      required List<Parameter> parameters,
      required TypeDeclaration returnType,
      required String channelName,
      required String errorClassName,
    }) onWriteBody = _writeFlutterMethodMessageCall,
  }) {
    final String returnTypeString =
        returnType.isVoid ? 'Unit' : _nullsafeKotlinTypeForDartType(returnType);

    addDocumentationComments(
      indent,
      documentationComments,
      _docCommentSpec,
    );

    if (parameters.isEmpty) {
      indent.write('fun $name(callback: (Result<$returnTypeString>) -> Unit) ');
    } else {
      final Iterable<String> argTypes = parameters
          .map((NamedType e) => _nullsafeKotlinTypeForDartType(e.type));
      final Iterable<String> argNames =
          parameters.mapIndexed(_getSafeArgumentName);
      final String argsSignature =
          map2(argTypes, argNames, (String type, String name) => '$name: $type')
              .join(', ');
      indent.write(
          'fun $name($argsSignature, callback: (Result<$returnTypeString>) -> Unit) ');
    }
    indent.addScoped('{', '}', () {
      onWriteBody(
        indent,
        parameters: parameters,
        returnType: returnType,
        channelName: channelName,
        errorClassName: errorClassName,
      );
    });
  }

  static void _writeFlutterMethodMessageCall(
    Indent indent, {
    required List<Parameter> parameters,
    required TypeDeclaration returnType,
    required String channelName,
    required String errorClassName,
  }) {
    String sendArgument;

    if (parameters.isEmpty) {
      sendArgument = 'null';
    } else {
      final Iterable<String> enumSafeArgNames = parameters.mapIndexed(
          (int count, NamedType type) =>
              _getEnumSafeArgumentExpression(count, type));
      sendArgument = 'listOf(${enumSafeArgNames.join(', ')})';
    }

    const String channel = 'channel';
    indent.writeln('val channelName = "$channelName"');
    indent.writeln(
        'val $channel = BasicMessageChannel<Any?>(binaryMessenger, channelName, codec)');
    indent.writeScoped('$channel.send($sendArgument) {', '}', () {
      indent.writeScoped('if (it is List<*>) {', '} ', () {
        indent.writeScoped('if (it.size > 1) {', '} ', () {
          indent.writeln(
              'callback(Result.failure($errorClassName(it[0] as String, it[1] as String, it[2] as String?)))');
        }, addTrailingNewline: false);
        if (!returnType.isNullable && !returnType.isVoid) {
          indent.addScoped('else if (it[0] == null) {', '} ', () {
            indent.writeln(
                'callback(Result.failure($errorClassName("null-error", "Flutter method returned null value for non-null return value.", "")))');
          }, addTrailingNewline: false);
        }
        indent.addScoped('else {', '}', () {
          if (returnType.isVoid) {
            indent.writeln('callback(Result.success(Unit))');
          } else {
            const String output = 'output';
            // Nullable enums require special handling.
            if (returnType.isEnum && returnType.isNullable) {
              indent.writeScoped('val $output = (it[0] as Int?)?.let {', '}',
                  () {
                indent.writeln('${returnType.baseName}.ofRaw(it)');
              });
            } else {
              indent.writeln(
                  'val $output = ${_cast(indent, 'it[0]', type: returnType)}');
            }
            indent.writeln('callback(Result.success($output))');
          }
        });
      }, addTrailingNewline: false);
      indent.addScoped('else {', '} ', () {
        indent.writeln(
            'callback(Result.failure(createConnectionError(channelName)))');
      });
    });
  }
}

HostDatatype _getHostDatatype(Root root, NamedType field) {
  return getFieldHostDatatype(
      field, (TypeDeclaration x) => _kotlinTypeForBuiltinDartType(x));
}

/// Calculates the name of the codec that will be generated for [api].
String _getCodecName(Api api) => '${api.name}Codec';

String _getErrorClassName(KotlinOptions generatorOptions) =>
    generatorOptions.errorClassName ?? 'FlutterError';

String _getArgumentName(int count, NamedType argument) =>
    argument.name.isEmpty ? 'arg$count' : argument.name;

/// Returns an argument name that can be used in a context where it is possible to collide
/// and append `.index` to enums.
String _getEnumSafeArgumentExpression(int count, NamedType argument) {
  if (argument.type.isEnum) {
    return argument.type.isNullable
        ? '${_getArgumentName(count, argument)}Arg?.raw'
        : '${_getArgumentName(count, argument)}Arg.raw';
  }
  return '${_getArgumentName(count, argument)}Arg';
}

/// Returns an argument name that can be used in a context where it is possible to collide.
String _getSafeArgumentName(int count, NamedType argument) =>
    '${_getArgumentName(count, argument)}Arg';

String _castForceUnwrap(String value, TypeDeclaration type, Indent indent) {
  if (type.isEnum) {
    final String forceUnwrap = type.isNullable ? '' : '!!';
    final String nullableConditionPrefix =
        type.isNullable ? 'if ($value == null) null else ' : '';
    return '$nullableConditionPrefix${_kotlinTypeForDartType(type)}.ofRaw($value as Int)$forceUnwrap';
  } else {
    return _cast(indent, value, type: type);
  }
}

/// Converts a [List] of [TypeDeclaration]s to a comma separated [String] to be
/// used in Kotlin code.
String _flattenTypeArguments(List<TypeDeclaration> args) {
  return args.map(_kotlinTypeForDartType).join(', ');
}

String _kotlinTypeForBuiltinGenericDartType(TypeDeclaration type) {
  if (type.typeArguments.isEmpty) {
    switch (type.baseName) {
      case 'List':
        return 'List<Any?>';
      case 'Map':
        return 'Map<Any, Any?>';
      default:
        return 'Any';
    }
  } else {
    switch (type.baseName) {
      case 'List':
        return 'List<${_nullsafeKotlinTypeForDartType(type.typeArguments.first)}>';
      case 'Map':
        return 'Map<${_nullsafeKotlinTypeForDartType(type.typeArguments.first)}, ${_nullsafeKotlinTypeForDartType(type.typeArguments.last)}>';
      default:
        return '${type.baseName}<${_flattenTypeArguments(type.typeArguments)}>';
    }
  }
}

String? _kotlinTypeForBuiltinDartType(TypeDeclaration type) {
  const Map<String, String> kotlinTypeForDartTypeMap = <String, String>{
    'void': 'Void',
    'bool': 'Boolean',
    'String': 'String',
    'int': 'Long',
    'double': 'Double',
    'Uint8List': 'ByteArray',
    'Int32List': 'IntArray',
    'Int64List': 'LongArray',
    'Float32List': 'FloatArray',
    'Float64List': 'DoubleArray',
    'Object': 'Any',
  };
  if (kotlinTypeForDartTypeMap.containsKey(type.baseName)) {
    return kotlinTypeForDartTypeMap[type.baseName];
  } else if (type.baseName == 'List' || type.baseName == 'Map') {
    return _kotlinTypeForBuiltinGenericDartType(type);
  } else {
    return null;
  }
}

// TODO: Undo changes to HostDataType handling ProxyApi lol
String? _kotlinTypeForProxyApiType(TypeDeclaration type) {
  if (type.isProxyApi) {
    return type.associatedProxyApi!.kotlinOptions?.fullClassName ??
        type.associatedProxyApi!.name;
  }

  return null;
}

String _kotlinTypeForDartType(TypeDeclaration type) {
  return _kotlinTypeForBuiltinDartType(type) ??
      _kotlinTypeForProxyApiType(type) ??
      type.baseName;
}

String _nullsafeKotlinTypeForDartType(TypeDeclaration type) {
  final String nullSafe = type.isNullable ? '?' : '';
  return '${_kotlinTypeForDartType(type)}$nullSafe';
}

/// Returns an expression to cast [variable] to [kotlinType].
String _cast(Indent indent, String variable, {required TypeDeclaration type}) {
  // Special-case Any, since no-op casts cause warnings.
  final String typeString = _kotlinTypeForDartType(type);
  if (type.isNullable && typeString == 'Any') {
    return variable;
  }
  if (typeString == 'Int' || typeString == 'Long') {
    return '$variable${_castInt(type.isNullable)}';
  }
  if (type.isEnum) {
    if (type.isNullable) {
      return '($variable as Int?)?.let {\n'
          '${indent.str}  $typeString.ofRaw(it)\n'
          '${indent.str}}';
    }
    return '${type.baseName}.ofRaw($variable as Int)!!';
  }
  return '$variable as ${_nullsafeKotlinTypeForDartType(type)}';
}

String _castInt(bool isNullable) {
  final String nullability = isNullable ? '?' : '';
  return '.let { if (it is Int) it.toLong() else it as Long$nullability }';
}

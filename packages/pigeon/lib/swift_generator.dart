// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'ast.dart';
import 'functional.dart';
import 'generator.dart';
import 'generator_tools.dart';

/// Documentation comment open symbol.
const String _docCommentPrefix = '///';

/// Documentation comment spec.
const DocumentCommentSpecification _docCommentSpec =
    DocumentCommentSpecification(_docCommentPrefix);

const String _overflowClassName = '${classNamePrefix}CodecOverflow';

/// Options that control how Swift code will be generated.
class SwiftOptions {
  /// Creates a [SwiftOptions] object
  const SwiftOptions({
    this.copyrightHeader,
    this.fileSpecificClassNameComponent,
    this.errorClassName,
  });

  /// A copyright header that will get prepended to generated code.
  final Iterable<String>? copyrightHeader;

  /// A String to augment class names to avoid cross file collisions.
  final String? fileSpecificClassNameComponent;

  /// The name of the error class used for passing custom error parameters.
  final String? errorClassName;

  /// Creates a [SwiftOptions] from a Map representation where:
  /// `x = SwiftOptions.fromList(x.toMap())`.
  static SwiftOptions fromList(Map<String, Object> map) {
    return SwiftOptions(
      copyrightHeader: map['copyrightHeader'] as Iterable<String>?,
      fileSpecificClassNameComponent:
          map['fileSpecificClassNameComponent'] as String?,
      errorClassName: map['errorClassName'] as String?,
    );
  }

  /// Converts a [SwiftOptions] to a Map representation where:
  /// `x = SwiftOptions.fromList(x.toMap())`.
  Map<String, Object> toMap() {
    final Map<String, Object> result = <String, Object>{
      if (copyrightHeader != null) 'copyrightHeader': copyrightHeader!,
      if (fileSpecificClassNameComponent != null)
        'fileSpecificClassNameComponent': fileSpecificClassNameComponent!,
      if (errorClassName != null) 'errorClassName': errorClassName!,
    };
    return result;
  }

  /// Overrides any non-null parameters from [options] into this to make a new
  /// [SwiftOptions].
  SwiftOptions merge(SwiftOptions options) {
    return SwiftOptions.fromList(mergeMaps(toMap(), options.toMap()));
  }
}

/// Class that manages all Swift code generation.
class SwiftGenerator extends StructuredGenerator<SwiftOptions> {
  /// Instantiates a Swift Generator.
  const SwiftGenerator();

  @override
  void writeFilePrologue(
    SwiftOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    if (generatorOptions.copyrightHeader != null) {
      addLines(indent, generatorOptions.copyrightHeader!, linePrefix: '// ');
    }
    indent.writeln('// ${getGeneratedCodeWarning()}');
    indent.writeln('// $seeAlsoWarning');
    indent.newln();
  }

  @override
  void writeFileImports(
    SwiftOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.writeln('import Foundation');
    indent.newln();
    indent.format('''
#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif''');
  }

  @override
  void writeEnum(
    SwiftOptions generatorOptions,
    Root root,
    Indent indent,
    Enum anEnum, {
    required String dartPackageName,
  }) {
    indent.newln();
    addDocumentationComments(
        indent, anEnum.documentationComments, _docCommentSpec);

    indent.write('enum ${anEnum.name}: Int ');
    indent.addScoped('{', '}', () {
      enumerate(anEnum.members, (int index, final EnumMember member) {
        addDocumentationComments(
            indent, member.documentationComments, _docCommentSpec);
        indent.writeln('case ${_camelCase(member.name)} = $index');
      });
    });
  }

  @override
  void writeGeneralCodec(
    SwiftOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    final String codecName = _getCodecName(generatorOptions);
    final String readerWriterName = '${codecName}ReaderWriter';
    final String readerName = '${codecName}Reader';
    final String writerName = '${codecName}Writer';

    final List<EnumeratedType> enumeratedTypes =
        getEnumeratedTypes(root).toList();

    void writeDecodeLogic(EnumeratedType customType) {
      indent.writeln('case ${customType.enumeration}:');
      indent.nest(1, () {
        if (customType.type == CustomTypes.customEnum) {
          indent.writeln(
              'let enumResultAsInt: Int? = nilOrValue(self.readValue() as? Int)');
          indent.writeScoped('if let enumResultAsInt = enumResultAsInt {', '}',
              () {
            indent.writeln(
                'return ${customType.name}(rawValue: enumResultAsInt)');
          });
          indent.writeln('return nil');
        } else {
          indent.writeln(
              'return ${customType.name}.fromList(self.readValue() as! [Any?])');
        }
      });
    }

    final EnumeratedType overflowClass = EnumeratedType(
        _overflowClassName, maximumCodecFieldKey, CustomTypes.customClass);

    if (root.requiresOverflowClass) {
      indent.newln();
      _writeCodecOverflowUtilities(
          generatorOptions, root, indent, enumeratedTypes,
          dartPackageName: dartPackageName);
    }

    indent.newln();
    // Generate Reader
    indent.write('private class $readerName: FlutterStandardReader ');
    indent.addScoped('{', '}', () {
      if (enumeratedTypes.isNotEmpty) {
        indent.write('override func readValue(ofType type: UInt8) -> Any? ');
        indent.addScoped('{', '}', () {
          indent.write('switch type ');
          indent.addScoped('{', '}', nestCount: 0, () {
            for (final EnumeratedType customType in enumeratedTypes) {
              if (customType.enumeration < maximumCodecFieldKey) {
                writeDecodeLogic(customType);
              }
            }
            if (root.requiresOverflowClass) {
              writeDecodeLogic(overflowClass);
            }
            indent.writeln('default:');
            indent.nest(1, () {
              indent.writeln('return super.readValue(ofType: type)');
            });
          });
        });
      }
    });

    // Generate Writer
    indent.newln();
    indent.write('private class $writerName: FlutterStandardWriter ');
    indent.addScoped('{', '}', () {
      if (enumeratedTypes.isNotEmpty) {
        indent.write('override func writeValue(_ value: Any) ');
        indent.addScoped('{', '}', () {
          indent.write('');
          for (final EnumeratedType customType in enumeratedTypes) {
            indent.add('if let value = value as? ${customType.name} ');
            indent.addScoped('{', '} else ', () {
              final String encodeString =
                  customType.type == CustomTypes.customClass
                      ? 'toList()'
                      : 'rawValue';
              final String valueString =
                  customType.enumeration < maximumCodecFieldKey
                      ? 'value.$encodeString'
                      : 'wrap.toList()';
              final int enumeration =
                  customType.enumeration < maximumCodecFieldKey
                      ? customType.enumeration
                      : maximumCodecFieldKey;
              if (customType.enumeration >= maximumCodecFieldKey) {
                indent.writeln(
                    'let wrap = $_overflowClassName(type: ${customType.enumeration - maximumCodecFieldKey}, wrapped: value.$encodeString)');
              }
              indent.writeln('super.writeByte($enumeration)');
              indent.writeln('super.writeValue($valueString)');
            }, addTrailingNewline: false);
          }
          indent.addScoped('{', '}', () {
            indent.writeln('super.writeValue(value)');
          });
        });
      }
    });
    indent.newln();

    // Generate ReaderWriter
    indent
        .write('private class $readerWriterName: FlutterStandardReaderWriter ');
    indent.addScoped('{', '}', () {
      indent.write(
          'override func reader(with data: Data) -> FlutterStandardReader ');
      indent.addScoped('{', '}', () {
        indent.writeln('return $readerName(data: data)');
      });
      indent.newln();
      indent.write(
          'override func writer(with data: NSMutableData) -> FlutterStandardWriter ');
      indent.addScoped('{', '}', () {
        indent.writeln('return $writerName(data: data)');
      });
    });
    indent.newln();

    // Generate Codec
    indent.write(
        'class $codecName: FlutterStandardMessageCodec, @unchecked Sendable ');
    indent.addScoped('{', '}', () {
      indent.writeln(
          'static let shared = $codecName(readerWriter: $readerWriterName())');
    });
    indent.newln();
  }

  void _writeDataClassSignature(
    Indent indent,
    Class classDefinition, {
    bool private = false,
  }) {
    final String privateString = private ? 'private ' : '';
    if (classDefinition.isSwiftClass) {
      indent.write('${privateString}class ${classDefinition.name} ');
    } else {
      indent.write('${privateString}struct ${classDefinition.name} ');
    }

    indent.addScoped('{', '', () {
      final Iterable<NamedType> fields =
          getFieldsInSerializationOrder(classDefinition);

      if (classDefinition.isSwiftClass) {
        _writeClassInit(indent, fields.toList());
      }

      for (final NamedType field in fields) {
        addDocumentationComments(
            indent, field.documentationComments, _docCommentSpec);
        indent.write('var ');
        _writeClassField(indent, field, addNil: !classDefinition.isSwiftClass);
        indent.newln();
      }
    });
  }

  void _writeCodecOverflowUtilities(
    SwiftOptions generatorOptions,
    Root root,
    Indent indent,
    List<EnumeratedType> types, {
    required String dartPackageName,
  }) {
    final NamedType overflowInt = NamedType(
        name: 'type',
        type: const TypeDeclaration(baseName: 'Int', isNullable: false));
    final NamedType overflowObject = NamedType(
        name: 'wrapped',
        type: const TypeDeclaration(baseName: 'Object', isNullable: true));
    final List<NamedType> overflowFields = <NamedType>[
      overflowInt,
      overflowObject,
    ];
    final Class overflowClass =
        Class(name: _overflowClassName, fields: overflowFields);
    indent.newln();
    _writeDataClassSignature(indent, overflowClass, private: true);
    indent.addScoped('', '}', () {
      writeClassEncode(
        generatorOptions,
        root,
        indent,
        overflowClass,
        dartPackageName: dartPackageName,
      );

      indent.format('''
// swift-format-ignore: AlwaysUseLowerCamelCase
static func fromList(_ ${varNamePrefix}list: [Any?]) -> Any? {
  let type = ${varNamePrefix}list[0] as! Int
  let wrapped: Any? = ${varNamePrefix}list[1]

  let wrapper = $_overflowClassName(
    type: type,
    wrapped: wrapped
  )
  
  return wrapper.unwrap()
}
''');

      indent.writeScoped('func unwrap() -> Any? {', '}', () {
        indent.format('''
if (wrapped == nil) {
  return nil;
}
    ''');
        indent.writeScoped('switch type {', '}', () {
          for (int i = totalCustomCodecKeysAllowed; i < types.length; i++) {
            indent.writeScoped('case ${i - totalCustomCodecKeysAllowed}:', '',
                () {
              if (types[i].type == CustomTypes.customClass) {
                indent.writeln(
                    'return ${types[i].name}.fromList(wrapped as! [Any?]);');
              } else if (types[i].type == CustomTypes.customEnum) {
                indent.writeln(
                    'return ${types[i].name}(rawValue: wrapped as! Int);');
              }
            }, addTrailingNewline: false);
          }
          indent.writeScoped('default: ', '', () {
            indent.writeln('return nil');
          }, addTrailingNewline: false);
        });
      });
    });
  }

  @override
  void writeDataClass(
    SwiftOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    const List<String> generatedComments = <String>[
      ' Generated class from Pigeon that represents data sent in messages.'
    ];
    indent.newln();
    addDocumentationComments(
        indent, classDefinition.documentationComments, _docCommentSpec,
        generatorComments: generatedComments);
    _writeDataClassSignature(indent, classDefinition);
    indent.writeScoped('', '}', () {
      indent.newln();
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

  void _writeClassInit(Indent indent, List<NamedType> fields) {
    indent.writeScoped('init(', ')', () {
      for (int i = 0; i < fields.length; i++) {
        indent.write('');
        _writeClassField(indent, fields[i]);
        if (i == fields.length - 1) {
          indent.newln();
        } else {
          indent.addln(',');
        }
      }
    }, addTrailingNewline: false);
    indent.addScoped(' {', '}', () {
      for (final NamedType field in fields) {
        _writeClassFieldInit(indent, field);
      }
    });
  }

  void _writeClassField(Indent indent, NamedType field, {bool addNil = true}) {
    indent.add('${field.name}: ${_nullsafeSwiftTypeForDartType(field.type)}');
    final String defaultNil = field.type.isNullable && addNil ? ' = nil' : '';
    indent.add(defaultNil);
  }

  void _writeClassFieldInit(Indent indent, NamedType field) {
    indent.writeln('self.${field.name} = ${field.name}');
  }

  @override
  void writeClassEncode(
    SwiftOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    indent.write('func toList() -> [Any?] ');
    indent.addScoped('{', '}', () {
      indent.write('return ');
      indent.addScoped('[', ']', () {
        // Follow swift-format style, which is to use a trailing comma unless
        // there is only one element.
        final String separator = classDefinition.fields.length > 1 ? ',' : '';
        for (final NamedType field
            in getFieldsInSerializationOrder(classDefinition)) {
          indent.writeln('${field.name}$separator');
        }
      });
    });
  }

  @override
  void writeClassDecode(
    SwiftOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    final String className = classDefinition.name;
    indent.writeln('// swift-format-ignore: AlwaysUseLowerCamelCase');
    indent.write(
        'static func fromList(_ ${varNamePrefix}list: [Any?]) -> $className? ');

    indent.addScoped('{', '}', () {
      enumerate(getFieldsInSerializationOrder(classDefinition),
          (int index, final NamedType field) {
        final String listValue = '${varNamePrefix}list[$index]';

        _writeGenericCasting(
          indent: indent,
          value: listValue,
          variableName: field.name,
          fieldType: _swiftTypeForDartType(field.type),
          type: field.type,
        );
      });

      indent.newln();
      indent.write('return ');
      indent.addScoped('$className(', ')', () {
        for (final NamedType field
            in getFieldsInSerializationOrder(classDefinition)) {
          final String comma =
              getFieldsInSerializationOrder(classDefinition).last == field
                  ? ''
                  : ',';
          indent.writeln('${field.name}: ${field.name}$comma');
        }
      });
    });
  }

  @override
  void writeApis(
    SwiftOptions generatorOptions,
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
  /// class Foo {
  ///   private let binaryMessenger: FlutterBinaryMessenger
  ///   init(binaryMessenger: FlutterBinaryMessenger) {...}
  ///   func add(x: Int32, y: Int32, completion: @escaping (Int32?) -> Void) {...}
  /// }
  @override
  void writeFlutterApi(
    SwiftOptions generatorOptions,
    Root root,
    Indent indent,
    AstFlutterApi api, {
    required String dartPackageName,
  }) {
    const List<String> generatedComments = <String>[
      ' Generated protocol from Pigeon that represents Flutter messages that can be called from Swift.'
    ];
    addDocumentationComments(indent, api.documentationComments, _docCommentSpec,
        generatorComments: generatedComments);

    indent.addScoped('protocol ${api.name}Protocol {', '}', () {
      for (final Method func in api.methods) {
        addDocumentationComments(
            indent, func.documentationComments, _docCommentSpec);
        indent.writeln(_getMethodSignature(
          name: func.name,
          parameters: func.parameters,
          returnType: func.returnType,
          errorTypeName: _getErrorClassName(generatorOptions),
          isAsynchronous: true,
          swiftFunction: func.swiftFunction,
          getParameterName: _getSafeArgumentName,
        ));
      }
    });

    indent.write('class ${api.name}: ${api.name}Protocol ');
    indent.addScoped('{', '}', () {
      indent.writeln('private let binaryMessenger: FlutterBinaryMessenger');
      indent.writeln('private let messageChannelSuffix: String');
      indent.write(
          'init(binaryMessenger: FlutterBinaryMessenger, messageChannelSuffix: String = "") ');
      indent.addScoped('{', '}', () {
        indent.writeln('self.binaryMessenger = binaryMessenger');
        indent.writeln(
            r'self.messageChannelSuffix = messageChannelSuffix.count > 0 ? ".\(messageChannelSuffix)" : ""');
      });
      final String codecName = _getCodecName(generatorOptions);
      indent.write('var codec: $codecName ');
      indent.addScoped('{', '}', () {
        indent.writeln('return $codecName.shared');
      });

      for (final Method func in api.methods) {
        addDocumentationComments(
            indent, func.documentationComments, _docCommentSpec);
        _writeFlutterMethod(
          indent,
          generatorOptions: generatorOptions,
          name: func.name,
          channelName: makeChannelName(api, func, dartPackageName),
          parameters: func.parameters,
          returnType: func.returnType,
          swiftFunction: func.swiftFunction,
        );
      }
    });
  }

  /// Write the swift code that represents a host [Api], [api].
  /// Example:
  /// protocol Foo {
  ///   Int32 add(x: Int32, y: Int32)
  /// }
  @override
  void writeHostApi(
    SwiftOptions generatorOptions,
    Root root,
    Indent indent,
    AstHostApi api, {
    required String dartPackageName,
  }) {
    final String apiName = api.name;

    const List<String> generatedComments = <String>[
      ' Generated protocol from Pigeon that represents a handler of messages from Flutter.'
    ];
    addDocumentationComments(indent, api.documentationComments, _docCommentSpec,
        generatorComments: generatedComments);

    indent.write('protocol $apiName ');
    indent.addScoped('{', '}', () {
      for (final Method method in api.methods) {
        addDocumentationComments(
            indent, method.documentationComments, _docCommentSpec);
        indent.writeln(_getMethodSignature(
          name: method.name,
          parameters: method.parameters,
          returnType: method.returnType,
          errorTypeName: 'Error',
          isAsynchronous: method.isAsynchronous,
          swiftFunction: method.swiftFunction,
        ));
      }
    });

    indent.newln();
    indent.writeln(
        '$_docCommentPrefix Generated setup class from Pigeon to handle messages through the `binaryMessenger`.');
    indent.write('class ${apiName}Setup ');
    indent.addScoped('{', '}', () {
      indent.writeln(
          'static var codec: FlutterStandardMessageCodec { ${_getCodecName(generatorOptions)}.shared }');
      indent.writeln(
          '$_docCommentPrefix Sets up an instance of `$apiName` to handle messages through the `binaryMessenger`.');
      indent.write(
          'static func setUp(binaryMessenger: FlutterBinaryMessenger, api: $apiName?, messageChannelSuffix: String = "") ');
      indent.addScoped('{', '}', () {
        indent.writeln(
            r'let channelSuffix = messageChannelSuffix.count > 0 ? ".\(messageChannelSuffix)" : ""');
        for (final Method method in api.methods) {
          _writeHostMethodMessageHandler(
            indent,
            name: method.name,
            channelName: makeChannelName(api, method, dartPackageName),
            parameters: method.parameters,
            returnType: method.returnType,
            isAsynchronous: method.isAsynchronous,
            swiftFunction: method.swiftFunction,
            documentationComments: method.documentationComments,
          );
        }
      });
    });
  }

  String _castForceUnwrap(String value, TypeDeclaration type) {
    assert(!type.isVoid);
    if (type.baseName == 'Object') {
      return value + (type.isNullable ? '' : '!');
    } else if (type.baseName == 'int') {
      if (type.isNullable) {
        // Nullable ints need to check for NSNull, and Int32 before casting can be done safely.
        // This nested ternary is a necessary evil to avoid less efficient conversions.
        return 'isNullish($value) ? nil : ($value is Int64? ? $value as! Int64? : Int64($value as! Int32))';
      } else {
        return '$value is Int64 ? $value as! Int64 : Int64($value as! Int32)';
      }
    } else if (type.isNullable) {
      return 'nilOrValue($value)';
    } else {
      return '$value as! ${_swiftTypeForDartType(type)}';
    }
  }

  void _writeGenericCasting({
    required Indent indent,
    required String value,
    required String variableName,
    required String fieldType,
    required TypeDeclaration type,
  }) {
    if (type.isNullable) {
      indent.writeln(
          'let $variableName: $fieldType? = ${_castForceUnwrap(value, type)}');
    } else {
      indent.writeln('let $variableName = ${_castForceUnwrap(value, type)}');
    }
  }

  void _writeIsNullish(Indent indent) {
    indent.newln();
    indent.write('private func isNullish(_ value: Any?) -> Bool ');
    indent.addScoped('{', '}', () {
      indent.writeln('return value is NSNull || value == nil');
    });
  }

  void _writeWrapResult(Indent indent) {
    indent.newln();
    indent.write('private func wrapResult(_ result: Any?) -> [Any?] ');
    indent.addScoped('{', '}', () {
      indent.writeln('return [result]');
    });
  }

  void _writeWrapError(SwiftOptions generatorOptions, Indent indent) {
    indent.newln();
    indent.write('private func wrapError(_ error: Any) -> [Any?] ');
    indent.addScoped('{', '}', () {
      indent.write(
          'if let pigeonError = error as? ${_getErrorClassName(generatorOptions)} ');
      indent.addScoped('{', '}', () {
        indent.write('return ');
        indent.addScoped('[', ']', () {
          indent.writeln('pigeonError.code,');
          indent.writeln('pigeonError.message,');
          indent.writeln('pigeonError.details,');
        });
      });
      indent.write('if let flutterError = error as? FlutterError ');
      indent.addScoped('{', '}', () {
        indent.write('return ');
        indent.addScoped('[', ']', () {
          indent.writeln('flutterError.code,');
          indent.writeln('flutterError.message,');
          indent.writeln('flutterError.details,');
        });
      });
      indent.write('return ');
      indent.addScoped('[', ']', () {
        indent.writeln(r'"\(error)",');
        indent.writeln(r'"\(type(of: error))",');
        indent.writeln(r'"Stacktrace: \(Thread.callStackSymbols)",');
      });
    });
  }

  void _writeNilOrValue(Indent indent) {
    indent.format('''

private func nilOrValue<T>(_ value: Any?) -> T? {
  if value is NSNull { return nil }
  return value as! T?
}''');
  }

  void _writeCreateConnectionError(
      SwiftOptions generatorOptions, Indent indent) {
    indent.newln();
    indent.writeScoped(
        'private func createConnectionError(withChannelName channelName: String) -> ${_getErrorClassName(generatorOptions)} {',
        '}', () {
      indent.writeln(
          'return ${_getErrorClassName(generatorOptions)}(code: "channel-error", message: "Unable to establish connection on channel: \'\\(channelName)\'.", details: "")');
    });
  }

  @override
  void writeGeneralUtilities(
    SwiftOptions generatorOptions,
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

    _writePigeonError(generatorOptions, indent);

    if (hasHostApi) {
      _writeWrapResult(indent);
      _writeWrapError(generatorOptions, indent);
    }
    if (hasFlutterApi) {
      _writeCreateConnectionError(generatorOptions, indent);
    }

    _writeIsNullish(indent);
    _writeNilOrValue(indent);
  }

  void _writeFlutterMethod(
    Indent indent, {
    required SwiftOptions generatorOptions,
    required String name,
    required String channelName,
    required List<Parameter> parameters,
    required TypeDeclaration returnType,
    required String? swiftFunction,
  }) {
    final String methodSignature = _getMethodSignature(
      name: name,
      parameters: parameters,
      returnType: returnType,
      errorTypeName: _getErrorClassName(generatorOptions),
      isAsynchronous: true,
      swiftFunction: swiftFunction,
      getParameterName: _getSafeArgumentName,
    );

    /// Returns an argument name that can be used in a context where it is possible to collide.
    String getEnumSafeArgumentExpression(int count, NamedType argument) {
      return '${_getArgumentName(count, argument)}Arg';
    }

    indent.writeScoped('$methodSignature {', '}', () {
      final Iterable<String> enumSafeArgNames = parameters.asMap().entries.map(
          (MapEntry<int, NamedType> e) =>
              getEnumSafeArgumentExpression(e.key, e.value));
      final String sendArgument = parameters.isEmpty
          ? 'nil'
          : '[${enumSafeArgNames.join(', ')}] as [Any?]';
      const String channel = 'channel';
      indent.writeln(
          'let channelName: String = "$channelName\\(messageChannelSuffix)"');
      indent.writeln(
          'let $channel = FlutterBasicMessageChannel(name: channelName, binaryMessenger: binaryMessenger, codec: codec)');
      indent.write('$channel.sendMessage($sendArgument) ');

      indent.addScoped('{ response in', '}', () {
        indent.writeScoped(
            'guard let listResponse = response as? [Any?] else {', '}', () {
          indent.writeln(
              'completion(.failure(createConnectionError(withChannelName: channelName)))');
          indent.writeln('return');
        });
        indent.writeScoped('if listResponse.count > 1 {', '} ', () {
          indent.writeln('let code: String = listResponse[0] as! String');
          indent.writeln('let message: String? = nilOrValue(listResponse[1])');
          indent.writeln('let details: String? = nilOrValue(listResponse[2])');
          indent.writeln(
              'completion(.failure(${_getErrorClassName(generatorOptions)}(code: code, message: message, details: details)))');
        }, addTrailingNewline: false);
        if (!returnType.isNullable && !returnType.isVoid) {
          indent.addScoped('else if listResponse[0] == nil {', '} ', () {
            indent.writeln(
                'completion(.failure(${_getErrorClassName(generatorOptions)}(code: "null-error", message: "Flutter api returned null value for non-null return value.", details: "")))');
          }, addTrailingNewline: false);
        }
        indent.addScoped('else {', '}', () {
          if (returnType.isVoid) {
            indent.writeln('completion(.success(Void()))');
          } else {
            final String fieldType = _swiftTypeForDartType(returnType);
            _writeGenericCasting(
              indent: indent,
              value: 'listResponse[0]',
              variableName: 'result',
              fieldType: fieldType,
              type: returnType,
            );
            indent.writeln('completion(.success(result))');
          }
        });
      });
    });
  }

  void _writeHostMethodMessageHandler(
    Indent indent, {
    required String name,
    required String channelName,
    required Iterable<Parameter> parameters,
    required TypeDeclaration returnType,
    required bool isAsynchronous,
    required String? swiftFunction,
    List<String> documentationComments = const <String>[],
  }) {
    final _SwiftFunctionComponents components = _SwiftFunctionComponents(
      name: name,
      parameters: parameters,
      returnType: returnType,
      swiftFunction: swiftFunction,
    );

    final String varChannelName = '${name}Channel';
    addDocumentationComments(indent, documentationComments, _docCommentSpec);
    indent.writeln(
        'let $varChannelName = FlutterBasicMessageChannel(name: "$channelName\\(channelSuffix)", binaryMessenger: binaryMessenger, codec: codec)');
    indent.write('if let api = api ');
    indent.addScoped('{', '}', () {
      indent.write('$varChannelName.setMessageHandler ');
      final String messageVarName = parameters.isNotEmpty ? 'message' : '_';
      indent.addScoped('{ $messageVarName, reply in', '}', () {
        final List<String> methodArgument = <String>[];
        if (components.arguments.isNotEmpty) {
          indent.writeln('let args = message as! [Any?]');
          enumerate(components.arguments,
              (int index, _SwiftFunctionArgument arg) {
            final String argName = _getSafeArgumentName(index, arg.namedType);
            final String argIndex = 'args[$index]';
            final String fieldType = _swiftTypeForDartType(arg.type);

            _writeGenericCasting(
                indent: indent,
                value: argIndex,
                variableName: argName,
                fieldType: fieldType,
                type: arg.type);

            if (arg.label == '_') {
              methodArgument.add(argName);
            } else {
              methodArgument.add('${arg.label ?? arg.name}: $argName');
            }
          });
        }
        final String tryStatement = isAsynchronous ? '' : 'try ';
        // Empty parens are not required when calling a method whose only
        // argument is a trailing closure.
        final String argumentString = methodArgument.isEmpty && isAsynchronous
            ? ''
            : '(${methodArgument.join(', ')})';
        final String call =
            '${tryStatement}api.${components.name}$argumentString';
        if (isAsynchronous) {
          final String resultName = returnType.isVoid ? 'nil' : 'res';
          final String successVariableInit =
              returnType.isVoid ? '' : '(let res)';
          indent.write('$call ');

          indent.addScoped('{ result in', '}', () {
            indent.write('switch result ');
            indent.addScoped('{', '}', nestCount: 0, () {
              indent.writeln('case .success$successVariableInit:');
              indent.nest(1, () {
                indent.writeln('reply(wrapResult($resultName))');
              });
              indent.writeln('case .failure(let error):');
              indent.nest(1, () {
                indent.writeln('reply(wrapError(error))');
              });
            });
          });
        } else {
          indent.write('do ');
          indent.addScoped('{', '}', () {
            if (returnType.isVoid) {
              indent.writeln(call);
              indent.writeln('reply(wrapResult(nil))');
            } else {
              indent.writeln('let result = $call');
              indent.writeln('reply(wrapResult(result))');
            }
          }, addTrailingNewline: false);
          indent.addScoped(' catch {', '}', () {
            indent.writeln('reply(wrapError(error))');
          });
        }
      });
    }, addTrailingNewline: false);
    indent.addScoped(' else {', '}', () {
      indent.writeln('$varChannelName.setMessageHandler(nil)');
    });
  }

  void _writePigeonError(SwiftOptions generatorOptions, Indent indent) {
    indent.newln();
    indent.writeln(
        '/// Error class for passing custom error details to Dart side.');
    indent.writeScoped(
        'final class ${_getErrorClassName(generatorOptions)}: Error {', '}',
        () {
      indent.writeln('let code: String');
      indent.writeln('let message: String?');
      indent.writeln('let details: Any?');
      indent.newln();
      indent.writeScoped(
          'init(code: String, message: String?, details: Any?) {', '}', () {
        indent.writeln('self.code = code');
        indent.writeln('self.message = message');
        indent.writeln('self.details = details');
      });
      indent.newln();
      indent.writeScoped('var localizedDescription: String {', '}', () {
        indent.writeScoped('return', '', () {
          indent.writeln(
              '"${_getErrorClassName(generatorOptions)}(code: \\(code), message: \\(message ?? "<nil>"), details: \\(details ?? "<nil>")"');
        }, addTrailingNewline: false);
      });
    });
  }
}

/// Calculates the name of the codec that will be generated for [api].
String _getCodecName(SwiftOptions options) {
  return '${options.fileSpecificClassNameComponent}PigeonCodec';
}

String _getErrorClassName(SwiftOptions generatorOptions) {
  return generatorOptions.errorClassName ?? 'PigeonError';
}

String _getArgumentName(int count, NamedType argument) {
  return argument.name.isEmpty ? 'arg$count' : argument.name;
}

/// Returns an argument name that can be used in a context where it is possible to collide.
String _getSafeArgumentName(int count, NamedType argument) {
  return '${_getArgumentName(count, argument)}Arg';
}

String _camelCase(String text) {
  final String pascal = text.split('_').map((String part) {
    return part.isEmpty ? '' : part[0].toUpperCase() + part.substring(1);
  }).join();
  return pascal[0].toLowerCase() + pascal.substring(1);
}

/// Converts a [List] of [TypeDeclaration]s to a comma separated [String] to be
/// used in Swift code.
String _flattenTypeArguments(List<TypeDeclaration> args) {
  return args.map((TypeDeclaration e) => _swiftTypeForDartType(e)).join(', ');
}

String _swiftTypeForBuiltinGenericDartType(TypeDeclaration type) {
  if (type.typeArguments.isEmpty ||
      (type.typeArguments.first.baseName == 'Object')) {
    if (type.baseName == 'List') {
      return '[Any?]';
    } else if (type.baseName == 'Map') {
      return '[AnyHashable: Any?]';
    } else {
      return 'Any';
    }
  } else {
    if (type.baseName == 'List') {
      return '[${_nullsafeSwiftTypeForDartType(type.typeArguments.first)}]';
    } else if (type.baseName == 'Map') {
      return '[${_nullsafeSwiftTypeForDartType(type.typeArguments.first)}: ${_nullsafeSwiftTypeForDartType(type.typeArguments.last)}]';
    } else {
      return '${type.baseName}<${_flattenTypeArguments(type.typeArguments)}>';
    }
  }
}

String? _swiftTypeForBuiltinDartType(TypeDeclaration type) {
  const Map<String, String> swiftTypeForDartTypeMap = <String, String>{
    'void': 'Void',
    'bool': 'Bool',
    'String': 'String',
    'int': 'Int64',
    'double': 'Double',
    'Uint8List': 'FlutterStandardTypedData',
    'Int32List': 'FlutterStandardTypedData',
    'Int64List': 'FlutterStandardTypedData',
    'Float32List': 'FlutterStandardTypedData',
    'Float64List': 'FlutterStandardTypedData',
    'Object': 'Any',
  };
  if (swiftTypeForDartTypeMap.containsKey(type.baseName)) {
    return swiftTypeForDartTypeMap[type.baseName];
  } else if (type.baseName == 'List' || type.baseName == 'Map') {
    return _swiftTypeForBuiltinGenericDartType(type);
  } else {
    return null;
  }
}

String _swiftTypeForDartType(TypeDeclaration type) {
  return _swiftTypeForBuiltinDartType(type) ?? type.baseName;
}

String _nullsafeSwiftTypeForDartType(TypeDeclaration type) {
  final String nullSafe = type.isNullable ? '?' : '';
  return '${_swiftTypeForDartType(type)}$nullSafe';
}

String _getMethodSignature({
  required String name,
  required Iterable<Parameter> parameters,
  required TypeDeclaration returnType,
  required String errorTypeName,
  bool isAsynchronous = false,
  String? swiftFunction,
  String Function(int index, NamedType argument) getParameterName =
      _getArgumentName,
}) {
  final _SwiftFunctionComponents components = _SwiftFunctionComponents(
    name: name,
    parameters: parameters,
    returnType: returnType,
    swiftFunction: swiftFunction,
  );
  final String returnTypeString =
      returnType.isVoid ? 'Void' : _nullsafeSwiftTypeForDartType(returnType);

  final Iterable<String> types =
      parameters.map((NamedType e) => _nullsafeSwiftTypeForDartType(e.type));
  final Iterable<String> labels = indexMap(components.arguments,
      (int index, _SwiftFunctionArgument argument) {
    return argument.label ?? _getArgumentName(index, argument.namedType);
  });
  final Iterable<String> names = indexMap(parameters, getParameterName);
  final String parameterSignature =
      map3(types, labels, names, (String type, String label, String name) {
    return '${label != name ? '$label ' : ''}$name: $type';
  }).join(', ');

  if (isAsynchronous) {
    if (parameters.isEmpty) {
      return 'func ${components.name}(completion: @escaping (Result<$returnTypeString, $errorTypeName>) -> Void)';
    } else {
      return 'func ${components.name}($parameterSignature, completion: @escaping (Result<$returnTypeString, $errorTypeName>) -> Void)';
    }
  } else {
    if (returnType.isVoid) {
      return 'func ${components.name}($parameterSignature) throws';
    } else {
      return 'func ${components.name}($parameterSignature) throws -> $returnTypeString';
    }
  }
}

/// A class that represents a Swift function argument.
///
/// The [name] is the name of the argument.
/// The [type] is the type of the argument.
/// The [namedType] is the [NamedType] that this argument is generated from.
/// The [label] is the label of the argument.
class _SwiftFunctionArgument {
  _SwiftFunctionArgument({
    required this.name,
    required this.type,
    required this.namedType,
    this.label,
  });

  final String name;
  final TypeDeclaration type;
  final NamedType namedType;
  final String? label;
}

/// A class that represents a Swift function signature.
///
/// The [name] is the name of the function.
/// The [arguments] are the arguments of the function.
/// The [returnType] is the return type of the function.
/// The [method] is the method that this function signature is generated from.
class _SwiftFunctionComponents {
  /// Constructor that generates a [_SwiftFunctionComponents] from a [Method].
  factory _SwiftFunctionComponents({
    required String name,
    required Iterable<Parameter> parameters,
    required TypeDeclaration returnType,
    String? swiftFunction,
  }) {
    if (swiftFunction == null || swiftFunction.isEmpty) {
      return _SwiftFunctionComponents._(
        name: name,
        returnType: returnType,
        arguments: parameters
            .map((NamedType field) => _SwiftFunctionArgument(
                  name: field.name,
                  type: field.type,
                  namedType: field,
                ))
            .toList(),
      );
    }

    final String argsExtractor = repeat(r'(\w+):', parameters.length).join();
    final RegExp signatureRegex = RegExp(r'(\w+) *\(' + argsExtractor + r'\)');
    final RegExpMatch match = signatureRegex.firstMatch(swiftFunction)!;

    final Iterable<String> labels = match
        .groups(List<int>.generate(parameters.length, (int index) => index + 2))
        .whereType();

    return _SwiftFunctionComponents._(
      name: match.group(1)!,
      returnType: returnType,
      arguments: map2(
        parameters,
        labels,
        (NamedType field, String label) => _SwiftFunctionArgument(
          name: field.name,
          label: label == field.name ? null : label,
          type: field.type,
          namedType: field,
        ),
      ).toList(),
    );
  }

  _SwiftFunctionComponents._({
    required this.name,
    required this.arguments,
    required this.returnType,
  });

  final String name;
  final List<_SwiftFunctionArgument> arguments;
  final TypeDeclaration returnType;
}

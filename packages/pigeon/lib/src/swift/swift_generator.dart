// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:graphs/graphs.dart';
import 'package:pub_semver/pub_semver.dart';

import '../ast.dart';
import '../functional.dart';
import '../generator.dart';
import '../generator_tools.dart';
import '../types/task_queue.dart';
import 'templates.dart';

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
    this.includeErrorClass = true,
  });

  /// A copyright header that will get prepended to generated code.
  final Iterable<String>? copyrightHeader;

  /// A String to augment class names to avoid cross file collisions.
  final String? fileSpecificClassNameComponent;

  /// The name of the error class used for passing custom error parameters.
  final String? errorClassName;

  /// Whether to include the error class in generation.
  ///
  /// This should only ever be set to false if you have another generated
  /// Swift file in the same directory.
  final bool includeErrorClass;

  /// Creates a [SwiftOptions] from a Map representation where:
  /// `x = SwiftOptions.fromList(x.toMap())`.
  static SwiftOptions fromList(Map<String, Object> map) {
    return SwiftOptions(
      copyrightHeader: map['copyrightHeader'] as Iterable<String>?,
      fileSpecificClassNameComponent:
          map['fileSpecificClassNameComponent'] as String?,
      errorClassName: map['errorClassName'] as String?,
      includeErrorClass: map['includeErrorClass'] as bool? ?? true,
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
      'includeErrorClass': includeErrorClass,
    };
    return result;
  }

  /// Overrides any non-null parameters from [options] into this to make a new
  /// [SwiftOptions].
  SwiftOptions merge(SwiftOptions options) {
    return SwiftOptions.fromList(mergeMaps(toMap(), options.toMap()));
  }
}

/// Options that control how Swift code will be generated.
class InternalSwiftOptions extends InternalOptions {
  /// Creates a [InternalSwiftOptions] object
  const InternalSwiftOptions({
    this.copyrightHeader,
    required this.swiftOut,
    this.fileSpecificClassNameComponent,
    this.errorClassName,
    this.includeErrorClass = true,
  });

  /// Creates InternalSwiftOptions from SwiftOptions.
  InternalSwiftOptions.fromSwiftOptions(
    SwiftOptions options, {
    required this.swiftOut,
    Iterable<String>? copyrightHeader,
  }) : copyrightHeader = options.copyrightHeader ?? copyrightHeader,
       fileSpecificClassNameComponent =
           options.fileSpecificClassNameComponent ??
           swiftOut.split('/').lastOrNull?.split('.').firstOrNull ??
           '',
       errorClassName = options.errorClassName,
       includeErrorClass = options.includeErrorClass;

  /// A copyright header that will get prepended to generated code.
  final Iterable<String>? copyrightHeader;

  /// Path to the swift file that will be generated.
  final String swiftOut;

  /// A String to augment class names to avoid cross file collisions.
  final String? fileSpecificClassNameComponent;

  /// The name of the error class used for passing custom error parameters.
  final String? errorClassName;

  /// Whether to include the error class in generation.
  ///
  /// This should only ever be set to false if you have another generated
  /// Swift file in the same directory.
  final bool includeErrorClass;
}

/// Options that control how Swift code will be generated for a specific
/// ProxyApi.
class SwiftProxyApiOptions {
  /// Constructs a [SwiftProxyApiOptions].
  const SwiftProxyApiOptions({
    this.name,
    this.import,
    this.minIosApi,
    this.minMacosApi,
    this.supportsIos = true,
    this.supportsMacos = true,
  });

  /// The name of the Swift class.
  ///
  /// By default, generated code will use the same name as the class in the Dart
  /// pigeon file.
  final String? name;

  /// The name of the module that needs to be imported to access the class.
  final String? import;

  /// The API version requirement for iOS.
  ///
  /// This adds `@available` annotations on top of any constructor, field, or
  /// method that references this element.
  final String? minIosApi;

  /// The API version requirement for macOS.
  ///
  /// This adds `@available` annotations on top of any constructor, field, or
  /// method that references this element.
  final String? minMacosApi;

  /// Whether this ProxyApi class compiles on iOS.
  ///
  /// This adds `#` annotations on top of any constructor, field, or
  /// method that references this element.
  ///
  /// Defaults to true.
  final bool supportsIos;

  /// Whether this ProxyApi class compiles on macOS.
  ///
  /// Defaults to true.
  final bool supportsMacos;
}

/// Options for Swift implementation of Event Channels.
class SwiftEventChannelOptions {
  /// Constructs a [SwiftEventChannelOptions].
  const SwiftEventChannelOptions({this.includeSharedClasses = true});

  /// Whether to include the error class in generation.
  ///
  /// This should only ever be set to false if you have another generated
  /// Swift file with Event Channels in the same directory.
  final bool includeSharedClasses;
}

/// Class that manages all Swift code generation.
class SwiftGenerator extends StructuredGenerator<InternalSwiftOptions> {
  /// Instantiates a Swift Generator.
  const SwiftGenerator();

  @override
  void writeFilePrologue(
    InternalSwiftOptions generatorOptions,
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
    InternalSwiftOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.writeln('import Foundation');

    _writeProxyApiImports(indent, root.apis.whereType<AstProxyApi>());
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
    InternalSwiftOptions generatorOptions,
    Root root,
    Indent indent,
    Enum anEnum, {
    required String dartPackageName,
  }) {
    indent.newln();
    addDocumentationComments(
      indent,
      anEnum.documentationComments,
      _docCommentSpec,
    );

    indent.write('enum ${anEnum.name}: Int ');
    indent.addScoped('{', '}', () {
      enumerate(anEnum.members, (int index, final EnumMember member) {
        addDocumentationComments(
          indent,
          member.documentationComments,
          _docCommentSpec,
        );
        indent.writeln('case ${_camelCase(member.name)} = $index');
      });
    });
  }

  @override
  void writeGeneralCodec(
    InternalSwiftOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    final String codecName = _getMessageCodecName(generatorOptions);
    final String readerWriterName = '${codecName}ReaderWriter';
    final String readerName = '${codecName}Reader';
    final String writerName = '${codecName}Writer';

    final List<EnumeratedType> enumeratedTypes = getEnumeratedTypes(
      root,
      excludeSealedClasses: true,
    ).toList();

    void writeDecodeLogic(EnumeratedType customType) {
      indent.writeln('case ${customType.enumeration}:');
      indent.nest(1, () {
        if (customType.type == CustomTypes.customEnum) {
          indent.writeln(
            'let enumResultAsInt: Int? = nilOrValue(self.readValue() as! Int?)',
          );
          indent.writeScoped(
            'if let enumResultAsInt = enumResultAsInt {',
            '}',
            () {
              indent.writeln(
                'return ${customType.name}(rawValue: enumResultAsInt)',
              );
            },
          );
          indent.writeln('return nil');
        } else {
          indent.writeln(
            'return ${customType.name}.fromList(self.readValue() as! [Any?])',
          );
        }
      });
    }

    final EnumeratedType overflowClass = EnumeratedType(
      _overflowClassName,
      maximumCodecFieldKey,
      CustomTypes.customClass,
    );

    if (root.requiresOverflowClass) {
      indent.newln();
      _writeCodecOverflowUtilities(
        generatorOptions,
        root,
        indent,
        enumeratedTypes,
        dartPackageName: dartPackageName,
      );
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
                  'let wrap = $_overflowClassName(type: ${customType.enumeration - maximumCodecFieldKey}, wrapped: value.$encodeString)',
                );
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
    indent.write(
      'private class $readerWriterName: FlutterStandardReaderWriter ',
    );
    indent.addScoped('{', '}', () {
      indent.write(
        'override func reader(with data: Data) -> FlutterStandardReader ',
      );
      indent.addScoped('{', '}', () {
        indent.writeln('return $readerName(data: data)');
      });
      indent.newln();
      indent.write(
        'override func writer(with data: NSMutableData) -> FlutterStandardWriter ',
      );
      indent.addScoped('{', '}', () {
        indent.writeln('return $writerName(data: data)');
      });
    });
    indent.newln();

    // Generate Codec
    indent.write(
      'class $codecName: FlutterStandardMessageCodec, @unchecked Sendable ',
    );
    indent.addScoped('{', '}', () {
      indent.writeln(
        'static let shared = $codecName(readerWriter: $readerWriterName())',
      );
    });
    indent.newln();
    if (root.containsEventChannel) {
      indent.writeln(
        'var ${_getMethodCodecVarName(generatorOptions)} = FlutterStandardMethodCodec(readerWriter: $readerWriterName());',
      );
      indent.newln();
    }
  }

  void _writeDataClassSignature(
    Indent indent,
    Class classDefinition, {
    bool private = false,
    bool hashable = true,
  }) {
    final String privateString = private ? 'private ' : '';
    final String extendsString = classDefinition.superClass != null
        ? ': ${classDefinition.superClass!.name}'
        : hashable
        ? ': Hashable'
        : '';
    if (classDefinition.isSwiftClass) {
      indent.write(
        '${privateString}class ${classDefinition.name}$extendsString ',
      );
    } else if (classDefinition.isSealed) {
      indent.write('protocol ${classDefinition.name} ');
    } else {
      indent.write(
        '${privateString}struct ${classDefinition.name}$extendsString ',
      );
    }

    indent.addScoped('{', '', () {
      final Iterable<NamedType> fields = getFieldsInSerializationOrder(
        classDefinition,
      );

      if (classDefinition.isSwiftClass) {
        _writeClassInit(indent, fields.toList());
      }

      for (final NamedType field in fields) {
        addDocumentationComments(
          indent,
          field.documentationComments,
          _docCommentSpec,
        );
        indent.write('var ');
        _writeClassField(indent, field, addNil: !classDefinition.isSwiftClass);
        indent.newln();
      }
    }, addTrailingNewline: false);
  }

  void _writeCodecOverflowUtilities(
    InternalSwiftOptions generatorOptions,
    Root root,
    Indent indent,
    List<EnumeratedType> types, {
    required String dartPackageName,
  }) {
    final NamedType overflowInt = NamedType(
      name: 'type',
      type: const TypeDeclaration(baseName: 'Int', isNullable: false),
    );
    final NamedType overflowObject = NamedType(
      name: 'wrapped',
      type: const TypeDeclaration(baseName: 'Object', isNullable: true),
    );
    final List<NamedType> overflowFields = <NamedType>[
      overflowInt,
      overflowObject,
    ];
    final Class overflowClass = Class(
      name: _overflowClassName,
      fields: overflowFields,
    );
    indent.newln();
    _writeDataClassSignature(
      indent,
      overflowClass,
      private: true,
      hashable: false,
    );
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
            indent.writeScoped(
              'case ${i - totalCustomCodecKeysAllowed}:',
              '',
              () {
                if (types[i].type == CustomTypes.customClass) {
                  indent.writeln(
                    'return ${types[i].name}.fromList(wrapped as! [Any?]);',
                  );
                } else if (types[i].type == CustomTypes.customEnum) {
                  indent.writeln(
                    'return ${types[i].name}(rawValue: wrapped as! Int);',
                  );
                }
              },
              addTrailingNewline: false,
            );
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
    InternalSwiftOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    final List<String> generatedComments = <String>[
      ' Generated class from Pigeon that represents data sent in messages.',
    ];
    if (classDefinition.isSealed) {
      generatedComments.add(
        ' This protocol should not be extended by any user class outside of the generated file.',
      );
    }
    indent.newln();
    addDocumentationComments(
      indent,
      classDefinition.documentationComments,
      _docCommentSpec,
      generatorComments: generatedComments,
    );
    _writeDataClassSignature(indent, classDefinition);
    indent.writeScoped('', '}', () {
      if (classDefinition.isSealed) {
        return;
      }
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
      writeClassEquality(
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
    indent.add('${field.name}: ${_nullSafeSwiftTypeForDartType(field.type)}');
    final String defaultNil = field.type.isNullable && addNil ? ' = nil' : '';
    indent.add(defaultNil);
  }

  void _writeClassFieldInit(Indent indent, NamedType field) {
    indent.writeln('self.${field.name} = ${field.name}');
  }

  @override
  void writeClassEncode(
    InternalSwiftOptions generatorOptions,
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
        for (final NamedType field in getFieldsInSerializationOrder(
          classDefinition,
        )) {
          indent.writeln('${field.name}$separator');
        }
      });
    });
  }

  @override
  void writeClassEquality(
    InternalSwiftOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    indent.writeScoped(
      'static func == (lhs: ${classDefinition.name}, rhs: ${classDefinition.name}) -> Bool {',
      '}',
      () {
        if (classDefinition.isSwiftClass) {
          indent.writeScoped('if (lhs === rhs) {', '}', () {
            indent.writeln('return true');
          });
        }
        indent.write(
          'return deepEquals${generatorOptions.fileSpecificClassNameComponent}(lhs.toList(), rhs.toList())',
        );
      },
    );

    indent.writeScoped('func hash(into hasher: inout Hasher) {', '}', () {
      indent.writeln(
        'deepHash${generatorOptions.fileSpecificClassNameComponent}(value: toList(), hasher: &hasher)',
      );
    });
  }

  @override
  void writeClassDecode(
    InternalSwiftOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    final String className = classDefinition.name;
    indent.writeln('// swift-format-ignore: AlwaysUseLowerCamelCase');
    indent.write(
      'static func fromList(_ ${varNamePrefix}list: [Any?]) -> $className? ',
    );

    indent.addScoped('{', '}', () {
      enumerate(getFieldsInSerializationOrder(classDefinition), (
        int index,
        final NamedType field,
      ) {
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
        for (final NamedType field in getFieldsInSerializationOrder(
          classDefinition,
        )) {
          final String comma =
              getFieldsInSerializationOrder(classDefinition).last == field
              ? ''
              : ',';
          // Force-casting nullable enums in maps doesn't work the same as other types.
          // It needs soft-casting followed by force unwrapping.
          final String forceUnwrapMapWithNullableEnums =
              (field.type.baseName == 'Map' &&
                  !field.type.isNullable &&
                  field.type.typeArguments.any(
                    (TypeDeclaration type) => type.isEnum,
                  ))
              ? '!'
              : '';
          indent.writeln(
            '${field.name}: ${field.name}$forceUnwrapMapWithNullableEnums$comma',
          );
        }
      });
    });
  }

  @override
  void writeApis(
    InternalSwiftOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    if (root.apis.any(
      (Api api) =>
          api is AstHostApi &&
          api.methods.any((Method it) => it.isAsynchronous),
    )) {
      indent.newln();
    }
    super.writeApis(
      generatorOptions,
      root,
      indent,
      dartPackageName: dartPackageName,
    );
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
    InternalSwiftOptions generatorOptions,
    Root root,
    Indent indent,
    AstFlutterApi api, {
    required String dartPackageName,
  }) {
    const List<String> generatedComments = <String>[
      ' Generated protocol from Pigeon that represents Flutter messages that can be called from Swift.',
    ];
    addDocumentationComments(
      indent,
      api.documentationComments,
      _docCommentSpec,
      generatorComments: generatedComments,
    );

    indent.addScoped('protocol ${api.name}Protocol {', '}', () {
      for (final Method func in api.methods) {
        addDocumentationComments(
          indent,
          func.documentationComments,
          _docCommentSpec,
        );
        indent.writeln(
          _getMethodSignature(
            name: func.name,
            parameters: func.parameters,
            returnType: func.returnType,
            errorTypeName: _getErrorClassName(generatorOptions),
            isAsynchronous: true,
            swiftFunction: func.swiftFunction,
            getParameterName: _getSafeArgumentName,
          ),
        );
      }
    });

    indent.write('class ${api.name}: ${api.name}Protocol ');
    indent.addScoped('{', '}', () {
      indent.writeln('private let binaryMessenger: FlutterBinaryMessenger');
      indent.writeln('private let messageChannelSuffix: String');
      indent.write(
        'init(binaryMessenger: FlutterBinaryMessenger, messageChannelSuffix: String = "") ',
      );
      indent.addScoped('{', '}', () {
        indent.writeln('self.binaryMessenger = binaryMessenger');
        indent.writeln(
          r'self.messageChannelSuffix = messageChannelSuffix.count > 0 ? ".\(messageChannelSuffix)" : ""',
        );
      });
      final String codecName = _getMessageCodecName(generatorOptions);
      indent.write('var codec: $codecName ');
      indent.addScoped('{', '}', () {
        indent.writeln('return $codecName.shared');
      });

      for (final Method func in api.methods) {
        addDocumentationComments(
          indent,
          func.documentationComments,
          _docCommentSpec,
        );
        _writeFlutterMethod(
          indent,
          generatorOptions: generatorOptions,
          name: func.name,
          channelName:
              '${makeChannelName(api, func, dartPackageName)}\\(messageChannelSuffix)',
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
    InternalSwiftOptions generatorOptions,
    Root root,
    Indent indent,
    AstHostApi api, {
    required String dartPackageName,
  }) {
    final String apiName = api.name;

    const List<String> generatedComments = <String>[
      ' Generated protocol from Pigeon that represents a handler of messages from Flutter.',
    ];
    addDocumentationComments(
      indent,
      api.documentationComments,
      _docCommentSpec,
      generatorComments: generatedComments,
    );

    indent.write('protocol $apiName ');
    indent.addScoped('{', '}', () {
      for (final Method method in api.methods) {
        addDocumentationComments(
          indent,
          method.documentationComments,
          _docCommentSpec,
        );
        indent.writeln(
          _getMethodSignature(
            name: method.name,
            parameters: method.parameters,
            returnType: method.returnType,
            errorTypeName: 'Error',
            isAsynchronous: method.isAsynchronous,
            swiftFunction: method.swiftFunction,
          ),
        );
      }
    });

    indent.newln();
    indent.writeln(
      '$_docCommentPrefix Generated setup class from Pigeon to handle messages through the `binaryMessenger`.',
    );
    indent.write('class ${apiName}Setup ');
    indent.addScoped('{', '}', () {
      indent.writeln(
        'static var codec: FlutterStandardMessageCodec { ${_getMessageCodecName(generatorOptions)}.shared }',
      );
      indent.writeln(
        '$_docCommentPrefix Sets up an instance of `$apiName` to handle messages through the `binaryMessenger`.',
      );
      indent.write(
        'static func setUp(binaryMessenger: FlutterBinaryMessenger, api: $apiName?, messageChannelSuffix: String = "") ',
      );
      indent.addScoped('{', '}', () {
        indent.writeln(
          r'let channelSuffix = messageChannelSuffix.count > 0 ? ".\(messageChannelSuffix)" : ""',
        );
        String? serialBackgroundQueue;
        if (api.methods.any(
          (Method m) => m.taskQueueType == TaskQueueType.serialBackgroundThread,
        )) {
          serialBackgroundQueue = 'taskQueue';
          // TODO(stuartmorgan): Remove the ? once macOS supports task queues
          // and this is no longer an optional protocol method.
          // See https://github.com/flutter/flutter/issues/162613 for why this
          // is an ifdef instead of just relying on the optionality check.
          indent.format('''
#if os(iOS)
  let $serialBackgroundQueue = binaryMessenger.makeBackgroundTaskQueue?()
#else
  let $serialBackgroundQueue: FlutterTaskQueue? = nil
#endif''');
        }
        for (final Method method in api.methods) {
          _writeHostMethodMessageHandler(
            indent,
            name: method.name,
            channelName:
                '${makeChannelName(api, method, dartPackageName)}\\(channelSuffix)',
            parameters: method.parameters,
            returnType: method.returnType,
            isAsynchronous: method.isAsynchronous,
            swiftFunction: method.swiftFunction,
            documentationComments: method.documentationComments,
            serialBackgroundQueue:
                method.taskQueueType == TaskQueueType.serialBackgroundThread
                ? serialBackgroundQueue
                : null,
          );
        }
      });
    });
  }

  @override
  void writeInstanceManager(
    InternalSwiftOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.format(instanceManagerFinalizerDelegateTemplate(generatorOptions));
    indent.format(instanceManagerFinalizerTemplate(generatorOptions));
    indent.format(instanceManagerTemplate(generatorOptions));
  }

  @override
  void writeInstanceManagerApi(
    InternalSwiftOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    final String instanceManagerApiName =
        '${swiftInstanceManagerClassName(generatorOptions)}Api';

    final String removeStrongReferenceName =
        makeRemoveStrongReferenceChannelName(dartPackageName);

    indent.writeScoped('private class $instanceManagerApiName {', '}', () {
      addDocumentationComments(indent, <String>[
        ' The codec used for serializing messages.',
      ], _docCommentSpec);
      indent.writeln(
        'var codec: FlutterStandardMessageCodec { ${_getMessageCodecName(generatorOptions)}.shared }',
      );
      indent.newln();

      addDocumentationComments(indent, <String>[
        ' Handles sending and receiving messages with Dart.',
      ], _docCommentSpec);
      indent.writeln('unowned let binaryMessenger: FlutterBinaryMessenger');
      indent.newln();

      indent.writeScoped(
        'init(binaryMessenger: FlutterBinaryMessenger) {',
        '}',
        () {
          indent.writeln('self.binaryMessenger = binaryMessenger');
        },
      );
      indent.newln();

      addDocumentationComments(indent, <String>[
        ' Sets up an instance of `$instanceManagerApiName` to handle messages through the `binaryMessenger`.',
      ], _docCommentSpec);
      indent.writeScoped(
        'static func setUpMessageHandlers(binaryMessenger: FlutterBinaryMessenger, instanceManager: ${swiftInstanceManagerClassName(generatorOptions)}?) {',
        '}',
        () {
          indent.writeln(
            'let codec = ${_getMessageCodecName(generatorOptions)}.shared',
          );
          const String setHandlerCondition =
              'let instanceManager = instanceManager';
          _writeHostMethodMessageHandler(
            indent,
            name: 'removeStrongReference',
            channelName: removeStrongReferenceName,
            parameters: <Parameter>[
              Parameter(
                name: 'identifier',
                type: const TypeDeclaration(baseName: 'int', isNullable: false),
              ),
            ],
            returnType: const TypeDeclaration.voidDeclaration(),
            swiftFunction: 'method(withIdentifier:)',
            setHandlerCondition: setHandlerCondition,
            isAsynchronous: false,
            onCreateCall:
                (List<String> safeArgNames, {required String apiVarName}) {
                  return 'let _: AnyObject? = try instanceManager.removeInstance(${safeArgNames.single})';
                },
          );
          _writeHostMethodMessageHandler(
            indent,
            name: 'clear',
            channelName: makeClearChannelName(dartPackageName),
            parameters: <Parameter>[],
            returnType: const TypeDeclaration.voidDeclaration(),
            setHandlerCondition: setHandlerCondition,
            swiftFunction: null,
            isAsynchronous: false,
            onCreateCall:
                (List<String> safeArgNames, {required String apiVarName}) {
                  return 'try instanceManager.removeAllObjects()';
                },
          );
        },
      );
      indent.newln();

      addDocumentationComments(indent, <String>[
        ' Sends a message to the Dart `InstanceManager` to remove the strong reference of the instance associated with `identifier`.',
      ], _docCommentSpec);
      _writeFlutterMethod(
        indent,
        generatorOptions: generatorOptions,
        name: 'removeStrongReference',
        parameters: <Parameter>[
          Parameter(
            name: 'identifier',
            type: const TypeDeclaration(baseName: 'int', isNullable: false),
          ),
        ],
        returnType: const TypeDeclaration.voidDeclaration(),
        channelName: removeStrongReferenceName,
        swiftFunction: null,
      );
    });
  }

  @override
  void writeProxyApiBaseCodec(
    InternalSwiftOptions generatorOptions,
    Root root,
    Indent indent,
  ) {
    final Iterable<AstProxyApi> allProxyApis = root.apis
        .whereType<AstProxyApi>();

    _writeProxyApiRegistrar(
      indent,
      generatorOptions: generatorOptions,
      allProxyApis: allProxyApis,
    );

    final String filePrefix =
        generatorOptions.fileSpecificClassNameComponent ?? '';

    final String registrarName = proxyApiRegistrarName(generatorOptions);

    indent.writeScoped(
      'private class ${proxyApiReaderWriterName(generatorOptions)}: FlutterStandardReaderWriter {',
      '}',
      () {
        indent.writeln('unowned let pigeonRegistrar: $registrarName');
        indent.newln();

        indent.writeScoped(
          'private class $filePrefix${classNamePrefix}ProxyApiCodecReader: ${_getMessageCodecName(generatorOptions)}Reader {',
          '}',
          () {
            indent.writeln('unowned let pigeonRegistrar: $registrarName');
            indent.newln();

            indent.writeScoped(
              'init(data: Data, pigeonRegistrar: $registrarName) {',
              '}',
              () {
                indent.writeln('self.pigeonRegistrar = pigeonRegistrar');
                indent.writeln('super.init(data: data)');
              },
            );
            indent.newln();

            indent.writeScoped(
              'override func readValue(ofType type: UInt8) -> Any? {',
              '}',
              () {
                indent.format('''
                  switch type {
                  case $proxyApiCodecInstanceManagerKey:
                    let identifier = self.readValue()
                    let instance: AnyObject? = pigeonRegistrar.instanceManager.instance(
                      forIdentifier: identifier is Int64 ? identifier as! Int64 : Int64(identifier as! Int32))
                    if instance == nil {
                      print("Failed to find instance with identifier: \\(identifier!)")
                    }
                    return instance
                  default:
                    return super.readValue(ofType: type)
                  }''');
              },
            );
          },
        );
        indent.newln();

        indent.writeScoped(
          'private class $filePrefix${classNamePrefix}ProxyApiCodecWriter: ${_getMessageCodecName(generatorOptions)}Writer {',
          '}',
          () {
            indent.writeln('unowned let pigeonRegistrar: $registrarName');
            indent.newln();

            indent.writeScoped(
              'init(data: NSMutableData, pigeonRegistrar: $registrarName) {',
              '}',
              () {
                indent.writeln('self.pigeonRegistrar = pigeonRegistrar');
                indent.writeln('super.init(data: data)');
              },
            );
            indent.newln();

            indent.writeScoped('override func writeValue(_ value: Any) {', '}', () {
              final List<String> nonProxyApiTypes = <String>[
                '[Any]',
                'Bool',
                'Data',
                '[AnyHashable: Any]',
                'Double',
                'FlutterStandardTypedData',
                'Int64',
                'String',
                ...root.enums.map((Enum anEnum) => anEnum.name),
              ];
              final String isBuiltinExpression = nonProxyApiTypes
                  .map((String swiftType) => 'value is $swiftType')
                  .join(' || ');
              // Non ProxyApi types are checked first to prevent the scenario
              // where a client wraps the `NSObject` class which all the
              // classes above extend.
              indent.writeScoped('if $isBuiltinExpression {', '}', () {
                indent.writeln('super.writeValue(value)');
                indent.writeln('return');
              });
              indent.newln();

              // Sort APIs where edges are an API's super class and interfaces.
              //
              // This sorts the APIs to have child classes be listed before their parent
              // classes. This prevents the scenario where a method might return the super
              // class of the actual class, so the incorrect Dart class gets created
              // because the 'value is <SuperClass>' was checked first in the codec. For
              // example:
              //
              // class Shape {}
              // class Circle extends Shape {}
              //
              // class SomeClass {
              //   Shape giveMeAShape() => Circle();
              // }
              final List<AstProxyApi> sortedApis = topologicalSort(
                allProxyApis,
                (AstProxyApi api) {
                  return <AstProxyApi>[
                    if (api.superClass?.associatedProxyApi != null)
                      api.superClass!.associatedProxyApi!,
                    ...api.interfaces.map(
                      (TypeDeclaration interface) =>
                          interface.associatedProxyApi!,
                    ),
                  ];
                },
              );

              enumerate(sortedApis, (int index, AstProxyApi api) {
                final TypeDeclaration apiAsTypeDecl = TypeDeclaration(
                  baseName: api.name,
                  isNullable: false,
                  associatedProxyApi: api,
                );
                final String? availability = _tryGetAvailabilityAnnotation(
                  <TypeDeclaration>[apiAsTypeDecl],
                );
                final String? unsupportedPlatforms =
                    _tryGetUnsupportedPlatformsCondition(<TypeDeclaration>[
                      apiAsTypeDecl,
                    ]);
                final String className = api.swiftOptions?.name ?? api.name;
                indent.format('''
                      ${unsupportedPlatforms != null ? '#if $unsupportedPlatforms' : ''}
                      if ${availability != null ? '#$availability, ' : ''}let instance = value as? $className {
                        pigeonRegistrar.apiDelegate.pigeonApi${api.name}(pigeonRegistrar).pigeonNewInstance(
                          pigeonInstance: instance
                        ) { _ in }
                        super.writeByte($proxyApiCodecInstanceManagerKey)
                        super.writeValue(
                          pigeonRegistrar.instanceManager.identifierWithStrongReference(forInstance: instance as AnyObject)!)
                        return
                      }
                      ${unsupportedPlatforms != null ? '#endif' : ''}''');
              });
              indent.newln();

              indent.format('''
                  if let instance = value as AnyObject?, pigeonRegistrar.instanceManager.containsInstance(instance)
                  {
                    super.writeByte($proxyApiCodecInstanceManagerKey)
                    super.writeValue(
                      pigeonRegistrar.instanceManager.identifierWithStrongReference(forInstance: instance)!)
                  } else {
                    print("Unsupported value: \\(value) of \\(type(of: value))")
                    assert(false, "Unsupported value for $filePrefix${classNamePrefix}ProxyApiCodecWriter")
                  }
                  ''');
            });
          },
        );
        indent.newln();

        indent.format('''
          init(pigeonRegistrar: $registrarName) {
            self.pigeonRegistrar = pigeonRegistrar
          }''');
        indent.newln();

        indent.format('''
          override func reader(with data: Data) -> FlutterStandardReader {
            return $filePrefix${classNamePrefix}ProxyApiCodecReader(data: data, pigeonRegistrar: pigeonRegistrar)
          }''');
        indent.newln();

        indent.format('''
          override func writer(with data: NSMutableData) -> FlutterStandardWriter {
            return $filePrefix${classNamePrefix}ProxyApiCodecWriter(data: data, pigeonRegistrar: pigeonRegistrar)
          }''');
      },
    );
  }

  @override
  void writeProxyApi(
    InternalSwiftOptions generatorOptions,
    Root root,
    Indent indent,
    AstProxyApi api, {
    required String dartPackageName,
  }) {
    final TypeDeclaration apiAsTypeDeclaration = TypeDeclaration(
      baseName: api.name,
      isNullable: false,
      associatedProxyApi: api,
    );

    final String swiftApiDelegateName =
        '${hostProxyApiPrefix}Delegate${api.name}';
    final String type = api.hasMethodsRequiringImplementation()
        ? 'protocol'
        : 'open class';
    indent.writeScoped('$type $swiftApiDelegateName {', '}', () {
      _writeProxyApiConstructorDelegateMethods(
        indent,
        api,
        apiAsTypeDeclaration: apiAsTypeDeclaration,
      );
      _writeProxyApiAttachedFieldDelegateMethods(
        indent,
        api,
        apiAsTypeDeclaration: apiAsTypeDeclaration,
      );
      if (api.hasCallbackConstructor()) {
        _writeProxyApiUnattachedFieldDelegateMethods(
          indent,
          api,
          apiAsTypeDeclaration: apiAsTypeDeclaration,
        );
      }
      _writeProxyApiHostMethodDelegateMethods(
        indent,
        api,
        apiAsTypeDeclaration: apiAsTypeDeclaration,
      );
    });
    indent.newln();

    final String swiftApiProtocolName =
        '${hostProxyApiPrefix}Protocol${api.name}';
    indent.writeScoped('protocol $swiftApiProtocolName {', '}', () {
      _writeProxyApiFlutterMethods(
        indent,
        api,
        generatorOptions: generatorOptions,
        apiAsTypeDeclaration: apiAsTypeDeclaration,
        dartPackageName: dartPackageName,
        writeBody: false,
      );
    });
    indent.newln();

    final String swiftApiName = '$hostProxyApiPrefix${api.name}';
    indent.writeScoped(
      'final class $swiftApiName: $swiftApiProtocolName  {',
      '}',
      () {
        indent.writeln(
          'unowned let pigeonRegistrar: ${proxyApiRegistrarName(generatorOptions)}',
        );
        indent.writeln('let pigeonDelegate: $swiftApiDelegateName');

        _writeProxyApiInheritedApiMethods(indent, api);

        indent.writeScoped(
          'init(pigeonRegistrar: ${proxyApiRegistrarName(generatorOptions)}, delegate: $swiftApiDelegateName) {',
          '}',
          () {
            indent.writeln('self.pigeonRegistrar = pigeonRegistrar');
            indent.writeln('self.pigeonDelegate = delegate');
          },
        );

        if (api.hasAnyHostMessageCalls()) {
          _writeProxyApiMessageHandlerMethod(
            indent,
            api,
            generatorOptions: generatorOptions,
            apiAsTypeDeclaration: apiAsTypeDeclaration,
            swiftApiName: swiftApiName,
            dartPackageName: dartPackageName,
          );
          indent.newln();
        }

        _writeProxyApiNewInstanceMethod(
          indent,
          api,
          generatorOptions: generatorOptions,
          apiAsTypeDeclaration: apiAsTypeDeclaration,
          newInstanceMethodName: '${classMemberNamePrefix}newInstance',
          dartPackageName: dartPackageName,
        );

        _writeProxyApiFlutterMethods(
          indent,
          api,
          generatorOptions: generatorOptions,
          apiAsTypeDeclaration: apiAsTypeDeclaration,
          dartPackageName: dartPackageName,
        );
      },
    );
  }

  String _castForceUnwrap(String value, TypeDeclaration type) {
    assert(!type.isVoid);
    if (type.baseName == 'Object') {
      return value + (type.isNullable ? '' : '!');
      // Force-casting nullable enums in maps doesn't work the same as other types.
      // It needs soft-casting followed by force unwrapping.
    } else if (type.baseName == 'Map' &&
        type.typeArguments.any((TypeDeclaration type) => type.isEnum)) {
      return '$value as? ${_swiftTypeForDartType(type)}';
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
        'let $variableName: $fieldType? = ${_castForceUnwrap(value, type)}',
      );
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

  void _writeWrapError(InternalSwiftOptions generatorOptions, Indent indent) {
    indent.newln();
    indent.write('private func wrapError(_ error: Any) -> [Any?] ');
    indent.addScoped('{', '}', () {
      indent.write(
        'if let pigeonError = error as? ${_getErrorClassName(generatorOptions)} ',
      );
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
}
''');
  }

  void _writeCreateConnectionError(
    InternalSwiftOptions generatorOptions,
    Indent indent,
  ) {
    indent.newln();
    indent.writeScoped(
      'private func createConnectionError(withChannelName channelName: String) -> ${_getErrorClassName(generatorOptions)} {',
      '}',
      () {
        indent.writeln(
          'return ${_getErrorClassName(generatorOptions)}(code: "channel-error", message: "Unable to establish connection on channel: \'\\(channelName)\'.", details: "")',
        );
      },
    );
  }

  void _writeDeepEquals(InternalSwiftOptions generatorOptions, Indent indent) {
    indent.format('''
func deepEquals${generatorOptions.fileSpecificClassNameComponent}(_ lhs: Any?, _ rhs: Any?) -> Bool {
  let cleanLhs = nilOrValue(lhs) as Any?
  let cleanRhs = nilOrValue(rhs) as Any?
  switch (cleanLhs, cleanRhs) {
  case (nil, nil):
    return true

  case (nil, _), (_, nil):
    return false

  case is (Void, Void):
    return true

  case let (cleanLhsHashable, cleanRhsHashable) as (AnyHashable, AnyHashable):
    return cleanLhsHashable == cleanRhsHashable

  case let (cleanLhsArray, cleanRhsArray) as ([Any?], [Any?]):
    guard cleanLhsArray.count == cleanRhsArray.count else { return false }
    for (index, element) in cleanLhsArray.enumerated() {
      if !deepEquals${generatorOptions.fileSpecificClassNameComponent}(element, cleanRhsArray[index]) {
        return false
      }
    }
    return true

  case let (cleanLhsDictionary, cleanRhsDictionary) as ([AnyHashable: Any?], [AnyHashable: Any?]):
    guard cleanLhsDictionary.count == cleanRhsDictionary.count else { return false }
    for (key, cleanLhsValue) in cleanLhsDictionary {
      guard cleanRhsDictionary.index(forKey: key) != nil else { return false }
      if !deepEquals${generatorOptions.fileSpecificClassNameComponent}(cleanLhsValue, cleanRhsDictionary[key]!) {
        return false
      }
    }
    return true

  default:
    // Any other type shouldn't be able to be used with pigeon. File an issue if you find this to be untrue.
    return false
  }
}

func deepHash${generatorOptions.fileSpecificClassNameComponent}(value: Any?, hasher: inout Hasher) {
  if let valueList = value as? [AnyHashable] {
     for item in valueList { deepHash${generatorOptions.fileSpecificClassNameComponent}(value: item, hasher: &hasher) }
     return
  }

  if let valueDict = value as? [AnyHashable: AnyHashable] {
    for key in valueDict.keys { 
      hasher.combine(key)
      deepHash${generatorOptions.fileSpecificClassNameComponent}(value: valueDict[key]!, hasher: &hasher)
    }
    return
  }

  if let hashableValue = value as? AnyHashable {
    hasher.combine(hashableValue.hashValue)
  }

  return hasher.combine(String(describing: value))
}

    ''');
  }

  @override
  void writeGeneralUtilities(
    InternalSwiftOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    if (generatorOptions.includeErrorClass) {
      _writePigeonError(generatorOptions, indent);
    }

    if (root.containsHostApi || root.containsProxyApi) {
      _writeWrapResult(indent);
      _writeWrapError(generatorOptions, indent);
    }
    if (root.containsFlutterApi || root.containsProxyApi) {
      _writeCreateConnectionError(generatorOptions, indent);
    }

    _writeIsNullish(indent);
    _writeNilOrValue(indent);
    if (root.classes.isNotEmpty) {
      _writeDeepEquals(generatorOptions, indent);
    }
  }

  @override
  void writeEventChannelApi(
    InternalSwiftOptions generatorOptions,
    Root root,
    Indent indent,
    AstEventChannelApi api, {
    required String dartPackageName,
  }) {
    indent.newln();
    indent.format('''
      private class PigeonStreamHandler<ReturnType>: NSObject, FlutterStreamHandler {
        private let wrapper: PigeonEventChannelWrapper<ReturnType>
        private var pigeonSink: PigeonEventSink<ReturnType>? = nil

        init(wrapper: PigeonEventChannelWrapper<ReturnType>) {
          self.wrapper = wrapper
        }

        func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
          -> FlutterError?
        {
          pigeonSink = PigeonEventSink<ReturnType>(events)
          wrapper.onListen(withArguments: arguments, sink: pigeonSink!)
          return nil
        }

        func onCancel(withArguments arguments: Any?) -> FlutterError? {
          pigeonSink = nil
          wrapper.onCancel(withArguments: arguments)
          return nil
        }
      }''');
    if (api.swiftOptions?.includeSharedClasses ?? true) {
      indent.format('''

      class PigeonEventChannelWrapper<ReturnType> {
        func onListen(withArguments arguments: Any?, sink: PigeonEventSink<ReturnType>) {}
        func onCancel(withArguments arguments: Any?) {}
      }

      class PigeonEventSink<ReturnType> {
        private let sink: FlutterEventSink

        init(_ sink: @escaping FlutterEventSink) {
          self.sink = sink
        }

        func success(_ value: ReturnType) {
          sink(value)
        }

        func error(code: String, message: String?, details: Any?) {
          sink(FlutterError(code: code, message: message, details: details))
        }

        func endOfStream() {
          sink(FlutterEndOfEventStream)
        }

      }
      ''');
    }
    addDocumentationComments(
      indent,
      api.documentationComments,
      _docCommentSpec,
    );
    for (final Method func in api.methods) {
      indent.format('''
        class ${toUpperCamelCase(func.name)}StreamHandler: PigeonEventChannelWrapper<${_swiftTypeForDartType(func.returnType)}> {
          static func register(with messenger: FlutterBinaryMessenger,
                              instanceName: String = "",
                              streamHandler: ${toUpperCamelCase(func.name)}StreamHandler) {
            var channelName = "${makeChannelName(api, func, dartPackageName)}"
            if !instanceName.isEmpty {
              channelName += ".\\(instanceName)"
            }
            let internalStreamHandler = PigeonStreamHandler<${_swiftTypeForDartType(func.returnType)}>(wrapper: streamHandler)
            let channel = FlutterEventChannel(name: channelName, binaryMessenger: messenger, codec: ${_getMethodCodecVarName(generatorOptions)})
            channel.setStreamHandler(internalStreamHandler)
          }
        }
      ''');
    }
  }

  void _writeFlutterMethod(
    Indent indent, {
    required InternalSwiftOptions generatorOptions,
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

    indent.writeScoped('$methodSignature {', '}', () {
      _writeFlutterMethodMessageCall(
        indent,
        generatorOptions: generatorOptions,
        parameters: parameters,
        returnType: returnType,
        channelName: channelName,
      );
    });
  }

  void _writeFlutterMethodMessageCall(
    Indent indent, {
    required InternalSwiftOptions generatorOptions,
    required List<Parameter> parameters,
    required TypeDeclaration returnType,
    required String channelName,
  }) {
    /// Returns an argument name that can be used in a context where it is possible to collide.
    String getEnumSafeArgumentExpression(int count, NamedType argument) {
      return '${_getArgumentName(count, argument)}Arg';
    }

    final Iterable<String> enumSafeArgNames = parameters.asMap().entries.map(
      (MapEntry<int, NamedType> e) =>
          getEnumSafeArgumentExpression(e.key, e.value),
    );
    final String sendArgument = parameters.isEmpty
        ? 'nil'
        : '[${enumSafeArgNames.join(', ')}] as [Any?]';
    const String channel = 'channel';
    indent.writeln('let channelName: String = "$channelName"');
    indent.writeln(
      'let $channel = FlutterBasicMessageChannel(name: channelName, binaryMessenger: binaryMessenger, codec: codec)',
    );
    indent.write('$channel.sendMessage($sendArgument) ');

    indent.addScoped('{ response in', '}', () {
      indent.writeScoped(
        'guard let listResponse = response as? [Any?] else {',
        '}',
        () {
          indent.writeln(
            'completion(.failure(createConnectionError(withChannelName: channelName)))',
          );
          indent.writeln('return');
        },
      );
      indent.writeScoped('if listResponse.count > 1 {', '} ', () {
        indent.writeln('let code: String = listResponse[0] as! String');
        indent.writeln('let message: String? = nilOrValue(listResponse[1])');
        indent.writeln('let details: String? = nilOrValue(listResponse[2])');
        indent.writeln(
          'completion(.failure(${_getErrorClassName(generatorOptions)}(code: code, message: message, details: details)))',
        );
      }, addTrailingNewline: false);
      if (!returnType.isNullable && !returnType.isVoid) {
        indent.addScoped('else if listResponse[0] == nil {', '} ', () {
          indent.writeln(
            'completion(.failure(${_getErrorClassName(generatorOptions)}(code: "null-error", message: "Flutter api returned null value for non-null return value.", details: "")))',
          );
        }, addTrailingNewline: false);
      }
      indent.addScoped('else {', '}', () {
        if (returnType.isVoid) {
          indent.writeln('completion(.success(()))');
        } else {
          final String fieldType = _swiftTypeForDartType(returnType);
          _writeGenericCasting(
            indent: indent,
            value: 'listResponse[0]',
            variableName: 'result',
            fieldType: fieldType,
            type: returnType,
          );
          // There is a swift bug with unwrapping maps of nullable Enums;
          final String enumMapForceUnwrap =
              returnType.baseName == 'Map' &&
                  returnType.typeArguments.any(
                    (TypeDeclaration type) => type.isEnum,
                  )
              ? '!'
              : '';
          indent.writeln('completion(.success(result$enumMapForceUnwrap))');
        }
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
    String? serialBackgroundQueue,
    String setHandlerCondition = 'let api = api',
    List<String> documentationComments = const <String>[],
    String Function(List<String> safeArgNames, {required String apiVarName})?
    onCreateCall,
  }) {
    final _SwiftFunctionComponents components = _SwiftFunctionComponents(
      name: name,
      parameters: parameters,
      returnType: returnType,
      swiftFunction: swiftFunction,
    );

    final String varChannelName = '${name}Channel';
    addDocumentationComments(indent, documentationComments, _docCommentSpec);
    final String baseArgs =
        'name: "$channelName", '
        'binaryMessenger: binaryMessenger, codec: codec';
    // The version with taskQueue: is an optional protocol method that isn't
    // implemented on macOS yet, so the call has to be conditionalized even
    // though the taskQueue argument is nullable. The runtime branching can be
    // removed once macOS supports task queues. The condition is on the task
    // queue variable not being nil because the earlier code to set it will
    // return nil on macOS where the optional parts of the protocol are not
    // implemented.
    final String channelCreationWithoutTaskQueue =
        'FlutterBasicMessageChannel($baseArgs)';
    if (serialBackgroundQueue == null) {
      indent.writeln('let $varChannelName = $channelCreationWithoutTaskQueue');
    } else {
      final String channelCreationWithTaskQueue =
          'FlutterBasicMessageChannel($baseArgs, taskQueue: $serialBackgroundQueue)';

      indent.write('let $varChannelName = $serialBackgroundQueue == nil');
      indent.addScoped('', '', () {
        indent.writeln('? $channelCreationWithoutTaskQueue');
        indent.writeln(': $channelCreationWithTaskQueue');
      });
    }

    indent.write('if $setHandlerCondition ');
    indent.addScoped('{', '}', () {
      indent.write('$varChannelName.setMessageHandler ');
      final String messageVarName = parameters.isNotEmpty ? 'message' : '_';
      indent.addScoped('{ $messageVarName, reply in', '}', () {
        final List<String> methodArgument = <String>[];
        if (components.arguments.isNotEmpty) {
          indent.writeln('let args = message as! [Any?]');
          enumerate(components.arguments, (
            int index,
            _SwiftFunctionArgument arg,
          ) {
            final String argName = _getSafeArgumentName(index, arg.namedType);
            final String argIndex = 'args[$index]';
            final String fieldType = _swiftTypeForDartType(arg.type);
            // There is a swift bug with unwrapping maps of nullable Enums;
            final String enumMapForceUnwrap =
                arg.type.baseName == 'Map' &&
                    arg.type.typeArguments.any(
                      (TypeDeclaration type) => type.isEnum,
                    )
                ? '!'
                : '';

            _writeGenericCasting(
              indent: indent,
              value: argIndex,
              variableName: argName,
              fieldType: fieldType,
              type: arg.type,
            );

            if (arg.label == '_') {
              methodArgument.add('$argName$enumMapForceUnwrap');
            } else {
              methodArgument.add(
                '${arg.label ?? arg.name}: $argName$enumMapForceUnwrap',
              );
            }
          });
        }
        final String tryStatement = isAsynchronous ? '' : 'try ';
        late final String call;
        if (onCreateCall == null) {
          // Empty parens are not required when calling a method whose only
          // argument is a trailing closure.
          final String argumentString = methodArgument.isEmpty && isAsynchronous
              ? ''
              : '(${methodArgument.join(', ')})';
          call = '${tryStatement}api.${components.name}$argumentString';
        } else {
          call = onCreateCall(methodArgument, apiVarName: 'api');
        }
        if (isAsynchronous) {
          final String resultName = returnType.isVoid ? 'nil' : 'res';
          final String successVariableInit = returnType.isVoid
              ? ''
              : '(let res)';
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

  void _writeProxyApiRegistrar(
    Indent indent, {
    required InternalSwiftOptions generatorOptions,
    required Iterable<AstProxyApi> allProxyApis,
  }) {
    final String delegateName =
        '${generatorOptions.fileSpecificClassNameComponent ?? ''}${proxyApiClassNamePrefix}ProxyApiDelegate';
    indent.writeScoped('protocol $delegateName {', '}', () {
      for (final AstProxyApi api in allProxyApis) {
        final String hostApiName = '$hostProxyApiPrefix${api.name}';
        addDocumentationComments(indent, <String>[
          ' An implementation of [$hostApiName] used to add a new Dart instance of',
          ' `${api.name}` to the Dart `InstanceManager` and make calls to Dart.',
        ], _docCommentSpec);
        indent.writeln(
          'func pigeonApi${api.name}(_ registrar: ${proxyApiRegistrarName(generatorOptions)}) -> $hostApiName',
        );
      }
    });
    indent.newln();

    // Some APIs don't have any methods to implement,
    // so this creates an extension of the PigeonProxyApiDelegate that adds
    // default implementations for these APIs.
    final Iterable<AstProxyApi> apisThatCanHaveADefaultImpl = allProxyApis
        .where((AstProxyApi api) => !api.hasMethodsRequiringImplementation());
    if (apisThatCanHaveADefaultImpl.isNotEmpty) {
      indent.writeScoped('extension $delegateName {', '}', () {
        for (final AstProxyApi api in apisThatCanHaveADefaultImpl) {
          final String hostApiName = '$hostProxyApiPrefix${api.name}';
          final String swiftApiDelegateName =
              '${hostProxyApiPrefix}Delegate${api.name}';
          indent.format('''
            func pigeonApi${api.name}(_ registrar: ${proxyApiRegistrarName(generatorOptions)}) -> $hostApiName {
              return $hostApiName(pigeonRegistrar: registrar, delegate: $swiftApiDelegateName())
            }''');
        }
      });
      indent.newln();
    }

    final String instanceManagerApiName =
        '${swiftInstanceManagerClassName(generatorOptions)}Api';

    indent.writeScoped(
      'open class ${proxyApiRegistrarName(generatorOptions)} {',
      '}',
      () {
        indent.writeln('let binaryMessenger: FlutterBinaryMessenger');
        indent.writeln('let apiDelegate: $delegateName');
        indent.writeln(
          'let instanceManager: ${swiftInstanceManagerClassName(generatorOptions)}',
        );

        addDocumentationComments(indent, <String>[
          ' Whether APIs should ignore calling to Dart.',
        ], _docCommentSpec);
        indent.writeln('public var ignoreCallsToDart = false');

        indent.writeln('private var _codec: FlutterStandardMessageCodec?');
        indent.format('''
        var codec: FlutterStandardMessageCodec {
          if _codec == nil {
            _codec = FlutterStandardMessageCodec(
              readerWriter: ${proxyApiReaderWriterName(generatorOptions)}(pigeonRegistrar: self))
          }
          return _codec!
        }''');
        indent.newln();

        indent.format('''
        private class InstanceManagerApiFinalizerDelegate: ${instanceManagerFinalizerDelegateName(generatorOptions)} {
          let api: $instanceManagerApiName

          init(_ api: $instanceManagerApiName) {
            self.api = api
          }

          public func onDeinit(identifier: Int64) {
            api.removeStrongReference(identifier: identifier) {
              _ in
            }
          }
        }''');
        indent.newln();

        indent.format('''
        init(binaryMessenger: FlutterBinaryMessenger, apiDelegate: $delegateName) {
          self.binaryMessenger = binaryMessenger
          self.apiDelegate = apiDelegate
          self.instanceManager = ${swiftInstanceManagerClassName(generatorOptions)}(
            finalizerDelegate: InstanceManagerApiFinalizerDelegate(
              $instanceManagerApiName(binaryMessenger: binaryMessenger)))
        }''');
        indent.newln();

        indent.writeScoped('func setUp() {', '}', () {
          indent.writeln(
            '$instanceManagerApiName.setUpMessageHandlers(binaryMessenger: binaryMessenger, instanceManager: instanceManager)',
          );
          for (final AstProxyApi api in allProxyApis) {
            if (api.hasAnyHostMessageCalls()) {
              indent.writeln(
                '$hostProxyApiPrefix${api.name}.setUpMessageHandlers(binaryMessenger: binaryMessenger, api: apiDelegate.pigeonApi${api.name}(self))',
              );
            }
          }
        });

        indent.writeScoped('func tearDown() {', '}', () {
          indent.writeln(
            '$instanceManagerApiName.setUpMessageHandlers(binaryMessenger: binaryMessenger, instanceManager: nil)',
          );
          for (final AstProxyApi api in allProxyApis) {
            if (api.hasAnyHostMessageCalls()) {
              indent.writeln(
                '$hostProxyApiPrefix${api.name}.setUpMessageHandlers(binaryMessenger: binaryMessenger, api: nil)',
              );
            }
          }
        });
      },
    );
  }

  // Writes the delegate method that instantiates a new instance of the Kotlin
  // class.
  void _writeProxyApiConstructorDelegateMethods(
    Indent indent,
    AstProxyApi api, {
    required TypeDeclaration apiAsTypeDeclaration,
  }) {
    for (final Constructor constructor in api.constructors) {
      final List<TypeDeclaration> allReferencedTypes = <TypeDeclaration>[
        apiAsTypeDeclaration,
        ...api.unattachedFields.map((ApiField field) => field.type),
        ...constructor.parameters.map((Parameter parameter) => parameter.type),
      ];

      final String? unsupportedPlatforms = _tryGetUnsupportedPlatformsCondition(
        allReferencedTypes,
      );
      if (unsupportedPlatforms != null) {
        indent.writeln('#if $unsupportedPlatforms');
      }

      addDocumentationComments(
        indent,
        constructor.documentationComments,
        _docCommentSpec,
      );

      final String? availableAnnotation = _tryGetAvailabilityAnnotation(
        allReferencedTypes,
      );
      if (availableAnnotation != null) {
        indent.writeln('@$availableAnnotation');
      }

      final String methodSignature = _getMethodSignature(
        name: constructor.name.isNotEmpty
            ? constructor.name
            : 'pigeonDefaultConstructor',
        parameters: <Parameter>[
          Parameter(
            name: 'pigeonApi',
            type: TypeDeclaration(
              baseName: '$hostProxyApiPrefix${api.name}',
              isNullable: false,
            ),
          ),
          ...api.unattachedFields.map((ApiField field) {
            return Parameter(name: field.name, type: field.type);
          }),
          ...constructor.parameters,
        ],
        returnType: apiAsTypeDeclaration,
        errorTypeName: '',
      );
      indent.writeln(methodSignature);

      if (unsupportedPlatforms != null) {
        indent.writeln('#endif');
      }
    }
  }

  // Writes the delegate method that handles instantiating an attached field.
  void _writeProxyApiAttachedFieldDelegateMethods(
    Indent indent,
    AstProxyApi api, {
    required TypeDeclaration apiAsTypeDeclaration,
  }) {
    for (final ApiField field in api.attachedFields) {
      final List<TypeDeclaration> allReferencedTypes = <TypeDeclaration>[
        apiAsTypeDeclaration,
        field.type,
      ];

      final String? unsupportedPlatforms = _tryGetUnsupportedPlatformsCondition(
        allReferencedTypes,
      );
      if (unsupportedPlatforms != null) {
        indent.writeln('#if $unsupportedPlatforms');
      }

      addDocumentationComments(
        indent,
        field.documentationComments,
        _docCommentSpec,
      );

      final String? availableAnnotation = _tryGetAvailabilityAnnotation(
        allReferencedTypes,
      );
      if (availableAnnotation != null) {
        indent.writeln('@$availableAnnotation');
      }

      final String methodSignature = _getMethodSignature(
        name: field.name,
        parameters: <Parameter>[
          Parameter(
            name: 'pigeonApi',
            type: TypeDeclaration(
              baseName: '$hostProxyApiPrefix${api.name}',
              isNullable: false,
            ),
          ),
          if (!field.isStatic)
            Parameter(name: 'pigeonInstance', type: apiAsTypeDeclaration),
        ],
        returnType: field.type,
        errorTypeName: '',
      );
      indent.writeln(methodSignature);

      if (unsupportedPlatforms != null) {
        indent.writeln('#endif');
      }
    }
  }

  // Writes the delegate method that handles accessing an unattached field.
  void _writeProxyApiUnattachedFieldDelegateMethods(
    Indent indent,
    AstProxyApi api, {
    required TypeDeclaration apiAsTypeDeclaration,
  }) {
    for (final ApiField field in api.unattachedFields) {
      final List<TypeDeclaration> allReferencedTypes = <TypeDeclaration>[
        apiAsTypeDeclaration,
        field.type,
      ];

      final String? unsupportedPlatforms = _tryGetUnsupportedPlatformsCondition(
        allReferencedTypes,
      );
      if (unsupportedPlatforms != null) {
        indent.writeln('#if $unsupportedPlatforms');
      }

      addDocumentationComments(
        indent,
        field.documentationComments,
        _docCommentSpec,
      );

      final String? availableAnnotation = _tryGetAvailabilityAnnotation(
        allReferencedTypes,
      );
      if (availableAnnotation != null) {
        indent.writeln('@$availableAnnotation');
      }

      final String methodSignature = _getMethodSignature(
        name: field.name,
        parameters: <Parameter>[
          Parameter(
            name: 'pigeonApi',
            type: TypeDeclaration(
              baseName: '$hostProxyApiPrefix${api.name}',
              isNullable: false,
            ),
          ),
          Parameter(name: 'pigeonInstance', type: apiAsTypeDeclaration),
        ],
        returnType: field.type,
        errorTypeName: '',
      );
      indent.writeln(methodSignature);

      if (unsupportedPlatforms != null) {
        indent.writeln('#endif');
      }
    }
  }

  // Writes the delegate method that handles making a call from for a host
  // method.
  void _writeProxyApiHostMethodDelegateMethods(
    Indent indent,
    AstProxyApi api, {
    required TypeDeclaration apiAsTypeDeclaration,
  }) {
    for (final Method method in api.hostMethods) {
      final List<TypeDeclaration> allReferencedTypes = <TypeDeclaration>[
        if (!method.isStatic) apiAsTypeDeclaration,
        method.returnType,
        ...method.parameters.map((Parameter p) => p.type),
      ];

      final String? unsupportedPlatforms = _tryGetUnsupportedPlatformsCondition(
        allReferencedTypes,
      );
      if (unsupportedPlatforms != null) {
        indent.writeln('#if $unsupportedPlatforms');
      }

      addDocumentationComments(
        indent,
        method.documentationComments,
        _docCommentSpec,
      );

      final String? availableAnnotation = _tryGetAvailabilityAnnotation(
        allReferencedTypes,
      );
      if (availableAnnotation != null) {
        indent.writeln('@$availableAnnotation');
      }

      final String methodSignature = _getMethodSignature(
        name: method.name,
        parameters: <Parameter>[
          Parameter(
            name: 'pigeonApi',
            type: TypeDeclaration(
              baseName: '$hostProxyApiPrefix${api.name}',
              isNullable: false,
            ),
          ),
          if (!method.isStatic)
            Parameter(name: 'pigeonInstance', type: apiAsTypeDeclaration),
          ...method.parameters,
        ],
        returnType: method.returnType,
        isAsynchronous: method.isAsynchronous,
        errorTypeName: 'Error',
      );
      indent.writeln(methodSignature);

      if (unsupportedPlatforms != null) {
        indent.writeln('#endif');
      }
    }
  }

  // Writes the getters for accessing the implementation of other ProxyApis.
  //
  // These are used for inherited Flutter methods.
  void _writeProxyApiInheritedApiMethods(Indent indent, AstProxyApi api) {
    final Set<String> inheritedApiNames = <String>{
      if (api.superClass != null) api.superClass!.baseName,
      ...api.interfaces.map((TypeDeclaration type) => type.baseName),
    };
    for (final String name in inheritedApiNames) {
      addDocumentationComments(indent, <String>[
        'An implementation of [$name] used to access callback methods',
      ], _docCommentSpec);
      indent.writeScoped(
        'var pigeonApi$name: $hostProxyApiPrefix$name {',
        '}',
        () {
          indent.writeln(
            'return pigeonRegistrar.apiDelegate.pigeonApi$name(pigeonRegistrar)',
          );
        },
      );
      indent.newln();
    }
  }

  // Writes the `..setUpMessageHandler` method to ensure incoming messages are
  // handled by the correct delegate host methods.
  void _writeProxyApiMessageHandlerMethod(
    Indent indent,
    AstProxyApi api, {
    required InternalSwiftOptions generatorOptions,
    required TypeDeclaration apiAsTypeDeclaration,
    required String swiftApiName,
    required String dartPackageName,
  }) {
    indent.writeScoped(
      'static func setUpMessageHandlers(binaryMessenger: FlutterBinaryMessenger, api: $swiftApiName?) {',
      '}',
      () {
        indent.format('''
          let codec: FlutterStandardMessageCodec =
            api != nil
            ? FlutterStandardMessageCodec(
              readerWriter: ${proxyApiReaderWriterName(generatorOptions)}(pigeonRegistrar: api!.pigeonRegistrar))
            : FlutterStandardMessageCodec.sharedInstance()''');
        void writeWithApiCheckIfNecessary(
          List<TypeDeclaration> types, {
          required String methodName,
          required String channelName,
          required void Function() onWrite,
        }) {
          final String? unsupportedPlatforms =
              _tryGetUnsupportedPlatformsCondition(types);
          if (unsupportedPlatforms != null) {
            indent.writeln('#if $unsupportedPlatforms');
          }

          final String? availableAnnotation = _tryGetAvailabilityAnnotation(
            types,
          );
          if (availableAnnotation != null) {
            indent.writeScoped(
              'if #$availableAnnotation {',
              '}',
              onWrite,
              addTrailingNewline: false,
            );
            indent.writeScoped(' else {', '}', () {
              final String varChannelName = '${methodName}Channel';
              indent.format('''
                let $varChannelName = FlutterBasicMessageChannel(
                  name: "$channelName",
                  binaryMessenger: binaryMessenger, codec: codec)
                if api != nil {
                  $varChannelName.setMessageHandler { message, reply in
                    reply(wrapError(FlutterError(code: "PigeonUnsupportedOperationError",
                                                 message: "Call to $methodName requires @$availableAnnotation.",
                                                 details: nil
                                                )))
                  }
                } else {
                  $varChannelName.setMessageHandler(nil)
                }''');
            });
          } else {
            onWrite();
          }

          if (unsupportedPlatforms != null) {
            indent.writeln('#endif');
          }
        }

        for (final Constructor constructor in api.constructors) {
          final String name = constructor.name.isNotEmpty
              ? constructor.name
              : 'pigeonDefaultConstructor';
          final String channelName = makeChannelNameWithStrings(
            apiName: api.name,
            methodName: constructor.name.isNotEmpty
                ? constructor.name
                : '${classMemberNamePrefix}defaultConstructor',
            dartPackageName: dartPackageName,
          );
          writeWithApiCheckIfNecessary(
            <TypeDeclaration>[
              apiAsTypeDeclaration,
              ...api.unattachedFields.map((ApiField f) => f.type),
              ...constructor.parameters.map((Parameter p) => p.type),
            ],
            methodName: name,
            channelName: channelName,
            onWrite: () {
              _writeHostMethodMessageHandler(
                indent,
                name: name,
                channelName: channelName,
                returnType: const TypeDeclaration.voidDeclaration(),
                swiftFunction: null,
                isAsynchronous: false,
                onCreateCall:
                    (
                      List<String> methodParameters, {
                      required String apiVarName,
                    }) {
                      final List<String> parameters = <String>[
                        'pigeonApi: $apiVarName',
                        // Skip the identifier used by the InstanceManager.
                        ...methodParameters.skip(1),
                      ];
                      return '$apiVarName.pigeonRegistrar.instanceManager.addDartCreatedInstance(\n'
                          'try $apiVarName.pigeonDelegate.$name(${parameters.join(', ')}),\n'
                          'withIdentifier: pigeonIdentifierArg)';
                    },
                parameters: <Parameter>[
                  Parameter(
                    name: 'pigeonIdentifier',
                    type: const TypeDeclaration(
                      baseName: 'int',
                      isNullable: false,
                    ),
                  ),
                  ...api.unattachedFields.map((ApiField field) {
                    return Parameter(name: field.name, type: field.type);
                  }),
                  ...constructor.parameters,
                ],
              );
            },
          );
        }

        for (final ApiField field in api.attachedFields) {
          final String channelName = makeChannelNameWithStrings(
            apiName: api.name,
            methodName: field.name,
            dartPackageName: dartPackageName,
          );
          writeWithApiCheckIfNecessary(
            <TypeDeclaration>[apiAsTypeDeclaration, field.type],
            methodName: field.name,
            channelName: channelName,
            onWrite: () {
              _writeHostMethodMessageHandler(
                indent,
                name: field.name,
                channelName: channelName,
                swiftFunction: null,
                isAsynchronous: false,
                returnType: const TypeDeclaration.voidDeclaration(),
                onCreateCall:
                    (
                      List<String> methodParameters, {
                      required String apiVarName,
                    }) {
                      final String instanceArg = field.isStatic
                          ? ''
                          : ', pigeonInstance: pigeonInstanceArg';
                      return '$apiVarName.pigeonRegistrar.instanceManager.addDartCreatedInstance('
                          'try $apiVarName.pigeonDelegate.${field.name}(pigeonApi: api$instanceArg), '
                          'withIdentifier: pigeonIdentifierArg)';
                    },
                parameters: <Parameter>[
                  if (!field.isStatic)
                    Parameter(
                      name: 'pigeonInstance',
                      type: apiAsTypeDeclaration,
                    ),
                  Parameter(
                    name: 'pigeonIdentifier',
                    type: const TypeDeclaration(
                      baseName: 'int',
                      isNullable: false,
                    ),
                  ),
                ],
              );
            },
          );
        }

        for (final Method method in api.hostMethods) {
          final String channelName = makeChannelName(
            api,
            method,
            dartPackageName,
          );
          writeWithApiCheckIfNecessary(
            <TypeDeclaration>[
              apiAsTypeDeclaration,
              method.returnType,
              ...method.parameters.map((Parameter parameter) => parameter.type),
            ],
            methodName: method.name,
            channelName: channelName,
            onWrite: () {
              _writeHostMethodMessageHandler(
                indent,
                name: method.name,
                channelName: makeChannelName(api, method, dartPackageName),
                returnType: method.returnType,
                isAsynchronous: method.isAsynchronous,
                swiftFunction: null,
                onCreateCall:
                    (
                      List<String> methodParameters, {
                      required String apiVarName,
                    }) {
                      final String tryStatement = method.isAsynchronous
                          ? ''
                          : 'try ';
                      final List<String> parameters = <String>[
                        'pigeonApi: $apiVarName',
                        // Skip the identifier used by the InstanceManager.
                        ...methodParameters,
                      ];

                      return '$tryStatement$apiVarName.pigeonDelegate.${method.name}(${parameters.join(', ')})';
                    },
                parameters: <Parameter>[
                  if (!method.isStatic)
                    Parameter(
                      name: 'pigeonInstance',
                      type: apiAsTypeDeclaration,
                    ),
                  ...method.parameters,
                ],
              );
            },
          );
        }
      },
    );
  }

  // Writes the method that calls to Dart to instantiate a new Dart instance.
  void _writeProxyApiNewInstanceMethod(
    Indent indent,
    AstProxyApi api, {
    required InternalSwiftOptions generatorOptions,
    required TypeDeclaration apiAsTypeDeclaration,
    required String newInstanceMethodName,
    required String dartPackageName,
  }) {
    final List<TypeDeclaration> allReferencedTypes = <TypeDeclaration>[
      apiAsTypeDeclaration,
      ...api.unattachedFields.map((ApiField field) => field.type),
    ];

    final String? unsupportedPlatforms = _tryGetUnsupportedPlatformsCondition(
      allReferencedTypes,
    );
    if (unsupportedPlatforms != null) {
      indent.writeln('#if $unsupportedPlatforms');
    }

    addDocumentationComments(indent, <String>[
      'Creates a Dart instance of ${api.name} and attaches it to [pigeonInstance].',
    ], _docCommentSpec);

    final String? availableAnnotation = _tryGetAvailabilityAnnotation(
      allReferencedTypes,
    );
    if (availableAnnotation != null) {
      indent.writeln('@$availableAnnotation');
    }

    final String methodSignature = _getMethodSignature(
      name: 'pigeonNewInstance',
      parameters: <Parameter>[
        Parameter(name: 'pigeonInstance', type: apiAsTypeDeclaration),
      ],
      returnType: const TypeDeclaration.voidDeclaration(),
      isAsynchronous: true,
      errorTypeName: _getErrorClassName(generatorOptions),
    );
    indent.writeScoped('$methodSignature {', '}', () {
      indent.writeScoped('if pigeonRegistrar.ignoreCallsToDart {', '}', () {
        indent.format(
          '''
            completion(
              .failure(
                ${_getErrorClassName(generatorOptions)}(
                  code: "ignore-calls-error",
                  message: "Calls to Dart are being ignored.", details: "")))''',
        );
      }, addTrailingNewline: false);

      indent.writeScoped(
        ' else if pigeonRegistrar.instanceManager.containsInstance(pigeonInstance as AnyObject) {',
        '}',
        () {
          indent.writeln('completion(.success(()))');
        },
        addTrailingNewline: false,
      );
      indent.writeScoped(' else {', '}', () {
        if (api.hasCallbackConstructor()) {
          indent.writeln(
            'let pigeonIdentifierArg = pigeonRegistrar.instanceManager.addHostCreatedInstance(pigeonInstance as AnyObject)',
          );
          enumerate(api.unattachedFields, (int index, ApiField field) {
            final String argName = _getSafeArgumentName(index, field);
            indent.writeln(
              'let $argName = try! pigeonDelegate.${field.name}(pigeonApi: self, pigeonInstance: pigeonInstance)',
            );
          });
          indent.writeln(
            'let binaryMessenger = pigeonRegistrar.binaryMessenger',
          );
          indent.writeln('let codec = pigeonRegistrar.codec');
          _writeFlutterMethodMessageCall(
            indent,
            generatorOptions: generatorOptions,
            parameters: <Parameter>[
              Parameter(
                name: 'pigeonIdentifier',
                type: const TypeDeclaration(baseName: 'int', isNullable: false),
              ),
              ...api.unattachedFields.map((ApiField field) {
                return Parameter(name: field.name, type: field.type);
              }),
            ],
            returnType: const TypeDeclaration.voidDeclaration(),
            channelName: makeChannelNameWithStrings(
              apiName: api.name,
              methodName: newInstanceMethodName,
              dartPackageName: dartPackageName,
            ),
          );
        } else {
          indent.format(
            '''
            completion(
              .failure(
                ${_getErrorClassName(generatorOptions)}(
                  code: "new-instance-error",
                  message: "Error: Attempting to create a new Dart instance of ${api.name}, but the class has a nonnull callback method.", details: "")))''',
          );
        }
      });
    });

    if (unsupportedPlatforms != null) {
      indent.writeln('#endif');
    }
  }

  // Writes the Flutter methods that call back to Dart.
  void _writeProxyApiFlutterMethods(
    Indent indent,
    AstProxyApi api, {
    required InternalSwiftOptions generatorOptions,
    required TypeDeclaration apiAsTypeDeclaration,
    required String dartPackageName,
    bool writeBody = true,
  }) {
    for (final Method method in api.flutterMethods) {
      final List<TypeDeclaration> allReferencedTypes = <TypeDeclaration>[
        apiAsTypeDeclaration,
        ...method.parameters.map((Parameter parameter) => parameter.type),
        method.returnType,
      ];

      final String? unsupportedPlatforms = _tryGetUnsupportedPlatformsCondition(
        allReferencedTypes,
      );
      if (unsupportedPlatforms != null) {
        indent.writeln('#if $unsupportedPlatforms');
      }

      addDocumentationComments(
        indent,
        method.documentationComments,
        _docCommentSpec,
      );

      final String? availableAnnotation = _tryGetAvailabilityAnnotation(
        allReferencedTypes,
      );
      if (availableAnnotation != null) {
        indent.writeln('@$availableAnnotation');
      }

      final String methodSignature = _getMethodSignature(
        name: method.name,
        parameters: <Parameter>[
          Parameter(name: 'pigeonInstance', type: apiAsTypeDeclaration),
          ...method.parameters,
        ],
        returnType: method.returnType,
        isAsynchronous: true,
        errorTypeName: _getErrorClassName(generatorOptions),
        getParameterName: _getSafeArgumentName,
      );

      indent.write(methodSignature);
      if (writeBody) {
        indent.writeScoped(' {', '}', () {
          indent.writeScoped('if pigeonRegistrar.ignoreCallsToDart {', '}', () {
            indent.format('''
                completion(
                  .failure(
                    ${_getErrorClassName(generatorOptions)}(
                      code: "ignore-calls-error",
                      message: "Calls to Dart are being ignored.", details: "")))
                return''');
          });
          indent.writeln(
            'let binaryMessenger = pigeonRegistrar.binaryMessenger',
          );
          indent.writeln('let codec = pigeonRegistrar.codec');

          _writeFlutterMethodMessageCall(
            indent,
            generatorOptions: generatorOptions,
            parameters: <Parameter>[
              Parameter(name: 'pigeonInstance', type: apiAsTypeDeclaration),
              ...method.parameters,
            ],
            returnType: method.returnType,
            channelName: makeChannelName(api, method, dartPackageName),
          );
        });
      }
      if (unsupportedPlatforms != null) {
        indent.writeln('#endif');
      }
      indent.newln();
    }
  }

  void _writePigeonError(InternalSwiftOptions generatorOptions, Indent indent) {
    indent.newln();
    indent.writeln(
      '/// Error class for passing custom error details to Dart side.',
    );
    indent.writeScoped(
      'final class ${_getErrorClassName(generatorOptions)}: Error {',
      '}',
      () {
        indent.writeln('let code: String');
        indent.writeln('let message: String?');
        indent.writeln('let details: Sendable?');
        indent.newln();
        indent.writeScoped(
          'init(code: String, message: String?, details: Sendable?) {',
          '}',
          () {
            indent.writeln('self.code = code');
            indent.writeln('self.message = message');
            indent.writeln('self.details = details');
          },
        );
        indent.newln();
        indent.writeScoped('var localizedDescription: String {', '}', () {
          indent.writeScoped('return', '', () {
            indent.writeln(
              '"${_getErrorClassName(generatorOptions)}(code: \\(code), message: \\(message ?? "<nil>"), details: \\(details ?? "<nil>")"',
            );
          }, addTrailingNewline: false);
        });
      },
    );
  }

  void _writeProxyApiImports(Indent indent, Iterable<AstProxyApi> apis) {
    final Map<String, List<AstProxyApi>> apisOfImports =
        <String, List<AstProxyApi>>{};
    for (final AstProxyApi proxyApi in apis) {
      final String? import = proxyApi.swiftOptions?.import;
      if (import != null) {
        if (apisOfImports.containsKey(import)) {
          apisOfImports[import]!.add(proxyApi);
        } else {
          apisOfImports[import] = <AstProxyApi>[proxyApi];
        }
      }
    }

    for (final String import in apisOfImports.keys) {
      // If every ProxyApi that shares an import excludes a platform for
      // support, surround the import with `#if !os(...) #endif`.
      final List<String> unsupportedPlatforms = <String>[
        if (!apisOfImports[import]!.any(
          (AstProxyApi api) => api.swiftOptions?.supportsIos ?? true,
        ))
          '!os(iOS)',
        if (!apisOfImports[import]!.any(
          (AstProxyApi api) => api.swiftOptions?.supportsMacos ?? true,
        ))
          '!os(macOS)',
      ];

      if (unsupportedPlatforms.isNotEmpty) {
        indent.writeln('#if ${unsupportedPlatforms.join(' || ')}');
      }
      indent.writeln('import $import');
      if (unsupportedPlatforms.isNotEmpty) {
        indent.writeln('#endif');
      }
    }
  }
}

typedef _VersionRequirement = ({TypeDeclaration type, Version version});
({_VersionRequirement? ios, _VersionRequirement? macos})
_findHighestVersionRequirement(Iterable<TypeDeclaration> types) {
  final _VersionRequirement? iosApiRequirement =
      findHighestApiRequirement<Version>(
        types,
        onGetApiRequirement: (TypeDeclaration type) {
          final String? apiRequirement =
              type.associatedProxyApi?.swiftOptions?.minIosApi;
          if (apiRequirement != null) {
            return Version.parse(apiRequirement);
          }

          return null;
        },
        onCompare: (Version one, Version two) => one.compareTo(two),
      );

  final _VersionRequirement? macosApiRequirement =
      findHighestApiRequirement<Version>(
        types,
        onGetApiRequirement: (TypeDeclaration type) {
          final String? apiRequirement =
              type.associatedProxyApi?.swiftOptions?.minMacosApi;
          if (apiRequirement != null) {
            return Version.parse(apiRequirement);
          }

          return null;
        },
        onCompare: (Version one, Version two) => one.compareTo(two),
      );

  return (ios: iosApiRequirement, macos: macosApiRequirement);
}

/// Finds the highest api requirement for each supported platform and creates
/// the `available(platform version , platform version ..., *)` annotation.
///
/// Returns `null` if there is not api requirement in [types].
String? _tryGetAvailabilityAnnotation(Iterable<TypeDeclaration> types) {
  final ({_VersionRequirement? ios, _VersionRequirement? macos})
  versionRequirement = _findHighestVersionRequirement(types);

  final List<String> apis = <String>[
    if (versionRequirement.ios != null)
      'iOS ${versionRequirement.ios!.version}',
    if (versionRequirement.macos != null)
      'macOS ${versionRequirement.macos!.version}',
  ];

  return apis.isNotEmpty ? 'available(${apis.join(', ')}, *)' : null;
}

/// Creates the string used to indicate a platform is unsupported.
///
/// Recursively iterates through all types to find any that are not supported
/// by a platform.
///
/// Returns `null` if every type supports all platforms.
String? _tryGetUnsupportedPlatformsCondition(Iterable<TypeDeclaration> types) {
  Iterable<TypeDeclaration> addAllRecursive(TypeDeclaration type) sync* {
    yield type;
    if (type.typeArguments.isNotEmpty) {
      for (final TypeDeclaration typeArg in type.typeArguments) {
        yield* addAllRecursive(typeArg);
      }
    }
  }

  final Iterable<TypeDeclaration> allReferencedTypes = types.expand(
    addAllRecursive,
  );

  final List<String> unsupportedPlatforms = <String>[
    if (!allReferencedTypes.every((TypeDeclaration type) {
      return type.associatedProxyApi?.swiftOptions?.supportsIos ?? true;
    }))
      '!os(iOS)',
    if (!allReferencedTypes.every((TypeDeclaration type) {
      return type.associatedProxyApi?.swiftOptions?.supportsMacos ?? true;
    }))
      '!os(macOS)',
  ];

  return unsupportedPlatforms.isNotEmpty
      ? unsupportedPlatforms.join(' || ')
      : null;
}

/// Calculates the name of the codec that will be generated for [api].
String _getMessageCodecName(InternalSwiftOptions options) {
  return toUpperCamelCase(
    '${options.fileSpecificClassNameComponent}PigeonCodec',
  );
}

/// Calculates the name of the codec that will be generated for [api].
String _getMethodCodecVarName(InternalSwiftOptions options) {
  return '${toLowerCamelCase(options.fileSpecificClassNameComponent ?? '')}PigeonMethodCodec';
}

String _getErrorClassName(InternalSwiftOptions generatorOptions) {
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
  if (type.typeArguments.isEmpty) {
    if (type.baseName == 'List') {
      return '[Any?]';
    } else if (type.baseName == 'Map') {
      return '[AnyHashable?: Any?]';
    } else {
      return 'Any';
    }
  } else {
    if (type.baseName == 'List') {
      return '[${_nullSafeSwiftTypeForDartType(type.typeArguments.first)}]';
    } else if (type.baseName == 'Map') {
      return '[${_nullSafeSwiftTypeForDartType(type.typeArguments.first, mapKey: true)}: ${_nullSafeSwiftTypeForDartType(type.typeArguments.last)}]';
    } else {
      return '${type.baseName}<${_flattenTypeArguments(type.typeArguments)}>';
    }
  }
}

String? _swiftTypeForBuiltinDartType(
  TypeDeclaration type, {
  bool mapKey = false,
}) {
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
  if (mapKey && type.baseName == 'Object') {
    return 'AnyHashable';
  } else if (swiftTypeForDartTypeMap.containsKey(type.baseName)) {
    return swiftTypeForDartTypeMap[type.baseName];
  } else if (type.baseName == 'List' || type.baseName == 'Map') {
    return _swiftTypeForBuiltinGenericDartType(type);
  } else {
    return null;
  }
}

String? _swiftTypeForProxyApiType(TypeDeclaration type) {
  if (type.isProxyApi) {
    return type.associatedProxyApi!.swiftOptions?.name ??
        type.associatedProxyApi!.name;
  }

  return null;
}

String _swiftTypeForDartType(TypeDeclaration type, {bool mapKey = false}) {
  return _swiftTypeForBuiltinDartType(type, mapKey: mapKey) ??
      _swiftTypeForProxyApiType(type) ??
      type.baseName;
}

String _nullSafeSwiftTypeForDartType(
  TypeDeclaration type, {
  bool mapKey = false,
}) {
  final String nullSafe = type.isNullable ? '?' : '';
  return '${_swiftTypeForDartType(type, mapKey: mapKey)}$nullSafe';
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
  final String returnTypeString = returnType.isVoid
      ? 'Void'
      : _nullSafeSwiftTypeForDartType(returnType);

  final Iterable<String> types = parameters.map(
    (NamedType e) => _nullSafeSwiftTypeForDartType(e.type),
  );
  final Iterable<String> labels = indexMap(components.arguments, (
    int index,
    _SwiftFunctionArgument argument,
  ) {
    return argument.label ?? _getArgumentName(index, argument.namedType);
  });
  final Iterable<String> names = indexMap(parameters, getParameterName);
  final String parameterSignature = map3(types, labels, names, (
    String type,
    String label,
    String name,
  ) {
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
            .map(
              (NamedType field) => _SwiftFunctionArgument(
                name: field.name,
                type: field.type,
                namedType: field,
              ),
            )
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

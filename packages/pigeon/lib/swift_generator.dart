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

/// Options that control how Swift code will be generated.
class SwiftOptions {
  /// Creates a [SwiftOptions] object
  const SwiftOptions({
    this.copyrightHeader,
  });

  /// A copyright header that will get prepended to generated code.
  final Iterable<String>? copyrightHeader;

  /// Creates a [SwiftOptions] from a Map representation where:
  /// `x = SwiftOptions.fromList(x.toMap())`.
  static SwiftOptions fromList(Map<String, Object> map) {
    return SwiftOptions(
      copyrightHeader: map['copyrightHeader'] as Iterable<String>?,
    );
  }

  /// Converts a [SwiftOptions] to a Map representation where:
  /// `x = SwiftOptions.fromList(x.toMap())`.
  Map<String, Object> toMap() {
    final Map<String, Object> result = <String, Object>{
      if (copyrightHeader != null) 'copyrightHeader': copyrightHeader!,
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

    indent.write('struct ${classDefinition.name} ');
    indent.addScoped('{', '}', () {
      getFieldsInSerializationOrder(classDefinition).forEach((NamedType field) {
        _writeClassField(indent, field);
      });

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
          String toWriteValue = '';
          final String fieldName = field.name;
          final String nullsafe = field.type.isNullable ? '?' : '';
          if (field.type.isClass) {
            toWriteValue = '$fieldName$nullsafe.toList()';
          } else if (field.type.isEnum) {
            toWriteValue = '$fieldName$nullsafe.rawValue';
          } else {
            toWriteValue = field.name;
          }

          indent.writeln('$toWriteValue$separator');
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
    indent.write('static func fromList(_ list: [Any?]) -> $className? ');

    indent.addScoped('{', '}', () {
      enumerate(getFieldsInSerializationOrder(classDefinition),
          (int index, final NamedType field) {
        final String listValue = 'list[$index]';

        _writeDecodeCasting(
          indent: indent,
          value: listValue,
          variableName: field.name,
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

  void _writeClassField(Indent indent, NamedType field) {
    addDocumentationComments(
        indent, field.documentationComments, _docCommentSpec);

    indent.write(
        'var ${field.name}: ${_nullsafeSwiftTypeForDartType(field.type)}');
    final String defaultNil = field.type.isNullable ? ' = nil' : '';
    indent.addln(defaultNil);
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
    final bool isCustomCodec = getCodecClasses(api, root).isNotEmpty;
    if (isCustomCodec) {
      _writeCodec(indent, api, root);
    }

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
          errorTypeName: 'FlutterError',
          isAsynchronous: true,
          swiftFunction: func.swiftFunction,
          getParameterName: _getSafeArgumentName,
        ));
      }
    });

    indent.write('class ${api.name}: ${api.name}Protocol ');
    indent.addScoped('{', '}', () {
      indent.writeln('private let binaryMessenger: FlutterBinaryMessenger');
      indent.write('init(binaryMessenger: FlutterBinaryMessenger) ');
      indent.addScoped('{', '}', () {
        indent.writeln('self.binaryMessenger = binaryMessenger');
      });
      final String codecName = _getCodecName(api);
      String codecArgumentString = '';
      if (getCodecClasses(api, root).isNotEmpty) {
        codecArgumentString = ', codec: codec';
        indent.write('var codec: FlutterStandardMessageCodec ');
        indent.addScoped('{', '}', () {
          indent.writeln('return $codecName.shared');
        });
      }

      for (final Method func in api.methods) {
        addDocumentationComments(
            indent, func.documentationComments, _docCommentSpec);
        _writeFlutterMethod(
          indent,
          name: func.name,
          channelName: makeChannelName(api, func, dartPackageName),
          parameters: func.parameters,
          returnType: func.returnType,
          codecArgumentString: codecArgumentString,
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

    final bool isCustomCodec = getCodecClasses(api, root).isNotEmpty;
    if (isCustomCodec) {
      _writeCodec(indent, api, root);
    }
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
      final String codecName = _getCodecName(api);
      indent.writeln('$_docCommentPrefix The codec used by $apiName.');
      String codecArgumentString = '';
      if (getCodecClasses(api, root).isNotEmpty) {
        codecArgumentString = ', codec: codec';
        indent.writeln(
            'static var codec: FlutterStandardMessageCodec { $codecName.shared }');
      }
      indent.writeln(
          '$_docCommentPrefix Sets up an instance of `$apiName` to handle messages through the `binaryMessenger`.');
      indent.write(
          'static func setUp(binaryMessenger: FlutterBinaryMessenger, api: $apiName?) ');
      indent.addScoped('{', '}', () {
        for (final Method method in api.methods) {
          _writeHostMethodMessageHandler(
            indent,
            name: method.name,
            channelName: makeChannelName(api, method, dartPackageName),
            parameters: method.parameters,
            returnType: method.returnType,
            isAsynchronous: method.isAsynchronous,
            codecArgumentString: codecArgumentString,
            swiftFunction: method.swiftFunction,
            documentationComments: method.documentationComments,
          );
        }
      });
    });
  }

  /// Writes the codec class will be used for encoding messages for the [api].
  /// Example:
  /// private class FooHostApiCodecReader: FlutterStandardReader {...}
  /// private class FooHostApiCodecWriter: FlutterStandardWriter {...}
  /// private class FooHostApiCodecReaderWriter: FlutterStandardReaderWriter {...}
  void _writeCodec(Indent indent, Api api, Root root) {
    assert(getCodecClasses(api, root).isNotEmpty);
    final String codecName = _getCodecName(api);
    final String readerWriterName = '${codecName}ReaderWriter';
    final String readerName = '${codecName}Reader';
    final String writerName = '${codecName}Writer';

    // Generate Reader
    indent.write('private class $readerName: FlutterStandardReader ');
    indent.addScoped('{', '}', () {
      if (getCodecClasses(api, root).isNotEmpty) {
        indent.write('override func readValue(ofType type: UInt8) -> Any? ');
        indent.addScoped('{', '}', () {
          indent.write('switch type ');
          indent.addScoped('{', '}', nestCount: 0, () {
            for (final EnumeratedClass customClass
                in getCodecClasses(api, root)) {
              indent.writeln('case ${customClass.enumeration}:');
              indent.nest(1, () {
                indent.writeln(
                    'return ${customClass.name}.fromList(self.readValue() as! [Any?])');
              });
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
      if (getCodecClasses(api, root).isNotEmpty) {
        indent.write('override func writeValue(_ value: Any) ');
        indent.addScoped('{', '}', () {
          indent.write('');
          for (final EnumeratedClass customClass
              in getCodecClasses(api, root)) {
            indent.add('if let value = value as? ${customClass.name} ');
            indent.addScoped('{', '} else ', () {
              indent.writeln('super.writeByte(${customClass.enumeration})');
              indent.writeln('super.writeValue(value.toList())');
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
    indent.write('class $codecName: FlutterStandardMessageCodec ');
    indent.addScoped('{', '}', () {
      indent.writeln(
          'static let shared = $codecName(readerWriter: $readerWriterName())');
    });
    indent.newln();
  }

  String _castForceUnwrap(String value, TypeDeclaration type) {
    assert(!type.isVoid);
    if (type.isEnum) {
      String output =
          '${_swiftTypeForDartType(type)}(rawValue: $value as! Int)!';
      if (type.isNullable) {
        output = 'isNullish($value) ? nil : $output';
      }
      return output;
    } else if (type.baseName == 'Object') {
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

  /// Writes decode and casting code for any type.
  ///
  /// Optional parameters should only be used for class decoding.
  void _writeDecodeCasting({
    required Indent indent,
    required String value,
    required String variableName,
    required TypeDeclaration type,
  }) {
    final String fieldType = _swiftTypeForDartType(type);

    if (type.isNullable) {
      if (type.isClass) {
        indent.writeln('var $variableName: $fieldType? = nil');
        indent
            .write('if let ${variableName}List: [Any?] = nilOrValue($value) ');
        indent.addScoped('{', '}', () {
          indent.writeln(
              '$variableName = $fieldType.fromList(${variableName}List)');
        });
      } else if (type.isEnum) {
        indent.writeln('var $variableName: $fieldType? = nil');
        indent.writeln(
            'let ${variableName}EnumVal: Int? = ${_castForceUnwrap(value, const TypeDeclaration(baseName: 'Int', isNullable: true))}');
        indent
            .write('if let ${variableName}RawValue = ${variableName}EnumVal ');
        indent.addScoped('{', '}', () {
          indent.writeln(
              '$variableName = $fieldType(rawValue: ${variableName}RawValue)!');
        });
      } else {
        _writeGenericCasting(
          indent: indent,
          value: value,
          variableName: variableName,
          fieldType: fieldType,
          type: type,
        );
      }
    } else {
      if (type.isClass) {
        indent.writeln(
            'let $variableName = $fieldType.fromList($value as! [Any?])!');
      } else {
        _writeGenericCasting(
          indent: indent,
          value: value,
          variableName: variableName,
          fieldType: fieldType,
          type: type,
        );
      }
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

  void _writeWrapError(Indent indent) {
    indent.newln();
    indent.write('private func wrapError(_ error: Any) -> [Any?] ');
    indent.addScoped('{', '}', () {
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

  void _writeCreateConnectionError(Indent indent) {
    indent.newln();
    indent.writeScoped(
        'private func createConnectionError(withChannelName channelName: String) -> FlutterError {',
        '}', () {
      indent.writeln(
          'return FlutterError(code: "channel-error", message: "Unable to establish connection on channel: \'\\(channelName)\'.", details: "")');
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

    if (hasHostApi) {
      _writeWrapResult(indent);
      _writeWrapError(indent);
    }
    if (hasFlutterApi) {
      _writeCreateConnectionError(indent);
    }
    _writeIsNullish(indent);
    _writeNilOrValue(indent);
  }

  void _writeFlutterMethod(
    Indent indent, {
    required String name,
    required String channelName,
    required List<Parameter> parameters,
    required TypeDeclaration returnType,
    required String codecArgumentString,
    required String? swiftFunction,
  }) {
    final String methodSignature = _getMethodSignature(
      name: name,
      parameters: parameters,
      returnType: returnType,
      errorTypeName: 'FlutterError',
      isAsynchronous: true,
      swiftFunction: swiftFunction,
      getParameterName: _getSafeArgumentName,
    );

    /// Returns an argument name that can be used in a context where it is possible to collide.
    String getEnumSafeArgumentExpression(int count, NamedType argument) {
      String enumTag = '';
      if (argument.type.isEnum) {
        enumTag = argument.type.isNullable ? '?.rawValue' : '.rawValue';
      }

      return '${_getArgumentName(count, argument)}Arg$enumTag';
    }

    indent.writeScoped('$methodSignature {', '}', () {
      final Iterable<String> enumSafeArgNames = parameters.asMap().entries.map(
          (MapEntry<int, NamedType> e) =>
              getEnumSafeArgumentExpression(e.key, e.value));
      final String sendArgument = parameters.isEmpty
          ? 'nil'
          : '[${enumSafeArgNames.join(', ')}] as [Any?]';
      const String channel = 'channel';
      indent.writeln('let channelName: String = "$channelName"');
      indent.writeln(
          'let $channel = FlutterBasicMessageChannel(name: channelName, binaryMessenger: binaryMessenger$codecArgumentString)');
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
              'completion(.failure(FlutterError(code: code, message: message, details: details)))');
        }, addTrailingNewline: false);
        if (!returnType.isNullable && !returnType.isVoid) {
          indent.addScoped('else if listResponse[0] == nil {', '} ', () {
            indent.writeln(
                'completion(.failure(FlutterError(code: "null-error", message: "Flutter api returned null value for non-null return value.", details: "")))');
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
    required String codecArgumentString,
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
        'let $varChannelName = FlutterBasicMessageChannel(name: "$channelName", binaryMessenger: binaryMessenger$codecArgumentString)');
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
              final String nullsafe = returnType.isNullable ? '?' : '';
              final String enumTag =
                  returnType.isEnum ? '$nullsafe.rawValue' : '';
              indent.writeln('case .success$successVariableInit:');
              indent.nest(1, () {
                indent.writeln('reply(wrapResult($resultName$enumTag))');
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
              String enumTag = '';
              if (returnType.isEnum) {
                enumTag = '.rawValue';
              }
              enumTag = returnType.isNullable && returnType.isEnum
                  ? '?$enumTag'
                  : enumTag;
              indent.writeln('let result = $call');
              indent.writeln('reply(wrapResult(result$enumTag))');
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
}

/// Calculates the name of the codec that will be generated for [api].
String _getCodecName(Api api) => '${api.name}Codec';

String _getArgumentName(int count, NamedType argument) =>
    argument.name.isEmpty ? 'arg$count' : argument.name;

/// Returns an argument name that can be used in a context where it is possible to collide.
String _getSafeArgumentName(int count, NamedType argument) =>
    '${_getArgumentName(count, argument)}Arg';

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

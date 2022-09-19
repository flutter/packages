// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'ast.dart';
import 'functional.dart';
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
  /// `x = SwiftOptions.fromMap(x.toMap())`.
  static SwiftOptions fromMap(Map<String, Object> map) {
    return SwiftOptions(
      copyrightHeader: map['copyrightHeader'] as Iterable<String>?,
    );
  }

  /// Converts a [SwiftOptions] to a Map representation where:
  /// `x = SwiftOptions.fromMap(x.toMap())`.
  Map<String, Object> toMap() {
    final Map<String, Object> result = <String, Object>{
      if (copyrightHeader != null) 'copyrightHeader': copyrightHeader!,
    };
    return result;
  }

  /// Overrides any non-null parameters from [options] into this to make a new
  /// [SwiftOptions].
  SwiftOptions merge(SwiftOptions options) {
    return SwiftOptions.fromMap(mergeMaps(toMap(), options.toMap()));
  }
}

/// Calculates the name of the codec that will be generated for [api].
String _getCodecName(Api api) => '${api.name}Codec';

/// Writes the codec classwill be used for encoding messages for the [api].
/// Example:
/// private class FooHostApiCodecReader: FlutterStandardReader {...}
/// private class FooHostApiCodecWriter: FlutterStandardWriter {...}
/// private class FooHostApiCodecReaderWriter: FlutterStandardReaderWriter {...}
void _writeCodec(Indent indent, Api api, Root root) {
  final String codecName = _getCodecName(api);
  final String readerWriterName = '${codecName}ReaderWriter';
  final String readerName = '${codecName}Reader';
  final String writerName = '${codecName}Writer';

  // Generate Reader
  indent.write('private class $readerName: FlutterStandardReader ');
  indent.scoped('{', '}', () {
    if (getCodecClasses(api, root).isNotEmpty) {
      indent.write('override func readValue(ofType type: UInt8) -> Any? ');
      indent.scoped('{', '}', () {
        indent.write('switch type ');
        indent.scoped('{', '}', () {
          for (final EnumeratedClass customClass
              in getCodecClasses(api, root)) {
            indent.write('case ${customClass.enumeration}:');
            indent.scoped('', '', () {
              indent.write(
                  'return ${customClass.name}.fromMap(self.readValue() as! [String: Any])');
            });
          }
          indent.write('default:');
          indent.scoped('', '', () {
            indent.writeln('return super.readValue(ofType: type)');
          });
        });
      });
    }
  });

  // Generate Writer
  indent.write('private class $writerName: FlutterStandardWriter ');
  indent.scoped('{', '}', () {
    if (getCodecClasses(api, root).isNotEmpty) {
      indent.write('override func writeValue(_ value: Any) ');
      indent.scoped('{', '}', () {
        indent.write('');
        for (final EnumeratedClass customClass in getCodecClasses(api, root)) {
          indent.add('if let value = value as? ${customClass.name} ');
          indent.scoped('{', '} else ', () {
            indent.writeln('super.writeByte(${customClass.enumeration})');
            indent.writeln('super.writeValue(value.toMap())');
          }, addTrailingNewline: false);
        }
        indent.scoped('{', '}', () {
          indent.writeln('super.writeValue(value)');
        });
      });
    }
  });
  indent.writeln('');

  // Generate ReaderWriter
  indent.write('private class $readerWriterName: FlutterStandardReaderWriter ');
  indent.scoped('{', '}', () {
    indent.write(
        'override func reader(with data: Data) -> FlutterStandardReader ');
    indent.scoped('{', '}', () {
      indent.writeln('return $readerName(data: data)');
    });
    indent.writeln('');
    indent.write(
        'override func writer(with data: NSMutableData) -> FlutterStandardWriter ');
    indent.scoped('{', '}', () {
      indent.writeln('return $writerName(data: data)');
    });
  });
  indent.writeln('');

  // Generate Codec
  indent.write('class $codecName: FlutterStandardMessageCodec ');
  indent.scoped('{', '}', () {
    indent.writeln(
        'static let shared = $codecName(readerWriter: $readerWriterName())');
  });
}

/// Write the swift code that represents a host [Api], [api].
/// Example:
/// protocol Foo {
///   Int32 add(x: Int32, y: Int32)
/// }
void _writeHostApi(Indent indent, Api api, Root root) {
  assert(api.location == ApiLocation.host);

  final String apiName = api.name;

  const List<String> generatedComments = <String>[
    'Generated protocol from Pigeon that represents a handler of messages from Flutter.'
  ];
  addDocumentationComments(indent, api.documentationComments, _docCommentSpec,
      generatorComments: generatedComments);

  indent.write('protocol $apiName ');
  indent.scoped('{', '}', () {
    for (final Method method in api.methods) {
      final List<String> argSignature = <String>[];
      if (method.arguments.isNotEmpty) {
        final Iterable<String> argTypes = method.arguments
            .map((NamedType e) => _nullsafeSwiftTypeForDartType(e.type));
        final Iterable<String> argNames =
            method.arguments.map((NamedType e) => e.name);
        argSignature
            .addAll(map2(argTypes, argNames, (String argType, String argName) {
          return '$argName: $argType';
        }));
      }

      final String returnType = method.returnType.isVoid
          ? ''
          : _nullsafeSwiftTypeForDartType(method.returnType);
      addDocumentationComments(
          indent, method.documentationComments, _docCommentSpec);

      if (method.isAsynchronous) {
        argSignature.add('completion: @escaping ($returnType) -> Void');
        indent.writeln('func ${method.name}(${argSignature.join(', ')})');
      } else if (method.returnType.isVoid) {
        indent.writeln('func ${method.name}(${argSignature.join(', ')})');
      } else {
        indent.writeln(
            'func ${method.name}(${argSignature.join(', ')}) -> $returnType');
      }
    }
  });

  indent.addln('');
  indent.writeln(
      '$_docCommentPrefix Generated setup class from Pigeon to handle messages through the `binaryMessenger`.');
  indent.write('class ${apiName}Setup ');
  indent.scoped('{', '}', () {
    final String codecName = _getCodecName(api);
    indent.writeln('$_docCommentPrefix The codec used by $apiName.');
    indent.writeln(
        'static var codec: FlutterStandardMessageCodec { $codecName.shared }');
    indent.writeln(
        '$_docCommentPrefix Sets up an instance of `$apiName` to handle messages through the `binaryMessenger`.');
    indent.write(
        'static func setUp(binaryMessenger: FlutterBinaryMessenger, api: $apiName?) ');
    indent.scoped('{', '}', () {
      for (final Method method in api.methods) {
        final String channelName = makeChannelName(api, method);
        final String varChannelName = '${method.name}Channel';
        addDocumentationComments(
            indent, method.documentationComments, _docCommentSpec);

        indent.writeln(
            'let $varChannelName = FlutterBasicMessageChannel(name: "$channelName", binaryMessenger: binaryMessenger, codec: codec)');
        indent.write('if let api = api ');
        indent.scoped('{', '}', () {
          indent.write('$varChannelName.setMessageHandler ');
          final String messageVarName =
              method.arguments.isNotEmpty ? 'message' : '_';
          indent.scoped('{ $messageVarName, reply in', '}', () {
            final List<String> methodArgument = <String>[];
            if (method.arguments.isNotEmpty) {
              indent.writeln('let args = message as! [Any?]');
              enumerate(method.arguments, (int index, NamedType arg) {
                final String argName = _getSafeArgumentName(index, arg);
                final String argIndex = 'args[$index]';
                indent.writeln(
                    'let $argName = ${_castForceUnwrap(argIndex, arg.type, root)}');
                methodArgument.add('${arg.name}: $argName');
              });
            }
            final String call =
                'api.${method.name}(${methodArgument.join(', ')})';
            if (method.isAsynchronous) {
              indent.write('$call ');
              if (method.returnType.isVoid) {
                indent.scoped('{', '}', () {
                  indent.writeln('reply(nil)');
                });
              } else {
                indent.scoped('{ result in', '}', () {
                  indent.writeln('reply(wrapResult(result))');
                });
              }
            } else {
              if (method.returnType.isVoid) {
                indent.writeln(call);
                indent.writeln('reply(nil)');
              } else {
                indent.writeln('let result = $call');
                indent.writeln('reply(wrapResult(result))');
              }
            }
          });
        }, addTrailingNewline: false);
        indent.scoped(' else {', '}', () {
          indent.writeln('$varChannelName.setMessageHandler(nil)');
        });
      }
    });
  });
}

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

/// Writes the code for a flutter [Api], [api].
/// Example:
/// class Foo {
///   private let binaryMessenger: FlutterBinaryMessenger
///   init(binaryMessenger: FlutterBinaryMessenger) {...}
///   func add(x: Int32, y: Int32, completion: @escaping (Int32?) -> Void) {...}
/// }
void _writeFlutterApi(Indent indent, Api api, Root root) {
  assert(api.location == ApiLocation.flutter);
  const List<String> generatedComments = <String>[
    'Generated class from Pigeon that represents Flutter messages that can be called from Swift.'
  ];
  addDocumentationComments(indent, api.documentationComments, _docCommentSpec,
      generatorComments: generatedComments);

  indent.write('class ${api.name} ');
  indent.scoped('{', '}', () {
    indent.writeln('private let binaryMessenger: FlutterBinaryMessenger');
    indent.write('init(binaryMessenger: FlutterBinaryMessenger)');
    indent.scoped('{', '}', () {
      indent.writeln('self.binaryMessenger = binaryMessenger');
    });
    final String codecName = _getCodecName(api);
    indent.write('var codec: FlutterStandardMessageCodec ');
    indent.scoped('{', '}', () {
      indent.writeln('return $codecName.shared');
    });
    for (final Method func in api.methods) {
      final String channelName = makeChannelName(api, func);
      final String returnType = func.returnType.isVoid
          ? ''
          : _nullsafeSwiftTypeForDartType(func.returnType);
      String sendArgument;
      addDocumentationComments(
          indent, func.documentationComments, _docCommentSpec);

      if (func.arguments.isEmpty) {
        indent.write(
            'func ${func.name}(completion: @escaping ($returnType) -> Void) ');
        sendArgument = 'nil';
      } else {
        final Iterable<String> argTypes = func.arguments
            .map((NamedType e) => _nullsafeSwiftTypeForDartType(e.type));
        final Iterable<String> argLabels =
            indexMap(func.arguments, _getArgumentName);
        final Iterable<String> argNames =
            indexMap(func.arguments, _getSafeArgumentName);
        sendArgument = '[${argNames.join(', ')}]';
        final String argsSignature = map3(
            argTypes,
            argLabels,
            argNames,
            (String type, String label, String name) =>
                '$label $name: $type').join(', ');
        if (func.returnType.isVoid) {
          indent.write(
              'func ${func.name}($argsSignature, completion: @escaping () -> Void) ');
        } else {
          indent.write(
              'func ${func.name}($argsSignature, completion: @escaping ($returnType) -> Void) ');
        }
      }
      indent.scoped('{', '}', () {
        const String channel = 'channel';
        indent.writeln(
            'let $channel = FlutterBasicMessageChannel(name: "$channelName", binaryMessenger: binaryMessenger, codec: codec)');
        indent.write('$channel.sendMessage($sendArgument) ');
        if (func.returnType.isVoid) {
          indent.scoped('{ _ in', '}', () {
            indent.writeln('completion()');
          });
        } else {
          indent.scoped('{ response in', '}', () {
            indent.writeln(
                'let result = ${_castForceUnwrap("response", func.returnType, root)}');
            indent.writeln('completion(result)');
          });
        }
      });
    }
  });
}

String _castForceUnwrap(String value, TypeDeclaration type, Root root) {
  if (isEnum(root, type)) {
    final String forceUnwrap = type.isNullable ? '' : '!';
    final String nullableConditionPrefix =
        type.isNullable ? '$value == nil ? nil : ' : '';
    return '$nullableConditionPrefix${_swiftTypeForDartType(type)}(rawValue: $value as! Int)$forceUnwrap';
  } else {
    final String castUnwrap = type.isNullable ? '?' : '!';
    return '$value as$castUnwrap ${_swiftTypeForDartType(type)}';
  }
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
    'int': 'Int32',
    'double': 'Double',
    'Uint8List': '[UInt8]',
    'Int32List': '[Int32]',
    'Int64List': '[Int64]',
    'Float32List': '[Float32]',
    'Float64List': '[Float64]',
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

/// Generates the ".swift" file for the AST represented by [root] to [sink] with the
/// provided [options].
void generateSwift(SwiftOptions options, Root root, StringSink sink) {
  final Set<String> rootClassNameSet =
      root.classes.map((Class x) => x.name).toSet();
  final Set<String> rootEnumNameSet =
      root.enums.map((Enum x) => x.name).toSet();
  final Indent indent = Indent(sink);

  HostDatatype getHostDatatype(NamedType field) {
    return getFieldHostDatatype(field, root.classes, root.enums,
        (TypeDeclaration x) => _swiftTypeForBuiltinDartType(x));
  }

  void writeHeader() {
    if (options.copyrightHeader != null) {
      addLines(indent, options.copyrightHeader!, linePrefix: '// ');
    }
    indent.writeln('// $generatedCodeWarning');
    indent.writeln('// $seeAlsoWarning');
  }

  void writeImports() {
    indent.writeln('import Foundation');
    indent.format('''
#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#else
#error("Unsupported platform.")
#endif
''');
  }

  void writeEnum(Enum anEnum) {
    addDocumentationComments(
        indent, anEnum.documentationComments, _docCommentSpec);

    indent.write('enum ${anEnum.name}: Int ');
    indent.scoped('{', '}', () {
      // We use explicit indexing here as use of the ordinal() method is
      // discouraged. The toMap and fromMap API matches class API to allow
      // the same code to work with enums and classes, but this
      // can also be done directly in the host and flutter APIs.
      int index = 0;
      for (final String member in anEnum.members) {
        indent.writeln('case ${_camelCase(member)} = $index');
        index++;
      }
    });
  }

  void writeDataClass(Class klass) {
    void writeField(NamedType field) {
      addDocumentationComments(
          indent, field.documentationComments, _docCommentSpec);

      indent.write(
          'var ${field.name}: ${_nullsafeSwiftTypeForDartType(field.type)}');
      final String defaultNil = field.type.isNullable ? ' = nil' : '';
      indent.addln(defaultNil);
    }

    void writeToMap() {
      indent.write('func toMap() -> [String: Any?] ');
      indent.scoped('{', '}', () {
        indent.write('return ');
        indent.scoped('[', ']', () {
          for (final NamedType field in klass.fields) {
            final HostDatatype hostDatatype = getHostDatatype(field);
            String toWriteValue = '';
            final String fieldName = field.name;
            final String nullsafe = field.type.isNullable ? '?' : '';
            if (!hostDatatype.isBuiltin &&
                rootClassNameSet.contains(field.type.baseName)) {
              toWriteValue = '$fieldName$nullsafe.toMap()';
            } else if (!hostDatatype.isBuiltin &&
                rootEnumNameSet.contains(field.type.baseName)) {
              toWriteValue = '$fieldName$nullsafe.rawValue';
            } else {
              toWriteValue = field.name;
            }

            final String comma = klass.fields.last == field ? '' : ',';

            indent.writeln('"${field.name}": $toWriteValue$comma');
          }
        });
      });
    }

    void writeFromMap() {
      final String className = klass.name;
      indent
          .write('static func fromMap(_ map: [String: Any?]) -> $className? ');

      indent.scoped('{', '}', () {
        for (final NamedType field in klass.fields) {
          final HostDatatype hostDatatype = getHostDatatype(field);

          final String mapValue = 'map["${field.name}"]';
          final String fieldType = _swiftTypeForDartType(field.type);

          if (field.type.isNullable) {
            if (!hostDatatype.isBuiltin &&
                rootClassNameSet.contains(field.type.baseName)) {
              indent.writeln('var ${field.name}: $fieldType? = nil');
              indent.write(
                  'if let ${field.name}Map = $mapValue as? [String: Any?] ');
              indent.scoped('{', '}', () {
                indent.writeln(
                    '${field.name} = $fieldType.fromMap(${field.name}Map)');
              });
            } else if (!hostDatatype.isBuiltin &&
                rootEnumNameSet.contains(field.type.baseName)) {
              indent.writeln('var ${field.name}: $fieldType? = nil');
              indent.write('if let ${field.name}RawValue = $mapValue as? Int ');
              indent.scoped('{', '}', () {
                indent.writeln(
                    '${field.name} = $fieldType(rawValue: ${field.name}RawValue)');
              });
            } else {
              indent.writeln('let ${field.name} = $mapValue as? $fieldType ');
            }
          } else {
            if (!hostDatatype.isBuiltin &&
                rootClassNameSet.contains(field.type.baseName)) {
              indent.writeln(
                  'let ${field.name} = $fieldType.fromMap($mapValue as! [String: Any?])!');
            } else if (!hostDatatype.isBuiltin &&
                rootEnumNameSet.contains(field.type.baseName)) {
              indent.writeln(
                  'let ${field.name} = $fieldType(rawValue: $mapValue as! Int)!');
            } else {
              indent.writeln('let ${field.name} = $mapValue as! $fieldType');
            }
          }
        }

        indent.writeln('');
        indent.write('return ');
        indent.scoped('$className(', ')', () {
          for (final NamedType field in klass.fields) {
            final String comma = klass.fields.last == field ? '' : ',';
            indent.writeln('${field.name}: ${field.name}$comma');
          }
        });
      });
    }

    const List<String> generatedComments = <String>[
      'Generated class from Pigeon that represents data sent in messages.'
    ];
    addDocumentationComments(
        indent, klass.documentationComments, _docCommentSpec,
        generatorComments: generatedComments);

    indent.write('struct ${klass.name} ');
    indent.scoped('{', '}', () {
      klass.fields.forEach(writeField);

      indent.writeln('');
      writeFromMap();
      writeToMap();
    });
  }

  void writeApi(Api api, Root root) {
    if (api.location == ApiLocation.host) {
      _writeHostApi(indent, api, root);
    } else if (api.location == ApiLocation.flutter) {
      _writeFlutterApi(indent, api, root);
    }
  }

  void writeWrapResult() {
    indent.write('private func wrapResult(_ result: Any?) -> [String: Any?] ');
    indent.scoped('{', '}', () {
      indent.writeln('return ["result": result]');
    });
  }

  void writeWrapError() {
    indent.write(
        'private func wrapError(_ error: FlutterError) -> [String: Any?] ');
    indent.scoped('{', '}', () {
      indent.write('return ');
      indent.scoped('[', ']', () {
        indent.write('"error": ');
        indent.scoped('[', ']', () {
          indent.writeln('"${Keys.errorCode}": error.code,');
          indent.writeln('"${Keys.errorMessage}": error.message,');
          indent.writeln('"${Keys.errorDetails}": error.details');
        });
      });
    });
  }

  writeHeader();
  indent.addln('');
  writeImports();
  indent.addln('');
  indent.writeln('$_docCommentPrefix Generated class from Pigeon.');
  for (final Enum anEnum in root.enums) {
    indent.writeln('');
    writeEnum(anEnum);
  }

  for (final Class klass in root.classes) {
    indent.addln('');
    writeDataClass(klass);
  }

  if (root.apis.any((Api api) =>
      api.location == ApiLocation.host &&
      api.methods.any((Method it) => it.isAsynchronous))) {
    indent.addln('');
  }

  for (final Api api in root.apis) {
    _writeCodec(indent, api, root);
    indent.addln('');
    writeApi(api, root);
  }

  indent.addln('');
  writeWrapResult();
  indent.addln('');
  writeWrapError();
}

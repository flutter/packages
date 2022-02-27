// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/functional.dart';

import 'ast.dart';
import 'generator_tools.dart';

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
              indent
                  .write('guard let map = self.readValue() as? [String: Any] ');
              indent.scoped('else {', '}', () {
                indent.writeln('return nil');
              });
              indent.write('return ${customClass.name}.fromMap(map)');
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
          indent.scoped(
              'if let value = value as? ${customClass.name} {', '} else ', () {
            indent.writeln('super.writeByte(${customClass.enumeration})');
            indent.writeln('super.writeValue(value.toMap() ?? [:])');
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
  indent.write('private class $codecName: FlutterStandardMessageCodec ');
  indent.scoped('{', '}', () {
    indent.write(
        'static let shared = $codecName(readerWriter: $readerWriterName())');
  });
}

/// Write the swift code that represents a host [Api], [api].
/// Example:
/// public protocol Foo {
///   Int add(x: Int, y: Int);
///   static func setup(FlutterBinaryMessenger binaryMessenger, Foo api) {...}
/// }
void _writeHostApi(Indent indent, Api api) {
  assert(api.location == ApiLocation.host);

  indent.writeln(
      '/** Generated protocol from Pigeon that represents a handler of messages from Flutter.*/');
  indent.write('public protocol ${api.name} ');
  indent.scoped('{', '}', () {
    for (final Method method in api.methods) {
      final List<String> argSignature = <String>[];
      if (method.arguments.isNotEmpty) {
        final Iterable<String> argTypes = method.arguments
            .map((NamedType e) => _swiftTypeForDartType(e.type));
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
      '/** Generated setup class from Pigeon to handle messages through the `binaryMessenger`.*/');
  indent.write('public class ${api.name}Setup ');
  indent.scoped('{', '}', () {
    final String codecName = _getCodecName(api);
    indent.format('''
/** The codec used by ${api.name}. */
static var codec: FlutterStandardMessageCodec { $codecName.shared }
''');
    indent.writeln(
        '/** Sets up an instance of `${api.name}` to handle messages through the `binaryMessenger`. */');
    indent.write(
        'static func setup(binaryMessenger: FlutterBinaryMessenger, api: ${api.name}) ');
    indent.scoped('{', '}', () {
      for (final Method method in api.methods) {
        final String channelName = makeChannelName(api, method);
        final String varChannelName = '${method.name}Channel';

        indent.writeln(
            'let $varChannelName = FlutterBasicMessageChannel(name: "$channelName", binaryMessenger: binaryMessenger, codec: codec)');
        indent.write('$varChannelName.setMessageHandler ');
        indent.scoped('{ message, reply in', '}', () {
          final List<String> methodArgument = <String>[];
          if (method.arguments.isNotEmpty) {
            indent.write('guard let args = message as? [Any?] ');
            indent.scoped('else {', '}', () {
              indent.writeln(
                  'let error = FlutterError(code: "unexpected-args", message: "Unexpected argument parameters", details: nil)');
              indent.writeln('reply(wrapError(error))');
              indent.writeln('return');
            });
            indent.write('guard args.count == ${method.arguments.length} ');
            indent.scoped('else {', '}', () {
              indent.writeln(
                  'let error = FlutterError(code: "unexpected-args-count", message: "Unexpected argument parameters count", details: "Expected parameters count: ${method.arguments.length}. Received: \\(args.count)")');
              indent.writeln('reply(wrapError(error))');
              indent.writeln('return');
            });
            enumerate(method.arguments, (int index, NamedType arg) {
              final String argType = _swiftTypeForDartType(arg.type);
              final String argName = _getSafeArgumentName(index, arg);

              indent.write('guard let $argName = args[$index] as? $argType ');
              indent.scoped('else {', '}', () {
                indent.writeln(
                    'let error = FlutterError(code: "unexpected-arg-type", message: "${arg.name} argument unexpected type", details: "Expected type: $argType. Received: \\(type(of: args[$index]))")');
                indent.writeln('reply(wrapError(error))');
                indent.writeln('return');
              });
              methodArgument.add('${arg.name}: $argName');
            });
          }
          final String call =
              'api.${method.name}(${methodArgument.join(', ')})';
          if (method.isAsynchronous) {
            indent.write('$call ');
            if (method.returnType.isVoid) {
              indent.scoped('{', '}', () {
                indent.writeln('reply(wrapResult(nil))');
              });
            } else {
              indent.scoped('{ result in', '}', () {
                indent.writeln('reply(wrapResult(result))');
              });
            }
          } else {
            if (method.returnType.isVoid) {
              indent.writeln(call);
              indent.writeln('reply(wrapResult(nil))');
            } else {
              indent.writeln('let result = $call');
              indent.writeln('reply(wrapResult(result))');
            }
          }
          if (!method.isAsynchronous) {
          } else {}
        });
      }
    });
  });
}

String _getArgumentName(int count, NamedType argument) =>
    argument.name.isEmpty ? 'arg$count' : argument.name;

/// Returns an argument name that can be used in a context where it is possible to collide.
String _getSafeArgumentName(int count, NamedType argument) =>
    _getArgumentName(count, argument) + 'Arg';

/// Writes the code for a flutter [Api], [api].
/// Example:
/// public class Foo {
///   private let binaryMessenger: FlutterBinaryMessenger
///   public init(binaryMessenger: FlutterBinaryMessenger) {...}
///   public func add(x: Int, y: Int, completion: @escaping (Int?) -> Void) {...}
/// }
void _writeFlutterApi(Indent indent, Api api) {
  assert(api.location == ApiLocation.flutter);
  indent.writeln(
      '/** Generated class from Pigeon that represents Flutter messages that can be called from Swift.*/');
  indent.write('public class ${api.name} ');
  indent.scoped('{', '}', () {
    indent.writeln('private let binaryMessenger: FlutterBinaryMessenger');
    indent.write('public init(binaryMessenger: FlutterBinaryMessenger)');
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
      final String returnType =
          func.returnType.isVoid ? '' : _swiftTypeForDartType(func.returnType);
      final String nullsafe = func.returnType.isNullable ? '?' : '';
      String sendArgument;
      if (func.arguments.isEmpty) {
        indent.write(
            'public func ${func.name}(completion: @escaping ($returnType$nullsafe) -> Void) ');
        sendArgument = 'null';
      } else {
        final Iterable<String> argTypes =
            func.arguments.map((NamedType e) => _swiftTypeForDartType(e.type));
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
              'public func ${func.name}($argsSignature, completion: @escaping () -> Void) ');
        } else {
          indent.write(
              'public func ${func.name}($argsSignature, completion: @escaping ($returnType$nullsafe) -> Void) ');
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
            indent.writeln('let result = response as$nullsafe $returnType');
            indent.writeln('completion(result)');
          });
        }
      });
    }
  });
}

/// Converts a [List] of [TypeDeclaration]s to a comma separated [String] to be
/// used in Swift code.
String _flattenTypeArguments(List<TypeDeclaration> args) {
  return args.map<String>(_swiftTypeForDartType).join(', ');
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
    'int': 'Int',
    'double': 'Double',
    'Uint8List': '[UInt8]',
    'Int32List': '[Int32]',
    'Int64List': '[Int64]',
    'Float32List': '[Float32]',
    'Float64List': '[Float64]',
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
  final Indent indent = Indent(sink);

  void writeHeader() {
    if (options.copyrightHeader != null) {
      addLines(indent, options.copyrightHeader!, linePrefix: '// ');
    }
    indent.writeln('// $generatedCodeWarning');
    indent.writeln('// $seeAlsoWarning');
  }

  void writeImports() {
    indent.writeln('import Foundation');
    indent.writeln('import Flutter');
  }

  void writeExtensions() {
    indent.write('''
fileprivate protocol Mappable: Codable {}

fileprivate let jsonEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.nonConformingFloatEncodingStrategy = .convertToString(positiveInfinity: "+inf", negativeInfinity: "-inf", nan: "nan")
    return encoder
}()
fileprivate let jsonDecoder = JSONDecoder()

fileprivate extension Mappable {
    static func fromMap(_ map: [String: Any?]) -> Self? {
        guard let json = try? JSONSerialization.data(withJSONObject: map, options: []) else {
            return nil
        }
        return try? jsonDecoder.decode(Self.self, from: json)
    }
    
    func toMap() -> [String: Any?]? {
        guard let json = try? jsonEncoder.encode(self) else {
            return nil
        }
        return try? JSONSerialization.jsonObject(with: json, options: .allowFragments) as? [String: Any?]
    }
}
''');
  }

  void writeEnum(Enum anEnum) {
    indent.write('public enum ${anEnum.name}: Int, Mappable ');
    indent.scoped('{', '}', () {
      // We use explicit indexing here as use of the ordinal() method is
      // discouraged. The toMap and fromMap API matches class API to allow
      // the same code to work with enums and classes, but this
      // can also be done directly in the host and flutter APIs.
      int index = 0;
      for (final String member in anEnum.members) {
        indent.writeln('case $member = $index');
        index++;
      }
    });
  }

  void writeDataClass(Class klass) {
    void writeField(NamedType field) {
      final HostDatatype hostDatatype = getHostDatatype(field, root.classes,
          root.enums, (NamedType x) => _swiftTypeForBuiltinDartType(x.type));
      final String nullability = field.type.isNullable ? '?' : '';
      indent.writeln('let ${field.name}: ${hostDatatype.datatype}$nullability');
    }

    indent.writeln(
        '/** Generated class from Pigeon that represents data sent in messages. */');
    indent.write('public struct ${klass.name}: Mappable ');
    indent.scoped('{', '}', () {
      klass.fields.forEach(writeField);
    });
  }

  void writeApi(Api api) {
    if (api.location == ApiLocation.host) {
      _writeHostApi(indent, api);
    } else if (api.location == ApiLocation.flutter) {
      _writeFlutterApi(indent, api);
    }
  }

  void writeWrapResult() {
    indent.write(
        'fileprivate func wrapResult(_ result: Any?) -> [String: Any?] ');
    indent.scoped('{', '}', () {
      indent.writeln('return ["result": result]');
    });
  }

  void writeWrapError() {
    indent.write(
        'fileprivate func wrapError(_ error: FlutterError) -> [String: Any?] ');
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
  indent.writeln('/** Generated class from Pigeon. */');

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
    writeApi(api);
  }

  indent.addln('');
  writeWrapResult();
  indent.addln('');
  writeWrapError();
  indent.addln('');
  writeExtensions();
}

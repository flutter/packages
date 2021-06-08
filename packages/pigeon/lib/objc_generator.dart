// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'ast.dart';
import 'generator_tools.dart';

/// Options that control how Objective-C code will be generated.
class ObjcOptions {
  /// Parametric constructor for ObjcOptions.
  ObjcOptions({
    this.header,
    this.prefix,
  });

  /// The path to the header that will get placed in the source filed (example:
  /// "foo.h").
  String? header;

  /// Prefix that will be appended before all generated classes and protocols.
  String? prefix;
}

String _className(String? prefix, String className) {
  if (prefix != null) {
    return '$prefix$className';
  } else {
    return className;
  }
}

String _callbackForType(String dartType, String objcType) {
  return dartType == 'void'
      ? 'void(^)(NSError* _Nullable)'
      : 'void(^)($objcType*, NSError* _Nullable)';
}

const Map<String, String> _objcTypeForDartTypeMap = <String, String>{
  'bool': 'NSNumber *',
  'int': 'NSNumber *',
  'String': 'NSString *',
  'double': 'NSNumber *',
  'Uint8List': 'FlutterStandardTypedData *',
  'Int32List': 'FlutterStandardTypedData *',
  'Int64List': 'FlutterStandardTypedData *',
  'Float64List': 'FlutterStandardTypedData *',
  'List': 'NSArray *',
  'Map': 'NSDictionary *',
};

const Map<String, String> _propertyTypeForDartTypeMap = <String, String>{
  'String': 'copy',
  'bool': 'strong',
  'int': 'strong',
  'double': 'strong',
  'Uint8List': 'strong',
  'Int32List': 'strong',
  'Int64List': 'strong',
  'Float64List': 'strong',
  'List': 'strong',
  'Map': 'strong',
};

String? _objcTypeForDartType(String type) {
  return _objcTypeForDartTypeMap[type];
}

String _propertyTypeForDartType(String type) {
  final String? result = _propertyTypeForDartTypeMap[type];
  if (result == null) {
    return 'assign';
  } else {
    return result;
  }
}

void _writeClassDeclarations(
    Indent indent, List<Class> classes, List<Enum> enums, String? prefix) {
  final List<String> enumNames = enums.map((Enum x) => x.name).toList();
  for (final Class klass in classes) {
    indent.writeln('@interface ${_className(prefix, klass.name)} : NSObject');
    for (final Field field in klass.fields) {
      final HostDatatype hostDatatype = getHostDatatype(
          field, classes, enums, _objcTypeForDartType,
          customResolver: enumNames.contains(field.dataType)
              ? (String x) => _className(prefix, x)
              : (String x) => '${_className(prefix, x)} *');
      late final String propertyType;
      if (hostDatatype.isBuiltin) {
        propertyType = _propertyTypeForDartType(field.dataType);
      } else if (enumNames.contains(field.dataType)) {
        propertyType = 'assign';
      } else {
        propertyType = 'strong';
      }
      final String nullability =
          hostDatatype.datatype.contains('*') ? ', nullable' : '';
      indent.writeln(
          '@property(nonatomic, $propertyType$nullability) ${hostDatatype.datatype} ${field.name};');
    }
    indent.writeln('@end');
    indent.writeln('');
  }
}

void _writeHostApiDeclaration(Indent indent, Api api, ObjcOptions options) {
  final String apiName = _className(options.prefix, api.name);
  indent.writeln('@protocol $apiName');
  for (final Method func in api.methods) {
    final String returnTypeName = _className(options.prefix, func.returnType);
    if (func.isAsynchronous) {
      if (func.returnType == 'void') {
        if (func.argType == 'void') {
          indent.writeln(
              '-(void)${func.name}:(void(^)(FlutterError *_Nullable))completion;');
        } else {
          final String argType = _className(options.prefix, func.argType);
          indent.writeln(
              '-(void)${func.name}:(nullable $argType *)input completion:(void(^)(FlutterError *_Nullable))completion;');
        }
      } else {
        if (func.argType == 'void') {
          indent.writeln(
              '-(void)${func.name}:(void(^)($returnTypeName *_Nullable, FlutterError *_Nullable))completion;');
        } else {
          final String argType = _className(options.prefix, func.argType);
          indent.writeln(
              '-(void)${func.name}:(nullable $argType *)input completion:(void(^)($returnTypeName *_Nullable, FlutterError *_Nullable))completion;');
        }
      }
    } else {
      final String returnType =
          func.returnType == 'void' ? 'void' : 'nullable $returnTypeName *';
      if (func.argType == 'void') {
        indent.writeln(
            '-($returnType)${func.name}:(FlutterError *_Nullable *_Nonnull)error;');
      } else {
        final String argType = _className(options.prefix, func.argType);
        indent.writeln(
            '-($returnType)${func.name}:($argType*)input error:(FlutterError *_Nullable *_Nonnull)error;');
      }
    }
  }
  indent.writeln('@end');
  indent.writeln('');
  indent.writeln(
      'extern void ${apiName}Setup(id<FlutterBinaryMessenger> binaryMessenger, id<$apiName> _Nullable api);');
  indent.writeln('');
}

void _writeFlutterApiDeclaration(Indent indent, Api api, ObjcOptions options) {
  final String apiName = _className(options.prefix, api.name);
  indent.writeln('@interface $apiName : NSObject');
  indent.writeln(
      '- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger;');
  for (final Method func in api.methods) {
    final String returnType = _className(options.prefix, func.returnType);
    final String callbackType = _callbackForType(func.returnType, returnType);
    if (func.argType == 'void') {
      indent.writeln('- (void)${func.name}:($callbackType)completion;');
    } else {
      final String argType = _className(options.prefix, func.argType);
      indent.writeln(
          '- (void)${func.name}:($argType*)input completion:($callbackType)completion;');
    }
  }
  indent.writeln('@end');
}

/// Generates the ".h" file for the AST represented by [root] to [sink] with the
/// provided [options].
void generateObjcHeader(ObjcOptions options, Root root, StringSink sink) {
  final Indent indent = Indent(sink);
  indent.writeln('// $generatedCodeWarning');
  indent.writeln('// $seeAlsoWarning');
  indent.writeln('#import <Foundation/Foundation.h>');
  indent.writeln('@protocol FlutterBinaryMessenger;');
  indent.writeln('@class FlutterError;');
  indent.writeln('@class FlutterStandardTypedData;');
  indent.writeln('');

  indent.writeln('NS_ASSUME_NONNULL_BEGIN');

  for (final Enum anEnum in root.enums) {
    indent.writeln('');
    final String enumName = _className(options.prefix, anEnum.name);
    indent.write('typedef NS_ENUM(NSUInteger, $enumName) ');
    indent.scoped('{', '};', () {
      int index = 0;
      for (final String member in anEnum.members) {
        // Capitalized first letter to ensure Swift compatibility
        indent.writeln(
            '$enumName${member[0].toUpperCase()}${member.substring(1)} = $index,');
        index++;
      }
    });
  }
  indent.writeln('');

  for (final Class klass in root.classes) {
    indent.writeln('@class ${_className(options.prefix, klass.name)};');
  }

  indent.writeln('');

  _writeClassDeclarations(indent, root.classes, root.enums, options.prefix);

  for (final Api api in root.apis) {
    if (api.location == ApiLocation.host) {
      _writeHostApiDeclaration(indent, api, options);
    } else if (api.location == ApiLocation.flutter) {
      _writeFlutterApiDeclaration(indent, api, options);
    }
  }

  indent.writeln('NS_ASSUME_NONNULL_END');
}

String _dictGetter(
    List<String> classNames, String dict, Field field, String? prefix) {
  if (classNames.contains(field.dataType)) {
    String className = field.dataType;
    if (prefix != null) {
      className = '$prefix$className';
    }
    return '[$className fromMap:$dict[@"${field.name}"]]';
  } else {
    return '$dict[@"${field.name}"]';
  }
}

String _dictValue(
    List<String> classNames, List<String> enumNames, Field field) {
  if (classNames.contains(field.dataType)) {
    return '(self.${field.name} ? [self.${field.name} toMap] : [NSNull null])';
  } else if (enumNames.contains(field.dataType)) {
    return '@(self.${field.name})';
  } else {
    return '(self.${field.name} ? self.${field.name} : [NSNull null])';
  }
}

void _writeHostApiSource(Indent indent, ObjcOptions options, Api api) {
  assert(api.location == ApiLocation.host);
  final String apiName = _className(options.prefix, api.name);
  indent.write(
      'void ${apiName}Setup(id<FlutterBinaryMessenger> binaryMessenger, id<$apiName> api) ');
  indent.scoped('{', '}', () {
    for (final Method func in api.methods) {
      indent.write('');
      indent.scoped('{', '}', () {
        indent.writeln('FlutterBasicMessageChannel *channel =');
        indent.inc();
        indent.writeln('[FlutterBasicMessageChannel');
        indent.inc();
        indent
            .writeln('messageChannelWithName:@"${makeChannelName(api, func)}"');
        indent.writeln('binaryMessenger:binaryMessenger];');
        indent.dec();
        indent.dec();

        indent.write('if (api) ');
        indent.scoped('{', '}', () {
          indent.write(
              '[channel setMessageHandler:^(id _Nullable message, FlutterReply callback) ');
          indent.scoped('{', '}];', () {
            final String returnType =
                _className(options.prefix, func.returnType);
            String syncCall;
            if (func.argType == 'void') {
              syncCall = '[api ${func.name}:&error]';
            } else {
              final String argType = _className(options.prefix, func.argType);
              indent.writeln('$argType *input = [$argType fromMap:message];');
              syncCall = '[api ${func.name}:input error:&error]';
            }
            if (func.isAsynchronous) {
              if (func.returnType == 'void') {
                const String callback = 'callback(error);';
                if (func.argType == 'void') {
                  indent.writeScoped(
                      '[api ${func.name}:^(FlutterError *_Nullable error) {',
                      '}];', () {
                    indent.writeln(callback);
                  });
                } else {
                  indent.writeScoped(
                      '[api ${func.name}:input completion:^(FlutterError *_Nullable error) {',
                      '}];', () {
                    indent.writeln(callback);
                  });
                }
              } else {
                const String callback =
                    'callback(wrapResult([output toMap], error));';
                if (func.argType == 'void') {
                  indent.writeScoped(
                      '[api ${func.name}:^($returnType *_Nullable output, FlutterError *_Nullable error) {',
                      '}];', () {
                    indent.writeln(callback);
                  });
                } else {
                  indent.writeScoped(
                      '[api ${func.name}:input completion:^($returnType *_Nullable output, FlutterError *_Nullable error) {',
                      '}];', () {
                    indent.writeln(callback);
                  });
                }
              }
            } else {
              indent.writeln('FlutterError *error;');
              if (func.returnType == 'void') {
                indent.writeln('$syncCall;');
                indent.writeln('callback(wrapResult(nil, error));');
              } else {
                indent.writeln('$returnType *output = $syncCall;');
                indent.writeln('callback(wrapResult([output toMap], error));');
              }
            }
          });
        });
        indent.write('else ');
        indent.scoped('{', '}', () {
          indent.writeln('[channel setMessageHandler:nil];');
        });
      });
    }
  });
}

void _writeFlutterApiSource(Indent indent, ObjcOptions options, Api api) {
  assert(api.location == ApiLocation.flutter);
  final String apiName = _className(options.prefix, api.name);
  indent.writeln('@interface $apiName ()');
  indent.writeln(
      '@property (nonatomic, strong) NSObject<FlutterBinaryMessenger>* binaryMessenger;');
  indent.writeln('@end');
  indent.addln('');
  indent.writeln('@implementation $apiName');
  indent.write(
      '- (instancetype)initWithBinaryMessenger:(NSObject<FlutterBinaryMessenger>*)binaryMessenger ');
  indent.scoped('{', '}', () {
    indent.writeln('self = [super init];');
    indent.write('if (self) ');
    indent.scoped('{', '}', () {
      indent.writeln('_binaryMessenger = binaryMessenger;');
    });
    indent.writeln('return self;');
  });
  indent.addln('');
  for (final Method func in api.methods) {
    final String returnType = _className(options.prefix, func.returnType);
    final String callbackType = _callbackForType(func.returnType, returnType);

    String sendArgument;
    if (func.argType == 'void') {
      indent.write('- (void)${func.name}:($callbackType)completion ');
      sendArgument = 'nil';
    } else {
      final String argType = _className(options.prefix, func.argType);
      indent.write(
          '- (void)${func.name}:($argType*)input completion:($callbackType)completion ');
      sendArgument = 'inputMap';
    }
    indent.scoped('{', '}', () {
      indent.writeln('FlutterBasicMessageChannel *channel =');
      indent.inc();
      indent.writeln('[FlutterBasicMessageChannel');
      indent.inc();
      indent.writeln('messageChannelWithName:@"${makeChannelName(api, func)}"');
      indent.writeln('binaryMessenger:self.binaryMessenger];');
      indent.dec();
      indent.dec();
      if (func.argType != 'void') {
        indent.writeln('NSDictionary* inputMap = [input toMap];');
      }
      indent.write('[channel sendMessage:$sendArgument reply:^(id reply) ');
      indent.scoped('{', '}];', () {
        if (func.returnType == 'void') {
          indent.writeln('completion(nil);');
        } else {
          indent.writeln('NSDictionary* outputMap = reply;');
          indent.writeln(
              '$returnType * output = [$returnType fromMap:outputMap];');
          indent.writeln('completion(output, nil);');
        }
      });
    });
  }
  indent.writeln('@end');
}

/// Generates the ".m" file for the AST represented by [root] to [sink] with the
/// provided [options].
void generateObjcSource(ObjcOptions options, Root root, StringSink sink) {
  final Indent indent = Indent(sink);
  final List<String> classNames =
      root.classes.map((Class x) => x.name).toList();
  final List<String> enumNames = root.enums.map((Enum x) => x.name).toList();

  indent.writeln('// $generatedCodeWarning');
  indent.writeln('// $seeAlsoWarning');
  indent.writeln('#import "${options.header}"');
  indent.writeln('#import <Flutter/Flutter.h>');
  indent.writeln('');

  indent.writeln('#if !__has_feature(objc_arc)');
  indent.writeln('#error File requires ARC to be enabled.');
  indent.writeln('#endif');
  indent.addln('');

  indent.format('''
static NSDictionary<NSString*, id>* wrapResult(NSDictionary *result, FlutterError *error) {
\tNSDictionary *errorDict = (NSDictionary *)[NSNull null];
\tif (error) {
\t\terrorDict = @{
\t\t\t\t@"${Keys.errorCode}": (error.code ? error.code : [NSNull null]),
\t\t\t\t@"${Keys.errorMessage}": (error.message ? error.message : [NSNull null]),
\t\t\t\t@"${Keys.errorDetails}": (error.details ? error.details : [NSNull null]),
\t\t\t\t};
\t}
\treturn @{
\t\t\t@"${Keys.result}": (result ? result : [NSNull null]),
\t\t\t@"${Keys.error}": errorDict,
\t\t\t};
}''');
  indent.addln('');

  for (final Class klass in root.classes) {
    final String className = _className(options.prefix, klass.name);
    indent.writeln('@interface $className ()');
    indent.writeln('+($className*)fromMap:(NSDictionary*)dict;');
    indent.writeln('-(NSDictionary*)toMap;');
    indent.writeln('@end');
  }

  indent.writeln('');

  for (final Class klass in root.classes) {
    final String className = _className(options.prefix, klass.name);
    indent.writeln('@implementation $className');
    indent.write('+($className*)fromMap:(NSDictionary*)dict ');
    indent.scoped('{', '}', () {
      const String resultName = 'result';
      indent.writeln('$className* $resultName = [[$className alloc] init];');
      for (final Field field in klass.fields) {
        if (enumNames.contains(field.dataType)) {
          indent.writeln(
              '$resultName.${field.name} = [${_dictGetter(classNames, 'dict', field, options.prefix)} integerValue];');
        } else {
          indent.writeln(
              '$resultName.${field.name} = ${_dictGetter(classNames, 'dict', field, options.prefix)};');
          indent.write(
              'if ((NSNull *)$resultName.${field.name} == [NSNull null]) ');
          indent.scoped('{', '}', () {
            indent.writeln('$resultName.${field.name} = nil;');
          });
        }
      }
      indent.writeln('return $resultName;');
    });
    indent.write('-(NSDictionary*)toMap ');
    indent.scoped('{', '}', () {
      indent.write('return [NSDictionary dictionaryWithObjectsAndKeys:');
      for (final Field field in klass.fields) {
        indent.add(
            _dictValue(classNames, enumNames, field) + ', @"${field.name}", ');
      }
      indent.addln('nil];');
    });
    indent.writeln('@end');
    indent.writeln('');
  }

  for (final Api api in root.apis) {
    if (api.location == ApiLocation.host) {
      _writeHostApiSource(indent, options, api);
    } else if (api.location == ApiLocation.flutter) {
      _writeFlutterApiSource(indent, options, api);
    }
  }
}

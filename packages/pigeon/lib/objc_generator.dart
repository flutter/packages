// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'ast.dart';
import 'generator_tools.dart';

/// Options that control how Objective-C code will be generated.
class ObjcOptions {
  /// Parametric constructor for ObjcOptions.
  ObjcOptions({this.header, this.prefix});

  /// The path to the header that will get placed in the source filed (example:
  /// "foo.h").
  String header;

  /// Prefix that will be appended before all generated classes and protocols.
  String prefix;
}

String _className(String prefix, String className) {
  if (prefix != null) {
    return '$prefix$className';
  } else {
    return className;
  }
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
};

String _objcTypeForDartType(String type) {
  return _objcTypeForDartTypeMap[type];
}

String _propertyTypeForDartType(String type) {
  final String result = _propertyTypeForDartTypeMap[type];
  if (result == null) {
    return 'assign';
  } else {
    return result;
  }
}

/// Generates the ".h" file for the AST represented by [root] to [sink] with the
/// provided [options].
void generateObjcHeader(ObjcOptions options, Root root, StringSink sink) {
  final Indent indent = Indent(sink);
  indent.writeln('// $generatedCodeWarning');
  indent.writeln('// $seeAlsoWarning');
  indent.writeln('#import <Foundation/Foundation.h>');
  indent.writeln('@protocol FlutterBinaryMessenger;');
  indent.writeln('@class FlutterStandardTypedData;');
  indent.writeln('');

  for (Class klass in root.classes) {
    indent.writeln('@class ${_className(options.prefix, klass.name)};');
  }

  indent.writeln('');

  for (Class klass in root.classes) {
    indent.writeln(
        '@interface ${_className(options.prefix, klass.name)} : NSObject ');
    for (Field field in klass.fields) {
      final HostDatatype hostDatatype = getHostDatatype(
          field,
          root.classes,
          _objcTypeForDartType,
          (String x) => '${_className(options.prefix, x)} *');
      final String propertyType = hostDatatype.isBuiltin
          ? _propertyTypeForDartType(field.dataType)
          : 'strong';
      indent.writeln(
          '@property(nonatomic, $propertyType) ${hostDatatype.datatype} ${field.name};');
    }
    indent.writeln('@end');
    indent.writeln('');
  }

  for (Api api in root.apis) {
    final String apiName = _className(options.prefix, api.name);
    if (api.location == ApiLocation.host) {
      indent.writeln('@protocol $apiName');
      for (Method func in api.methods) {
        final String returnType = _className(options.prefix, func.returnType);
        final String argType = _className(options.prefix, func.argType);
        indent.writeln('-($returnType *)${func.name}:($argType*)input;');
      }
      indent.writeln('@end');
      indent.writeln('');
      indent.writeln(
          'extern void ${apiName}Setup(id<FlutterBinaryMessenger> binaryMessenger, id<$apiName> api);');
      indent.writeln('');
    } else if (api.location == ApiLocation.flutter) {
      indent.writeln('@interface $apiName : NSObject');
      indent.writeln(
          '- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger;');
      for (Method func in api.methods) {
        final String returnType = _className(options.prefix, func.returnType);
        final String argType = _className(options.prefix, func.argType);
        indent.writeln(
            '- (void)${func.name}:($argType*)input completion:(void(^)($returnType*, NSError*))completion;');
      }
      indent.writeln('@end');
    }
  }
}

String _dictGetter(
    List<String> classnames, String dict, Field field, String prefix) {
  if (classnames.contains(field.dataType)) {
    String className = field.dataType;
    if (prefix != null) {
      className = '$prefix$className';
    }
    return '[$className fromMap:$dict[@"${field.name}"]]';
  } else {
    return '$dict[@"${field.name}"]';
  }
}

String _dictValue(List<String> classnames, Field field) {
  if (classnames.contains(field.dataType)) {
    return '(self.${field.name} ? [self.${field.name} toMap] : [NSNull null])';
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
    for (Method func in api.methods) {
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
            final String argType = _className(options.prefix, func.argType);
            final String returnType =
                _className(options.prefix, func.returnType);
            indent.writeln('$argType *input = [$argType fromMap:message];');
            indent.writeln('$returnType *output = [api ${func.name}:input];');
            indent.writeln('callback([output toMap]);');
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
      indent.writeln('self.binaryMessenger = binaryMessenger;');
    });
    indent.writeln('return self;');
  });
  indent.addln('');
  for (Method func in api.methods) {
    final String returnType = _className(options.prefix, func.returnType);
    final String argType = _className(options.prefix, func.argType);
    indent.write(
        '- (void)${func.name}:($argType*)input completion:(void(^)($returnType*, NSError*))completion ');
    indent.scoped('{', '}', () {
      indent.writeln('FlutterBasicMessageChannel *channel =');
      indent.inc();
      indent.writeln('[FlutterBasicMessageChannel');
      indent.inc();
      indent.writeln('messageChannelWithName:@"${makeChannelName(api, func)}"');
      indent.writeln('binaryMessenger:self.binaryMessenger];');
      indent.dec();
      indent.dec();
      indent.writeln('NSDictionary* inputMap = [input toMap];');
      indent.write('[channel sendMessage:inputMap reply:^(id reply) ');
      indent.scoped('{', '}];', () {
        indent.writeln('NSDictionary* outputMap = reply;');
        indent
            .writeln('$returnType * output = [$returnType fromMap:outputMap];');
        indent.writeln('completion(output, nil);');
      });
    });
  }
  indent.writeln('@end');
}

/// Generates the ".m" file for the AST represented by [root] to [sink] with the
/// provided [options].
void generateObjcSource(ObjcOptions options, Root root, StringSink sink) {
  final Indent indent = Indent(sink);
  final List<String> classnames =
      root.classes.map((Class x) => x.name).toList();

  indent.writeln('// Autogenerated from Dartle.');
  indent.writeln('#import "${options.header}"');
  indent.writeln('#import <Flutter/Flutter.h>');
  indent.writeln('');

  for (Class klass in root.classes) {
    final String className = _className(options.prefix, klass.name);
    indent.writeln('@interface $className ()');
    indent.writeln('+($className*)fromMap:(NSDictionary*)dict;');
    indent.writeln('-(NSDictionary*)toMap;');
    indent.writeln('@end');
  }

  indent.writeln('');

  for (Class klass in root.classes) {
    final String className = _className(options.prefix, klass.name);
    indent.writeln('@implementation $className');
    indent.write('+($className*)fromMap:(NSDictionary*)dict ');
    indent.scoped('{', '}', () {
      const String resultName = 'result';
      indent.writeln('$className* $resultName = [[$className alloc] init];');
      for (Field field in klass.fields) {
        indent.writeln(
            '$resultName.${field.name} = ${_dictGetter(classnames, 'dict', field, options.prefix)};');
        indent.write(
            'if ((NSNull *)$resultName.${field.name} == [NSNull null]) ');
        indent.scoped('{', '}', () {
          indent.writeln('$resultName.${field.name} = nil;');
        });
      }
      indent.writeln('return $resultName;');
    });
    indent.write('-(NSDictionary*)toMap ');
    indent.scoped('{', '}', () {
      indent.write('return [NSDictionary dictionaryWithObjectsAndKeys:');
      for (Field field in klass.fields) {
        indent.add(_dictValue(classnames, field) + ', @"${field.name}", ');
      }
      indent.addln('nil];');
    });
    indent.writeln('@end');
    indent.writeln('');
  }

  for (Api api in root.apis) {
    if (api.location == ApiLocation.host) {
      _writeHostApiSource(indent, options, api);
    } else if (api.location == ApiLocation.flutter) {
      _writeFlutterApiSource(indent, options, api);
    }
  }
}

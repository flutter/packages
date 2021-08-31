// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/functional.dart';

import 'ast.dart';
import 'generator_tools.dart';

/// Options that control how Objective-C code will be generated.
class ObjcOptions {
  /// Parametric constructor for ObjcOptions.
  const ObjcOptions({
    this.header,
    this.prefix,
    this.copyrightHeader,
  });

  /// The path to the header that will get placed in the source filed (example:
  /// "foo.h").
  final String? header;

  /// Prefix that will be appended before all generated classes and protocols.
  final String? prefix;

  /// A copyright header that will get prepended to generated code.
  final Iterable<String>? copyrightHeader;

  /// Creates a [ObjcOptions] from a Map representation where:
  /// `x = ObjcOptions.fromMap(x.toMap())`.
  static ObjcOptions fromMap(Map<String, Object> map) {
    return ObjcOptions(
      header: map['header'] as String?,
      prefix: map['prefix'] as String?,
      copyrightHeader: map['copyrightHeader'] as Iterable<String>?,
    );
  }

  /// Converts a [ObjcOptions] to a Map representation where:
  /// `x = ObjcOptions.fromMap(x.toMap())`.
  Map<String, Object> toMap() {
    final Map<String, Object> result = <String, Object>{
      if (header != null) 'header': header!,
      if (prefix != null) 'prefix': prefix!,
      if (copyrightHeader != null) 'copyrightHeader': copyrightHeader!,
    };
    return result;
  }

  /// Overrides any non-null parameters from [options] into this to make a new
  /// [ObjcOptions].
  ObjcOptions merge(ObjcOptions options) {
    return ObjcOptions.fromMap(mergeMaps(toMap(), options.toMap()));
  }
}

String _className(String? prefix, String className) {
  if (prefix != null) {
    return '$prefix$className';
  } else {
    return className;
  }
}

String _callbackForType(TypeDeclaration type, String objcType) {
  return type.isVoid
      ? 'void(^)(NSError *_Nullable)'
      : 'void(^)($objcType *, NSError *_Nullable)';
}

const Map<String, String> _objcTypeForDartTypeMap = <String, String>{
  'bool': 'NSNumber',
  'int': 'NSNumber',
  'String': 'NSString',
  'double': 'NSNumber',
  'Uint8List': 'FlutterStandardTypedData',
  'Int32List': 'FlutterStandardTypedData',
  'Int64List': 'FlutterStandardTypedData',
  'Float64List': 'FlutterStandardTypedData',
  'List': 'NSArray',
  'Map': 'NSDictionary',
};

String _flattenTypeArguments(String? classPrefix, List<TypeDeclaration> args) {
  final String result = args
      .map<String>(
          (TypeDeclaration e) => '${_objcTypeForDartType(classPrefix, e)} *')
      .join(', ');
  return result;
}

String? _objcTypePtrForPrimitiveDartType(String? classPrefix, NamedType field) {
  return _objcTypeForDartTypeMap.containsKey(field.type.baseName)
      ? '${_objcTypeForDartType(classPrefix, field.type)} *'
      : null;
}

/// Returns the objc type for a dart [type], prepending the [classPrefix] for
/// generated classes.  For example:
/// _objcTypeForDartType(null, 'int') => 'NSNumber'.
String _objcTypeForDartType(String? classPrefix, TypeDeclaration field) {
  return _objcTypeForDartTypeMap.containsKey(field.baseName)
      ? field.typeArguments.isEmpty
          ? _objcTypeForDartTypeMap[field.baseName]!
          : '${_objcTypeForDartTypeMap[field.baseName]}<${_flattenTypeArguments(classPrefix, field.typeArguments)}>'
      : _className(classPrefix, field.baseName);
}

String _propertyTypeForDartType(NamedType field) {
  const Map<String, String> propertyTypeForDartTypeMap = <String, String>{
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

  final String? result = propertyTypeForDartTypeMap[field.type.baseName];
  if (result == null) {
    return 'strong';
  } else {
    return result;
  }
}

void _writeClassDeclarations(
    Indent indent, List<Class> classes, List<Enum> enums, String? prefix) {
  final List<String> enumNames = enums.map((Enum x) => x.name).toList();
  for (final Class klass in classes) {
    indent.writeln('@interface ${_className(prefix, klass.name)} : NSObject');
    for (final NamedType field in klass.fields) {
      final HostDatatype hostDatatype = getHostDatatype(field, classes, enums,
          (NamedType x) => _objcTypePtrForPrimitiveDartType(prefix, x),
          customResolver: enumNames.contains(field.type.baseName)
              ? (String x) => _className(prefix, x)
              : (String x) => '${_className(prefix, x)} *');
      late final String propertyType;
      if (enumNames.contains(field.type.baseName)) {
        propertyType = 'assign';
      } else {
        propertyType = _propertyTypeForDartType(field);
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

String _getCodecName(String? prefix, String className) =>
    '${_className(prefix, className)}Codec';

String _getCodecGetterName(String? prefix, String className) =>
    '${_className(prefix, className)}GetCodec';

void _writeCodec(Indent indent, String name, ObjcOptions options, Api api) {
  final String readerWriterName = '${name}ReaderWriter';
  final String readerName = '${name}Reader';
  final String writerName = '${name}Writer';
  indent.writeln('@interface $readerName : FlutterStandardReader');
  indent.writeln('@end');
  indent.writeln('@implementation $readerName');
  if (getCodecClasses(api).isNotEmpty) {
    indent.writeln('- (nullable id)readValueOfType:(UInt8)type ');
    indent.scoped('{', '}', () {
      indent.write('switch (type) ');
      indent.scoped('{', '}', () {
        for (final EnumeratedClass customClass in getCodecClasses(api)) {
          indent.write('case ${customClass.enumeration}: ');
          indent.writeScoped('', '', () {
            indent.writeln(
                'return [${_className(options.prefix, customClass.name)} fromMap:[self readValue]];');
          });
        }
        indent.write('default:');
        indent.writeScoped('', '', () {
          indent.writeln('return [super readValueOfType:type];');
        });
      });
    });
  }
  indent.writeln('@end');
  indent.addln('');
  indent.writeln('@interface $writerName : FlutterStandardWriter');
  indent.writeln('@end');
  indent.writeln('@implementation $writerName');
  if (getCodecClasses(api).isNotEmpty) {
    indent.writeln('- (void)writeValue:(id)value ');
    indent.scoped('{', '}', () {
      for (final EnumeratedClass customClass in getCodecClasses(api)) {
        indent.write(
            'if ([value isKindOfClass:[${_className(options.prefix, customClass.name)} class]]) ');
        indent.scoped('{', '} else ', () {
          indent.writeln('[self writeByte:${customClass.enumeration}];');
          indent.writeln('[self writeValue:[value toMap]];');
        });
      }
      indent.scoped('{', '}', () {
        indent.writeln('[super writeValue:value];');
      });
    });
  }
  indent.writeln('@end');
  indent.addln('');
  indent.format('''
@interface $readerWriterName : FlutterStandardReaderWriter
@end
@implementation $readerWriterName
- (FlutterStandardWriter *)writerWithData:(NSMutableData *)data {
\treturn [[$writerName alloc] initWithData:data];
}
- (FlutterStandardReader *)readerWithData:(NSData *)data {
\treturn [[$readerName alloc] initWithData:data];
}
@end

NSObject<FlutterMessageCodec> *${_getCodecGetterName(options.prefix, api.name)}() {
\tstatic dispatch_once_t s_pred = 0;
\tstatic FlutterStandardMessageCodec *s_sharedObject = nil;
\tdispatch_once(&s_pred, ^{
\t\t$readerWriterName *readerWriter = [[$readerWriterName alloc] init];
\t\ts_sharedObject = [FlutterStandardMessageCodec codecWithReaderWriter:readerWriter];
\t});
\treturn s_sharedObject;
}
''');
}

String _capitalize(String str) =>
    (str.isEmpty) ? '' : str[0].toUpperCase() + str.substring(1);

/// Returns the components of the objc selector that will be generated from
/// [func], ie the strings between the semicolons.  [lastSelectorComponent] is
/// the last component of the selector aka the label of the last parameter which
/// isn't included in [func].
/// Example:
///   f('void add(int x, int y)', 'count') -> ['addX', 'y', 'count']
Iterable<String> _getSelectorComponents(
    Method func, String lastSelectorComponent) sync* {
  if (func.objcSelector.isEmpty) {
    final Iterator<NamedType> it = func.arguments.iterator;
    final bool hasArguments = it.moveNext();
    final String namePostfix =
        (lastSelectorComponent.isNotEmpty && func.arguments.isEmpty)
            ? 'With${_capitalize(lastSelectorComponent)}'
            : '';
    yield '${func.name}${hasArguments ? _capitalize(func.arguments[0].name) : namePostfix}';
    while (it.moveNext()) {
      yield it.current.name;
    }
  } else {
    assert(':'.allMatches(func.objcSelector).length == func.arguments.length);
    final Iterable<String> customComponents = func.objcSelector
        .split(':')
        .where((String element) => element.isNotEmpty);
    yield* customComponents;
  }
  if (lastSelectorComponent.isNotEmpty && func.arguments.isNotEmpty) {
    yield lastSelectorComponent;
  }
}

/// Generates the objc source code method signature for [func].  [returnType] is
/// the return value of method, this may not match the return value in [func]
/// since [func] may be asynchronous.  The function requires you specify a
/// [lastArgType] and [lastArgName] for arguments that aren't represented in
/// [func].  This is typically used for passing in 'error' or 'completion'
/// arguments that don't exist in the pigeon file but are required in the objc
/// output.  [argNameFunc] is the function used to generate the argument name
/// [func.arguments].
String _makeObjcSignature({
  required Method func,
  required ObjcOptions options,
  required String returnType,
  required String lastArgType,
  required String lastArgName,
  String Function(int, NamedType)? argNameFunc,
}) {
  argNameFunc = argNameFunc ?? (int _, NamedType e) => e.name;
  final Iterable<String> argNames =
      followedByOne(indexMap(func.arguments, argNameFunc), lastArgName);
  final Iterable<String> selectorComponents =
      _getSelectorComponents(func, lastArgName);
  final Iterable<String> argTypes = followedByOne(
    func.arguments.map((NamedType arg) {
      final String nullable = func.isAsynchronous ? 'nullable ' : '';
      final String argType = _objcTypeForDartType(options.prefix, arg.type);
      return '$nullable$argType *';
    }),
    lastArgType,
  );

  final String argSignature = map3(
    selectorComponents,
    argTypes,
    argNames,
    (String component, String argType, String argName) =>
        '$component:($argType)$argName',
  ).join(' ');
  return '- ($returnType)$argSignature';
}

void _writeHostApiDeclaration(Indent indent, Api api, ObjcOptions options) {
  final String apiName = _className(options.prefix, api.name);
  indent.writeln('@protocol $apiName');
  for (final Method func in api.methods) {
    final String returnTypeName =
        _objcTypeForDartType(options.prefix, func.returnType);

    String? lastArgName;
    String? lastArgType;
    String? returnType;
    if (func.isAsynchronous) {
      returnType = 'void';
      if (func.returnType.isVoid) {
        lastArgType = 'void(^)(FlutterError *_Nullable)';
        lastArgName = 'completion';
      } else {
        lastArgType =
            'void(^)($returnTypeName *_Nullable, FlutterError *_Nullable)';
        lastArgName = 'completion';
      }
    } else {
      returnType =
          func.returnType.isVoid ? 'void' : 'nullable $returnTypeName *';
      lastArgType = 'FlutterError *_Nullable *_Nonnull';
      lastArgName = 'error';
    }
    indent.writeln(_makeObjcSignature(
            func: func,
            options: options,
            returnType: returnType,
            lastArgName: lastArgName,
            lastArgType: lastArgType) +
        ';');
  }
  indent.writeln('@end');
  indent.writeln('');
  indent.writeln(
      'extern void ${apiName}Setup(id<FlutterBinaryMessenger> binaryMessenger, NSObject<$apiName> *_Nullable api);');
  indent.writeln('');
}

void _writeFlutterApiDeclaration(Indent indent, Api api, ObjcOptions options) {
  final String apiName = _className(options.prefix, api.name);
  indent.writeln('@interface $apiName : NSObject');
  indent.writeln(
      '- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger;');
  for (final Method func in api.methods) {
    final String returnType =
        _objcTypeForDartType(options.prefix, func.returnType);
    final String callbackType = _callbackForType(func.returnType, returnType);
    indent.writeln(_makeObjcSignature(
          func: func,
          options: options,
          returnType: 'void',
          lastArgName: 'completion',
          lastArgType: callbackType,
        ) +
        ';');
  }
  indent.writeln('@end');
}

/// Generates the ".h" file for the AST represented by [root] to [sink] with the
/// provided [options].
void generateObjcHeader(ObjcOptions options, Root root, StringSink sink) {
  final Indent indent = Indent(sink);
  if (options.copyrightHeader != null) {
    addLines(indent, options.copyrightHeader!, linePrefix: '// ');
  }
  indent.writeln('// $generatedCodeWarning');
  indent.writeln('// $seeAlsoWarning');
  indent.writeln('#import <Foundation/Foundation.h>');
  indent.writeln('@protocol FlutterBinaryMessenger;');
  indent.writeln('@protocol FlutterMessageCodec;');
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
    indent.writeln(
        '/// The codec used by ${_className(options.prefix, api.name)}.');
    indent.writeln(
        'NSObject<FlutterMessageCodec> *${_getCodecGetterName(options.prefix, api.name)}(void);');
    indent.addln('');
    if (api.location == ApiLocation.host) {
      _writeHostApiDeclaration(indent, api, options);
    } else if (api.location == ApiLocation.flutter) {
      _writeFlutterApiDeclaration(indent, api, options);
    }
  }

  indent.writeln('NS_ASSUME_NONNULL_END');
}

String _dictGetter(
    List<String> classNames, String dict, NamedType field, String? prefix) {
  if (classNames.contains(field.type.baseName)) {
    String className = field.type.baseName;
    if (prefix != null) {
      className = '$prefix$className';
    }
    return '[$className fromMap:$dict[@"${field.name}"]]';
  } else {
    return '$dict[@"${field.name}"]';
  }
}

String _dictValue(
    List<String> classNames, List<String> enumNames, NamedType field) {
  if (classNames.contains(field.type.baseName)) {
    return '(self.${field.name} ? [self.${field.name} toMap] : [NSNull null])';
  } else if (enumNames.contains(field.type.baseName)) {
    return '@(self.${field.name})';
  } else {
    return '(self.${field.name} ? self.${field.name} : [NSNull null])';
  }
}

String _getSelector(Method func, String lastSelectorComponent) =>
    _getSelectorComponents(func, lastSelectorComponent).join(':') + ':';

/// Returns an argument name that can be used in a context where it is possible to collide.
String _getSafeArgName(int count, NamedType arg) =>
    arg.name.isEmpty ? 'arg$count' : 'arg_${arg.name}';

void _writeHostApiSource(Indent indent, ObjcOptions options, Api api) {
  assert(api.location == ApiLocation.host);
  final String apiName = _className(options.prefix, api.name);
  indent.write(
      'void ${apiName}Setup(id<FlutterBinaryMessenger> binaryMessenger, NSObject<$apiName> *api) ');
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
        indent.writeln('binaryMessenger:binaryMessenger');
        indent.writeln(
            'codec:${_getCodecGetterName(options.prefix, api.name)}()];');
        indent.dec();
        indent.dec();

        indent.write('if (api) ');
        indent.scoped('{', '}', () {
          // TODO(gaaclarke): Incorporate this into _getSelectorComponents.
          final String lastSelectorComponent =
              func.isAsynchronous ? 'completion' : 'error';
          final String selector = _getSelector(func, lastSelectorComponent);
          indent.writeln(
              'NSCAssert([api respondsToSelector:@selector($selector)], @"$apiName api doesn\'t respond to @selector($selector)");');
          indent.write(
              '[channel setMessageHandler:^(id _Nullable message, FlutterReply callback) ');
          indent.scoped('{', '}];', () {
            final String returnType =
                _objcTypeForDartType(options.prefix, func.returnType);
            String syncCall;
            String? callSignature;
            final Iterable<String> selectorComponents =
                _getSelectorComponents(func, lastSelectorComponent);
            if (func.arguments.isEmpty) {
              syncCall = '[api ${selectorComponents.first}:&error]';
            } else {
              indent.writeln('NSArray *args = message;');
              final Iterable<String> argNames =
                  indexMap(func.arguments, _getSafeArgName);
              map3(wholeNumbers.take(func.arguments.length), argNames,
                  func.arguments, (int count, String argName, NamedType arg) {
                final String argType =
                    _objcTypeForDartType(options.prefix, arg.type);
                return '$argType *$argName = args[$count];';
              }).forEach(indent.writeln);
              callSignature =
                  map2(selectorComponents.take(argNames.length), argNames,
                      (String selectorComponent, String argName) {
                return '$selectorComponent:$argName';
              }).join(' ');
              syncCall = '[api $callSignature error:&error]';
            }
            if (func.isAsynchronous) {
              if (func.returnType.isVoid) {
                const String callback = 'callback(wrapResult(nil, error));';
                if (func.arguments.isEmpty) {
                  indent.writeScoped(
                      '[api ${selectorComponents.first}:^(FlutterError *_Nullable error) {',
                      '}];', () {
                    indent.writeln(callback);
                  });
                } else {
                  indent.writeScoped(
                      '[api $callSignature ${selectorComponents.last}:^(FlutterError *_Nullable error) {',
                      '}];', () {
                    indent.writeln(callback);
                  });
                }
              } else {
                const String callback = 'callback(wrapResult(output, error));';
                if (func.arguments.isEmpty) {
                  indent.writeScoped(
                      '[api ${selectorComponents.first}:^($returnType *_Nullable output, FlutterError *_Nullable error) {',
                      '}];', () {
                    indent.writeln(callback);
                  });
                } else {
                  indent.writeScoped(
                      '[api $callSignature ${selectorComponents.last}:^($returnType *_Nullable output, FlutterError *_Nullable error) {',
                      '}];', () {
                    indent.writeln(callback);
                  });
                }
              }
            } else {
              indent.writeln('FlutterError *error;');
              if (func.returnType.isVoid) {
                indent.writeln('$syncCall;');
                indent.writeln('callback(wrapResult(nil, error));');
              } else {
                indent.writeln('$returnType *output = $syncCall;');
                indent.writeln('callback(wrapResult(output, error));');
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
      '@property (nonatomic, strong) NSObject<FlutterBinaryMessenger> *binaryMessenger;');
  indent.writeln('@end');
  indent.addln('');
  indent.writeln('@implementation $apiName');
  indent.write(
      '- (instancetype)initWithBinaryMessenger:(NSObject<FlutterBinaryMessenger> *)binaryMessenger ');
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
    final String returnType =
        _objcTypeForDartType(options.prefix, func.returnType);
    final String callbackType = _callbackForType(func.returnType, returnType);

    String argNameFunc(int count, NamedType arg) => _getSafeArgName(count, arg);
    final Iterable<String> argNames = indexMap(func.arguments, argNameFunc);
    String sendArgument;
    if (func.arguments.isEmpty) {
      sendArgument = 'nil';
    } else {
      sendArgument = '@[${argNames.join(', ')}]';
    }
    indent.write(_makeObjcSignature(
      func: func,
      options: options,
      returnType: 'void',
      lastArgName: 'completion',
      lastArgType: callbackType,
      argNameFunc: argNameFunc,
    ));
    indent.scoped(' {', '}', () {
      indent.writeln('FlutterBasicMessageChannel *channel =');
      indent.inc();
      indent.writeln('[FlutterBasicMessageChannel');
      indent.inc();
      indent.writeln('messageChannelWithName:@"${makeChannelName(api, func)}"');
      indent.writeln('binaryMessenger:self.binaryMessenger');
      indent.writeln(
          'codec:${_getCodecGetterName(options.prefix, api.name)}()];');
      indent.dec();
      indent.dec();
      indent.write('[channel sendMessage:$sendArgument reply:^(id reply) ');
      indent.scoped('{', '}];', () {
        if (func.returnType.isVoid) {
          indent.writeln('completion(nil);');
        } else {
          indent.writeln('$returnType *output = reply;');
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

  if (options.copyrightHeader != null) {
    addLines(indent, options.copyrightHeader!, linePrefix: '// ');
  }
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
static NSDictionary<NSString *, id> *wrapResult(id result, FlutterError *error) {
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
    indent.writeln('+ ($className *)fromMap:(NSDictionary *)dict;');
    indent.writeln('- (NSDictionary *)toMap;');
    indent.writeln('@end');
  }

  indent.writeln('');

  for (final Class klass in root.classes) {
    final String className = _className(options.prefix, klass.name);
    indent.writeln('@implementation $className');
    indent.write('+ ($className *)fromMap:(NSDictionary *)dict ');
    indent.scoped('{', '}', () {
      const String resultName = 'result';
      indent.writeln('$className *$resultName = [[$className alloc] init];');
      for (final NamedType field in klass.fields) {
        if (enumNames.contains(field.type.baseName)) {
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
    indent.write('- (NSDictionary *)toMap ');
    indent.scoped('{', '}', () {
      indent.write('return [NSDictionary dictionaryWithObjectsAndKeys:');
      for (final NamedType field in klass.fields) {
        indent.add(
            _dictValue(classNames, enumNames, field) + ', @"${field.name}", ');
      }
      indent.addln('nil];');
    });
    indent.writeln('@end');
    indent.writeln('');
  }

  for (final Api api in root.apis) {
    final String codecName = _getCodecName(options.prefix, api.name);
    _writeCodec(indent, codecName, options, api);
    indent.addln('');
    if (api.location == ApiLocation.host) {
      _writeHostApiSource(indent, options, api);
    } else if (api.location == ApiLocation.flutter) {
      _writeFlutterApiSource(indent, options, api);
    }
  }
}

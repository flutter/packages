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
    final Iterable<dynamic>? copyrightHeader =
        map['copyrightHeader'] as Iterable<dynamic>?;
    return ObjcOptions(
      header: map['header'] as String?,
      prefix: map['prefix'] as String?,
      copyrightHeader: copyrightHeader?.cast<String>(),
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

/// Calculates the ObjC class name, possibly prefixed.
String _className(String? prefix, String className) {
  if (prefix != null) {
    return '$prefix$className';
  } else {
    return className;
  }
}

/// Calculates callback block signature for for async methods.
String _callbackForType(TypeDeclaration type, _ObjcPtr objcType) {
  return type.isVoid
      ? 'void(^)(NSError *_Nullable)'
      : 'void(^)(${objcType.ptr.trim()}, NSError *_Nullable)';
}

/// Represents an ObjC pointer (ex 'id', 'NSString *').
class _ObjcPtr {
  const _ObjcPtr({required this.baseName}) : hasAsterisk = baseName != 'id';
  final String baseName;
  final bool hasAsterisk;
  String get ptr => '$baseName${hasAsterisk ? ' *' : ' '}';
}

/// Maps between Dart types to ObjC pointer types (ex 'String' => 'NSString *').
const Map<String, _ObjcPtr> _objcTypeForDartTypeMap = <String, _ObjcPtr>{
  'bool': _ObjcPtr(baseName: 'NSNumber'),
  'int': _ObjcPtr(baseName: 'NSNumber'),
  'String': _ObjcPtr(baseName: 'NSString'),
  'double': _ObjcPtr(baseName: 'NSNumber'),
  'Uint8List': _ObjcPtr(baseName: 'FlutterStandardTypedData'),
  'Int32List': _ObjcPtr(baseName: 'FlutterStandardTypedData'),
  'Int64List': _ObjcPtr(baseName: 'FlutterStandardTypedData'),
  'Float64List': _ObjcPtr(baseName: 'FlutterStandardTypedData'),
  'List': _ObjcPtr(baseName: 'NSArray'),
  'Map': _ObjcPtr(baseName: 'NSDictionary'),
  'Object': _ObjcPtr(baseName: 'id'),
};

/// Converts list of [TypeDeclaration] to a code string representing the type
/// arguments for use in generics.
/// Example: ('FOO', ['Foo', 'Bar']) -> 'FOOFoo *, FOOBar *').
String _flattenTypeArguments(String? classPrefix, List<TypeDeclaration> args) {
  final String result = args
      .map<String>((TypeDeclaration e) =>
          _objcTypeForDartType(classPrefix, e).ptr.trim())
      .join(', ');
  return result;
}

String? _objcTypePtrForPrimitiveDartType(String? classPrefix, NamedType field) {
  return _objcTypeForDartTypeMap.containsKey(field.type.baseName)
      ? _objcTypeForDartType(classPrefix, field.type).ptr
      : null;
}

/// Returns the objc type for a dart [type], prepending the [classPrefix] for
/// generated classes.  For example:
/// _objcTypeForDartType(null, 'int') => 'NSNumber'.
_ObjcPtr _objcTypeForDartType(String? classPrefix, TypeDeclaration field) {
  return _objcTypeForDartTypeMap.containsKey(field.baseName)
      ? field.typeArguments.isEmpty
          ? _objcTypeForDartTypeMap[field.baseName]!
          : _ObjcPtr(
              baseName:
                  '${_objcTypeForDartTypeMap[field.baseName]!.baseName}<${_flattenTypeArguments(classPrefix, field.typeArguments)}>')
      : _ObjcPtr(baseName: _className(classPrefix, field.baseName));
}

/// Maps a type to a properties memory semantics (ie strong, copy).
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

bool _isNullable(HostDatatype hostDatatype, TypeDeclaration type) =>
    hostDatatype.datatype.contains('*') && type.isNullable;

/// Writes the method declaration for the initializer.
///
/// Example '+ (instancetype)makeWithFoo:(NSString *)foo'
void _writeInitializerDeclaration(Indent indent, Class klass,
    List<Class> classes, List<Enum> enums, String? prefix) {
  final List<String> enumNames = enums.map((Enum x) => x.name).toList();
  indent.write('+ (instancetype)makeWith');
  bool isFirst = true;
  indent.nest(2, () {
    for (final NamedType field in klass.fields) {
      final String label = isFirst ? _capitalize(field.name) : field.name;
      final void Function(String) printer = isFirst
          ? indent.add
          : (String x) {
              indent.addln('');
              indent.write(x);
            };
      isFirst = false;
      final HostDatatype hostDatatype = getHostDatatype(field, classes, enums,
          (NamedType x) => _objcTypePtrForPrimitiveDartType(prefix, x),
          customResolver: enumNames.contains(field.type.baseName)
              ? (String x) => _className(prefix, x)
              : (String x) => '${_className(prefix, x)} *');
      final String nullable =
          _isNullable(hostDatatype, field.type) ? 'nullable ' : '';
      printer('$label:($nullable${hostDatatype.datatype})${field.name}');
    }
  });
}

/// Writes the class declaration for a data class.
///
/// Example:
/// @interface Foo : NSObject
/// @property (nonatomic, copy) NSString *bar;
/// @end
void _writeClassDeclarations(
    Indent indent, List<Class> classes, List<Enum> enums, String? prefix) {
  final List<String> enumNames = enums.map((Enum x) => x.name).toList();
  for (final Class klass in classes) {
    indent.writeln('@interface ${_className(prefix, klass.name)} : NSObject');
    if (klass.fields.isNotEmpty) {
      if (klass.fields
          .map((NamedType e) => !e.type.isNullable)
          .any((bool e) => e)) {
        indent.writeln(
            '/// `init` unavailable to enforce nonnull fields, see the `make` class method.');
        indent.writeln('- (instancetype)init NS_UNAVAILABLE;');
      }
      _writeInitializerDeclaration(indent, klass, classes, enums, prefix);
      indent.addln(';');
    }
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
          _isNullable(hostDatatype, field.type) ? ', nullable' : '';
      indent.writeln(
          '@property(nonatomic, $propertyType$nullability) ${hostDatatype.datatype} ${field.name};');
    }
    indent.writeln('@end');
    indent.writeln('');
  }
}

/// Generates the name of the codec that will be generated.
String _getCodecName(String? prefix, String className) =>
    '${_className(prefix, className)}Codec';

/// Generates the name of the function for accessing the codec instance used by
/// the api class named [className].
String _getCodecGetterName(String? prefix, String className) =>
    '${_className(prefix, className)}GetCodec';

/// Writes the codec that will be used for encoding messages for the [api].
///
/// Example:
/// @interface FooHostApiCodecReader : FlutterStandardReader
/// ...
/// @interface FooHostApiCodecWriter : FlutterStandardWriter
/// ...
/// @interface FooHostApiCodecReaderWriter : FlutterStandardReaderWriter
/// ...
/// NSObject<FlutterMessageCodec> *FooHostApiCodecGetCodec() {...}
void _writeCodec(
    Indent indent, String name, ObjcOptions options, Api api, Root root) {
  final String readerWriterName = '${name}ReaderWriter';
  final String readerName = '${name}Reader';
  final String writerName = '${name}Writer';
  indent.writeln('@interface $readerName : FlutterStandardReader');
  indent.writeln('@end');
  indent.writeln('@implementation $readerName');
  if (getCodecClasses(api, root).isNotEmpty) {
    indent.writeln('- (nullable id)readValueOfType:(UInt8)type ');
    indent.scoped('{', '}', () {
      indent.write('switch (type) ');
      indent.scoped('{', '}', () {
        for (final EnumeratedClass customClass in getCodecClasses(api, root)) {
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
  if (getCodecClasses(api, root).isNotEmpty) {
    indent.writeln('- (void)writeValue:(id)value ');
    indent.scoped('{', '}', () {
      for (final EnumeratedClass customClass in getCodecClasses(api, root)) {
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
\tstatic dispatch_once_t sPred = 0;
\tstatic FlutterStandardMessageCodec *sSharedObject = nil;
\tdispatch_once(&sPred, ^{
\t\t$readerWriterName *readerWriter = [[$readerWriterName alloc] init];
\t\tsSharedObject = [FlutterStandardMessageCodec codecWithReaderWriter:readerWriter];
\t});
\treturn sSharedObject;
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
      final _ObjcPtr argType = _objcTypeForDartType(options.prefix, arg.type);
      return '$nullable${argType.ptr.trim()}';
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

/// Writes the declaration for an host [Api].
///
/// Example:
/// @protocol Foo
/// - (NSInteger)add:(NSInteger)x to:(NSInteger)y error:(NSError**)error;
/// @end
///
/// extern void FooSetup(id<FlutterBinaryMessenger> binaryMessenger, NSObject<Foo> *_Nullable api);
void _writeHostApiDeclaration(Indent indent, Api api, ObjcOptions options) {
  final String apiName = _className(options.prefix, api.name);
  indent.writeln('@protocol $apiName');
  for (final Method func in api.methods) {
    final _ObjcPtr returnTypeName =
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
            'void(^)(${returnTypeName.ptr}_Nullable, FlutterError *_Nullable)';
        lastArgName = 'completion';
      }
    } else {
      returnType = func.returnType.isVoid
          ? 'void'
          : 'nullable ${returnTypeName.ptr.trim()}';
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

/// Writes the declaration for an flutter [Api].
///
/// Example:
///
/// @interface Foo : NSObject
/// - (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger;
/// - (void)add:(NSInteger)x to:(NSInteger)y completion:(void(^)(NSError *, NSInteger result)completion;
/// @end
void _writeFlutterApiDeclaration(Indent indent, Api api, ObjcOptions options) {
  final String apiName = _className(options.prefix, api.name);
  indent.writeln('@interface $apiName : NSObject');
  indent.writeln(
      '- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger;');
  for (final Method func in api.methods) {
    final _ObjcPtr returnType =
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

  void writeHeader() {
    if (options.copyrightHeader != null) {
      addLines(indent, options.copyrightHeader!, linePrefix: '// ');
    }
    indent.writeln('// $generatedCodeWarning');
    indent.writeln('// $seeAlsoWarning');
  }

  void writeImports() {
    indent.writeln('#import <Foundation/Foundation.h>');
  }

  void writeForwardDeclarations() {
    indent.writeln('@protocol FlutterBinaryMessenger;');
    indent.writeln('@protocol FlutterMessageCodec;');
    indent.writeln('@class FlutterError;');
    indent.writeln('@class FlutterStandardTypedData;');
  }

  void writeEnum(Enum anEnum) {
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

  writeHeader();
  writeImports();
  writeForwardDeclarations();
  indent.writeln('');

  indent.writeln('NS_ASSUME_NONNULL_BEGIN');

  for (final Enum anEnum in root.enums) {
    indent.writeln('');
    writeEnum(anEnum);
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
    return '[$className fromMap:GetNullableObject($dict, @"${field.name}")]';
  } else {
    return 'GetNullableObject($dict, @"${field.name}")';
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

/// Writes the definition code for a host [Api].
/// See also: [_writeHostApiDeclaration]
void _writeHostApiSource(Indent indent, ObjcOptions options, Api api) {
  assert(api.location == ApiLocation.host);
  final String apiName = _className(options.prefix, api.name);

  void writeChannelAllocation(Method func, String varName) {
    indent.writeln('FlutterBasicMessageChannel *$varName =');
    indent.inc();
    indent.writeln('[FlutterBasicMessageChannel');
    indent.inc();
    indent.writeln('messageChannelWithName:@"${makeChannelName(api, func)}"');
    indent.writeln('binaryMessenger:binaryMessenger');
    indent
        .writeln('codec:${_getCodecGetterName(options.prefix, api.name)}()];');
    indent.dec();
    indent.dec();
  }

  void writeChannelApiBinding(Method func, String channel) {
    void unpackArgs(String variable, Iterable<String> argNames) {
      indent.writeln('NSArray *args = $variable;');
      map3(wholeNumbers.take(func.arguments.length), argNames, func.arguments,
          (int count, String argName, NamedType arg) {
        final _ObjcPtr argType = _objcTypeForDartType(options.prefix, arg.type);
        return '${argType.ptr}$argName = args[$count];';
      }).forEach(indent.writeln);
    }

    void writeAsyncBindings(Iterable<String> selectorComponents,
        String callSignature, _ObjcPtr returnType) {
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
              '[api ${selectorComponents.first}:^(${returnType.ptr}_Nullable output, FlutterError *_Nullable error) {',
              '}];', () {
            indent.writeln(callback);
          });
        } else {
          indent.writeScoped(
              '[api $callSignature ${selectorComponents.last}:^(${returnType.ptr}_Nullable output, FlutterError *_Nullable error) {',
              '}];', () {
            indent.writeln(callback);
          });
        }
      }
    }

    void writeSyncBindings(String call, _ObjcPtr returnType) {
      indent.writeln('FlutterError *error;');
      if (func.returnType.isVoid) {
        indent.writeln('$call;');
        indent.writeln('callback(wrapResult(nil, error));');
      } else {
        indent.writeln('${returnType.ptr}output = $call;');
        indent.writeln('callback(wrapResult(output, error));');
      }
    }

    // TODO(gaaclarke): Incorporate this into _getSelectorComponents.
    final String lastSelectorComponent =
        func.isAsynchronous ? 'completion' : 'error';
    final String selector = _getSelector(func, lastSelectorComponent);
    indent.writeln(
        'NSCAssert([api respondsToSelector:@selector($selector)], @"$apiName api (%@) doesn\'t respond to @selector($selector)", api);');
    indent.write(
        '[$channel setMessageHandler:^(id _Nullable message, FlutterReply callback) ');
    indent.scoped('{', '}];', () {
      final _ObjcPtr returnType =
          _objcTypeForDartType(options.prefix, func.returnType);
      final Iterable<String> selectorComponents =
          _getSelectorComponents(func, lastSelectorComponent);
      final Iterable<String> argNames =
          indexMap(func.arguments, _getSafeArgName);
      final String callSignature =
          map2(selectorComponents.take(argNames.length), argNames,
              (String selectorComponent, String argName) {
        return '$selectorComponent:$argName';
      }).join(' ');
      if (func.arguments.isNotEmpty) {
        unpackArgs('message', argNames);
      }
      if (func.isAsynchronous) {
        writeAsyncBindings(selectorComponents, callSignature, returnType);
      } else {
        final String syncCall = func.arguments.isEmpty
            ? '[api ${selectorComponents.first}:&error]'
            : '[api $callSignature error:&error]';
        writeSyncBindings(syncCall, returnType);
      }
    });
  }

  const String channelName = 'channel';
  indent.write(
      'void ${apiName}Setup(id<FlutterBinaryMessenger> binaryMessenger, NSObject<$apiName> *api) ');
  indent.scoped('{', '}', () {
    for (final Method func in api.methods) {
      indent.write('');
      indent.scoped('{', '}', () {
        writeChannelAllocation(func, channelName);
        indent.write('if (api) ');
        indent.scoped('{', '}', () {
          writeChannelApiBinding(func, channelName);
        });
        indent.write('else ');
        indent.scoped('{', '}', () {
          indent.writeln('[$channelName setMessageHandler:nil];');
        });
      });
    }
  });
}

/// Writes the definition code for a flutter [Api].
/// See also: [_writeFlutterApiDeclaration]
void _writeFlutterApiSource(Indent indent, ObjcOptions options, Api api) {
  assert(api.location == ApiLocation.flutter);
  final String apiName = _className(options.prefix, api.name);

  void writeExtension() {
    indent.writeln('@interface $apiName ()');
    indent.writeln(
        '@property (nonatomic, strong) NSObject<FlutterBinaryMessenger> *binaryMessenger;');
    indent.writeln('@end');
  }

  void writeInitializer() {
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
  }

  void writeMethod(Method func) {
    final _ObjcPtr returnType =
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
          indent.writeln('${returnType.ptr}output = reply;');
          indent.writeln('completion(output, nil);');
        }
      });
    });
  }

  writeExtension();
  indent.addln('');
  indent.writeln('@implementation $apiName');
  indent.addln('');
  writeInitializer();
  api.methods.forEach(writeMethod);
  indent.writeln('@end');
}

/// Generates the ".m" file for the AST represented by [root] to [sink] with the
/// provided [options].
void generateObjcSource(ObjcOptions options, Root root, StringSink sink) {
  final Indent indent = Indent(sink);
  final List<String> classNames =
      root.classes.map((Class x) => x.name).toList();
  final List<String> enumNames = root.enums.map((Enum x) => x.name).toList();

  void writeHeader() {
    if (options.copyrightHeader != null) {
      addLines(indent, options.copyrightHeader!, linePrefix: '// ');
    }
    indent.writeln('// $generatedCodeWarning');
    indent.writeln('// $seeAlsoWarning');
  }

  void writeImports() {
    indent.writeln('#import "${options.header}"');
    indent.writeln('#import <Flutter/Flutter.h>');
  }

  void writeArcEnforcer() {
    indent.writeln('#if !__has_feature(objc_arc)');
    indent.writeln('#error File requires ARC to be enabled.');
    indent.writeln('#endif');
  }

  void writeHelperFunctions() {
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
    indent.format('''
static id GetNullableObject(NSDictionary* dict, id key) {
\tid result = dict[key];
\treturn (result == [NSNull null]) ? nil : result;
}
''');
  }

  void writeDataClassExtension(Class klass) {
    final String className = _className(options.prefix, klass.name);
    indent.writeln('@interface $className ()');
    indent.writeln('+ ($className *)fromMap:(NSDictionary *)dict;');
    indent.writeln('- (NSDictionary *)toMap;');
    indent.writeln('@end');
  }

  void writeDataClassImplementation(Class klass) {
    final String className = _className(options.prefix, klass.name);
    void writeInitializer() {
      _writeInitializerDeclaration(
          indent, klass, root.classes, root.enums, options.prefix);
      indent.writeScoped(' {', '}', () {
        const String result = 'pigeonResult';
        indent.writeln('$className* $result = [[$className alloc] init];');
        for (final NamedType field in klass.fields) {
          indent.writeln('$result.${field.name} = ${field.name};');
        }
        indent.writeln('return $result;');
      });
    }

    void writeFromMap() {
      indent.write('+ ($className *)fromMap:(NSDictionary *)dict ');
      indent.scoped('{', '}', () {
        const String resultName = 'pigeonResult';
        indent.writeln('$className *$resultName = [[$className alloc] init];');
        for (final NamedType field in klass.fields) {
          if (enumNames.contains(field.type.baseName)) {
            indent.writeln(
                '$resultName.${field.name} = [${_dictGetter(classNames, 'dict', field, options.prefix)} integerValue];');
          } else {
            indent.writeln(
                '$resultName.${field.name} = ${_dictGetter(classNames, 'dict', field, options.prefix)};');
            if (!field.type.isNullable) {
              indent
                  .writeln('NSAssert($resultName.${field.name} != nil, @"");');
            }
          }
        }
        indent.writeln('return $resultName;');
      });
    }

    void writeToMap() {
      indent.write('- (NSDictionary *)toMap ');
      indent.scoped('{', '}', () {
        indent.write('return [NSDictionary dictionaryWithObjectsAndKeys:');
        for (final NamedType field in klass.fields) {
          indent.add(_dictValue(classNames, enumNames, field) +
              ', @"${field.name}", ');
        }
        indent.addln('nil];');
      });
    }

    indent.writeln('@implementation $className');
    writeInitializer();
    writeFromMap();
    writeToMap();
    indent.writeln('@end');
  }

  void writeApi(Api api) {
    final String codecName = _getCodecName(options.prefix, api.name);
    _writeCodec(indent, codecName, options, api, root);
    indent.addln('');
    if (api.location == ApiLocation.host) {
      _writeHostApiSource(indent, options, api);
    } else if (api.location == ApiLocation.flutter) {
      _writeFlutterApiSource(indent, options, api);
    }
  }

  writeHeader();
  writeImports();
  indent.writeln('');
  writeArcEnforcer();
  indent.addln('');
  writeHelperFunctions();
  indent.addln('');
  root.classes.forEach(writeDataClassExtension);
  indent.writeln('');
  for (final Class klass in root.classes) {
    writeDataClassImplementation(klass);
    indent.writeln('');
  }
  root.apis.forEach(writeApi);
}

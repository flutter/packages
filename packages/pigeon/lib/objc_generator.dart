// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'ast.dart';
import 'functional.dart';
import 'generator.dart';
import 'generator_tools.dart';
import 'pigeon_lib.dart' show Error, TaskQueueType;

/// Documentation comment open symbol.
const String _docCommentPrefix = '///';

/// Documentation comment spec.
const DocumentCommentSpecification _docCommentSpec =
    DocumentCommentSpecification(_docCommentPrefix);

/// Options that control how Objective-C code will be generated.
class ObjcOptions {
  /// Parametric constructor for ObjcOptions.
  const ObjcOptions({
    this.headerIncludePath,
    this.prefix,
    this.copyrightHeader,
  });

  /// The path to the header that will get placed in the source filed (example:
  /// "foo.h").
  final String? headerIncludePath;

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
      headerIncludePath: map['header'] as String?,
      prefix: map['prefix'] as String?,
      copyrightHeader: copyrightHeader?.cast<String>(),
    );
  }

  /// Converts a [ObjcOptions] to a Map representation where:
  /// `x = ObjcOptions.fromMap(x.toMap())`.
  Map<String, Object> toMap() {
    final Map<String, Object> result = <String, Object>{
      if (headerIncludePath != null) 'header': headerIncludePath!,
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

/// Class that manages all Objc code generation.
class ObjcGenerator extends Generator<OutputFileOptions<ObjcOptions>> {
  /// Instantiates a Objc Generator.
  const ObjcGenerator();

  /// Generates Objc file of type specified in [generatorOptions]
  @override
  void generate(
    OutputFileOptions<ObjcOptions> generatorOptions,
    Root root,
    StringSink sink, {
    required String dartPackageName,
  }) {
    if (generatorOptions.fileType == FileType.header) {
      const ObjcHeaderGenerator().generate(
        generatorOptions.languageOptions,
        root,
        sink,
        dartPackageName: dartPackageName,
      );
    } else if (generatorOptions.fileType == FileType.source) {
      const ObjcSourceGenerator().generate(
        generatorOptions.languageOptions,
        root,
        sink,
        dartPackageName: dartPackageName,
      );
    }
  }
}

/// Generates Objc .h file.
class ObjcHeaderGenerator extends StructuredGenerator<ObjcOptions> {
  /// Constructor.
  const ObjcHeaderGenerator();

  @override
  void writeFilePrologue(
    ObjcOptions generatorOptions,
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
    ObjcOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.writeln('#import <Foundation/Foundation.h>');
    indent.newln();

    indent.writeln('@protocol FlutterBinaryMessenger;');
    indent.writeln('@protocol FlutterMessageCodec;');
    indent.writeln('@class FlutterError;');
    indent.writeln('@class FlutterStandardTypedData;');
    indent.newln();
    indent.writeln('NS_ASSUME_NONNULL_BEGIN');
  }

  @override
  void writeEnum(
    ObjcOptions generatorOptions,
    Root root,
    Indent indent,
    Enum anEnum, {
    required String dartPackageName,
  }) {
    final String enumName =
        _enumName(anEnum.name, prefix: generatorOptions.prefix);
    indent.newln();
    addDocumentationComments(
        indent, anEnum.documentationComments, _docCommentSpec);

    indent.write('typedef NS_ENUM(NSUInteger, $enumName) ');
    indent.addScoped('{', '};', () {
      enumerate(anEnum.members, (int index, final EnumMember member) {
        addDocumentationComments(
            indent, member.documentationComments, _docCommentSpec);
        // Capitalized first letter to ensure Swift compatibility
        indent.writeln(
            '$enumName${member.name[0].toUpperCase()}${member.name.substring(1)} = $index,');
      });
    });
    _writeEnumWrapper(indent, enumName);
  }

  void _writeEnumWrapper(Indent indent, String enumName) {
    indent.newln();
    indent.writeln('/// Wrapper for $enumName to allow for nullability.');
    indent.writeln(
        '@interface ${_enumName(enumName, prefix: '', box: true)} : NSObject');
    indent.writeln('@property(nonatomic, assign) $enumName value;');
    indent.writeln('- (instancetype)initWithValue:($enumName)value;');
    indent.writeln('@end');
  }

  @override
  void writeDataClasses(
    ObjcOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.newln();
    for (final Class classDefinition in root.classes) {
      indent.writeln(
          '@class ${_className(generatorOptions.prefix, classDefinition.name)};');
    }
    indent.newln();
    super.writeDataClasses(
      generatorOptions,
      root,
      indent,
      dartPackageName: dartPackageName,
    );
  }

  @override
  void writeDataClass(
    ObjcOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    final List<Class> classes = root.classes;
    final List<Enum> enums = root.enums;
    final String? prefix = generatorOptions.prefix;

    addDocumentationComments(
        indent, classDefinition.documentationComments, _docCommentSpec);

    indent.writeln(
        '@interface ${_className(prefix, classDefinition.name)} : NSObject');
    if (getFieldsInSerializationOrder(classDefinition).isNotEmpty) {
      if (getFieldsInSerializationOrder(classDefinition)
          .map((NamedType e) => !e.type.isNullable)
          .any((bool e) => e)) {
        indent.writeln(
            '$_docCommentPrefix `init` unavailable to enforce nonnull fields, see the `make` class method.');
        indent.writeln('- (instancetype)init NS_UNAVAILABLE;');
      }
      _writeObjcSourceClassInitializerDeclaration(
        indent,
        generatorOptions,
        root,
        classDefinition,
        classes,
        enums,
        prefix,
      );
      indent.addln(';');
    }
    for (final NamedType field
        in getFieldsInSerializationOrder(classDefinition)) {
      final HostDatatype hostDatatype = getFieldHostDatatype(
          field,
          (TypeDeclaration x) => _objcTypeStringForPrimitiveDartType(prefix, x,
              beforeString: true),
          customResolver: field.type.isEnum
              ? (String x) => _enumName(x, prefix: prefix)
              : (String x) => '${_className(prefix, x)} *');
      late final String propertyType;
      addDocumentationComments(
          indent, field.documentationComments, _docCommentSpec);
      propertyType = _propertyTypeForDartType(field.type,
          isNullable: field.type.isNullable, isEnum: field.type.isEnum);
      final String nullability = field.type.isNullable ? ', nullable' : '';
      final String fieldType = field.type.isEnum && field.type.isNullable
          ? _enumName(field.type.baseName,
              suffix: ' *',
              prefix: generatorOptions.prefix,
              box: field.type.isNullable)
          : hostDatatype.datatype;
      indent.writeln(
          '@property(nonatomic, $propertyType$nullability) $fieldType ${field.name};');
    }
    indent.writeln('@end');
    indent.newln();
  }

  @override
  void writeClassEncode(
    ObjcOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {}

  @override
  void writeClassDecode(
    ObjcOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {}

  @override
  void writeApis(
    ObjcOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    super.writeApis(generatorOptions, root, indent,
        dartPackageName: dartPackageName);
    indent.writeln('NS_ASSUME_NONNULL_END');
  }

  @override
  void writeFlutterApi(
    ObjcOptions generatorOptions,
    Root root,
    Indent indent,
    Api api, {
    required String dartPackageName,
  }) {
    indent.writeln(
        '$_docCommentPrefix The codec used by ${_className(generatorOptions.prefix, api.name)}.');
    indent.writeln(
        'NSObject<FlutterMessageCodec> *${_getCodecGetterName(generatorOptions.prefix, api.name)}(void);');
    indent.newln();
    final String apiName = _className(generatorOptions.prefix, api.name);
    addDocumentationComments(
        indent, api.documentationComments, _docCommentSpec);

    indent.writeln('@interface $apiName : NSObject');
    indent.writeln(
        '- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger;');
    for (final Method func in api.methods) {
      final _ObjcType returnType = _objcTypeForDartType(
        generatorOptions.prefix, func.returnType,
        // Nullability is required since the return must be nil if NSError is set.
        forceNullability: true,
      );
      final String callbackType =
          _callbackForType(func.returnType, returnType, generatorOptions);
      addDocumentationComments(
          indent, func.documentationComments, _docCommentSpec);

      indent.writeln('${_makeObjcSignature(
        func: func,
        options: generatorOptions,
        returnType: 'void',
        lastArgName: 'completion',
        lastArgType: callbackType,
      )};');
    }
    indent.writeln('@end');
    indent.newln();
  }

  @override
  void writeHostApi(
    ObjcOptions generatorOptions,
    Root root,
    Indent indent,
    Api api, {
    required String dartPackageName,
  }) {
    indent.writeln(
        '$_docCommentPrefix The codec used by ${_className(generatorOptions.prefix, api.name)}.');
    indent.writeln(
        'NSObject<FlutterMessageCodec> *${_getCodecGetterName(generatorOptions.prefix, api.name)}(void);');
    indent.newln();
    final String apiName = _className(generatorOptions.prefix, api.name);
    addDocumentationComments(
        indent, api.documentationComments, _docCommentSpec);

    indent.writeln('@protocol $apiName');
    for (final Method func in api.methods) {
      final _ObjcType returnTypeName = _objcTypeForDartType(
        generatorOptions.prefix,
        func.returnType,
        // Nullability is required since the return must be nil if NSError is
        // set.
        forceNullability: true,
      );

      String? lastArgName;
      String? lastArgType;
      String? returnType;
      final String enumReturnType = _enumName(
        returnTypeName.baseName,
        suffix: ' *_Nullable',
        prefix: generatorOptions.prefix,
        box: true,
      );
      if (func.isAsynchronous) {
        returnType = 'void';
        lastArgName = 'completion';
        if (func.returnType.isVoid) {
          lastArgType = 'void (^)(FlutterError *_Nullable)';
        } else if (func.returnType.isEnum) {
          lastArgType = 'void (^)($enumReturnType, FlutterError *_Nullable)';
        } else {
          lastArgType =
              'void (^)(${returnTypeName.beforeString}_Nullable, FlutterError *_Nullable)';
        }
      } else {
        if (func.returnType.isVoid) {
          returnType = 'void';
        } else if (func.returnType.isEnum) {
          returnType = enumReturnType;
        } else {
          returnType = 'nullable $returnTypeName';
        }

        lastArgType = 'FlutterError *_Nullable *_Nonnull';
        lastArgName = 'error';
      }
      final List<String> generatorComments = <String>[];
      if (!func.returnType.isNullable &&
          !func.returnType.isVoid &&
          !func.isAsynchronous) {
        generatorComments.add(' @return `nil` only when `error != nil`.');
      }
      addDocumentationComments(
          indent, func.documentationComments, _docCommentSpec,
          generatorComments: generatorComments);

      final String signature = _makeObjcSignature(
        func: func,
        options: generatorOptions,
        returnType: returnType,
        lastArgName: lastArgName,
        lastArgType: lastArgType,
      );
      indent.writeln('$signature;');
    }
    indent.writeln('@end');
    indent.newln();
    indent.writeln(
        'extern void SetUp$apiName(id<FlutterBinaryMessenger> binaryMessenger, NSObject<$apiName> *_Nullable api);');
    indent.newln();
  }
}

/// Generates Objc .m file.
class ObjcSourceGenerator extends StructuredGenerator<ObjcOptions> {
  /// Constructor.
  const ObjcSourceGenerator();

  @override
  void writeFilePrologue(
    ObjcOptions generatorOptions,
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
    ObjcOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.writeln('#import "${generatorOptions.headerIncludePath}"');
    indent.newln();
    indent.writeln('#if TARGET_OS_OSX');
    indent.writeln('#import <FlutterMacOS/FlutterMacOS.h>');
    indent.writeln('#else');
    indent.writeln('#import <Flutter/Flutter.h>');
    indent.writeln('#endif');
    indent.newln();

    indent.writeln('#if !__has_feature(objc_arc)');
    indent.writeln('#error File requires ARC to be enabled.');
    indent.writeln('#endif');
    indent.newln();
  }

  @override
  void writeEnum(
    ObjcOptions generatorOptions,
    Root root,
    Indent indent,
    Enum anEnum, {
    required String dartPackageName,
  }) {
    final String enumName =
        _enumName(anEnum.name, prefix: generatorOptions.prefix);
    indent.newln();
    addDocumentationComments(
        indent, anEnum.documentationComments, _docCommentSpec);
    indent.writeln(
        '@implementation ${_enumName(enumName, prefix: '', box: true)}');
    indent.writeScoped('- (instancetype)initWithValue:($enumName)value {', '}',
        () {
      indent.writeln('self = [super init];');
      indent.writeScoped('if (self) {', '}', () {
        indent.writeln('_value = value;');
      });

      indent.writeln('return self;');
    });
    indent.writeln('@end');
  }

  @override
  void writeDataClasses(
    ObjcOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    for (final Class classDefinition in root.classes) {
      _writeObjcSourceDataClassExtension(
          generatorOptions, indent, classDefinition);
    }
    indent.newln();
    super.writeDataClasses(
      generatorOptions,
      root,
      indent,
      dartPackageName: dartPackageName,
    );
  }

  @override
  void writeDataClass(
    ObjcOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    final Set<String> customClassNames =
        root.classes.map((Class x) => x.name).toSet();
    final Set<String> customEnumNames =
        root.enums.map((Enum x) => x.name).toSet();
    final String className =
        _className(generatorOptions.prefix, classDefinition.name);

    indent.writeln('@implementation $className');
    _writeObjcSourceClassInitializer(generatorOptions, root, indent,
        classDefinition, customClassNames, customEnumNames, className);
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
    indent.writeln('@end');
    indent.newln();
  }

  @override
  void writeClassEncode(
    ObjcOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    indent.write('- (NSArray *)toList ');
    indent.addScoped('{', '}', () {
      indent.write('return');
      indent.addScoped(' @[', '];', () {
        for (final NamedType field in classDefinition.fields) {
          indent.writeln('${_arrayValue(field)},');
        }
      });
    });
  }

  @override
  void writeClassDecode(
    ObjcOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    final String className =
        _className(generatorOptions.prefix, classDefinition.name);
    indent.write('+ ($className *)fromList:(NSArray *)list ');
    indent.addScoped('{', '}', () {
      const String resultName = 'pigeonResult';
      indent.writeln('$className *$resultName = [[$className alloc] init];');
      enumerate(getFieldsInSerializationOrder(classDefinition),
          (int index, final NamedType field) {
        final bool isEnumType = field.type.isEnum;
        final String valueGetter =
            _listGetter('list', field, index, generatorOptions.prefix);
        final String? primitiveExtractionMethod =
            _nsnumberExtractionMethod(field.type);
        final String ivarValueExpression;
        if (primitiveExtractionMethod != null) {
          ivarValueExpression = '[$valueGetter $primitiveExtractionMethod]';
        } else if (isEnumType) {
          indent.writeln('NSNumber *${field.name}AsNumber = $valueGetter;');
          indent.writeln(
              '${_enumName(field.type.baseName, suffix: ' *', prefix: generatorOptions.prefix, box: true)}${field.name} = ${field.name}AsNumber == nil ? nil : [[${_enumName(field.type.baseName, prefix: generatorOptions.prefix, box: true)} alloc] initWithValue:[${field.name}AsNumber integerValue]];');
          ivarValueExpression = field.name;
        } else {
          ivarValueExpression = valueGetter;
        }
        indent.writeln('$resultName.${field.name} = $ivarValueExpression;');
      });
      indent.writeln('return $resultName;');
    });

    indent.write('+ (nullable $className *)nullableFromList:(NSArray *)list ');
    indent.addScoped('{', '}', () {
      indent.writeln('return (list) ? [$className fromList:list] : nil;');
    });
  }

  void _writeCodecAndGetter(
      ObjcOptions generatorOptions, Root root, Indent indent, Api api) {
    final String codecName = _getCodecName(generatorOptions.prefix, api.name);
    if (getCodecClasses(api, root).isNotEmpty) {
      _writeCodec(indent, codecName, generatorOptions, api, root);
      indent.newln();
    }
    _writeCodecGetter(indent, codecName, generatorOptions, api, root);
    indent.newln();
  }

  @override
  void writeFlutterApi(
    ObjcOptions generatorOptions,
    Root root,
    Indent indent,
    AstFlutterApi api, {
    required String dartPackageName,
  }) {
    final String apiName = _className(generatorOptions.prefix, api.name);

    _writeCodecAndGetter(generatorOptions, root, indent, api);

    _writeExtension(indent, apiName);
    indent.newln();
    indent.writeln('@implementation $apiName');
    indent.newln();
    _writeInitializer(indent);
    for (final Method func in api.methods) {
      _writeMethod(
        generatorOptions,
        root,
        indent,
        api,
        func,
        dartPackageName: dartPackageName,
      );
    }
    indent.writeln('@end');
    indent.newln();
  }

  @override
  void writeHostApi(
    ObjcOptions generatorOptions,
    Root root,
    Indent indent,
    AstHostApi api, {
    required String dartPackageName,
  }) {
    final String apiName = _className(generatorOptions.prefix, api.name);

    _writeCodecAndGetter(generatorOptions, root, indent, api);

    const String channelName = 'channel';
    indent.write(
        'void SetUp$apiName(id<FlutterBinaryMessenger> binaryMessenger, NSObject<$apiName> *api) ');
    indent.addScoped('{', '}', () {
      for (final Method func in api.methods) {
        addDocumentationComments(
            indent, func.documentationComments, _docCommentSpec);

        indent.writeScoped('{', '}', () {
          String? taskQueue;
          if (func.taskQueueType != TaskQueueType.serial) {
            taskQueue = 'taskQueue';
            indent.writeln(
                'NSObject<FlutterTaskQueue> *$taskQueue = [binaryMessenger makeBackgroundTaskQueue];');
          }
          _writeChannelAllocation(
            generatorOptions,
            indent,
            api,
            func,
            channelName,
            taskQueue,
            dartPackageName: dartPackageName,
          );
          indent.write('if (api) ');
          indent.addScoped('{', '}', () {
            _writeChannelApiBinding(
                generatorOptions, root, indent, apiName, func, channelName);
          }, addTrailingNewline: false);
          indent.add(' else ');
          indent.addScoped('{', '}', () {
            indent.writeln('[$channelName setMessageHandler:nil];');
          });
        });
      }
    });
  }

  @override
  void writeGeneralUtilities(
    ObjcOptions generatorOptions,
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
      _writeWrapError(indent);
      indent.newln();
    }
    if (hasFlutterApi) {
      _writeCreateConnectionError(indent);
      indent.newln();
    }
    _writeGetNullableObjectAtIndex(indent);
  }

  void _writeWrapError(Indent indent) {
    indent.format('''
static NSArray *wrapResult(id result, FlutterError *error) {
\tif (error) {
\t\treturn @[
\t\t\terror.code ?: [NSNull null], error.message ?: [NSNull null], error.details ?: [NSNull null]
\t\t];
\t}
\treturn @[ result ?: [NSNull null] ];
}''');
  }

  void _writeGetNullableObjectAtIndex(Indent indent) {
    indent.format('''
static id GetNullableObjectAtIndex(NSArray *array, NSInteger key) {
\tid result = array[key];
\treturn (result == [NSNull null]) ? nil : result;
}''');
  }

  void _writeCreateConnectionError(Indent indent) {
    indent.format('''
static FlutterError *createConnectionError(NSString *channelName) {
\treturn [FlutterError errorWithCode:@"channel-error" message:[NSString stringWithFormat:@"%@/%@/%@", @"Unable to establish connection on channel: '", channelName, @"'."] details:@""];
}''');
  }

  void _writeChannelApiBinding(ObjcOptions generatorOptions, Root root,
      Indent indent, String apiName, Method func, String channel) {
    void unpackArgs(String variable) {
      indent.writeln('NSArray *args = $variable;');
      int count = 0;
      for (final NamedType arg in func.parameters) {
        final String argName = _getSafeArgName(count, arg);
        final String valueGetter = 'GetNullableObjectAtIndex(args, $count)';
        final String? primitiveExtractionMethod =
            _nsnumberExtractionMethod(arg.type);
        final _ObjcType objcArgType = _objcTypeForDartType(
          generatorOptions.prefix,
          arg.type,
        );
        if (primitiveExtractionMethod != null) {
          indent.writeln(
              '${objcArgType.beforeString}$argName = [$valueGetter $primitiveExtractionMethod];');
        } else if (arg.type.isEnum) {
          indent.writeln('NSNumber *${argName}AsNumber = $valueGetter;');
          indent.writeln(
              '${_enumName(arg.type.baseName, suffix: ' *', prefix: '', box: true)}$argName = ${argName}AsNumber == nil ? nil : [[${_enumName(arg.type.baseName, prefix: generatorOptions.prefix, box: true)} alloc] initWithValue:[${argName}AsNumber integerValue]];');
        } else {
          indent.writeln('${objcArgType.beforeString}$argName = $valueGetter;');
        }
        count++;
      }
    }

    void writeAsyncBindings(Iterable<String> selectorComponents,
        String callSignature, _ObjcType returnType) {
      if (func.returnType.isVoid) {
        const String callback = 'callback(wrapResult(nil, error));';
        if (func.parameters.isEmpty) {
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
        String returnTypeString = '${returnType.beforeString}_Nullable output';
        const String numberOutput = 'NSNumber *output =';
        const String enumConversionExpression =
            'enumValue == nil ? nil : [NSNumber numberWithInteger:enumValue.value];';

        if (func.returnType.isEnum) {
          returnTypeString =
              '${_enumName(returnType.baseName, suffix: ' *_Nullable', prefix: generatorOptions.prefix, box: true)} enumValue';
        }
        if (func.parameters.isEmpty) {
          indent.writeScoped(
              '[api ${selectorComponents.first}:^($returnTypeString, FlutterError *_Nullable error) {',
              '}];', () {
            if (func.returnType.isEnum) {
              indent.writeln('$numberOutput $enumConversionExpression');
            }
            indent.writeln(callback);
          });
        } else {
          indent.writeScoped(
              '[api $callSignature ${selectorComponents.last}:^($returnTypeString, FlutterError *_Nullable error) {',
              '}];', () {
            if (func.returnType.isEnum) {
              indent.writeln('$numberOutput $enumConversionExpression');
            }
            indent.writeln(callback);
          });
        }
      }
    }

    void writeSyncBindings(String call, _ObjcType returnType) {
      indent.writeln('FlutterError *error;');
      if (func.returnType.isVoid) {
        indent.writeln('$call;');
        indent.writeln('callback(wrapResult(nil, error));');
      } else {
        if (func.returnType.isEnum) {
          indent.writeln(
              '${_enumName(func.returnType.baseName, suffix: ' *', prefix: generatorOptions.prefix, box: true)} enumBox = $call;');
          indent.writeln(
              'NSNumber *output = enumBox == nil ? nil : [NSNumber numberWithInteger:enumBox.value];');
        } else {
          indent.writeln('${returnType.beforeString}output = $call;');
        }
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
    indent.addScoped('{', '}];', () {
      final _ObjcType returnType = _objcTypeForDartType(
        generatorOptions.prefix, func.returnType,
        // Nullability is required since the return must be nil if NSError is set.
        forceNullability: true,
      );
      final Iterable<String> selectorComponents =
          _getSelectorComponents(func, lastSelectorComponent);
      final Iterable<String> argNames =
          indexMap(func.parameters, _getSafeArgName);
      final String callSignature =
          map2(selectorComponents.take(argNames.length), argNames,
              (String selectorComponent, String argName) {
        return '$selectorComponent:$argName';
      }).join(' ');
      if (func.parameters.isNotEmpty) {
        unpackArgs('message');
      }
      if (func.isAsynchronous) {
        writeAsyncBindings(selectorComponents, callSignature, returnType);
      } else {
        final String syncCall = func.parameters.isEmpty
            ? '[api ${selectorComponents.first}:&error]'
            : '[api $callSignature error:&error]';
        writeSyncBindings(syncCall, returnType);
      }
    });
  }

  void _writeChannelAllocation(
    ObjcOptions generatorOptions,
    Indent indent,
    Api api,
    Method func,
    String varName,
    String? taskQueue, {
    required String dartPackageName,
  }) {
    indent.writeln('FlutterBasicMessageChannel *$varName =');
    indent.nest(1, () {
      indent.writeln('[[FlutterBasicMessageChannel alloc]');
      indent.nest(1, () {
        indent.writeln(
            'initWithName:@"${makeChannelName(api, func, dartPackageName)}"');
        indent.writeln('binaryMessenger:binaryMessenger');
        indent.write('codec:');
        indent
            .add('${_getCodecGetterName(generatorOptions.prefix, api.name)}()');

        if (taskQueue != null) {
          indent.newln();
          indent.addln('taskQueue:$taskQueue];');
        } else {
          indent.addln('];');
        }
      });
    });
  }

  void _writeObjcSourceDataClassExtension(
      ObjcOptions languageOptions, Indent indent, Class classDefinition) {
    final String className =
        _className(languageOptions.prefix, classDefinition.name);
    indent.newln();
    indent.writeln('@interface $className ()');
    indent.writeln('+ ($className *)fromList:(NSArray *)list;');
    indent
        .writeln('+ (nullable $className *)nullableFromList:(NSArray *)list;');
    indent.writeln('- (NSArray *)toList;');
    indent.writeln('@end');
  }

  void _writeObjcSourceClassInitializer(
    ObjcOptions languageOptions,
    Root root,
    Indent indent,
    Class classDefinition,
    Set<String> customClassNames,
    Set<String> customEnumNames,
    String className,
  ) {
    _writeObjcSourceClassInitializerDeclaration(
      indent,
      languageOptions,
      root,
      classDefinition,
      root.classes,
      root.enums,
      languageOptions.prefix,
    );
    indent.writeScoped(' {', '}', () {
      const String result = 'pigeonResult';
      indent.writeln('$className* $result = [[$className alloc] init];');
      for (final NamedType field
          in getFieldsInSerializationOrder(classDefinition)) {
        indent.writeln('$result.${field.name} = ${field.name};');
      }
      indent.writeln('return $result;');
    });
  }

  /// Writes the codec that will be used for encoding messages for the [api].
  ///
  /// Example:
  /// @interface FooHostApiCodecReader : FlutterStandardReader
  /// ...
  /// @interface FooHostApiCodecWriter : FlutterStandardWriter
  /// ...
  /// @interface FooHostApiCodecReaderWriter : FlutterStandardReaderWriter
  /// ...
  /// NSObject<FlutterMessageCodec> *FooHostApiCodecGetCodec(void) {...}
  void _writeCodec(
      Indent indent, String name, ObjcOptions options, Api api, Root root) {
    assert(getCodecClasses(api, root).isNotEmpty);
    final Iterable<EnumeratedClass> codecClasses = getCodecClasses(api, root);
    final String readerWriterName = '${name}ReaderWriter';
    final String readerName = '${name}Reader';
    final String writerName = '${name}Writer';
    indent.writeln('@interface $readerName : FlutterStandardReader');
    indent.writeln('@end');
    indent.writeln('@implementation $readerName');
    indent.write('- (nullable id)readValueOfType:(UInt8)type ');
    indent.addScoped('{', '}', () {
      indent.write('switch (type) ');
      indent.addScoped('{', '}', () {
        for (final EnumeratedClass customClass in codecClasses) {
          indent.writeln('case ${customClass.enumeration}: ');
          indent.nest(1, () {
            indent.writeln(
                'return [${_className(options.prefix, customClass.name)} fromList:[self readValue]];');
          });
        }
        indent.writeln('default:');
        indent.nest(1, () {
          indent.writeln('return [super readValueOfType:type];');
        });
      });
    });
    indent.writeln('@end');
    indent.newln();
    indent.writeln('@interface $writerName : FlutterStandardWriter');
    indent.writeln('@end');
    indent.writeln('@implementation $writerName');
    indent.write('- (void)writeValue:(id)value ');
    indent.addScoped('{', '}', () {
      bool firstClass = true;
      for (final EnumeratedClass customClass in codecClasses) {
        if (firstClass) {
          indent.write('');
          firstClass = false;
        }
        indent.add(
            'if ([value isKindOfClass:[${_className(options.prefix, customClass.name)} class]]) ');
        indent.addScoped('{', '} else ', () {
          indent.writeln('[self writeByte:${customClass.enumeration}];');
          indent.writeln('[self writeValue:[value toList]];');
        }, addTrailingNewline: false);
      }
      indent.addScoped('{', '}', () {
        indent.writeln('[super writeValue:value];');
      });
    });
    indent.writeln('@end');
    indent.newln();
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
@end''');
  }

  void _writeCodecGetter(
      Indent indent, String name, ObjcOptions options, Api api, Root root) {
    final String readerWriterName = '${name}ReaderWriter';

    indent.write(
        'NSObject<FlutterMessageCodec> *${_getCodecGetterName(options.prefix, api.name)}(void) ');
    indent.addScoped('{', '}', () {
      indent
          .writeln('static FlutterStandardMessageCodec *sSharedObject = nil;');
      if (getCodecClasses(api, root).isNotEmpty) {
        indent.writeln('static dispatch_once_t sPred = 0;');
        indent.write('dispatch_once(&sPred, ^');
        indent.addScoped('{', '});', () {
          indent.writeln(
              '$readerWriterName *readerWriter = [[$readerWriterName alloc] init];');
          indent.writeln(
              'sSharedObject = [FlutterStandardMessageCodec codecWithReaderWriter:readerWriter];');
        });
      } else {
        indent.writeln(
            'sSharedObject = [FlutterStandardMessageCodec sharedInstance];');
      }

      indent.writeln('return sSharedObject;');
    });
  }

  void _writeMethod(
    ObjcOptions languageOptions,
    Root root,
    Indent indent,
    Api api,
    Method func, {
    required String dartPackageName,
  }) {
    final _ObjcType returnType = _objcTypeForDartType(
      languageOptions.prefix,
      func.returnType,
      // Nullability is required since the return must be nil if NSError is set.
      forceNullability: true,
    );
    final String callbackType =
        _callbackForType(func.returnType, returnType, languageOptions);

    String argNameFunc(int count, NamedType arg) => _getSafeArgName(count, arg);
    String sendArgument;
    if (func.parameters.isEmpty) {
      sendArgument = 'nil';
    } else {
      int count = 0;
      String makeVarOrNSNullExpression(NamedType arg) {
        final String argName = argNameFunc(count, arg);
        String varExpression = _collectionSafeExpression(argName, arg.type);
        if (arg.type.isEnum) {
          if (arg.type.isNullable) {
            varExpression =
                '${argNameFunc(count, arg)} == nil ? [NSNull null] : [NSNumber numberWithInteger:$argName.value]';
          } else {
            varExpression = '[NSNumber numberWithInteger:$argName]';
          }
        }
        count++;
        return varExpression;
      }

      sendArgument =
          '@[${func.parameters.map(makeVarOrNSNullExpression).join(', ')}]';
    }
    indent.write(_makeObjcSignature(
      func: func,
      options: languageOptions,
      returnType: 'void',
      lastArgName: 'completion',
      lastArgType: callbackType,
      argNameFunc: argNameFunc,
    ));
    indent.addScoped(' {', '}', () {
      indent.writeln(
          'NSString *channelName = @"${makeChannelName(api, func, dartPackageName)}";');
      indent.writeln('FlutterBasicMessageChannel *channel =');
      indent.nest(1, () {
        indent.writeln('[FlutterBasicMessageChannel');
        indent.nest(1, () {
          indent.writeln('messageChannelWithName:channelName');
          indent.writeln('binaryMessenger:self.binaryMessenger');
          indent.write(
              'codec:${_getCodecGetterName(languageOptions.prefix, api.name)}()');
          indent.addln('];');
        });
      });
      final String valueOnErrorResponse = func.returnType.isVoid ? '' : 'nil, ';
      indent.write(
          '[channel sendMessage:$sendArgument reply:^(NSArray<id> *reply) ');
      indent.addScoped('{', '}];', () {
        indent.writeScoped('if (reply != nil) {', '} ', () {
          indent.writeScoped('if (reply.count > 1) {', '} ', () {
            indent.writeln(
                'completion($valueOnErrorResponse[FlutterError errorWithCode:reply[0] message:reply[1] details:reply[2]]);');
          }, addTrailingNewline: false);
          indent.addScoped('else {', '}', () {
            const String nullCheck =
                'reply[0] == [NSNull null] ? nil : reply[0]';
            if (func.returnType.isVoid) {
              indent.writeln('completion(nil);');
            } else {
              if (func.returnType.isEnum) {
                final String enumName = _enumName(returnType.baseName,
                    prefix: languageOptions.prefix, box: true);
                indent.writeln('NSNumber *outputAsNumber = $nullCheck;');
                indent.writeln(
                    '$enumName *output = outputAsNumber == nil ? nil : [[$enumName alloc] initWithValue:[outputAsNumber integerValue]];');
              } else {
                indent
                    .writeln('${returnType.beforeString}output = $nullCheck;');
              }
              indent.writeln('completion(output, nil);');
            }
          });
        }, addTrailingNewline: false);
        indent.addScoped('else {', '} ', () {
          indent.writeln(
              'completion(${valueOnErrorResponse}createConnectionError(channelName));');
        });
      });
    });
  }
}

/// Writes the method declaration for the initializer.
///
/// Example '+ (instancetype)makeWithFoo:(NSString *)foo'
void _writeObjcSourceClassInitializerDeclaration(
    Indent indent,
    ObjcOptions generatorOptions,
    Root root,
    Class classDefinition,
    List<Class> classes,
    List<Enum> enums,
    String? prefix) {
  indent.write('+ (instancetype)makeWith');
  bool isFirst = true;
  indent.nest(2, () {
    for (final NamedType field
        in getFieldsInSerializationOrder(classDefinition)) {
      final String label = isFirst ? _capitalize(field.name) : field.name;
      final void Function(String) printer = isFirst
          ? indent.add
          : (String x) {
              indent.newln();
              indent.write(x);
            };
      isFirst = false;
      final HostDatatype hostDatatype = getFieldHostDatatype(
          field,
          (TypeDeclaration x) => _objcTypeStringForPrimitiveDartType(prefix, x,
              beforeString: true),
          customResolver: field.type.isEnum
              ? (String x) => field.type.isNullable
                  ? _enumName(x, suffix: ' *', prefix: prefix, box: true)
                  : _enumName(x, prefix: prefix)
              : (String x) => '${_className(prefix, x)} *');
      final String nullable = field.type.isNullable ? 'nullable ' : '';
      printer('$label:($nullable${hostDatatype.datatype})${field.name}');
    }
  });
}

String _enumName(String name,
        {required String? prefix, String suffix = '', bool box = false}) =>
    '${prefix ?? ''}$name${box ? 'Box' : ''}$suffix';

/// Calculates the ObjC class name, possibly prefixed.
String _className(String? prefix, String className) {
  if (prefix != null) {
    return '$prefix$className';
  } else {
    return className;
  }
}

/// Calculates callback block signature for async methods.
String _callbackForType(
    TypeDeclaration type, _ObjcType objcType, ObjcOptions options) {
  if (type.isVoid) {
    return 'void (^)(FlutterError *_Nullable)';
  } else if (type.isEnum) {
    return 'void (^)(${_enumName(objcType.baseName, suffix: ' *_Nullable', prefix: options.prefix, box: true)}, FlutterError *_Nullable)';
  } else {
    return 'void (^)(${objcType.beforeString}_Nullable, FlutterError *_Nullable)';
  }
}

/// Represents an Objective-C type, including pointer (id, NSString*, etc.) and
/// primitive (BOOL, NSInteger, etc.) types.
class _ObjcType {
  const _ObjcType({required this.baseName, bool isPointer = true})
      : hasAsterisk = isPointer && baseName != 'id';
  final String baseName;
  final bool hasAsterisk;

  @override
  String toString() => hasAsterisk ? '$baseName *' : baseName;

  /// Returns a version of the string form that can be used directly before
  /// another string (e.g., a variable name) and handle spacing correctly for
  /// a right-aligned pointer format.
  String get beforeString => hasAsterisk ? toString() : '$this ';
}

/// Maps between Dart types to ObjC pointer types (ex 'String' => 'NSString *').
const Map<String, _ObjcType> _objcTypeForNullableDartTypeMap =
    <String, _ObjcType>{
  'bool': _ObjcType(baseName: 'NSNumber'),
  'int': _ObjcType(baseName: 'NSNumber'),
  'String': _ObjcType(baseName: 'NSString'),
  'double': _ObjcType(baseName: 'NSNumber'),
  'Uint8List': _ObjcType(baseName: 'FlutterStandardTypedData'),
  'Int32List': _ObjcType(baseName: 'FlutterStandardTypedData'),
  'Int64List': _ObjcType(baseName: 'FlutterStandardTypedData'),
  'Float64List': _ObjcType(baseName: 'FlutterStandardTypedData'),
  'List': _ObjcType(baseName: 'NSArray'),
  'Map': _ObjcType(baseName: 'NSDictionary'),
  'Object': _ObjcType(baseName: 'id'),
};

/// Maps between Dart types to ObjC pointer types (ex 'String' => 'NSString *').
const Map<String, _ObjcType> _objcTypeForNonNullableDartTypeMap =
    <String, _ObjcType>{
  'bool': _ObjcType(baseName: 'BOOL', isPointer: false),
  'int': _ObjcType(baseName: 'NSInteger', isPointer: false),
  'String': _ObjcType(baseName: 'NSString'),
  'double': _ObjcType(baseName: 'double', isPointer: false),
  'Uint8List': _ObjcType(baseName: 'FlutterStandardTypedData'),
  'Int32List': _ObjcType(baseName: 'FlutterStandardTypedData'),
  'Int64List': _ObjcType(baseName: 'FlutterStandardTypedData'),
  'Float64List': _ObjcType(baseName: 'FlutterStandardTypedData'),
  'List': _ObjcType(baseName: 'NSArray'),
  'Map': _ObjcType(baseName: 'NSDictionary'),
  'Object': _ObjcType(baseName: 'id'),
};

bool _usesPrimitive(TypeDeclaration type) {
  // Only non-nullable types are unboxed.
  if (!type.isNullable) {
    if (type.isEnum) {
      return true;
    }
    switch (type.baseName) {
      case 'bool':
      case 'int':
      case 'double':
        return true;
    }
  }
  return false;
}

String _collectionSafeExpression(
  String expression,
  TypeDeclaration type,
) {
  return _usesPrimitive(type)
      ? '@($expression)'
      : '$expression ?: [NSNull null]';
}

/// Returns the method to convert [type] from a boxed NSNumber to its
/// corresponding primitive value, if any.
String? _nsnumberExtractionMethod(
  TypeDeclaration type,
) {
  // Only non-nullable types are unboxed.
  if (!type.isNullable) {
    if (type.isEnum) {
      return 'integerValue';
    }
    switch (type.baseName) {
      case 'bool':
        return 'boolValue';
      case 'int':
        return 'integerValue';
      case 'double':
        return 'doubleValue';
    }
  }
  return null;
}

/// Converts list of [TypeDeclaration] to a code string representing the type
/// arguments for use in generics.
/// Example: ('FOO', ['Foo', 'Bar']) -> 'FOOFoo *, FOOBar *').
String _flattenTypeArguments(String? classPrefix, List<TypeDeclaration> args) {
  final String result = args
      .map<String>((TypeDeclaration e) =>
          _objcTypeForDartType(classPrefix, e).toString())
      .join(', ');
  return result;
}

_ObjcType? _objcTypeForPrimitiveDartType(TypeDeclaration type,
    {bool forceNullability = false}) {
  return forceNullability || type.isNullable
      ? _objcTypeForNullableDartTypeMap[type.baseName]
      : _objcTypeForNonNullableDartTypeMap[type.baseName];
}

String? _objcTypeStringForPrimitiveDartType(
    String? classPrefix, TypeDeclaration type,
    {required bool beforeString, bool forceNullability = false}) {
  final _ObjcType? objcType;
  if (forceNullability || type.isNullable) {
    objcType = _objcTypeForNullableDartTypeMap.containsKey(type.baseName)
        ? _objcTypeForDartType(classPrefix, type)
        : null;
  } else {
    objcType = _objcTypeForNonNullableDartTypeMap.containsKey(type.baseName)
        ? _objcTypeForDartType(classPrefix, type)
        : null;
  }
  return beforeString ? objcType?.beforeString : objcType?.toString();
}

/// Returns the Objective-C type for a Dart [field], prepending the
/// [classPrefix] for generated classes.
_ObjcType _objcTypeForDartType(String? classPrefix, TypeDeclaration field,
    {bool forceNullability = false}) {
  final _ObjcType? primitiveType =
      _objcTypeForPrimitiveDartType(field, forceNullability: forceNullability);
  return primitiveType == null
      ? _ObjcType(
          baseName: _className(classPrefix, field.baseName),
          // Non-nullable enums are non-pointer types.
          isPointer: !field.isEnum || (field.isNullable || forceNullability))
      : field.typeArguments.isEmpty
          ? primitiveType
          : _ObjcType(
              baseName:
                  '${primitiveType.baseName}<${_flattenTypeArguments(classPrefix, field.typeArguments)}>');
}

/// Maps a type to a properties memory semantics (ie strong, copy).
String _propertyTypeForDartType(TypeDeclaration type,
    {required bool isNullable, required bool isEnum}) {
  if (isEnum) {
    // Only the nullable versions are objects.
    return isNullable ? 'strong' : 'assign';
  }
  switch (type.baseName) {
    case 'List':
    case 'Map':
    case 'String':
      // Standard Objective-C practice is to copy strings and collections to
      // avoid unexpected mutation if set to mutable versions.
      return 'copy';
    case 'double':
    case 'bool':
    case 'int':
      // Only the nullable versions are objects.
      return isNullable ? 'strong' : 'assign';
  }
  // Anything else is a standard object, and should therefore be strong.
  return 'strong';
}

/// Generates the name of the codec that will be generated.
String _getCodecName(String? prefix, String className) =>
    '${_className(prefix, className)}Codec';

/// Generates the name of the function for accessing the codec instance used by
/// the api class named [className].
String _getCodecGetterName(String? prefix, String className) =>
    '${_className(prefix, className)}GetCodec';

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
    final Iterator<NamedType> it = func.parameters.iterator;
    final bool hasArguments = it.moveNext();
    final String namePostfix =
        (lastSelectorComponent.isNotEmpty && func.parameters.isEmpty)
            ? 'With${_capitalize(lastSelectorComponent)}'
            : '';
    yield '${func.name}${hasArguments ? _capitalize(func.parameters[0].name) : namePostfix}';
    while (it.moveNext()) {
      yield it.current.name;
    }
  } else {
    assert(':'.allMatches(func.objcSelector).length == func.parameters.length);
    final Iterable<String> customComponents = func.objcSelector
        .split(':')
        .where((String element) => element.isNotEmpty);
    yield* customComponents;
  }
  if (lastSelectorComponent.isNotEmpty && func.parameters.isNotEmpty) {
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
/// [func.parameters].
String _makeObjcSignature({
  required Method func,
  required ObjcOptions options,
  required String returnType,
  required String lastArgType,
  required String lastArgName,
  String Function(int, NamedType)? argNameFunc,
}) {
  argNameFunc = argNameFunc ??
      (int _, NamedType e) =>
          e.type.isNullable && e.type.isEnum ? '${e.name}Boxed' : e.name;
  final Iterable<String> argNames =
      followedByOne(indexMap(func.parameters, argNameFunc), lastArgName);
  final Iterable<String> selectorComponents =
      _getSelectorComponents(func, lastArgName);
  final Iterable<String> argTypes = followedByOne(
    func.parameters.map((NamedType arg) {
      if (arg.type.isEnum) {
        return '${arg.type.isNullable ? 'nullable ' : ''}${_enumName(arg.type.baseName, suffix: arg.type.isNullable ? ' *' : '', prefix: options.prefix, box: arg.type.isNullable)}';
      } else {
        final String nullable = arg.type.isNullable ? 'nullable ' : '';
        final _ObjcType argType =
            _objcTypeForDartType(options.prefix, arg.type);
        return '$nullable$argType';
      }
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

/// Generates the ".h" file for the AST represented by [root] to [sink] with the
/// provided [options].
void generateObjcHeader(ObjcOptions options, Root root, Indent indent) {}

String _listGetter(String list, NamedType field, int index, String? prefix) {
  if (field.type.isClass) {
    String className = field.type.baseName;
    if (prefix != null) {
      className = '$prefix$className';
    }
    return '[$className nullableFromList:(GetNullableObjectAtIndex($list, $index))]';
  } else {
    return 'GetNullableObjectAtIndex($list, $index)';
  }
}

String _arrayValue(NamedType field) {
  if (field.type.isClass) {
    return '(self.${field.name} ? [self.${field.name} toList] : [NSNull null])';
  } else if (field.type.isEnum) {
    if (field.type.isNullable) {
      return '(self.${field.name} == nil ? [NSNull null] : [NSNumber numberWithInteger:self.${field.name}.value])';
    }
    return '@(self.${field.name})';
  } else {
    return _collectionSafeExpression(
      'self.${field.name}',
      field.type,
    );
  }
}

String _getSelector(Method func, String lastSelectorComponent) =>
    '${_getSelectorComponents(func, lastSelectorComponent).join(':')}:';

/// Returns an argument name that can be used in a context where it is possible to collide.
String _getSafeArgName(int count, NamedType arg) =>
    arg.name.isEmpty ? 'arg$count' : 'arg_${arg.name}';

void _writeExtension(Indent indent, String apiName) {
  indent.writeln('@interface $apiName ()');
  indent.writeln(
      '@property(nonatomic, strong) NSObject<FlutterBinaryMessenger> *binaryMessenger;');
  indent.writeln('@end');
}

void _writeInitializer(Indent indent) {
  indent.write(
      '- (instancetype)initWithBinaryMessenger:(NSObject<FlutterBinaryMessenger> *)binaryMessenger ');
  indent.addScoped('{', '}', () {
    indent.writeln('self = [super init];');
    indent.write('if (self) ');
    indent.addScoped('{', '}', () {
      indent.writeln('_binaryMessenger = binaryMessenger;');
    });
    indent.writeln('return self;');
  });
}

/// Looks through the AST for features that aren't supported by the ObjC
/// generator.
List<Error> validateObjc(ObjcOptions options, Root root) {
  final List<Error> errors = <Error>[];
  for (final Api api in root.apis) {
    for (final Method method in api.methods) {
      for (final NamedType arg in method.parameters) {
        if (arg.type.isEnum && arg.type.isNullable) {
          // TODO(gaaclarke): Add line number.
          errors.add(Error(
              message:
                  "Nullable enum types aren't support in ObjC arguments in method:${api.name}.${method.name} argument:(${arg.type.baseName} ${arg.name})."));
        }
      }
    }
  }

  return errors;
}

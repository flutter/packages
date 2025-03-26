// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:path/path.dart' as path;

import '../ast.dart';
import '../functional.dart';
import '../generator.dart';
import '../generator_tools.dart';
import '../pigeon_lib.dart';

/// Documentation comment open symbol.
const String _docCommentPrefix = '///';

/// Documentation comment spec.
const DocumentCommentSpecification _docCommentSpec =
    DocumentCommentSpecification(_docCommentPrefix);

const String _overflowClassName = '${classNamePrefix}CodecOverflow';

final NamedType _overflowInt = NamedType(
    name: 'type',
    type: const TypeDeclaration(baseName: 'int', isNullable: false));
final NamedType _overflowObject = NamedType(
    name: 'wrapped',
    type: const TypeDeclaration(baseName: 'Object', isNullable: true));
final List<NamedType> _overflowFields = <NamedType>[
  _overflowInt,
  _overflowObject,
];
final Class _overflowClass =
    Class(name: _overflowClassName, fields: _overflowFields);
final EnumeratedType _enumeratedOverflow = EnumeratedType(
    _overflowClassName, maximumCodecFieldKey, CustomTypes.customClass,
    associatedClass: _overflowClass);

/// Options that control how Objective-C code will be generated.
class ObjcOptions {
  /// Parametric constructor for ObjcOptions.
  const ObjcOptions({
    this.headerIncludePath,
    this.prefix,
    this.copyrightHeader,
    this.fileSpecificClassNameComponent,
  });

  /// The path to the header that will get placed in the source file (example:
  /// "foo.h").
  final String? headerIncludePath;

  /// Prefix that will be appended before all generated classes and protocols.
  final String? prefix;

  /// A copyright header that will get prepended to generated code.
  final Iterable<String>? copyrightHeader;

  /// A String to augment class names to avoid cross file collisions.
  final String? fileSpecificClassNameComponent;

  /// Creates a [ObjcOptions] from a Map representation where:
  /// `x = ObjcOptions.fromMap(x.toMap())`.
  static ObjcOptions fromMap(Map<String, Object> map) {
    final Iterable<dynamic>? copyrightHeader =
        map['copyrightHeader'] as Iterable<dynamic>?;
    return ObjcOptions(
      headerIncludePath: map['headerIncludePath'] as String?,
      prefix: map['prefix'] as String?,
      copyrightHeader: copyrightHeader?.cast<String>(),
      fileSpecificClassNameComponent:
          map['fileSpecificClassNameComponent'] as String?,
    );
  }

  /// Converts a [ObjcOptions] to a Map representation where:
  /// `x = ObjcOptions.fromMap(x.toMap())`.
  Map<String, Object> toMap() {
    final Map<String, Object> result = <String, Object>{
      if (headerIncludePath != null) 'headerIncludePath': headerIncludePath!,
      if (prefix != null) 'prefix': prefix!,
      if (copyrightHeader != null) 'copyrightHeader': copyrightHeader!,
      if (fileSpecificClassNameComponent != null)
        'fileSpecificClassNameComponent': fileSpecificClassNameComponent!,
    };
    return result;
  }

  /// Overrides any non-null parameters from [options] into this to make a new
  /// [ObjcOptions].
  ObjcOptions merge(ObjcOptions options) {
    return ObjcOptions.fromMap(mergeMaps(toMap(), options.toMap()));
  }
}

/// Options that control how Objective-C code will be generated.
class InternalObjcOptions extends PigeonInternalOptions {
  /// Parametric constructor for InternalObjcOptions.
  const InternalObjcOptions({
    required this.headerIncludePath,
    required this.objcHeaderOut,
    required this.objcSourceOut,
    this.prefix,
    this.copyrightHeader,
    this.fileSpecificClassNameComponent,
  });

  /// Creates InternalObjcOptions from ObjcOptions.
  InternalObjcOptions.fromObjcOptions(
    ObjcOptions options, {
    required this.objcHeaderOut,
    required this.objcSourceOut,
    String? fileSpecificClassNameComponent,
    Iterable<String>? copyrightHeader,
  })  : headerIncludePath =
            options.headerIncludePath ?? path.basename(objcHeaderOut),
        prefix = options.prefix,
        copyrightHeader = options.copyrightHeader ?? copyrightHeader,
        fileSpecificClassNameComponent =
            options.fileSpecificClassNameComponent ??
                fileSpecificClassNameComponent;

  /// The path to the header that will get placed in the source file (example:
  /// "foo.h").
  final String headerIncludePath;

  /// Path to the ".h" Objective-C file will be generated.
  final String objcHeaderOut;

  /// Path to the ".m" Objective-C file will be generated.
  final String objcSourceOut;

  /// Prefix that will be appended before all generated classes and protocols.
  final String? prefix;

  /// A copyright header that will get prepended to generated code.
  final Iterable<String>? copyrightHeader;

  /// A String to augment class names to avoid cross file collisions.
  final String? fileSpecificClassNameComponent;
}

/// Class that manages all Objc code generation.
class ObjcGenerator extends Generator<OutputFileOptions<InternalObjcOptions>> {
  /// Instantiates a Objc Generator.
  const ObjcGenerator();

  /// Generates Objc file of type specified in [generatorOptions]
  @override
  void generate(
    OutputFileOptions<InternalObjcOptions> generatorOptions,
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
class ObjcHeaderGenerator extends StructuredGenerator<InternalObjcOptions> {
  /// Constructor.
  const ObjcHeaderGenerator();

  @override
  void writeFilePrologue(
    InternalObjcOptions generatorOptions,
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
    InternalObjcOptions generatorOptions,
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
    InternalObjcOptions generatorOptions,
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
    InternalObjcOptions generatorOptions,
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
    InternalObjcOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    _writeDataClassDeclaration(
      generatorOptions,
      root,
      indent,
      classDefinition,
    );
  }

  @override
  void writeClassEncode(
    InternalObjcOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {}

  @override
  void writeClassDecode(
    InternalObjcOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {}

  @override
  void writeGeneralCodec(
    InternalObjcOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.writeln('$_docCommentPrefix The codec used by all APIs.');
    indent.writeln(
        'NSObject<FlutterMessageCodec> *${generatorOptions.prefix}Get${toUpperCamelCase(generatorOptions.fileSpecificClassNameComponent ?? '')}Codec(void);');
  }

  @override
  void writeApis(
    InternalObjcOptions generatorOptions,
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
    InternalObjcOptions generatorOptions,
    Root root,
    Indent indent,
    Api api, {
    required String dartPackageName,
  }) {
    indent.newln();
    final String apiName = _className(generatorOptions.prefix, api.name);
    addDocumentationComments(
        indent, api.documentationComments, _docCommentSpec);

    indent.writeln('@interface $apiName : NSObject');
    indent.writeln(
        '- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger;');
    indent.writeln(
        '- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger messageChannelSuffix:(nullable NSString *)messageChannelSuffix;');
    for (final Method func in api.methods) {
      final _ObjcType returnType = _objcTypeForDartType(
        generatorOptions.prefix, func.returnType,
        // Nullability is required since the return must be nil if NSError is set.
        forceBox: true,
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
    InternalObjcOptions generatorOptions,
    Root root,
    Indent indent,
    Api api, {
    required String dartPackageName,
  }) {
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
        forceBox: true,
      );

      String? lastArgName;
      String? lastArgType;
      String? returnType;
      final String enumReturnType = _enumName(
        func.returnType.baseName,
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
    indent.writeln(
        'extern void SetUp${apiName}WithSuffix(id<FlutterBinaryMessenger> binaryMessenger, NSObject<$apiName> *_Nullable api, NSString *messageChannelSuffix);');
    indent.newln();
  }
}

/// Generates Objc .m file.
class ObjcSourceGenerator extends StructuredGenerator<InternalObjcOptions> {
  /// Constructor.
  const ObjcSourceGenerator();

  @override
  void writeFilePrologue(
    InternalObjcOptions generatorOptions,
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
    InternalObjcOptions generatorOptions,
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
    InternalObjcOptions generatorOptions,
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
    InternalObjcOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    for (final Class classDefinition in root.classes) {
      _writeObjcSourceDataClassExtension(
        generatorOptions,
        indent,
        classDefinition,
      );
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
    InternalObjcOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    final String className =
        _className(generatorOptions.prefix, classDefinition.name);

    indent.writeln('@implementation $className');
    _writeObjcSourceClassInitializer(
        generatorOptions, root, indent, classDefinition, className);
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
    InternalObjcOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    indent.write('- (NSArray<id> *)toList ');
    indent.addScoped('{', '}', () {
      indent.write('return');
      indent.addScoped(' @[', '];', () {
        for (final NamedType field in classDefinition.fields) {
          indent.writeln('${_arrayValue(field, generatorOptions.prefix)},');
        }
      });
    });
  }

  @override
  void writeClassDecode(
    InternalObjcOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    final String className =
        _className(generatorOptions.prefix, classDefinition.name);
    indent.write('+ ($className *)fromList:(NSArray<id> *)list ');
    indent.addScoped('{', '}', () {
      const String resultName = 'pigeonResult';
      indent.writeln('$className *$resultName = [[$className alloc] init];');
      enumerate(getFieldsInSerializationOrder(classDefinition),
          (int index, final NamedType field) {
        final String valueGetter = 'GetNullableObjectAtIndex(list, $index)';
        final String? primitiveExtractionMethod =
            _nsnumberExtractionMethod(field.type);
        final String ivarValueExpression;
        if (field.type.isEnum && !field.type.isNullable) {
          final String varName =
              'boxed${_enumName(field.type.baseName, prefix: generatorOptions.prefix)}';
          _writeEnumBoxToEnum(
            indent,
            field,
            varName,
            valueGetter,
            prefix: generatorOptions.prefix,
          );
          ivarValueExpression = '$varName.value';
        } else if (primitiveExtractionMethod != null) {
          ivarValueExpression = '[$valueGetter $primitiveExtractionMethod]';
        } else {
          ivarValueExpression = valueGetter;
        }
        indent.writeln('$resultName.${field.name} = $ivarValueExpression;');
      });
      indent.writeln('return $resultName;');
    });

    indent.write(
        '+ (nullable $className *)nullableFromList:(NSArray<id> *)list ');
    indent.addScoped('{', '}', () {
      indent.writeln('return (list) ? [$className fromList:list] : nil;');
    });
  }

  void _writeCodecOverflowUtilities(
    InternalObjcOptions generatorOptions,
    Root root,
    Indent indent,
    List<EnumeratedType> types, {
    required String dartPackageName,
  }) {
    _writeObjcSourceDataClassExtension(
      generatorOptions,
      indent,
      _overflowClass,
      returnType: 'id',
      isOverflowClass: true,
    );
    indent.newln();
    indent.writeln(
        '@implementation ${_className(generatorOptions.prefix, _overflowClassName)}');

    _writeObjcSourceClassInitializer(
        generatorOptions,
        root,
        indent,
        _overflowClass,
        _className(generatorOptions.prefix, _overflowClassName));
    writeClassEncode(
      generatorOptions,
      root,
      indent,
      _overflowClass,
      dartPackageName: dartPackageName,
    );

    indent.format('''
+ (id)fromList:(NSArray<id> *)list {
  ${_className(generatorOptions.prefix, _overflowClassName)} *wrapper = [[${_className(generatorOptions.prefix, _overflowClassName)} alloc] init];
  wrapper.type = [GetNullableObjectAtIndex(list, 0) integerValue];
  wrapper.wrapped = GetNullableObjectAtIndex(list, 1);
  return [wrapper unwrap];
}
''');

    indent.writeScoped('- (id) unwrap {', '}', () {
      indent.format('''
if (self.wrapped == nil) {
  return nil;
}
    ''');
      indent.writeScoped('switch (self.type) {', '}', () {
        for (int i = totalCustomCodecKeysAllowed; i < types.length; i++) {
          indent.write('case ${i - totalCustomCodecKeysAllowed}:');
          _writeCodecDecode(
            indent,
            types[i],
            generatorOptions.prefix ?? '',
            isOverflowClass: true,
          );
        }
        indent.writeScoped('default: ', '', () {
          indent.writeln('return nil;');
        }, addTrailingNewline: false);
      });
    });
    indent.writeln('@end');
  }

  void _writeCodecDecode(
      Indent indent, EnumeratedType customType, String? prefix,
      {bool isOverflowClass = false}) {
    String readValue = '[self readValue]';
    if (isOverflowClass) {
      readValue = 'self.wrapped';
    }
    if (customType.type == CustomTypes.customClass) {
      indent.addScoped('', null, () {
        indent.writeln(
            'return [${_className(prefix, customType.name)} fromList:$readValue];');
      }, addTrailingNewline: false);
    } else if (customType.type == CustomTypes.customEnum) {
      indent.addScoped(
          !isOverflowClass ? '{' : '', !isOverflowClass ? '}' : null, () {
        String enumAsNumber = 'enumAsNumber';
        if (!isOverflowClass) {
          indent.writeln('NSNumber *$enumAsNumber = $readValue;');
          indent.write('return $enumAsNumber == nil ? nil : ');
        } else {
          enumAsNumber = 'self.wrapped';
          indent.write('return ');
        }
        indent.addln(
            '[[${_enumName(customType.name, prefix: prefix, box: true)} alloc] initWithValue:[$enumAsNumber integerValue]];');
      }, addTrailingNewline: !isOverflowClass);
    }
  }

  @override
  void writeGeneralCodec(
    InternalObjcOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    const String codecName = 'PigeonCodec';
    final List<EnumeratedType> enumeratedTypes =
        getEnumeratedTypes(root, excludeSealedClasses: true).toList();
    final String readerWriterName =
        '${generatorOptions.prefix}${toUpperCamelCase(generatorOptions.fileSpecificClassNameComponent ?? '')}${codecName}ReaderWriter';
    final String readerName =
        '${generatorOptions.prefix}${toUpperCamelCase(generatorOptions.fileSpecificClassNameComponent ?? '')}${codecName}Reader';
    final String writerName =
        '${generatorOptions.prefix}${toUpperCamelCase(generatorOptions.fileSpecificClassNameComponent ?? '')}${codecName}Writer';

    if (root.requiresOverflowClass) {
      _writeCodecOverflowUtilities(
          generatorOptions, root, indent, enumeratedTypes,
          dartPackageName: dartPackageName);
    }

    indent.writeln('@interface $readerName : FlutterStandardReader');
    indent.writeln('@end');
    indent.writeln('@implementation $readerName');
    indent.write('- (nullable id)readValueOfType:(UInt8)type ');
    indent.addScoped('{', '}', () {
      indent.writeScoped('switch (type) {', '}', () {
        for (final EnumeratedType customType in enumeratedTypes) {
          if (customType.enumeration < maximumCodecFieldKey) {
            indent.write('case ${customType.enumeration}: ');
            _writeCodecDecode(
                indent, customType, generatorOptions.prefix ?? '');
          }
        }
        if (root.requiresOverflowClass) {
          indent.write('case $maximumCodecFieldKey: ');
          _writeCodecDecode(
            indent,
            _enumeratedOverflow,
            generatorOptions.prefix,
          );
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
      indent.write('');
      for (final EnumeratedType customType in enumeratedTypes) {
        final String encodeString = customType.type == CustomTypes.customClass
            ? '[value toList]'
            : '(value == nil ? [NSNull null] : [NSNumber numberWithInteger:box.value])';
        final String valueString = customType.enumeration < maximumCodecFieldKey
            ? encodeString
            : '[wrap toList]';
        final String className = customType.type == CustomTypes.customClass
            ? _className(generatorOptions.prefix, customType.name)
            : _enumName(customType.name,
                prefix: generatorOptions.prefix, box: true);
        indent.addScoped(
            'if ([value isKindOfClass:[$className class]]) {', '} else ', () {
          if (customType.type == CustomTypes.customEnum) {
            indent.writeln('$className *box = ($className *)value;');
          }
          final int enumeration = customType.enumeration < maximumCodecFieldKey
              ? customType.enumeration
              : maximumCodecFieldKey;
          if (customType.enumeration >= maximumCodecFieldKey) {
            indent.writeln(
                '${_className(generatorOptions.prefix, _overflowClassName)} *wrap = [${_className(generatorOptions.prefix, _overflowClassName)} makeWithType:${customType.enumeration - maximumCodecFieldKey} wrapped:$encodeString];');
          }
          indent.writeln('[self writeByte:$enumeration];');
          indent.writeln('[self writeValue:$valueString];');
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
    indent.newln();

    indent.write(
        'NSObject<FlutterMessageCodec> *${generatorOptions.prefix}Get${toUpperCamelCase(generatorOptions.fileSpecificClassNameComponent ?? '')}Codec(void) ');
    indent.addScoped('{', '}', () {
      indent
          .writeln('static FlutterStandardMessageCodec *sSharedObject = nil;');

      indent.writeln('static dispatch_once_t sPred = 0;');
      indent.write('dispatch_once(&sPred, ^');
      indent.addScoped('{', '});', () {
        indent.writeln(
            '$readerWriterName *readerWriter = [[$readerWriterName alloc] init];');
        indent.writeln(
            'sSharedObject = [FlutterStandardMessageCodec codecWithReaderWriter:readerWriter];');
      });

      indent.writeln('return sSharedObject;');
    });
  }

  @override
  void writeFlutterApi(
    InternalObjcOptions generatorOptions,
    Root root,
    Indent indent,
    AstFlutterApi api, {
    required String dartPackageName,
  }) {
    final String apiName = _className(generatorOptions.prefix, api.name);

    _writeExtension(indent, apiName);
    indent.newln();
    indent.writeln('@implementation $apiName');
    indent.newln();
    _writeInitializers(indent);
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
    InternalObjcOptions generatorOptions,
    Root root,
    Indent indent,
    AstHostApi api, {
    required String dartPackageName,
  }) {
    final String apiName = _className(generatorOptions.prefix, api.name);

    const String channelName = 'channel';
    indent.write(
        'void SetUp$apiName(id<FlutterBinaryMessenger> binaryMessenger, NSObject<$apiName> *api) ');
    indent.addScoped('{', '}', () {
      indent.writeln('SetUp${apiName}WithSuffix(binaryMessenger, api, @"");');
    });
    indent.newln();
    indent.write(
        'void SetUp${apiName}WithSuffix(id<FlutterBinaryMessenger> binaryMessenger, NSObject<$apiName> *api, NSString *messageChannelSuffix) ');
    indent.addScoped('{', '}', () {
      indent.writeln(
          'messageChannelSuffix = messageChannelSuffix.length > 0 ? [NSString stringWithFormat: @".%@", messageChannelSuffix] : @"";');
      String? serialBackgroundQueue;
      if (api.methods.any((Method m) =>
          m.taskQueueType == TaskQueueType.serialBackgroundThread)) {
        serialBackgroundQueue = 'taskQueue';
        // See https://github.com/flutter/flutter/issues/162613 for why this
        // is an ifdef instead of just a respondsToSelector: check.
        indent.format('''
#if TARGET_OS_IOS
  NSObject<FlutterTaskQueue> *$serialBackgroundQueue = [binaryMessenger makeBackgroundTaskQueue];
#else
  NSObject<FlutterTaskQueue> *$serialBackgroundQueue = nil;
#endif''');
      }
      for (final Method func in api.methods) {
        addDocumentationComments(
            indent, func.documentationComments, _docCommentSpec);

        indent.writeScoped('{', '}', () {
          _writeChannelAllocation(
            generatorOptions,
            indent,
            api,
            func,
            channelName,
            func.taskQueueType == TaskQueueType.serialBackgroundThread
                ? serialBackgroundQueue
                : null,
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
    InternalObjcOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    if (root.containsHostApi) {
      _writeWrapError(indent);
      indent.newln();
    }
    if (root.containsFlutterApi) {
      _writeCreateConnectionError(indent);
      indent.newln();
    }

    if (root.containsHostApi || root.containsFlutterApi) {
      _writeGetNullableObjectAtIndex(indent);
    }

    if (root.requiresOverflowClass) {
      _writeDataClassDeclaration(
        generatorOptions,
        root,
        indent,
        _overflowClass,
      );
    }
  }

  void _writeWrapError(Indent indent) {
    indent.format('''
static NSArray<id> *wrapResult(id result, FlutterError *error) {
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
static id GetNullableObjectAtIndex(NSArray<id> *array, NSInteger key) {
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

  void _writeChannelApiBinding(InternalObjcOptions generatorOptions, Root root,
      Indent indent, String apiName, Method func, String channel) {
    void unpackArgs(String variable) {
      indent.writeln('NSArray<id> *args = $variable;');
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
        final String ivarValueExpression;
        String beforeString = objcArgType.beforeString;
        if (arg.type.isEnum && !arg.type.isNullable) {
          final String varName =
              'boxed${_enumName(arg.type.baseName, prefix: generatorOptions.prefix)}';
          _writeEnumBoxToEnum(
            indent,
            arg,
            varName,
            valueGetter,
            prefix: generatorOptions.prefix,
          );
          ivarValueExpression = '$varName.value';
        } else if (primitiveExtractionMethod != null) {
          ivarValueExpression = '[$valueGetter $primitiveExtractionMethod]';
        } else {
          if (arg.type.isEnum) {
            beforeString = _enumName(
              arg.type.baseName,
              prefix: generatorOptions.prefix,
              box: true,
              suffix: ' *',
            );
          }
          ivarValueExpression = valueGetter;
        }
        indent.writeln('$beforeString$argName = $ivarValueExpression;');
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

        if (func.returnType.isEnum) {
          returnTypeString =
              '${_enumName(func.returnType.baseName, suffix: ' *_Nullable', prefix: generatorOptions.prefix, box: true)} output';
        }
        if (func.parameters.isEmpty) {
          indent.writeScoped(
              '[api ${selectorComponents.first}:^($returnTypeString, FlutterError *_Nullable error) {',
              '}];', () {
            indent.writeln(callback);
          });
        } else {
          indent.writeScoped(
              '[api $callSignature ${selectorComponents.last}:^($returnTypeString, FlutterError *_Nullable error) {',
              '}];', () {
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
              '${_enumName(func.returnType.baseName, suffix: ' *', prefix: generatorOptions.prefix, box: true)} output = $call;');
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
        forceBox: true,
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
    InternalObjcOptions generatorOptions,
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
            'initWithName:[NSString stringWithFormat:@"%@%@", @"${makeChannelName(api, func, dartPackageName)}", messageChannelSuffix]');
        indent.writeln('binaryMessenger:binaryMessenger');
        indent.write('codec:');
        indent.add(
            '${generatorOptions.prefix}Get${toUpperCamelCase(generatorOptions.fileSpecificClassNameComponent ?? '')}Codec()');

        if (taskQueue != null) {
          indent.newln();
          // See https://github.com/flutter/flutter/issues/162613 for why this
          // is in an ifdef instead of just relying on the parameter being
          // nullable.
          indent.format('''
#ifdef TARGET_OS_IOS
taskQueue:$taskQueue
#endif
];
''');
        } else {
          indent.addln('];');
        }
      });
    });
  }

  void _writeObjcSourceDataClassExtension(
    InternalObjcOptions languageOptions,
    Indent indent,
    Class classDefinition, {
    String? returnType,
    bool isOverflowClass = false,
  }) {
    final String className =
        _className(languageOptions.prefix, classDefinition.name);
    returnType = returnType ?? className;
    indent.newln();
    indent.writeln('@interface $className ()');
    indent.writeln(
        '+ ($returnType${isOverflowClass ? '' : ' *'})fromList:(NSArray<id> *)list;');
    if (!isOverflowClass) {
      indent.writeln(
          '+ (nullable $returnType *)nullableFromList:(NSArray<id> *)list;');
    }
    indent.writeln('- (NSArray<id> *)toList;');
    indent.writeln('@end');
  }

  void _writeObjcSourceClassInitializer(
    InternalObjcOptions languageOptions,
    Root root,
    Indent indent,
    Class classDefinition,
    String className,
  ) {
    _writeObjcSourceClassInitializerDeclaration(
      indent,
      languageOptions,
      root,
      classDefinition,
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
}

void _writeMethod(
  InternalObjcOptions languageOptions,
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
    forceBox: true,
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
              '${argNameFunc(count, arg)} == nil ? [NSNull null] : $argName';
        } else {
          varExpression = _getEnumToEnumBox(arg, argNameFunc(count, arg),
              prefix: languageOptions.prefix);
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
        'NSString *channelName = [NSString stringWithFormat:@"%@%@", @"${makeChannelName(api, func, dartPackageName)}", _messageChannelSuffix];');
    indent.writeln('FlutterBasicMessageChannel *channel =');

    indent.nest(1, () {
      indent.writeln('[FlutterBasicMessageChannel');
      indent.nest(1, () {
        indent.writeln('messageChannelWithName:channelName');
        indent.writeln('binaryMessenger:self.binaryMessenger');
        indent.write(
            'codec:${languageOptions.prefix}Get${toUpperCamelCase(languageOptions.fileSpecificClassNameComponent ?? '')}Codec()');
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
          const String nullCheck = 'reply[0] == [NSNull null] ? nil : reply[0]';
          if (func.returnType.isVoid) {
            indent.writeln('completion(nil);');
          } else {
            if (func.returnType.isEnum) {
              final String enumName = _enumName(func.returnType.baseName,
                  prefix: languageOptions.prefix, box: true);
              indent.writeln('$enumName *output = $nullCheck;');
            } else {
              indent.writeln('${returnType.beforeString}output = $nullCheck;');
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

/// Writes the method declaration for the initializer.
///
/// Example '+ (instancetype)makeWithFoo:(NSString *)foo'
void _writeObjcSourceClassInitializerDeclaration(
  Indent indent,
  InternalObjcOptions generatorOptions,
  Root root,
  Class classDefinition,
  String? prefix,
) {
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
    TypeDeclaration type, _ObjcType objcType, InternalObjcOptions options) {
  if (type.isVoid) {
    return 'void (^)(FlutterError *_Nullable)';
  } else if (type.isEnum) {
    return 'void (^)(${_enumName(type.baseName, suffix: ' *_Nullable', prefix: options.prefix, box: true)}, FlutterError *_Nullable)';
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
  String toString() =>
      hasAsterisk ? '$baseName$listGenericTag *' : '$baseName$listGenericTag';

  String get listGenericTag => baseName == 'NSArray' ? '<id>' : '';

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
  final String result = args.map<String>((TypeDeclaration e) {
    if (e.isEnum) {
      return _enumName(e.baseName,
          prefix: classPrefix, box: true, suffix: ' *');
    }
    return _objcTypeForDartType(classPrefix, e, forceBox: true).toString();
  }).join(', ');
  return result;
}

_ObjcType? _objcTypeForPrimitiveDartType(TypeDeclaration type,
    {bool forceBox = false}) {
  return forceBox || type.isNullable
      ? _objcTypeForNullableDartTypeMap[type.baseName]
      : _objcTypeForNonNullableDartTypeMap[type.baseName];
}

String? _objcTypeStringForPrimitiveDartType(
    String? classPrefix, TypeDeclaration type,
    {required bool beforeString, bool forceBox = false}) {
  final _ObjcType? objcType;
  if (forceBox || type.isNullable) {
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
    {bool forceBox = false}) {
  final _ObjcType? primitiveType =
      _objcTypeForPrimitiveDartType(field, forceBox: forceBox);
  return primitiveType == null
      ? _ObjcType(
          baseName: _className(classPrefix, field.baseName),
          // Non-nullable enums are non-pointer types.
          isPointer: !field.isEnum || (field.isNullable || forceBox))
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

String _capitalize(String str) =>
    str.isEmpty ? '' : str[0].toUpperCase() + str.substring(1);

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
  required InternalObjcOptions options,
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
void generateObjcHeader(
    InternalObjcOptions options, Root root, Indent indent) {}

String _arrayValue(NamedType field, String? prefix) {
  if (field.type.isEnum && !field.type.isNullable) {
    return _getEnumToEnumBox(field, 'self.${field.name}', prefix: prefix);
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
  indent
      .writeln('@property(nonatomic, strong) NSString *messageChannelSuffix;');
  indent.writeln('@end');
}

void _writeInitializers(Indent indent) {
  indent.write(
      '- (instancetype)initWithBinaryMessenger:(NSObject<FlutterBinaryMessenger> *)binaryMessenger ');
  indent.addScoped('{', '}', () {
    indent.writeln(
        'return [self initWithBinaryMessenger:binaryMessenger messageChannelSuffix:@""];');
  });
  indent.write(
      '- (instancetype)initWithBinaryMessenger:(NSObject<FlutterBinaryMessenger> *)binaryMessenger messageChannelSuffix:(nullable NSString*)messageChannelSuffix');
  indent.addScoped('{', '}', () {
    indent.writeln('self = [self init];');
    indent.write('if (self) ');
    indent.addScoped('{', '}', () {
      indent.writeln('_binaryMessenger = binaryMessenger;');
      indent.writeln(
          '_messageChannelSuffix = [messageChannelSuffix length] == 0 ? @"" : [NSString stringWithFormat: @".%@", messageChannelSuffix];');
    });
    indent.writeln('return self;');
  });
}

/// Looks through the AST for features that aren't supported by the ObjC
/// generator.
List<Error> validateObjc(InternalObjcOptions options, Root root) {
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

void _writeEnumBoxToEnum(
  Indent indent,
  NamedType field,
  String varName,
  String valueGetter, {
  String? prefix = '',
}) {
  indent.writeln(
      '${_enumName(field.type.baseName, prefix: prefix, box: true, suffix: ' *')}$varName = $valueGetter;');
}

String _getEnumToEnumBox(
  NamedType field,
  String valueSetter, {
  String? prefix = '',
}) {
  return '[[${_enumName(field.type.baseName, prefix: prefix, box: true)} alloc] initWithValue:$valueSetter]';
}

void _writeDataClassDeclaration(
  InternalObjcOptions generatorOptions,
  Root root,
  Indent indent,
  Class classDefinition,
) {
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
      prefix,
    );
    indent.addln(';');
  }
  for (final NamedType field
      in getFieldsInSerializationOrder(classDefinition)) {
    final HostDatatype hostDatatype = getFieldHostDatatype(
        field,
        (TypeDeclaration x) =>
            _objcTypeStringForPrimitiveDartType(prefix, x, beforeString: true),
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

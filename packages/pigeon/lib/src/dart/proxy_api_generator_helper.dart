// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:code_builder/code_builder.dart' as cb;
import 'package:collection/collection.dart';
import 'package:dart_style/dart_style.dart';

import '../ast.dart';
import '../functional.dart';
import '../generator_tools.dart';
import 'dart_generator.dart';
import 'templates.dart';

/// Converts fields and methods of an [AstProxyApi] constructor to the
/// `code_builder` Parameters.
Iterable<cb.Parameter> asConstructorParameters({
  required String apiName,
  required Iterable<Parameter> parameters,
  required Iterable<ApiField> unattachedFields,
  required Iterable<(Method, AstProxyApi)> flutterMethodsFromSuperClasses,
  required Iterable<(Method, AstProxyApi)> flutterMethodsFromInterfaces,
  required Iterable<Method> declaredFlutterMethods,
  bool defineType = true,
  bool includeBinaryMessengerAndInstanceManager = true,
}) sync* {
  if (includeBinaryMessengerAndInstanceManager) {
    yield cb.Parameter(
      (cb.ParameterBuilder builder) =>
          builder
            ..name = '${classMemberNamePrefix}binaryMessenger'
            ..named = true
            ..type = defineType ? cb.refer('BinaryMessenger?') : null
            ..toSuper = !defineType
            ..required = false,
    );
    yield cb.Parameter(
      (cb.ParameterBuilder builder) =>
          builder
            ..name = instanceManagerVarName
            ..named = true
            ..type =
                defineType ? cb.refer('$dartInstanceManagerClassName?') : null
            ..toSuper = !defineType
            ..required = false,
    );
  }

  for (final ApiField field in unattachedFields) {
    yield cb.Parameter(
      (cb.ParameterBuilder builder) =>
          builder
            ..name = field.name
            ..named = true
            ..type =
                defineType
                    ? cb.refer(addGenericTypesNullable(field.type))
                    : null
            ..toThis = !defineType
            ..required = !field.type.isNullable,
    );
  }

  for (final (Method method, AstProxyApi api)
      in flutterMethodsFromSuperClasses) {
    yield cb.Parameter(
      (cb.ParameterBuilder builder) =>
          builder
            ..name = method.name
            ..named = true
            ..type =
                defineType
                    ? methodAsFunctionType(method, apiName: api.name)
                    : null
            ..toSuper = !defineType
            ..required = method.isRequired,
    );
  }

  for (final (Method method, AstProxyApi api) in flutterMethodsFromInterfaces) {
    yield cb.Parameter(
      (cb.ParameterBuilder builder) =>
          builder
            ..name = method.name
            ..named = true
            ..type =
                defineType
                    ? methodAsFunctionType(method, apiName: api.name)
                    : null
            ..toThis = !defineType
            ..required = method.isRequired,
    );
  }

  for (final Method method in declaredFlutterMethods) {
    yield cb.Parameter(
      (cb.ParameterBuilder builder) =>
          builder
            ..name = method.name
            ..named = true
            ..type =
                defineType
                    ? methodAsFunctionType(method, apiName: apiName)
                    : null
            ..toThis = !defineType
            ..required = method.isRequired,
    );
  }

  yield* parameters.mapIndexed(
    (int index, NamedType parameter) => cb.Parameter(
      (cb.ParameterBuilder builder) =>
          builder
            ..name = getParameterName(index, parameter)
            ..type = refer(parameter.type)
            ..named = true
            ..required = !parameter.type.isNullable,
    ),
  );
}

/// Converts all the constructors of each AstProxyApi into `code_builder` fields
/// that are used to override the corresponding factory constructor of the
/// generated Dart proxy class.
Iterable<cb.Field> overridesClassConstructors(
  Iterable<AstProxyApi> proxyApis,
) sync* {
  for (final AstProxyApi api in proxyApis) {
    final String lowerCamelCaseApiName = toLowerCamelCase(api.name);

    for (final Constructor constructor in api.constructors) {
      yield cb.Field((cb.FieldBuilder builder) {
        final String constructorName =
            constructor.name.isEmpty ? 'new' : constructor.name;
        final Iterable<cb.Parameter> parameters = asConstructorParameters(
          apiName: api.name,
          parameters: constructor.parameters,
          unattachedFields: api.unattachedFields,
          flutterMethodsFromSuperClasses:
              api.flutterMethodsFromSuperClassesWithApis(),
          flutterMethodsFromInterfaces:
              api.flutterMethodsFromInterfacesWithApis(),
          declaredFlutterMethods: api.flutterMethods,
          includeBinaryMessengerAndInstanceManager: false,
        );
        builder
          ..name =
              constructor.name.isEmpty
                  ? '${lowerCamelCaseApiName}_new'
                  : '${lowerCamelCaseApiName}_${constructor.name}'
          ..static = true
          ..docs.add('/// Overrides [${api.name}.$constructorName].')
          ..type = cb.FunctionType(
            (cb.FunctionTypeBuilder builder) =>
                builder
                  ..returnType = cb.refer(api.name)
                  ..isNullable = true
                  ..namedRequiredParameters.addAll(<String, cb.Reference>{
                    for (final cb.Parameter parameter in parameters.where(
                      (cb.Parameter parameter) => parameter.required,
                    ))
                      parameter.name: parameter.type!,
                  })
                  ..namedParameters.addAll(<String, cb.Reference>{
                    for (final cb.Parameter parameter in parameters.where(
                      (cb.Parameter parameter) => !parameter.required,
                    ))
                      parameter.name: parameter.type!,
                  }),
          );
      });
    }
  }
}

/// Converts all the static fields of each AstProxyApi into `code_builder`
/// fields that are used to override the corresponding static field of the
/// generated Dart proxy class.
Iterable<cb.Field> overridesClassStaticFields(
  Iterable<AstProxyApi> proxyApis,
) sync* {
  for (final AstProxyApi api in proxyApis) {
    final String lowerCamelCaseApiName = toLowerCamelCase(api.name);

    for (final ApiField field in api.fields.where(
      (ApiField field) => field.isStatic,
    )) {
      yield cb.Field((cb.FieldBuilder builder) {
        builder
          ..name = '${lowerCamelCaseApiName}_${field.name}'
          ..static = true
          ..docs.add('/// Overrides [${api.name}.${field.name}].')
          ..type = cb.refer('${field.type.baseName}?');
      });
    }
  }
}

/// Converts all the static methods of each AstProxyApi into `code_builder`
/// fields that are used to override the corresponding static method of the
/// generated Dart proxy class.
Iterable<cb.Field> overridesClassStaticMethods(
  Iterable<AstProxyApi> proxyApis,
) sync* {
  for (final AstProxyApi api in proxyApis) {
    final String lowerCamelCaseApiName = toLowerCamelCase(api.name);

    for (final Method method in api.hostMethods.where(
      (Method method) => method.isStatic,
    )) {
      yield cb.Field((cb.FieldBuilder builder) {
        builder
          ..name = '${lowerCamelCaseApiName}_${method.name}'
          ..static = true
          ..docs.add('/// Overrides [${api.name}.${method.name}].')
          ..type = cb.FunctionType((cb.FunctionTypeBuilder builder) {
            builder
              ..isNullable = true
              ..returnType = refer(method.returnType, asFuture: true)
              ..requiredParameters.addAll(<cb.Reference>[
                for (final Parameter parameter in method.parameters)
                  refer(parameter.type),
              ]);
          });
      });
    }
  }
}

/// Creates the reset method for the `PigeonOverrides` class that sets all
/// overrideable methods to null.
cb.Method overridesClassResetMethod(Iterable<AstProxyApi> proxyApis) {
  return cb.Method.returnsVoid((cb.MethodBuilder builder) {
    builder
      ..name = '${classMemberNamePrefix}reset'
      ..static = true
      ..docs.addAll(<String>[
        '/// Sets all overridden ProxyApi class members to null.',
      ])
      ..body = cb.Block.of(<cb.Code>[
        for (final AstProxyApi api in proxyApis) ...<cb.Code>[
          for (final Constructor constructor in api.constructors)
            cb.Code(
              '${toLowerCamelCase(api.name)}_${constructor.name.isEmpty ? 'new' : constructor.name} = null;',
            ),
          for (final ApiField attachedField in api.fields.where(
            (ApiField field) => field.isStatic,
          ))
            cb.Code(
              '${toLowerCamelCase(api.name)}_${attachedField.name} = null;',
            ),
          for (final Method staticMethod in api.methods.where(
            (Method method) => method.isStatic,
          ))
            cb.Code(
              '${toLowerCamelCase(api.name)}_${staticMethod.name} = null;',
            ),
        ],
      ]);
  });
}

/// Converts a method to a `code_builder` FunctionType with all parameters as
/// positional arguments.
cb.FunctionType methodAsFunctionType(Method method, {required String apiName}) {
  return cb.FunctionType(
    (cb.FunctionTypeBuilder builder) =>
        builder
          ..returnType = refer(
            method.returnType,
            asFuture: method.isAsynchronous,
          )
          ..isNullable = !method.isRequired
          ..requiredParameters.addAll(<cb.Reference>[
            if (method.location == ApiLocation.flutter)
              cb.refer('$apiName ${classMemberNamePrefix}instance'),
            ...method.parameters.mapIndexed((int index, NamedType parameter) {
              return cb.refer(
                '${addGenericTypesNullable(parameter.type)} ${getParameterName(index, parameter)}',
              );
            }),
          ]),
  );
}

/// Converts static attached Fields from the pigeon AST to `code_builder`
/// Method.
///
/// Static attached fields return an overrideable test value or returns the
/// private static instance.
///
/// Example Output:
///
/// ```dart
/// static MyClass get instance => PigeonMyClassOverrides.instance ?? _instance;
/// ```
Iterable<cb.Method> staticAttachedFieldsGetters(
  Iterable<ApiField> fields, {
  required String apiName,
}) sync* {
  for (final ApiField field in fields) {
    yield cb.Method(
      (cb.MethodBuilder builder) =>
          builder
            ..name = field.name
            ..type = cb.MethodType.getter
            ..static = true
            ..returns = cb.refer(addGenericTypesNullable(field.type))
            ..docs.addAll(
              asDocumentationComments(
                field.documentationComments,
                docCommentSpec,
              ),
            )
            ..lambda = true
            ..body = cb.Code(
              '$proxyApiOverridesClassName.${toLowerCamelCase(apiName)}_${field.name} ?? _${field.name}',
            ),
    );
  }
}

/// Write the `PigeonOverrides` class that provides overrides for constructors
/// and static members of each generated Dart proxy class.
void writeProxyApiPigeonOverrides(
  Indent indent, {
  required DartFormatter formatter,
  required Iterable<AstProxyApi> proxyApis,
}) {
  final cb.Class proxyApiOverrides = cb.Class(
    (cb.ClassBuilder builder) =>
        builder
          ..name = proxyApiOverridesClassName
          ..annotations.add(cb.refer('visibleForTesting'))
          ..docs.addAll(<String>[
            '/// Provides overrides for the constructors and static members of each',
            '/// Dart proxy class.',
            '///',
            '/// This is only intended to be used with unit tests to prevent errors from',
            '/// making message calls in a unit test.',
            '///',
            '/// See [$proxyApiOverridesClassName.${classMemberNamePrefix}reset] to set all overrides back to null.',
          ])
          ..fields.addAll(overridesClassConstructors(proxyApis))
          ..fields.addAll(overridesClassStaticFields(proxyApis))
          ..fields.addAll(overridesClassStaticMethods(proxyApis))
          ..methods.add(overridesClassResetMethod(proxyApis)),
  );

  final cb.DartEmitter emitter = cb.DartEmitter(useNullSafetySyntax: true);
  indent.format(formatter.format('${proxyApiOverrides.accept(emitter)}'));
}

/// Converts constructors from an [AstProxyApi] to `code_builder` constructors.
///
/// Creates a factory constructor that can return an overrideable static
/// method for testing and a constructor that calls to the native type API.
Iterable<cb.Constructor> constructors(
  Iterable<Constructor> constructors, {
  required String apiName,
  required String dartPackageName,
  required String codecName,
  required String codecInstanceName,
  required AstProxyApi? superClassApi,
  required Iterable<ApiField> unattachedFields,
  required Iterable<(Method, AstProxyApi)> flutterMethodsFromSuperClasses,
  required Iterable<(Method, AstProxyApi)> flutterMethodsFromInterfaces,
  required Iterable<Method> declaredFlutterMethods,
}) sync* {
  final cb.Parameter binaryMessengerParameter = cb.Parameter(
    (cb.ParameterBuilder builder) =>
        builder
          ..name = '${classMemberNamePrefix}binaryMessenger'
          ..named = true
          ..toSuper = true,
  );

  for (final Constructor constructor in constructors) {
    final String? factoryConstructorName =
        constructor.name.isNotEmpty ? constructor.name : null;
    final String constructorName =
        '$classMemberNamePrefix${constructor.name.isNotEmpty ? constructor.name : 'new'}';
    final String overridesConstructorName =
        constructor.name.isNotEmpty
            ? '${toLowerCamelCase(apiName)}_${constructor.name}'
            : '${toLowerCamelCase(apiName)}_new';

    // Factory constructor that forwards the parameters to the overrides class
    // or to the constructor yielded below this one.
    yield cb.Constructor((cb.ConstructorBuilder builder) {
      final Iterable<cb.Parameter> parameters = asConstructorParameters(
        apiName: apiName,
        parameters: constructor.parameters,
        unattachedFields: unattachedFields,
        flutterMethodsFromSuperClasses: flutterMethodsFromSuperClasses,
        flutterMethodsFromInterfaces: flutterMethodsFromInterfaces,
        declaredFlutterMethods: declaredFlutterMethods,
      );
      final Iterable<cb.Parameter> parametersWithoutMessengerAndManager =
          asConstructorParameters(
            apiName: apiName,
            parameters: constructor.parameters,
            unattachedFields: unattachedFields,
            flutterMethodsFromSuperClasses: flutterMethodsFromSuperClasses,
            flutterMethodsFromInterfaces: flutterMethodsFromInterfaces,
            declaredFlutterMethods: declaredFlutterMethods,
            includeBinaryMessengerAndInstanceManager: false,
          );
      builder
        ..name = factoryConstructorName
        ..factory = true
        ..docs.addAll(
          asDocumentationComments(
            constructor.documentationComments,
            docCommentSpec,
          ),
        )
        ..optionalParameters.addAll(parameters)
        ..body = cb.Block((cb.BlockBuilder builder) {
          final Map<String, cb.Expression> forwardedParams =
              <String, cb.Expression>{
                for (final cb.Parameter parameter in parameters)
                  parameter.name: cb.refer(parameter.name),
              };
          final Map<String, cb.Expression>
          forwardedParamsWithoutMessengerAndManager = <String, cb.Expression>{
            for (final cb.Parameter parameter
                in parametersWithoutMessengerAndManager)
              parameter.name: cb.refer(parameter.name),
          };

          builder.statements.addAll(<cb.Code>[
            cb.Code(
              'if ($proxyApiOverridesClassName.$overridesConstructorName != null) {',
            ),
            cb.CodeExpression(
                  cb.Code(
                    '$proxyApiOverridesClassName.$overridesConstructorName!',
                  ),
                )
                .call(
                  <cb.Expression>[],
                  forwardedParamsWithoutMessengerAndManager,
                )
                .returned
                .statement,
            const cb.Code('}'),
            cb.CodeExpression(
              cb.Code('$apiName.$constructorName'),
            ).call(<cb.Expression>[], forwardedParams).returned.statement,
          ]);
        });
    });

    yield cb.Constructor((cb.ConstructorBuilder builder) {
      final String channelName = makeChannelNameWithStrings(
        apiName: apiName,
        methodName:
            constructor.name.isNotEmpty
                ? constructor.name
                : '${classMemberNamePrefix}defaultConstructor',
        dartPackageName: dartPackageName,
      );
      builder
        ..name = constructorName
        ..annotations.add(cb.refer('protected'))
        ..docs.addAll(
          asDocumentationComments(
            constructor.documentationComments,
            docCommentSpec,
          ),
        )
        ..optionalParameters.addAll(
          asConstructorParameters(
            apiName: apiName,
            parameters: constructor.parameters,
            unattachedFields: unattachedFields,
            flutterMethodsFromSuperClasses: flutterMethodsFromSuperClasses,
            flutterMethodsFromInterfaces: flutterMethodsFromInterfaces,
            declaredFlutterMethods: declaredFlutterMethods,
            defineType: false,
          ),
        )
        ..initializers.addAll(<cb.Code>[
          if (superClassApi != null)
            const cb.Code('super.${classMemberNamePrefix}detached()'),
        ])
        ..body = cb.Block((cb.BlockBuilder builder) {
          final StringBuffer messageCallSink = StringBuffer();
          DartGenerator.writeHostMethodMessageCall(
            Indent(messageCallSink),
            addSuffixVariable: false,
            channelName: channelName,
            insideAsyncMethod: false,
            parameters: <Parameter>[
              Parameter(
                name: '${varNamePrefix}instanceIdentifier',
                type: const TypeDeclaration(baseName: 'int', isNullable: false),
              ),
              ...unattachedFields.map(
                (ApiField field) =>
                    Parameter(name: field.name, type: field.type),
              ),
              ...constructor.parameters,
            ],
            returnType: const TypeDeclaration.voidDeclaration(),
          );

          builder.statements.addAll(<cb.Code>[
            const cb.Code(
              'final int ${varNamePrefix}instanceIdentifier = $instanceManagerVarName.addDartCreatedInstance(this);',
            ),
            cb.Code(
              'final $codecName $pigeonChannelCodec =\n'
              '    $codecInstanceName;',
            ),
            cb.Code(
              'final BinaryMessenger? ${varNamePrefix}binaryMessenger = ${binaryMessengerParameter.name};',
            ),
            cb.Code(messageCallSink.toString()),
          ]);
        });
    });
  }
}

/// The detached constructor present for every Dart proxy class.
///
/// This constructor doesn't include a host method call to create a new native
/// type instance. It is mainly used when the native type API makes a Flutter
/// method call to instantiate a Dart proxy class instance or when the
/// `InstanceManager` wants to create a copy to be used for automatic garbage
/// collection.
cb.Constructor detachedConstructor({
  required String apiName,
  required AstProxyApi? superClassApi,
  required Iterable<ApiField> unattachedFields,
  required Iterable<(Method, AstProxyApi)> flutterMethodsFromSuperClasses,
  required Iterable<(Method, AstProxyApi)> flutterMethodsFromInterfaces,
  required Iterable<Method> declaredFlutterMethods,
}) {
  return cb.Constructor(
    (cb.ConstructorBuilder builder) =>
        builder
          ..name = '${classMemberNamePrefix}detached'
          ..docs.addAll(<String>[
            '/// Constructs [$apiName] without creating the associated native object.',
            '///',
            '/// This should only be used by subclasses created by this library or to',
            '/// create copies for an [$dartInstanceManagerClassName].',
          ])
          ..annotations.add(cb.refer('protected'))
          ..optionalParameters.addAll(
            asConstructorParameters(
              apiName: apiName,
              parameters: <Parameter>[],
              unattachedFields: unattachedFields,
              flutterMethodsFromSuperClasses: flutterMethodsFromSuperClasses,
              flutterMethodsFromInterfaces: flutterMethodsFromInterfaces,
              declaredFlutterMethods: declaredFlutterMethods,
              defineType: false,
            ),
          )
          ..initializers.addAll(<cb.Code>[
            if (superClassApi != null)
              const cb.Code('super.${classMemberNamePrefix}detached()'),
          ]),
  );
}

/// A private Field of the base codec.
cb.Field codecInstanceField({
  required String codecInstanceName,
  required String codecName,
}) {
  return cb.Field(
    (cb.FieldBuilder builder) =>
        builder
          ..name = codecInstanceName
          ..type = cb.refer(codecName)
          ..late = true
          ..modifier = cb.FieldModifier.final$
          ..assignment = cb.Code('$codecName($instanceManagerVarName)'),
  );
}

/// Converts unattached fields from the pigeon AST to `code_builder`
/// Fields.
Iterable<cb.Field> unattachedFields(Iterable<ApiField> fields) sync* {
  for (final ApiField field in fields) {
    yield cb.Field(
      (cb.FieldBuilder builder) =>
          builder
            ..name = field.name
            ..type = cb.refer(addGenericTypesNullable(field.type))
            ..modifier = cb.FieldModifier.final$
            ..docs.addAll(
              asDocumentationComments(
                field.documentationComments,
                docCommentSpec,
              ),
            ),
    );
  }
}

/// Converts Flutter methods from [AstProxyApi] to `code_builder` fields.
///
/// Flutter methods of a ProxyApi are represented as an anonymous function for
/// an instance of a Dart proxy class, so this converts methods to a `Function`
/// type field.
Iterable<cb.Field> flutterMethodFields(
  Iterable<Method> methods, {
  required String apiName,
}) sync* {
  for (final Method method in methods) {
    yield cb.Field(
      (cb.FieldBuilder builder) =>
          builder
            ..name = method.name
            ..modifier = cb.FieldModifier.final$
            ..docs.addAll(
              asDocumentationComments(<String>[
                ...method.documentationComments,
                ...<String>[
                  if (method.documentationComments.isEmpty) 'Callback method.',
                  '',
                  'For the associated Native object to be automatically garbage collected,',
                  "it is required that the implementation of this `Function` doesn't have a",
                  'strong reference to the encapsulating class instance. When this `Function`',
                  'references a non-local variable, it is strongly recommended to access it',
                  'with a `WeakReference`:',
                  '',
                  '```dart',
                  'final WeakReference weakMyVariable = WeakReference(myVariable);',
                  'final $apiName instance = $apiName(',
                  '  ${method.name}: ($apiName ${classMemberNamePrefix}instance, ...) {',
                  '    print(weakMyVariable?.target);',
                  '  },',
                  ');',
                  '```',
                  '',
                  'Alternatively, [$dartInstanceManagerClassName.removeWeakReference] can be used to',
                  'release the associated Native object manually.',
                ],
              ], docCommentSpec),
            )
            ..type = methodAsFunctionType(method, apiName: apiName),
    );
  }
}

/// Converts the Flutter methods from the [AstProxyApi] to `code_builder`
/// fields.
///
/// Flutter methods of a ProxyApi are represented as an anonymous function for
/// an instance of a Dart proxy class, so this converts methods to a `Function`
/// type field.
///
/// This is similar to [_proxyApiFlutterMethodFields] except all the methods are
/// inherited from [AstProxyApi]s that are being implemented (following the
/// `implements` keyword).
Iterable<cb.Field> interfaceApiFields(
  Iterable<AstProxyApi> apisOfInterfaces,
) sync* {
  for (final AstProxyApi proxyApi in apisOfInterfaces) {
    for (final Method method in proxyApi.methods) {
      yield cb.Field(
        (cb.FieldBuilder builder) =>
            builder
              ..name = method.name
              ..modifier = cb.FieldModifier.final$
              ..annotations.add(cb.refer('override'))
              ..docs.addAll(
                asDocumentationComments(
                  method.documentationComments,
                  docCommentSpec,
                ),
              )
              ..type = cb.FunctionType(
                (cb.FunctionTypeBuilder builder) =>
                    builder
                      ..returnType = refer(
                        method.returnType,
                        asFuture: method.isAsynchronous,
                      )
                      ..isNullable = !method.isRequired
                      ..requiredParameters.addAll(<cb.Reference>[
                        cb.refer(
                          '${proxyApi.name} ${classMemberNamePrefix}instance',
                        ),
                        ...method.parameters.mapIndexed((
                          int index,
                          NamedType parameter,
                        ) {
                          return cb.refer(
                            '${addGenericTypesNullable(parameter.type)} ${getParameterName(index, parameter)}',
                          );
                        }),
                      ]),
              ),
      );
    }
  }
}

/// Converts attached Fields from the pigeon AST to `code_builder` Field.
///
/// Attached fields are set lazily by calling a private method that returns
/// it.
///
/// Example Output:
///
/// ```dart
/// final MyOtherProxyApiClass value = _pigeon_value();
/// ```
Iterable<cb.Field> attachedFields(Iterable<ApiField> fields) sync* {
  for (final ApiField field in fields) {
    yield cb.Field(
      (cb.FieldBuilder builder) =>
          builder
            ..name = '${field.isStatic ? '_' : ''}${field.name}'
            ..type = cb.refer(addGenericTypesNullable(field.type))
            ..modifier = cb.FieldModifier.final$
            ..static = field.isStatic
            ..late = !field.isStatic
            ..docs.addAll(
              asDocumentationComments(
                field.documentationComments,
                docCommentSpec,
              ),
            )
            ..assignment = cb.Code('$varNamePrefix${field.name}()'),
    );
  }
}

/// Creates the static `setUpMessageHandlers` method for a Dart proxy class.
///
/// This method handles setting the message handler for every un-inherited
/// Flutter method.
///
/// This also adds a handler to receive a call from the platform to
/// instantiate a new Dart instance if [AstProxyApi.hasCallbackConstructor] is
/// set to true.
cb.Method setUpMessageHandlerMethod({
  required Iterable<Method> flutterMethods,
  required String apiName,
  required String dartPackageName,
  required String codecName,
  required Iterable<ApiField> unattachedFields,
  required bool hasCallbackConstructor,
}) {
  final bool hasAnyMessageHandlers =
      hasCallbackConstructor || flutterMethods.isNotEmpty;
  return cb.Method.returnsVoid(
    (cb.MethodBuilder builder) =>
        builder
          ..name = '${classMemberNamePrefix}setUpMessageHandlers'
          ..returns = cb.refer('void')
          ..static = true
          ..optionalParameters.addAll(<cb.Parameter>[
            cb.Parameter(
              (cb.ParameterBuilder builder) =>
                  builder
                    ..name = '${classMemberNamePrefix}clearHandlers'
                    ..type = cb.refer('bool')
                    ..named = true
                    ..defaultTo = const cb.Code('false'),
            ),
            cb.Parameter(
              (cb.ParameterBuilder builder) =>
                  builder
                    ..name = '${classMemberNamePrefix}binaryMessenger'
                    ..named = true
                    ..type = cb.refer('BinaryMessenger?'),
            ),
            cb.Parameter(
              (cb.ParameterBuilder builder) =>
                  builder
                    ..name = instanceManagerVarName
                    ..named = true
                    ..type = cb.refer('$dartInstanceManagerClassName?'),
            ),
            if (hasCallbackConstructor)
              cb.Parameter(
                (cb.ParameterBuilder builder) =>
                    builder
                      ..name = '${classMemberNamePrefix}newInstance'
                      ..named = true
                      ..type = cb.FunctionType(
                        (cb.FunctionTypeBuilder builder) =>
                            builder
                              ..returnType = cb.refer(apiName)
                              ..isNullable = true
                              ..requiredParameters.addAll(
                                unattachedFields.mapIndexed((
                                  int index,
                                  ApiField field,
                                ) {
                                  return cb.refer(
                                    '${addGenericTypesNullable(field.type)} ${getParameterName(index, field)}',
                                  );
                                }),
                              ),
                      ),
              ),
            for (final Method method in flutterMethods)
              cb.Parameter(
                (cb.ParameterBuilder builder) =>
                    builder
                      ..name = method.name
                      ..type = cb.FunctionType(
                        (cb.FunctionTypeBuilder builder) =>
                            builder
                              ..returnType = refer(
                                method.returnType,
                                asFuture: method.isAsynchronous,
                              )
                              ..isNullable = true
                              ..requiredParameters.addAll(<cb.Reference>[
                                cb.refer(
                                  '$apiName ${classMemberNamePrefix}instance',
                                ),
                                ...method.parameters.mapIndexed((
                                  int index,
                                  NamedType parameter,
                                ) {
                                  return cb.refer(
                                    '${addGenericTypesNullable(parameter.type)} ${getParameterName(index, parameter)}',
                                  );
                                }),
                              ]),
                      ),
              ),
          ])
          ..body = cb.Block.of(<cb.Code>[
            if (hasAnyMessageHandlers) ...<cb.Code>[
              cb.Code(
                'final $codecName $pigeonChannelCodec = $codecName($instanceManagerVarName ?? $dartInstanceManagerClassName.instance);',
              ),
              const cb.Code(
                'final BinaryMessenger? binaryMessenger = ${classMemberNamePrefix}binaryMessenger;',
              ),
            ],
            if (hasCallbackConstructor)
              ...cb.Block((cb.BlockBuilder builder) {
                final StringBuffer messageHandlerSink = StringBuffer();
                const String methodName = '${classMemberNamePrefix}newInstance';
                DartGenerator.writeFlutterMethodMessageHandler(
                  Indent(messageHandlerSink),
                  name: methodName,
                  parameters: <Parameter>[
                    Parameter(
                      name: '${classMemberNamePrefix}instanceIdentifier',
                      type: const TypeDeclaration(
                        baseName: 'int',
                        isNullable: false,
                      ),
                    ),
                    ...unattachedFields.map((ApiField field) {
                      return Parameter(name: field.name, type: field.type);
                    }),
                  ],
                  returnType: const TypeDeclaration.voidDeclaration(),
                  channelName: makeChannelNameWithStrings(
                    apiName: apiName,
                    methodName: methodName,
                    dartPackageName: dartPackageName,
                  ),
                  isMockHandler: false,
                  isAsynchronous: false,
                  nullHandlerExpression:
                      '${classMemberNamePrefix}clearHandlers',
                  onCreateApiCall: (
                    String methodName,
                    Iterable<Parameter> parameters,
                    Iterable<String> safeArgumentNames,
                  ) {
                    final String argsAsNamedParams =
                        map2(parameters, safeArgumentNames, (
                          Parameter parameter,
                          String safeArgName,
                        ) {
                          return '${parameter.name}: $safeArgName,\n';
                        }).skip(1).join();

                    return '($instanceManagerVarName ?? $dartInstanceManagerClassName.instance)\n'
                        '    .addHostCreatedInstance(\n'
                        '  $methodName?.call(${safeArgumentNames.skip(1).join(',')}) ??\n'
                        '      $apiName.${classMemberNamePrefix}detached('
                        '        ${classMemberNamePrefix}binaryMessenger: ${classMemberNamePrefix}binaryMessenger,\n'
                        '        $instanceManagerVarName: $instanceManagerVarName,\n'
                        '        $argsAsNamedParams\n'
                        '      ),\n'
                        '  ${safeArgumentNames.first},\n'
                        ')';
                  },
                );
                builder.statements.add(cb.Code(messageHandlerSink.toString()));
              }).statements,
            for (final Method method in flutterMethods)
              ...cb.Block((cb.BlockBuilder builder) {
                final StringBuffer messageHandlerSink = StringBuffer();
                DartGenerator.writeFlutterMethodMessageHandler(
                  Indent(messageHandlerSink),
                  name: method.name,
                  parameters: <Parameter>[
                    Parameter(
                      name: '${classMemberNamePrefix}instance',
                      type: TypeDeclaration(
                        baseName: apiName,
                        isNullable: false,
                      ),
                    ),
                    ...method.parameters,
                  ],
                  returnType: TypeDeclaration(
                    baseName: method.returnType.baseName,
                    isNullable:
                        !method.isRequired || method.returnType.isNullable,
                    typeArguments: method.returnType.typeArguments,
                    associatedEnum: method.returnType.associatedEnum,
                    associatedClass: method.returnType.associatedClass,
                    associatedProxyApi: method.returnType.associatedProxyApi,
                  ),
                  channelName: makeChannelNameWithStrings(
                    apiName: apiName,
                    methodName: method.name,
                    dartPackageName: dartPackageName,
                  ),
                  isMockHandler: false,
                  isAsynchronous: method.isAsynchronous,
                  nullHandlerExpression:
                      '${classMemberNamePrefix}clearHandlers',
                  onCreateApiCall: (
                    String methodName,
                    Iterable<Parameter> parameters,
                    Iterable<String> safeArgumentNames,
                  ) {
                    final String nullability = method.isRequired ? '' : '?';
                    return '($methodName ?? ${safeArgumentNames.first}.$methodName)$nullability.call(${safeArgumentNames.join(',')})';
                  },
                );
                builder.statements.add(cb.Code(messageHandlerSink.toString()));
              }).statements,
          ]),
  );
}

/// Converts attached fields from the pigeon AST to `code_builder` Methods.
///
/// These private methods are used to lazily instantiate attached fields. The
/// instance is created and returned synchronously while the native instance
/// is created asynchronously. This is similar to how constructors work.
Iterable<cb.Method> attachedFieldMethods(
  Iterable<ApiField> fields, {
  required String apiName,
  required String dartPackageName,
  required String codecInstanceName,
  required String codecName,
}) sync* {
  for (final ApiField field in fields) {
    yield cb.Method((cb.MethodBuilder builder) {
      final String type = addGenericTypesNullable(field.type);
      const String instanceName = '${varNamePrefix}instance';
      const String identifierInstanceName =
          '${varNamePrefix}instanceIdentifier';
      builder
        ..name = '$varNamePrefix${field.name}'
        ..static = field.isStatic
        ..returns = cb.refer(type)
        ..body = cb.Block((cb.BlockBuilder builder) {
          final StringBuffer messageCallSink = StringBuffer();
          DartGenerator.writeHostMethodMessageCall(
            Indent(messageCallSink),
            addSuffixVariable: false,
            channelName: makeChannelNameWithStrings(
              apiName: apiName,
              methodName: field.name,
              dartPackageName: dartPackageName,
            ),
            parameters: <Parameter>[
              if (!field.isStatic)
                Parameter(
                  name: 'this',
                  type: TypeDeclaration(baseName: apiName, isNullable: false),
                ),
              Parameter(
                name: identifierInstanceName,
                type: const TypeDeclaration(baseName: 'int', isNullable: false),
              ),
            ],
            returnType: const TypeDeclaration.voidDeclaration(),
          );
          builder.statements.addAll(<cb.Code>[
            if (!field.isStatic) ...<cb.Code>[
              cb.Code(
                'final $type $instanceName = $type.${classMemberNamePrefix}detached(\n'
                '  ${classMemberNamePrefix}binaryMessenger: ${classMemberNamePrefix}binaryMessenger,\n'
                '  ${classMemberNamePrefix}instanceManager: ${classMemberNamePrefix}instanceManager,\n'
                ');',
              ),
              cb.Code(
                'final $codecName $pigeonChannelCodec =\n'
                '    $codecInstanceName;',
              ),
              const cb.Code(
                'final BinaryMessenger? ${varNamePrefix}binaryMessenger = ${classMemberNamePrefix}binaryMessenger;',
              ),
              const cb.Code(
                'final int $identifierInstanceName = $instanceManagerVarName.addDartCreatedInstance($instanceName);',
              ),
            ] else ...<cb.Code>[
              cb.Code(
                'final $type $instanceName = $type.${classMemberNamePrefix}detached();',
              ),
              cb.Code(
                'final $codecName $pigeonChannelCodec = $codecName($dartInstanceManagerClassName.instance);',
              ),
              const cb.Code(
                'final BinaryMessenger ${varNamePrefix}binaryMessenger = ServicesBinding.instance.defaultBinaryMessenger;',
              ),
              const cb.Code(
                'final int $identifierInstanceName = $dartInstanceManagerClassName.instance.addDartCreatedInstance($instanceName);',
              ),
            ],
            const cb.Code('() async {'),
            cb.Code(messageCallSink.toString()),
            const cb.Code('}();'),
            const cb.Code('return $instanceName;'),
          ]);
        });
    });
  }
}

/// Converts host methods from [AstProxyApi] to `code_builder` Methods.
///
/// This creates methods like a HostApi except that the message call includes
/// the calling Dart proxy class instance if the method is not static.
Iterable<cb.Method> hostMethods(
  Iterable<Method> methods, {
  required String apiName,
  required String dartPackageName,
  required String codecInstanceName,
  required String codecName,
}) sync* {
  for (final Method method in methods) {
    assert(method.location == ApiLocation.host);
    final Iterable<cb.Parameter> parameters = method.parameters.mapIndexed(
      (int index, NamedType parameter) => cb.Parameter(
        (cb.ParameterBuilder builder) =>
            builder
              ..name = getParameterName(index, parameter)
              ..type = cb.refer(addGenericTypesNullable(parameter.type)),
      ),
    );
    yield cb.Method(
      (cb.MethodBuilder builder) =>
          builder
            ..name = method.name
            ..static = method.isStatic
            ..modifier = cb.MethodModifier.async
            ..docs.addAll(
              asDocumentationComments(
                method.documentationComments,
                docCommentSpec,
              ),
            )
            ..returns = refer(method.returnType, asFuture: true)
            ..requiredParameters.addAll(parameters)
            ..optionalParameters.addAll(<cb.Parameter>[
              if (method.isStatic) ...<cb.Parameter>[
                cb.Parameter(
                  (cb.ParameterBuilder builder) =>
                      builder
                        ..name = '${classMemberNamePrefix}binaryMessenger'
                        ..type = cb.refer('BinaryMessenger?')
                        ..named = true,
                ),
                cb.Parameter(
                  (cb.ParameterBuilder builder) =>
                      builder
                        ..name = instanceManagerVarName
                        ..type = cb.refer('$dartInstanceManagerClassName?'),
                ),
              ],
            ])
            ..body = cb.Block((cb.BlockBuilder builder) {
              final StringBuffer messageCallSink = StringBuffer();
              DartGenerator.writeHostMethodMessageCall(
                Indent(messageCallSink),
                addSuffixVariable: false,
                channelName: makeChannelNameWithStrings(
                  apiName: apiName,
                  methodName: method.name,
                  dartPackageName: dartPackageName,
                ),
                parameters: <Parameter>[
                  if (!method.isStatic)
                    Parameter(
                      name: 'this',
                      type: TypeDeclaration(
                        baseName: apiName,
                        isNullable: false,
                      ),
                    ),
                  ...method.parameters,
                ],
                returnType: method.returnType,
              );
              builder.statements.addAll(<cb.Code>[
                if (method.isStatic) ...<cb.Code>[
                  cb.Code(
                    'if ($proxyApiOverridesClassName.${toLowerCamelCase(apiName)}_${method.name} != null) {',
                  ),
                  cb.CodeExpression(
                        cb.Code(
                          '$proxyApiOverridesClassName.${toLowerCamelCase(apiName)}_${method.name}!',
                        ),
                      )
                      .call(
                        parameters.map(
                          (cb.Parameter parameter) => cb.refer(parameter.name),
                        ),
                      )
                      .returned
                      .statement,
                  const cb.Code('}'),
                ],
                if (!method.isStatic)
                  cb.Code(
                    'final $codecName $pigeonChannelCodec =\n'
                    '    $codecInstanceName;',
                  )
                else
                  cb.Code(
                    'final $codecName $pigeonChannelCodec = $codecName($instanceManagerVarName ?? $dartInstanceManagerClassName.instance);',
                  ),
                const cb.Code(
                  'final BinaryMessenger? ${varNamePrefix}binaryMessenger = ${classMemberNamePrefix}binaryMessenger;',
                ),
                cb.Code(messageCallSink.toString()),
              ]);
            }),
    );
  }
}

/// Creates the copy method for a Dart proxy class.
///
/// This method returns a copy of the instance with all the Flutter methods
/// and unattached fields passed to the new instance. This method is inherited
/// from the base class of all Dart proxy classes.
cb.Method copyMethod({
  required String apiName,
  required Iterable<ApiField> unattachedFields,
  required Iterable<(Method, AstProxyApi)> flutterMethodsFromSuperClasses,
  required Iterable<(Method, AstProxyApi)> flutterMethodsFromInterfaces,
  required Iterable<Method> declaredFlutterMethods,
}) {
  final Iterable<cb.Parameter> parameters = asConstructorParameters(
    apiName: apiName,
    parameters: <Parameter>[],
    unattachedFields: unattachedFields,
    flutterMethodsFromSuperClasses: flutterMethodsFromSuperClasses,
    flutterMethodsFromInterfaces: flutterMethodsFromInterfaces,
    declaredFlutterMethods: declaredFlutterMethods,
  );
  return cb.Method(
    (cb.MethodBuilder builder) =>
        builder
          ..name = '${classMemberNamePrefix}copy'
          ..returns = cb.refer(apiName)
          ..annotations.add(cb.refer('override'))
          ..body = cb.Block.of(<cb.Code>[
            cb
                .refer('$apiName.${classMemberNamePrefix}detached')
                .call(<cb.Expression>[], <String, cb.Expression>{
                  for (final cb.Parameter parameter in parameters)
                    parameter.name: cb.refer(parameter.name),
                })
                .returned
                .statement,
          ]),
  );
}

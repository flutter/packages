// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:code_builder/code_builder.dart' as cb;
import 'package:collection/collection.dart';
import 'package:dart_style/dart_style.dart';

import '../ast.dart';
import '../generator_tools.dart';
import 'dart_generator.dart';
import 'templates.dart';

/// Converts fields and methods of a [AstProxyApi] constructor to the
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
      (cb.ParameterBuilder builder) => builder
        ..name = '${classMemberNamePrefix}binaryMessenger'
        ..named = true
        ..type = defineType ? cb.refer('BinaryMessenger?') : null
        ..toSuper = !defineType
        ..required = false,
    );
    yield cb.Parameter(
      (cb.ParameterBuilder builder) => builder
        ..name = instanceManagerVarName
        ..named = true
        ..type = defineType ? cb.refer('$dartInstanceManagerClassName?') : null
        ..toSuper = !defineType
        ..required = false,
    );
  }

  for (final ApiField field in unattachedFields) {
    yield cb.Parameter(
      (cb.ParameterBuilder builder) => builder
        ..name = field.name
        ..named = true
        ..type =
            defineType ? cb.refer(addGenericTypesNullable(field.type)) : null
        ..toThis = !defineType
        ..required = !field.type.isNullable,
    );
  }

  for (final (Method method, AstProxyApi api)
      in flutterMethodsFromSuperClasses) {
    yield cb.Parameter(
      (cb.ParameterBuilder builder) => builder
        ..name = method.name
        ..named = true
        ..type =
            defineType ? methodAsFunctionType(method, apiName: api.name) : null
        ..toSuper = !defineType
        ..required = method.isRequired,
    );
  }

  for (final (Method method, AstProxyApi api) in flutterMethodsFromInterfaces) {
    yield cb.Parameter(
      (cb.ParameterBuilder builder) => builder
        ..name = method.name
        ..named = true
        ..type =
            defineType ? methodAsFunctionType(method, apiName: api.name) : null
        ..toThis = !defineType
        ..required = method.isRequired,
    );
  }

  for (final Method method in declaredFlutterMethods) {
    yield cb.Parameter(
      (cb.ParameterBuilder builder) => builder
        ..name = method.name
        ..named = true
        ..type =
            defineType ? methodAsFunctionType(method, apiName: apiName) : null
        ..toThis = !defineType
        ..required = method.isRequired,
    );
  }

  yield* parameters.mapIndexed(
    (int index, NamedType parameter) => cb.Parameter(
      (cb.ParameterBuilder builder) => builder
        ..name = getParameterName(index, parameter)
        ..type = refer(parameter.type)
        ..named = true
        ..required = !parameter.type.isNullable,
    ),
  );
}

/// Converts all the constructors of a ProxyApi into fields that are used to
/// override the corresponding factory constructor of the generated Dart class.
Iterable<cb.Field> overridesClassConstructors(
  Iterable<AstProxyApi> proxyApis,
) sync* {
  for (final AstProxyApi api in proxyApis) {
    final String lowerCamelCaseApiName = toLowerCamelCase(api.name);

    for (final Constructor constructor in api.constructors) {
      yield cb.Field(
        (cb.FieldBuilder builder) {
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
            ..name = constructor.name.isEmpty
                ? '${lowerCamelCaseApiName}_new'
                : '${lowerCamelCaseApiName}_${constructor.name}'
            ..static = true
            ..docs.add('/// Overrides [${api.name}.$constructorName].')
            ..type = cb.FunctionType(
              (cb.FunctionTypeBuilder builder) => builder
                ..returnType = cb.refer(api.name)
                ..isNullable = true
                ..namedRequiredParameters.addAll(<String, cb.Reference>{
                  for (final cb.Parameter parameter in parameters
                      .where((cb.Parameter parameter) => parameter.required))
                    parameter.name: parameter.type!,
                })
                ..namedParameters.addAll(<String, cb.Reference>{
                  for (final cb.Parameter parameter in parameters
                      .where((cb.Parameter parameter) => !parameter.required))
                    parameter.name: parameter.type!,
                }),
            );
        },
      );
    }
  }
}

/// Converts all the static fields of a ProxyApi into fields that are used to
/// override the corresponding static field of the generated Dart class.
Iterable<cb.Field> overridesClassStaticFields(
  Iterable<AstProxyApi> proxyApis,
) sync* {
  for (final AstProxyApi api in proxyApis) {
    final String lowerCamelCaseApiName = toLowerCamelCase(api.name);

    for (final ApiField field
        in api.fields.where((ApiField field) => field.isStatic)) {
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

/// Converts all the static methods of a ProxyApi into fields that are used to
/// override the corresponding static method of the generated Dart class.
Iterable<cb.Field> overridesClassStaticMethods(
  Iterable<AstProxyApi> proxyApis,
) sync* {
  for (final AstProxyApi api in proxyApis) {
    final String lowerCamelCaseApiName = toLowerCamelCase(api.name);

    for (final Method method
        in api.hostMethods.where((Method method) => method.isStatic)) {
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
cb.Method overridesClassResetMethod(
  Iterable<AstProxyApi> proxyApis,
) {
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
          for (final ApiField attachedField
              in api.fields.where((ApiField field) => field.isStatic))
            cb.Code(
              '${toLowerCamelCase(api.name)}_${attachedField.name} = null;',
            ),
          for (final Method staticMethod
              in api.methods.where((Method method) => method.isStatic))
            cb.Code(
              '${toLowerCamelCase(api.name)}_${staticMethod.name} = null;',
            ),
        ],
      ]);
  });
}

/// Converts a method to a `code_builder` FunctionType with all parameters as
/// positional arguments.
cb.FunctionType methodAsFunctionType(
  Method method, {
  required String apiName,
}) {
  return cb.FunctionType(
    (cb.FunctionTypeBuilder builder) => builder
      ..returnType = refer(
        method.returnType,
        asFuture: method.isAsynchronous,
      )
      ..isNullable = !method.isRequired
      ..requiredParameters.addAll(<cb.Reference>[
        if (method.location == ApiLocation.flutter)
          cb.refer('$apiName ${classMemberNamePrefix}instance'),
        ...method.parameters.mapIndexed(
          (int index, NamedType parameter) {
            return cb.refer(
              '${addGenericTypesNullable(parameter.type)} ${getParameterName(index, parameter)}',
            );
          },
        )
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
    yield cb.Method((cb.MethodBuilder builder) => builder
      ..name = field.name
      ..type = cb.MethodType.getter
      ..static = true
      ..returns = cb.refer(addGenericTypesNullable(field.type))
      ..docs.addAll(asDocumentationComments(
        field.documentationComments,
        docCommentSpec,
      ))
      ..lambda = true
      ..body = cb.Code(
        '$proxyApiOverridesClassName.${toLowerCamelCase(apiName)}_${field.name} ?? _${field.name}',
      ));
  }
}

/// Write the `PigeonOverrides` class that provides overrides for constructors
/// and static members of each generated Dart class of a ProxyApi.
void writeProxyApiPigeonOverrides(
  Indent indent, {
  required DartFormatter formatter,
  required Iterable<AstProxyApi> proxyApis,
}) {
  final cb.Class proxyApiOverrides = cb.Class(
    (cb.ClassBuilder builder) => builder
      ..name = proxyApiOverridesClassName
      ..annotations.add(cb.refer('visibleForTesting'))
      ..docs.addAll(<String>[
        '/// Provides overrides for the constructors and static members of each proxy',
        '/// API.',
        '///',
        '/// This is only intended to be used with unit tests to prevent errors from',
        '/// making message calls in a unit test.',
        '///',
        '/// See [$proxyApiOverridesClassName.${classMemberNamePrefix}reset] to set all overrides back to null.',
      ])
      ..fields.addAll(
        overridesClassConstructors(proxyApis),
      )
      ..fields.addAll(
        overridesClassStaticFields(proxyApis),
      )
      ..fields.addAll(overridesClassStaticMethods(proxyApis))
      ..methods.add(
        overridesClassResetMethod(proxyApis),
      ),
  );

  final cb.DartEmitter emitter = cb.DartEmitter(useNullSafetySyntax: true);
  indent.format(formatter.format('${proxyApiOverrides.accept(emitter)}'));
}

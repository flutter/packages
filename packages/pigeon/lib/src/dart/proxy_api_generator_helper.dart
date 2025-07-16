// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:code_builder/code_builder.dart' as cb;
import 'package:collection/collection.dart';

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

  for (final (Method, AstProxyApi) method in flutterMethodsFromSuperClasses) {
    yield cb.Parameter(
      (cb.ParameterBuilder builder) => builder
        ..name = method.$1.name
        ..named = true
        ..type = defineType
            ? methodAsFunctionType(method.$1, apiName: method.$2.name)
            : null
        ..toSuper = !defineType
        ..required = method.$1.isRequired,
    );
  }

  for (final (Method, AstProxyApi) method in flutterMethodsFromInterfaces) {
    yield cb.Parameter(
      (cb.ParameterBuilder builder) => builder
        ..name = method.$1.name
        ..named = true
        ..type = defineType
            ? methodAsFunctionType(method.$1, apiName: method.$2.name)
            : null
        ..toThis = !defineType
        ..required = method.$1.isRequired,
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
        for (final AstProxyApi api in proxyApis)
          for (final Constructor constructor in api.constructors)
            cb.Code(
              '${toLowerCamelCase(api.name)}_${constructor.name.isEmpty ? 'new' : constructor.name} = null;',
            ),
        for (final AstProxyApi api in proxyApis)
          for (final ApiField attachedField
              in api.fields.where((ApiField field) => field.isStatic))
            cb.Code(
              '${toLowerCamelCase(api.name)}_${attachedField.name} = null;',
            ),
        for (final AstProxyApi api in proxyApis)
          for (final Method staticMethod
              in api.methods.where((Method method) => method.isStatic))
            cb.Code(
              '${toLowerCamelCase(api.name)}_${staticMethod.name} = null;',
            ),
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

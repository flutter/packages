// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart' show ListEquality;
import 'package:meta/meta.dart';

import 'generator_tools.dart';
import 'kotlin/kotlin_generator.dart'
    show KotlinEventChannelOptions, KotlinProxyApiOptions;
import 'pigeon_lib.dart';
import 'swift/swift_generator.dart'
    show SwiftEventChannelOptions, SwiftProxyApiOptions;

typedef _ListEquals = bool Function(List<Object?>, List<Object?>);

final _ListEquals _listEquals = const ListEquality<dynamic>().equals;

/// Enum that represents where an [Api] is located, on the host or Flutter.
enum ApiLocation {
  /// The API is for calling functions defined on the host.
  host,

  /// The API is for calling functions defined in Flutter.
  flutter,
}

/// Superclass for all AST nodes.
class Node {}

/// Represents a method on an [Api].
class Method extends Node {
  /// Parametric constructor for [Method].
  Method({
    required this.name,
    required this.returnType,
    required this.parameters,
    required this.location,
    this.isRequired = true,
    this.isAsynchronous = false,
    this.isStatic = false,
    this.offset,
    this.objcSelector = '',
    this.swiftFunction = '',
    this.taskQueueType = TaskQueueType.serial,
    this.documentationComments = const <String>[],
  });

  /// The name of the method.
  String name;

  /// The data-type of the return value.
  TypeDeclaration returnType;

  /// The parameters passed into the [Method].
  List<Parameter> parameters;

  /// Whether the receiver of this method is expected to return synchronously or not.
  bool isAsynchronous;

  /// The offset in the source file where the field appears.
  int? offset;

  /// An override for the generated objc selector (ex. "divideNumber:by:").
  String objcSelector;

  /// An override for the generated swift function signature (ex. "divideNumber(_:by:)").
  String swiftFunction;

  /// Specifies how handlers are dispatched with respect to threading.
  TaskQueueType taskQueueType;

  /// List of documentation comments, separated by line.
  ///
  /// Lines should not include the comment marker itself, but should include any
  /// leading whitespace, so that any indentation in the original comment is preserved.
  /// For example: [" List of documentation comments, separated by line.", ...]
  List<String> documentationComments;

  /// Where the implementation of this method is located, host or Flutter.
  ApiLocation location;

  /// Whether this method is required to be implemented.
  ///
  /// This flag is typically only used to determine whether a callback method
  /// for an instance of a Dart proxy class of a ProxyAPI is nonnull.
  bool isRequired;

  /// Whether the method of an [AstProxyApi] is denoted with [static].
  bool isStatic;

  @override
  String toString() {
    final String objcSelectorStr =
        objcSelector.isEmpty ? '' : ' objcSelector:$objcSelector';
    final String swiftFunctionStr =
        swiftFunction.isEmpty ? '' : ' swiftFunction:$swiftFunction';
    return '(Method name:$name returnType:$returnType parameters:$parameters isAsynchronous:$isAsynchronous$objcSelectorStr$swiftFunctionStr documentationComments:$documentationComments)';
  }
}

/// Represents a collection of [Method]s that are implemented on the platform
/// side.
class AstHostApi extends Api {
  /// Parametric constructor for [AstHostApi].
  AstHostApi({
    required super.name,
    required super.methods,
    super.documentationComments = const <String>[],
    this.dartHostTestHandler,
  });

  /// The name of the Dart test interface to generate to help with testing.
  String? dartHostTestHandler;

  @override
  String toString() {
    return '(HostApi name:$name methods:$methods documentationComments:$documentationComments dartHostTestHandler:$dartHostTestHandler)';
  }
}

/// Represents a collection of [Method]s that are hosted on the Flutter side.
class AstFlutterApi extends Api {
  /// Parametric constructor for [AstFlutterApi].
  AstFlutterApi({
    required super.name,
    required super.methods,
    super.documentationComments = const <String>[],
  });

  @override
  String toString() {
    return '(FlutterApi name:$name methods:$methods documentationComments:$documentationComments)';
  }
}

/// Represents the AST for the class denoted with the ProxyAPI annotation.
class AstProxyApi extends Api {
  /// Parametric constructor for [AstProxyApi].
  AstProxyApi({
    required super.name,
    required super.methods,
    super.documentationComments = const <String>[],
    required this.constructors,
    required this.fields,
    this.superClass,
    this.interfaces = const <TypeDeclaration>{},
    this.swiftOptions,
    this.kotlinOptions,
  });

  /// List of constructors declared in the class.
  final List<Constructor> constructors;

  /// List of fields declared in the class.
  List<ApiField> fields;

  /// A [TypeDeclaration] of the parent class if the class had one.
  TypeDeclaration? superClass;

  /// A set of [TypeDeclaration]s that this class implements.
  Set<TypeDeclaration> interfaces;

  /// Options that control how Swift code will be generated for a specific
  /// ProxyApi.
  final SwiftProxyApiOptions? swiftOptions;

  /// Options that control how Kotlin code will be generated for a specific
  /// ProxyApi.
  final KotlinProxyApiOptions? kotlinOptions;

  /// Methods that handled by an implementation of the native type api.
  Iterable<Method> get hostMethods => methods.where(
        (Method method) => method.location == ApiLocation.host,
      );

  /// Methods that are handled by an instance of the Dart proxy class.
  Iterable<Method> get flutterMethods => methods.where(
        (Method method) => method.location == ApiLocation.flutter,
      );

  /// All fields that are attached.
  ///
  /// See [attached].
  Iterable<ApiField> get attachedFields => fields.where(
        (ApiField field) => field.isAttached,
      );

  /// All fields that are not attached.
  ///
  /// See [attached].
  Iterable<ApiField> get unattachedFields => fields.where(
        (ApiField field) => !field.isAttached,
      );

  /// A list of [AstProxyApi]s where each is the [superClass] of the one
  /// proceeding it.
  ///
  /// Returns an empty list if this class did not provide a [superClass].
  ///
  /// This method assumes the [superClass] of each class doesn't lead to a loop
  /// Throws a [ArgumentError] if a loop is found.
  ///
  /// This method also assumes that the type of [superClass] is annotated with
  /// `@ProxyApi`. Otherwise, throws an [ArgumentError].
  Iterable<AstProxyApi> allSuperClasses() {
    final List<AstProxyApi> superClassChain = <AstProxyApi>[];

    if (superClass != null && !superClass!.isProxyApi) {
      throw ArgumentError(
        'Could not find a ProxyApi for super class: ${superClass!.baseName}',
      );
    }

    AstProxyApi? currentProxyApi = superClass?.associatedProxyApi;
    while (currentProxyApi != null) {
      if (superClassChain.contains(currentProxyApi)) {
        throw ArgumentError(
          'Loop found when processing super classes for a ProxyApi: '
          '$name, ${superClassChain.map((AstProxyApi api) => api.name)}',
        );
      }

      superClassChain.add(currentProxyApi);

      if (currentProxyApi.superClass != null &&
          !currentProxyApi.superClass!.isProxyApi) {
        throw ArgumentError(
          'Could not find a ProxyApi for super class: '
          '${currentProxyApi.superClass!.baseName}',
        );
      }

      currentProxyApi = currentProxyApi.superClass?.associatedProxyApi;
    }

    return superClassChain;
  }

  /// All classes this class `implements` and all the interfaces those classes
  /// `implements`.
  Iterable<AstProxyApi> apisOfInterfaces() => _recursiveFindAllInterfaceApis();

  /// Returns a record for each Flutter method inherited from an interface and
  /// the AST of its corresponding class.
  Iterable<(Method, AstProxyApi)> flutterMethodsFromInterfacesWithApis() sync* {
    for (final AstProxyApi proxyApi in apisOfInterfaces()) {
      yield* proxyApi.methods.map((Method method) => (method, proxyApi));
    }
  }

  /// Returns a record for each Flutter method inherited from [superClass].
  ///
  /// This also includes methods that the [superClass] inherits from interfaces.
  Iterable<(Method, AstProxyApi)>
      flutterMethodsFromSuperClassesWithApis() sync* {
    for (final AstProxyApi proxyApi in allSuperClasses().toList().reversed) {
      yield* proxyApi.flutterMethods.map((Method method) => (method, proxyApi));
    }
    if (superClass != null) {
      final Set<AstProxyApi> interfaceApisFromSuperClasses =
          superClass!.associatedProxyApi!._recursiveFindAllInterfaceApis();
      for (final AstProxyApi proxyApi in interfaceApisFromSuperClasses) {
        yield* proxyApi.methods.map((Method method) => (method, proxyApi));
      }
    }
  }

  /// All methods inherited from interfaces.
  Iterable<Method> flutterMethodsFromInterfaces() sync* {
    yield* flutterMethodsFromInterfacesWithApis().map(
      ((Method, AstProxyApi) method) => method.$1,
    );
  }

  /// A list of Flutter methods inherited from [superClass].
  ///
  /// This also recursively checks the [superClass] of [superClass].
  ///
  /// This also includes methods that [superClass] inherits from interfaces with
  /// `implements`.
  Iterable<Method> flutterMethodsFromSuperClasses() sync* {
    yield* flutterMethodsFromSuperClassesWithApis().map(
      ((Method, AstProxyApi) method) => method.$1,
    );
  }

  /// Whether the generated ProxyAPI should generate a method in the native type
  /// API that calls to Dart to instantiate a Dart proxy class instance.
  ///
  /// This is possible as the class does not contain a method that is required
  /// to be handled by an instance of the Dart proxy class.
  bool hasCallbackConstructor() {
    return flutterMethods
        .followedBy(flutterMethodsFromSuperClasses())
        .followedBy(flutterMethodsFromInterfaces())
        .every((Method method) => !method.isRequired);
  }

  /// Whether the Dart proxy class makes any message calls to the native type
  /// API.
  bool hasAnyHostMessageCalls() =>
      constructors.isNotEmpty ||
      attachedFields.isNotEmpty ||
      hostMethods.isNotEmpty;

  /// Whether the native type API makes any message calls to the Dart proxy
  /// class or calls to instantiate a Dart proxy class instance.
  bool hasAnyFlutterMessageCalls() =>
      hasCallbackConstructor() || flutterMethods.isNotEmpty;

  /// Whether the native type API will have methods that need to be implemented.
  bool hasMethodsRequiringImplementation() =>
      hasAnyHostMessageCalls() || unattachedFields.isNotEmpty;

  // Recursively search for all the interfaces apis from a list of names of
  // interfaces.
  //
  // This method assumes that all interfaces are ProxyApis and an api doesn't
  // contains itself as an interface. Otherwise, throws an [ArgumentError].
  Set<AstProxyApi> _recursiveFindAllInterfaceApis([
    Set<AstProxyApi> seenApis = const <AstProxyApi>{},
  ]) {
    final Set<AstProxyApi> allInterfaces = <AstProxyApi>{};

    allInterfaces.addAll(
      interfaces.map(
        (TypeDeclaration type) {
          if (!type.isProxyApi) {
            throw ArgumentError(
              'Could not find a valid ProxyApi for an interface: $type',
            );
          } else if (seenApis.contains(type.associatedProxyApi)) {
            throw ArgumentError(
              'A ProxyApi cannot be a super class of itself: ${type.baseName}',
            );
          }
          return type.associatedProxyApi!;
        },
      ),
    );

    // Adds the current api since it would be invalid for it to be an interface
    // of itself.
    final Set<AstProxyApi> newSeenApis = <AstProxyApi>{...seenApis, this};

    for (final AstProxyApi interfaceApi in <AstProxyApi>{...allInterfaces}) {
      allInterfaces.addAll(
        interfaceApi._recursiveFindAllInterfaceApis(newSeenApis),
      );
    }

    return allInterfaces;
  }

  @override
  String toString() {
    return '(ProxyApi name:$name methods:$methods field:$fields '
        'documentationComments:$documentationComments '
        'superClassName:$superClass interfacesNames:$interfaces)';
  }
}

/// Represents a collection of [Method]s that are wrappers for Event
class AstEventChannelApi extends Api {
  /// Parametric constructor for [AstEventChannelApi].
  AstEventChannelApi({
    required super.name,
    required super.methods,
    this.kotlinOptions,
    this.swiftOptions,
    super.documentationComments = const <String>[],
  });

  /// Options for Kotlin generated code for Event Channels.
  final KotlinEventChannelOptions? kotlinOptions;

  /// Options for Swift generated code for Event Channels.
  final SwiftEventChannelOptions? swiftOptions;

  @override
  String toString() {
    return '(EventChannelApi name:$name methods:$methods documentationComments:$documentationComments)';
  }
}

/// Represents a constructor for an API.
class Constructor extends Method {
  /// Parametric constructor for [Constructor].
  Constructor({
    required super.name,
    required super.parameters,
    super.offset,
    super.swiftFunction = '',
    super.documentationComments = const <String>[],
  }) : super(
          returnType: const TypeDeclaration.voidDeclaration(),
          location: ApiLocation.host,
        );

  @override
  String toString() {
    final String swiftFunctionStr =
        swiftFunction.isEmpty ? '' : ' swiftFunction:$swiftFunction';
    return '(Constructor name:$name parameters:$parameters $swiftFunctionStr documentationComments:$documentationComments)';
  }
}

/// Represents a field declared in a class denoted with the ProxyApi annotation.
class ApiField extends NamedType {
  /// Constructor for [ApiField].
  ApiField({
    required super.name,
    required super.type,
    super.offset,
    super.documentationComments,
    this.isAttached = false,
    this.isStatic = false,
  }) : assert(!isStatic || isAttached);

  /// Whether this represents an attached field of an [AstProxyApi].
  ///
  /// See [attached].
  final bool isAttached;

  /// Whether this represents a static field of an [AstProxyApi].
  ///
  /// A static field must also be attached. See [static].
  final bool isStatic;

  /// Returns a copy of an [ApiField] with the new [TypeDeclaration].
  @override
  ApiField copyWithType(TypeDeclaration type) {
    return ApiField(
      name: name,
      type: type,
      offset: offset,
      documentationComments: documentationComments,
      isAttached: isAttached,
      isStatic: isStatic,
    );
  }

  @override
  String toString() {
    return '(Field name:$name type:$type isAttached:$isAttached '
        'isStatic:$isStatic documentationComments:$documentationComments)';
  }
}

/// Represents a collection of [Method]s.
sealed class Api extends Node {
  /// Parametric constructor for [Api].
  Api({
    required this.name,
    required this.methods,
    this.documentationComments = const <String>[],
  });

  /// The name of the API.
  String name;

  /// List of methods inside the API.
  List<Method> methods;

  /// List of documentation comments, separated by line.
  ///
  /// Lines should not include the comment marker itself, but should include any
  /// leading whitespace, so that any indentation in the original comment is preserved.
  /// For example: [" List of documentation comments, separated by line.", ...]
  List<String> documentationComments;

  @override
  String toString() {
    return '(Api name:$name methods:$methods documentationComments:$documentationComments)';
  }
}

/// A specific instance of a type.
@immutable
class TypeDeclaration {
  /// Constructor for [TypeDeclaration].
  const TypeDeclaration({
    required this.baseName,
    required this.isNullable,
    this.associatedEnum,
    this.associatedClass,
    this.associatedProxyApi,
    this.typeArguments = const <TypeDeclaration>[],
  });

  /// Void constructor.
  const TypeDeclaration.voidDeclaration()
      : baseName = 'void',
        isNullable = false,
        associatedEnum = null,
        associatedClass = null,
        associatedProxyApi = null,
        typeArguments = const <TypeDeclaration>[];

  /// The base name of the [TypeDeclaration] (ex 'Foo' to 'Foo<Bar>?').
  final String baseName;

  /// Whether the declaration represents 'void'.
  bool get isVoid => baseName == 'void';

  /// Whether the type arguments to the entity (ex 'Bar' to 'Foo<Bar>?').
  final List<TypeDeclaration> typeArguments;

  /// Whether the type is nullable.
  final bool isNullable;

  /// Whether the [TypeDeclaration] has an [associatedEnum].
  bool get isEnum => associatedEnum != null;

  /// Associated [Enum], if any.
  final Enum? associatedEnum;

  /// Whether the [TypeDeclaration] has an [associatedClass].
  bool get isClass => associatedClass != null;

  /// Associated [Class], if any.
  final Class? associatedClass;

  /// Whether the [TypeDeclaration] has an [associatedProxyApi].
  bool get isProxyApi => associatedProxyApi != null;

  /// Associated [AstProxyApi], if any.
  final AstProxyApi? associatedProxyApi;

  @override
  int get hashCode {
    // This has to be implemented because TypeDeclaration is used as a Key to a
    // Map in generator_tools.dart.
    int hash = 17;
    hash = hash * 37 + baseName.hashCode;
    hash = hash * 37 + isNullable.hashCode;
    for (final TypeDeclaration typeArgument in typeArguments) {
      hash = hash * 37 + typeArgument.hashCode;
    }
    return hash;
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    } else {
      return other is TypeDeclaration &&
          baseName == other.baseName &&
          isNullable == other.isNullable &&
          _listEquals(typeArguments, other.typeArguments) &&
          isEnum == other.isEnum &&
          isClass == other.isClass &&
          associatedClass == other.associatedClass &&
          associatedEnum == other.associatedEnum;
    }
  }

  /// Returns duplicated `TypeDeclaration` with attached `associatedEnum` value.
  TypeDeclaration copyWithEnum(Enum enumDefinition) {
    return TypeDeclaration(
      baseName: baseName,
      isNullable: isNullable,
      associatedEnum: enumDefinition,
      typeArguments: typeArguments,
    );
  }

  /// Returns duplicated `TypeDeclaration` with attached `associatedClass` value.
  TypeDeclaration copyWithClass(Class classDefinition) {
    return TypeDeclaration(
      baseName: baseName,
      isNullable: isNullable,
      associatedClass: classDefinition,
      typeArguments: typeArguments,
    );
  }

  /// Returns duplicated `TypeDeclaration` with attached `associatedProxyApi` value.
  TypeDeclaration copyWithProxyApi(AstProxyApi proxyApiDefinition) {
    return TypeDeclaration(
      baseName: baseName,
      isNullable: isNullable,
      associatedProxyApi: proxyApiDefinition,
      typeArguments: typeArguments,
    );
  }

  /// Returns duplicated `TypeDeclaration` with attached `associatedProxyApi` value.
  TypeDeclaration copyWithTypeArguments(List<TypeDeclaration> types) {
    return TypeDeclaration(
      baseName: baseName,
      isNullable: isNullable,
      typeArguments: types,
      associatedClass: associatedClass,
      associatedEnum: associatedEnum,
      associatedProxyApi: associatedProxyApi,
    );
  }

  @override
  String toString() {
    final String typeArgumentsStr =
        typeArguments.isEmpty ? '' : ' typeArguments:$typeArguments';
    return '(TypeDeclaration baseName:$baseName isNullable:$isNullable$typeArgumentsStr isEnum:$isEnum isClass:$isClass isProxyApi:$isProxyApi)';
  }
}

/// Represents a named entity that has a type.
@immutable
class NamedType extends Node {
  /// Parametric constructor for [NamedType].
  NamedType({
    required this.name,
    required this.type,
    this.offset,
    this.defaultValue,
    this.documentationComments = const <String>[],
  });

  /// The name of the entity.
  final String name;

  /// The type.
  final TypeDeclaration type;

  /// The offset in the source file where the [NamedType] appears.
  final int? offset;

  /// Stringified version of the default value of types that have default values.
  final String? defaultValue;

  /// List of documentation comments, separated by line.
  ///
  /// Lines should not include the comment marker itself, but should include any
  /// leading whitespace, so that any indentation in the original comment is preserved.
  /// For example: [" List of documentation comments, separated by line.", ...]
  final List<String> documentationComments;

  /// Returns a copy of [NamedType] instance with new attached [TypeDeclaration].
  @mustBeOverridden
  NamedType copyWithType(TypeDeclaration type) {
    return NamedType(
      name: name,
      type: type,
      offset: offset,
      defaultValue: defaultValue,
      documentationComments: documentationComments,
    );
  }

  @override
  String toString() {
    return '(NamedType name:$name type:$type defaultValue:$defaultValue documentationComments:$documentationComments)';
  }
}

/// Represents a [Method]'s parameter that has a type and a name.
@immutable
class Parameter extends NamedType {
  /// Parametric constructor for [Parameter].
  Parameter({
    required super.name,
    required super.type,
    super.offset,
    super.defaultValue,
    bool? isNamed,
    bool? isOptional,
    bool? isPositional,
    bool? isRequired,
    super.documentationComments,
  })  : isNamed = isNamed ?? false,
        isOptional = isOptional ?? false,
        isPositional = isPositional ?? true,
        isRequired = isRequired ?? true;

  /// Whether this parameter is a named parameter.
  ///
  /// Defaults to `true`.
  final bool isNamed;

  /// Whether this parameter is an optional parameter.
  ///
  /// Defaults to `false`.
  final bool isOptional;

  /// Whether this parameter is a positional parameter.
  ///
  /// Defaults to `true`.
  final bool isPositional;

  /// Whether this parameter is a required parameter.
  ///
  /// Defaults to `true`.
  final bool isRequired;

  /// Returns a copy of [Parameter] instance with new attached [TypeDeclaration].
  @override
  Parameter copyWithType(TypeDeclaration type) {
    return Parameter(
      name: name,
      type: type,
      offset: offset,
      defaultValue: defaultValue,
      isNamed: isNamed,
      isOptional: isOptional,
      isPositional: isPositional,
      isRequired: isRequired,
      documentationComments: documentationComments,
    );
  }

  @override
  String toString() {
    return '(Parameter name:$name type:$type isNamed:$isNamed isOptional:$isOptional isPositional:$isPositional isRequired:$isRequired documentationComments:$documentationComments)';
  }
}

/// Represents a class with fields.
class Class extends Node {
  /// Parametric constructor for [Class].
  Class({
    required this.name,
    required this.fields,
    this.superClassName,
    this.superClass,
    this.isSealed = false,
    this.isReferenced = true,
    this.isSwiftClass = false,
    this.documentationComments = const <String>[],
  });

  /// The name of the class.
  String name;

  /// All the fields contained in the class.
  List<NamedType> fields;

  /// Name of parent class, will be empty when there is no super class.
  String? superClassName;

  /// The definition of the parent class.
  Class? superClass;

  /// List of class definitions of children.
  ///
  /// This is only meant to be used by sealed classes used in event channel methods.
  List<Class> children = <Class>[];

  /// Whether the class is sealed.
  bool isSealed;

  /// Whether the class is referenced in any API.
  bool isReferenced;

  /// Determines whether the defined class should be represented as a struct or
  /// a class in Swift generation.
  ///
  /// Defaults to false, which would represent a struct.
  bool isSwiftClass;

  /// List of documentation comments, separated by line.
  ///
  /// Lines should not include the comment marker itself, but should include any
  /// leading whitespace, so that any indentation in the original comment is preserved.
  /// For example: [" List of documentation comments, separated by line.", ...]
  List<String> documentationComments;

  @override
  String toString() {
    return '(Class name:$name fields:$fields superClass:$superClassName children:$children isSealed:$isSealed isReferenced:$isReferenced documentationComments:$documentationComments)';
  }
}

/// Represents a Enum.
class Enum extends Node {
  /// Parametric constructor for [Enum].
  Enum({
    required this.name,
    required this.members,
    this.documentationComments = const <String>[],
  });

  /// The name of the enum.
  String name;

  /// All of the members of the enum.
  List<EnumMember> members;

  /// List of documentation comments, separated by line.
  ///
  /// Lines should not include the comment marker itself, but should include any
  /// leading whitespace, so that any indentation in the original comment is preserved.
  /// For example: [" List of documentation comments, separated by line.", ...]
  List<String> documentationComments;

  @override
  String toString() {
    return '(Enum name:$name members:$members documentationComments:$documentationComments)';
  }
}

/// Represents a Enum member.
class EnumMember extends Node {
  /// Parametric constructor for [EnumMember].
  EnumMember({
    required this.name,
    this.documentationComments = const <String>[],
  });

  /// The name of the enum member.
  final String name;

  /// List of documentation comments, separated by line.
  ///
  /// Lines should not include the comment marker itself, but should include any
  /// leading whitespace, so that any indentation in the original comment is preserved.
  /// For example: [" List of documentation comments, separated by line.", ...]
  final List<String> documentationComments;

  @override
  String toString() {
    return '(EnumMember name:$name documentationComments:$documentationComments)';
  }
}

/// Top-level node for the AST.
class Root extends Node {
  /// Parametric constructor for [Root].
  Root({
    required this.classes,
    required this.apis,
    required this.enums,
    this.containsHostApi = false,
    this.containsFlutterApi = false,
    this.containsProxyApi = false,
    this.containsEventChannel = false,
  });

  /// Factory function for generating an empty root, usually used when early errors are encountered.
  factory Root.makeEmpty() {
    return Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]);
  }

  /// All the classes contained in the AST.
  List<Class> classes;

  /// All the API's contained in the AST.
  List<Api> apis;

  /// All of the enums contained in the AST.
  List<Enum> enums;

  /// Whether the root has any Host API definitions.
  bool containsHostApi;

  /// Whether the root has any Flutter API definitions.
  bool containsFlutterApi;

  /// Whether the root has any Proxy API definitions.
  bool containsProxyApi;

  /// Whether the root has any event channel definitions.
  bool containsEventChannel;

  /// Returns true if the number of custom types would exceed the available enumerations
  /// on the standard codec.
  bool get requiresOverflowClass =>
      classes.length - _numberOfSealedClasses() + enums.length >=
      totalCustomCodecKeysAllowed;

  int _numberOfSealedClasses() => classes.where((Class c) => c.isSealed).length;

  @override
  String toString() {
    return '(Root classes:$classes apis:$apis enums:$enums)';
  }
}

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is hand-formatted.

import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../formats.dart';

import 'content.dart';

/// Signature of builders for local widgets.
///
/// The [LocalWidgetLibrary] class wraps a map of widget names to
/// [LocalWidgetBuilder] callbacks.
typedef LocalWidgetBuilder = Widget Function(BuildContext context, DataSource source);

/// Signature of the callback passed to a [RemoteWidget].
///
/// This is used by [RemoteWidget] and [Runtime.build] as the callback for
/// events triggered by remote widgets.
typedef RemoteEventHandler = void Function(String eventName, DynamicMap eventArguments);

/// Signature of the callback passed to [DataSource.handler].
///
/// The callback should return a function of type `T`. That function should call
/// `trigger`.
///
/// See [DataSource.handler] for details.
typedef HandlerGenerator<T extends Function> = T Function(HandlerTrigger trigger);

/// Signature of the callback passed to a [HandlerGenerator].
///
/// See [DataSource.handler] for details.
typedef HandlerTrigger = void Function([DynamicMap? extraArguments]);

/// Used to indicate that there is an error with one of the libraries loaded
/// into the Remote Flutter Widgets [Runtime].
///
/// For example, a reference to a state variable did not match any actual state
/// values, or a library import loop.
class RemoteFlutterWidgetsException implements Exception {
  /// Creates a [RemoteFlutterWidgetsException].
  ///
  /// The message should be a complete sentence, starting with a capital letter
  /// and ending with a period.
  const RemoteFlutterWidgetsException(this.message);

  /// A description of the problem that was detected.
  ///
  /// This will end with a period.
  final String message;

  @override
  String toString() => message;
}

/// Interface for [LocalWidgetBuilder] to obtain data from arguments.
///
/// The interface exposes the [v] method, the argument to which is a list of
/// keys forming a path to a node in the arguments expected by the widget. If
/// the method's type argument does not match the value obtained, null is
/// returned instead.
///
/// In addition, to fetch widgets specifically, the [child] and [childList]
/// methods must be used, and to fetch event handlers, the [handler] method must
/// be used.
///
/// The [isList] and [isMap] methods can be used to avoid inspecting keys that
/// may not be present (e.g. before reading 15 keys in a map that isn't even
/// present, consider checking if the map is present using [isMap] and
/// short-circuiting the key lookups if it is not).
///
/// To iterate over a list, the [length] method can be used to find the number
/// of items in the list.
abstract class DataSource {
  /// Return the int, double, bool, or String value at the given path of the
  /// arguments to the widget.
  ///
  /// `T` must be one of [int], [double], [bool], or [String].
  ///
  /// If `T` does not match the type of the value obtained, then the method
  /// returns null.
  T? v<T extends Object>(List<Object> argsKey);

  /// Return true if the given key identifies a list, otherwise false.
  bool isList(List<Object> argsKey);

  /// Return the length of the list at the given path of the arguments to the
  /// widget.
  ///
  /// If the given path does not identify a list, returns zero.
  int length(List<Object> argsKey);

  /// Return true if the given key identifies a map, otherwise false.
  bool isMap(List<Object> argsKey);

  /// Build the child at the given key.
  ///
  /// If the node specified is not a widget, returns an [ErrorWidget].
  ///
  /// See also:
  ///
  ///  * [optionalChild], which returns null if the widget is missing.
  Widget child(List<Object> argsKey);

  /// Build the child at the given key.
  ///
  /// If the node specified is not a widget, returns null.
  ///
  /// See also:
  ///
  ///  * [child], which returns an [ErrorWidget] instead of null if the widget
  ///    is missing.
  Widget? optionalChild(List<Object> argsKey);

  /// Builds the children at the given key.
  ///
  /// If the node is missing, returns an empty list.
  ///
  /// If the node specified is not a list of widgets, returns a list with the
  /// non-widget nodes replaced by [ErrorWidget].
  List<Widget> childList(List<Object> argsKey);

  /// Gets a [VoidCallback] event handler at the given key.
  ///
  /// If the node specified is an [AnyEventHandler] or a [DynamicList] of
  /// [AnyEventHandler]s, returns a callback that invokes the specified event
  /// handler(s), merging the given `extraArguments` into the arguments
  /// specified in each event handler. In the event of a key conflict (where
  /// both the arguments specified in the remote widget declaration and the
  /// argument provided to this method have the same name), the arguments
  /// specified here take precedence.
  VoidCallback? voidHandler(List<Object> argsKey, [ DynamicMap? extraArguments ]);

  /// Gets an event handler at the given key.
  ///
  /// The event handler can be of any Function type, as specified by the type
  /// argument `T`.
  ///
  /// When this method is called, the second argument, `generator`, is invoked.
  /// The `generator` callback must return a function, which we will call
  /// _entrypoint_, that matches the signature of `T`. The `generator` callback
  /// receives an argument, which we will call `trigger`. The _entrypoint_
  /// function must call `trigger`, optionally passing it any extra arguments
  /// that should be merged into the arguments specified in each event handler.
  ///
  /// This is admittedly a little confusing. At its core, the problem is that
  /// this method cannot itself automatically create a function (_entrypoint_)
  /// of the right type (`T`), and therefore a callback (`generator`) that knows
  /// how to wrap a function body (`trigger`) in the right signature (`T`) is
  /// needed to actually build that function (_entrypoint_).
  T? handler<T extends Function>(List<Object> argsKey, HandlerGenerator<T> generator);
}

/// Widgets defined by the client application. All remote widgets eventually
/// bottom out in these widgets.
class LocalWidgetLibrary extends WidgetLibrary {
  /// Create a [LocalWidgetLibrary].
  ///
  /// The given map must not change once the object is created.
  LocalWidgetLibrary(this._widgets);

  final Map<String, LocalWidgetBuilder> _widgets;

  /// Returns the builder for the widget of the given name, if any.
  @protected
  LocalWidgetBuilder? findConstructor(String name) {
    return _widgets[name];
  }

  /// The widgets defined by this [LocalWidgetLibrary].
  ///
  /// The returned map is an immutable view of the map provided to the constructor.
  /// They keys are the unqualified widget names, and the values are the corresponding
  /// [LocalWidgetBuilder]s.
  ///
  /// The map never changes during the lifetime of the [LocalWidgetLibrary], but a new
  /// instance of an [UnmodifiableMapView] is returned each time this getter is used.
  ///
  /// See also:
  ///
  ///  * [createCoreWidgets], a function that creates a [Map] of local widgets.
  UnmodifiableMapView<String, LocalWidgetBuilder> get widgets {
    return UnmodifiableMapView<String, LocalWidgetBuilder>(_widgets);
  }
}

class _ResolvedConstructor {
  const _ResolvedConstructor(this.fullName, this.constructor);
  final FullyQualifiedWidgetName fullName;
  final Object constructor;
}

/// The logic that builds and maintains Remote Flutter Widgets.
///
/// To declare the libraries of widgets, the [update] method is used.
///
/// At least one [LocalWidgetLibrary] instance must be declared
/// so that [RemoteWidgetLibrary] instances can resolve to real widgets.
///
/// The [build] method returns a [Widget] generated from one of the libraries of
/// widgets added in this manner. Generally, it is simpler to use the
/// [RemoteWidget] widget (which calls [build]).
class Runtime extends ChangeNotifier {
  /// Create a [Runtime] object.
  ///
  /// This object should be [dispose]d when it is no longer needed.
  Runtime();

  final Map<LibraryName, WidgetLibrary> _libraries = <LibraryName, WidgetLibrary>{};

  /// Replace the definitions of the specified library (`name`).
  ///
  /// References to widgets that are not defined in the available libraries will
  /// default to using the [ErrorWidget] widget.
  ///
  /// [LocalWidgetLibrary] and [RemoteWidgetLibrary] instances are added using
  /// this method.
  ///
  /// [RemoteWidgetLibrary] instances are typically first obtained using
  /// [decodeLibraryBlob].
  ///
  /// To remove a library, the libraries must be cleared using [clearLibraries]
  /// and then the libraries being retained must be readded.
  void update(LibraryName name, WidgetLibrary library) {
    _libraries[name] = library;
    _clearCache();
  }

  /// Remove all the libraries and start afresh.
  ///
  /// Calling this notifies the listeners, which typically causes them to
  /// rebuild their widgets in the next frame (for example, that is how
  /// [RemoteWidget] is implemented). If no libraries are readded after calling
  /// [clearLibraries], and there are any listeners, they will fail to rebuild
  /// any widgets that they were configured to create. For this reason, this
  /// call should usually be immediately followed by calls to [update].
  void clearLibraries() {
    _libraries.clear();
    _clearCache();
  }

  /// The widget libraries imported in this [Runtime].
  ///
  /// The returned map is an immutable view of the map updated by calls to
  /// [update] and [clearLibraries].
  ///
  /// The keys are instances [LibraryName] which encode fully qualified library
  /// names, and the values are the corresponding [WidgetLibrary]s.
  ///
  /// The returned map is an immutable copy of the registered libraries
  /// at the time of this call.
  ///
  /// See also:
  ///
  ///  * [update] and [clearLibraries], functions that populate this map.
  UnmodifiableMapView<LibraryName, WidgetLibrary> get libraries {
    return UnmodifiableMapView<LibraryName, WidgetLibrary>(Map<LibraryName, WidgetLibrary>.from(_libraries));
  }

  final Map<FullyQualifiedWidgetName, _ResolvedConstructor?> _cachedConstructors = <FullyQualifiedWidgetName, _ResolvedConstructor?>{};
  final Map<FullyQualifiedWidgetName, _CurriedWidget> _widgets = <FullyQualifiedWidgetName, _CurriedWidget>{};

  void _clearCache() {
    _cachedConstructors.clear();
    _widgets.clear();
    notifyListeners();
  }

  /// Build the root widget of a Remote Widget subtree.
  ///
  /// The widget is identified by a [FullyQualifiedWidgetName], which identifies
  /// a library and a widget name. The widget does not strictly have to be in
  /// that library, so long as it is in that library's dependencies.
  ///
  /// The data for the widget is given by the `data` argument. That object can
  /// be updated independently, the widget will rebuild appropriately as it
  /// changes.
  ///
  /// The `remoteEventTarget` argument is the callback that the RFW runtime will
  /// invoke whenever a remote widget event handler is triggered.
  Widget build(BuildContext context, FullyQualifiedWidgetName widget, DynamicContent data, RemoteEventHandler remoteEventTarget) {
    _CurriedWidget? boundWidget = _widgets[widget];
    if (boundWidget == null) {
      _checkForImportLoops(widget.library);
      boundWidget = _applyConstructorAndBindArguments(widget, const <String, Object?>{}, -1, <FullyQualifiedWidgetName>{}, null);
      _widgets[widget] = boundWidget;
    }
    return boundWidget.build(context, data, remoteEventTarget, const <_WidgetState>[]);
  }

  /// Returns the [BlobNode] that most closely corresponds to a given [BuildContext].
  ///
  /// If the `context` is not a remote widget and has no ancestor remote widget,
  /// then this function returns null.
  ///
  /// The [BlobNode] is typically either a [WidgetDeclaration] (whose
  /// [WidgetDeclaration.root] argument is a [ConstructorCall] or a [Switch]
  /// that resolves to a [ConstructorCall]), indicating the [BuildContext] maps
  /// to a remote widget, or a [ConstructorCall] directly, in the case where it
  /// maps to a local widget. Widgets that correspond to render objects (i.e.
  /// anything that might be found by hit testing on the screen) are always
  /// local widgets.
  static BlobNode? blobNodeFor(BuildContext context) {
    if (context.widget is! _Widget) {
      context.visitAncestorElements((Element element) {
        if (element.widget is _Widget) {
          context = element;
          return false;
        }
        return true;
      });
    }
    if (context.widget is! _Widget) {
      return null;
    }
    return (context.widget as _Widget).curriedWidget;
  }

  void _checkForImportLoops(LibraryName name, [ Set<LibraryName>? visited ]) {
    final WidgetLibrary? library = _libraries[name];
    if (library is RemoteWidgetLibrary) {
      visited ??= <LibraryName>{};
      visited.add(name);
      for (final Import import in library.imports) {
        final LibraryName dependency = import.name;
        if (visited.contains(dependency)) {
          final List<LibraryName> path = <LibraryName>[dependency];
          for (final LibraryName name in visited.toList().reversed) {
            if (name == dependency) {
              break;
            }
            path.add(name);
          }
          if (path.length == 1) {
            assert(path.single == dependency);
            throw RemoteFlutterWidgetsException('Library $dependency depends on itself.');
          } else {
            throw RemoteFlutterWidgetsException('Library $dependency indirectly depends on itself via ${path.reversed.join(" which depends on ")}.');
          }
        }
        _checkForImportLoops(dependency, visited.toSet());
      }
    }
  }

  _ResolvedConstructor? _findConstructor(FullyQualifiedWidgetName fullName) {
    final _ResolvedConstructor? result = _cachedConstructors[fullName];
    if (result != null) {
      return result;
    }
    final WidgetLibrary? library = _libraries[fullName.library];
    if (library is RemoteWidgetLibrary) {
      for (final WidgetDeclaration constructor in library.widgets) {
        if (constructor.name == fullName.widget) {
          return _cachedConstructors[fullName] = _ResolvedConstructor(fullName, constructor);
        }
      }
      for (final Import import in library.imports) {
        final LibraryName dependency = import.name;
        final _ResolvedConstructor? result = _findConstructor(FullyQualifiedWidgetName(dependency, fullName.widget));
        if (result != null) {
          // We cache the constructor under each name that we tried to look it up with, so
          // that next time it takes less time to find it.
          return _cachedConstructors[fullName] = result;
        }
      }
    } else if (library is LocalWidgetLibrary) {
      final LocalWidgetBuilder? constructor = library.findConstructor(fullName.widget);
      if (constructor != null) {
        return _cachedConstructors[fullName] = _ResolvedConstructor(fullName, constructor);
      }
    } else {
      assert(library is Null); // ignore: prefer_void_to_null, type_check_with_null, https://github.com/dart-lang/sdk/issues/47017#issuecomment-907562014
    }
    _cachedConstructors[fullName] = null;
    return null;
  }

  Iterable<LibraryName> _findMissingLibraries(LibraryName library) sync* {
    final WidgetLibrary? root = _libraries[library];
    if (root == null) {
      yield library;
      return;
    }
    if (root is LocalWidgetLibrary) {
      return;
    }
    root as RemoteWidgetLibrary;
    for (final Import import in root.imports) {
      yield* _findMissingLibraries(import.name);
    }
  }

  /// Resolves `fullName` to a [_ResolvedConstructor], then binds its arguments
  /// to `arguments` (binding any [ArgsReference]s to [BoundArgsReference]s) and
  /// expands any references to [ConstructorCall]s so that all remaining widgets
  /// are [_CurriedWidget]s.
  ///
  /// Widgets can't reference each other recursively; this is enforced using the
  /// `usedWidgets` argument.
  ///
  /// The `source` argument is the [BlobNode] that referenced the widget
  /// constructor, in the event that the widget comes from a
  /// [LocalWidgetBuilder] rather than a [WidgetDeclaration], and is used to
  /// provide source information for local widgets (which otherwise could not be
  /// associated with a part of the source). See also [Runtime.blobNodeFor].
  _CurriedWidget _applyConstructorAndBindArguments(FullyQualifiedWidgetName fullName, DynamicMap arguments, int stateDepth, Set<FullyQualifiedWidgetName> usedWidgets, BlobNode? source) {
    final _ResolvedConstructor? widget = _findConstructor(fullName);
    if (widget != null) {
      if (widget.constructor is WidgetDeclaration) {
        if (usedWidgets.contains(widget.fullName)) {
          return _CurriedLocalWidget.error(fullName, 'Widget loop: Tried to call ${widget.fullName} constructor reentrantly.')
            ..propagateSource(source);
        }
        usedWidgets = usedWidgets.toSet()..add(widget.fullName);
        final WidgetDeclaration constructor = widget.constructor as WidgetDeclaration;
        final int newDepth;
        if (constructor.initialState != null) {
          newDepth = stateDepth + 1;
        } else {
          newDepth = stateDepth;
        }
        Object result = _bindArguments(widget.fullName, constructor.root, arguments, newDepth, usedWidgets);
        if (result is Switch) {
          result = _CurriedSwitch(widget.fullName, result, arguments, constructor.initialState)
            ..propagateSource(result);
        } else {
          result as _CurriedWidget;
          if (constructor.initialState != null) {
            result = _CurriedRemoteWidget(widget.fullName, result, arguments, constructor.initialState)
              ..propagateSource(result);
          }
        }
        return result as _CurriedWidget;
      }
      assert(widget.constructor is LocalWidgetBuilder);
      return _CurriedLocalWidget(widget.fullName, widget.constructor as LocalWidgetBuilder, arguments)
        ..propagateSource(source);
    }
    final Set<LibraryName> missingLibraries = _findMissingLibraries(fullName.library).toSet();
    if (missingLibraries.isNotEmpty) {
      return _CurriedLocalWidget.error(
        fullName,
        'Could not find remote widget named ${fullName.widget} in ${fullName.library}, '
        'possibly because some dependencies were missing: ${missingLibraries.join(", ")}',
      )..propagateSource(source);
    }
    return _CurriedLocalWidget.error(fullName, 'Could not find remote widget named ${fullName.widget} in ${fullName.library}.')
      ..propagateSource(source);
  }

  Object _bindArguments(FullyQualifiedWidgetName context, Object node, Object arguments, int stateDepth, Set<FullyQualifiedWidgetName> usedWidgets) {
    if (node is ConstructorCall) {
      final DynamicMap subArguments = _bindArguments(context, node.arguments, arguments, stateDepth, usedWidgets) as DynamicMap;
      return _applyConstructorAndBindArguments(FullyQualifiedWidgetName(context.library, node.name), subArguments, stateDepth, usedWidgets, node);
    }
    if (node is DynamicMap) {
      return node.map<String, Object?>(
        (String name, Object? value) => MapEntry<String, Object?>(name, _bindArguments(context, value!, arguments, stateDepth, usedWidgets)),
      );
    }
    if (node is DynamicList) {
      return List<Object>.generate(
        node.length,
        (int index) => _bindArguments(context, node[index]!, arguments, stateDepth, usedWidgets),
        growable: false,
      );
    }
    if (node is Loop) {
      final Object input = _bindArguments(context, node.input, arguments, stateDepth, usedWidgets);
      final Object output = _bindArguments(context, node.output, arguments, stateDepth, usedWidgets);
      return Loop(input, output)
        ..propagateSource(node);
    }
    if (node is Switch) {
      return Switch(
        _bindArguments(context, node.input, arguments, stateDepth, usedWidgets),
        node.outputs.map<Object?, Object>(
          (Object? key, Object value) {
            return MapEntry<Object?, Object>(
              key == null ? key : _bindArguments(context, key, arguments, stateDepth, usedWidgets),
              _bindArguments(context, value, arguments, stateDepth, usedWidgets),
            );
          },
        ),
      )..propagateSource(node);
    }
    if (node is ArgsReference) {
      return node.bind(arguments)..propagateSource(node);
    }
    if (node is StateReference) {
      return node.bind(stateDepth)..propagateSource(node);
    }
    if (node is EventHandler) {
      return EventHandler(node.eventName, _bindArguments(context, node.eventArguments, arguments, stateDepth, usedWidgets) as DynamicMap)
        ..propagateSource(node);
    }
    if (node is SetStateHandler) {
      assert(node.stateReference is StateReference);
      final BoundStateReference stateReference = (node.stateReference as StateReference).bind(stateDepth);
      return SetStateHandler(stateReference, _bindArguments(context, node.value, arguments, stateDepth, usedWidgets))
        ..propagateSource(node);
    }
    assert(node is! WidgetDeclaration);
    return node;
  }
}

// Internal structure to represent the result of indexing into a list.
//
// There are two ways this can go: either we index in and find a result, in
// which case [result] is that value and the other fields are null, or we fail
// to index into the list and we obtain the length as a side-effect, in which
// case [result] is null, [rawList] is the raw list (might contain [Loop] objects),
// and [length] is the effective length after expanding all the internal loops.
class _ResolvedDynamicList {
  const _ResolvedDynamicList(this.rawList, this.result, this.length);
  final DynamicList? rawList;
  final Object? result; // null means out of range
  final int? length; // might be null if result is not null
}

typedef _DataResolverCallback = Object Function(List<Object> dataKey);
typedef _StateResolverCallback = Object Function(List<Object> stateKey, int depth);

abstract class _CurriedWidget extends BlobNode {
  const _CurriedWidget(this.fullName, this.arguments, this.initialState);

  final FullyQualifiedWidgetName fullName;
  final DynamicMap arguments;
  final DynamicMap? initialState;

  static Object _bindLoopVariable(Object node, Object argument, int depth) {
    if (node is DynamicMap) {
      return node.map<String, Object?>(
        (String name, Object? value) => MapEntry<String, Object?>(name, _bindLoopVariable(value!, argument, depth)),
      );
    }
    if (node is DynamicList) {
      return List<Object>.generate(
        node.length,
        (int index) => _bindLoopVariable(node[index]!, argument, depth),
        growable: false,
      );
    }
    if (node is Loop) {
      return Loop(_bindLoopVariable(node.input, argument, depth), _bindLoopVariable(node.output, argument, depth + 1))
        ..propagateSource(node);
    }
    if (node is Switch) {
      return Switch(
        _bindLoopVariable(node.input, argument, depth),
        node.outputs.map<Object?, Object>(
          (Object? key, Object value) => MapEntry<Object?, Object>(
            key == null ? null : _bindLoopVariable(key, argument, depth),
            _bindLoopVariable(value, argument, depth),
          ),
        )
      )..propagateSource(node);
    }
    if (node is _CurriedLocalWidget) {
      return _CurriedLocalWidget(
        node.fullName,
        node.child,
        _bindLoopVariable(node.arguments, argument, depth) as DynamicMap,
      )..propagateSource(node);
    }
    if (node is _CurriedRemoteWidget) {
      return _CurriedRemoteWidget(
        node.fullName,
        _bindLoopVariable(node.child, argument, depth) as _CurriedWidget,
        _bindLoopVariable(node.arguments, argument, depth) as DynamicMap,
        node.initialState,
      )..propagateSource(node);
    }
    if (node is _CurriedSwitch) {
      return _CurriedSwitch(
        node.fullName,
        _bindLoopVariable(node.root, argument, depth) as Switch,
        _bindLoopVariable(node.arguments, argument, depth) as DynamicMap,
        node.initialState,
      )..propagateSource(node);
    }
    if (node is LoopReference) {
      if (node.loop == depth) {
        return node.bind(argument)..propagateSource(node);
      }
      return node;
    }
    if (node is BoundArgsReference) {
      return BoundArgsReference(_bindLoopVariable(node.arguments, argument, depth), node.parts)
        ..propagateSource(node);
    }
    if (node is EventHandler) {
      return EventHandler(node.eventName, _bindLoopVariable(node.eventArguments, argument, depth) as DynamicMap)
        ..propagateSource(node);
    }
    if (node is SetStateHandler) {
      return SetStateHandler(node.stateReference, _bindLoopVariable(node.value, argument, depth))
        ..propagateSource(node);
    }
    return node;
  }

  /// Look up the _index_th entry in `list`, expanding any loops in `list`.
  ///
  /// If `targetEffectiveIndex` is -1, this evaluates the entire list to ensure
  /// the length is available.
  //
  // TODO(ianh): This really should have some sort of caching. Right now, evaluating a whole list
  // ends up being around O(N^2) since we have to walk the list from the start for every entry.
  static _ResolvedDynamicList _listLookup(DynamicList list, int targetEffectiveIndex, _StateResolverCallback stateResolver, _DataResolverCallback dataResolver) {
    int currentIndex = 0; // where we are in `list` (some entries of which might represent multiple values, because they are themselves loops)
    int effectiveIndex = 0; // where we are in the fully expanded list (the coordinate space in which we're aiming for `targetEffectiveIndex`)
    while ((effectiveIndex <= targetEffectiveIndex || targetEffectiveIndex < 0) && currentIndex < list.length) {
      final Object node = list[currentIndex]!;
      if (node is Loop) {
        Object inputList = node.input;
        while (inputList is! DynamicList) {
          if (inputList is BoundArgsReference) {
            inputList = _resolveFrom(inputList.arguments, inputList.parts, stateResolver, dataResolver);
          } else if (inputList is DataReference) {
            inputList = dataResolver(inputList.parts);
          } else if (inputList is BoundStateReference) {
            inputList = stateResolver(inputList.parts, inputList.depth);
          } else if (inputList is BoundLoopReference) {
            inputList = _resolveFrom(inputList.value, inputList.parts, stateResolver, dataResolver);
          } else if (inputList is Switch) {
            inputList = _resolveFrom(inputList, const <Object>[], stateResolver, dataResolver);
          } else {
            // e.g. it's a map or something else that isn't indexable
            inputList = DynamicList.empty();
          }
          assert(inputList is! _ResolvedDynamicList);
        }
        final _ResolvedDynamicList entry = _listLookup(inputList, targetEffectiveIndex >= 0 ? targetEffectiveIndex - effectiveIndex : -1, stateResolver, dataResolver);
        if (entry.result != null) {
          final Object boundResult = _bindLoopVariable(node.output, entry.result!, 0);
          return _ResolvedDynamicList(null, boundResult, null);
        }
        effectiveIndex += entry.length!;
      } else { // list[currentIndex] is not a Loop
        if (effectiveIndex == targetEffectiveIndex) {
          return _ResolvedDynamicList(null, list[currentIndex], null);
        }
        effectiveIndex += 1;
      }
      currentIndex += 1;
    }
    return _ResolvedDynamicList(list, null, effectiveIndex);
  }

  static Object _resolveFrom(Object root, List<Object> parts, _StateResolverCallback stateResolver, _DataResolverCallback dataResolver) {
    int index = 0;
    Object current = root;
    while (true) {
      if (current is DataReference) {
        if (index < parts.length) {
          current = current.constructReference(parts.sublist(index));
          index = parts.length;
        }
        current = dataResolver(current.parts);
        continue;
      } else if (current is BoundArgsReference) {
        List<Object> nextParts = current.parts;
        if (index < parts.length) {
          nextParts += parts.sublist(index);
        }
        parts = nextParts;
        current = current.arguments;
        index = 0;
        continue;
      } else if (current is BoundStateReference) {
        if (index < parts.length) {
          current = current.constructReference(parts.sublist(index));
          index = parts.length;
        }
        current = stateResolver(current.parts, current.depth);
        continue;
      } else if (current is BoundLoopReference) {
        List<Object> nextParts = current.parts;
        if (index < parts.length) {
          nextParts += parts.sublist(index);
        }
        parts = nextParts;
        current = current.value;
        index = 0;
        continue;
      } else if (current is Switch) {
        final Object key = _resolveFrom(current.input, const <Object>[], stateResolver, dataResolver);
        Object? value = current.outputs[key];
        if (value == null) {
          value = current.outputs[null];
          if (value == null) {
            return missing;
          }
        }
        current = value;
        continue;
      } else if (index >= parts.length) {
        // We've reached the end of the line.
        // We handle some special leaf cases that still need processing before we return.
        if (current is EventHandler) {
          current = EventHandler(current.eventName, _fix(current.eventArguments, stateResolver, dataResolver) as DynamicMap);
        } else if (current is SetStateHandler) {
          current = SetStateHandler(current.stateReference, _fix(current.value, stateResolver, dataResolver));
        }
        // else `current` is nothing special, and we'll just return it below.
        break; // This is where the loop ends.
      } else if (current is DynamicMap) {
        if (parts[index] is! String) {
          return missing;
        }
        if (!current.containsKey(parts[index])) {
          return missing;
        }
        current = current[parts[index]]!;
      } else if (current is DynamicList) {
        if (parts[index] is! int) {
          return missing;
        }
        current = _listLookup(current, parts[index] as int, stateResolver, dataResolver).result ?? missing;
      } else {
        assert(current is! ArgsReference);
        assert(current is! StateReference);
        assert(current is! LoopReference);
        return missing;
      }
      index += 1;
    }
    assert(current is! Reference, 'Unexpected unbound reference (of type ${current.runtimeType}): $current');
    assert(current is! Switch);
    assert(current is! Loop);
    return current;
  }

  static Object _fix(Object root, _StateResolverCallback stateResolver, _DataResolverCallback dataResolver) {
    if (root is DynamicMap) {
      return root.map((String key, Object? value) => MapEntry<String, Object?>(key, _fix(root[key]!, stateResolver, dataResolver)));
    } else if (root is DynamicList) {
      if (root.any((Object? entry) => entry is Loop)) {
        final int length = _listLookup(root, -1, stateResolver, dataResolver).length!;
        return DynamicList.generate(length, (int index) => _fix(_listLookup(root, index, stateResolver, dataResolver).result!, stateResolver, dataResolver));
      } else {
        return DynamicList.generate(root.length, (int index) => _fix(root[index]!, stateResolver, dataResolver));
      }
    } else if (root is BlobNode) {
      return _resolveFrom(root, const <Object>[], stateResolver, dataResolver);
    } else {
      return root;
    }
  }

  Object resolve(List<Object> parts, _StateResolverCallback stateResolver, _DataResolverCallback dataResolver, { required bool expandLists }) {
    Object result = _resolveFrom(arguments, parts, stateResolver, dataResolver);
    if (result is DynamicList && expandLists) {
      result = _listLookup(result, -1, stateResolver, dataResolver);
    }
    assert(result is! Reference);
    assert(result is! Switch);
    assert(result is! Loop);
    return result;
  }

  Widget build(BuildContext context, DynamicContent data, RemoteEventHandler remoteEventTarget, List<_WidgetState> states) {
    return _Widget(curriedWidget: this, data: data, remoteEventTarget: remoteEventTarget, states: states);
  }

  Widget buildChild(BuildContext context, DataSource source, DynamicContent data, RemoteEventHandler remoteEventTarget, List<_WidgetState> states, _StateResolverCallback stateResolver, _DataResolverCallback dataResolver);

  @override
  String toString() => '$fullName ${initialState ?? "{}"} $arguments';
}

class _CurriedLocalWidget extends _CurriedWidget {
  const _CurriedLocalWidget(FullyQualifiedWidgetName fullName, this.child, DynamicMap arguments) : super(fullName, arguments, null);

  factory _CurriedLocalWidget.error(FullyQualifiedWidgetName fullName, String message) {
    return _CurriedLocalWidget(fullName, (BuildContext context, DataSource data) => _buildErrorWidget(message), const <String, Object?>{});
  }

  final LocalWidgetBuilder child;

  @override
  Widget buildChild(BuildContext context, DataSource source, DynamicContent data, RemoteEventHandler remoteEventTarget, List<_WidgetState> states,  _StateResolverCallback stateResolver, _DataResolverCallback dataResolver) {
    return child(context, source);
  }
}

class _CurriedRemoteWidget extends _CurriedWidget {
  const _CurriedRemoteWidget(FullyQualifiedWidgetName fullName, this.child, DynamicMap arguments, DynamicMap? initialState) : super(fullName, arguments, initialState);

  final _CurriedWidget child;

  @override
  Widget buildChild(BuildContext context, DataSource source, DynamicContent data, RemoteEventHandler remoteEventTarget, List<_WidgetState> states,  _StateResolverCallback stateResolver, _DataResolverCallback dataResolver) {
    return child.build(context, data, remoteEventTarget, states);
  }

  @override
  String toString() => '${super.toString()} = $child';
}

class _CurriedSwitch extends _CurriedWidget {
  const _CurriedSwitch(FullyQualifiedWidgetName fullName, this.root, DynamicMap arguments, DynamicMap? initialState) : super(fullName, arguments, initialState);

  final Switch root;

  @override
  Widget buildChild(BuildContext context, DataSource source, DynamicContent data, RemoteEventHandler remoteEventTarget, List<_WidgetState> states,  _StateResolverCallback stateResolver, _DataResolverCallback dataResolver) {
    final Object resolvedWidget = _CurriedWidget._resolveFrom(root, const <Object>[], stateResolver, dataResolver);
    if (resolvedWidget is _CurriedWidget) {
      return resolvedWidget.build(context, data, remoteEventTarget, states);
    }
    return _buildErrorWidget('Switch in $fullName did not resolve to a widget (got $resolvedWidget).');
  }

  @override
  String toString() => '${super.toString()} = $root';
}

class _Widget extends StatefulWidget {
  const _Widget({ required this.curriedWidget, required this.data, required this.remoteEventTarget, required this.states });

  final _CurriedWidget curriedWidget;

  final DynamicContent data;

  final RemoteEventHandler remoteEventTarget;

  final List<_WidgetState> states;

  @override
  State<_Widget> createState() => _WidgetState();
}

class _WidgetState extends State<_Widget> implements DataSource {
  DynamicContent? _state;
  DynamicMap? _stateStore;
  late List<_WidgetState> _states;

  @override
  void initState() {
    super.initState();
    _updateState();
  }

  @override
  void didUpdateWidget(_Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.curriedWidget != widget.curriedWidget) {
      _updateState();
    }
    if (oldWidget.data != widget.data || oldWidget.curriedWidget != widget.curriedWidget || oldWidget.states != widget.states) {
      _unsubscribe();
    }
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _updateState() {
    _stateStore = deepClone(widget.curriedWidget.initialState) as DynamicMap?;
    if (_stateStore != null) {
      _state ??= DynamicContent();
      _state!.updateAll(_stateStore!);
    } else {
      _state = null;
    }
    _states = widget.states;
    if (_state != null) {
      _states = _states.toList()..add(this);
    }
  }

  void _handleSetState(int depth, List<Object> parts, Object value) {
    _states[depth].applySetState(parts, value);
  }

  void applySetState(List<Object> parts, Object value) {
    assert(parts.isNotEmpty);
    assert(_stateStore != null);
    int index = 0;
    Object current = _stateStore!;
    while (index < parts.length) {
      final Object subindex = parts[index];
      if (current is DynamicMap) {
        if (subindex is! String) {
          throw RemoteFlutterWidgetsException('${parts.join(".")} does not identify existing state.');
        }
        if (!current.containsKey(subindex)) {
          throw RemoteFlutterWidgetsException('${parts.join(".")} does not identify existing state.');
        }
        if (index == parts.length - 1) {
          current[subindex] = value;
        } else {
          current = current[parts[index]]!;
        }
      } else if (current is DynamicList) {
        if (subindex is! int) {
          throw RemoteFlutterWidgetsException('${parts.join(".")} does not identify existing state.');
        }
        if (subindex < 0 || subindex >= current.length) {
          throw RemoteFlutterWidgetsException('${parts.join(".")} does not identify existing state.');
        }
        if (index == parts.length - 1) {
          current[subindex] = value;
        } else {
          current = current[subindex]!;
        }
      } else {
        throw RemoteFlutterWidgetsException('${parts.join(".")} does not identify existing state.');
      }
      index += 1;
    }
    _state!.updateAll(_stateStore!);
  }

  // List of subscriptions into [widget.data].
  //
  // Keys are into the [DynamicContent] object.
  final Map<_Key, _Subscription> _subscriptions = <_Key, _Subscription>{};

  void _unsubscribe() {
    for (final _Subscription value in _subscriptions.values) {
      value.dispose();
    }
    _subscriptions.clear();
    _argsCache.clear();
  }

  @override
  T? v<T extends Object>(List<Object> argsKey) {
    assert(T == int || T == double || T == bool || T == String);
    final Object value = _fetch(argsKey, expandLists: false);
    return value is T ? value : null;
  }

  @override
  bool isList(List<Object> argsKey) {
    final Object value = _fetch(argsKey, expandLists: false);
    return value is _ResolvedDynamicList
        || value is DynamicList;
  }

  @override
  int length(List<Object> argsKey) {
    final Object value = _fetch(argsKey, expandLists: true);
    if (value is _ResolvedDynamicList) {
      if (value.rawList != null) {
        assert(value.length != null);
        return value.length!;
      }
    }
    assert(value is! DynamicList);
    return 0;
  }

  @override
  bool isMap(List<Object> argsKey) {
    final Object value = _fetch(argsKey, expandLists: false);
    return value is DynamicMap;
  }

  @override
  Widget child(List<Object> argsKey) {
    final Object value = _fetch(argsKey, expandLists: false);
    if (value is _CurriedWidget) {
      return value.build(context, widget.data, widget.remoteEventTarget, widget.states);
    }
    return _buildErrorWidget('Not a widget at $argsKey (got $value) for ${widget.curriedWidget.fullName}.');
  }

  @override
  Widget? optionalChild(List<Object> argsKey) {
    final Object value = _fetch(argsKey, expandLists: false);
    if (value is _CurriedWidget) {
      return value.build(context, widget.data, widget.remoteEventTarget, widget.states);
    }
    return null;
  }

  @override
  List<Widget> childList(List<Object> argsKey) {
    final Object value = _fetch(argsKey, expandLists: true);
    if (value is _ResolvedDynamicList) {
      assert(value.length != null);
      final DynamicList fullList = _fetchList(argsKey, value.length!);
      return List<Widget>.generate(
        fullList.length,
        (int index) {
          final Object? node = fullList[index];
          if (node is _CurriedWidget) {
            return node.build(context, widget.data, widget.remoteEventTarget, _states);
          }
          return _buildErrorWidget('Not a widget at $argsKey (got $node) for ${widget.curriedWidget.fullName}.');
        },
      );
    }
    if (value == missing) {
      return const <Widget>[];
    }
    return <Widget>[
      _buildErrorWidget('Not a widget list at $argsKey (got $value) for ${widget.curriedWidget.fullName}.'),
    ];
  }

  @override
  VoidCallback? voidHandler(List<Object> argsKey, [ DynamicMap? extraArguments ]) {
    return handler<VoidCallback>(argsKey, (HandlerTrigger callback) => () => callback(extraArguments));
  }

  @override
  T? handler<T extends Function>(List<Object> argsKey, HandlerGenerator<T> generator) {
    Object value = _fetch(argsKey, expandLists: true);
    if (value is AnyEventHandler) {
      value = <Object>[ value ];
    } else if (value is _ResolvedDynamicList) {
      value = _fetchList(argsKey, value.length!);
    }
    if (value is DynamicList) {
      final List<AnyEventHandler> handlers = value.whereType<AnyEventHandler>().toList();
      if (handlers.isNotEmpty) {
        return generator(([DynamicMap? extraArguments]) {
          for (final AnyEventHandler entry in handlers) {
            if (entry is EventHandler) {
              DynamicMap arguments = entry.eventArguments;
              if (extraArguments != null) {
                arguments = DynamicMap.fromEntries(arguments.entries.followedBy(extraArguments.entries));
              }
              widget.remoteEventTarget(entry.eventName, arguments);
            } else if (entry is SetStateHandler) {
              assert(entry.stateReference is BoundStateReference);
              _handleSetState((entry.stateReference as BoundStateReference).depth, entry.stateReference.parts, entry.value);
            }
          }
        });
      }
    }
    return null;
  }

  // null values means the data is not in the cache
  final Map<_Key, Object?> _argsCache = <_Key, Object?>{};

  bool _debugFetching = false;
  final List<_Subscription> _dependencies = <_Subscription>[];

  Object _fetch(List<Object> argsKey, { required bool expandLists }) {
    final _Key key = _Key(_kArgsSection, argsKey);
    final Object? value = _argsCache[key];
    if (value != null && (value is! DynamicList || !expandLists)) {
      return value;
    }
    assert(!_debugFetching);
    try {
      _debugFetching = true;
      final Object result = widget.curriedWidget.resolve(argsKey, _stateResolver, _dataResolver, expandLists: expandLists);
      for (final _Subscription subscription in _dependencies) {
        subscription.addClient(key);
      }
      _argsCache[key] = result;
      return result;
    } finally {
      _dependencies.clear();
      _debugFetching = false;
    }
  }

  DynamicList _fetchList(List<Object> argsKey, int length) {
    return DynamicList.generate(length, (int index) {
      return _fetch(<Object>[...argsKey, index], expandLists: false);
    });
  }

  Object _dataResolver(List<Object> rawDataKey) {
    final _Key dataKey = _Key(_kDataSection, rawDataKey);
    final _Subscription subscription;
    if (!_subscriptions.containsKey(dataKey)) {
      subscription = _Subscription(widget.data, this, rawDataKey);
      _subscriptions[dataKey] = subscription;
    } else {
      subscription = _subscriptions[dataKey]!;
    }
    _dependencies.add(subscription);
    return subscription.value;
  }

  Object _stateResolver(List<Object> rawStateKey, int depth) {
    final _Key stateKey = _Key(depth, rawStateKey);
    final _Subscription subscription;
    if (!_subscriptions.containsKey(stateKey)) {
      if (depth >= _states.length) {
        throw const RemoteFlutterWidgetsException('Reference to state value did not correspond to any stateful remote widget.');
      }
      final DynamicContent? state = _states[depth]._state;
      if (state == null) {
        return missing;
      }
      subscription = _Subscription(state, this, rawStateKey);
      _subscriptions[stateKey] = subscription;
    } else {
      subscription = _subscriptions[stateKey]!;
    }
    _dependencies.add(subscription);
    return subscription.value;
  }

  void updateData(Set<_Key> affectedArgs) {
    setState(() {
      for (final _Key key in affectedArgs) {
        _argsCache[key] = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO(ianh): what if this creates some _dependencies?
    return widget.curriedWidget.buildChild(context, this, widget.data, widget.remoteEventTarget, _states, _stateResolver, _dataResolver);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('name', '${widget.curriedWidget.fullName}'));
  }
}

const int _kDataSection = -1;
const int _kArgsSection = -2;

@immutable
class _Key {
  _Key(this.section, this.parts) : assert(_isValidKey(parts), '$parts is not a valid key');

  static bool _isValidKey(List<Object> parts) {
    return parts.every((Object segment) => segment is int || segment is String);
  }

  final int section;
  final List<Object> parts;

  @override
  bool operator ==(Object other) {
    return other is _Key // _Key has no subclasses, don't need to check runtimeType
        && section == other.section
        && listEquals(parts, other.parts);
  }

  @override
  int get hashCode => Object.hash(section, Object.hashAll(parts));
}

class _Subscription {
  _Subscription(this._data, this._state, this._dataKey) {
    _update(_data.subscribe(_dataKey, _update));
  }

  final DynamicContent _data;
  final _WidgetState _state;
  final List<Object> _dataKey;
  final Set<_Key> _clients = <_Key>{};

  Object get value => _value;
  late Object _value;

  void _update(Object value) {
    _state.updateData(_clients);
    _value = value;
  }

  void addClient(_Key key) {
    _clients.add(key);
  }

  void dispose() {
    _data.unsubscribe(_dataKey, _update);
  }
}

ErrorWidget _buildErrorWidget(String message) {
  FlutterError.reportError(FlutterErrorDetails(
    exception: message,
    stack: StackTrace.current,
    library: 'Remote Flutter Widgets',
  ));
  return ErrorWidget(message);
}

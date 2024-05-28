// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is hand-formatted.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show objectRuntimeType;

import '../dart/model.dart';

/// Signature for the callback passed to [DynamicContent.subscribe].
///
/// Do not modify the provided value (e.g. if it is a map or list). Doing so
/// would leave the [DynamicContent] in an inconsistent state.
typedef SubscriptionCallback = void Function(Object value);

/// Returns a copy of a data structure if it consists of only [DynamicMap]s,
/// [DynamicList]s, [int]s, [double]s, [bool]s, and [String]s.
///
/// This is relatively expensive as the entire data structure must be walked and
/// new objects created.
Object? deepClone(Object? template) {
  if (template == null) {
    return null;
  } else if (template is DynamicMap) {
    return template.map((String key, Object? value) => MapEntry<String, Object?>(key, deepClone(value)));
  } else if (template is DynamicList) {
    return template.map((Object? value) => deepClone(value)).toList();
  } else {
    assert(template is int || template is double || template is bool || template is String, 'unexpected state object type: ${template.runtimeType} ($template)');
    return template;
  }
}

/// Configuration data from the remote widgets.
///
/// Typically this represents the data model, and is updated frequently (or at
/// least, more frequently than the remote widget definitions) by the server
/// (or, indeed, by local code, in response to events or other activity).
///
/// ## Structure
///
/// A [DynamicContent] object represents a tree. A consumer (the remote widgets)
/// can subscribe to a node to obtain its value.
///
/// The root of a [DynamicContent] tree is a map of string-value pairs. The
/// values are:
///
///  * Other maps of string-value pairs ([DynamicMap]).
///  * Lists of values ([DynamicList]).
///  * Booleans ([bool]).
///  * Integers ([int]).
///  * Doubles ([double]).
///  * Strings ([String]).
///
/// The keys in the root map are independently updated. Typically each
/// represents a different category of data from the server that the server
/// updates independently, e.g. theming information and the app state might be
/// provided separately.
///
/// ## Updates
///
/// Data is updated using [update] and [updateAll]. The objects passed to those
/// methods are of the types described above.
///
/// Objects for [update] can be obtained in several ways:
///
/// 1. Dart maps, lists, and literals of the types given above ("raw data") can
///    be created directly in code. This is useful for configuring remote
///    widgets with local client information such as the current time, GPS
///    coordinates, system settings like dark mode, window dimensions, etc,
///    where the data was never encoded in the first place.
///
/// 2. A Remote Flutter Widgets binary data blob can be parsed using
///    [decodeDataBlob]. This is the preferred method for decoding data obtained
///    from the network. See [encodeDataBlob] for a function that generates data
///    in this format.
///
/// 3. A Remote Flutter Widgets text data file can be parsed using
///    [parseTextDataFile]. Decoding this text format is about ten times slower
///    than decoding the binary format and about five times slower than decoding
///    JSON, so it is discouraged in production applications. This text
///    representation of the Remote Flutter Widgets binary data blob format is
///    similar to JSON. This form is typically not used in applications; it is
///    more common for this format to be used on the server side, parsed and
///    then encoded in binary form for transmission to the client.
///
/// 4. Data in JSON form can be decoded using [JsonCodec.decode] (typically
///    using the [json] object); the JSON decoder creates the same types of data
///    structures as expected by [update]. This is not generally recommended but
///    may be appropriate if the data was obtained from a third-party source in
///    JSON form and could not be preprocessed by a server to convert the data
///    to the binary form described above. Numbers in JSON are interpreted as
///    doubles if they contain a decimal point or an `e` in their source
///    representation, and as integers otherwise. This can cause issues as the
///    [DynamicContent] and [DataSource] are strongly typed and distinguish
///    [int] and [double]. Explicit nulls in the JSON are an error (the data
///    format supported by [DynamicContent] does not support nulls). Decoding
///    JSON is about 1.5x slower than the binary format.
///
/// Subscribers are notified immediately after an update if their data changed.
///
/// ## References
///
/// To subscribe to a node, the [subscribe] method is used. The method returns
/// the current value. When the value later changes, the provided callback is
/// invoked with the new value.
///
/// The [unsubscribe] method must be called when the client no longer needs
/// updates (e.g. when the widget goes away).
///
/// To identify a node, a list of keys is used, giving the path from the root to
/// the node. Each key is either a string (to index into maps) or an integer (to
/// index into lists). If no node is identified, the [missing] value is
/// returned. Similarly, if a node goes away, subscribers are given the value
/// [missing] as the new value. It is not an error to subscribe to missing data.
/// It _is_ an error to add [missing] values to the data model, however.
///
/// To subscribe to the root of the [DynamicContent], use an empty list as the
/// key when subscribing.
///
/// The [LocalWidgetBuilder]s passed to a [LocalWidgetLibrary] use a
/// [DataSource] as their interface into the [DynamicContent]. To ensure the
/// integrity of the update mechanism, _that_ interface only allows access to
/// leaves, not intermediate nodes (maps and lists).
///
/// It is an error to subscribe to the same key multiple times with the same
/// callback.
class DynamicContent {
  /// Create a fresh [DynamicContent] object.
  ///
  /// The `initialData` argument, if provided, is used to update all the keys
  /// in the [DynamicContent], as if [updateAll] had been called.
  DynamicContent([ DynamicMap? initialData ]) {
    if (initialData != null) {
      updateAll(initialData);
    }
  }

  final _DynamicNode _root = _DynamicNode.root();

  /// Update all the keys in the [DynamicContent].
  ///
  /// Each key in the provided map is added to [DynamicContent], replacing any
  /// data that was there previously, as if [update] had been called for each
  /// key.
  ///
  /// Existing keys that are not present in the given map are left unmodified.
  ///
  /// If the root node has subscribers (see [subscribe]), they are called once
  /// per key in `initialData`, not just a single time.
  ///
  /// Collections (maps and lists) in `initialData` must not be mutated after
  /// calling this method; doing so would leave the [DynamicContent] in an
  /// inconsistent state.
  void updateAll(DynamicMap initialData) {
    for (final String key in initialData.keys) {
      final Object value = initialData[key] ?? missing;
      update(key, value);
    }
  }

  /// Updates the content with the specified data.
  ///
  /// The given `rootKey` is updated with the data `value`.
  ///
  /// The `value` must consist exclusively of [DynamicMap], [DynamicList], [int],
  /// [double], [bool], and [String] objects.
  ///
  /// Collections (maps and lists) in `value` must not be mutated after calling
  /// this method; doing so would leave the [DynamicContent] in an inconsistent
  /// state.
  void update(String rootKey, Object value) {
    _root.updateKey(rootKey, deepClone(value)!);
    _scheduleCleanup();
  }

  /// Obtain the value at location `key`, and subscribe `callback` to that key
  /// so that future [update]s will invoke the callback with the new value.
  ///
  /// The value is always non-null; if the value is missing, the [missing]
  /// object is used instead.
  ///
  /// The empty key refers to the root of the [DynamicContent] object (i.e.
  /// the map manipulated by [updateAll] and [update]).
  ///
  /// Use [unsubscribe] when the subscription is no longer needed.
  ///
  /// Do not modify the value returned by this method or passed to the given
  /// `callback` (e.g. if it is a map or list). Changes made in this manner will
  /// leave the [DynamicContent] in an inconsistent state.
  Object subscribe(List<Object> key, SubscriptionCallback callback) {
    return _root.subscribe(key, 0, callback);
  }

  /// Removes a subscription created by [subscribe].
  void unsubscribe(List<Object> key, SubscriptionCallback callback) {
    _root.unsubscribe(key, 0, callback);
  }

  bool _cleanupPending = false;

  void _scheduleCleanup() {
    if (!_cleanupPending) {
      _cleanupPending = true;
      scheduleMicrotask(() {
        _cleanupPending = false;
        _DynamicNode.cleanup();
      });
    }
  }

  @override
  String toString() => '${objectRuntimeType(this, 'DynamicContent')}($_root)';
}

// Node in the [DynamicContent] tree. This should contain no [BlobNode]s.
class _DynamicNode {
  _DynamicNode(this._key, this._parent, this._value) : assert(_value == missing || _hasValidType(_value));

  _DynamicNode.root() : _key = missing, _parent = null, _value = DynamicMap(); // ignore: prefer_collection_literals

  final Object _key;
  final _DynamicNode? _parent;
  Object _value;

  final Set<SubscriptionCallback> _callbacks = <SubscriptionCallback>{};
  final Map<Object, _DynamicNode> _children = <Object, _DynamicNode>{};

  bool get isObsolete => _callbacks.isEmpty && _children.isEmpty;

  static final Set<_DynamicNode> _obsoleteNodes = <_DynamicNode>{};

  /// Allow garbage collection to collect unused nodes.
  ///
  /// When a node has no subscribers, it is no longer needed (it can be
  /// recreated if necessary from the raw data). In that situation, the node
  /// adds itself to a list of "obsolete nodes", but the parent still references
  /// it and therefore garbage collection would not notice that it is no longer
  /// used.
  ///
  /// This method solves this problem by disconnecting obsolete nodes from the
  /// tree.
  static void cleanup() {
    while (_obsoleteNodes.isNotEmpty) {
      final _DynamicNode node = _obsoleteNodes.first;
      _obsoleteNodes.remove(node);
      if (node.isObsolete) {
        node._parent?._forget(node._key, node);
      }
    }
  }

  void _forget(Object childKey, _DynamicNode child) {
    assert(_children[childKey] == child);
    _children.remove(childKey);
    if (isObsolete) {
      _obsoleteNodes.add(this);
    }
  }

  static bool _hasValidType(Object? value) {
    if (value is DynamicMap) {
      return value.values.every(_hasValidType);
    }
    if (value is DynamicList) {
      return value.every(_hasValidType);
    }
    return value is int
        || value is double
        || value is bool
        || value is String;
  }

  _DynamicNode _prepare(Object childKey) {
    assert(childKey is String || childKey is int);
    if (!_children.containsKey(childKey)) {
      Object value;
      if (_value is DynamicMap) {
        if (childKey is String && (_value as DynamicMap).containsKey(childKey)) {
          value = (_value as DynamicMap)[childKey]!;
        } else {
          value = missing;
        }
      } else if (_value is DynamicList) {
        if (childKey is int && childKey >= 0 && childKey < (_value as DynamicList).length) {
          value = (_value as DynamicList)[childKey]!;
        } else {
          value = missing;
        }
      } else {
        value = _value;
      }
      _children[childKey] = _DynamicNode(childKey, this, value);
    }
    return _children[childKey]!;
  }

  Object subscribe(List<Object> key, int index, SubscriptionCallback callback) {
    _obsoleteNodes.remove(this);
    if (index == key.length) {
      assert(!_callbacks.contains(callback));
      _callbacks.add(callback);
      return _value;
    }
    final _DynamicNode child = _prepare(key[index]);
    return child.subscribe(key, index + 1, callback);
  }

  void unsubscribe(List<Object> key, int index, SubscriptionCallback callback) {
    if (index == key.length) {
      assert(_callbacks.contains(callback));
      _callbacks.remove(callback);
      if (_callbacks.isEmpty) {
        _obsoleteNodes.add(this);
      }
    } else {
      assert(_children.containsKey(key[index]));
      _children[key[index]]!.unsubscribe(key, index + 1, callback);
    }
  }

  void update(Object value) {
    assert(value == missing || _hasValidType(value), 'cannot update $this using $value');
    if (value == _value) {
      return;
    }
    _value = value;
    if (value is DynamicMap) {
      for (final Object childKey in _children.keys) {
        Object? childValue;
        if (childKey is String) {
          childValue = value[childKey];
        }
        _children[childKey]!.update(childValue ?? missing);
      }
    } else if (value is DynamicList) {
      for (final Object childKey in _children.keys) {
        Object? childValue;
        if (childKey is int && childKey >= 0 && childKey < value.length) {
          childValue = value[childKey];
        }
        _children[childKey]!.update(childValue ?? missing);
      }
    } else {
      for (final _DynamicNode child in _children.values) {
        child.update(missing);
      }
    }
    _sendUpdates(value);
  }

  void updateKey(String rootKey, Object value) {
    assert(_value is DynamicMap);
    assert(_hasValidType(value));
    if ((_value as DynamicMap)[rootKey] == value) {
      return;
    }
    (_value as DynamicMap)[rootKey] = value;
    if (_children.containsKey(rootKey)) {
      _children[rootKey]!.update(value);
    }
    _sendUpdates(_value);
  }

  void _sendUpdates(Object value) {
    for (final SubscriptionCallback callback in _callbacks) {
      callback(value);
    }
  }

  @override
  String toString() => '$_value';
}

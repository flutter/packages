// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is hand-formatted.

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../dart/model.dart';
import 'content.dart';
import 'runtime.dart';

export '../dart/model.dart' show DynamicMap, LibraryName;

/// Injection point for a remote widget.
///
/// This widget combines an RFW [Runtime] and [DynamicData], inserting a
/// specified [widget] into the tree.
class RemoteWidget extends StatefulWidget {
  /// Inserts the specified [widget] into the tree.
  ///
  /// The [onEvent] argument is optional. When omitted, events are discarded.
  const RemoteWidget({
    super.key,
    required this.runtime,
    required this.widget,
    required this.data,
    this.onEvent,
  });

  /// The [Runtime] to use to render the widget specified by [widget].
  ///
  /// This should update rarely (doing so is relatively expensive), but it is
  /// fine to update it. For example, a client could update this on the fly when
  /// the server deploys a new version of the widget library.
  ///
  /// Frequent updates (e.g. animations) should be done by updating [data] instead.
  final Runtime runtime;

  /// The name of the widget to display, and the library from which to obtain
  /// it.
  ///
  /// The widget must be declared either in the specified library, or one of its
  /// dependencies.
  ///
  /// The data to show in the widget is specified using [data].
  final FullyQualifiedWidgetName widget;

  /// The data to which the widget specified by [name] will be bound.
  ///
  /// This includes data that comes from the application, e.g. a description of
  /// the user's device, the current time, or an animation controller's value,
  /// and data that comes from the server, e.g. the contents of the user's
  /// shopping cart.
  ///
  /// This can be updated frequently (once per frame) using
  /// [DynamicContent.update].
  final DynamicContent data;

  /// Called when there's an event triggered by a remote widget.
  ///
  /// If this is null, events are discarded.
  final RemoteEventHandler? onEvent;

  @override
  State<RemoteWidget> createState() => _RemoteWidgetState();

  @override
  StatefulElement createElement() => _RemoteElement(this);
}

class _RemoteWidgetState extends State<RemoteWidget> {
  @override
  void initState() {
    super.initState();
    widget.runtime.addListener(_runtimeChanged);
  }

  @override
  void didUpdateWidget(RemoteWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.runtime != widget.runtime) {
      oldWidget.runtime.removeListener(_runtimeChanged);
      widget.runtime.addListener(_runtimeChanged);
    }
  }

  @override
  void dispose() {
    widget.runtime.removeListener(_runtimeChanged);
    super.dispose();
  }

  void _runtimeChanged() {
    setState(() {/* widget probably changed */});
  }

  void _eventHandler(String eventName, DynamicMap eventArguments) {
    if (widget.onEvent != null) {
      widget.onEvent!(eventName, eventArguments);
      if (kDebugMode) {
        // TODO(kenz): get this from here somehow.
        final String elementDebugId = context.describeElement('').toString();
        RemoteWidgetBinding.debugInstance
            .addEventForRemote(elementDebugId, eventName, eventArguments);
        print('in event handler, done trying to add event for remote');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.runtime.build(
      context,
      widget.widget,
      widget.data,
      _eventHandler,
    );
  }
}

class _RemoteElement extends StatefulElement {
  _RemoteElement(super.widget);

  late String _debugId;
  static int _nextRemoteId = 0;

  @override
  void mount(Element? parent, Object? newSlot) {
    if (kDebugMode) {
      _debugId = '${_nextRemoteId++}';
      RemoteWidgetBinding.debugInstance.remoteDetails = {
        ...RemoteWidgetBinding.debugInstance.remoteDetails,
        _debugId: RemoteNode(
          id: _debugId,
          type: widget.runtimeType.toString(),
          events: <RemoteNodeEvent>[],
          element: this,
        )
      };
      // Add an event for testing because the test apps are very simple.
      RemoteWidgetBinding.debugInstance.addEventForRemote(
        _debugId,
        'foo',
        <String, Object?>{'bar': 'baz'},
      );
    }
    super.mount(parent, newSlot);
  }

  @override
  void unmount() {
    if (kDebugMode) {
      RemoteWidgetBinding.debugInstance.remoteDetails = {
        ...RemoteWidgetBinding.debugInstance.remoteDetails,
      }..remove(_debugId);
    }
    super.unmount();
  }

  @override
  void markNeedsBuild() {
    if (kDebugMode) {
      // This will be triggered when setState is called on [RemoteWidget].
      RemoteWidgetBinding.debugInstance.remoteDidChange(_debugId);
    }
    super.markNeedsBuild();
  }
}

@protected
class RemoteWidgetBinding {
  RemoteWidgetBinding._() {
    if (kDebugMode) {
      _registerServiceExtensions();
    }
  }

  void _registerServiceExtensions() {
    assert(kDebugMode);
    developer.registerExtension('ext.rfw.getRemoteWidgetData',
        (String method, Map<String, String> parameters) async {
      final String? remoteId = parameters['id'];
      if (remoteId == null) {
        return developer.ServiceExtensionResponse.error(
          developer.ServiceExtensionResponse.invalidParams,
          'Missing parameter "id".',
        );
      }
      final RemoteWidget? widgetForId =
          _remoteDetails[remoteId]?.element.widget as RemoteWidget?;
      final Map<String, Object?> dataAsMap =
          widgetForId?.data.toDartMap() ?? <String, Object?>{};
      return developer.ServiceExtensionResponse.result(
        json.encode({'data': dataAsMap}),
      );
    });

    developer.registerExtension('ext.rfw.getRemoteWidgetEvents',
        (String method, Map<String, String> parameters) async {
      final String? remoteId = parameters['id'];
      if (remoteId == null) {
        return developer.ServiceExtensionResponse.error(
          developer.ServiceExtensionResponse.invalidParams,
          'Missing parameter "id".',
        );
      }
      final List<Map<String, Object>>? eventsForId = _remoteDetails[remoteId]
          ?.events
          .map((RemoteNodeEvent e) => e.toJson())
          .toList();
      return developer.ServiceExtensionResponse.result(
        json.encode({'events': eventsForId}),
      );
    });

    developer.registerExtension('ext.rfw.getRemoteWidgetLibraries',
        (String method, Map<String, String> parameters) async {
      final String? remoteId = parameters['id'];
      if (remoteId == null) {
        return developer.ServiceExtensionResponse.error(
          developer.ServiceExtensionResponse.invalidParams,
          'Missing parameter "id".',
        );
      }
      final RemoteWidget? widgetForId =
          _remoteDetails[remoteId]?.element.widget as RemoteWidget?;
      final List<String> libraryNames =
          widgetForId?.runtime.debugGetLibraryNames() ?? <String>[];
      return developer.ServiceExtensionResponse.result(
        json.encode({'libraries': libraryNames}),
      );
    });

    developer.registerExtension('ext.rfw.getRemoteWidgetLibraryContent',
        (String method, Map<String, String> parameters) async {
      final String? remoteId = parameters['id'];
      if (remoteId == null) {
        return developer.ServiceExtensionResponse.error(
          developer.ServiceExtensionResponse.invalidParams,
          'Missing parameter "id".',
        );
      }

      final String? libraryName = parameters['name'];
      if (libraryName == null) {
        return developer.ServiceExtensionResponse.error(
          developer.ServiceExtensionResponse.invalidParams,
          'Missing parameter "name".',
        );
      }

      final RemoteWidget? widgetForId =
          _remoteDetails[remoteId]?.element.widget as RemoteWidget?;
      final String? content =
          widgetForId?.runtime.debugGetLibraryContent(libraryName);
      return developer.ServiceExtensionResponse.result(
        json.encode({'content': content}),
      );
    });
  }

  static final RemoteWidgetBinding debugInstance = kDebugMode
      ? RemoteWidgetBinding._()
      : throw UnsupportedError(
          'Cannot use RemoteWidgetBinding in release mode',
        );

  Map<String, RemoteNode> _remoteDetails = {};
  Map<String, RemoteNode> get remoteDetails => _remoteDetails;
  set remoteDetails(Map<String, RemoteNode> value) {
    developer.postEvent('rfw:remote_list_changed', <dynamic, dynamic>{});
    _remoteDetails = value;
  }

  void remoteDidChange(String remoteId) {
    developer.postEvent(
      'rfw:remote_changed',
      <dynamic, dynamic>{'id': remoteId},
    );
  }

  void addEventForRemote(
    String remoteId,
    String eventName,
    Map<String, Object?> args,
  ) {
    _remoteDetails[remoteId]?.events.add(
          RemoteNodeEvent(
            name: eventName,
            args: args,
          ),
        );
  }
}

@protected
class RemoteNode {
  const RemoteNode({
    required this.id,
    required this.type,
    required this.events,
    required this.element,
  });

  final String id;
  final String type;
  final List<RemoteNodeEvent> events;
  final _RemoteElement element;
}

class RemoteNodeEvent {
  RemoteNodeEvent({required this.name, required this.args});

  final String name;
  final DynamicMap args;

  Map<String, Object> toJson() {
    return <String, Object>{'name': name, 'args': args};
  }
}

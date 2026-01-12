// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is hand-formatted.

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
  const RemoteWidget({ super.key, required this.runtime, required this.widget, required this.data, this.onEvent });

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
    setState(() { /* widget probably changed */ });
  }

  void _eventHandler(String eventName, DynamicMap eventArguments) {
    if (widget.onEvent != null) {
      widget.onEvent!(eventName, eventArguments);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.runtime.build(context, widget.widget, widget.data, _eventHandler);
  }
}

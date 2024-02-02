// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:devtools_app_shared/service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vm_service/vm_service.dart';

import 'eval.dart';

@immutable
class RfwData {
  const RfwData({
    required this.id,
    required this.type,
  });

  final String id;
  final String type;
}

@immutable
class RfwEvent {
  const RfwEvent({
    required this.name,
    required this.args,
  });

  factory RfwEvent.parse(Map<String, Object?> json) {
    return RfwEvent(
      name: json['name'] as String,
      args: (json['args'] as Map).cast<String, Object?>(),
    );
  }

  final String name;
  final Map<String, Object?> args;
}

final _remoteListChanged = AutoDisposeStreamProvider<void>((ref) async* {
  final service = await ref.watch(serviceProvider.future);

  yield* service.onExtensionEvent.where((event) {
    return event.extensionKind == 'rfw:remote_list_changed';
  });
});

final _rawRemoteIdsProvider = AutoDisposeFutureProvider<List<String>>(
  (ref) async {
    // recompute the list of providers on hot-restart
    ref.watch(hotRestartEventProvider);
    // cause the list of providers to be re-evaluated when notified of a change
    ref.watch(_remoteListChanged);

    final isAlive = Disposable();
    ref.onDispose(isAlive.dispose);

    final eval = await ref.watch(remoteEvalProvider.future);

    final remoteIdRefs = await eval.evalInstance(
      'RemoteWidgetBinding.debugInstance.remoteDetails.keys.toList()',
      isAlive: isAlive,
    );

    final remoteIdInstances = await Future.wait([
      for (final idRef in remoteIdRefs.elements!.cast<InstanceRef>())
        eval.safeGetInstance(idRef, isAlive),
    ]);

    return [
      for (final idInstance in remoteIdInstances) idInstance.valueAsString!,
    ];
  },
  name: '_rawRemoteIdsProvider',
);

final _rawRemoteNodeProvider = AutoDisposeFutureProviderFamily<RfwData, String>(
  (ref, id) async {
    // recompute the remote informations on hot-restart
    ref.watch(hotRestartEventProvider);

    final isAlive = Disposable();
    ref.onDispose(isAlive.dispose);

    final eval = await ref.watch(remoteEvalProvider.future);

    final remoteNodeInstance = await eval.evalInstance(
      "RemoteWidgetBinding.debugInstance.remoteDetails['$id']",
      isAlive: isAlive,
    );

    Future<Instance> getFieldWithName(String name) {
      return eval.safeGetInstance(
        remoteNodeInstance.fields!.firstWhere((e) => e.decl?.name == name).value
            as InstanceRef,
        isAlive,
      );
    }

    final type = await getFieldWithName('type');

    // Rfw Events.
    // final eventNamesListInstance = await eval.evalInstance(
    //   "RemoteWidgetBinding.debugInstance.remoteDetails['$id']!.events.map((e) => e.name).toList()",
    //   isAlive: isAlive,
    // );
    // final eventArgsListInstance = await eval.evalInstance(
    //   "RemoteWidgetBinding.debugInstance.remoteDetails['$id']!.events.map((e) => e.args).toList()",
    //   isAlive: isAlive,
    // );

    // final eventNames = (await Future.wait([
    //   for (final eventName
    //       in eventNamesListInstance.elements!.cast<InstanceRef>())
    //     eval.safeGetInstance(eventName, isAlive),
    // ]))
    //     .map((e) => e.valueAsString!)
    //     .toList();

    // final halfParsedEvents = eventNames
    //     .map(
    //       (e) => RfwEvent(
    //         name: e,
    //         args: {'todo': 'parse args'},
    //       ),
    //     )
    //     .toList();

    // final events = (await Future.wait([
    //   for (final event in eventsInstance.elements!.cast<InstanceRef>())
    //     eval.safeGetInstance(event, isAlive),
    // ]))
    //     .map((e) => e.valueAsString!)
    //     .toList();
    // TODO: we can't json decode this string because it looks like: "{name: foo, args: {bar: baz}""
    // .map(
    //   (e) => {
    //     'name': e.associations!.firstWhere((a) => a.key == 'name').value,
    //     'args': 'todo',
    //   },
    // )
    // .map((m) => RfwEvent.parse(m))
    // .toList();
    // print(events);

    // final element = await getFieldWithName('element');
    // final widget = await eval.safeGetInstance(
    //   element.fields!.firstWhere((e) => e.decl?.name == '_widget').value
    //       as InstanceRef,
    //   isAlive,
    // );

    // // Rfw runtime.
    // final runtime = await eval.safeGetInstance(
    //   widget.fields!.firstWhere((e) => e.decl?.name == 'runtime').value
    //       as InstanceRef,
    //   isAlive,
    // );

    // // Rfw data.
    // final data = await eval.safeGetInstance(
    //   widget.fields!.firstWhere((e) => e.decl?.name == 'data').value
    //       as InstanceRef,
    //   isAlive,
    // );
    // final dataRoot = await eval.safeGetInstance(
    //   data.fields!.firstWhere((e) => e.decl?.name == '_root').value
    //       as InstanceRef,
    //   isAlive,
    // );
    // final dataRootValue = await eval.safeGetInstance(
    //   dataRoot.fields!.firstWhere((e) => e.decl?.name == '_value').value
    //       as InstanceRef,
    //   isAlive,
    // );
    // final dataRootValueAsString = dataRootValue.valueAsString;
//     print('dataRootValueAsString: $dataRootValueAsString');
//     final dataValueToString = (await eval.safeEval(
//       "RemoteWidgetBinding.debugInstance.remoteDetails['$id']!.element._widget.data._root.toString()",
//       isAlive: isAlive,
//     ));
//     final s = dataValueToString.valueAsString;
// print('s: $s');

    // final eventsAsJsonString = (await Future.wait([
    //   for (final idRef in eventsInstance.elements!.cast<InstanceRef>())
    //     eval.safeGetInstance(idRef, isAlive),
    // ]))
    //     .map((e) => e.valueAsString!)
    //     .toList();
    //   print(eventsAsJsonString.toString());
    // final events =
    //     eventsAsJsonString.map((e) => RfwEvent.parse(jsonDecode(e))).toList();

    //     final remoteNodeInstance = await eval.evalInstance(
    //   "RemoteWidgetBinding.debugInstance.remoteDetails['$id']",
    //   isAlive: isAlive,
    // );

    // Future<Instance> getFieldWithName(String name) {
    //   return eval.safeGetInstance(
    //     remoteNodeInstance.fields!
    //         .firstWhere((e) => e.decl?.name == name)
    //         .value as InstanceRef,
    //     isAlive,
    //   );
    // }

    return RfwData(
      id: id,
      type: type.valueAsString!,
    );
  },
  name: '_rawRemoteNodeProvider',
);

/// Combines [remoteIdsProvider] with [remoteNodeProvider] to obtain all
/// the [RfwData]s at once, sorted alphabetically.
final sortedRemoteNodesProvider =
    AutoDisposeFutureProvider<List<RfwData>>((ref) async {
  final ids = await ref.watch(_rawRemoteIdsProvider.future);

  final nodes = await Future.wait<RfwData>(
    ids.map((id) => ref.watch(_rawRemoteNodeProvider(id).future)),
  );

  return nodes.toList()..sort((a, b) => a.type.compareTo(b.type));
});

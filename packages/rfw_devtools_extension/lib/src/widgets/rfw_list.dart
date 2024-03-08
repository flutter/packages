// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:devtools_app_shared/service.dart';
import 'package:devtools_app_shared/ui.dart';
import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rfw_devtools_extension/src/controller.dart';
import 'package:rfw_devtools_extension/src/rfw_connection/data_providers.dart';
import 'package:vm_service/vm_service.dart';

class RfwList extends ConsumerStatefulWidget {
  const RfwList({super.key, required this.extensionController});

  final RfwExtensionController extensionController;

  @override
  ConsumerState<RfwList> createState() => _RfwInspectorState();
}

class _RfwInspectorState extends ConsumerState<RfwList> {
  late final EvalOnDartLibrary remoteBindindEval;
  late final Disposable evalDisposable;

  static const _defaultEvalResponseText = '--';

  var evalResponseText = _defaultEvalResponseText;

  List<String> rfwIds = [];

  @override
  void initState() {
    super.initState();
    unawaited(
      _initEval().then((_) async {
        final ids = await _getRemoteIds();
        setState(() {
          rfwIds = ids;
        });
      }),
    );
  }

  Future<void> _initEval() async {
    await serviceManager.onServiceAvailable;
    remoteBindindEval = EvalOnDartLibrary(
      'package:rfw/src/flutter/remote_widget.dart',
      serviceManager.service!,
      serviceManager: serviceManager,
    );
    evalDisposable = Disposable();
  }

  Future<List<String>> _getRemoteIds() async {
    final remoteIdRefs = await remoteBindindEval.evalInstance(
      'RemoteWidgetBinding.debugInstance.remoteDetails.keys.toList()',
      isAlive: evalDisposable,
    );

    final remoteIdInstances = await Future.wait([
      for (final idRef in remoteIdRefs.elements!.cast<InstanceRef>())
        remoteBindindEval.safeGetInstance(idRef, evalDisposable),
    ]);

    return [
      for (final idInstance in remoteIdInstances) idInstance.valueAsString!,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final rfws = ref.watch(sortedRemoteNodesProvider);
    return rfws.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: defaultSpacing,
          vertical: denseSpacing,
        ),
        child: Text('<unknown error>\n$stack'),
      ),
      data: (rfws) {
        return ListView.builder(
          itemCount: rfws.length,
          itemBuilder: (context, index) {
            final rfw = rfws[index];
            return RfwItem(
              key: Key('rfw-${rfw.id}'),
              extensionController: widget.extensionController,
              data: rfw,
              // TODO(kenz): this will probably be stale. wrap in value listenable builder.
              isSelected:
                  widget.extensionController.selectedRfw.value?.id == rfw.id,
            );
          },
        );
      },
    );
  }
}

class RfwItem extends ConsumerWidget {
  const RfwItem({
    super.key,
    required this.extensionController,
    required this.data,
    required this.isSelected,
  });

  final RfwExtensionController extensionController;
  final RfwData data;
  final bool isSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor =
        isSelected ? colorScheme.selectedRowBackgroundColor : null;

    return InkWell(
      onTap: () {
        extensionController.selectRfw(data);
      },
      child: Container(
        color: backgroundColor,
        padding: const EdgeInsets.symmetric(
          horizontal: defaultSpacing,
          vertical: denseSpacing,
        ),
        child: Text('${data.type}() [${data.id}]'),
      ),
    );
  }
}

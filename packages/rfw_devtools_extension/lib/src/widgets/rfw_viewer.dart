// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:devtools_app_shared/ui.dart';
import 'package:devtools_app_shared/utils.dart';
import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/material.dart';
import 'package:rfw_devtools_extension/src/controller.dart';
import 'package:rfw_devtools_extension/src/model.dart';
import 'package:rfw_devtools_extension/src/rfw_connection/data_providers.dart';
import 'package:rfwpad/rfwpad.dart' hide RfwEvent;

const JsonEncoder _jsonEncoder = JsonEncoder.withIndent('  ');

class RfwViewer extends StatefulWidget {
  const RfwViewer({super.key, required this.extensionController});

  final RfwExtensionController extensionController;

  @override
  State<RfwViewer> createState() => _RfwViewerState();
}

class _RfwViewerState extends State<RfwViewer> with AutoDisposeMixin {
  List<String> librariesForSelectedRfw = [];
  RfwLibrary? selectedLibrary;

  @override
  void initState() {
    super.initState();

    librariesForSelectedRfw =
        widget.extensionController.selectedRfwLibraryNames.value;
    addAutoDisposeListener(
      widget.extensionController.selectedRfwLibraryNames,
      () async {
        setState(() {
          librariesForSelectedRfw =
              widget.extensionController.selectedRfwLibraryNames.value;
        });
      },
    );

    selectedLibrary = widget.extensionController.selectedRfwLibrary.value;
    addAutoDisposeListener(
      widget.extensionController.selectedRfwLibrary,
      () async {
        setState(() {
          selectedLibrary = widget.extensionController.selectedRfwLibrary.value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return FlexSplitColumn(
          totalHeight: constraints.maxHeight,
          initialFractions: const [0.6, 0.2, 0.2],
          minSizes: const [0.0, 0.0, 0.0],
          headers: [
            AreaPaneHeader(
              title: const Text('Library'),
              roundedTopBorder: false,
              includeLeftBorder: false,
              includeRightBorder: false,
              actions: [
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedLibrary?.name,
                    onChanged: (value) {
                      unawaited(
                        widget.extensionController.selectLibrary(value),
                      );
                    },
                    isDense: true,
                    items: [
                      for (final library in librariesForSelectedRfw)
                        DropdownMenuItem<String>(
                          value: library,
                          child: Text(library),
                        ),
                    ],
                  ),
                )
              ],
            ),
            const AreaPaneHeader(
              title: Text('Data'),
              roundedTopBorder: false,
              includeLeftBorder: false,
              includeRightBorder: false,
            ),
            const AreaPaneHeader(
              title: Text('Events'),
              roundedTopBorder: false,
              includeLeftBorder: false,
              includeRightBorder: false,
            ),
          ],
          children: [
            RfwCodeEditor(
              extensionController: widget.extensionController,
            ),
            RfwDataEditor(
              extensionController: widget.extensionController,
            ),
            RfwEventsView(extensionController: widget.extensionController),
          ],
        );
      },
    );
  }
}

class RfwCodeEditor extends StatelessWidget {
  const RfwCodeEditor({
    super.key,
    required this.extensionController,
  });

  final RfwExtensionController extensionController;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: extensionController.selectedRfwLibrary,
        builder: (context, library, _) {
          if (library == null) {
            return const Center(
              child: Text('No library selected'),
            );
          }
          if (library.content == null) {
            return const Center(
              child: Text('Cannot show content for this library'),
            );
          }
          extensionController.rfwContentController.text = library.content!;
          return RfwpadTextEditor(
            codeController: extensionController.rfwContentController,
            onChanged: extensionController.editRfwContent,
            error: null,
            includeBorder: false,
          );
        });
  }
}

class RfwDataEditor extends StatelessWidget {
  const RfwDataEditor({
    super.key,
    required this.extensionController,
  });

  final RfwExtensionController extensionController;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: extensionController.selectedRfwData,
      builder: (context, data, _) {
        if (data == null) {
          return const Center(
            child: Text('No data for the selected widget.'),
          );
        }

        extensionController.rfwDataController.text = _jsonEncoder.convert(data);
        return RfwpadTextEditor(
          codeController: extensionController.rfwDataController,
          onChanged: extensionController.editRfwData,
          error: null,
          includeBorder: false,
        );
      },
    );
  }
}

class RfwEventsView extends StatefulWidget {
  const RfwEventsView({super.key, required this.extensionController});

  final RfwExtensionController extensionController;

  @override
  State<RfwEventsView> createState() => _RfwEventsViewState();
}

class _RfwEventsViewState extends State<RfwEventsView> with AutoDisposeMixin {
  final selectedEvent = ValueNotifier<RfwEvent?>(null);

  List<RfwEvent> events = [];

  @override
  void initState() {
    super.initState();
    events = widget.extensionController.selectedRfwEvents.value;
    addAutoDisposeListener(widget.extensionController.selectedRfwEvents,
        () async {
      setState(() {
        events = widget.extensionController.selectedRfwEvents.value;
      });
    });
  }

  @override
  void dispose() {
    selectedEvent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Center(child: Text('No events to show.'));
    }
    return Split(
      axis: Axis.horizontal,
      initialFractions: const [0.5, 0.5],
      children: [
        OutlineDecoration.onlyRight(
          child: ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return OutlineDecoration.onlyBottom(
                child: InkWell(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: defaultSpacing,
                      vertical: denseSpacing,
                    ),
                    child: Text(event.name),
                  ),
                  onTap: () => selectedEvent.value = event,
                ),
              );
            },
          ),
        ),
        OutlineDecoration.onlyLeft(
          child: ValueListenableBuilder(
            valueListenable: selectedEvent,
            builder: (context, selected, _) {
              if (selected == null) {
                return const Center(child: Text('Select an event.'));
              }
              return Padding(
                padding: const EdgeInsets.all(denseSpacing),
                child: FormattedJson(json: selected.args),
              );
            },
          ),
        ),
      ],
    );
  }
}

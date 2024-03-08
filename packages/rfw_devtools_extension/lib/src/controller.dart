// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:code_text_field/code_text_field.dart';
import 'package:devtools_app_shared/utils.dart';
import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:highlight/languages/dart.dart';
import 'package:rfw_devtools_extension/src/model.dart';
import 'package:rfw_devtools_extension/src/rfw_connection/data_providers.dart';

class RfwExtensionController {
  final service = RfwExtensionService();

  final rfws = ListValueNotifier<RfwData>([]);

  ValueListenable<RfwData?> get selectedRfw => _selectedRfw;
  final _selectedRfw = ValueNotifier<RfwData?>(null);

  ValueListenable<List<String>> get selectedRfwLibraryNames =>
      _selectedRfwLibraryNames;
  final _selectedRfwLibraryNames = ValueNotifier<List<String>>([]);

  ValueListenable<RfwLibrary?> get selectedRfwLibrary => _selectedRfwLibrary;
  final _selectedRfwLibrary = ValueNotifier<RfwLibrary?>(null);

  ValueListenable<Map<String, Object?>?> get selectedRfwData =>
      _selectedRfwData;
  final _selectedRfwData = ValueNotifier<Map<String, Object?>?>({});

  final selectedRfwEvents = ListValueNotifier<RfwEvent>([]);

  final rfwContentController = CodeController(language: dart);
  final rfwDataController = CodeController(language: dart);

  Future<void> init() async {
    // final nodes = ref.watch(sortedProviderNodesProvider);
  }

  void selectRfw(RfwData rfw) {
    _selectedRfw.value = rfw;
    _updateNotifiersForSelected();
  }

  Future<void> _updateNotifiersForSelected() async {
    final selected = _selectedRfw.value;
    final libraryNames = await service.fetchRfwLibraryNames(selected);

    String? selectedLibraryName;
    String? selectedLibraryContent;
    if (libraryNames.isNotEmpty) {
      selectedLibraryName = libraryNames.first;
      selectedLibraryContent =
          await service.fetchRfwLibraryContent(selected, selectedLibraryName);
    }

    final data = await service.fetchRfwData(selected);
    final events = await service.fetchRfwEvents(selected);

    _selectedRfwLibraryNames.value = libraryNames;
    if (selectedLibraryName != null) {
      _selectedRfwLibrary.value = RfwLibrary(
          name: selectedLibraryName, content: selectedLibraryContent);
    }
    _selectedRfwData.value = data;
    selectedRfwEvents
      ..clear()
      ..addAll(events);
  }

  Future<void> selectLibrary(String? name) async {
    if (name == null) {
      _selectedRfwLibrary.value = null;
      return;
    }

    final selectedLibraryContent =
        await service.fetchRfwLibraryContent(_selectedRfw.value, name);
    _selectedRfwLibrary.value =
        RfwLibrary(name: name, content: selectedLibraryContent);
  }

  void editRfwContent(String value) {}

  void editRfwData(String value) {}
}

class RfwExtensionService {
  Future<Map<String, Object?>?> fetchRfwData(RfwData? rfw) async {
    if (rfw == null) return null;
    try {
      final response = await serviceManager.callServiceExtensionOnMainIsolate(
        'ext.rfw.getRemoteWidgetData',
        args: {'id': rfw.id},
      );
      final data = (response.json?['data'] as Map?)?.cast<String, Object?>();
      return data;
    } catch (e) {
      print('Error fetching RFW data for ${rfw.id}: $e');
      return null;
    }
  }

  Future<List<RfwEvent>> fetchRfwEvents(RfwData? rfw) async {
    if (rfw == null) return [];
    try {
      final response = await serviceManager.callServiceExtensionOnMainIsolate(
        'ext.rfw.getRemoteWidgetEvents',
        args: {'id': rfw.id},
      );
      final events =
          (response.json?['events'] as List?)?.cast<Map<String, Object?>>();

      return events?.map((e) => RfwEvent.parse(e)).toList() ?? [];
    } catch (e) {
      print('Error fetching RFW events for ${rfw.id}: $e');
      return [];
    }
  }

  Future<List<String>> fetchRfwLibraryNames(RfwData? rfw) async {
    if (rfw == null) return [];
    try {
      final response = await serviceManager.callServiceExtensionOnMainIsolate(
        'ext.rfw.getRemoteWidgetLibraries',
        args: {'id': rfw.id},
      );
      return (response.json?['libraries'] as List?)?.cast<String>().toList() ??
          <String>[];
    } catch (e) {
      print('Error fetching RFW library names for ${rfw.id}: $e');
      return [];
    }
  }

  Future<String?> fetchRfwLibraryContent(
    RfwData? rfw,
    String? libraryName,
  ) async {
    if (rfw == null || libraryName == null) return null;
    try {
      final response = await serviceManager.callServiceExtensionOnMainIsolate(
        'ext.rfw.getRemoteWidgetLibraryContent',
        args: {
          'id': rfw.id,
          'name': libraryName,
        },
      );
      return response.json?['content'] as String?;
    } catch (e) {
      print('Error fetching RFW library content for ${rfw.id}: $e');
      return null;
    }
  }
}

// const _testRfws = [
//   RfwData(
//     id: '0',
//     type: 'FooRemoteWidget',
//     // content: initialRfwText,
//     // data: initialRfwData,
//   ),
//   RfwData(
//     id: '1',
//     type: 'BarRemoteWidget',
//     // content: initialRfwText,
//     // data: initialRfwData,
//   ),
//   RfwData(
//     id: '2',
//     type: 'BazzRemoteWidget',
//     // content: initialRfwText,
//     // data: initialRfwData,
//   ),
// ];

// const _testRfwEvents = [
//   RfwEvent('AbcEvent', {'id': 34, 'description': 'lorem ipsum'}),
//   RfwEvent('DefEvent', {'id': 35, 'description': 'lorem ipsum'}),
//   RfwEvent('XyzEvent', {'id': 36, 'description': 'lorem ipsum'}),
// ];

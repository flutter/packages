// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:devtools_app_shared/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../async_state.dart';
import '../shared_preferences_state.dart';
import '../shared_preferences_state_notifier.dart';
import '../shared_preferences_state_notifier_provider.dart';
import 'error_panel.dart';

/// A panel that displays the data of the selected key.
class DataPanel extends StatefulWidget {
  /// Default constructor for [DataPanel].
  const DataPanel({super.key});

  @override
  State<DataPanel> createState() => _DataPanelState();
}

class _DataPanelState extends State<DataPanel> {
  String? currentValue;

  void _setCurrentValue(String value) {
    setState(() {
      currentValue = value;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _dismissDialog() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final SharedPreferencesStateNotifier notifier =
        SharedPreferencesStateNotifierProvider.of(context);
    final SharedPreferencesState? data = notifier.value.dataOrNull;
    final SelectedSharedPreferencesKey? selectedKey = data?.selectedKey;

    if (data == null || selectedKey == null) {
      return const Center(
        child: Text('Select a key to view its data.'),
      );
    }

    return RoundedOutlinedBorder(
      clip: true,
      child: switch (selectedKey.value) {
        AsyncStateLoading<SharedPreferencesData>() => const Center(
            child: CircularProgressIndicator(),
          ),
        final AsyncStateError<SharedPreferencesData> value => ErrorPanel(
            error: value.error,
            stackTrace: value.stackTrace,
          ),
        final AsyncStateData<SharedPreferencesData> value => Column(
            children: <Widget>[
              AreaPaneHeader(
                roundedTopBorder: false,
                includeTopBorder: false,
                tall: true,
                title: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        selectedKey.key,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    if (data.editing) ...<Widget>[
                      TextButton(
                        onPressed: () => notifier.stopEditing(),
                        child: const Text('Cancel'),
                      ),
                      if (currentValue case final String currentValue?
                          when currentValue != value.data.valueAsString &&
                              (value.data is SharedPreferencesDataString ||
                                  currentValue.isNotEmpty)) ...<Widget>[
                        const SizedBox(width: defaultSpacing),
                        TextButton(
                          onPressed: () async {
                            try {
                              await notifier.changeValue(
                                selectedKey.key,
                                value.data.changeValue(currentValue),
                              );
                            } catch (error) {
                              _showSnackBar('Error: $error');
                            }
                          },
                          child: const Text('Commit changes'),
                        ),
                      ],
                    ] else ...<Widget>[
                      TextButton(
                        onPressed: () => showDialog<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return DevToolsDialog(
                              title: const Text('Remove Key'),
                              content: Text(
                                'Are you sure you want to remove ${selectedKey.key}?',
                              ),
                              actions: <Widget>[
                                const DialogCancelButton(),
                                DialogTextButton(
                                  child: const Text('REMOVE'),
                                  onPressed: () async {
                                    try {
                                      await notifier.deleteKey(selectedKey);
                                    } catch (error) {
                                      _showSnackBar('Error: $error');
                                    }
                                    _dismissDialog();
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                        child: const Text('Remove'),
                      ),
                      TextButton(
                        onPressed: () => notifier.startEditing(),
                        child: const Text('Edit'),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(largeSpacing),
                    child: SelectionArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text('Type: ${value.data.prettyType}'),
                          const SizedBox(height: denseSpacing),
                          if (data.editing) ...<Widget>[
                            const Text('Value:'),
                            const SizedBox(height: denseSpacing),
                            switch (value.data) {
                              final SharedPreferencesDataBool state =>
                                DropdownMenu<bool>(
                                  initialSelection: state.value,
                                  onSelected: (bool? value) {
                                    _setCurrentValue(value.toString());
                                  },
                                  dropdownMenuEntries: const <DropdownMenuEntry<
                                      bool>>[
                                    DropdownMenuEntry<bool>(
                                      label: 'true',
                                      value: true,
                                    ),
                                    DropdownMenuEntry<bool>(
                                      label: 'false',
                                      value: false,
                                    ),
                                  ],
                                ),
                              final SharedPreferencesDataStringList state =>
                                _EditStringList(
                                  selectedKey: selectedKey.key,
                                  initialData: state.value,
                                  onChanged: _setCurrentValue,
                                ),
                              _ => TextFormField(
                                  autofocus: true,
                                  initialValue: value.data.valueAsString,
                                  inputFormatters: switch (value.data) {
                                    SharedPreferencesDataInt() =>
                                      <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'^-?\d*'),
                                        ),
                                      ],
                                    SharedPreferencesDataDouble() =>
                                      <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'^-?\d*\.?\d*'),
                                        ),
                                      ],
                                    _ => <TextInputFormatter>[],
                                  },
                                  onChanged: _setCurrentValue,
                                )
                            },
                          ] else ...<Widget>[
                            Text('Value: ${value.data.valueAsString}'),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
      },
    );
  }
}

class _EditStringList extends StatefulWidget {
  const _EditStringList({
    required this.selectedKey,
    required this.initialData,
    required this.onChanged,
  });

  final String selectedKey;
  final List<String> initialData;
  final ValueChanged<String> onChanged;

  @override
  State<_EditStringList> createState() => _EditStringListState();
}

class _EditStringListState extends State<_EditStringList> {
  late final List<(int key, String value)> _currentList;
  int _keyCounter = 0;

  void _addElementAt(int index) {
    setState(() {
      _currentList.insert(index, (_keyCounter++, ''));
    });
  }

  @override
  void initState() {
    super.initState();
    _currentList = <(int, String)>[
      for (final String str in widget.initialData) (_keyCounter++, str),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final (int index, (int keyValue, String str))
            in _currentList.indexed) ...<Widget>[
          _AddListElement(
            onPressed: () => _addElementAt(index),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: densePadding),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    key: Key('list_element_$keyValue'),
                    initialValue: str,
                    onChanged: (String value) {
                      setState(() {
                        _currentList[index] = (keyValue, value);
                      });
                      widget.onChanged(jsonEncode(
                        <String>[
                          for (final (_, String value) in _currentList) value,
                        ],
                      ));
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.remove,
                    size: 16,
                  ),
                  onPressed: () {
                    setState(() {
                      _currentList.removeAt(index);
                    });
                  },
                )
              ],
            ),
          ),
        ],
        _AddListElement(
          onPressed: () => _addElementAt(_currentList.length),
        ),
      ],
    );
  }
}

class _AddListElement extends StatelessWidget {
  const _AddListElement({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        icon: const Icon(
          Icons.add,
          size: 16,
        ),
        onPressed: onPressed,
      ),
    );
  }
}

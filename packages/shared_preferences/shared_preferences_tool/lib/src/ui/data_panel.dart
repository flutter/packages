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
import '../shared_preferences_state_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final AsyncState<SharedPreferencesData>? selectedKeyData =
        SharedPreferencesStateProvider.selectedKeyDataOf(context);

    return RoundedOutlinedBorder(
      clip: true,
      child: switch (selectedKeyData) {
        null => const Center(
            child: Text('Select a key to view its data.'),
          ),
        AsyncStateLoading<SharedPreferencesData>() => const Center(
            child: CircularProgressIndicator(),
          ),
        final AsyncStateError<SharedPreferencesData> value => ErrorPanel(
            error: value.error,
            stackTrace: value.stackTrace,
          ),
        AsyncStateData<SharedPreferencesData>(
          data: final SharedPreferencesData data,
        ) =>
          Column(
            children: <Widget>[
              _Header(
                currentValue: currentValue,
                data: data,
              ),
              Expanded(
                child: _Content(
                  data: data,
                  setCurrentValue: _setCurrentValue,
                ),
              ),
            ],
          ),
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.currentValue,
    required this.data,
  });

  final String? currentValue;
  final SharedPreferencesData data;

  @override
  Widget build(BuildContext context) {
    final bool editing = SharedPreferencesStateProvider.editingOf(context);
    // it is safe to assume that the selected key is not null
    // because the header is only shown when a key is selected
    final String selectedKey =
        SharedPreferencesStateProvider.requireSelectedKeyOf(context).key;

    return AreaPaneHeader(
      roundedTopBorder: false,
      includeTopBorder: false,
      tall: true,
      title: Text(
        selectedKey,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      actions: <Widget>[
        if (editing) ...<Widget>[
          DevToolsButton(
            onPressed: () {
              context.sharedPreferencesStateNotifier.stopEditing();
            },
            label: 'Cancel',
          ),
          if (currentValue case final String currentValue?
              when currentValue != data.valueAsString &&
                  (data is SharedPreferencesDataString ||
                      currentValue.isNotEmpty)) ...<Widget>[
            const SizedBox(width: denseRowSpacing),
            DevToolsButton(
              onPressed: () async {
                try {
                  await context.sharedPreferencesStateNotifier.changeValue(
                    data.changeValue(currentValue),
                  );
                } catch (error) {
                  if (context.mounted) {
                    context.showSnackBar('Error: $error');
                  }
                }
              },
              label: 'Apply changes',
            ),
          ],
        ] else ...<Widget>[
          DevToolsButton(
            onPressed: () {
              // we need to get the notifier here because it is not present in
              // the context when the dialog is built
              final SharedPreferencesStateNotifier notifier =
                  context.sharedPreferencesStateNotifier;
              showDialog<void>(
                context: context,
                builder: (BuildContext context) => _ConfirmRemoveDialog(
                  selectedKey: selectedKey,
                  notifier: notifier,
                ),
              );
            },
            label: 'Remove',
          ),
          const SizedBox(width: denseRowSpacing),
          DevToolsButton(
            onPressed: () =>
                context.sharedPreferencesStateNotifier.startEditing(),
            label: 'Edit',
          ),
        ],
      ],
    );
  }
}

class _ConfirmRemoveDialog extends StatelessWidget {
  const _ConfirmRemoveDialog({
    required this.selectedKey,
    required this.notifier,
  });

  final String selectedKey;
  final SharedPreferencesStateNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return DevToolsDialog(
      title: const Text('Remove Key'),
      content: Text(
        'Are you sure you want to remove $selectedKey?',
      ),
      actions: <Widget>[
        const DialogCancelButton(),
        DialogTextButton(
          child: const Text('REMOVE'),
          onPressed: () async {
            Navigator.of(context).pop();
            try {
              await notifier.deleteSelectedKey();
            } catch (error) {
              if (context.mounted) {
                context.showSnackBar('Error: $error');
              }
            }
          },
        ),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.data,
    required this.setCurrentValue,
  });

  final SharedPreferencesData data;
  final ValueChanged<String> setCurrentValue;

  @override
  Widget build(BuildContext context) {
    final bool editing = SharedPreferencesStateProvider.editingOf(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(largeSpacing),
        child: SelectionArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Type: ${data.kind}'),
              const SizedBox(height: denseSpacing),
              if (editing) ...<Widget>[
                const Text('Value:'),
                const SizedBox(height: denseSpacing),
                switch (data) {
                  final SharedPreferencesDataBool state => _EditBoolean(
                      initialValue: state.value,
                      setCurrentValue: setCurrentValue,
                    ),
                  final SharedPreferencesDataStringList state =>
                    _EditStringList(
                      initialData: state.value,
                      onChanged: setCurrentValue,
                    ),
                  _ => TextFormField(
                      autofocus: true,
                      initialValue: data.valueAsString,
                      inputFormatters: switch (data) {
                        SharedPreferencesDataInt() => <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^-?\d*'),
                            ),
                          ],
                        SharedPreferencesDataDouble() => <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^-?\d*\.?\d*'),
                            ),
                          ],
                        _ => <TextInputFormatter>[],
                      },
                      onChanged: setCurrentValue,
                    )
                },
              ] else ...<Widget>[
                Text('Value: ${data.valueAsString}'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EditBoolean extends StatelessWidget {
  const _EditBoolean({
    required this.setCurrentValue,
    required this.initialValue,
  });

  final ValueChanged<String> setCurrentValue;
  final bool initialValue;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<bool>(
      initialSelection: initialValue,
      onSelected: (bool? value) {
        setCurrentValue(value.toString());
      },
      dropdownMenuEntries: const <DropdownMenuEntry<bool>>[
        DropdownMenuEntry<bool>(
          label: 'true',
          value: true,
        ),
        DropdownMenuEntry<bool>(
          label: 'false',
          value: false,
        ),
      ],
    );
  }
}

class _EditStringList extends StatefulWidget {
  const _EditStringList({
    required this.initialData,
    required this.onChanged,
  });

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
    _updateValue();
  }

  void _updateValue() {
    widget.onChanged(jsonEncode(
      <String>[
        for (final (_, String value) in _currentList) value,
      ],
    ));
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
          if (index > 0) const SizedBox(height: largeSpacing),
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
                      _updateValue();
                    },
                  ),
                ),
                DevToolsButton(
                  icon: Icons.remove,
                  onPressed: () {
                    setState(() {
                      _currentList.removeAt(index);
                    });
                    _updateValue();
                  },
                )
              ],
            ),
          ),
        ],
        const SizedBox(height: largeSpacing),
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
      child: DevToolsButton(
        icon: Icons.add,
        onPressed: onPressed,
      ),
    );
  }
}

extension on BuildContext {
  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}

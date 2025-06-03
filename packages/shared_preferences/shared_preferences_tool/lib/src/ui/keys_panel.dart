// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:devtools_app_shared/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../async_state.dart';
import '../shared_preferences_state.dart';
import '../shared_preferences_state_provider.dart';
import 'api_switch.dart';
import 'error_panel.dart';

/// A panel that displays the keys stored in shared preferences.
class KeysPanel extends StatefulWidget {
  /// Default constructor for [KeysPanel].
  const KeysPanel({super.key});

  @override
  State<KeysPanel> createState() => _KeysPanelState();
}

class _KeysPanelState extends State<KeysPanel> {
  bool searching = false;
  final FocusNode searchFocusNode = FocusNode();

  @override
  void dispose() {
    searchFocusNode.dispose();
    super.dispose();
  }

  void _startSearching() {
    setState(() {
      searching = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    void stopSearching() {
      setState(() {
        searching = false;
      });
      context.sharedPreferencesStateNotifier.filter('');
    }

    return RoundedOutlinedBorder(
      clip: true,
      child: Column(
        children: <Widget>[
          AreaPaneHeader(
            roundedTopBorder: false,
            includeTopBorder: false,
            tall: true,
            title: Row(
              children: <Widget>[
                Text(
                  'Stored Keys',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (searching) ...<Widget>[
                  const SizedBox(
                    width: denseSpacing,
                  ),
                  Expanded(
                    child: _SearchField(
                      searchFocusNode: searchFocusNode,
                      stopSearching: stopSearching,
                    ),
                  ),
                ] else ...<Widget>[
                  const Spacer(),
                  _ToolbarAction(
                    tooltipMessage: 'Search',
                    icon: Icons.search,
                    onPressed: _startSearching,
                  ),
                ],
                const SizedBox(
                  width: denseRowSpacing,
                ),
                _ToolbarAction(
                  tooltipMessage: 'Refresh',
                  icon: Icons.refresh,
                  onPressed: () {
                    stopSearching();
                    context.sharedPreferencesStateNotifier.fetchAllKeys();
                  },
                ),
              ],
            ),
          ),
          const ApiSwitch(),
          const Expanded(
            child: _StateMapper(),
          ),
        ],
      ),
    );
  }
}

// TODO(adsonpleal): replace this with `ToolbarAction` once it's available in `devtools_app_shared`, https://github.com/flutter/devtools/issues/7793.
class _ToolbarAction extends StatelessWidget {
  const _ToolbarAction({
    required this.tooltipMessage,
    required this.icon,
    required this.onPressed,
  });

  final String tooltipMessage;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DevToolsTooltip(
      message: tooltipMessage,
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: onPressed,
        child: Icon(
          icon,
          size: actionsIconSize,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.searchFocusNode,
    required this.stopSearching,
  });

  final FocusNode searchFocusNode;
  final VoidCallback stopSearching;

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: searchFocusNode,
      onKeyEvent: (KeyEvent value) {
        if (value.logicalKey == LogicalKeyboardKey.escape) {
          stopSearching();
        }
      },
      child: TextField(
        autofocus: true,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: densePadding,
          ),
          hintText: 'Search',
          border: const OutlineInputBorder(),
          suffix: _ToolbarAction(
            tooltipMessage: 'Stop searching',
            icon: Icons.close,
            onPressed: stopSearching,
          ),
        ),
        onChanged: (String newValue) {
          context.sharedPreferencesStateNotifier.filter(newValue);
        },
      ),
    );
  }
}

class _StateMapper extends StatelessWidget {
  const _StateMapper();

  @override
  Widget build(BuildContext context) {
    return switch (SharedPreferencesStateProvider.keysListStateOf(context)) {
      final AsyncStateData<List<String>> value => _KeysList(
          keys: value.data,
        ),
      final AsyncStateError<List<String>> value => ErrorPanel(
          error: value.error,
          stackTrace: value.stackTrace,
        ),
      AsyncStateLoading<List<String>>() => const Center(
          child: CircularProgressIndicator(),
        ),
    };
  }
}

class _KeysList extends StatefulWidget {
  const _KeysList({
    required this.keys,
  });

  final List<String> keys;

  @override
  State<_KeysList> createState() => _KeysListState();
}

class _KeysListState extends State<_KeysList> {
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: scrollController,
      child: ListView(
        controller: scrollController,
        children: <Widget>[
          for (final String keyName in widget.keys)
            _KeyItem(
              keyName: keyName,
            ),
        ],
      ),
    );
  }
}

class _KeyItem extends StatelessWidget {
  const _KeyItem({
    required this.keyName,
  });

  final String keyName;

  @override
  Widget build(BuildContext context) {
    final SelectedSharedPreferencesKey? selectedKey =
        SharedPreferencesStateProvider.selectedKeyOf(context);
    final bool isSelected = selectedKey?.key == keyName;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color? backgroundColor =
        isSelected ? colorScheme.selectedRowBackgroundColor : null;

    return InkWell(
      onTap: () {
        context.sharedPreferencesStateNotifier.selectKey(keyName);
      },
      child: Container(
        color: backgroundColor,
        padding: const EdgeInsets.only(
          left: defaultSpacing,
          right: densePadding,
          top: densePadding,
          bottom: densePadding,
        ),
        child: Text(
          keyName,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
    );
  }
}

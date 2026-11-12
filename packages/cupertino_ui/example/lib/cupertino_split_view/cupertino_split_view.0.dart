// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// #region body
import 'package:cupertino_ui/cupertino_ui.dart';

/// Flutter code sample for [CupertinoSplitView].

void main() => runApp(const CupertinoSplitViewApp());

class CupertinoSplitViewApp extends StatelessWidget {
  const CupertinoSplitViewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      home: CupertinoSplitView<String>(
        initialColumnVisibility: CupertinoSplitViewVisibility.doubleColumn,
        sidebar: _MailboxSidebar(),
        detailBuilder: _buildMailboxDetail,
      ),
    );
  }

  static Widget _buildMailboxDetail(BuildContext context, String? selection) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(selection ?? 'Mail')),
      child: Center(
        child: Text(
          selection == null ? 'Select a mailbox' : 'Messages in $selection',
        ),
      ),
    );
  }
}

class _MailboxSidebar extends StatelessWidget {
  const _MailboxSidebar();

  static const List<String> mailboxes = <String>['Inbox', 'Drafts', 'Sent'];

  @override
  Widget build(BuildContext context) {
    final CupertinoSplitViewState<String>? splitView =
        CupertinoSplitView.maybeOf<String>(context);
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          const CupertinoSliverNavigationBar(largeTitle: Text('Mailboxes')),
          SliverToBoxAdapter(
            child: CupertinoListSection.insetGrouped(
              children: <Widget>[
                for (final String mailbox in mailboxes)
                  Semantics(
                    selected: splitView?.selection == mailbox,
                    child: CupertinoListTile(
                      title: Text(mailbox),
                      onTap: () => splitView?.select(mailbox),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// #endregion body

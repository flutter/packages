import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../models/mail_models.dart';
import '../theme/mail_theme.dart';
import 'compose_email_sheet.dart';
import 'inbox_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MAILBOXES VIEW (1:1 iOS 26 Mail Screen)
// ─────────────────────────────────────────────────────────────────────────────

class MailboxesView extends StatefulWidget {
  const MailboxesView({
    super.key,
    required this.emails,
    required this.onMarkAllAsRead,
    required this.onDeleteEmail,
    required this.onToggleUnread,
  });

  final List<MailItem> emails;
  final VoidCallback onMarkAllAsRead;
  final void Function(String id) onDeleteEmail;
  final void Function(String id) onToggleUnread;

  @override
  State<MailboxesView> createState() => _MailboxesViewState();
}

class _MailboxesViewState extends State<MailboxesView> {
  final GlassLargeTitleController _titleController =
      GlassLargeTitleController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _navigateToInbox(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => MailGlassScope(
          child: InboxView(
            emails: widget.emails,
            onMarkAllAsRead: widget.onMarkAllAsRead,
            onDeleteEmail: widget.onDeleteEmail,
            onToggleUnread: widget.onToggleUnread,
          ),
        ),
      ),
    );
  }

  void _openCompose(BuildContext context, GlassMorphAnchor? anchor) {
    GlassModalSheet.show(
      context: context,
      morphFrom: anchor,
      initialState: GlassSheetState.full,
      builder: (sheetContext) => MailGlassScope(
        child: ComposeEmailSheet(
          onSend: (to, subject, body) {
            setState(() {
              widget.emails.insert(
                0,
                MailItem(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  sender: 'To: $to',
                  time: 'Just now',
                  subject: subject,
                  snippet: '↳ $body',
                  initials: to.isNotEmpty ? to[0].toUpperCase() : 'ME',
                  avatarType: AvatarType.initials,
                  avatarColor: const Color(0xFF007AFF),
                  isUnread: false,
                  body: body,
                ),
              );
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPad = mediaQuery.padding.top;
    final botPad = mediaQuery.padding.bottom;
    final unreadCount = widget.emails.where((e) => e.isUnread).length;

    return GlassScaffold(
      background: ColoredBox(color: kMailBg.resolveFrom(context)),
      appBar: GlassAppBar.pinned(
        buttonSettings: kMailTriggerGlass(context),
        title: Text(
          'Mailboxes',
          style: TextStyle(
            color: CupertinoColors.label.resolveFrom(context),
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        largeTitleController: _titleController,
        actions: [
          // Edit capsule pill that morphs into the inbox menu button (···)
          GlassBarItem.custom(
            id: 'inbox_menu',
            background: GlassBarItemBackground.separate,
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Center(
                child: Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    color: CupertinoColors.label.resolveFrom(context),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // Compose button floats in bottom-right corner
      bottomBar: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          botPad > 24 ? botPad - 8 : 16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GlassMorphTrigger(
              builder: (triggerContext, anchor) => GlassButton.custom(
                onTap: () => _openCompose(context, anchor),
                width: 52,
                height: 52,
                settings: kMailSearchGlass(context),
                shape: const LiquidOval(),
                quality: GlassQuality.premium,
                useOwnLayer: true,
                child: Center(
                  child: Icon(
                    CupertinoIcons.square_pencil,
                    size: 24,
                    color: CupertinoColors.label.resolveFrom(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        controller: _titleController.scrollController,
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: topPad + 44)),

          // Large Title "Mailboxes" (collapses automatically on scroll)
          GlassLargeTitle(
            text: 'Mailboxes',
            controller: _titleController,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
          ),

          // Subtitle "Updated Just Now"
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Updated Just Now',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: kMailSecondaryLabel.resolveFrom(context),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 14)),

          // ── FIRST CARD: INSET GROUPED (Normal list, never glass in scroll) ──
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: kMailCardBg.resolveFrom(context),
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _MailboxRow(
                    icon: CupertinoIcons.tray,
                    iconColor: kMailBlue,
                    title: 'All Inboxes',
                    count: unreadCount > 0 ? unreadCount : 6899,
                    onTap: () => _navigateToInbox(context),
                  ),
                  _buildDivider(context),
                  _MailboxRow(
                    icon: CupertinoIcons.tray,
                    iconColor: kMailBlue,
                    title: 'iCloud',
                    count: 24549,
                    onTap: () => _navigateToInbox(context),
                  ),
                  _buildDivider(context),
                  _MailboxRow(
                    icon: CupertinoIcons.tray,
                    iconColor: kMailBlue,
                    title: 'alex@orion-labs.com',
                    count: 18375,
                    onTap: () => _navigateToInbox(context),
                  ),
                  _buildDivider(context),
                  _MailboxRow(
                    icon: CupertinoIcons.tray,
                    iconColor: kMailBlue,
                    title: 'Orion Labs',
                    count: 458,
                    onTap: () => _navigateToInbox(context),
                  ),
                  _buildDivider(context),
                  _MailboxRow(
                    icon: CupertinoIcons.flag,
                    iconColor: CupertinoColors.systemOrange,
                    title: 'Flagged',
                    count: 74,
                    onTap: () => _navigateToInbox(context),
                  ),
                  _buildDivider(context),
                  _MailboxRow(
                    icon: CupertinoIcons.star,
                    iconColor: const Color(0xFFFFD60A),
                    title: 'VIP',
                    onTap: () => _navigateToInbox(context),
                  ),
                  _buildDivider(context),
                  _MailboxRow(
                    icon: CupertinoIcons.paperclip,
                    iconColor: kMailBlue,
                    title: 'Attachments',
                    count: 498,
                    onTap: () => _navigateToInbox(context),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── SECTION 2 HEADER: ACCOUNT FOLDER WITH BLUE DROPDOWN CHEVRON ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Orion Account',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: CupertinoColors.label.resolveFrom(context),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    CupertinoIcons.chevron_down,
                    size: 18,
                    color: kMailBlue,
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          // ── SECOND CARD: INSET GROUPED (Normal list, never glass in scroll) ──
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: kMailCardBg.resolveFrom(context),
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _MailboxRow(
                    icon: CupertinoIcons.tray,
                    iconColor: kMailBlue,
                    title: 'Inbox',
                    count: 24549,
                    onTap: () => _navigateToInbox(context),
                  ),
                  _buildDivider(context),
                  _MailboxRow(
                    icon: CupertinoIcons.doc,
                    iconColor: kMailBlue,
                    title: 'Drafts',
                    onTap: () {},
                  ),
                  _buildDivider(context),
                  _MailboxRow(
                    icon: CupertinoIcons.paperplane,
                    iconColor: kMailBlue,
                    title: 'Sent',
                    onTap: () {},
                  ),
                  _buildDivider(context),
                  _MailboxRow(
                    icon: CupertinoIcons.archivebox,
                    iconColor: kMailBlue,
                    title: 'Spam',
                    onTap: () {},
                  ),
                  _buildDivider(context),
                  _MailboxRow(
                    icon: CupertinoIcons.trash,
                    iconColor: kMailBlue,
                    title: 'Bin',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),

          // Bottom scroll clearance for floating compose button
          SliverToBoxAdapter(child: SizedBox(height: 120 + botPad)),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 0.5,
      color: kMailDivider.resolveFrom(context),
      margin: const EdgeInsets.only(left: 54),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MAILBOX ROW (Standard iOS List Item — Normal Container, No Glass)
// ─────────────────────────────────────────────────────────────────────────────

class _MailboxRow extends StatelessWidget {
  const _MailboxRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.count,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final int? count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Left Icon in 24px box
            SizedBox(
              width: 26,
              height: 26,
              child: Center(
                child: Icon(
                  icon,
                  size: 22,
                  color: iconColor,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Title
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Unread / Total Count Badge
            if (count != null) ...[
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 16,
                  color: kMailSecondaryLabel.resolveFrom(context),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 6),
            ],

            // iOS Chevron
            const Icon(
              CupertinoIcons.chevron_right,
              size: 14,
              color: Color(0xFF48484A),
            ),
          ],
        ),
      ),
    );
  }
}

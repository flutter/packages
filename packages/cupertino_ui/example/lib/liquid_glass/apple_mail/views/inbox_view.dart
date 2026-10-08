import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../models/mail_models.dart';
import '../theme/mail_theme.dart';
import 'compose_email_sheet.dart';
import 'email_detail_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// INBOX VIEW (Email List + Glass Bottom Utility Bar)
// ─────────────────────────────────────────────────────────────────────────────

class InboxView extends StatefulWidget {
  const InboxView({
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
  State<InboxView> createState() => _InboxViewState();
}

class _InboxViewState extends State<InboxView> {
  final GlassLargeTitleController _titleController =
      GlassLargeTitleController();
  final Set<String> _selectedIds = {};
  bool _isSelectMode = false;
  String _selectedView = 'List View'; // 'Categories' or 'List View'
  bool _showPriority = true;
  bool _showContactPhotos = true;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _toggleSelectMode() {
    setState(() {
      _isSelectMode = !_isSelectMode;
      _selectedIds.clear();
    });
  }

  void _toggleItemSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedIds.length == widget.emails.length) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(widget.emails.map((e) => e.id));
      }
    });
  }

  void _deleteSelected() {
    for (final id in _selectedIds.toList()) {
      widget.onDeleteEmail(id);
    }
    setState(() {
      _selectedIds.clear();
      _isSelectMode = false;
    });
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

    return GlassScaffold(
      background: ColoredBox(color: kMailBg.resolveFrom(context)),
      appBar: GlassAppBar.pinned(
        buttonSettings: kMailTriggerGlass(context),
        // ── No leading on the root Inbox screen — it is the bottom of the
        // navigation stack. A leading 'nav_back' item here would show a
        // spurious back chevron and confuse the GlassNavigationShell, which
        // uses id-matching to decide which items to hoist across routes.
        title: Text(
          'Inbox',
          style: TextStyle(
            color: CupertinoColors.label.resolveFrom(context),
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        largeTitleController: _titleController,
        // ─────────────────────────────────────────────────────────────────
        // Actions — gel-morph across two states and across the push to Detail
        //
        // Normal mode:  [ Edit (id:inbox_edit) | ··· (id:inbox_menu) ]
        //                 both share one glass capsule → glass == true
        //
        // Select mode:  [ Select All (id:inbox_select_all) | ✓ Done tinted ]
        //                 id:inbox_edit on Done matches id:inbox_edit above,
        //                 so the Shell cross-fades the glyph in-route.
        //
        // → Push to Detail: [ ∧ (id:detail_prev) | ∨ (id:detail_next) ]
        //   The capsule swells and the icons cross-fade across the push.
        // ─────────────────────────────────────────────────────────────────
        actions: _isSelectMode
            ? [
                // "Select All" / "Deselect All" — same oval pill as "Select"
                GlassBarItem.custom(
                  id: 'inbox_select_all',
                  background: GlassBarItemBackground.own,
                  child: GlassButton.custom(
                    onTap: _selectAll,
                    width: null,
                    height: 44,
                    settings: kMailTriggerGlass(context),
                    shape: const LiquidRoundedRectangle(borderRadius: 22),
                    quality: GlassQuality.premium,
                    useOwnLayer: true,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        _selectedIds.length == widget.emails.length
                            ? 'Deselect All'
                            : 'Select All',
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
                // Done ✓ — same id as Edit so the glyph cross-fades in-route
                GlassBarItem.icon(
                  id: 'inbox_edit',
                  icon: const Icon(CupertinoIcons.checkmark, size: 18),
                  onTap: _toggleSelectMode,
                  background: GlassBarItemBackground.separate,
                  tintColor: CupertinoColors.activeBlue,
                ),
              ]
            : [
                // ── "Select" pill — GlassButton.custom IS the glass surface,
                // so background: own prevents double-refraction (Rule 2) and
                // registers glass == true so the Shell can gel-morph on push.
                GlassBarItem.custom(
                  id: 'select_toggle',
                  background: GlassBarItemBackground.own,
                  child: GlassButton.custom(
                    onTap: _toggleSelectMode,
                    width: null,
                    height: 44,
                    settings: kMailTriggerGlass(context),
                    shape: const LiquidRoundedRectangle(borderRadius: 22),
                    quality: GlassQuality.premium,
                    useOwnLayer: true,
                    persistPressOnDrag: true,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'Select',
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
                // ── Options ··· menu (separate capsule)
                GlassBarItem.menu(
                  id: 'inbox_menu',
                  icon: const Icon(CupertinoIcons.ellipsis, size: 18),
                  background: GlassBarItemBackground.separate,
                  menuWidth: 260,
                  menuItems: [
                    // Visual Switcher: Categories vs List View
                    GlassMenuLabel(
                      height: _OptionsMenuViewSwitcher.height,
                      horizontalPadding: 0,
                      child: _OptionsMenuViewSwitcher(
                        selectedView: _selectedView,
                        onChanged: (view) =>
                            setState(() => _selectedView = view),
                      ),
                    ),
                    const GlassMenuDivider(),
                    GlassMenuItem(
                      title: 'About Categories',
                      icon: const Icon(CupertinoIcons.info_circle),
                      onTap: () {},
                    ),
                    GlassMenuItem(
                      title: 'Show Priority',
                      icon: Icon(
                        _showPriority
                            ? CupertinoIcons.checkmark
                            : CupertinoIcons.sparkles,
                      ),
                      onTap: () =>
                          setState(() => _showPriority = !_showPriority),
                    ),
                    GlassMenuItem(
                      title: 'Show Contact Photos',
                      icon: Icon(
                        _showContactPhotos
                            ? CupertinoIcons.checkmark
                            : CupertinoIcons.person_crop_circle,
                      ),
                      onTap: () => setState(
                          () => _showContactPhotos = !_showContactPhotos),
                    ),
                    const GlassMenuDivider(),
                    GlassMenuItem(
                      title: 'iOS 27 Glass',
                      closeDelay: const Duration(milliseconds: 650),
                      onTap: () {
                        MailGlassScope.of(context).value =
                            !MailGlassScope.isIos27(context);
                      },
                      trailing: GlassSwitch(
                        value: MailGlassScope.isIos27(context),
                        activeColor: kMailBlue,
                        useOwnLayer: true,
                        enableHaptics: false,
                        onChanged: (v) {
                          MailGlassScope.of(context).value = v;
                        },
                      ),
                    ),
                  ],
                ),
              ],
      ),
      bottomBar: _isSelectMode
          ? _BatchActionsBar(
              selectedCount: _selectedIds.length,
              onMarkRead: () {
                for (final id in _selectedIds) {
                  widget.onToggleUnread(id);
                }
                setState(() => _isSelectMode = false);
              },
              onDelete: _deleteSelected,
              bottomPad: botPad,
            )
          : _InboxBottomBar(
              bottomPad: botPad,
              onOpenCompose: (anchor) => _openCompose(context, anchor),
            ),
      body: CustomScrollView(
        controller: _titleController.scrollController,
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: topPad + 44)),

          // Large "Inbox" Header
          GlassLargeTitle(
            text: 'Inbox',
            controller: _titleController,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
          ),

          // Subtitle
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Orion Labs · Updated Just Now',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: kMailSecondaryLabel.resolveFrom(context),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // Email List Rows
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final email = widget.emails[i];
                final isSelected = _selectedIds.contains(email.id);

                return _EmailRow(
                  item: email,
                  isSelectMode: _isSelectMode,
                  isSelected: isSelected,
                  showContactPhotos: _showContactPhotos,
                  onSelectToggle: () => _toggleItemSelection(email.id),
                  onTap: () {
                    if (_isSelectMode) {
                      _toggleItemSelection(email.id);
                    } else {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => MailGlassScope(
                            child: EmailDetailView(
                              item: email,
                              emailIndex: i,
                              allEmails: widget.emails,
                              onDelete: () {
                                widget.onDeleteEmail(email.id);
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ),
                      );
                    }
                  },
                );
              },
              childCount: widget.emails.length,
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 96 + botPad)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OPTIONS MENU VIEW SWITCHER (Categories vs List View)
// ─────────────────────────────────────────────────────────────────────────────

class _OptionsMenuViewSwitcher extends StatelessWidget
    implements PreferredSizeWidget {
  const _OptionsMenuViewSwitcher({
    required this.selectedView,
    required this.onChanged,
  });

  final String selectedView;
  final ValueChanged<String> onChanged;

  static const double height = 156.0;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: OverflowBox(
        minWidth: 236,
        maxWidth: 236,
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: _PhoneOptionCard(
                  title: 'Categories',
                  isSelected: selectedView == 'Categories',
                  isCategories: true,
                  onTap: () => onChanged('Categories'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PhoneOptionCard(
                  title: 'List View',
                  isSelected: selectedView == 'List View',
                  isCategories: false,
                  onTap: () => onChanged('List View'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhoneOptionCard extends StatelessWidget {
  const _PhoneOptionCard({
    required this.title,
    required this.isSelected,
    required this.isCategories,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final bool isCategories;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Phone silhouette
          Container(
            width: 52,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? CupertinoColors.activeBlue
                    : const Color(0xFF3A3A3C),
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            padding: const EdgeInsets.all(5),
            child: Column(
              children: [
                if (isCategories) ...[
                  // Segmented categories header
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A3A3C),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ] else ...[
                  // Full list view header
                  Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: CupertinoColors.activeBlue.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Column(
                      children: List.generate(
                        4,
                        (index) => Container(
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2E),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.label.resolveFrom(context),
            ),
          ),
          const SizedBox(height: 5),
          Icon(
            isSelected
                ? CupertinoIcons.checkmark_circle_fill
                : CupertinoIcons.circle,
            size: 19,
            color: isSelected
                ? CupertinoColors.activeBlue
                : CupertinoColors.tertiaryLabel.resolveFrom(context),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMAIL ROW
// ─────────────────────────────────────────────────────────────────────────────

class _EmailRow extends StatelessWidget {
  const _EmailRow({
    required this.item,
    required this.isSelectMode,
    required this.isSelected,
    required this.showContactPhotos,
    required this.onSelectToggle,
    required this.onTap,
  });

  final MailItem item;
  final bool isSelectMode;
  final bool isSelected;
  final bool showContactPhotos;
  final VoidCallback onSelectToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      background: Container(
        color: CupertinoColors.systemOrange,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child:
            const Icon(CupertinoIcons.flag_fill, color: CupertinoColors.white),
      ),
      secondaryBackground: Container(
        color: CupertinoColors.systemRed,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child:
            const Icon(CupertinoIcons.trash_fill, color: CupertinoColors.white),
      ),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Select Mode Checkbox OR Unread Dot
                  if (isSelectMode)
                    Padding(
                      padding: const EdgeInsets.only(right: 8, top: 8),
                      child: Icon(
                        isSelected
                            ? CupertinoIcons.checkmark_circle_fill
                            : CupertinoIcons.circle,
                        color: isSelected
                            ? CupertinoColors.activeBlue
                            : CupertinoColors.tertiaryLabel
                                .resolveFrom(context),
                        size: 22,
                      ),
                    )
                  else
                    SizedBox(
                      width: 14,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: item.isUnread
                            ? Container(
                                width: 9,
                                height: 9,
                                decoration: const BoxDecoration(
                                  color: kMailBlue,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : null,
                      ),
                    ),
                  const SizedBox(width: 4),

                  // Avatar / Squircle (Apple store or Contact initials)
                  if (showContactPhotos) ...[
                    _EmailAvatar(item: item),
                    const SizedBox(width: 12),
                  ],

                  // Content column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sender + Time + Chevron
                        Row(
                          children: [
                            if (item.hasReplied) ...[
                              Icon(
                                CupertinoIcons.reply,
                                size: 14,
                                color: CupertinoColors.secondaryLabel
                                    .resolveFrom(context),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Expanded(
                              child: Text(
                                item.sender,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: item.isUnread
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: CupertinoColors.label
                                      .resolveFrom(context),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              item.time,
                              style: TextStyle(
                                fontSize: 13,
                                color: CupertinoColors.secondaryLabel
                                    .resolveFrom(context),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              CupertinoIcons.chevron_forward,
                              size: 13,
                              color: CupertinoColors.tertiaryLabel
                                  .resolveFrom(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),

                        // Subject Line
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.subject,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: item.isUnread
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: CupertinoColors.label
                                      .resolveFrom(context),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (item.hasAttachment) ...[
                              const SizedBox(width: 4),
                              Icon(
                                CupertinoIcons.paperclip,
                                size: 14,
                                color: CupertinoColors.secondaryLabel
                                    .resolveFrom(context),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),

                        // Snippet Line
                        Text(
                          item.snippet,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.25,
                            color: CupertinoColors.secondaryLabel
                                .resolveFrom(context),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Hairline separator indented past the avatar
            Padding(
              padding: EdgeInsets.only(left: showContactPhotos ? 68.0 : 32.0),
              child: Container(
                height: 0.5,
                color: CupertinoColors.separator.resolveFrom(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmailAvatar extends StatelessWidget {
  const _EmailAvatar({required this.item});
  final MailItem item;

  @override
  Widget build(BuildContext context) {
    if (item.avatarType == AvatarType.store) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: item.avatarColor,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: const Icon(
          CupertinoIcons.bag_fill,
          color: CupertinoColors.white,
          size: 22,
        ),
      );
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: kMailAvatarBg.resolveFrom(context),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        item.initials ?? '?',
        style: const TextStyle(
          color: CupertinoColors.white,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INBOX BOTTOM FLOATING UTILITY BAR
// ─────────────────────────────────────────────────────────────────────────────

class _InboxBottomBar extends StatelessWidget {
  const _InboxBottomBar({
    required this.bottomPad,
    required this.onOpenCompose,
  });

  final double bottomPad;
  final void Function(GlassMorphAnchor? anchor) onOpenCompose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        bottomPad > 32 ? bottomPad - 8 : 32,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Filter Circle Button (☰)
          GlassButton.custom(
            onTap: () {},
            width: 48,
            height: 48,
            settings: kMailSearchGlass(context),
            shape: const LiquidOval(),
            quality: GlassQuality.premium,
            useOwnLayer: true,
            child: Center(
              child: Icon(
                CupertinoIcons.line_horizontal_3_decrease,
                size: 20,
                color: CupertinoColors.label.resolveFrom(context),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Search Pill
          Expanded(
            child: GlassSearchBar(
              placeholder: 'Search',
              height: 48,
              settings: kMailSearchGlass(context),
              quality: GlassQuality.premium,
              useOwnLayer: true,
              showsCancelButton: true,
              onChanged: (_) {},
              onCancel: () {},
            ),
          ),
          const SizedBox(width: 8),

          // Compose Circle Button wrapped in GlassMorphTrigger
          GlassMorphTrigger(
            builder: (triggerContext, anchor) => GlassButton.custom(
              onTap: () => onOpenCompose(anchor),
              width: 48,
              height: 48,
              settings: kMailSearchGlass(context),
              shape: const LiquidOval(),
              quality: GlassQuality.premium,
              useOwnLayer: true,
              child: Center(
                child: Icon(
                  CupertinoIcons.square_pencil,
                  size: 22,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BATCH ACTIONS BOTTOM BAR (Selection Mode)
// ─────────────────────────────────────────────────────────────────────────────

class _BatchActionsBar extends StatelessWidget {
  const _BatchActionsBar({
    required this.selectedCount,
    required this.onMarkRead,
    required this.onDelete,
    required this.bottomPad,
  });

  final int selectedCount;
  final VoidCallback onMarkRead;
  final VoidCallback onDelete;
  final double bottomPad;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        bottomPad > 32 ? bottomPad - 8 : 32,
      ),
      child: GlassCard(
        useOwnLayer: true,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: const LiquidRoundedRectangle(borderRadius: 28),
        settings: kMailSearchGlass(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              onPressed: selectedCount > 0 ? onMarkRead : null,
              child: const Text('Mark', style: TextStyle(fontSize: 16)),
            ),
            Expanded(
              child: Center(
                child: Text(
                  selectedCount > 0
                      ? '$selectedCount Selected'
                      : 'Select Messages',
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              onPressed: selectedCount > 0 ? onDelete : null,
              child: const Text(
                'Trash',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.destructiveRed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

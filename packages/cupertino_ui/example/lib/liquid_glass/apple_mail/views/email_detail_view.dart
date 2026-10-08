import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../models/mail_models.dart';
import '../theme/mail_theme.dart';
import 'compose_email_sheet.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EMAIL DETAIL VIEW — matches real iOS 26 Mail
//
// Top bar:
//   Leading  — back chevron + message-count badge pill ("< 10")
//   Trailing — prev/next navigation arrows in one shared capsule (∧ ∨)
//
// Bottom bar:
//   Left  — [trash][archive][reply] triage group in one shared capsule
//   Right — compose circular button
// ─────────────────────────────────────────────────────────────────────────────

class EmailDetailView extends StatefulWidget {
  const EmailDetailView({
    super.key,
    required this.item,
    required this.onDelete,
    this.emailIndex = 0,
    this.allEmails,
    this.onNavigate,
  });

  final MailItem item;
  final VoidCallback onDelete;

  /// Position of this email in the list (0-based) — used for prev/next.
  final int emailIndex;

  /// Full email list so we can open prev/next in-place.
  final List<MailItem>? allEmails;

  /// Called with the new index when the user presses prev/next.
  final void Function(int newIndex)? onNavigate;

  @override
  State<EmailDetailView> createState() => _EmailDetailViewState();
}

class _EmailDetailViewState extends State<EmailDetailView> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.emailIndex;
  }

  MailItem get _current =>
      widget.allEmails != null ? widget.allEmails![_currentIndex] : widget.item;

  bool get _hasPrev => widget.allEmails != null && _currentIndex > 0;

  bool get _hasNext =>
      widget.allEmails != null &&
      _currentIndex < (widget.allEmails!.length - 1);

  void _goPrev() {
    if (!_hasPrev) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex--);
    widget.onNavigate?.call(_currentIndex);
  }

  void _goNext() {
    if (!_hasNext) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex++);
    widget.onNavigate?.call(_currentIndex);
  }

  void _openReplySheet(
    BuildContext context,
    String prefix,
    GlassMorphAnchor? anchor,
  ) {
    GlassModalSheet.show(
      context: context,
      morphFrom: anchor,
      initialState: GlassSheetState.full,
      builder: (sheetContext) => MailGlassScope(
        child: ComposeEmailSheet(
          initialRecipient: _current.sender,
          initialSubject: '$prefix: ${_current.subject}',
          onSend: (to, subject, body) {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    final botPad = MediaQuery.paddingOf(context).bottom;

    return GlassScaffold(
      background: ColoredBox(color: kMailBg.resolveFrom(context)),
      appBar: GlassAppBar.pinned(
        buttonSettings: kMailTriggerGlass(context),

        title: Text(
          _current.sender,
          style: TextStyle(
            color: CupertinoColors.label.resolveFrom(context),
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),

        // ── Trailing: prev/next navigation ∧ ∨ ─────────────────────────────
        // Two icons sharing one glass capsule — exactly as iOS Mail renders them.
        actions: [
          GlassBarItem.icon(
            id: 'detail_prev',
            icon: Icon(
              CupertinoIcons.chevron_up,
              size: 18,
              color: _hasPrev
                  ? CupertinoColors.label.resolveFrom(context)
                  : CupertinoColors.systemGrey.resolveFrom(context),
            ),
            enabled: _hasPrev,
            onTap: _goPrev,
          ),
          GlassBarItem.icon(
            id: 'detail_next',
            icon: Icon(
              CupertinoIcons.chevron_down,
              size: 18,
              color: _hasNext
                  ? CupertinoColors.label.resolveFrom(context)
                  : CupertinoColors.systemGrey.resolveFrom(context),
            ),
            enabled: _hasNext,
            onTap: _goNext,
          ),
        ],
      ),

      // ── Bottom triage bar ────────────────────────────────────────────────────
      bottomBar: _DetailBottomBar(
        bottomPad: botPad,
        onDelete: () {
          widget.onDelete();
          Navigator.of(context).pop();
        },
        onReply: (anchor) => _openReplySheet(context, 'Re', anchor),
        onCompose: (anchor) => _openReplySheet(context, 'Fwd', anchor),
      ),

      body: _EmailBody(item: _current, topPad: topPad),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMAIL BODY
// ─────────────────────────────────────────────────────────────────────────────

class _EmailBody extends StatelessWidget {
  const _EmailBody({required this.item, required this.topPad});

  final MailItem item;
  final double topPad;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        SizedBox(height: topPad + 44 + 12),

        // ── "1 Message  |  ✦ Summarise" row ─────────────────────────────────
        Row(
          children: [
            Text(
              '1 Message',
              style: TextStyle(
                fontSize: 13,
                color: kMailSecondaryLabel.resolveFrom(context),
              ),
            ),
            const Spacer(),
            const Icon(CupertinoIcons.sparkles, size: 14, color: kMailBlue),
            const SizedBox(width: 4),
            const Text(
              'Summarise',
              style: TextStyle(
                fontSize: 13,
                color: kMailBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
        Container(height: 0.33, color: const Color(0xFF38383A)),
        const SizedBox(height: 12),

        // ── Sender row ───────────────────────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.avatarColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: item.avatarType == AvatarType.store
                    ? Icon(CupertinoIcons.bag_fill,
                        color: item.avatarColor, size: 20)
                    : Text(
                        item.initials ?? '?',
                        style: TextStyle(
                          color: item.avatarColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 10),

            // Name + recipients
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.sender,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label.resolveFrom(context),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'To: carmen@degenaar.co... & 1 more',
                          style: TextStyle(
                            fontSize: 12,
                            color: kMailSecondaryLabel.resolveFrom(context),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        CupertinoIcons.chevron_right,
                        size: 10,
                        color: kMailSecondaryLabel.resolveFrom(context),
                      ),
                      if (item.hasAttachment) ...[
                        const SizedBox(width: 4),
                        Icon(
                          CupertinoIcons.paperclip,
                          size: 12,
                          color: kMailSecondaryLabel.resolveFrom(context),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Date
            Text(
              item.time,
              style: TextStyle(
                fontSize: 13,
                color: kMailSecondaryLabel.resolveFrom(context),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // ── Subject ──────────────────────────────────────────────────────────
        Text(
          item.subject,
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: CupertinoColors.label.resolveFrom(context),
            letterSpacing: -0.4,
          ),
        ),

        const SizedBox(height: 14),

        // ── Body ─────────────────────────────────────────────────────────────
        Text(
          item.body ?? item.snippet,
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),

        // ── Attachment card ──────────────────────────────────────────────────
        if (item.hasAttachment) ...[
          const SizedBox(height: 20),
          _AttachmentCard(),
        ],

        const SizedBox(height: 100),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ATTACHMENT CARD — matches the dark rounded card in the screenshot
// ─────────────────────────────────────────────────────────────────────────────

class _AttachmentCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2C2C2E), width: 0.5),
      ),
      child: Row(
        children: [
          // Doc icon
          Container(
            width: 44,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Icon(CupertinoIcons.doc_fill,
                  color: Color(0xFF636366), size: 22),
            ),
          ),
          const SizedBox(width: 12),

          // File name + size
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SecureWorks Group\nWarranty.docx',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: CupertinoColors.white,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '25 KB',
                  style: TextStyle(fontSize: 12, color: Color(0xFF636366)),
                ),
              ],
            ),
          ),

          // Share button (blue tinted glass circle)
          GlassButton.custom(
            onTap: () => HapticFeedback.selectionClick(),
            width: 36,
            height: 36,
            shape: const LiquidOval(),
            quality: GlassQuality.premium,
            useOwnLayer: true,
            child: const Icon(CupertinoIcons.share, size: 16, color: kMailBlue),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DETAIL BOTTOM BAR
//
//   [ trash | archive | reply ]   ·····   [ compose ○ ]
//   ← GlassButtonGroup shared →           ← separate →
// ─────────────────────────────────────────────────────────────────────────────

class _DetailBottomBar extends StatelessWidget {
  const _DetailBottomBar({
    required this.bottomPad,
    required this.onDelete,
    required this.onReply,
    required this.onCompose,
  });

  final double bottomPad;
  final VoidCallback onDelete;
  final void Function(GlassMorphAnchor? anchor) onReply;
  final void Function(GlassMorphAnchor? anchor) onCompose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        bottomPad > 32 ? bottomPad - 8 : 28,
      ),
      child: Row(
        children: [
          // Left: three-icon triage capsule
          GlassButtonGroup.icons(
            settings: kMailTriggerGlass(context),
            items: [
              GlassButtonGroupItem(
                icon: const Icon(CupertinoIcons.trash, size: 20),
                onTap: () {
                  HapticFeedback.selectionClick();
                  onDelete();
                },
              ),
              GlassButtonGroupItem(
                icon: const Icon(CupertinoIcons.folder, size: 20),
                onTap: () => HapticFeedback.selectionClick(),
              ),
              GlassButtonGroupItem(
                icon: const Icon(CupertinoIcons.reply, size: 20),
                onTap: () => onReply(null),
              ),
            ],
          ),

          const Spacer(),

          // Right: compose circle
          GlassMorphTrigger(
            builder: (ctx, anchor) => GlassButton.custom(
              onTap: () => onCompose(anchor),
              width: 44,
              height: 44,
              settings: kMailTriggerGlass(context),
              shape: const LiquidOval(),
              quality: GlassQuality.premium,
              useOwnLayer: true,
              child: Center(
                child: Icon(
                  CupertinoIcons.square_pencil,
                  size: 20,
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

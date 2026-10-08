import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../theme/mail_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// COMPOSE EMAIL SHEET (Liquid Morph-To-Full & Prominent tintColor Action)
// ─────────────────────────────────────────────────────────────────────────────

class ComposeEmailSheet extends StatefulWidget {
  const ComposeEmailSheet({
    super.key,
    required this.onSend,
    this.initialRecipient,
    this.initialSubject,
    this.title = 'New Message',
    this.fromAddress = 'sebastian@degenaar.com.au',
  });

  final void Function(String to, String subject, String body) onSend;
  final String? initialRecipient;
  final String? initialSubject;
  final String title;
  final String fromAddress;

  @override
  State<ComposeEmailSheet> createState() => _ComposeEmailSheetState();
}

class _ComposeEmailSheetState extends State<ComposeEmailSheet> {
  late final TextEditingController _toController;
  late final TextEditingController _subjectController;
  final TextEditingController _bodyController =
      TextEditingController(text: 'Sent from my iPhone');

  // ValueNotifier instead of setState so that only the send-button
  // ValueListenableBuilder rebuilds on each keystroke. This keeps the
  // X button's GlassButton glass layer completely stable, which prevents
  // the "glass platter disappears while typing" regression.
  final ValueNotifier<bool> _canSendNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _toController = TextEditingController(text: widget.initialRecipient ?? '');
    _subjectController =
        TextEditingController(text: widget.initialSubject ?? '');
    _toController.addListener(_validate);
    _subjectController.addListener(_validate);
    _validate();
  }

  void _validate() {
    _canSendNotifier.value = _toController.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _toController.removeListener(_validate);
    _subjectController.removeListener(_validate);
    _toController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    _canSendNotifier.dispose();
    super.dispose();
  }

  bool get _hasDraftContent {
    final hasTo = _toController.text.trim().isNotEmpty;
    final hasSubject = _subjectController.text.trim().isNotEmpty;
    final body = _bodyController.text.trim();
    final hasBody = body.isNotEmpty && body != 'Sent from my iPhone';
    return hasTo || hasSubject || hasBody;
  }

  Future<void> _attemptClose() async {
    if (_hasDraftContent) {
      final shouldDismiss = await showCupertinoModalPopup<bool>(
        context: context,
        builder: (popupContext) => CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(popupContext).pop(true),
              child: const Text('Delete Draft'),
            ),
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(popupContext).pop(true),
              child: const Text('Save Draft'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(popupContext).pop(false),
            child: const Text('Cancel'),
          ),
        ),
      );

      if (shouldDismiss == true && mounted) {
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  void _send() {
    if (!_canSendNotifier.value) return;
    HapticFeedback.mediumImpact();
    widget.onSend(
      _toController.text.trim(),
      _subjectController.text.trim(),
      _bodyController.text.trim(),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    // NOTE: MediaQuery.viewInsetsOf is intentionally NOT read here.
    // It is read inside a nested Builder below so that keyboard open/close
    // does NOT rebuild the top-bar GlassButton widgets (which drops their
    // useOwnLayer glass platters). The top-bar row is therefore completely
    // stable during typing and keyboard animation.

    return Container(
      color:
          isDark ? const Color(0xFF1C1C1E) : CupertinoColors.systemBackground,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sheet Grabber Handle
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF5A5A5E)
                      : const Color(0xFFC7C7CC),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            const SizedBox(height: 6),

            // ── Top Bar ──────────────────────────────────────────────────────
            // This Padding row is outside the Builder so it NEVER rebuilds
            // from keyboard events or from typing (see _validate / ValueNotifier).
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dismiss (X) Circular Button
                  GlassButton.custom(
                    onTap: _attemptClose,
                    width: 44,
                    height: 44,
                    useOwnLayer: true,
                    quality: GlassQuality.premium,
                    shape: const LiquidOval(),
                    settings: kMailTriggerGlass(context),
                    child: Center(
                      child: Icon(
                        CupertinoIcons.xmark,
                        size: 18,
                        color: isDark
                            ? CupertinoColors.white
                            : CupertinoColors.black,
                      ),
                    ),
                  ),

                  // Send (↑) Circular Button
                  // ValueListenableBuilder ensures ONLY this widget rebuilds
                  // when canSend toggles — the X button is left completely
                  // undisturbed, keeping its glass layer stable.
                  ValueListenableBuilder<bool>(
                    valueListenable: _canSendNotifier,
                    builder: (ctx, canSend, _) {
                      final triggerSettings = kMailTriggerGlass(ctx);
                      return GlassButton.custom(
                        onTap: () {
                          if (canSend) _send();
                        },
                        width: 44,
                        height: 44,
                        useOwnLayer: true,
                        quality: GlassQuality.premium,
                        shape: const LiquidOval(),
                        settings: canSend
                            ? triggerSettings.copyWith(
                                glassColor: kMailBlue,
                                bodyMode: GlassBodyMode.clear,
                              )
                            : triggerSettings,
                        child: Center(
                          child: Icon(
                            CupertinoIcons.arrow_up,
                            size: 18,
                            color: canSend
                                ? CupertinoColors.white
                                : (isDark
                                    ? const Color(0xFF636366)
                                    : const Color(0xFF8E8E93)),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Large Title: "New Message"
            Padding(
              padding:
                  const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 8),
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.4,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
            ),

            // ── Compose Body ─────────────────────────────────────────────────
            // Builder isolates MediaQuery.viewInsetsOf so the keyboard sliding
            // up/down only rebuilds this subtree, never the top-bar buttons.
            Expanded(
              child: Builder(
                builder: (bCtx) {
                  final mqPadding = MediaQuery.paddingOf(bCtx);
                  final bottomInset = MediaQuery.viewInsetsOf(bCtx).bottom;
                  final sheetInfo = GlassModalSheetStateProvider.of(bCtx);

                  // When presented inside a GlassModalSheet in full state, the sheet's
                  // bottom edge is submerged past the bottom of the screen by
                  // `extraHeight` (bottom safe area + adaptive corner radius) so its
                  // bottom rounded corners sink offscreen to give a flat full-sheet look.
                  // We compensate for this submerged offset so that the toolbar and
                  // scrolling content sit cleanly above the keyboard or home indicator.
                  final submergedOffset = sheetInfo?.submergedBottom ?? 0.0;
                  final hasKeyboard = bottomInset > 0;
                  final floorFromScreenBottom =
                      math.max(bottomInset, mqPadding.bottom);
                  final effectiveBottomPadding =
                      floorFromScreenBottom + submergedOffset;

                  return Padding(
                    padding: EdgeInsets.only(bottom: effectiveBottomPadding),
                    child: Stack(
                      children: [
                        ListView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 60),
                          children: [
                            // To Field
                            _ComposeFieldRow(
                              label: 'To: ',
                              child: CupertinoTextField(
                                controller: _toController,
                                cursorColor: kMailBlue,
                                placeholderStyle: const TextStyle(
                                  color: Color(0xFF636366),
                                  fontSize: 16,
                                ),
                                style: const TextStyle(
                                  color: kMailBlue,
                                  fontSize: 16,
                                ),
                                decoration: null,
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                            Container(
                              height: 0.5,
                              color: isDark
                                  ? const Color(0xFF38383A)
                                  : const Color(0xFFE5E5EA),
                            ),

                            // Cc/Bcc/From
                            _ComposeFieldRow(
                              label: '',
                              child: Text(
                                'Cc/Bcc, From: ${widget.fromAddress}',
                                style: TextStyle(
                                  color: kMailSecondaryLabel.resolveFrom(bCtx),
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Container(
                              height: 0.5,
                              color: isDark
                                  ? const Color(0xFF38383A)
                                  : const Color(0xFFE5E5EA),
                            ),

                            // Subject Field
                            _ComposeFieldRow(
                              label: 'Subject: ',
                              child: CupertinoTextField(
                                controller: _subjectController,
                                cursorColor: kMailBlue,
                                placeholderStyle: const TextStyle(
                                  color: Color(0xFF636366),
                                  fontSize: 16,
                                ),
                                style: TextStyle(
                                  color:
                                      CupertinoColors.label.resolveFrom(bCtx),
                                  fontSize: 16,
                                ),
                                decoration: null,
                              ),
                            ),
                            Container(
                              height: 0.5,
                              color: isDark
                                  ? const Color(0xFF38383A)
                                  : const Color(0xFFE5E5EA),
                            ),
                            const SizedBox(height: 12),

                            // Message Body Field
                            CupertinoTextField(
                              controller: _bodyController,
                              cursorColor: kMailBlue,
                              placeholderStyle: const TextStyle(
                                color: Color(0xFF636366),
                                fontSize: 16,
                              ),
                              style: TextStyle(
                                color: CupertinoColors.label.resolveFrom(bCtx),
                                fontSize: 16,
                              ),
                              maxLines: 14,
                              minLines: 8,
                              decoration: null,
                            ),
                          ],
                        ),

                        // Floating Keyboard / Formatting Toolbar
                        // Only visible when the keyboard is active, smoothly fading in/out
                        Positioned(
                          right: 16,
                          bottom: 12,
                          child: AnimatedOpacity(
                            opacity: hasKeyboard ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOut,
                            child: IgnorePointer(
                              ignoring: !hasKeyboard,
                              child: const _ComposeKeyboardToolbar(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComposeKeyboardToolbar extends StatelessWidget {
  const _ComposeKeyboardToolbar();

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? CupertinoColors.white : CupertinoColors.black;

    return GlassButtonGroup.icons(
      useOwnLayer: true,
      quality: GlassQuality.premium,
      borderRadius: 22.0,
      settings: kMailSearchGlass(context),
      iconSize: 19.0,
      itemPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      items: [
        GlassButtonGroupItem(
          label: 'Format text',
          icon: Text(
            'Aa',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: iconColor,
            ),
          ),
          onTap: () => HapticFeedback.selectionClick(),
        ),
        GlassButtonGroupItem(
          label: 'Writing tools',
          icon: Icon(CupertinoIcons.sparkles, size: 19, color: iconColor),
          onTap: () => HapticFeedback.selectionClick(),
        ),
        GlassButtonGroupItem(
          label: 'Attach file',
          icon: Icon(CupertinoIcons.paperclip, size: 19, color: iconColor),
          onTap: () => HapticFeedback.selectionClick(),
        ),
        GlassButtonGroupItem(
          label: 'Drawing',
          icon: Icon(CupertinoIcons.pencil_outline, size: 19, color: iconColor),
          onTap: () => HapticFeedback.selectionClick(),
        ),
      ],
    );
  }
}

class _ComposeFieldRow extends StatelessWidget {
  const _ComposeFieldRow({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (label.isNotEmpty)
            Text(
              label,
              style: TextStyle(
                color: kMailSecondaryLabel.resolveFrom(context),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

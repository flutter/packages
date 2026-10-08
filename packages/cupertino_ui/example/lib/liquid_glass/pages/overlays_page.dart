import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:liquid_glass_widgets_example/constants/glass_settings.dart';

class OverlaysPage extends StatefulWidget {
  const OverlaysPage({super.key});

  @override
  State<OverlaysPage> createState() => _OverlaysPageState();
}

class _OverlaysPageState extends State<OverlaysPage> {
  String _lastMenuSelection = 'None';

  // ── Sheet methods ──────────────────────────────────────────────────────

  void _showBasicSheet() {
    GlassSheet.show(
      context: context,
      settings: RecommendedGlassSettings.sheet,
      builder: (context) => Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.checkmark_circle_fill,
                color: CupertinoColors.activeGreen, size: 64),
            SizedBox(height: 16),
            Text('Success!',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.label.resolveFrom(context))),
            SizedBox(height: 8),
            Text(
              'This is a basic glass bottom sheet',
              style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.label
                      .resolveFrom(context)
                      .withValues(alpha: 0.7)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            _SheetButton(label: 'Dismiss', onTap: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  void _showScrollableSheet() {
    // The sheet itself is the glass surface. Content rows inside it are plain
    // styled Containers — glass belongs in navigation chrome, not list items.
    const hues = [
      Color(0xFF3D5AFE),
      Color(0xFF00BFA5),
      Color(0xFFFF6D00),
      Color(0xFFD500F9),
      Color(0xFFFFD600),
    ];
    GlassSheet.show(
      context: context,
      settings: RecommendedGlassSettings.sheet,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Scrollable Content',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.label.resolveFrom(context)),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: 15,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final hue = hues[index % hues.length];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        colors: [
                          hue.withValues(alpha: 0.45),
                          hue.withValues(alpha: 0.15),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: hue.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text('${index + 1}',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: CupertinoColors.label
                                        .resolveFrom(context))),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text('Item ${index + 1}',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.label
                                    .resolveFrom(context))),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: _SheetButton(
                  label: 'Close', onTap: () => Navigator.pop(context)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Dialog methods ─────────────────────────────────────────────────────

  void _showBasicDialog() {
    GlassDialog.show(
      context: context,
      title: 'Success',
      message: 'Your changes have been saved successfully.',
      actions: [
        GlassDialogAction(
          label: 'OK',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  void _showDestructiveDialog() {
    GlassDialog.show(
      context: context,
      title: 'Delete Item?',
      message: 'This action cannot be undone.',
      actions: [
        GlassDialogAction(
          label: 'Cancel',
          onPressed: () => Navigator.pop(context),
        ),
        GlassDialogAction(
          label: 'Delete',
          isDestructive: true,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  void _showSaveDialog() {
    GlassDialog.show(
      context: context,
      title: 'Save Changes?',
      message: 'You have unsaved changes. What would you like to do?',
      actions: [
        GlassDialogAction(
          label: 'Don\'t Save',
          onPressed: () => Navigator.pop(context),
        ),
        GlassDialogAction(
          label: 'Cancel',
          onPressed: () => Navigator.pop(context),
        ),
        GlassDialogAction(
          label: 'Save',
          isPrimary: true,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  // ── Action Sheet methods ───────────────────────────────────────────────

  void _showPhotoActionSheet() {
    showGlassActionSheet(
      context: context,
      title: 'Photo Options',
      actions: [
        GlassActionSheetAction(
          label: 'Save to Photos',
          icon: Icon(CupertinoIcons.photo),
          onPressed: () {},
        ),
        GlassActionSheetAction(
          label: 'Share',
          icon: Icon(CupertinoIcons.share),
          onPressed: () {},
        ),
        GlassActionSheetAction(
          label: 'Copy',
          icon: Icon(CupertinoIcons.doc_on_doc),
          onPressed: () {},
        ),
        GlassActionSheetAction(
          label: 'Delete',
          icon: Icon(CupertinoIcons.trash),
          style: GlassActionSheetStyle.destructive,
          onPressed: () {},
        ),
      ],
    );
  }

  // ── Modal Sheet methods ────────────────────────────────────────────

  void _showModalSheet() {
    GlassModalSheet.show(
      context: context,
      settings: RecommendedGlassSettings.sheet,
      builder: (context) => Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(height: 16),
            Text(
              'Modal Sheet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.label.resolveFrom(context),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Drag up for full, down to dismiss. '
              'Multi-state: peek → half → full.',
              style: TextStyle(
                fontSize: 15,
                color: CupertinoColors.label
                    .resolveFrom(context)
                    .withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            GlassButton.custom(
              onTap: () => Navigator.pop(context),
              width: double.infinity,
              height: 48,
              useOwnLayer: true,
              settings: RecommendedGlassSettings.overlay,
              shape: const LiquidRoundedSuperellipse(borderRadius: 12),
              child: Text(
                'Dismiss',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      background: const ShowcaseBackground(),
      settings: RecommendedGlassSettings.standard,
      statusBarStyle: CupertinoTheme.of(context).brightness == Brightness.dark
          ? GlassStatusBarStyle.light
          : GlassStatusBarStyle.dark,
      child: GlassScaffold(
        appBar: const GlassAppBar.pinned(),
        body: GlassScrollEdgeEffect(
          topFadeHeight: MediaQuery.paddingOf(context).top + 44 + 40,
          fadeBottom: false,
          child: CustomScrollView(
            slivers: [
              // Space for the app bar + safe area
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.paddingOf(context).top + 44,
                ),
              ),
              // ── Large page title (iOS 26 inline style) ──────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Text(
                    'Overlays',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: CupertinoColors.label.resolveFrom(context),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── GlassSheet ───────────────────────────────────
                      const _SectionTitle(title: 'GlassSheet'),
                      SizedBox(height: 16),
                      _ActionButton(
                        label: 'Basic Bottom Sheet',
                        glowColor: CupertinoColors.activeBlue,
                        onTap: _showBasicSheet,
                      ),
                      SizedBox(height: 12),
                      _ActionButton(
                        label: 'Scrollable Content',
                        glowColor: CupertinoColors.activeGreen,
                        onTap: _showScrollableSheet,
                      ),

                      SizedBox(height: 40),

                      // ── GlassDialog ──────────────────────────────────
                      const _SectionTitle(title: 'GlassDialog'),
                      SizedBox(height: 16),
                      _ActionButton(
                        label: 'Basic Alert',
                        glowColor: CupertinoColors.activeGreen,
                        onTap: _showBasicDialog,
                      ),
                      SizedBox(height: 12),
                      _ActionButton(
                        label: 'Destructive Confirm',
                        glowColor: CupertinoColors.systemRed,
                        onTap: _showDestructiveDialog,
                      ),
                      SizedBox(height: 12),
                      _ActionButton(
                        label: 'Save Changes (3 Actions)',
                        glowColor: CupertinoColors.activeOrange,
                        onTap: _showSaveDialog,
                      ),

                      SizedBox(height: 40),

                      // ── GlassMenu ────────────────────────────────────
                      const _SectionTitle(title: 'GlassMenu'),
                      SizedBox(height: 4),
                      _QualityLabel(label: 'Premium vs Standard'),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              _QualityBadge(
                                  label: 'Premium',
                                  color: CupertinoColors.activeOrange),
                              SizedBox(height: 8),
                              GlassMenu(
                                quality: GlassQuality.premium,
                                triggerBuilder: (context, toggle) =>
                                    GlassButton(
                                  icon: Icon(CupertinoIcons.ellipsis),
                                  onTap: toggle,
                                  label: 'Premium',
                                ),
                                items: [
                                  GlassMenuItem(
                                    icon: Icon(CupertinoIcons.share),
                                    title: 'Share',
                                    onTap: () => setState(
                                        () => _lastMenuSelection = 'Share'),
                                  ),
                                  GlassMenuItem(
                                    icon: Icon(CupertinoIcons.pen),
                                    title: 'Edit',
                                    onTap: () => setState(
                                        () => _lastMenuSelection = 'Edit'),
                                  ),
                                  GlassMenuItem(
                                    icon: Icon(CupertinoIcons.trash),
                                    title: 'Delete',
                                    isDestructive: true,
                                    onTap: () => setState(
                                        () => _lastMenuSelection = 'Delete'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              _QualityBadge(
                                  label: 'Standard',
                                  color: CupertinoColors.white
                                      .withValues(alpha: 0.38)),
                              SizedBox(height: 8),
                              GlassMenu(
                                quality: GlassQuality.standard,
                                triggerBuilder: (context, toggle) =>
                                    GlassButton(
                                  icon: Icon(CupertinoIcons.ellipsis),
                                  onTap: toggle,
                                  label: 'Standard',
                                ),
                                items: [
                                  GlassMenuItem(
                                    icon: Icon(CupertinoIcons.share),
                                    title: 'Share',
                                    onTap: () => setState(
                                        () => _lastMenuSelection = 'Share'),
                                  ),
                                  GlassMenuItem(
                                    icon: Icon(CupertinoIcons.pen),
                                    title: 'Edit',
                                    onTap: () => setState(
                                        () => _lastMenuSelection = 'Edit'),
                                  ),
                                  GlassMenuItem(
                                    icon: Icon(CupertinoIcons.trash),
                                    title: 'Delete',
                                    isDestructive: true,
                                    onTap: () => setState(
                                        () => _lastMenuSelection = 'Delete'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      _ResultRow(
                        icon: CupertinoIcons.info_circle_fill,
                        label: 'Selection: $_lastMenuSelection',
                      ),

                      SizedBox(height: 40),

                      // ── GlassPopover ──────────────────────────────────
                      const _SectionTitle(title: 'GlassPopover'),
                      SizedBox(height: 4),
                      _QualityLabel(label: 'Premium vs Standard'),
                      SizedBox(height: 16),

                      // ── Quality comparison row ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // ── Premium quality ──
                          Column(
                            children: [
                              _QualityBadge(
                                  label: 'Premium',
                                  color: CupertinoColors.activeOrange),
                              SizedBox(height: 8),
                              GlassPopover(
                                quality: GlassQuality.premium,
                                popoverWidth: 220,
                                popoverHeight: 160,
                                triggerBuilder: (context, toggle) =>
                                    GlassButton(
                                  icon: Icon(CupertinoIcons.sparkles),
                                  onTap: toggle,
                                  label: 'Premium',
                                  quality: GlassQuality.premium,
                                  useOwnLayer: true,
                                ),
                                contentBuilder: (context, close) => Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            CupertinoIcons.sparkles,
                                            color: CupertinoColors.activeOrange,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Liquid Glass',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600,
                                              color: CupertinoColors.label
                                                  .resolveFrom(context),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'Premium quality with full '
                                        'metaball morph blending '
                                        'between trigger and popover.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: CupertinoColors.white
                                              .withValues(alpha: 0.7),
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // ── Standard quality ──
                          Column(
                            children: [
                              _QualityBadge(
                                  label: 'Standard',
                                  color: CupertinoColors.white
                                      .withValues(alpha: 0.38)),
                              SizedBox(height: 8),
                              GlassPopover(
                                quality: GlassQuality.standard,
                                popoverWidth: 220,
                                popoverHeight: 160,
                                triggerBuilder: (context, toggle) =>
                                    GlassButton(
                                  icon: Icon(CupertinoIcons.info_circle),
                                  onTap: toggle,
                                  label: 'Standard',
                                  quality: GlassQuality.standard,
                                  useOwnLayer: true,
                                ),
                                contentBuilder: (context, close) => Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            CupertinoIcons.info_circle,
                                            color: CupertinoColors
                                                .secondaryLabel
                                                .resolveFrom(context),
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Backdrop Filter',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600,
                                              color: CupertinoColors.label
                                                  .resolveFrom(context),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'Standard quality uses backdrop '
                                        'filter — lighter on GPU but '
                                        'without metaball blending.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: CupertinoColors.white
                                              .withValues(alpha: 0.7),
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 24),

                      // ── Self-close use case ──
                      Text(
                        'Custom content with close callback',
                        style: TextStyle(
                          fontSize: 13,
                          color: CupertinoColors.label
                              .resolveFrom(context)
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      SizedBox(height: 12),
                      Center(
                        child: GlassPopover(
                          quality: GlassQuality.premium,
                          barrierDismissible:
                              false, // Testing the non-dismissible gap
                          popoverWidth: 220,
                          // popoverHeight removed to test auto-height measurement gap
                          triggerBuilder: (context, toggle) => GlassButton(
                            icon: Icon(CupertinoIcons.person_circle),
                            onTap: toggle,
                            label: 'Profile',
                            quality: GlassQuality.premium,
                            useOwnLayer: true,
                          ),
                          contentBuilder: (context, close) => Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        CupertinoColors.systemPurple
                                            .withValues(alpha: 0.8),
                                        CupertinoColors.activeBlue,
                                      ],
                                    ),
                                  ),
                                  child: Icon(
                                    CupertinoIcons.person_fill,
                                    color: CupertinoColors.label
                                        .resolveFrom(context),
                                    size: 28,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Jane Doe',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: CupertinoColors.label
                                        .resolveFrom(context),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Flutter Developer',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: CupertinoColors.label
                                        .resolveFrom(context)
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                SizedBox(height: 16),
                                GlassButton.custom(
                                  onTap: close,
                                  width: 120,
                                  height: 36,
                                  shape: const LiquidRoundedSuperellipse(
                                      borderRadius: 18),
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.white
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Text(
                                      'Done',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: CupertinoColors.label
                                            .resolveFrom(context),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 40),

                      // ── GlassActionSheet ─────────────────────────────
                      const _SectionTitle(title: 'GlassActionSheet'),
                      SizedBox(height: 16),
                      _ActionButton(
                        label: 'Photo Options',
                        glowColor: CupertinoColors.systemPurple,
                        onTap: _showPhotoActionSheet,
                      ),

                      SizedBox(height: 40),

                      // ── GlassModalSheet ────────────────────────────
                      const _SectionTitle(title: 'GlassModalSheet'),
                      SizedBox(height: 16),
                      _ActionButton(
                        label: 'Multi-State Modal Sheet',
                        glowColor: Colors.teal,
                        onTap: _showModalSheet,
                      ),

                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Helper Widgets
// =============================================================================

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: CupertinoColors.label.resolveFrom(context),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.glowColor,
    required this.onTap,
  });
  final String label;
  final Color glowColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassButton.custom(
      onTap: onTap,
      width: double.infinity,
      height: 48,
      shape: const LiquidRoundedSuperellipse(borderRadius: 12),
      glowColor: glowColor.withValues(alpha: 0.3),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.label.resolveFrom(context),
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassButton.custom(
      onTap: onTap,
      width: double.infinity,
      height: 48,
      useOwnLayer: true,
      settings: RecommendedGlassSettings.overlay,
      shape: const LiquidRoundedSuperellipse(borderRadius: 12),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.label.resolveFrom(context),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: CupertinoColors.activeBlue, size: 20),
        SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: CupertinoColors.label
                .resolveFrom(context)
                .withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class _QualityLabel extends StatelessWidget {
  const _QualityLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        color:
            CupertinoColors.label.resolveFrom(context).withValues(alpha: 0.5),
      ),
    );
  }
}

class _QualityBadge extends StatelessWidget {
  const _QualityBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

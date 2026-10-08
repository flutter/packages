import 'package:flutter/cupertino.dart';

import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Developer Regression Reference — GlassScaffold + GlassMenu (0.14.x)
///
/// Kept as an internal developer reference to document investigated regressions
/// and their resolutions. Not linked from the main example app.
///
/// **Issue 1 — GlassScaffold black background (FIXED in 0.14.x)**
/// When no `background:` widget is supplied, the inner Scaffold was forced to
/// `const Color(0x00000000)`, rendering black instead of `Theme.scaffoldBackgroundColor`.
/// Fixed by: adding `backgroundColor: Color?` param and only forcing transparent
/// when `background != null`.
///
/// **Issue 2 — GlassMenu "bleed-through" (NOT a regression — expected behaviour)**
/// User reported GlassButtons visible through expanded GlassMenu in 0.14.x but not
/// in 0.13.x. Root cause of the perception: the 0.14.0 `BackdropGroup` isolation
/// change. In 0.13.x all glass layers shared a single `BackdropGroup` (via
/// `GlassBackdropScope`), so the menu's backdrop was sampled BEFORE page glass
/// elements were composited — making them invisible through the glass. In 0.14.x
/// each `LiquidGlassLayer` gets its own isolated `BackdropGroup`, so the menu
/// correctly captures the fully-composited page (including glass buttons) as its
/// backdrop. Content is then shown through the glass as a frosted/blurred image —
/// which IS the correct iOS 26 glass frost effect. The additional aggravating
/// factor was Issue 1 (black background), which made the frosted glass appear
/// much more transparent than intended (dark glass on black = nearly invisible
/// surface). Fixing Issue 1 resolved the perceived severity of this report.
/// GlassMenu and GlassPopover are architecturally identical — no fix was missed.
class ScaffoldMenuRegressionDemo extends StatelessWidget {
  const ScaffoldMenuRegressionDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      background: _buildBackground(),
      statusBarStyle: GlassStatusBarStyle.light,
      child: GlassScaffold(
        appBar: GlassAppBar(
          leading: GlassButton(
            icon: Icon(CupertinoIcons.back),
            onTap: () => Navigator.of(context).pop(),
            width: 40,
            height: 40,
            iconSize: 20,
          ),
        ),
        body: ListView(
          padding: EdgeInsets.only(
            top: MediaQuery.paddingOf(context).top + 60,
            left: 20,
            right: 20,
            bottom: 40,
          ),
          children: const [
            // ── Title ────────────────────────────────────────────────
            Text(
              'Regression Reference',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: CupertinoColors.white,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'GlassScaffold + GlassMenu — 0.14.x investigations',
              style: TextStyle(
                fontSize: 15,
                color: Color(0x99FFFFFF),
              ),
            ),
            SizedBox(height: 32),

            // ── Bug 1: GlassScaffold background ──────────────────────
            _BugSection(
              number: '1',
              title: 'GlassScaffold — backgroundColor (FIXED)',
              description:
                  'GlassScaffold with no background: was hardcoded transparent, '
                  'rendering black. Now fixed: use backgroundColor: param '
                  'or omit for Theme.scaffoldBackgroundColor.',
            ),
            SizedBox(height: 16),
            _ScaffoldBugDemo(),

            SizedBox(height: 40),

            // ── Bug 2: GlassMenu in GlassScaffold ────────────────────
            _BugSection(
              number: '2',
              title: 'GlassMenu — "bleed-through" (NOT a regression)',
              description:
                  'User reported buttons visible through expanded GlassMenu '
                  'in 0.14.x but not 0.13.x. Root cause: the 0.14.0 '
                  'BackdropGroup isolation change. In 0.13.x all glass layers '
                  'shared one BackdropGroup, so the menu sampled the scene '
                  'BEFORE glass buttons were painted — making them invisible. '
                  'In 0.14.x each LiquidGlassLayer has its own BackdropGroup '
                  'and captures the fully-composited page. Buttons appear '
                  'frosted through the glass — which is correct iOS 26 '
                  'behaviour. The black background (Issue 1) made it look '
                  'far worse than it actually was.',
            ),
            SizedBox(height: 16),
            _MenuInScaffoldDemo(),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Bug 1 — GlassScaffold background (FIXED)
// =============================================================================

class _ScaffoldBugDemo extends StatelessWidget {
  const _ScaffoldBugDemo();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassButton.custom(
          onTap: () => Navigator.of(context).push(
            CupertinoPageRoute<void>(
              builder: (_) => const _GlassScaffoldBugPage(),
            ),
          ),
          width: double.infinity,
          height: 48,
          shape: LiquidRoundedSuperellipse(borderRadius: 12),
          glowColor: CupertinoColors.activeGreen.withValues(alpha: 0.3),
          child: Text(
            'Open GlassScaffold page (backgroundColor: fixed ✓)',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.white,
            ),
          ),
        ),
        SizedBox(height: 8),
        _InfoLabel(
          text: 'backgroundColor: Color(0xFF020715) — deep navy via new param.',
        ),
      ],
    );
  }
}

/// Full-screen GlassScaffold using the new backgroundColor parameter.
class _GlassScaffoldBugPage extends StatelessWidget {
  const _GlassScaffoldBugPage();

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      backgroundColor: const Color(0xFF020715),
      appBar: GlassAppBar(
        leading: GlassButton(
          icon: Icon(CupertinoIcons.back),
          onTap: () => Navigator.of(context).pop(),
          width: 40,
          height: 40,
          iconSize: 20,
        ),
        title: Text(
          'GlassScaffold — backgroundColor:',
          style: TextStyle(
              color: CupertinoColors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.checkmark_seal_fill,
                color: CupertinoColors.activeGreen, size: 48),
            SizedBox(height: 16),
            Text(
              'FIXED ✓',
              style: TextStyle(
                color: CupertinoColors.activeGreen,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Deep navy (#020715) via backgroundColor: param.',
              style: TextStyle(
                color: CupertinoColors.white.withValues(alpha: 0.6),
                fontSize: 14,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Bug 2 — GlassMenu inside GlassScaffold (no background:)
// =============================================================================

class _MenuInScaffoldDemo extends StatelessWidget {
  const _MenuInScaffoldDemo();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassButton.custom(
          onTap: () => Navigator.of(context).push(
            CupertinoPageRoute<void>(
              builder: (_) => const _GlassMenuInScaffoldPage(),
            ),
          ),
          width: double.infinity,
          height: 48,
          shape: LiquidRoundedSuperellipse(borderRadius: 12),
          glowColor: CupertinoColors.activeOrange.withValues(alpha: 0.3),
          child: Text(
            'Open GlassScaffold + GlassMenu test page',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.white,
            ),
          ),
        ),
        SizedBox(height: 8),
        _InfoLabel(
          text:
              'CONCLUSION: Not a regression. The glass frost effect correctly '
              'shows the composited page through the menu surface (0.14.x '
              'BackdropGroup isolation). The black background from Issue 1 '
              'amplified the perceived severity. Open the test page, expand '
              'both menus, and observe the frosted glass is working correctly.',
        ),
      ],
    );
  }
}

/// GlassScaffold page with a GlassMenu and GlassButtons — tests whether
/// the transparent Scaffold compositing causes GlassMenu bleed-through.
class _GlassMenuInScaffoldPage extends StatelessWidget {
  const _GlassMenuInScaffoldPage();

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      // No backgroundColor: — inherits Theme.scaffoldBackgroundColor.
      // This page intentionally omits background: to reproduce the user's
      // exact setup. Issue 1 fix means this is no longer black (uses theme
      // colour). The menus below test whether glass buttons bleed through
      // the overlay — conclusion: they don't "bleed through", they appear
      // correctly frosted. The menu's LiquidGlassLayer captures the fully-
      // composited page (including glass buttons) via its own BackdropGroup.
      // This is correct 0.14.x behaviour, not a regression.
      appBar: GlassAppBar(
        leading: GlassButton(
          icon: Icon(CupertinoIcons.back),
          onTap: () => Navigator.of(context).pop(),
          width: 40,
          height: 40,
          iconSize: 20,
        ),
        title: Text(
          'GlassMenu + GlassScaffold',
          style: TextStyle(
              color: CupertinoColors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          GlassMenu(
            menuWidth: 220,
            autoAdjustToScreen: true,
            triggerBuilder: (context, toggle) => GlassButton(
              icon: Icon(CupertinoIcons.ellipsis_circle),
              onTap: toggle,
              width: 40,
              height: 40,
              iconSize: 20,
            ),
            items: [
              GlassMenuItem(
                icon: Icon(CupertinoIcons.share),
                title: 'Share',
                onTap: () {},
              ),
              GlassMenuItem(
                icon: Icon(CupertinoIcons.pencil),
                title: 'Edit',
                onTap: () {},
              ),
              GlassMenuItem(
                icon: Icon(CupertinoIcons.trash),
                title: 'Delete',
                isDestructive: true,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Text(
            'Menu A — app bar (GlassIsolationScope).\n'
            'Menu B — body (no isolation scope).\n'
            'Open both menus and observe: GlassButtons show through the '
            'glass as a frosted/blurred image — this IS correct iOS 26 '
            'glass behaviour, not a bleed-through regression.\n'
            'The 0.13.x behaviour (buttons invisible) was a side-effect of '
            'the old shared BackdropGroup architecture.',
            style: TextStyle(
              color: CupertinoColors.white.withValues(alpha: 0.70),
              fontSize: 14,
              height: 1.6,
            ),
          ),
          SizedBox(height: 16),
          // ── Menu B — body-level, NO GlassIsolationScope ──────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  'Menu B (body — no isolation):',
                  style: TextStyle(color: Color(0x99FFFFFF), fontSize: 13),
                ),
              ),
              GlassMenu(
                menuWidth: 220,
                autoAdjustToScreen: true,
                triggerBuilder: (context, toggle) => GlassButton(
                  icon: Icon(CupertinoIcons.ellipsis_circle_fill),
                  label: 'Open Menu B',
                  onTap: toggle,
                ),
                items: [
                  GlassMenuItem(
                    icon: Icon(CupertinoIcons.share),
                    title: 'Share',
                    onTap: () {},
                  ),
                  GlassMenuItem(
                    icon: Icon(CupertinoIcons.pencil),
                    title: 'Edit',
                    onTap: () {},
                  ),
                  GlassMenuItem(
                    icon: Icon(CupertinoIcons.trash),
                    title: 'Delete',
                    isDestructive: true,
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24),
          ...List.generate(
            6,
            (i) => Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: GlassButton.custom(
                onTap: () {},
                width: double.infinity,
                height: 52,
                shape: LiquidRoundedSuperellipse(borderRadius: 14),
                glowColor: CupertinoColors.activeOrange.withValues(alpha: 0.35),
                child: Text(
                  'GlassButton ${i + 1}  ← should be hidden when menu open',
                  style: TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Shared helper widgets
// =============================================================================

class _BugSection extends StatelessWidget {
  const _BugSection({
    required this.number,
    required this.title,
    required this.description,
  });

  final String number;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: CupertinoColors.activeOrange.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: CupertinoColors.activeOrange.withValues(alpha: 0.4),
            ),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.activeOrange,
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.white.withValues(alpha: 0.55),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoLabel extends StatelessWidget {
  const _InfoLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: CupertinoColors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ℹ️ ', style: TextStyle(fontSize: 13)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: CupertinoColors.white.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Reusable gradient background (same as main app)
// =============================================================================

Widget _buildBackground() {
  return Container(
    color: const Color(0xFF020715),
    child: Stack(
      children: [
        Positioned(
          top: -50,
          right: -100,
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFA246F7).withValues(alpha: 0.32),
                  const Color(0xFF9B59FF).withValues(alpha: 0.1),
                  const Color(0x00000000),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          top: 280,
          left: -100,
          child: Container(
            width: 460,
            height: 460,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFEB66FF).withValues(alpha: 0.16),
                  const Color(0x00000000),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -60,
          right: -40,
          child: Container(
            width: 420,
            height: 420,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF2077FF).withValues(alpha: 0.18),
                  const Color(0x00000000),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

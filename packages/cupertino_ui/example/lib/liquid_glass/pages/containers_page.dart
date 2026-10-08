import 'package:liquid_glass_widgets_example/constants/glass_settings.dart';

import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ContainersPage extends StatelessWidget {
  const ContainersPage({super.key});

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
        body: Material(
          type: MaterialType.transparency,
          child: GlassScrollEdgeEffect(
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
                // ── Large page title (iOS 26 inline style) ────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: Text(
                      'Containers',
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
                        // ── GlassContainer ─────────────────────────────────
                        const _SectionTitle(title: 'GlassContainer'),
                        SizedBox(height: 16),
                        GlassContainer(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Basic Glass Container',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: CupertinoColors.label
                                      .resolveFrom(context),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'The foundational container with glass effect.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: CupertinoColors.label
                                      .resolveFrom(context)
                                      .withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: GlassContainer(
                                padding: EdgeInsets.all(16),
                                shape: const LiquidRoundedSuperellipse(
                                  borderRadius: 20,
                                ),
                                child: Column(
                                  children: [
                                    Icon(CupertinoIcons.cube_box,
                                        color: CupertinoColors.activeBlue,
                                        size: 32),
                                    SizedBox(height: 8),
                                    Text(
                                      'Superellipse',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: CupertinoColors.label
                                            .resolveFrom(context)
                                            .withValues(alpha: 0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: GlassContainer(
                                width: double.infinity,
                                height: 100,
                                alignment: Alignment.center,
                                child: Text(
                                  'Fixed Size',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: CupertinoColors.label
                                          .resolveFrom(context)),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 40),

                        // ── GlassCard ──────────────────────────────────────
                        const _SectionTitle(title: 'GlassCard'),
                        SizedBox(height: 16),
                        GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.systemPurple
                                          .withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(CupertinoIcons.rectangle_stack,
                                        color: CupertinoColors.systemPurple),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Glass Card Title',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: CupertinoColors.label
                                                .resolveFrom(context),
                                          ),
                                        ),
                                        Text(
                                          'Opinionated defaults for card content',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: CupertinoColors
                                                  .secondaryLabel
                                                  .resolveFrom(context)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            _MiniCard(
                                icon: CupertinoIcons.heart_fill,
                                color: CupertinoColors.systemRed,
                                label: 'Favorites'),
                            SizedBox(width: 12),
                            _MiniCard(
                                icon: CupertinoIcons.star_fill,
                                color: CupertinoColors.activeOrange,
                                label: 'Starred'),
                            SizedBox(width: 12),
                            _MiniCard(
                                icon: CupertinoIcons.bookmark_fill,
                                color: CupertinoColors.activeGreen,
                                label: 'Saved'),
                          ],
                        ),

                        SizedBox(height: 40),

                        // ── GlassDivider ───────────────────────────────────
                        const _SectionTitle(title: 'GlassDivider'),
                        SizedBox(height: 16),
                        GlassCard(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: SizedBox(
                            height: 60,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text('Left',
                                    style: TextStyle(
                                        color: CupertinoColors.white
                                            .withValues(alpha: 0.8))),
                                const GlassDivider.vertical(),
                                Text('Center',
                                    style: TextStyle(
                                        color: CupertinoColors.white
                                            .withValues(alpha: 0.8))),
                                const GlassDivider.vertical(),
                                Text('Right',
                                    style: TextStyle(
                                        color: CupertinoColors.white
                                            .withValues(alpha: 0.8))),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 40),

                        // ── GlassListTile ──────────────────────────────────
                        const _SectionTitle(title: 'GlassListTile'),
                        SizedBox(height: 16),
                        GlassCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              GlassListTile(
                                leading: Icon(CupertinoIcons.person_fill,
                                    color: CupertinoColors.activeBlue),
                                title: Text('Account'),
                                trailing: GlassListTile.chevron,
                                onTap: () {},
                              ),
                              GlassListTile(
                                leading: Icon(CupertinoIcons.bell_fill,
                                    color: CupertinoColors.activeOrange),
                                title: Text('Notifications'),
                                subtitle: Text('Banners, sounds, badges'),
                                trailing: GlassListTile.chevron,
                                onTap: () {},
                              ),
                              GlassListTile(
                                leading: Icon(CupertinoIcons.lock_fill,
                                    color: CupertinoColors.activeGreen),
                                title: Text('Privacy & Security'),
                                trailing: GlassListTile.chevron,
                                onTap: () {},
                              ),
                              GlassListTile(
                                leading: Icon(CupertinoIcons.paintbrush_fill,
                                    color: CupertinoColors.systemPurple),
                                title: Text('Appearance'),
                                subtitle: Text('Dark mode, accent colour'),
                                trailing: GlassListTile.chevron,
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 40),

                        // ── GlassGroupedSection ─────────────────────────
                        const _SectionTitle(title: 'GlassGroupedSection'),
                        SizedBox(height: 8),
                        Text(
                          'Dividers injected automatically between tiles',
                          style: TextStyle(
                            fontSize: 13,
                            color: CupertinoColors.label
                                .resolveFrom(context)
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        SizedBox(height: 16),
                        GlassGroupedSection(
                          header: Padding(
                            padding: EdgeInsets.only(left: 16, bottom: 8),
                            child: Text(
                              'NETWORK',
                              style: TextStyle(
                                color: CupertinoColors.label
                                    .resolveFrom(context)
                                    .withValues(alpha: 0.5),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          children: [
                            GlassListTile(
                              leading: Icon(CupertinoIcons.wifi,
                                  color: CupertinoColors.activeBlue),
                              title: Text('Wi-Fi'),
                              subtitle: Text('Connected'),
                              trailing: GlassListTile.chevron,
                              onTap: () {},
                            ),
                            GlassListTile(
                              leading: Icon(CupertinoIcons.bluetooth,
                                  color: CupertinoColors.activeBlue
                                      .withValues(alpha: 0.7)),
                              title: Text('Bluetooth'),
                              subtitle: Text('On'),
                              trailing: GlassListTile.chevron,
                              onTap: () {},
                            ),
                            GlassListTile(
                              leading: Icon(
                                  CupertinoIcons.antenna_radiowaves_left_right,
                                  color: CupertinoColors.activeGreen),
                              title: Text('VPN'),
                              trailing: GlassListTile.chevron,
                              onTap: () {},
                              // No isLast needed — GlassGroupedSection handles it!
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        GlassGroupedSection(
                          header: Padding(
                            padding: EdgeInsets.only(left: 16, bottom: 8),
                            child: Text(
                              'DISPLAY',
                              style: TextStyle(
                                color: CupertinoColors.label
                                    .resolveFrom(context)
                                    .withValues(alpha: 0.5),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          footer: Padding(
                            padding: EdgeInsets.only(left: 16, top: 8),
                            child: Text(
                              'Adjusts the colour temperature of your display.',
                              style: TextStyle(
                                color: CupertinoColors.label
                                    .resolveFrom(context)
                                    .withValues(alpha: 0.4),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          children: [
                            GlassListTile(
                              leading: Icon(CupertinoIcons.brightness,
                                  color: CupertinoColors.activeOrange),
                              title: Text('Brightness'),
                              trailing: GlassListTile.chevron,
                              onTap: () {},
                            ),
                            GlassListTile(
                              leading: Icon(CupertinoIcons.moon_fill,
                                  color: Colors.indigo),
                              title: Text('Night Shift'),
                              trailing: GlassListTile.chevron,
                              onTap: () {},
                            ),
                          ],
                        ),

                        SizedBox(height: 40),

                        // ── GlassStepper ───────────────────────────────────
                        const _SectionTitle(title: 'GlassStepper'),
                        SizedBox(height: 16),
                        const _StepperDemo(),

                        SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.icon,
    required this.color,
    required this.label,
  });
  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: CupertinoColors.label
                    .resolveFrom(context)
                    .withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperDemo extends StatefulWidget {
  const _StepperDemo();

  @override
  State<_StepperDemo> createState() => _StepperDemoState();
}

class _StepperDemoState extends State<_StepperDemo> {
  double _quantity = 1;
  double _temperature = 20;
  double _rating = 3;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Quantity',
                  style: TextStyle(
                      color: CupertinoColors.label.resolveFrom(context),
                      fontSize: 16)),
              Row(
                children: [
                  Text(
                    _quantity.toInt().toString(),
                    style: TextStyle(
                      color: CupertinoColors.label.resolveFrom(context),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 16),
                  GlassStepper(
                    value: _quantity,
                    min: 1,
                    max: 99,
                    step: 1,
                    onChanged: (v) => setState(() => _quantity = v),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        GlassCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Temperature',
                  style: TextStyle(
                      color: CupertinoColors.label.resolveFrom(context),
                      fontSize: 16)),
              Row(
                children: [
                  Text(
                    '${_temperature.toInt()}°C',
                    style: TextStyle(
                      color: CupertinoColors.label.resolveFrom(context),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 16),
                  GlassStepper(
                    value: _temperature,
                    min: -10,
                    max: 40,
                    step: 0.5,
                    onChanged: (v) => setState(() => _temperature = v),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        GlassCard(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Rating (wraps)',
                      style: TextStyle(
                          color: CupertinoColors.label.resolveFrom(context),
                          fontSize: 16)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (i) {
                      return Icon(
                        i < _rating ? CupertinoIcons.star : CupertinoIcons.star,
                        color: i < _rating
                            ? CupertinoColors.activeOrange
                            : CupertinoColors.white.withValues(alpha: 0.38),
                        size: 18,
                      );
                    }),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: GlassStepper(
                  value: _rating,
                  min: 1,
                  max: 5,
                  step: 1,
                  wraps: true,
                  onChanged: (v) => setState(() => _rating = v),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

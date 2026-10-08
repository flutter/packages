// Copyright 2026, Sebastian Degenaar for pixel-innovations.com (liquid_glass_widgets)
//
// SPDX-License-Identifier: MIT

/// Materialize Showcase — `GlassMaterialize` entrance and exit transitions.
///
/// Demonstrates the iOS 26 `glassEffectTransition(.materialize)` effect on
/// ordinary glass, away from the navigation bar:
///
///   • [GlassMaterialize] — the implicit, `visible:`-driven form
///   • [GlassMaterializeTransition.switcherBuilder] — inside an
///     [AnimatedSwitcher], swapping one glass chip for another
///   • A Reduce Motion toggle, so the cross-dissolve fallback can be seen
///     side by side with the full effect
///
/// The background is deliberately busy: the effect drives the glass shader's
/// own visibility uniforms, and the refraction dissolving to nothing is only
/// legible over content worth refracting.
///
/// Run standalone:
///   flutter run -t lib/demos/materialize_demo.dart
library;

import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(LiquidGlassWidgets.wrap(child: const _App()));
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'Materialize Playground',
      theme: CupertinoThemeData(brightness: Brightness.dark),
      home: MaterializeDemo(),
    );
  }
}

/// Interactive playground for the materialize transition.
class MaterializeDemo extends StatefulWidget {
  /// Creates the materialize demo.
  const MaterializeDemo({super.key});

  @override
  State<MaterializeDemo> createState() => _MaterializeDemoState();
}

class _MaterializeDemoState extends State<MaterializeDemo> {
  bool _showButton = true;
  bool _showCapsule = true;
  bool _reduceMotion = false;
  int _chip = 0;

  static const _chips = <String>['Trending', 'Latest', 'For You'];

  @override
  Widget build(BuildContext context) {
    return GlassAccessibilityScope(
      reduceMotion: _reduceMotion,
      child: GlassScaffold(
        background: const _Backdrop(),
        appBar: GlassAppBar(title: const Text('Materialize')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 80),
                const _Caption('A single glass button'),
                SizedBox(
                  height: 72,
                  child: Center(
                    child: GlassMaterialize(
                      visible: _showButton,
                      child: GlassButton(
                        icon: const Icon(CupertinoIcons.search),
                        width: 56,
                        height: 56,
                        useOwnLayer: true,
                        label: 'Search',
                        onTap: () {},
                      ),
                    ),
                  ),
                ),
                CupertinoButton(
                  onPressed: () => setState(() => _showButton = !_showButton),
                  child: Text(_showButton ? 'Dematerialize' : 'Materialize'),
                ),
                const SizedBox(height: 24),
                const _Caption('A capsule of several items'),
                SizedBox(
                  height: 72,
                  child: Center(
                    child: GlassMaterialize(
                      visible: _showCapsule,
                      // Anchored right, as a trailing bar cluster would be.
                      alignment: Alignment.centerRight,
                      child: GlassButtonGroup.icons(
                        items: [
                          GlassButtonGroupItem(
                            icon: const Icon(CupertinoIcons.share),
                            onTap: () {},
                          ),
                          GlassButtonGroupItem(
                            icon: const Icon(CupertinoIcons.heart),
                            onTap: () {},
                          ),
                          GlassButtonGroupItem(
                            icon: const Icon(CupertinoIcons.ellipsis),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                CupertinoButton(
                  onPressed: () => setState(() => _showCapsule = !_showCapsule),
                  child: Text(_showCapsule ? 'Dematerialize' : 'Materialize'),
                ),
                const SizedBox(height: 24),
                const _Caption('Swapped through an AnimatedSwitcher'),
                SizedBox(
                  height: 72,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: GlassDefaults.materializeDuration,
                      reverseDuration: GlassDefaults.dematerializeDuration,
                      transitionBuilder:
                          GlassMaterializeTransition.switcherBuilder,
                      child: GlassContainer(
                        key: ValueKey(_chip),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: const LiquidRoundedSuperellipse(
                          borderRadius: 22,
                        ),
                        child: Text(_chips[_chip]),
                      ),
                    ),
                  ),
                ),
                CupertinoButton(
                  onPressed: () =>
                      setState(() => _chip = (_chip + 1) % _chips.length),
                  child: const Text('Next'),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Reduce Motion'),
                      const SizedBox(width: 12),
                      CupertinoSwitch(
                        value: _reduceMotion,
                        onChanged: (v) => setState(() => _reduceMotion = v),
                      ),
                    ],
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

class _Caption extends StatelessWidget {
  const _Caption(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          text,
          style: const TextStyle(fontSize: 13, color: Color(0x99FFFFFF)),
        ),
      );
}

/// A busy backdrop, so the dissolving refraction has something to refract.
class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1B2A4A),
            Color(0xFF7B2D5E),
            Color(0xFFB5542F),
          ],
        ),
      ),
      child: Column(
        children: List.generate(
          14,
          (i) => Expanded(
            child: Row(
              children: List.generate(
                8,
                (j) => Expanded(
                  child: ColoredBox(
                    color: (i + j).isEven
                        ? const Color(0x14FFFFFF)
                        : const Color(0x00000000),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

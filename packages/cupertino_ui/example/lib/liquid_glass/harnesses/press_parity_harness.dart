// Parity harness — the package's press interaction beside iOS's own.
//
// Each row pairs a native SwiftUI `glassEffect(.regular.interactive())` shape
// on the left with a [GlassButton] of the same geometry on the right. Press,
// hold, drag, release: native inflates the glass on touch-down with a spring,
// brightens it, and lets it stretch toward the finger. A screen recording of
// the two side by side shows where ours diverges.
//
// NOT a showcase demo, which is why it does not live in lib/demos: it will
// not run as-is. It needs a `liquid_glass_widgets/native_press` UIKitView
// factory registered in the iOS runner's AppDelegate, backed by a SwiftUI
// view that reads `shape`, `width` and `height` from its creation params.
// example/ios is scaffolded per checkout and is not tracked, so that
// registration has to be written by hand before this will start.
//
//   cd example && flutter run -t lib/harnesses/press_parity_harness.dart
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets_example/constants/glass_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(LiquidGlassWidgets.wrap(child: const _App()));
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) => const CupertinoApp(
        debugShowCheckedModeBanner: false,
        title: 'Press Parity',
        theme: CupertinoThemeData(brightness: Brightness.light),
        home: PressParityHarness(),
      );
}

/// Shows the native and package press interactions side by side.
class PressParityHarness extends StatelessWidget {
  /// Creates the parity harness.
  const PressParityHarness({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          const Positioned.fill(child: _Backdrop()),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),
                const Text(
                  'Press parity',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Press · hold · drag · release',
                  style: TextStyle(fontSize: 13, color: Color(0x8A000000)),
                ),
                const SizedBox(height: 28),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _Label('NATIVE — glassEffect(.interactive)'),
                    _Label('PACKAGE — GlassButton'),
                  ],
                ),
                _ParityRow(
                  shape: 'circle',
                  buttonSize: const Size(56, 56),
                  hostSize: const Size(140, 140),
                  package: GlassButton(
                    icon: const Icon(CupertinoIcons.plus),
                    iconSize: 22,
                    width: 56,
                    height: 56,
                    quality: GlassQuality.premium,
                    label: 'Add',
                    onTap: () {},
                  ),
                ),
                const SizedBox(height: 12),
                _ParityRow(
                  shape: 'capsule',
                  buttonSize: const Size(132, 44),
                  hostSize: const Size(180, 120),
                  package: GlassButton.custom(
                    width: 132,
                    height: 44,
                    shape: const LiquidRoundedRectangle(borderRadius: 22),
                    quality: GlassQuality.premium,
                    label: 'Label',
                    onTap: () {},
                    child: const Text(
                      'Label',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
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

/// One native/package pair of the same geometry, each centred in a host box
/// large enough that the inflated, stretched glass is never clipped.
class _ParityRow extends StatelessWidget {
  const _ParityRow({
    required this.shape,
    required this.buttonSize,
    required this.hostSize,
    required this.package,
  });

  /// `circle` or `capsule` — which SwiftUI shape the native side draws.
  final String shape;
  final Size buttonSize;
  final Size hostSize;
  final Widget package;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox.fromSize(
          size: hostSize,
          child: UiKitView(
            viewType: 'liquid_glass_widgets/native_press',
            creationParams: <String, Object>{
              'shape': shape,
              'width': buttonSize.width,
              'height': buttonSize.height,
            },
            creationParamsCodec: const StandardMessageCodec(),
            // Claim the pointer outright so the native glass sees touch-down
            // on the same frame ours does, not once the gesture arena settles.
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
          ),
        ),
        // The same layer and settings the showcase demos use, so the package
        // side looks exactly as it does in the app.
        SizedBox.fromSize(
          size: hostSize,
          child: AdaptiveLiquidGlassLayer(
            settings: RecommendedGlassSettings.standard,
            child: Center(child: package),
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            letterSpacing: 0.4,
            color: Color(0x8A000000),
          ),
        ),
      );
}

/// A backdrop with structure, so refraction moving under the glass is legible.
class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFBFD4F2), Color(0xFFE9C7D8), Color(0xFFF7D9A8)],
        ),
      ),
      child: Column(
        children: List.generate(
          16,
          (i) => Expanded(
            // Stretch: an empty ColoredBox has no height of its own, and a
            // centred cross axis would collapse each cell to 0 px.
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(
                9,
                (j) => Expanded(
                  child: ColoredBox(
                    color: (i + j).isEven
                        ? const Color(0x22000000)
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

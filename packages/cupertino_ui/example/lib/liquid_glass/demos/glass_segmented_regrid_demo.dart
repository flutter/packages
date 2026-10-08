// Scrollable segmented control — re-grid morph + selection seating
//
// The scrollable control's hard case is a list whose LENGTH changes while a
// selection is showing: a time picker that re-steps 60 → 30 → 15 minutes
// re-grids every cell around the value you are looking at.
//
// Toggle "Morph" to compare the two candidate defaults for regridDuration:
//   off (Duration.zero) — the list swaps instantly
//   on  (180ms)         — entrants grow in, leavers shrink out, and the
//                         selection stays anchored under your eye
//
// "Remount" rebuilds the control from scratch to show the seating beat: a
// fresh mount lands with the selection already centred rather than sliding
// in from the first segment.

import 'package:flutter/cupertino.dart';

import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(LiquidGlassWidgets.wrap(child: const SegmentedRegridApp()));
}

class SegmentedRegridApp extends StatelessWidget {
  const SegmentedRegridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'Segmented — Re-grid Morph',
      theme: CupertinoThemeData(brightness: Brightness.dark),
      home: SegmentedRegridHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SegmentedRegridHome extends StatefulWidget {
  const SegmentedRegridHome({super.key});

  @override
  State<SegmentedRegridHome> createState() => _SegmentedRegridHomeState();
}

class _SegmentedRegridHomeState extends State<SegmentedRegridHome> {
  /// Minutes-per-step, coarse → fine.
  static const List<int> _steps = [60, 30, 15];

  int _stepMin = 60;
  int _selectedMin = 9 * 60; // 9:00 AM
  bool _morph = true;
  int _mountEpoch = 0; // bump to force a fresh mount

  /// Every step from midnight, plus the current selection if the step no
  /// longer lands on it — the same insert-if-missing rule a real picker
  /// needs so stepping coarse can't silently move the user's value.
  List<int> get _values {
    final values = [for (var m = 0; m < 24 * 60; m += _stepMin) m];
    if (!values.contains(_selectedMin)) {
      values.add(_selectedMin);
      values.sort();
    }
    return values;
  }

  static String _label(int minutes) {
    final h24 = minutes ~/ 60;
    final m = minutes % 60;
    final h = h24 % 12 == 0 ? 12 : h24 % 12;
    final digits = m == 0 ? '$h' : '$h:${m.toString().padLeft(2, '0')}';
    return '$digits ${h24 < 12 ? 'AM' : 'PM'}';
  }

  void _setStep(int step) => setState(() => _stepMin = step);

  @override
  Widget build(BuildContext context) {
    final values = _values;
    final stepIdx = _steps.indexOf(_stepMin);

    return CupertinoPageScaffold(
      navigationBar: GlassAppBar(
        title: const Text(
          'Segmented — Re-grid Morph',
          style: TextStyle(
            color: CupertinoColors.label,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          GlassButton(
            icon: const Icon(CupertinoIcons.refresh),
            onTap: () => setState(() => _mountEpoch++),
          ),
        ],
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GlassSegmentedControl.scrollable(
                  // The key is the demo's remount button, not part of the
                  // API — it throws the state away so the seating beat runs
                  // again on a fresh mount.
                  key: ValueKey(_mountEpoch),
                  quality: GlassQuality.premium,
                  selectedIndex: values.indexOf(_selectedMin),
                  onSegmentSelected: (i) =>
                      setState(() => _selectedMin = values[i]),
                  selectionAlignment: SegmentSelectionAlignment.center,
                  dragBehavior: SegmentDragBehavior.scroll,
                  regridDuration: _morph
                      ? const Duration(milliseconds: 180)
                      : Duration.zero,
                  segments: [
                    for (final m in values)
                      // id is what lets a surviving cell keep its element
                      // across the re-grid; without it the morph has no
                      // anchor and the list simply redraws.
                      GlassSegment(label: _label(m), id: 'time-$m'),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Step control — the re-grid trigger.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GlassButton(
                    icon: const Icon(CupertinoIcons.zoom_in),
                    onTap: () => _setStep(
                        _steps[(stepIdx + 1).clamp(0, _steps.length - 1)]),
                  ),
                  const SizedBox(width: 12),
                  GlassButton(
                    icon: const Icon(CupertinoIcons.zoom_out),
                    onTap: () => _setStep(
                        _steps[(stepIdx - 1).clamp(0, _steps.length - 1)]),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Morph',
                    style: TextStyle(
                      color: CupertinoColors.label.resolveFrom(context),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 10),
                  CupertinoSwitch(
                    value: _morph,
                    onChanged: (v) => setState(() => _morph = v),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                '$_stepMin-min steps  ·  ${values.length} segments  ·  '
                '${_label(_selectedMin)}',
                style: TextStyle(
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Zoom to re-step  ·  toggle Morph to compare  ·  ↻ to remount',
                style: TextStyle(
                  color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

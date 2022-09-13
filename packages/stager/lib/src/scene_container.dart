import 'package:flutter/material.dart';
import 'package:stager/src/environment_manipulation_panel.dart';

import 'multifinger_long_press_gesture_detector.dart';

/// Wraps [child] in a MediaQuery whose properties (such as textScale and
/// brightness) are editable using an on-screen widget.
///
/// The environment editing widget can be toggled using a two-finger long press.
class SceneContainer extends StatefulWidget {
  final Widget child;

  const SceneContainer({super.key, required this.child});

  @override
  State<SceneContainer> createState() => _SceneContainerState();
}

class _SceneContainerState extends State<SceneContainer> {
  bool _showEnvPanel = true;

  double _textScale = 1;
  bool _isDarkMode = false;
  TargetPlatform? _targetPlatform;

  @override
  Widget build(BuildContext context) {
    return MultiTouchLongPressGestureDetector(
      numberOfTouches: 2,
      onGestureDetected: () => setState(() {
        setState(() {
          _showEnvPanel = !_showEnvPanel;
        });
      }),
      child: Stack(
        children: [
          MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: _textScale,
              platformBrightness:
                  _isDarkMode ? Brightness.dark : Brightness.light,
            ),
            child: Theme(
              data: Theme.of(context).copyWith(platform: _targetPlatform),
              child: widget.child,
            ),
          ),
          AnimatedPositioned(
            left: 0,
            right: 0,
            // 100 was chosen arbitrarily as a "high enough" value to ensure the
            // panel is not visible when animated out.
            bottom: _showEnvPanel ? 0 : -100,
            duration: Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: EnvironmentManipulationPanel(
              targetPlatform: _targetPlatform,
              toggleDarkMode: () => setState(() {
                _isDarkMode = !_isDarkMode;
              }),
              decrementTextScale: () => setState(() {
                _textScale -= 0.1;
              }),
              incrementTextScale: () => setState(() {
                _textScale += 0.1;
              }),
              onTargetPlatformChanged: (targetPlatform) => setState(() {
                _targetPlatform = targetPlatform;
              }),
              hidePanel: () => setState(() {
                _showEnvPanel = false;
              }),
            ),
          ),
        ],
      ),
    );
  }
}

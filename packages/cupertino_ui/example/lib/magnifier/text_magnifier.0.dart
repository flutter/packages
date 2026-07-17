// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// #region body
import 'package:flutter/foundation.dart';
import 'package:cupertino_ui/cupertino_ui.dart';

void main() => runApp(const TextMagnifierExampleApp(text: 'Hello world!'));

class TextMagnifierExampleApp extends StatefulWidget {
  const TextMagnifierExampleApp({super.key, this.textDirection = TextDirection.ltr, required this.text});

  final TextDirection textDirection;
  final String text;

  @override
  State<TextMagnifierExampleApp> createState() => _TextMagnifierExampleAppState();
}

class _TextMagnifierExampleAppState extends State<TextMagnifierExampleApp> {
  late final controller = TextEditingController(text: widget.text);

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: CupertinoPageScaffold(
        child: Padding(
          padding: const .symmetric(horizontal: 48.0),
          child: Center(
            child: CupertinoTextField(
              textDirection: widget.textDirection,
              // Create a custom magnifier configuration that
              // this `TextField` will use to build a magnifier with.
              magnifierConfiguration: TextMagnifierConfiguration(
                magnifierBuilder: (_, _, ValueNotifier<MagnifierInfo> magnifierInfo) =>
                    CustomMagnifier(magnifierInfo: magnifierInfo),
              ),
              controller: controller,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class CustomMagnifier extends StatelessWidget {
  const CustomMagnifier({super.key, required this.magnifierInfo});

  static const Size magnifierSize = Size(200, 200);

  // This magnifier will consume some text data and position itself
  // based on the info in the magnifier.
  final ValueNotifier<MagnifierInfo> magnifierInfo;

  @override
  Widget build(BuildContext context) {
    // Use a value listenable builder because we want to rebuild
    // every time the text selection info changes.
    // `CustomMagnifier` could also be a `StatefulWidget` and call `setState`
    // when `magnifierInfo` updates. This would be useful for more complex
    // positioning cases.
    return ValueListenableBuilder<MagnifierInfo>(
      valueListenable: magnifierInfo,
      builder: (BuildContext context, MagnifierInfo currentMagnifierInfo, _) {
        // We want to position the magnifier at the global position of the gesture.
        Offset magnifierPosition = currentMagnifierInfo.globalGesturePosition;

        // You may use the `MagnifierInfo` however you'd like:
        // In this case, we make sure the magnifier never goes out of the current line bounds.
        magnifierPosition = Offset(
          clampDouble(
            magnifierPosition.dx,
            currentMagnifierInfo.currentLineBoundaries.left,
            currentMagnifierInfo.currentLineBoundaries.right,
          ),
          clampDouble(
            magnifierPosition.dy,
            currentMagnifierInfo.currentLineBoundaries.top,
            currentMagnifierInfo.currentLineBoundaries.bottom,
          ),
        );

        // Finally, align the magnifier to the bottom center. The initial anchor is
        // the top left, so subtract bottom center alignment.
        magnifierPosition -= Alignment.bottomCenter.alongSize(magnifierSize);

        return Positioned(
          left: magnifierPosition.dx,
          top: magnifierPosition.dy,
          child: RawMagnifier(
            magnificationScale: 2,
            // The focal point starts at the center of the magnifier.
            // We probably want to point below the magnifier, so
            // offset the focal point by half the magnifier height.
            focalPointOffset: Offset(0, magnifierSize.height / 2),
            // Decorate it however we'd like!
            decoration: const MagnifierDecoration(
              shape: StarBorder(side: BorderSide(color: Color(0xFF00FF00), width: 2)),
            ),
            size: magnifierSize,
          ),
        );
      },
    );
  }
}
// #endregion body

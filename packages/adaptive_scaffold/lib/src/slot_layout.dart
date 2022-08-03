// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'breakpoints.dart';
import 'slot_layout_config.dart';

/// A Widget that takes a mapping of [SlotLayoutConfig]s to [Breakpoint]s and
/// adds the appropriate Widget based on the current screen size.
///
/// Commonly used with [AdaptiveLayout] but also functional on its own.
class SlotLayout extends StatefulWidget {
  /// Creates a [SlotLayout] widget.
  const SlotLayout({required this.config, super.key});

  /// Given a context and a config, it returns the [SlotLayoutConfig] that will
  /// be chosen from the config under the context's conditions.
  static SlotLayoutConfig? pickWidget(
      BuildContext context, Map<Breakpoint, SlotLayoutConfig?> config) {
    SlotLayoutConfig? chosenWidget;
    config.forEach((Breakpoint breakpoint, SlotLayoutConfig? pickedWidget) {
      if (breakpoint.isActive(context)) {
        chosenWidget = pickedWidget;
      }
    });
    return chosenWidget;
  }

  /// This is a mapping from [Breakpoint]s to [SlotLayoutConfig]s that
  /// is used to determine what Widget to display at what point. The
  /// [SlotLayoutConfig]s in this map are nullable since some breakpoints apply
  /// to more open ranges and the nullability allows one to override the value
  /// at that Breakpoint to be null.
  ///
  /// The appropriate [SlotLayoutConfig] is picked based on the assigned
  /// [Breakpoint]'s isActive method.
  final Map<Breakpoint, SlotLayoutConfig?> config;

  @override
  State<SlotLayout> createState() => _SlotLayoutState();
}

class _SlotLayoutState extends State<SlotLayout>
    with SingleTickerProviderStateMixin {
  SlotLayoutConfig? chosenWidget;

  @override
  Widget build(BuildContext context) {
    chosenWidget = SlotLayout.pickWidget(context, widget.config);
    bool hasAnimation = false;
    return AnimatedSwitcher(
        duration: const Duration(milliseconds: 1000),
        layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
          final Stack elements = Stack(
            children: <Widget>[
              if (hasAnimation) ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
          return elements;
        },
        transitionBuilder: (Widget child, Animation<double> animation) {
          final SlotLayoutConfig configChild = child as SlotLayoutConfig;
          if (child.key == chosenWidget?.key) {
            return (configChild.inAnimation != null)
                ? child.inAnimation!(child, animation)
                : child;
          } else {
            if (configChild.outAnimation != null) {
              hasAnimation = true;
            }
            return (configChild.outAnimation != null)
                ? child.outAnimation!(child, ReverseAnimation(animation))
                : child;
          }
        },
        child: chosenWidget ?? SlotLayoutConfig.empty());
  }
}

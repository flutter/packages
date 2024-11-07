import 'package:flutter/widgets.dart';

import 'loaders.dart';

/// The SVG theme to apply to descendant [SvgPicture] widgets
/// which don't have explicit theme values.
class DefaultSvgTheme extends InheritedTheme {
  /// Creates a default SVG theme for the given subtree
  /// using the provided [theme].
  const DefaultSvgTheme({
    super.key,
    required super.child,
    required this.theme,
  });

  /// The SVG theme to apply.
  final SvgTheme theme;

  /// The closest instance of this class that encloses the given context.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// DefaultSvgTheme theme = DefaultSvgTheme.of(context);
  /// ```
  static DefaultSvgTheme? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DefaultSvgTheme>();
  }

  @override
  bool updateShouldNotify(DefaultSvgTheme oldWidget) {
    return theme != oldWidget.theme;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return DefaultSvgTheme(
      theme: theme,
      child: child,
    );
  }
}

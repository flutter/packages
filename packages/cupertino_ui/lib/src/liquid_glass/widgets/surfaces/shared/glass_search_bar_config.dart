import 'package:flutter/cupertino.dart';

/// Configuration for the morphing search bar in [GlassTabBar.searchable].
///
/// When the user taps the collapsed search pill, [onSearchToggle] is called
/// with `true`. Set `isSearchActive` to `true` to
/// expand the search bar and collapse the tab pill.
///
/// ## Example
/// ```dart
/// GlassTabBar.searchable(
///   tabs: [...],
///   selectedIndex: _tab,
///   onTabSelected: (i) => setState(() => _tab = i),
///   isSearchActive: _searching,
///   searchConfig: GlassSearchBarConfig(
///     onSearchToggle: (v) => setState(() => _searching = v),
///     hintText: 'Apple News',
///     collapsedLogoBuilder: (ctx) => ..., // N logo shown when searching
///   ),
/// )
/// ```
class GlassSearchBarConfig {
  /// Creates a search bar configuration.
  const GlassSearchBarConfig({
    required this.onSearchToggle,
    this.hintText = 'Search',
    this.collapsedTabWidth,
    this.collapsedLogoBuilder,
    this.searchIconColor,
    this.searchIcon,
    this.micIconColor,
    this.hintStyle,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onMicTap,
    this.textColor,
    this.cursorColor,
    this.trailingBuilder,
    this.textInputAction,
    this.keyboardType,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.onTapOutside,
    this.autoFocusOnExpand = false,
    this.expandWhenActive = true,
    this.showPill = true,
    this.showsCancelButton = true,
    this.cancelButtonColor,
    this.cancelIcon,
    this.cancelIconSize = 24,
    this.onSearchFocusChanged,
    this.onSearchFieldTap,
    this.onCancelTap,
    this.clearButtonSemanticLabel,
    this.micButtonSemanticLabel,
    this.cancelButtonSemanticLabel,
  });

  /// Called with `true` when search is activated, `false` when dismissed.
  final ValueChanged<bool> onSearchToggle;

  /// Placeholder text in the expanded search bar. Defaults to `'Search'`.
  final String hintText;

  /// Width of the collapsed tab pill when search is active.
  ///
  /// If omitted, defaults to matching the `searchBarHeight`
  /// to ensure the collapsed indicator perfectly shrinks proportionately into a circle.
  final double? collapsedTabWidth;

  /// Widget shown inside the collapsed tab pill when search is active.
  ///
  /// Optional builder for a custom logo/icon shown on the collapsed tab pill
  /// when search is fully active.
  ///
  /// If omitted, this defaults to displaying the [GlassTab.activeIcon] (or fallback
  /// [GlassTab.icon]) of the currently selected [GlassTab], matching the native
  /// iOS Apple News behavior.
  final WidgetBuilder? collapsedLogoBuilder;

  /// Color for the 🔍 and 🎤️ icons. Defaults to `CupertinoColors.secondaryLabel`
  /// (adapts to light/dark mode).
  final Color? searchIconColor;

  /// Custom widget rendered in place of the default magnifying-glass
  /// icon on the collapsed search pill. When non-null, [searchIconColor]
  /// is ignored for this particular slot — the caller's widget is
  /// expected to handle its own coloring.
  ///
  /// The default (`null`) preserves the upstream behavior:
  /// `Icon(CupertinoIcons.search, color: searchIconColor ?? CupertinoColors.secondaryLabel)`.
  ///
  /// Useful when the caller wants a higher-fidelity glyph (e.g. real
  /// SF Symbols via `flutter_sficon`) or a different icon set with
  /// weight control (e.g. Material Symbols).
  final Widget? searchIcon;

  /// Color for the microphone icon specifically. Falls back to [searchIconColor].
  ///
  /// Ignored when [trailingBuilder] is provided.
  final Color? micIconColor;

  /// Text style for the hint text. Uses a sensible default when null.
  ///
  /// Its font size, weight and family are shared with the typed text, so the
  /// field does not change metrics as the user starts typing. Its colour is
  /// the hint's; typed text takes [textColor] instead, and falls back to this
  /// colour only when [textColor] is null. To mute the hint while keeping the
  /// typed text strong, set both.
  final TextStyle? hintStyle;

  /// Optional controller for the search text field.
  ///
  /// If null, the widget manages its own internal controller.
  final TextEditingController? controller;

  /// Optional focus node for the search text field.
  ///
  /// Providing a [FocusNode] gives you full programmatic control over when
  /// the search keyboard appears and disappears — independently of
  /// [autoFocusOnExpand].  Typical use-cases:
  ///
  /// - Call `focusNode.requestFocus()` to open the keyboard at an arbitrary
  ///   moment (e.g. after an animation completes or a voice-search result
  ///   arrives).
  /// - Call `focusNode.unfocus()` to dismiss the keyboard without collapsing
  ///   the search bar.
  /// - Listen to `focusNode.addListener(...)` for focus events in addition to
  ///   or instead of [onSearchFocusChanged].
  ///
  /// **Lifecycle:** the caller is responsible for disposing the node.
  /// The widget will never dispose a caller-provided [FocusNode].
  ///
  /// If null, an internal node is created and disposed automatically.
  final FocusNode? focusNode;

  /// Called on every keystroke as the user types in the search field.
  ///
  /// Use this for live/incremental search filtering. For submit-only
  /// behaviour (e.g. triggering a network request on Enter) use [onSubmitted].
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the search (keyboard action).
  final ValueChanged<String>? onSubmitted;

  /// Called when the user taps the microphone icon.
  ///
  /// When null the microphone icon is hidden. Ignored when [trailingBuilder]
  /// is provided (the builder is responsible for its own tap handling).
  final VoidCallback? onMicTap;

  /// Color of the typed text in the expanded search field.
  ///
  /// When `null` (the default), the colour is resolved from
  /// `CupertinoColors.label` using the **app's** active ThemeMode via
  /// `GlassTheme.brightnessOf` — the package's single brightness authority.
  /// This ensures the text is always legible against the glass pill regardless
  /// of whether the device OS is in dark mode, matching the iOS 26 behaviour
  /// where `UIUserInterfaceStyle` overrides propagate to every sub-view.
  ///
  /// Pass an explicit colour (including a [CupertinoDynamicColor]) to override.
  /// An explicit colour always wins for typed text, including over a colour
  /// set on [hintStyle], which then applies to the hint alone.
  final Color? textColor;

  /// Color of the text cursor (blinking caret) in the expanded
  /// search field.
  ///
  /// When `null` (the default), the cursor inherits via Flutter's
  /// standard resolution chain:
  ///   1. `Theme.of(context).textSelectionTheme.cursorColor`
  ///   2. On iOS, `CupertinoTheme.of(context).primaryColor`
  ///   3. `Theme.of(context).colorScheme.primary`
  ///
  /// This matches how every other Material `TextField` cursor in a
  /// Flutter app resolves color, so theme-driven apps Just Work
  /// without needing to set this here.
  ///
  /// **Breaking change in 0.13.0**: in 0.12.x and earlier the cursor
  /// was hard-coupled to [textColor]. To restore the previous
  /// behaviour, pass `cursorColor: textColor` explicitly:
  ///
  /// ```dart
  /// GlassSearchBarConfig(
  ///   textColor: Colors.white,
  ///   cursorColor: Colors.white,  // ← previously implicit
  ///   ...
  /// )
  /// ```
  final Color? cursorColor;

  // ── SearchBar parity ────────────────────────────────────────────────────────

  /// Custom widget builder for the trailing section of the expanded search bar.
  ///
  /// When provided, **completely replaces** the microphone icon and [onMicTap]
  /// behaviour. Use this to show a "Clear" button, voice-action indicator, or
  /// any other widget in the trailing position — matching Flutter's own
  /// [SearchBar.trailing] API.
  ///
  /// The builder receives a [BuildContext] that is a descendant of the
  /// expanded glass pill. If null, the standard mic icon / empty logic applies.
  ///
  /// ## Example — clear button
  /// ```dart
  /// trailingBuilder: (ctx) => GestureDetector(
  ///   onTap: () => searchController.clear(),
  ///   child: Icon(CupertinoIcons.clear_circled_solid,
  ///       color: Colors.white54, size: 18),
  /// ),
  /// ```
  final WidgetBuilder? trailingBuilder;

  /// The keyboard action button label for the search [TextField].
  ///
  /// Common values: [TextInputAction.search], [TextInputAction.done],
  /// [TextInputAction.go]. Defaults to null (system / platform default).
  final TextInputAction? textInputAction;

  /// The type of keyboard to display for the search [TextField].
  ///
  /// Defaults to null, which uses [TextInputType.text]. Pass
  /// [TextInputType.url] or [TextInputType.emailAddress] for specialised
  /// search contexts.
  final TextInputType? keyboardType;

  /// Whether to enable autocorrection for the search [TextField].
  ///
  /// Defaults to `true`. Set to `false` for search bars where autocorrection
  /// would interfere (e.g. product codes, usernames).
  final bool autocorrect;

  /// Whether to show input suggestions (QuickType bar on iOS) for the search
  /// [TextField].
  ///
  /// Defaults to `true`. Mirrors [TextField.enableSuggestions].
  final bool enableSuggestions;

  /// Called when the user taps outside the expanded search [TextField].
  ///
  /// Passed directly to [TextField.onTapOutside]. A common use-case is
  /// unfocusing the field so the keyboard dismisses when the user taps the
  /// page content above the bar:
  ///
  /// ```dart
  /// onTapOutside: (_) => FocusScope.of(context).unfocus(),
  /// ```
  final TapRegionCallback? onTapOutside;

  /// Whether the search [TextField] should automatically receive keyboard focus
  /// when the search bar expands.
  ///
  /// - `false` (default): the bar expands without triggering the keyboard;
  ///   the user taps inside the pill to start typing. Matches the behaviour
  ///   of the real iOS 26 Apple News search bar and looks more polished.
  /// - `true`: the keyboard opens automatically as soon as the bar expands —
  ///   useful for modal or dedicated search screens where typing is the
  ///   immediate next action.
  final bool autoFocusOnExpand;

  /// Whether the search pill expands horizontally to fill the available width
  /// when search is active.
  ///
  /// Defaults to `true` (Apple News style). Set to `false` if you want the
  /// search pill to remain a compact circular button on the right side when
  /// active, creating an empty gap in the center of the bar.
  final bool expandWhenActive;

  /// Whether the compact search pill exists on the bar.
  ///
  /// Defaults to `true` — the pill is present in both states, the original
  /// layout. `false` removes it entirely: the tab pill takes over the
  /// reclaimed width, and the pill is genuinely absent rather than
  /// invisible — it contributes no glass shape to the blend layer, so
  /// nothing fuses with the tab pill's trailing edge.
  ///
  /// The value may change at runtime: the pill spring-scales in and out in
  /// place at its slot, on the same spring the pill morphs use. That is the
  /// building block for app-driven policies — a bar that wants the pill
  /// only while search is active simply flips this together with
  /// `isSearchActive`.
  final bool showPill;

  /// Whether to show a cancel/dismiss button when the search bar is focused.
  ///
  /// Defaults to `true`, providing an intuitive escape hatch for users to dismiss
  /// the keyboard and search state. Note that if `true`, it renders a detached glass
  /// dismiss pill with an "X" icon, replicating Apple News.
  final bool showsCancelButton;

  /// Color of the cancel (×) icon.
  ///
  /// Defaults to white with 90% opacity, matching iOS system style.
  final Color? cancelButtonColor;

  /// Custom icon widget for the cancel (dismiss) button.
  ///
  /// When non-null, replaces the default [CupertinoIcons.xmark] glyph.
  /// The provided widget is rendered as-is inside the glass pill, so it
  /// should already carry its own color and size:
  ///
  /// ```dart
  /// cancelIcon: Icon(CupertinoIcons.xmark_circle_fill,
  ///     color: Colors.white, size: 22),
  /// ```
  ///
  /// When null, the default × icon is used with [cancelButtonColor] and
  /// [cancelIconSize].
  final Widget? cancelIcon;

  /// Size of the cancel (×) icon in logical pixels.
  ///
  /// Defaults to `24`. The reporter noted that `16` (the old default) was
  /// noticeably smaller than the iOS 26 dismiss button; `24` matches the
  /// visual weight of the adjacent search and mic icons.
  final double cancelIconSize;

  /// Called whenever the search field gains or loses keyboard focus.
  ///
  /// `true`  — keyboard is visible, field is active.
  /// `false` — keyboard dismissed, field is unfocused.
  ///
  /// Use this to switch the body content between a focused search state
  /// (e.g. "No Recent Searches") and an unfocused search state (e.g. a topic
  /// browse grid), without fully closing the search bar.
  final ValueChanged<bool>? onSearchFocusChanged;

  /// Called when the user taps the body of the active (expanded) search field.
  ///
  /// Passed directly to [TextField.onTap]. Useful for navigating to a
  /// dedicated search screen, showing a suggestion overlay, or logging an
  /// analytics event on search interaction — without needing to own the
  /// [FocusNode] yourself.
  ///
  /// Note: this fires on every tap of the field, including taps that
  /// merely restore focus after the keyboard was dismissed.
  final VoidCallback? onSearchFieldTap;

  /// Called when the user taps the dismiss (×) cancel pill to close the keyboard.
  ///
  /// Fires immediately after the library's own focus-release and
  /// [onSearchToggle]`(false)` calls, so the search state is already collapsing
  /// by the time your callback runs. Use this for:
  ///
  /// - Analytics (`analytics.log('search_cancelled')`).
  /// - Clearing search results so the body resets before the bar animates shut.
  /// - Programmatically unfocusing a custom [FocusNode] you own.
  ///
  /// When null (the default), the standard dismiss behaviour runs unchanged.
  final VoidCallback? onCancelTap;

  // ── Accessibility ───────────────────────────────────────────────────────────

  /// Screen reader label of the clear (×) button inside the expanded field.
  ///
  /// Defaults to the app's [CupertinoLocalizations.clearButtonLabel].
  final String? clearButtonSemanticLabel;

  /// Screen reader label of the microphone button (for example "Dictate").
  ///
  /// The button is exposed whenever [onMicTap] is set. Flutter has no
  /// localized string for dictation, so without this label it is announced
  /// by its role alone.
  final String? micButtonSemanticLabel;

  /// Screen reader label of the dismiss (×) pill beside the search field.
  ///
  /// Defaults to the app's [CupertinoLocalizations.cancelButtonLabel].
  final String? cancelButtonSemanticLabel;
}

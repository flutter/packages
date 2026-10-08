import 'package:flutter/cupertino.dart';

import '../../constants/glass_defaults.dart';
import '../../src/renderer/liquid_glass_renderer.dart';
import '../../src/types/glass_interaction_behavior.dart';
import '../../theme/glass_theme.dart';
import '../../theme/glass_theme_helpers.dart';
import '../../types/glass_quality.dart';
import '../shared/adaptive_liquid_glass_layer.dart';
import '../surfaces/shared/tab_bar_types.dart' show MaskingQuality;
import '../surfaces/glass_tab_bar.dart'
    show
        DividerSettings,
        GlassSegment,
        SegmentDragBehavior,
        SegmentSelectionAlignment;
import '../../src/widgets/interactive/scrollable_segment_content.dart';
import '../../src/widgets/interactive/segmented_control_internal.dart';

/// A glass morphism segmented control following Apple's design patterns.
///
/// [GlassSegmentedControl] provides a sophisticated segmented control with
/// an animated glass indicator, jelly physics, and smooth transitions between
/// segments. It matches iOS's UISegmentedControl appearance and behavior.
///
/// ## Key Features
///
/// - **Animated Glass Indicator**: Smoothly animates between segments
/// - **Jelly Physics**: Organic squash and stretch effects during movement
/// - **Drag Support**: Swipe between segments with velocity-based snapping
/// - **Sharp Text**: Selected text stays sharp above the glass
/// - **Flexible Sizing**: Automatically sizes segments evenly
/// - **Customizable Appearance**: Full control over colors, sizes, and effects
///
/// ## ⚠️ Do Not Wrap in GlassContainer or GlassCard
///
/// Placing this widget inside a [GlassContainer] or [GlassCard] is an
/// anti-pattern that causes two problems:
///
/// 1. **Visual degradation** — the container sets `avoidsRefraction: true`
///    on its children, causing the indicator's glass refraction to fall back
///    to a non-refracting path.
/// 2. **Jelly-physics clipping** — with `useOwnLayer: true` on the container,
///    the container's own-layer clip cuts the indicator's jelly overshoot
///    during drag animations.
///
/// The track background is already handled by [backgroundColor] — no outer
/// container is needed. For a standalone glass layer, use [useOwnLayer] on
/// this widget directly.
///

/// ## Usage
///
/// ### Basic Usage
/// ```dart
/// int selectedIndex = 0;
///
/// GlassSegmentedControl(
///   segments: const [
///     GlassSegment(label: 'Daily'),
///     GlassSegment(label: 'Weekly'),
///     GlassSegment(label: 'Monthly'),
///   ],
///   selectedIndex: selectedIndex,
///   onSegmentSelected: (index) {
///     setState(() => selectedIndex = index);
///   },
/// )
/// ```
///
/// ### Within LiquidGlassLayer (Grouped Mode)
/// ```dart
/// AdaptiveLiquidGlassLayer(
///   settings: LiquidGlassSettings(
///     thickness: 30,
///     blur: 3,
///     refractiveIndex: 1.59,
///   ),
///   child: Column(
///     children: [
///       GlassSegmentedControl(
///         segments: const [
///           GlassSegment(label: 'One'),
///           GlassSegment(label: 'Two'),
///           GlassSegment(label: 'Three'),
///         ],
///         selectedIndex: _selectedIndex,
///         onSegmentSelected: (index) {
///           setState(() => _selectedIndex = index);
///         },
///       ),
///     ],
///   ),
/// )
/// ```
///
/// ### Standalone Mode
/// ```dart
/// GlassSegmentedControl(
///   segments: const [
///     GlassSegment(label: 'Option A'),
///     GlassSegment(label: 'Option B'),
///   ],
///   selectedIndex: _selectedIndex,
///   onSegmentSelected: (index) {
///     setState(() => _selectedIndex = index);
///   },
///   useOwnLayer: true,
///   settings: LiquidGlassSettings(
///     thickness: 30,
///     blur: 3,
///   ),
/// )
/// ```
///
/// ### Icons and labels
/// ```dart
/// GlassSegmentedControl(
///   segments: const [
///     GlassSegment(icon: Icon(Icons.photo),     label: 'Photos'),
///     GlassSegment(icon: Icon(Icons.videocam),  label: 'Videos'),
///     GlassSegment(icon: Icon(Icons.music_note),label: 'Music'),
///   ],
///   selectedIndex: _selectedIndex,
///   onSegmentSelected: (index) =>
///       setState(() => _selectedIndex = index),
///   height: 56,
/// )
/// ```
///
/// ### Custom Styling
/// ```dart
/// GlassSegmentedControl(
///   segments: const [
///     GlassSegment(label: 'Small'),
///     GlassSegment(label: 'Medium'),
///     GlassSegment(label: 'Large'),
///   ],
///   selectedIndex: _selectedIndex,
///   onSegmentSelected: (index) =>
///       setState(() => _selectedIndex = index),
///   height: 36,
///   borderRadius: 18,
///   selectedTextStyle: TextStyle(
///     fontSize: 14,
///     fontWeight: FontWeight.w600,
///     color: CupertinoColors.white,
///   ),
///   unselectedTextStyle: TextStyle(
///     fontSize: 14,
///     fontWeight: FontWeight.w500,
///     color: CupertinoColors.white.withOpacity(0.6),
///   ),
/// )
/// ```
///
/// ### Vertical icon control
/// ```dart
/// GlassSegmentedControl(
///   direction: Axis.vertical,
///   height: 44, // cross-axis width in vertical mode
///   segmentExtent: 52,
///   segments: const [
///     GlassSegment(
///       icon: Icon(CupertinoIcons.square_grid_2x2),
///       semanticLabel: 'Canvas',
///     ),
///     GlassSegment(
///       icon: Icon(CupertinoIcons.circle_grid_hex),
///       semanticLabel: 'Flow',
///     ),
///   ],
///   selectedIndex: selectedIndex,
///   onSegmentSelected: onSelected,
/// )
/// ```
class GlassSegmentedControl extends StatefulWidget {
  /// Creates a fixed-extent glass segmented control (iOS UISegmentedControl).
  ///
  /// All segments are equal-width. For a scrollable variant that mimics
  /// [GlassTabBar]`(isScrollable: true)`, use [GlassSegmentedControl.scrollable].
  const GlassSegmentedControl({
    required this.segments,
    required this.selectedIndex,
    required this.onSegmentSelected,
    super.key,
    this.height = GlassDefaults.heightControl,
    this.borderRadius = GlassDefaults.capsuleRadius,
    this.indicatorBorderRadius,
    this.padding = const EdgeInsets.all(2),
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.backgroundColor,
    this.indicatorColor,
    this.indicatorSettings,
    this.indicatorPinchStrength = 0.4,
    this.indicatorExpansion =
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.settings,
    this.useOwnLayer = false,
    this.quality,
    this.backgroundKey,
    this.scrollController,
    this.selectionAlignment = SegmentSelectionAlignment.minimal,
    this.regridDuration = Duration.zero,
    this.dragBehavior = SegmentDragBehavior.selectIndicator,
    this.direction = Axis.horizontal,
    this.segmentExtent,
    // ── iOS 26 interaction ──────────────────────────────────────────────────
    this.interactionBehavior = GlassInteractionBehavior.full,
    this.glowColor,
    this.glowRadius = 1.5,
    // Scrollable-mode fields — unused in fixed mode.
    this.isScrollable = false,
    this.iconSize = 24.0,
    this.labelPadding = const EdgeInsets.symmetric(horizontal: 16),
    this.selectedIconColor,
    this.unselectedIconColor,
    this.maskingQuality = MaskingQuality.high,
    this.dividerSettings,
    this.indicatorShadow,
  })  : assert(
          segments.length >= 2,
          'GlassSegmentedControl requires at least 2 segments',
        ),
        assert(
          segments.length <= 6,
          'GlassSegmentedControl works best with 2–5 segments. '
          'For 6+ items use GlassSegmentedControl.scrollable().',
        ),
        assert(
          selectedIndex >= 0 && selectedIndex < segments.length,
          'selectedIndex must be within bounds of segments list',
        );

  /// Creates a scrollable glass segmented control that 100% mimics
  /// [GlassTabBar]`(isScrollable: true)` from the original API.
  ///
  /// Use this when you have many segments (typically 6+) that won’t fit in
  /// the available width. Segments have natural widths and scroll horizontally.
  ///
  /// ```dart
  /// GlassSegmentedControl.scrollable(
  ///   segments: [
  ///     GlassSegment(label: 'All'),
  ///     GlassSegment(label: 'Photos', icon: Icon(Icons.photo)),
  ///     GlassSegment(label: 'Videos'),
  ///     GlassSegment(label: 'Music'),
  ///     GlassSegment(label: 'Files'),
  ///   ],
  ///   selectedIndex: _selectedIndex,
  ///   onSegmentSelected: (i) => setState(() => _selectedIndex = i),
  /// )
  /// ```
  const GlassSegmentedControl.scrollable({
    required this.segments,
    required this.selectedIndex,
    required this.onSegmentSelected,
    super.key,
    this.height = 44.0,
    this.borderRadius = GlassDefaults.capsuleRadius,
    this.indicatorBorderRadius,
    this.padding = const EdgeInsets.all(2),
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.backgroundColor,
    this.indicatorColor,
    this.indicatorSettings,
    this.indicatorPinchStrength = 0.4,
    this.indicatorExpansion =
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.settings,
    this.useOwnLayer = false,
    this.quality,
    this.backgroundKey,
    // Scrollable-specific params
    this.scrollController,
    this.selectionAlignment = SegmentSelectionAlignment.minimal,
    this.regridDuration = Duration.zero,
    this.dragBehavior = SegmentDragBehavior.selectIndicator,
    this.iconSize = 24.0,
    this.labelPadding = const EdgeInsets.symmetric(horizontal: 16),
    this.selectedIconColor,
    this.unselectedIconColor,
    this.maskingQuality = MaskingQuality.high,
    this.dividerSettings,
    this.indicatorShadow,
  })  : isScrollable = true,
        direction = Axis.horizontal,
        segmentExtent = null,
        interactionBehavior = GlassInteractionBehavior.full,
        glowColor = null,
        glowRadius = 1.5,
        assert(segments.length >= 1,
            'GlassSegmentedControl.scrollable requires at least 1 segment'),
        assert(
          selectedIndex >= 0 && selectedIndex < segments.length,
          'selectedIndex must be within bounds of segments list',
        );

  // ===========================================================================
  // Segment Configuration
  // ===========================================================================

  /// List of segments to display.
  ///
  /// Each [GlassSegment] may have a [GlassSegment.label], a [GlassSegment.icon], or both.
  /// In fixed mode (default), all segments are equal-width. In scrollable mode
  /// segments have natural widths and scroll horizontally.
  ///
  /// Minimum 2 segments required (fixed mode), 1 segment (scrollable mode).
  final List<GlassSegment> segments;

  /// Whether this control scrolls horizontally.
  ///
  /// When `false` (default), uses equal-width segments with [SegmentedControlContent].
  /// When `true`, uses [ScrollableSegmentContent] with natural widths — identical to
  /// [GlassTabBar]`(isScrollable: true)` from the original API.
  final bool isScrollable;

  /// Index of the currently selected segment.
  ///
  /// Must be between 0 and segments.length - 1.
  final int selectedIndex;

  /// Called when a segment is selected.
  ///
  /// Provides the index of the newly selected segment.
  ///
  /// > **Note (iOS-style behaviour):** This callback may fire during a
  /// > *cancelled* gesture if the drag indicator travelled far enough to
  /// > snap to a different segment before the cancel arrived. This matches
  /// > `UISegmentedControl` semantics. If you need strict tap-only selection,
  /// > compare the received index against `selectedIndex` before acting.
  final ValueChanged<int> onSegmentSelected;

  /// The axis along which fixed-mode segments are laid out.
  ///
  /// Scrollable controls remain horizontal.
  final Axis direction;

  /// Main-axis size of each segment in vertical mode.
  ///
  /// Defaults to [height], producing square segments.
  final double? segmentExtent;

  // ===========================================================================
  // Layout Properties
  // ===========================================================================

  /// Height of the segmented control.
  ///
  /// In vertical mode this is the control's cross-axis width. The total height
  /// is ([segmentExtent] ?? [height]) × the number of segments.
  ///
  /// Defaults to 32 (matching iOS UISegmentedControl).
  final double height;

  /// Border radius of the segmented control.
  ///
  /// Defaults to `9999.0` — a capsule that matches the iOS 26 UISegmentedControl
  /// appearance regardless of bar height. Set to a finite value (e.g. 16) to
  /// produce rounded-rectangle corners.
  final double borderRadius;

  /// Optional override for the active indicator's corner radius.
  ///
  /// The radius is resolved in priority order:
  /// 1. **Manual override** (this value) — always wins.
  /// 2. **Capsule guard** — if [borderRadius] ≥ 9999.0 the indicator also
  ///    receives 9999.0, keeping the glass shader in true-capsule mode even
  ///    during jelly-bloom expansion where the pill canvas grows beyond its
  ///    rest size.
  /// 3. **Concentric math** — otherwise `(borderRadius − 2).clamp(0, 9999)`
  ///    so the indicator arcs nest concentrically inside the container.
  final double? indicatorBorderRadius;

  /// Padding around the indicator inside the background.
  ///
  /// Defaults to 2 pixels on all sides.
  final EdgeInsetsGeometry padding;

  // ===========================================================================
  // Style Properties
  // ===========================================================================

  /// Text style for the selected segment.
  ///
  /// If null, uses default style with fontSize 13, fontWeight w600,
  /// and white color.
  final TextStyle? selectedTextStyle;

  /// Text style for unselected segments.
  ///
  /// If null, uses default style with fontSize 13, fontWeight w500,
  /// and white color at 60% opacity.
  final TextStyle? unselectedTextStyle;

  /// Background color of the segmented control.
  ///
  /// If null, uses a semi-transparent fill depending on brightness.
  final Color? backgroundColor;

  /// Color of the indicator when not being dragged.
  ///
  /// If null, uses a semi-transparent color from the theme.
  final Color? indicatorColor;

  /// Glass settings for the draggable indicator.
  ///
  /// If null, uses optimized defaults for the indicator:
  /// - glassColor: Color.from(alpha: 0.1, red: 1, green: 1, blue: 1)
  /// - saturation: 1.5
  /// - refractiveIndex: 1.15
  /// - thickness: 20
  /// - lightIntensity: 2
  /// - chromaticAberration: 0.5
  /// - blur: 0
  final LiquidGlassSettings? indicatorSettings;

  /// Maximum concave lens pinch strength for the sliding indicator pill.
  ///
  /// - `1.0` (default) — full Apple-calibrated pinch
  /// - `0.0` — pinch fully disabled
  /// Maximum concave lens pinch strength. Forwarded to [AnimatedGlassIndicator].
  ///
  /// Defaults to `0.4` — the iOS 26-calibrated gentle concave lens warp, matching
  /// [GlassTabBar] for a consistent feel across all
  /// interactive indicator widgets. Set to `0.0` to disable, `1.0` to restore
  /// the original full-strength warp.
  final double indicatorPinchStrength;

  /// Expansion padding applied to the active indicator pill during interaction.
  ///
  /// The pill grows by this amount beyond its segment boundary as the user drags,
  /// creating the iOS 26 "jelly" overshoot. Defaults to
  /// `EdgeInsets.symmetric(horizontal: 12, vertical: 8)` matching
  /// [GlassTabBar].
  final EdgeInsetsGeometry indicatorExpansion;

  // ===========================================================================
  // Glass Effect Properties
  // ===========================================================================

  /// Glass effect settings (only used when [useOwnLayer] is true).
  ///
  /// If null when [useOwnLayer] is true, uses optimized defaults:
  /// - thickness: 30
  /// - blur: 3
  /// - chromaticAberration: 0.5
  /// - lightIntensity: 2
  /// - refractiveIndex: 1.15
  final LiquidGlassSettings? settings;

  /// Whether to create its own layer or use grouped glass.
  ///
  /// - `false` (default): Uses grouped glass, must be inside [LiquidGlassLayer]
  /// - `true`: Creates own layer with [LiquidGlass.withOwnLayer]
  ///
  /// Defaults to false.
  final bool useOwnLayer;

  /// Rendering quality for the glass effect.
  ///
  /// Defaults to [GlassQuality.standard] (backdrop filter).
  final GlassQuality? quality;

  /// Optional background key for Skia/Web refraction.
  final GlobalKey? backgroundKey;

  // ── iOS 26 interaction ────────────────────────────────────────────────────

  /// Controls which iOS 26 interaction effects are active on the indicator.
  ///
  /// | Value | Glow on press/drag |
  /// |---|---|
  /// | `none` | ✗ |
  /// | `glowOnly` | ✓ |
  /// | `scaleOnly` | ✗ |
  /// | `full` *(default)* | ✓ |
  ///
  /// Set to [GlassInteractionBehavior.none] to suppress the glow entirely.
  final GlassInteractionBehavior interactionBehavior;

  /// Colour of the press/drag glow on the indicator pill.
  ///
  /// Only active when [interactionBehavior] includes glow. Defaults to a
  /// soft white (~12% opacity) — same as [GlassTextField].
  final Color? glowColor;

  /// Spread radius of the glow relative to the indicator's shorter dimension.
  ///
  /// Defaults to `1.5` (150%), matching [GlassTextField].
  final double glowRadius;

  // ===========================================================================
  // Scrollable-mode params (used only when isScrollable: true)
  // ===========================================================================

  /// External scroll controller for the scrollable variant. Scrollable
  /// mode only.
  ///
  /// Lets the host read and position the viewport — for example, keeping
  /// the selected segment at an exact screen position while the segment
  /// list is reconfigured around it (a picker changing its granularity).
  /// When null the control manages its own. Provide it from the first
  /// build; swapping between external and internal after mount is not
  /// supported.
  final ScrollController? scrollController;

  /// Where the scrollable variant keeps its selected segment. Scrollable
  /// mode only.
  ///
  /// [SegmentSelectionAlignment.minimal] (default) scrolls just enough for
  /// the selection to be visible; [SegmentSelectionAlignment.center] keeps
  /// it centered whenever the list allows — the picker behavior.
  final SegmentSelectionAlignment selectionAlignment;

  /// Duration of the re-grid morph when the segment LIST changes around a
  /// surviving selection (scrollable mode only): entering segments grow in
  /// (width, with a slight scale and fade riding it), leaving segments
  /// shrink out, and the survivors glide — anchored so the selected
  /// segment does not move on screen.
  ///
  /// Defaults to [Duration.zero] — the list snaps, and the morph is
  /// opt-in. There is no platform behavior to mirror here (native
  /// segmented controls do not scroll), so a host's control should not
  /// start animating just because the package was upgraded.
  /// Reduce Motion always snaps.
  final Duration regridDuration;

  /// What a horizontal drag means. Scrollable mode only — the fixed
  /// control always drags its indicator (`UISegmentedControl` parity).
  ///
  /// Defaults to [SegmentDragBehavior.selectIndicator] (unchanged
  /// behavior). Use [SegmentDragBehavior.scroll] for picker-style strips
  /// where a drag should navigate the list and selection is tap-only.
  final SegmentDragBehavior dragBehavior;

  /// Icon size in logical pixels. Used in scrollable mode only.
  /// Defaults to 24.0 — matching [GlassTabBar].
  final double iconSize;

  /// Horizontal padding inside each tab label cell. Scrollable mode only.
  final EdgeInsetsGeometry labelPadding;

  /// Icon color for the selected segment. Scrollable mode only.
  /// Defaults to the primary label color.
  final Color? selectedIconColor;

  /// Icon color for unselected segments. Scrollable mode only.
  /// Defaults to the secondary label color.
  final Color? unselectedIconColor;

  /// Masking quality for the dual-layer icon rendering. Scrollable mode only.
  final MaskingQuality maskingQuality;

  /// Optional divider settings between segments. Scrollable mode only.
  final DividerSettings? dividerSettings;

  /// Optional box shadows on the pill indicator. Scrollable mode only.
  final List<BoxShadow>? indicatorShadow;

  @override
  State<GlassSegmentedControl> createState() => _GlassSegmentedControlState();
}

class _GlassSegmentedControlState extends State<GlassSegmentedControl> {
  late final ScrollController _scrollController;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _ownsController = widget.scrollController == null;
  }

  @override
  void dispose() {
    if (_ownsController) _scrollController.dispose();
    super.dispose();
  }

  // Default background colors — match GlassTabBar._buildInline() exactly.
  static const _defaultLightBg = Color(0x1F000000); // black12
  static const _defaultDarkBg = Color(0x1FFFFFFF); // white12

  @override
  Widget build(BuildContext context) {
    final effectiveQuality = GlassThemeHelpers.resolveQuality(
      context,
      widgetQuality: widget.quality,
    );

    final effectiveSettings = widget.settings ??
        const LiquidGlassSettings(
          thickness: GlassDefaults.thickness,
          blur: GlassDefaults.blur,
          chromaticAberration: GlassDefaults.chromaticAberration,
          lightIntensity: GlassDefaults.lightIntensity,
          refractiveIndex: GlassDefaults.refractiveIndex,
          lightAngle: GlassDefaults.lightAngle,
        );

    // ── Scrollable mode: 100% mirrors GlassTabBar(isScrollable: true) ────────
    if (widget.isScrollable) {
      final isLight = GlassTheme.brightnessOf(context) == Brightness.light;
      final bg = widget.backgroundColor ??
          (isLight ? _defaultLightBg : _defaultDarkBg);
      final borderRadius = GlassDefaults.safeBorderRadius(widget.borderRadius);

      final content = Container(
        height: widget.height,
        // No clipBehavior: glass pill expansion must not be clipped.
        // SingleChildScrollView's own Clip.hardEdge clips scroll content.
        decoration: BoxDecoration(color: bg, borderRadius: borderRadius),
        padding: widget.padding,
        child: ScrollableSegmentContent(
          tabs: widget.segments,
          selectedIndex: widget.selectedIndex,
          onTabSelected: widget.onSegmentSelected,
          isScrollable: true,
          scrollController: _scrollController,
          selectionAlignment: widget.selectionAlignment,
          regridDuration: widget.regridDuration,
          dragBehavior: widget.dragBehavior,
          indicatorColor: widget.indicatorColor,
          selectedLabelStyle: widget.selectedTextStyle,
          unselectedLabelStyle: widget.unselectedTextStyle,
          selectedIconColor: widget.selectedIconColor,
          unselectedIconColor: widget.unselectedIconColor,
          iconSize: widget.iconSize,
          labelPadding: widget.labelPadding,
          quality: effectiveQuality,
          indicatorBorderRadius: widget.indicatorBorderRadius,
          indicatorSettings: widget.indicatorSettings,
          indicatorPinchStrength: widget.indicatorPinchStrength,
          indicatorExpansion: widget.indicatorExpansion,
          backgroundKey: widget.backgroundKey,
          maskingQuality: widget.maskingQuality,
          dividerSettings: widget.dividerSettings,
          indicatorShadow: widget.indicatorShadow,
          tabBarBorderRadius: borderRadius,
        ),
      );

      if (widget.useOwnLayer) {
        return AdaptiveLiquidGlassLayer(
          settings: effectiveSettings,
          quality: effectiveQuality,
          child: content,
        );
      }
      return content;
    }

    // ── Fixed mode: equal-width SegmentedControlContent ───────────────────────
    final backgroundColor = widget.backgroundColor ??
        (GlassTheme.brightnessOf(context) == Brightness.light
            ? CupertinoColors.black.withValues(alpha: 0.08)
            : CupertinoColors.white.withValues(alpha: 0.12));

    // SizedBox sets the height without clipping. DecoratedBox paints the
    // background without enforcing a clip — jelly expansion can overflow freely.
    final isVertical = widget.direction == Axis.vertical;
    final control = SizedBox(
      width: isVertical ? widget.height : null,
      height: isVertical
          ? (widget.segmentExtent ?? widget.height) * widget.segments.length
          : widget.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: GlassDefaults.safeBorderRadius(widget.borderRadius),
        ),
        child: Padding(
          padding: widget.padding,
          child: SegmentedControlContent(
            segments: widget.segments,
            direction: widget.direction,
            selectedIndex: widget.selectedIndex,
            onSegmentSelected: widget.onSegmentSelected,
            selectedTextStyle: widget.selectedTextStyle,
            unselectedTextStyle: widget.unselectedTextStyle,
            indicatorColor: widget.indicatorColor,
            indicatorSettings: widget.indicatorSettings,
            indicatorPinchStrength: widget.indicatorPinchStrength,
            indicatorExpansion: widget.indicatorExpansion,
            borderRadius: widget.borderRadius,
            indicatorBorderRadius: widget.indicatorBorderRadius,
            quality: effectiveQuality,
            backgroundKey: widget.backgroundKey,
            interactionBehavior: widget.interactionBehavior,
            glowColor: widget.glowColor,
            glowRadius: widget.glowRadius,
          ),
        ),
      ),
    );

    if (widget.useOwnLayer) {
      return AdaptiveLiquidGlassLayer(
        settings: effectiveSettings,
        quality: effectiveQuality,
        child: control,
      );
    }
    return control;
  }
}

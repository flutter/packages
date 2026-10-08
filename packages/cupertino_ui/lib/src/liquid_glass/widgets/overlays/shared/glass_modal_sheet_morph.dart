part of '../glass_modal_sheet.dart';

// ===========================================================================
// Liquid Morph presentation for GlassModalSheet
// ===========================================================================
//
// The second consumer of the Liquid Morph Engine (docs/LIQUID_MORPH_ENGINE.md),
// after GlassMenu. Where GlassMenu morphs a trigger button into a floating menu,
// this morphs a trigger button into a presented modal sheet: the trigger empties,
// a glass droplet detaches and inflates while travelling down the J-curve, and
// lands exactly on the sheet's resting frame. Dismissal reverses it.
//
// ─── Why the sheet is not itself Blob B ──────────────────────────────────────
//
// The teardrop "neck" is drawn by the SDF metaball shader, which only bridges
// shapes that share ONE glass layer's blend group. The real sheet owns its own
// AdaptiveGlass layer (see _SheetLayout), so it structurally cannot merge with
// the trigger ghost. The morph therefore renders its own two-blob droplet and
// hands off to the real sheet at the settled instant — when both are motionless
// and share the exact same frame, so the swap is invisible.
//
// That handoff is also why SheetMorphGeometry derives the destination from
// SheetGeometry.positionForState — the same call the sheet's own metrics use —
// instead of a parallel calculation that could drift out of agreement.

/// The widget a [GlassModalSheet] morphs out of, and the channel that empties
/// it while the morph is in flight.
///
/// Close to an opaque token: [GlassMorphTrigger] creates one, hands it to its
/// builder, and disposes it; callers pass it straight to [GlassModalSheet.show]
/// as `morphFrom` and never touch it otherwise. All it reports back is
/// [isPresenting], for chrome that has to know whether the trigger it drew is
/// currently standing in for a sheet. The constructor is private so one cannot
/// be made by hand — an anchor with no trigger behind it has nothing to empty.
///
/// ## Why a token rather than a bare [GlobalKey]
///
/// A key can only *locate* the trigger. Reading its rect is enough to aim the
/// morph, but not to make the trigger look like it empties — and a trigger that
/// stays painted while a glass droplet inflates on top of it reads as a
/// duplicated button, not a morph. Nothing in Flutter lets one widget hide
/// another it does not own, so the trigger has to cooperate: [GlassMorphTrigger]
/// owns the key *and* the opacity, and this token is how the presented sheet
/// reaches back to it.
///
/// `GlassMenu` does the same thing internally with its own trigger; this is that
/// arrangement made available to a trigger the sheet does not own.
class GlassMorphAnchor {
  GlassMorphAnchor._();

  /// Identifies the trigger's subtree so its global rect can be resolved at
  /// `show()` time.
  final GlobalKey _key = GlobalKey();

  /// Broadcasts state changes to the owning [GlassMorphTrigger].
  ///
  /// Held rather than inherited so this type stays a plain token: extending
  /// [ChangeNotifier] would put `addListener` and `dispose` on the public
  /// surface, and a caller disposing their own anchor would strand the morph.
  final _AnchorNotifier _notifier = _AnchorNotifier();

  bool _emptied = false;
  _MorphHandback? _handback;
  bool _disposed = false;

  /// Whether the trigger is currently emptied for a presented sheet.
  ///
  /// True from the frame the sheet's morph starts until the droplet is caught
  /// on dismissal — or, if the route is torn down without the closing morph,
  /// until the trigger is restored. What the pinned chrome reads to keep a
  /// hoisted capsule through the sheet presented out of it.
  bool get isPresenting => _emptied;

  /// Notifies when [isPresenting] changes.
  ///
  /// Deferred past a build in progress exactly as the owning trigger is
  /// notified, so a listener may rebuild from it.
  Listenable get presentationChanges => _notifier;

  /// The trigger's rect in global coordinates, or null when it is not currently
  /// laid out.
  Rect? get _rect {
    final renderObject = _key.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;
    return renderObject.localToGlobal(Offset.zero) & renderObject.size;
  }

  /// Hides the trigger so the morph's anchor blob can stand in for it.
  void _empty() {
    if (_disposed) return;
    _handback = null;
    if (_emptied) return;
    _emptied = true;
    _notify();
  }

  /// Hands the trigger back at the moment the droplet is caught, passing the
  /// spring's live state so the trigger can carry the bounce the rest of the
  /// way itself.
  ///
  /// The presented route is torn down as soon as the droplet lands — otherwise
  /// its modal barrier would keep swallowing taps on a button that is visibly
  /// back — so the tail of the bounce cannot be driven from there. [travel] is
  /// the trigger-centre → sheet-centre vector the droplet came home along;
  /// [value] and [velocity] are the closing spring's state at the catch, so the
  /// trigger's own simulation continues it without a seam.
  void _handBack({
    required Offset travel,
    required double value,
    required double velocity,
  }) {
    if (_disposed || !_emptied) return;
    _emptied = false;
    _handback = _MorphHandback(travel, value, velocity);
    _notify();
  }

  /// Restores the trigger with no bounce.
  ///
  /// The safety net for a route torn down without the closing morph ever
  /// running — a Navigator reset, a hot restart. Leaving the trigger emptied
  /// would erase a live button.
  void _restore() {
    if (_disposed || !_emptied) return;
    _emptied = false;
    _handback = null;
    _notify();
  }

  void _dispose() {
    _disposed = true;
    _notifier.dispose();
  }

  /// Notifies the trigger without ever marking it dirty mid-build.
  ///
  /// The presenter drives this from its own lifecycle — `didChangeDependencies`
  /// on the way in, `dispose` on the way out — both of which run while the tree
  /// is being built or is locked, where `setState` on the listening trigger is
  /// illegal. Deferring to the end of the frame in those phases costs the
  /// trigger one frame, during which the droplet is still exactly on top of it,
  /// so nothing shows.
  void _notify() {
    final binding = WidgetsBinding.instance;
    final phase = binding.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks) {
      binding.addPostFrameCallback((_) {
        if (!_disposed) _notifier.notify();
      });
      return;
    }
    _notifier.notify();
  }
}

/// Minimal [ChangeNotifier] subclass exposing [notifyListeners] as [notify], so
/// [GlassMorphAnchor] can hold one instead of being one.
///
/// Mirrors `_ProgressNotifier` in `glass_modal_sheet_state.dart`.
class _AnchorNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

/// The closing spring's state at the instant the trigger catches the droplet.
class _MorphHandback {
  const _MorphHandback(this.travel, this.value, this.velocity);

  /// Trigger centre → sheet centre. The bounce is along this vector.
  final Offset travel;

  /// Spring position at the catch — near zero, heading into the undershoot.
  final double value;

  /// Spring velocity at the catch, so the trigger's simulation continues it.
  final double velocity;
}

/// Wraps the widget a [GlassModalSheet] morphs out of, so the trigger can empty
/// itself while the morph runs and take the hit when the droplet comes home.
///
/// The builder receives a [GlassMorphAnchor] to pass to
/// [GlassModalSheet.show] as `morphFrom`:
///
/// ```dart
/// GlassMorphTrigger(
///   builder: (context, anchor) => GlassButton(
///     onTap: () => GlassModalSheet.show(
///       context: context,
///       morphFrom: anchor,
///       builder: (context) => const MySheetBody(),
///     ),
///     child: const Icon(CupertinoIcons.add),
///   ),
/// )
/// ```
///
/// While the sheet is presented the child paints nothing — the morph's anchor
/// blob stands in for it, so the two never appear at once. When the droplet
/// lands, the child is restored and *this widget* runs the rest of the closing
/// bounce on its own ticker, so it keeps easing home after the presented route
/// is gone. The button is tappable throughout that tail, exactly as `GlassMenu`'s
/// trigger is: grabbing it cancels the bounce and opens again.
///
/// Without this wrapper `GlassModalSheet.show` still morphs (pass
/// `morphFromRect`), but it blooms from a point instead of stretching a
/// teardrop, because the anchor blob would otherwise duplicate a trigger it
/// cannot hide.
class GlassMorphTrigger extends StatefulWidget {
  /// Creates a new [GlassMorphTrigger].
  const GlassMorphTrigger({super.key, required this.builder});

  /// Builds the trigger, given the [GlassMorphAnchor] to present with.
  final Widget Function(BuildContext context, GlassMorphAnchor anchor) builder;

  @override
  State<GlassMorphTrigger> createState() => _GlassMorphTriggerState();
}

class _GlassMorphTriggerState extends State<GlassMorphTrigger>
    with SingleTickerProviderStateMixin {
  final GlassMorphAnchor _anchor = GlassMorphAnchor._();

  /// Drives the tail of the closing bounce, after the presented route — and the
  /// controller that started the spring — has been torn down.
  late final AnimationController _bounce =
      AnimationController.unbounded(vsync: this);

  /// Built once, not per build: [AnimatedBuilder] compares listenables by
  /// identity, so merging inline would resubscribe on every rebuild.
  late final Listenable _repaint =
      Listenable.merge([_anchor._notifier, _bounce]);

  /// Vector the current bounce swings along; zero when nothing is bouncing.
  Offset _travel = Offset.zero;

  @override
  void initState() {
    super.initState();
    _anchor._notifier.addListener(_onAnchorChanged);
  }

  @override
  void dispose() {
    _anchor._notifier.removeListener(_onAnchorChanged);
    _anchor._dispose();
    _bounce.dispose();
    super.dispose();
  }

  void _onAnchorChanged() {
    if (!mounted) return;
    final handback = _anchor._handback;
    if (_anchor._emptied ||
        handback == null ||
        handback.travel == Offset.zero) {
      // A fresh open cancels any bounce still running — including one the user
      // interrupted by tapping the button mid-swing — and so does a plain
      // restore, which carries no momentum to continue.
      _bounce.stop();
      if (_travel != Offset.zero) setState(() => _travel = Offset.zero);
      return;
    }

    // Continue the closing spring from exactly where the presenter left it, so
    // the catch has no seam. The tail always runs the native-parity profile;
    // across the speed profiles this is a sub-pixel difference over a bounce
    // this small, and it keeps the trigger from having to know the speed.
    setState(() => _travel = handback.travel);
    _bounce.animateWith(
      SpringSimulation(
        LiquidMorphPhysics.closeSpring,
        handback.value,
        0.0,
        handback.velocity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _repaint,
      // The consumer's trigger is built here, not inside the builder below, so
      // the bounce repaints it without rebuilding their subtree every frame.
      child: KeyedSubtree(
        key: _anchor._key,
        child: widget.builder(context, _anchor),
      ),
      builder: (context, child) {
        // Opacity is toggled between 0 and 1 outright, never animated: a glass
        // surface's backdrop pass renders fully or not at all, so a partial
        // fade pops. The morph's anchor blob covers the visual transition.
        final emptied = _anchor._emptied;
        return Transform.translate(
          offset: _travel * _bounce.value,
          child: Opacity(
            opacity: emptied ? 0.0 : 1.0,
            child: IgnorePointer(ignoring: emptied, child: child),
          ),
        );
      },
    );
  }
}

/// Pure geometry for presenting a [GlassModalSheet] with a liquid morph.
///
/// Stateless and free of `BuildContext`, so every value the morph renders can
/// be unit-tested without a widget tree — the same contract
/// [LiquidMorphPhysics] follows.
///
/// [LiquidMorphPhysics] answers *how far along* the morph is; this answers
/// *where the sheet actually sits*, so the droplet can be aimed at it.
class SheetMorphGeometry {
  // Pure utility class — no instances.
  const SheetMorphGeometry._();

  /// The frame the sheet comes to rest in for [state], in global coordinates.
  ///
  /// Mirrors the resting output of the sheet's own per-frame metrics (see
  /// `_calculateMetrics` in `glass_modal_sheet_state.dart`) for the case that
  /// matters here: no drag in flight, no frozen pivot, no interaction pulse.
  /// The vertical position comes from [SheetGeometry.positionForState] rather
  /// than a re-derivation, so the droplet and the sheet cannot disagree about
  /// where the sheet is.
  ///
  /// The sheet's top edge is always `(1 - pos) * screenSize.height`; only the
  /// horizontal inset and the bottom overhang differ per detent:
  ///
  ///   • [GlassSheetState.full] — edge to edge, sunk past the bottom by
  ///     [bottomInset] + [bottomRadius] so its lower corners leave the screen.
  ///   • [GlassSheetState.half] — inset by [horizontalMargin] / [bottomMargin].
  ///   • [GlassSheetState.peek] — inset by the `peek*` overrides, falling back
  ///     to the base margins; [peekWidth] centres a fixed-width floor.
  ///   • [GlassSheetState.hidden] — collapses to a zero-height line at the
  ///     bottom edge; never a morph destination, but kept total for callers.
  ///
  /// [stripPlacement] is the sheet's placement in iPhone Duo's vertical bar
  /// strip layout, and null elsewhere. There the large detent keeps its
  /// margins, and in a [regularWidth] every detent is a card placed as the
  /// sheet places itself.
  static Rect restingRect({
    required GlassSheetState state,
    required SheetGeometry geometry,
    required Size screenSize,
    required double horizontalMargin,
    required double bottomMargin,
    required double bottomInset,
    required double bottomRadius,
    double? peekHorizontalMargin,
    double? peekBottomMargin,
    double? peekWidth,
    GlassSheetPlacement? stripPlacement,
    bool regularWidth = false,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    final pos = geometry.positionForState(state, screenHeight);

    // Every detent parks its top edge at the same place: the visual height is
    // measured down from the top, so `bottom`/`height` only redistribute the
    // remainder below it.
    final top = (1.0 - pos) * screenHeight;

    late final double hPad;
    late final double bottom;

    switch (state) {
      case GlassSheetState.full:
        // Expanded: margins are gone and the sheet sinks by `extraHeight` so
        // its bottom corners run off screen instead of floating.
        hPad = stripPlacement == null ? 0.0 : horizontalMargin;
        bottom = -(bottomInset + bottomRadius);
        break;
      case GlassSheetState.peek:
        hPad = _peekHorizontalPad(
          screenWidth: screenWidth,
          horizontalMargin: horizontalMargin,
          peekHorizontalMargin: peekHorizontalMargin,
          peekWidth: peekWidth,
        );
        bottom = peekBottomMargin ?? bottomMargin;
        break;
      case GlassSheetState.half:
      case GlassSheetState.hidden:
        hPad = horizontalMargin;
        bottom = bottomMargin;
        break;
    }

    // A sheet narrower than its own margins (tiny test surfaces, extreme
    // margins) would invert the rect; clamp so the frame stays well-formed.
    final safeHPad = hPad.clamp(0.0, screenWidth / 2.0);
    final insets = stripPlacement == null
        ? EdgeInsets.symmetric(horizontal: safeHPad)
        : _stripSheetInsets(
            screenSize: screenSize,
            regularWidth: regularWidth,
            margin: safeHPad,
            placement: stripPlacement,
            textDirection: textDirection,
          );
    return Rect.fromLTRB(
      insets.left,
      top,
      screenWidth - insets.right,
      math.max(top, screenHeight - bottom),
    );
  }

  /// Horizontal inset of the peek floor.
  ///
  /// [peekWidth] wins when set — a fixed-width floor is centred rather than
  /// inset — matching the sheet's own peek resolution.
  static double _peekHorizontalPad({
    required double screenWidth,
    required double horizontalMargin,
    double? peekHorizontalMargin,
    double? peekWidth,
  }) {
    if (peekWidth != null) {
      return ((screenWidth - peekWidth) / 2.0).clamp(0.0, screenWidth / 2.0);
    }
    return peekHorizontalMargin ?? horizontalMargin;
  }

  /// Rate the swipe-to-dismiss shrink loses scale, per unit of the *card's own
  /// height* dragged.
  ///
  /// Fitted (with the knee and [minDismissScale]) to an iOS 26 gesture whose
  /// finger position was cursor-tracked through iPhone Mirroring, to an RMS
  /// scale error of 0.006. Card height, not screen height, is the normaliser:
  /// Maps' small "Map Modes" panel measures ~2.5x per screen height and a
  /// medium sheet ~1.4x, but one card-relative gain explains both. A gain
  /// below 1.0 per card height is also what lets the shrink pivot at the
  /// grabbed point without lifting the card's bottom edge into view
  /// ([dismissedRect]).
  static const double dismissScaleGain = 0.64;

  /// Size the shrink asymptotes toward, and never reaches.
  ///
  /// Past the knee the travel rubber-bands toward this floor, so a long swipe
  /// stops making the card meaningfully smaller but never freezes outright —
  /// the reference gesture parked at ~0.55 and was still creeping.
  static const double minDismissScale = 0.33;

  /// The detent a swipe-to-dismiss drag falls away from.
  ///
  /// Mirrors the pivot `_calculateMetrics` drags from: the peek floor when
  /// there is one, otherwise the lowest enabled visible detent.
  ///
  /// Deliberately *not* [SheetGeometry.minState], which is
  /// [GlassSheetState.hidden] for the common dismissible peek-less sheet —
  /// hidden is the position a swipe drags the sheet *to*, and measuring travel
  /// from it would read every drag as zero.
  static GlassSheetState dismissPivotState(SheetGeometry geometry) =>
      geometry.orderedStates.firstWhere(
        (state) => state != GlassSheetState.hidden,
      );

  /// How far the sheet has been dragged below its lowest detent, as a fraction
  /// of screen height.
  ///
  /// The sheet's position is already a screen-height fraction, so the drag
  /// distance is simply the gap between the two — no gesture plumbing needed,
  /// and a drag that never leaves the detent reads as zero.
  static double dismissTravel({
    required double position,
    required double minPosition,
  }) =>
      (minPosition - position).clamp(0.0, 1.0);

  /// The travel the sheet actually renders at, given what the finger did.
  ///
  /// In and out in screen-height fractions (the sheet position's unit); the
  /// damping itself works in card heights via [cardFraction], the unit the
  /// native curve is expressed in. Direct manipulation up to the knee, then
  /// rubber-banded so a long drag parks the card instead of sliding it off
  /// screen. Both the shrink and the fall read off this, so size and position
  /// settle as one object — while the sheet's own position keeps tracking 1:1
  /// underneath, leaving the dismiss threshold unaffected.
  static double dampedDismissTravel(
    double travel, {
    required double cardFraction,
  }) {
    if (cardFraction <= 0.0) return 0.0;
    final raw = (travel / cardFraction).clamp(0.0, _maxDismissTravel * 4);
    final damped = raw <= _dismissTravelKnee
        ? raw
        : _dismissTravelKnee +
            rubberBand(
              raw - _dismissTravelKnee,
              limit: _maxDismissTravel - _dismissTravelKnee,
            );
    return damped * cardFraction;
  }

  /// Uniform scale the sheet wears [travel] into a swipe-to-dismiss.
  ///
  /// Strictly linear in [dampedDismissTravel] — all of the easing lives in the
  /// travel, so there is exactly one curve to reason about and the shrink can
  /// never disagree with the fall. [cardFraction] is the card's height as a
  /// fraction of the screen's, the normaliser the whole curve works in.
  static double dismissScale(double travel, {required double cardFraction}) {
    if (cardFraction <= 0.0) return 1.0;
    return 1.0 -
        dismissScaleGain *
            (dampedDismissTravel(travel, cardFraction: cardFraction) /
                cardFraction);
  }

  /// Travel at which the fall stops being 1:1 and starts easing, as a fraction
  /// of the card's height.
  ///
  /// Fitted together with [dismissScaleGain] and [minDismissScale] over the
  /// cursor-tracked reference gesture. Below the knee the response is
  /// untouched, so every ordinary swipe is pure direct manipulation.
  static const double _dismissTravelKnee = 0.48;

  /// Travel the ease asymptotes toward (in card heights), derived so the card
  /// lands on [minDismissScale] rather than being tuned separately.
  static const double _maxDismissTravel =
      (1.0 - minDismissScale) / dismissScaleGain;

  /// iOS's rubber-band curve: direct at first, asymptotically stiffer.
  ///
  /// `f(x) = (1 - 1/(x·tension/limit + 1))·limit` — the platform's over-scroll
  /// shape, and the progressive sibling of [SheetGeometry.applyResistance],
  /// whose flat multiplier cannot express "free at first, heavier further on".
  /// [tension] is the slope at the origin (1.0 = direct manipulation at first;
  /// iOS's over-scroll 0.55 would read as lag here, where the finger has not
  /// hit a wall yet). The result never passes [limit].
  static double rubberBand(
    double offset, {
    required double limit,
    double tension = 1.0,
  }) {
    if (limit <= 0.0) return 0.0;
    final magnitude = offset.abs();
    final damped = (1.0 - 1.0 / (magnitude * tension / limit + 1.0)) * limit;
    return offset.isNegative ? -damped : damped;
  }

  /// The sideways offset the chase spring is targeted with, given the finger's
  /// raw offset.
  ///
  /// Free until the card's leading edge reaches the screen edge, then pinned
  /// there with a few points of give — natively the largest overshoot measured
  /// was ~4 pt on a 440 pt screen. Resistance is a function of *where the card
  /// is* ([cardRect]), not of finger displacement: pushing toward open room is
  /// free for the whole distance, pushing into an edge resists at once.
  /// Damping the displacement instead makes every drag equally gummy
  /// regardless of the room available, which reads as lag.
  static double horizontalOffsetFor({
    required double rawOffset,
    required Rect cardRect,
    required double screenWidth,
  }) {
    // Room before the card's leading edge meets the screen's.
    final slack = rawOffset.isNegative
        ? math.max(0.0, cardRect.left)
        : math.max(0.0, screenWidth - cardRect.right);
    final magnitude = rawOffset.abs();
    if (magnitude <= slack) return rawOffset;

    final past = rubberBand(magnitude - slack, limit: screenWidth * 0.04);
    final damped = slack + past;
    return rawOffset.isNegative ? -damped : damped;
  }

  /// The frame a sheet occupies mid-swipe, in global coordinates — the morph's
  /// destination when a swipe is what closed the sheet.
  ///
  /// [restingRect] is carried down by the damped fall and shrunk about the
  /// pivot.
  ///
  /// [scaleAnchor] supplies that pivot: the grabbed point, expressed in the
  /// *resting* card's frame (the live finger position minus the raw fall).
  /// Carried down with the fall, it keeps the grabbed content exactly under
  /// the finger below the damping knee — the direct-manipulation feel of the
  /// native gesture. Omit it and the sheet shrinks about its own centre.
  ///
  /// [horizontalOffset] only translates, never feeding the scale — measured
  /// off iOS 26, where a 143 pt sideways sweep changed the card's scale by
  /// just 0.029, all attributable to incidental vertical drift.
  ///
  /// The card's bottom edge cannot lift into view under this pivot while
  /// [dismissScaleGain] stays below 1.0 per card height, because the fall
  /// always outruns the shrink; the closing clamp guards that invariant
  /// against a future retune.
  static Rect dismissedRect({
    required Rect restingRect,
    required double travel,
    required double screenHeight,
    double horizontalOffset = 0.0,
    Offset? scaleAnchor,
  }) {
    final cardFraction =
        screenHeight <= 0.0 ? 0.0 : restingRect.height / screenHeight;
    final fall = Offset(
      0.0,
      dampedDismissTravel(travel, cardFraction: cardFraction) * screenHeight,
    );
    final fallen = restingRect.shift(fall);
    final scale = dismissScale(travel, cardFraction: cardFraction);
    final pivot = scaleAnchor == null
        ? fallen.center
        : scaleAnchor.translate(0.0, fall.dy);

    final scaled = Rect.fromLTRB(
      pivot.dx + (fallen.left - pivot.dx) * scale,
      pivot.dy + (fallen.top - pivot.dy) * scale,
      pivot.dx + (fallen.right - pivot.dx) * scale,
      pivot.dy + (fallen.bottom - pivot.dy) * scale,
    );
    // Invariant guard — see the doc comment. Never active at the shipped gain.
    final lift = restingRect.bottom - scaled.bottom;
    final grounded = lift > 0.0 ? scaled.shift(Offset(0.0, lift)) : scaled;

    return grounded.shift(Offset(horizontalOffset, 0.0));
  }

  /// The frame of the travelling droplet (Blob B) for one morph frame.
  ///
  /// Size follows [LiquidMorphState.sizeT] and position follows
  /// [LiquidMorphState.pathT]; keeping them on separate curves is what opens
  /// the gap the metaball neck stretches across.
  ///
  /// Center displacement is driven by [sizeT] with anchor-drift clamped to at
  /// most 8 px (`rawAnchorDrift.clamp(-8, 8)`), pinning the base of the expanding
  /// blob to the trigger button during flight. This achieves [GlassMenu]'s
  /// cohesive "one animated blob" feel that grows and shrinks smoothly.
  ///
  /// On close undershoot (`sizeT <= 0.0`), the droplet squeezes relative to
  /// the trigger's own dimensions rather than subtracting destination delta,
  /// preventing 0 px collapse.
  static Rect blobRect({
    required Rect trigger,
    required Rect destination,
    required double pathT,
    required double sizeT,
    double scaleDelta = 1.0,
    bool isClosing = false,
    double travelDx = 0.0,
    double travelDy = 0.0,
  }) {
    final double width;
    final double height;

    if (sizeT <= 0.0) {
      // Close undershoot bounce: droplet is at the trigger, squeeze relative
      // to the trigger's own dimensions — never subtract destination delta!
      // Subtracting an 852 px destination delta with negative sizeT would collapse
      // the container to 0 px and cause it to vanish from the screen.
      final squeeze = (1.0 + sizeT * 0.25).clamp(0.5, 1.0);
      width = trigger.width * squeeze;
      height = trigger.height * squeeze;
    } else {
      // Continuous fluid expansion: droplet expands smoothly and continuously
      // from the trigger into the destination bounds. Combined with the
      // anchor-drift clamping below, the base of the droplet stays rooted at
      // the trigger while inflating outward and upward — achieving GlassMenu's
      // cohesive "one animated blob" feel without artificial elongation artifacts.
      width =
          lerpDouble(trigger.width, destination.width, sizeT)!.clamp(0.0, 1e6);
      height = lerpDouble(trigger.height, destination.height, sizeT)!
          .clamp(0.0, 1e6);
    }

    // Anchor-drift clamping (parity with GlassMenu):
    // For large menus and sheets, clamp the anchor edge displacement so the
    // blob's pinned edge never drifts more than 8 px from the trigger button
    // during flight. By driving center displacement by sizeT (with clamped
    // J-curve drift), the blob's edges stay rooted at the trigger while it grows
    // outward — matching GlassMenu's unified-blob feel rather than a detached
    // flying droplet.
    const double maxAnchorDrift = 8.0;
    final double finalDx = destination.center.dx - trigger.center.dx;
    final double finalDy = destination.center.dy - trigger.center.dy;

    final double rawAnchorDriftX = finalDx * (pathT - sizeT);
    final double anchorDriftX =
        rawAnchorDriftX.clamp(-maxAnchorDrift, maxAnchorDrift);
    final double effectiveDx = finalDx * sizeT + anchorDriftX;

    final double rawAnchorDriftY = finalDy * (pathT - sizeT);
    final double anchorDriftY =
        rawAnchorDriftY.clamp(-maxAnchorDrift, maxAnchorDrift);
    final double effectiveDy = finalDy * sizeT + anchorDriftY;

    final double centerX = trigger.center.dx + effectiveDx;
    final double centerY = trigger.center.dy + effectiveDy;

    return Rect.fromLTWH(
      centerX - width / 2.0,
      centerY - height / 2.0,
      width,
      height,
    );
  }

  /// Corner radius of the droplet as it inflates from [trigger] into the sheet.
  ///
  /// Starts fully rounded (a pill/circle the size of the trigger) and holds
  /// the droplet round through early travel (sizeT <= 0.35). As the droplet
  /// expands and settles into the sheet, the radius smoothly relaxes into
  /// [target] with an easeInOut curve — giving a silky liquid unfolding rather
  /// than a harsh last-frame snap.
  static double blobRadius({
    required Size blobSize,
    required double target,
    required double sizeT,
  }) {
    final maxRadius = math.min(blobSize.width, blobSize.height) / 2.0;
    final double s = sizeT.clamp(0.0, 1.0);
    if (s <= 0.35) return maxRadius;
    final p = (s - 0.35) / 0.65;
    final t = Curves.easeInOutCubic.transform(p);
    return lerpDouble(maxRadius, math.min(target, maxRadius), t)!;
  }

  /// Opacity of the droplet's solid fill, ramping in over the last 30 % of the
  /// size curve so the glass droplet has already arrived before it takes on the
  /// sheet's opaque surface.
  ///
  /// Fading the *fill* is safe; fading the glass itself is not — a shader
  /// backdrop pass renders fully or not at all, so an animated `Opacity` over
  /// it pops. The droplet's glass therefore stays at full strength for the
  /// whole morph and only this plain colour layer crossfades.
  static double fillReveal(double sizeT) =>
      ((sizeT - 0.7) / 0.3).clamp(0.0, 1.0);

  /// Opacity the sheet's solid fill rests at in [state].
  ///
  /// Mirrors the fill branches of `_calculateMetrics` at rest so the droplet
  /// lands wearing the surface the sheet is about to show: a glass half detent
  /// hands off to glass, an opaque full detent hands off to opaque colour.
  /// Returning the wrong value here would show as a one-frame flash at the
  /// handoff, which is exactly what the unit tests pin down.
  static double restingFillOpacity({
    required GlassSheetState state,
    required LiquidGlassSettings baseSettings,
    required bool enablePeek,
    LiquidGlassSettings? peekSettings,
    LiquidGlassSettings? halfSettings,
    LiquidGlassSettings? fullSettings,
  }) {
    final sPeek = peekSettings ?? baseSettings;
    final sHalf = halfSettings ?? baseSettings;
    final sFull = fullSettings ?? baseSettings;

    switch (state) {
      case GlassSheetState.full:
        // t == 1: the crossfade is complete whichever route got us here, so
        // only the explicit full-state settings can keep the surface glassy.
        if (fullSettings == null) return 1.0;
        return _fillFor(from: sHalf, to: sFull, t: 1.0);
      case GlassSheetState.half:
        // t == 0: the half→full crossfade hasn't started. Without explicit
        // full settings the sheet is opaque only when its own surface has no
        // blur to show through.
        if (fullSettings == null) {
          return (sHalf.blur == 0 || baseSettings.blur == 0) ? 1.0 : 0.0;
        }
        return _fillFor(from: sHalf, to: sFull, t: 0.0);
      case GlassSheetState.peek:
        if (!enablePeek) return sHalf.blur == 0 ? 1.0 : 0.0;
        return _fillFor(from: sPeek, to: sHalf, t: 0.0);
      case GlassSheetState.hidden:
        return 0.0;
    }
  }

  /// Resolves the fill opacity for a crossfade between two surfaces at [t].
  ///
  /// A surface with `blur == 0` is a solid colour, so the fill is whichever
  /// side of the crossfade is currently solid.
  static double _fillFor({
    required LiquidGlassSettings from,
    required LiquidGlassSettings to,
    required double t,
  }) {
    if (from.blur > 0 && to.blur == 0) return t;
    if (from.blur == 0 && to.blur > 0) return 1.0 - t;
    if (from.blur == 0 && to.blur == 0) return 1.0;
    return 0.0;
  }

  /// The glass settings the sheet rests on in [state], before the solid fill is
  /// composited over them. Mirrors the settings interpolation in
  /// `_calculateMetrics` at rest.
  static LiquidGlassSettings restingSettings({
    required GlassSheetState state,
    required LiquidGlassSettings baseSettings,
    required bool enablePeek,
    LiquidGlassSettings? peekSettings,
    LiquidGlassSettings? halfSettings,
    LiquidGlassSettings? fullSettings,
  }) {
    switch (state) {
      case GlassSheetState.full:
        return fullSettings ?? baseSettings;
      case GlassSheetState.peek:
        if (!enablePeek) return halfSettings ?? baseSettings;
        return peekSettings ?? baseSettings;
      case GlassSheetState.half:
      case GlassSheetState.hidden:
        return halfSettings ?? baseSettings;
    }
  }
}

/// Drives the liquid morph that presents [child] (a [GlassModalSheetScaffold]).
///
/// Owns a [GlassMorphController] and renders the two-blob droplet while the
/// morph is in flight, swapping to the real sheet at the settled instant.
///
/// The route's own animation is used only as a *signal* — its reverse status
/// starts the closing morph — never as the morph's clock. Mapping the engine
/// onto a linear route animation would discard the J-curve and the underdamped
/// catch, which are the whole effect.
///
/// Inserted by [GlassModalSheet.show] when a trigger is supplied; it is not
/// part of the package's public surface, but is left constructible so the morph
/// can be driven directly in tests (headless test runs report no Impeller, so
/// `show()` itself always takes the slide fallback there).
class GlassSheetMorphPresenter extends StatefulWidget {
  /// Creates a new [GlassSheetMorphPresenter].
  const GlassSheetMorphPresenter({
    super.key,
    required this.routeAnimation,
    required this.triggerRect,
    required this.anchor,
    required this.speed,
    required this.restingState,
    required this.controller,
    required this.geometry,
    required this.horizontalMargin,
    required this.bottomMargin,
    required this.topBorderRadius,
    required this.fullTopBorderRadius,
    required this.bottomBorderRadius,
    required this.fullBottomBorderRadius,
    required this.settings,
    required this.peekSettings,
    required this.halfSettings,
    required this.fullSettings,
    required this.expandedColor,
    required this.quality,
    required this.peekHorizontalMargin,
    required this.peekBottomMargin,
    required this.peekWidth,
    required this.peekTopBorderRadius,
    required this.platformViewBackdrop,
    required this.child,
    this.expandedDarkColor,
    this.barrierColor,
    this.placement = GlassSheetPlacement.automatic,
  });

  /// The presenting route's animation. Watched for [AnimationStatus.reverse]
  /// so the closing morph starts the moment the route begins popping.
  final Animation<double> routeAnimation;

  /// Global rect of the widget the sheet morphs out of.
  final Rect triggerRect;

  /// The trigger this morph can empty, when there is one.
  ///
  /// Present: the anchor blob stands in for the hidden trigger and the teardrop
  /// neck stretches between them. Null: the trigger stays painted — so no
  /// anchor blob is drawn (it would duplicate the button) and the droplet
  /// blooms from [triggerRect]'s centre instead.
  final GlassMorphAnchor? anchor;

  /// Speed profile forwarded to the [GlassMorphController].
  final MorphSpeed speed;

  /// The detent the sheet comes to rest at — the morph's destination.
  final GlassSheetState restingState;

  /// The sheet's controller, read once at a swipe-dismissal to learn the
  /// position the finger let go at. Shared with the sheet itself, so both
  /// sides of the handoff agree on where it was.
  final GlassModalSheetController controller;

  /// Detent configuration, shared with the sheet so both resolve the same
  /// resting position.
  final SheetGeometry geometry;

  /// Sheet margins and radii, forwarded so the droplet lands on the sheet's
  /// exact frame.
  final double horizontalMargin;

  /// See [GlassModalSheet.bottomMargin].
  final double bottomMargin;

  /// See [GlassModalSheet.placement].
  final GlassSheetPlacement placement;

  /// See [GlassModalSheet.topBorderRadius].
  final double? topBorderRadius;

  /// See [GlassModalSheet.fullTopBorderRadius].
  final double? fullTopBorderRadius;

  /// See [GlassModalSheet.bottomBorderRadius].
  final double? bottomBorderRadius;

  /// See [GlassModalSheet.fullBottomBorderRadius].
  final double? fullBottomBorderRadius;

  /// See [GlassModalSheet.settings].
  final LiquidGlassSettings? settings;

  /// See [GlassModalSheet.peekSettings].
  final LiquidGlassSettings? peekSettings;

  /// See [GlassModalSheet.halfSettings].
  final LiquidGlassSettings? halfSettings;

  /// See [GlassModalSheet.fullSettings].
  final LiquidGlassSettings? fullSettings;

  /// See [GlassModalSheet.expandedColor].
  final Color? expandedColor;

  /// See [GlassModalSheet.expandedDarkColor].
  final Color? expandedDarkColor;

  /// See [GlassModalSheet.quality].
  final GlassQuality? quality;

  /// See [GlassModalSheet.peekHorizontalMargin].
  final double? peekHorizontalMargin;

  /// See [GlassModalSheet.peekBottomMargin].
  final double? peekBottomMargin;

  /// See [GlassModalSheet.peekWidth].
  final double? peekWidth;

  /// See [GlassModalSheet.peekTopBorderRadius].
  final double? peekTopBorderRadius;

  /// See [GlassModalSheet.platformViewBackdrop]. Suppresses the metaball blend
  /// group, exactly as it does in the sheet and in `GlassMenu`.
  final bool platformViewBackdrop;

  /// The real sheet. Mounted for the whole morph — never remounted at the
  /// handoff — so its glass layers and springs are already seeded when it is
  /// revealed.
  final Widget child;

  /// The colour of the modal scrim that appears behind the sheet during the
  /// morph. When non-null, the presenter drives this scrim itself via the
  /// liquid spring so it is in lockstep with the blob — identical to how
  /// [GlassMenu] has no independently-animating route barrier.
  ///
  /// Callers should pass [Colors.transparent] as `barrierColor` to their
  /// [showGeneralDialog] call and route the actual barrier colour through here
  /// instead.
  final Color? barrierColor;

  @override
  State<GlassSheetMorphPresenter> createState() =>
      _GlassSheetMorphPresenterState();
}

class _GlassSheetMorphPresenterState extends State<GlassSheetMorphPresenter>
    with TickerProviderStateMixin {
  late final GlassMorphController _morph;

  /// Latches once the droplet has landed and the real sheet has taken over.
  ///
  /// Without the latch the underdamped spring dipping back below the settle
  /// threshold would flip the sheet back to a droplet for a frame.
  bool _handedOffToSheet = false;

  /// True once the closing morph has started, so the reverse listener and the
  /// settle latch don't fight over the same transition.
  bool _isClosing = false;

  /// Guards blob A from painting before the trigger widget has hidden itself.
  ///
  /// [GlassMorphAnchor._empty] notifies the trigger via a post-frame callback
  /// when called mid-build, costing the trigger one frame before it vanishes.
  /// If blob A paints on that same frame, the two overlapping glass circles
  /// produce an additive specular — a bright white ring around the button.
  /// Setting this flag in a sibling post-frame callback guarantees blob A only
  /// appears once the trigger has painted itself invisible.
  bool _triggerHidden = false;

  /// Whether the pointer that is dismissing the sheet dragged it first.
  ///
  /// A dragged dismissal releases the sheet mid-swipe, so the morph starts
  /// from the frame it was actually wearing at the release; a barrier tap,
  /// back gesture, or controller close leaves it at rest, so those keep
  /// [SheetMorphGeometry.restingRect].
  bool _draggedSincePointerDown = false;

  /// The sheet's frame at the release that started a swipe-to-dismiss.
  ///
  /// Frozen once, at the catch, rather than tracked per frame: the sheet is
  /// already springing toward hidden by the time the droplet takes over, so
  /// reading it live would chase a sheet that is no longer the thing on
  /// screen. Null for every dismissal that leaves the sheet at rest.
  Rect? _dismissFrom;

  /// Where the active pointer went down, for the slop comparison above.
  Offset? _dragOrigin;

  /// Pointer x at the instant the swipe first crossed below the pivot detent.
  ///
  /// The sideways axis only opens once the dismissal is under way, so the
  /// offset is measured from here rather than from [_dragOrigin] — otherwise
  /// whatever horizontal wander the finger had already accumulated would snap
  /// in the moment the sheet started falling.
  double? _horizontalAnchor;

  /// Where the pointer went down, in screen coordinates.
  ///
  /// Supplies the *column* the shrink pivots on, so the spot under the touch
  /// stays under the touch horizontally. The pivot's y comes from
  /// [_lastPointer] instead — see [_restingAnchor].
  Offset? _scaleAnchor;

  /// The pointer's most recent position, updated on every move.
  ///
  /// The shrink's y-pivot derives from where the finger *is*, not where it
  /// went down — a sheet grabbed at `full` travels a long way before the
  /// dismissal starts. See [_restingAnchor].
  Offset? _lastPointer;

  /// Raw sideways finger displacement, measured from [_horizontalAnchor] —
  /// the input the chase in [_horizontalOffset] pursues, not the rendered
  /// offset.
  double _horizontalRaw = 0.0;

  /// The rendered sideways offset, chasing the damped finger offset through
  /// [_trackingSpring].
  ///
  /// iOS drives the card through a spring rather than copying the finger's x:
  /// a fast sweep visibly trails and catches up when the finger slows, a slow
  /// drag reads as 1:1 — measured off a native capture, and a signature no
  /// static curve can produce. Release retargets the same chase to zero, so a
  /// fling's momentum carries into the spring-back for free.
  ///
  /// Integrated by hand on [_horizontalTicker]: `animateWith` restarts its
  /// clock on every call, so a chase retargeted per pointer move would freeze
  /// while the finger keeps moving.
  double _horizontalOffset = 0.0;

  /// The chase's current velocity, in pixels per second.
  double _horizontalVelocity = 0.0;

  /// Where the chase is currently headed: the damped finger offset while
  /// dragging, zero after a release or when the axis closes.
  double _horizontalTarget = 0.0;

  /// The spring the chase is currently using — [_trackingSpring] while the
  /// finger drives it, [_returnSpring] on the way home.
  SpringDescription _horizontalSpringDesc = _trackingSpring;

  /// Drives the chase: one persistent ticker, started when the chase has
  /// somewhere to go and stopped when it has settled.
  late final Ticker _horizontalTicker;

  /// Elapsed time at the previous horizontal tick, for frame deltas.
  Duration _horizontalLastTick = Duration.zero;

  /// The chase spring: stiff and critically damped, so the lag is visible in
  /// a fast sweep and gone in a slow one.
  ///
  /// Sized from the native capture — ~12–24 pt of trail at a ~535 pt/s sweep.
  /// A critically damped spring tracking a ramp lags by 2·v/ω, so ω ≈ 45
  /// (stiffness ≈ 2000) lands in that window.
  static const SpringDescription _trackingSpring =
      SpringDescription(mass: 1.0, stiffness: 2000.0, damping: 89.0);

  /// The go-home spring: the sheet's own snap spring, used when the offset is
  /// released (or the axis closes) and the card returns to centre.
  static const SpringDescription _returnSpring =
      SpringDescription(mass: 1.0, stiffness: 220.0, damping: 30.0);

  /// The sheet's position notifier, once it has mounted and attached.
  ///
  /// The morph's own ticker is idle while a finger is dragging the sheet, so
  /// without this the swipe-away transform would never repaint mid-gesture.
  Listenable? _sheetProgress;

  /// Whether the last [_onSheetProgress] frame was the identity transform, so
  /// at-rest notifications — every ordinary detent drag and snap — can skip
  /// their rebuild instead of re-rendering a transform that has not changed.
  bool _wasAtRest = true;

  /// Whether the opening morph has been started. See [didChangeDependencies].
  bool _opened = false;

  /// Trigger-centre → destination-centre delta from the last build, handed to
  /// the trigger at the catch as the vector its bounce swings along.
  Offset _finalDelta = Offset.zero;

  /// Latches when the trigger has taken the bounce over, so the handoff fires
  /// exactly once per close.
  bool _handedBackToTrigger = false;

  @override
  void initState() {
    super.initState();
    _morph = GlassMorphController(vsync: this, speed: widget.speed);
    _morph.addListener(_onMorphTick);
    _horizontalTicker = createTicker(_onHorizontalTick);
    widget.routeAnimation.addStatusListener(_onRouteStatus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reduce Motion: swaps in the engine's instant spring. GlassMenu can set
    // this in didChangeDependencies and open later on a tap; a presented sheet
    // opens the moment it mounts, so the flag has to land BEFORE the spring
    // starts — otherwise the first presentation of every session animates at
    // full length with Reduce Motion on.
    _morph
        .setDisableAnimations(GlassAccessibilityData.of(context).reduceMotion);
    // The sheet mounts as this presenter's child, so it has not attached to
    // the controller yet on the first pass — bind once the frame is up, and
    // re-check on morph ticks in case the sheet's state is ever rebuilt.
    WidgetsBinding.instance.addPostFrameCallback((_) => _bindSheetProgress());
    if (!_opened) {
      _opened = true;
      // Empty the trigger before the first morph frame paints, so the button
      // and the anchor blob standing in for it are never both on screen.
      widget.anchor?._empty();
      // The anchor's _empty notification is deferred by one frame when called
      // mid-build, so the trigger widget is still visible for exactly one more
      // paint. Defer blob A by the same amount so the two never overlap.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _triggerHidden = true);
      });
      _morph.open();
    }
  }

  @override
  void dispose() {
    widget.routeAnimation.removeStatusListener(_onRouteStatus);
    _morph.removeListener(_onMorphTick);
    _morph.dispose();
    _horizontalTicker.dispose();
    _sheetProgress?.removeListener(_onSheetProgress);
    // The route can be torn down without the closing morph ever running (a
    // Navigator reset, a hot restart). Leaving the trigger emptied would erase
    // a live button, so restoring here is the safety net.
    widget.anchor?._restore();
    super.dispose();
  }

  void _bindSheetProgress() {
    if (!mounted) return;
    final progress = widget.controller.progressListenable;
    if (identical(progress, _sheetProgress)) return;
    _sheetProgress?.removeListener(_onSheetProgress);
    _sheetProgress = progress;
    _sheetProgress?.addListener(_onSheetProgress);
  }

  void _onSheetProgress() {
    if (!mounted) return;
    // The notifier fires for every sheet movement — ordinary detent drags and
    // snaps included, where the swipe transform is identity and a rebuild
    // renders nothing new. Skip those, but always paint the first at-rest
    // frame after a swipe so the transform actually returns to identity.
    final atRest = _dismissTravel() == 0.0 &&
        !_horizontalTicker.isActive &&
        _horizontalOffset.abs() < 0.05;
    if (atRest && _wasAtRest) return;
    _wasAtRest = atRest;
    setState(() {});
  }

  void _onMorphTick() {
    if (!mounted) return;
    _bindSheetProgress();
    // Hand off to the real sheet only at the settled instant, when the droplet
    // and the sheet occupy the identical frame and nothing is moving — the one
    // moment a glass surface can be swapped without a glitch frame.
    if (!_isClosing && !_handedOffToSheet && _morph.value >= 0.999) {
      _handedOffToSheet = true;
    }
    _syncTrigger();
    setState(() {});
  }

  /// Hands the trigger back at the moment the droplet is caught.
  ///
  /// [GlassMorphController.hasHandedOff] latches on the spring's first
  /// zero-crossing during a close, which is exactly when the droplet has
  /// arrived — so the real button reappears there rather than after the
  /// underdamped bounce has finished. Same latch GlassMenu hands off on.
  ///
  /// Fires once, and passes the spring's live state rather than driving the
  /// bounce frame by frame: this route is torn down moments later (its barrier
  /// would otherwise keep swallowing taps on a button that is visibly back), so
  /// the trigger continues the simulation itself from exactly here.
  void _syncTrigger() {
    final anchor = widget.anchor;
    if (anchor == null || !_isClosing || _handedBackToTrigger) return;
    if (!_morph.hasHandedOff) return;
    _handedBackToTrigger = true;
    anchor._handBack(
      travel: _finalDelta,
      value: _morph.value,
      velocity: _morph.velocity,
    );
  }

  void _onRouteStatus(AnimationStatus status) {
    if (status != AnimationStatus.reverse || _isClosing) return;
    setState(() {
      _isClosing = true;
      _handedOffToSheet = false;
      _handedBackToTrigger = false;
      // Safe to read the sheet's position here: the dismissal pops the route
      // synchronously from `_snapToState`, before the spring toward hidden has
      // ticked, so the controller still reports the release position.
      _dismissFrom = _draggedSincePointerDown ? _releaseRect() : null;
    });
    _morph.close();
  }

  /// The sheet's frame at the moment a swipe let go of it.
  ///
  /// Built from the same resting rect the droplet already aims at, shifted and
  /// shrunk by the drag — so the sheet and the droplet cannot disagree about
  /// where the sheet was, the same discipline [SheetMorphGeometry.restingRect]
  /// keeps for the resting case.
  Rect? _releaseRect() {
    if (!mounted) return null;
    final travel = _dismissTravel();
    if (travel <= 0.0) return null;
    final screenSize = MediaQuery.sizeOf(context);
    return SheetMorphGeometry.dismissedRect(
      restingRect: _pivotRect(screenSize),
      travel: travel,
      screenHeight: screenSize.height,
      horizontalOffset: _horizontalOffset,
      scaleAnchor: _restingAnchor(screenSize, travel),
    );
  }

  /// How far the sheet has been dragged below the detent a swipe falls from.
  ///
  /// Zero until the sheet has mounted and attached itself to the controller —
  /// an unattached controller has no position, and reading a missing one as
  /// 0.0 would be indistinguishable from a sheet dragged all the way to
  /// `hidden`, shrinking the sheet to the floor before it was ever touched.
  double _dismissTravel() {
    if (!mounted) return 0.0;
    final position = widget.controller._livePosition;
    if (position == null) return 0.0;
    final height = MediaQuery.sizeOf(context).height;
    return SheetMorphGeometry.dismissTravel(
      position: position,
      minPosition: widget.geometry.positionForState(
        SheetMorphGeometry.dismissPivotState(widget.geometry),
        height,
      ),
    );
  }

  /// The sheet's frame at the detent a swipe falls from.
  ///
  /// Below that detent the sheet renders at the pivot's size regardless of
  /// which detent it was opened at, so a sheet swiped away from `full` is
  /// already a half-sized (or peek-sized) card by the time it is falling.
  Rect _pivotRect(Size screenSize) => _restingRect(
        screenSize,
        state: SheetMorphGeometry.dismissPivotState(widget.geometry),
      );

  /// Layers the swipe-away scale and sideways offset over the real sheet.
  ///
  /// The transform is *derived from* [SheetMorphGeometry.dismissedRect] rather
  /// than re-stating its maths: the sheet inside [child] sits at the raw 1:1
  /// fall, the geometry says which frame it should be wearing, and the matrix
  /// is whatever uniform scale-and-translate maps one onto the other. The
  /// rendered frame and the frame a release hands to the morph therefore
  /// cannot disagree — they are the same computation.
  Widget _dragTransform(Size screenSize, Widget child) {
    final travel = _dismissTravel();
    final pivotRect = _pivotRect(screenSize);
    final cardFraction =
        screenSize.height <= 0.0 ? 0.0 : pivotRect.height / screenSize.height;
    final scale =
        SheetMorphGeometry.dismissScale(travel, cardFraction: cardFraction);

    // Where the sheet actually is: its own position tracks the finger 1:1.
    final rawFallen = pivotRect.shift(Offset(0.0, travel * screenSize.height));
    // Where it should be drawn. The sideways offset is the chase spring's live
    // value — the damping curve was applied when the spring was targeted.
    final target = SheetMorphGeometry.dismissedRect(
      restingRect: pivotRect,
      travel: travel,
      screenHeight: screenSize.height,
      horizontalOffset: _horizontalOffset,
      scaleAnchor: _restingAnchor(screenSize, travel),
    );

    // Always this same single wrapper, identity when the sheet is at rest.
    // Dropping it while idle would change the sheet's depth in the element
    // tree, and Flutter answers a depth change by tearing the subtree down and
    // rebuilding it — remounting every glass layer and re-seeding every spring
    // inside the sheet, mid-gesture. (The Stack below keeps its slot count
    // fixed for the same reason.)
    return Transform(
      transform: Matrix4.translationValues(
        target.left - rawFallen.left * scale,
        target.top - rawFallen.top * scale,
        0.0,
      )..scaleByDouble(scale, scale, 1.0, 1.0),
      // The premium renderer freezes its shader UVs under a uniform scale-down,
      // for the CupertinoSheet push-back — where the sampled page shrinks along
      // with the glass. A swipe is the other arrangement: the page behind holds
      // still, and freezing strands the surface's rim and rounded corners at
      // the size the sheet had when the drag began. Always present, so the
      // sheet's depth in the element tree never changes; only the flag moves.
      child: LiquidGlassSelfScaleScope(
        // The renderer's own threshold, not an invented one: the flag is set
        // exactly when the freeze would otherwise fire. A sheet at its detent
        // sits a hair under 1.0 (its live position lags its layout by a sub-
        // pixel), which must not read as a swipe.
        selfScaled: scale < LiquidGlassSelfScaleScope.freezeScaleThreshold,
        child: child,
      ),
    );
  }

  void _onPointerDown(PointerDownEvent event) {
    _dragOrigin = event.position;
    _scaleAnchor = event.position;
    _lastPointer = event.position;
    _draggedSincePointerDown = false;
    _horizontalAnchor = null;
    _horizontalRaw = 0.0;
    // Deliberately NOT stopping the spring: a card grabbed mid-spring-back is
    // still off centre, and zeroing the rendered offset here would snap it
    // home in one frame. Left alone, the running return spring finishes the
    // journey, and the next axis unlock re-anchors at zero anyway.
  }

  /// Points the chase at [target], keeping whatever position and velocity it
  /// currently has — the spring never jumps, it only changes its mind about
  /// where it is going. The ticker keeps running through retargets, so the
  /// chase advances every frame however often the finger moves.
  void _retargetHorizontal(double target, SpringDescription spring) {
    _horizontalTarget = target;
    _horizontalSpringDesc = spring;
    if (_horizontalTicker.isActive) return;
    if ((_horizontalOffset - target).abs() < 0.01 &&
        _horizontalVelocity.abs() < 0.01) {
      return; // already there and parked — don't wake the ticker.
    }
    _horizontalLastTick = Duration.zero;
    _horizontalTicker.start();
  }

  /// The card's frame at [travel], before any sideways offset — what the shrink
  /// leaves on screen, and the thing the edge resistance measures against.
  Rect _fallenCardRect(Size screenSize, double travel, Rect pivotRect) =>
      SheetMorphGeometry.dismissedRect(
        restingRect: pivotRect,
        travel: travel,
        screenHeight: screenSize.height,
        scaleAnchor: _restingAnchor(screenSize, travel),
      );

  void _onPointerMove(PointerMoveEvent event) {
    // Slop, not any movement at all: a tap on the dismiss barrier routinely
    // wobbles a pixel or two, and mistaking that for a drag would cost the
    // morph on the most common way of closing the sheet.
    final origin = _dragOrigin;
    if (origin == null) return;
    if (!_draggedSincePointerDown &&
        (event.position - origin).distance > kTouchSlop) {
      _draggedSincePointerDown = true;
    }
    _lastPointer = event.position;
    _trackHorizontal(event.position.dx);
  }

  /// The grabbed point, expressed in the resting card's frame — the anchor
  /// [SheetMorphGeometry.dismissedRect] pivots the shrink on.
  ///
  /// The sheet tracks the finger 1:1 all the way down, so subtracting the raw
  /// fall from the finger's live position recovers where the finger sits on
  /// the *resting* card, wherever the gesture started.
  Offset? _restingAnchor(Size screenSize, double travel) {
    final grab = _scaleAnchor;
    final pointer = _lastPointer;
    if (grab == null || pointer == null) return null;
    return Offset(grab.dx, pointer.dy - travel * screenSize.height);
  }

  /// Follows the finger sideways, but only while the sheet is actually falling.
  ///
  /// Above the pivot detent a horizontal drag belongs to the sheet's own
  /// gestures (and to whatever the content does with it); it is only once the
  /// sheet has left the detent — when it is already a shrinking card on its way
  /// out — that iOS lets it be pushed around the screen.
  void _trackHorizontal(double pointerX) {
    final travel = _dismissTravel();
    if (travel <= _horizontalUnlockTravel()) {
      if (_horizontalAnchor == null) return;
      // Back above the threshold: close the axis again and spring the sheet
      // home, rather than stranding it off to one side.
      _horizontalAnchor = null;
      _horizontalRaw = 0.0;
      _retargetHorizontal(0.0, _returnSpring);
      return;
    }
    // Anchored at the moment the axis opens, not at pointer-down, so whatever
    // sideways wander the finger did on the way here does not snap in.
    final anchor = _horizontalAnchor ??= pointerX;
    _horizontalRaw = pointerX - anchor;

    // Chase the *damped* finger offset — free through the room the card has,
    // pinned at the screen edge — through the tracking spring, which is where
    // the sideways weight comes from.
    final screenSize = MediaQuery.sizeOf(context);
    final pivotRect = _pivotRect(screenSize);
    _retargetHorizontal(
      SheetMorphGeometry.horizontalOffsetFor(
        rawOffset: _horizontalRaw,
        cardRect: _fallenCardRect(screenSize, travel, pivotRect),
        screenWidth: screenSize.width,
      ),
      _trackingSpring,
    );
  }

  /// Downward travel required before the sideways axis opens at all.
  ///
  /// Until the dismiss drag is genuinely under way, sideways movement belongs
  /// to the sheet's own jelly-follow stretch — a wobble on a resting sheet
  /// must not start sliding the card around. The bar is [kTouchSlop] worth of
  /// screen height: the distance the gesture system itself treats as "a drag
  /// has started", rather than a second, invented threshold.
  double _horizontalUnlockTravel() {
    if (!mounted) return double.infinity;
    final height = MediaQuery.sizeOf(context).height;
    return height <= 0.0 ? double.infinity : kTouchSlop / height;
  }

  void _onHorizontalTick(Duration elapsed) {
    if (!mounted) return;
    final dt = (elapsed - _horizontalLastTick).inMicroseconds /
        Duration.microsecondsPerSecond;
    _horizontalLastTick = elapsed;
    if (dt > 0.0) {
      // One closed-form spring step from the current state toward wherever
      // the target is right now.
      final sim = SpringSimulation(
        _horizontalSpringDesc,
        _horizontalOffset,
        _horizontalTarget,
        _horizontalVelocity,
      );
      _horizontalOffset = sim.x(dt);
      _horizontalVelocity = sim.dx(dt);
    }
    if ((_horizontalOffset - _horizontalTarget).abs() < 0.01 &&
        _horizontalVelocity.abs() < 0.5) {
      _horizontalOffset = _horizontalTarget;
      _horizontalVelocity = 0.0;
      _horizontalTicker.stop();
    }
    setState(() {});
  }

  void _onPointerRelease(PointerEvent event) {
    _dragOrigin = null;
    _horizontalAnchor = null;
    _horizontalRaw = 0.0;
    // A dismissal freezes the released frame in `_onRouteStatus` and the route
    // tears down moments later, so only an abandoned swipe needs the offset
    // animated away. The chase is simply retargeted home through the sheet's
    // own snap spring, keeping the position and velocity it already has — so
    // the card returns to the detent along both axes at once and a fling's
    // momentum carries into the spring-back.
    _retargetHorizontal(0.0, _returnSpring);
    // Cleared after the frame, not during it: a drag that ends in a dismissal
    // pops the route synchronously from this same pointer-up, and the flag has
    // to still be set when [_onRouteStatus] reads it. By the next frame the
    // gesture is over, so a later back gesture or controller close still
    // morphs.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _draggedSincePointerDown = false;
    });
  }

  /// The frame the sheet comes to rest in — the morph's destination whenever
  /// the sheet was not mid-swipe when it closed.
  Rect _restingRect(Size screenSize, {GlassSheetState? state}) {
    final adaptiveRadius = GlassThemeHelpers.resolveAdaptiveRadius(context);
    return SheetMorphGeometry.restingRect(
      state: state ?? widget.restingState,
      geometry: widget.geometry,
      screenSize: screenSize,
      horizontalMargin: widget.horizontalMargin,
      bottomMargin: widget.bottomMargin,
      bottomInset: MediaQuery.paddingOf(context).bottom,
      bottomRadius: widget.bottomBorderRadius ?? adaptiveRadius,
      peekHorizontalMargin: widget.peekHorizontalMargin,
      peekBottomMargin: widget.peekBottomMargin,
      peekWidth: widget.peekWidth,
      stripPlacement:
          GlassVerticalBar.maybeOf(context) == null ? null : widget.placement,
      regularWidth: VerticalBarTitleRow.regularWidth(context),
      textDirection: Directionality.of(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    final adaptiveRadius = GlassThemeHelpers.resolveAdaptiveRadius(context);
    final topRadiusBase = widget.topBorderRadius ?? adaptiveRadius;
    final bottomRadiusBase = widget.bottomBorderRadius ?? adaptiveRadius;

    // A swipe left the sheet somewhere other than its detent; every other way
    // of closing left it at rest.
    final destination = _dismissFrom ?? _restingRect(screenSize);

    // The real sheet stays mounted underneath for the whole morph so its
    // post-frame snap, glass layers and springs are already settled by the time
    // it is revealed; only painting and hit-testing are gated.
    //
    // Painting is gated by _handedOffToSheet (Visibility.visible), which is
    // the settled-open sentinel used by tests and accessibility. During the
    // morph, the content is revealed inside blob B (see _buildDroplet) so the
    // form appears to emerge from within the growing droplet — no separate
    // layer, no double glass surface.
    final Widget sheet = Visibility(
      visible: _handedOffToSheet,
      maintainState: true,
      maintainAnimation: true,
      maintainSize: true,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerRelease,
        onPointerCancel: _onPointerRelease,
        child: widget.child,
      ),
    );

    // The swipe-away transform lives here rather than in the sheet: it belongs
    // to the presentation, the way iOS hangs its interactive dismissal off the
    // zoom transition rather than off the sheet's detents (a sheet detent
    // "resizes from one edge while the other three remain fixed" — it cannot
    // express this). A sheet presented without a morph keeps the plain
    // slide-away it always had.
    final Widget draggableSheet = _dragTransform(screenSize, sheet);

    // The sheet is always slot 0 of the same Stack, whether the droplet is
    // present or not. Returning `sheet` bare at the handoff would change its
    // depth in the element tree, and Flutter answers a depth change by tearing
    // the subtree down and rebuilding it — remounting every glass layer and
    // re-seeding every spring inside the sheet, at the exact moment the morph
    // is trying to look seamless.
    //
    // The spring-driven barrier sits at slot 0. It follows _morph.value so
    // that the dim is in lockstep with the blob physics — matching GlassMenu's
    // single-unified-motion feel — rather than a decoupled linear route fade.
    final Color? barrier = widget.barrierColor;
    final double barrierT = _morph.value.clamp(0.0, 1.0);
    // Opening: easeOut → barrier rushes in with the initial blob growth, then
    // holds steady once the sheet is large. Closing: easeIn → barrier stays
    // near full opacity while the blob is still substantial, only clearing
    // quickly at the end when the blob has nearly returned to the trigger.
    // This prevents the background from "revealing too early" on dismiss.
    final Curve barrierCurve =
        _morph.isClosing ? Curves.easeIn : Curves.easeOut;
    final Widget? barrierWidget = barrier == null || barrier.a == 0.0
        ? null
        : Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(
                color: barrier.withValues(
                  alpha: barrier.a * barrierCurve.transform(barrierT),
                ),
              ),
            ),
          );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (barrierWidget != null) barrierWidget,
        draggableSheet,
        // Gate the droplet on _triggerHidden when an anchor is present.
        // On frame N the trigger widget is still at Opacity(1.0) — its _empty()
        // notification is deferred. Blob B starts at the trigger's size and
        // position (sizeT=0), so the two independent glass layers overlap and
        // their combined specular produces a bright white ring.
        // Suppressing the whole droplet for that one frame (16 ms) lets the
        // trigger paint itself invisible before any morph glass appears.
        // On close _triggerHidden is already true, so the full return journey
        // is unaffected.
        if (!_handedOffToSheet && (widget.anchor == null || _triggerHidden))
          _buildDroplet(
            context: context,
            destination: destination,
            topRadiusBase: topRadiusBase,
            bottomRadiusBase: bottomRadiusBase,
          ),
      ],
    );
  }

  Widget _buildDroplet({
    required BuildContext context,
    required Rect destination,
    required double topRadiusBase,
    required double bottomRadiusBase,
  }) {
    final trigger = widget.triggerRect;

    // The anchor blob only earns its place when the real trigger is hidden.
    // Drawn over a trigger that is still painted it reads as a duplicated
    // button rather than a morph, so without an anchor the droplet blooms from
    // the trigger's centre instead — no second button-sized shape at any point,
    // at the cost of the teardrop neck, which needs two blobs to stretch
    // between. Mirrors GlassMenu's `morphFromZero`.
    final showAnchorBlob = widget.anchor != null;
    final source = showAnchorBlob
        ? trigger
        : Rect.fromCenter(center: trigger.center, width: 0, height: 0);

    // The engine works in displacement-from-trigger-centre terms; the sheet's
    // destination is an absolute rect, so hand it the delta between centres.
    _finalDelta = destination.center - trigger.center;

    // Scale delta drives adaptive damping (J-curve amplitude) and 3-phase
    // blobRect expansion. Only relevant when a real trigger is visible;
    // morphFromZero (source = zero-size rect) has no meaningful scale ratio.
    final scaleDelta = showAnchorBlob
        ? LiquidMorphPhysics.computeScaleDelta(
            sourceSize: trigger.size,
            targetSize: destination.size,
          )
        : 1.0;

    final state = _morph.computeState(
      finalDx: _finalDelta.dx,
      finalDy: _finalDelta.dy,
      scaleDelta: scaleDelta,
    );

    final blob = SheetMorphGeometry.blobRect(
      trigger: source,
      destination: destination,
      pathT: state.pathT,
      sizeT: state.sizeT,
      scaleDelta: scaleDelta,
      isClosing: _morph.isClosing,
      travelDx: _finalDelta.dx,
      travelDy: _finalDelta.dy,
    );

    final enablePeek = widget.geometry.enablePeek;
    final baseSettings = GlassThemeHelpers.resolveSettings(
      context,
      explicit: widget.settings,
      fallback: kDefaultSheetSettings,
    );
    final dropletSettings = SheetMorphGeometry.restingSettings(
      state: widget.restingState,
      baseSettings: baseSettings,
      enablePeek: enablePeek,
      peekSettings: widget.peekSettings,
      halfSettings: widget.halfSettings,
      fullSettings: widget.fullSettings,
    );
    final fillOpacity = SheetMorphGeometry.restingFillOpacity(
          state: widget.restingState,
          baseSettings: baseSettings,
          enablePeek: enablePeek,
          peekSettings: widget.peekSettings,
          halfSettings: widget.halfSettings,
          fullSettings: widget.fullSettings,
        ) *
        SheetMorphGeometry.fillReveal(state.sizeT);

    final quality = GlassThemeHelpers.resolveQuality(
      context,
      widgetQuality: widget.quality,
      fallback: GlassQuality.premium,
    );

    final isDark = GlassTheme.brightnessOf(context) == Brightness.dark;
    final fillColor = (isDark ? widget.expandedDarkColor : null) ??
        widget.expandedColor ??
        (isDark ? const Color(0xFF1C1C1E) : CupertinoColors.white);

    // Radii the droplet resolves to: the sheet's own resting corners.
    final targetTopRadius = switch (widget.restingState) {
      GlassSheetState.full => widget.fullTopBorderRadius ?? topRadiusBase,
      GlassSheetState.peek => widget.peekTopBorderRadius ?? topRadiusBase,
      _ => topRadiusBase,
    };
    final targetBottomRadius = widget.restingState == GlassSheetState.full
        ? (widget.fullBottomBorderRadius ?? bottomRadiusBase)
        : bottomRadiusBase;

    final blobSize = blob.size;
    final topRadius = SheetMorphGeometry.blobRadius(
      blobSize: blobSize,
      target: targetTopRadius,
      sizeT: state.sizeT,
    );
    final bottomRadius = SheetMorphGeometry.blobRadius(
      blobSize: blobSize,
      target: targetBottomRadius,
      sizeT: state.sizeT,
    );

    // Blob A — the trigger ghost. Shrinks to nothing over the first 40 % of the
    // opening so the liquid bridge snaps, and grows back on close so the real
    // button "catches" the returning droplet.
    //
    // Only shown once _triggerHidden is true: the trigger's _empty notification
    // arrives one frame late, so without this guard the two glass circles
    // overlap on the first frame and their combined specular reads as a white
    // ring. On close the trigger is already hidden, so _triggerHidden stays true
    // for the whole reverse journey.
    final anchorRadius = trigger.shortestSide / 2.0;
    final Widget? blobA = !showAnchorBlob || !_triggerHidden
        ? null
        : Positioned(
            left: trigger.left + state.pushDx,
            top: trigger.top + state.pushDy,
            child: Transform.scale(
              scale: state.anchorScale,
              child: AdaptiveGlass(
                shape: LiquidRoundedRectangle(borderRadius: anchorRadius),
                settings: dropletSettings,
                quality: quality,
                platformViewBackdrop: widget.platformViewBackdrop,
                useOwnLayer: false,
                child: SizedBox(width: trigger.width, height: trigger.height),
              ),
            ),
          );

    // Blob B — the travelling body. Scaled by the engine's squeeze pulse so the
    // closing undershoot reads as a physical compression rather than a slide.
    final blobB = Positioned(
      left: blob.left,
      top: blob.top,
      child: IgnorePointer(
        child: Transform.scale(
          scale: state.containerScale,
          child: AdaptiveGlass(
            shape: LiquidVerticalRoundedSuperellipse(
              topRadius: topRadius,
              bottomRadius: bottomRadius,
            ),
            settings: dropletSettings,
            quality: quality,
            useOwnLayer: false,
            child: SizedBox(
              width: blobSize.width,
              height: blobSize.height,
              child: fillOpacity <= 0.0
                  ? null
                  : ColoredBox(
                      color: fillColor.withValues(alpha: fillOpacity),
                    ),
            ),
          ),
        ),
      ),
    );

    final Widget blobs = Stack(
      clipBehavior: Clip.none,
      children: [if (blobA != null) blobA, blobB],
    );

    // LiquidGlassBlendGroup needs the InheritedGeometryRenderLink that only a
    // full LiquidGlassLayer provides. AdaptiveLiquidGlassLayer skips that layer
    // in minimal quality and in platformViewBackdrop mode, so the blend group
    // has to be skipped in exactly those cases too (issue #214).
    final useBlendGroup =
        quality != GlassQuality.minimal && !widget.platformViewBackdrop;

    // Once the droplet has been caught, the real trigger is back on screen and
    // the droplet is standing in front of a button that is already there — two
    // shapes where there should be one. GlassMenu hides its overlay at exactly
    // this latch for the same reason; without it the last frames read as a
    // duplicated button that vanishes when the route unmounts, rather than a
    // droplet settling into the trigger.
    //
    // Toggled outright, never faded: a glass surface's backdrop pass renders
    // fully or not at all.
    final handedBack = _morph.isClosing && _morph.hasHandedOff;

    return Positioned.fill(
      child: IgnorePointer(
        child: Opacity(
          opacity: handedBack ? 0.0 : 1.0,
          child: AdaptiveLiquidGlassLayer(
            settings: dropletSettings,
            quality: quality,
            blendAmount: state.blend,
            platformViewBackdrop: widget.platformViewBackdrop,
            child: useBlendGroup
                ? LiquidGlassBlendGroup(blend: state.blend, child: blobs)
                : blobs,
          ),
        ),
      ),
    );
  }
}

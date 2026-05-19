// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Signature for `action` callback function provided to [OpenContainer.openBuilder].
///
/// Parameter `returnValue` is the value which will be provided to [OpenContainer.onClosed]
/// when `action` is called.
typedef CloseContainerActionCallback<S> = void Function({S? returnValue});

/// Signature for a function that creates a [Widget] in open state within an
/// [OpenContainer].
///
/// The `action` callback provided to [OpenContainer.openBuilder] can be used
/// to close the container.
typedef OpenContainerBuilder<S> =
    Widget Function(
      BuildContext context,
      CloseContainerActionCallback<S> action,
    );

/// Signature for a function that creates a [Widget] in closed state within an
/// [OpenContainer].
///
/// The `action` callback provided to [OpenContainer.closedBuilder] can be used
/// to open the container.
typedef CloseContainerBuilder =
    Widget Function(BuildContext context, VoidCallback action);

/// The [OpenContainer] widget's fade transition type.
///
/// This determines the type of fade transition that the incoming and outgoing
/// contents will use.
enum ContainerTransitionType {
  /// Fades the incoming element in over the outgoing element.
  fade,

  /// First fades the outgoing element out, and starts fading the incoming
  /// element in once the outgoing element has completely faded out.
  fadeThrough,
}

/// Callback function which is called when the [OpenContainer]
/// is closed.
typedef ClosedCallback<S> = void Function(S data);

/// A container that grows to fill the screen to reveal new content when tapped.
///
/// While the container is closed, it shows the [Widget] returned by
/// [closedBuilder]. When the container is tapped it grows to fill the entire
/// size of the surrounding [Navigator] while fading out the widget returned by
/// [closedBuilder] and fading in the widget returned by [openBuilder]. When the
/// container is closed again via the callback provided to [openBuilder] or via
/// Android's back button, the animation is reversed: The container shrinks back
/// to its original size while the widget returned by [openBuilder] is faded out
/// and the widget returned by [closedBuilder] is faded back in.
///
/// By default, the container is in the closed state. During the transition from
/// closed to open and vice versa the widgets returned by the [openBuilder] and
/// [closedBuilder] exist in the tree at the same time. Therefore, the widgets
/// returned by these builders cannot include the same global key.
///
/// `T` refers to the type of data returned by the route when the container
/// is closed. This value can be accessed in the `onClosed` function.
///
/// The following example shows an [OpenContainer] that transforms a blue
/// container widget into a full screen page using the Material container
/// transform animation. When the user taps the closed widget, the container
/// expands and morphs into the destination page defined in [openBuilder],
/// while the original widget from [closedBuilder] fades out during the
/// transition.
///
/// ```dart
/// OpenContainer(
///   transitionDuration: const Duration(milliseconds: 500),
///   transitionType: ContainerTransitionType.fadeThrough,
///   openBuilder: (context, action) {
///     return Scaffold(
///       appBar: AppBar(title: const Text('Details Page')),
///       body: const Center(
///         child: Text(
///           'This page opened with Container Transform animation',
///           style: TextStyle(fontSize: 18),
///           textAlign: TextAlign.center,
///         ),
///       ),
///     );
///   },
///   closedBuilder: (context, action) {
///     return Container(
///       width: 200,
///       height: 120,
///       alignment: Alignment.center,
///       decoration: BoxDecoration(
///         color: Colors.blue,
///         borderRadius: BorderRadius.circular(16),
///       ),
///       child: const Text(
///         'Open Details',
///         style: TextStyle(color: Colors.white, fontSize: 18),
///       ),
///     );
///   },
/// ),
/// ```
///
/// See also:
///
///  * [Transitions with animated containers](https://material.io/design/motion/choreography.html#transformation)
///    in the Material spec.
@optionalTypeArgs
class OpenContainer<T extends Object?> extends StatefulWidget {
  /// Creates an [OpenContainer].
  ///
  /// All arguments except for [key] must not be null. The arguments
  /// [openBuilder] and [closedBuilder] are required.
  const OpenContainer({
    super.key,
    this.closedColor = Colors.white,
    this.openColor = Colors.white,
    this.middleColor,
    this.closedElevation = 1.0,
    this.openElevation = 4.0,
    this.closedShape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
    ),
    this.openShape = const RoundedRectangleBorder(),
    this.onClosed,
    required this.closedBuilder,
    required this.openBuilder,
    this.tappable = true,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.transitionType = ContainerTransitionType.fade,
    this.useRootNavigator = false,
    this.routeSettings,
    this.clipBehavior = Clip.antiAlias,
    this.closedShadows,
    this.openShadows,
    this.transitionTag,
    this.onOpen,
  });

  /// Background color of the container while it is closed.
  ///
  /// When the container is opened, it will first transition from this color
  /// to [middleColor] and then transition from there to [openColor] in one
  /// smooth animation. When the container is closed, it will transition back to
  /// this color from [openColor] via [middleColor].
  ///
  /// Defaults to [Colors.white].
  ///
  /// See also:
  ///
  ///  * [Material.color], which is used to implement this property.
  final Color closedColor;

  /// Background color of the container while it is open.
  ///
  /// When the container is closed, it will first transition from [closedColor]
  /// to [middleColor] and then transition from there to this color in one
  /// smooth animation. When the container is closed, it will transition back to
  /// [closedColor] from this color via [middleColor].
  ///
  /// Defaults to [Colors.white].
  ///
  /// See also:
  ///
  ///  * [Material.color], which is used to implement this property.
  final Color openColor;

  /// The color to use for the background color during the transition
  /// with [ContainerTransitionType.fadeThrough].
  ///
  /// Defaults to [Theme]'s [ThemeData.canvasColor].
  ///
  /// See also:
  ///
  ///  * [Material.color], which is used to implement this property.
  final Color? middleColor;

  /// Elevation of the container while it is closed.
  ///
  /// When the container is opened, it will transition from this elevation to
  /// [openElevation]. When the container is closed, it will transition back
  /// from [openElevation] to this elevation.
  ///
  /// Defaults to 1.0.
  ///
  /// See also:
  ///
  ///  * [Material.elevation], which is used to implement this property.
  final double closedElevation;

  /// Elevation of the container while it is open.
  ///
  /// When the container is opened, it will transition to this elevation from
  /// [closedElevation]. When the container is closed, it will transition back
  /// from this elevation to [closedElevation].
  ///
  /// Defaults to 4.0.
  ///
  /// See also:
  ///
  ///  * [Material.elevation], which is used to implement this property.
  final double openElevation;

  /// Shape of the container while it is closed.
  ///
  /// When the container is opened it will transition from this shape to
  /// [openShape]. When the container is closed, it will transition back to this
  /// shape.
  ///
  /// Defaults to a [RoundedRectangleBorder] with a [Radius.circular] of 4.0.
  ///
  /// See also:
  ///
  ///  * [Material.shape], which is used to implement this property.
  final ShapeBorder closedShape;

  /// Shape of the container while it is open.
  ///
  /// When the container is opened it will transition from [closedShape] to
  /// this shape. When the container is closed, it will transition from this
  /// shape back to [closedShape].
  ///
  /// Defaults to a rectangular.
  ///
  /// See also:
  ///
  ///  * [Material.shape], which is used to implement this property.
  final ShapeBorder openShape;

  /// Called when the container is popped. This is called at the start of the
  /// closing transition.
  ///
  /// The return value from the popped screen is passed to this function as an
  /// argument.
  ///
  /// If no value is returned via [Navigator.pop] or [OpenContainer.openBuilder.action],
  /// `null` will be returned by default.
  final ClosedCallback<T?>? onClosed;

  /// Called to obtain the child for the container in the closed state.
  ///
  /// The [Widget] returned by this builder is faded out when the container
  /// opens and at the same time the widget returned by [openBuilder] is faded
  /// in while the container grows to fill the surrounding [Navigator].
  ///
  /// The `action` callback provided to the builder can be called to open the
  /// container.
  final CloseContainerBuilder closedBuilder;

  /// Called to obtain the child for the container in the open state.
  ///
  /// The [Widget] returned by this builder is faded in when the container
  /// opens and at the same time the widget returned by [closedBuilder] is
  /// faded out while the container grows to fill the surrounding [Navigator].
  ///
  /// The `action` callback provided to the builder can be called to close the
  /// container.
  final OpenContainerBuilder<T> openBuilder;

  /// Whether the entire closed container can be tapped to open it.
  ///
  /// Defaults to true.
  ///
  /// When this is set to false the container can only be opened by calling the
  /// `action` callback that is provided to the [closedBuilder].
  final bool tappable;

  /// The time it will take to animate the container from its closed to its
  /// open state and vice versa.
  ///
  /// Defaults to 300ms.
  final Duration transitionDuration;

  /// The type of fade transition that the container will use for its
  /// incoming and outgoing widgets.
  ///
  /// Defaults to [ContainerTransitionType.fade].
  final ContainerTransitionType transitionType;

  /// The [useRootNavigator] argument is used to determine whether to push the
  /// route for [openBuilder] to the Navigator furthest from or nearest to
  /// the given context.
  ///
  /// By default, [useRootNavigator] is false and the route created will push
  /// to the nearest navigator.
  final bool useRootNavigator;

  /// Provides additional data to the [openBuilder] route pushed by the Navigator.
  final RouteSettings? routeSettings;

  /// The [closedBuilder] will be clipped (or not) according to this option.
  ///
  /// Defaults to [Clip.antiAlias], and must not be null.
  ///
  /// See also:
  ///
  ///  * [Material.clipBehavior], which is used to implement this property.
  final Clip clipBehavior;

  /// Custom shadows of the container while it is closed.
  ///
  /// If this is provided, [closedElevation] will be ignored.
  final List<BoxShadow>? closedShadows;

  /// Custom shadows of the container while it is open.
  ///
  /// If this is provided, [openElevation] will be ignored.
  final List<BoxShadow>? openShadows;

  /// An optional tag to identify this [OpenContainer].
  ///
  /// This tag can be used by an [OpenContainerPage] to find this container
  /// and perform the container transform animation when the page is pushed
  /// declaratively (e.g. via `go_router`).
  final Object? transitionTag;

  /// An optional callback to trigger the opening of the container.
  ///
  /// If this is provided, it will be called instead of the default
  /// [Navigator.push] when the container is tapped or when
  /// [OpenContainerState.openContainer] is called.
  ///
  /// This is useful for integrating with declarative routers like `go_router`.
  /// For example:
  ///
  /// ```dart
  /// OpenContainer(
  ///   onOpen: () => context.push('/details'),
  ///   // ...
  /// )
  /// ```
  final Future<T?> Function()? onOpen;

  @override
  State<OpenContainer<T?>> createState() => OpenContainerState<T>();
}

/// A page that shows the container transform animation.
///
/// This is used for integrating with declarative routers like `go_router`.
/// It uses the [transitionTag] to find the source [OpenContainer] and perform
/// the container transform animation.
///
/// If the source [OpenContainer] is not found (e.g. direct URL navigation),
/// it will perform a simple fade-in transition using the provided properties.
class OpenContainerPage<T> extends Page<T> {
  /// Creates an [OpenContainerPage].
  const OpenContainerPage({
    this.closedColor = Colors.white,
    this.openColor = Colors.white,
    this.middleColor,
    this.closedElevation = 1.0,
    this.openElevation = 4.0,
    this.closedShape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
    ),
    this.openShape = const RoundedRectangleBorder(),
    required this.openBuilder,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.transitionType = ContainerTransitionType.fade,
    this.useRootNavigator = false,
    this.closedShadows,
    this.openShadows,
    this.transitionTag,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  /// Background color of the container while it is closed.
  final Color closedColor;

  /// Background color of the container while it is open.
  final Color openColor;

  /// The color to use for the background color during the transition.
  final Color? middleColor;

  /// Elevation of the container while it is closed.
  final double closedElevation;

  /// Elevation of the container while it is open.
  final double openElevation;

  /// Shape of the container while it is closed.
  final ShapeBorder closedShape;

  /// Shape of the container while it is open.
  final ShapeBorder openShape;

  /// Called to obtain the child for the container in the open state.
  final OpenContainerBuilder<T> openBuilder;

  /// The time it will take to animate the transition.
  final Duration transitionDuration;

  /// The type of fade transition that the container will use.
  final ContainerTransitionType transitionType;

  /// Whether to use the root navigator.
  final bool useRootNavigator;

  /// Custom shadows of the container while it is closed.
  final List<BoxShadow>? closedShadows;

  /// Custom shadows of the container while it is open.
  final List<BoxShadow>? openShadows;

  /// The tag of the source [OpenContainer].
  final Object? transitionTag;

  @override
  Route<T> createRoute(BuildContext context) {
    OpenContainerState<dynamic>? state;
    if (transitionTag != null) {
      state = OpenContainerRegistry.instance.get(transitionTag!);
    }

    return OpenContainerRoute<T>(
      closedColor: state?.widget.closedColor ?? closedColor,
      openColor: state?.widget.openColor ?? openColor,
      middleColor: state?.widget.middleColor ??
          middleColor ??
          Theme.of(context).canvasColor,
      closedElevation: state?.widget.closedElevation ?? closedElevation,
      openElevation: state?.widget.openElevation ?? openElevation,
      closedShape: state?.widget.closedShape ?? closedShape,
      openShape: state?.widget.openShape ?? openShape,
      closedBuilder: state?.widget.closedBuilder,
      openBuilder: openBuilder,
      hideableKey: state?.hideableKey,
      closedBuilderKey: state?.closedBuilderKey,
      transitionDuration:
          state?.widget.transitionDuration ?? transitionDuration,
      transitionType: state?.widget.transitionType ?? transitionType,
      useRootNavigator: state?.widget.useRootNavigator ?? useRootNavigator,
      routeSettings: this,
      closedShadows: state?.widget.closedShadows ?? closedShadows,
      openShadows: state?.widget.openShadows ?? openShadows,
    );
  }
}

/// A registry that tracks active [OpenContainerState] instances by their
/// [OpenContainer.transitionTag].
///
/// This is used by [OpenContainerPage] to coordinate the container transform
/// animation between the source [OpenContainer] and the destination page.
class OpenContainerRegistry {
  OpenContainerRegistry._();

  static final OpenContainerRegistry _instance = OpenContainerRegistry._();

  /// Returns the singleton instance of the registry.
  static OpenContainerRegistry get instance => _instance;

  final Map<Object, OpenContainerState<dynamic>> _states = <Object, OpenContainerState<dynamic>>{};

  /// Registers an [OpenContainerState] with the given [tag].
  void register(Object tag, OpenContainerState<dynamic> state) {
    _states[tag] = state;
  }

  /// Unregisters the [OpenContainerState] associated with the given [tag].
  void unregister(Object tag) {
    _states.remove(tag);
  }

  /// Returns the [OpenContainerState] associated with the given [tag], if any.
  OpenContainerState<dynamic>? get(Object tag) => _states[tag];
}

/// State for a [OpenContainer].
///
/// The [OpenContainerState.openContainer] can be triggered either by:
/// 1. Explicitly calling from [OpenContainerState] via a [GlobalKey].
/// 2. By tapping the [OpenContainer] widget itself,
///    if [OpenContainer.tappable] is true.
@optionalTypeArgs
class OpenContainerState<T> extends State<OpenContainer<T?>> {
  /// Key used in [OpenContainerRoute] to hide the widget returned by
  /// [OpenContainer.openBuilder] in the source route while the container is
  /// opening/open. A copy of that widget is included in the
  /// [OpenContainerRoute] where it fades out. To avoid issues with double
  /// shadows and transparency, we hide it in the source route.
  final GlobalKey<HideableState> hideableKey = GlobalKey<HideableState>();

  /// Key used to steal the state of the widget returned by
  /// [OpenContainer.openBuilder] from the source route and attach it to the
  /// same widget included in the [OpenContainerRoute] where it fades out.
  final GlobalKey closedBuilderKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.transitionTag != null) {
      OpenContainerRegistry.instance.register(widget.transitionTag!, this);
    }
  }

  @override
  void didUpdateWidget(OpenContainer<T?> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transitionTag != widget.transitionTag) {
      if (oldWidget.transitionTag != null) {
        OpenContainerRegistry.instance.unregister(oldWidget.transitionTag!);
      }
      if (widget.transitionTag != null) {
        OpenContainerRegistry.instance.register(widget.transitionTag!, this);
      }
    }
  }

  @override
  void dispose() {
    if (widget.transitionTag != null) {
      OpenContainerRegistry.instance.unregister(widget.transitionTag!);
    }
    super.dispose();
  }

  /// Open the container using the given middle color and specific route,
  /// then call `onClosed` with the returned data after popped.
  Future<void> openContainer() async {
    if (widget.onOpen != null) {
      final T? data = await widget.onOpen!();
      if (widget.onClosed != null) {
        widget.onClosed!(data);
      }
      return;
    }

    final Color middleColor =
        widget.middleColor ?? Theme.of(context).canvasColor;
    final T? data =
        await Navigator.of(
          context,
          rootNavigator: widget.useRootNavigator,
        ).push(
          OpenContainerRoute<T>(
            closedColor: widget.closedColor,
            openColor: widget.openColor,
            middleColor: middleColor,
            closedElevation: widget.closedElevation,
            openElevation: widget.openElevation,
            closedShape: widget.closedShape,
            openShape: widget.openShape,
            closedBuilder: widget.closedBuilder,
            openBuilder: widget.openBuilder,
            hideableKey: hideableKey,
            closedBuilderKey: closedBuilderKey,
            transitionDuration: widget.transitionDuration,
            transitionType: widget.transitionType,
            useRootNavigator: widget.useRootNavigator,
            routeSettings: widget.routeSettings,
            closedShadows: widget.closedShadows,
            openShadows: widget.openShadows,
          ),
        );
    if (widget.onClosed != null) {
      widget.onClosed!(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget material = Material(
      clipBehavior: widget.clipBehavior,
      color: widget.closedColor,
      elevation: widget.closedShadows == null ? widget.closedElevation : 0.0,
      shape: widget.closedShape,
      child: Builder(
        key: closedBuilderKey,
        builder: (BuildContext context) {
          return widget.closedBuilder(context, openContainer);
        },
      ),
    );

    return Hideable(
      key: hideableKey,
      child: GestureDetector(
        onTap: widget.tappable ? openContainer : null,
        child: widget.closedShadows == null
            ? material
            : DecoratedBox(
                decoration: ShapeDecoration(
                  shape: widget.closedShape,
                  shadows: widget.closedShadows,
                ),
                child: material,
              ),
      ),
    );
  }
}

/// Controls the visibility of its child.
///
/// The child can be in one of three states:
///
///  * It is included in the tree and fully visible. (The `placeholderSize` is
///    null and `isVisible` is true.)
///  * It is included in the tree, but not visible; its size is maintained.
///    (The `placeholderSize` is null and `isVisible` is false.)
///  * It is not included in the tree. Instead a [SizedBox] of dimensions
///    specified by `placeholderSize` is included in the tree. (The value of
///    `isVisible` is ignored).
class Hideable extends StatefulWidget {
  /// Creates a [Hideable].
  const Hideable({super.key, required this.child});

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  State<Hideable> createState() => HideableState();
}

/// State for [Hideable].
class HideableState extends State<Hideable> {
  /// When non-null the child is replaced by a [SizedBox] of the set size.
  Size? get placeholderSize => _placeholderSize;
  Size? _placeholderSize;
  set placeholderSize(Size? value) {
    if (_placeholderSize == value) {
      return;
    }
    setState(() {
      _placeholderSize = value;
    });
  }

  /// When true the child is not visible, but will maintain its size.
  ///
  /// The value of this property is ignored when [placeholderSize] is non-null
  /// (i.e. [isInTree] returns false).
  bool get isVisible => _visible;
  bool _visible = true;
  set isVisible(bool value) {
    if (_visible == value) {
      return;
    }
    setState(() {
      _visible = value;
    });
  }

  /// Whether the child is currently included in the tree.
  ///
  /// When it is included, it may be visible or not according to [isVisible].
  bool get isInTree => _placeholderSize == null;

  @override
  Widget build(BuildContext context) {
    if (_placeholderSize != null) {
      return SizedBox.fromSize(size: _placeholderSize);
    }
    return Visibility(
      visible: _visible,
      maintainSize: true,
      maintainState: true,
      maintainAnimation: true,
      child: widget.child,
    );
  }
}

/// A route that shows the container transform animation.
class OpenContainerRoute<T> extends ModalRoute<T> {
  /// Creates an [OpenContainerRoute].
  OpenContainerRoute({
    required this.closedColor,
    required this.openColor,
    required this.middleColor,
    required double closedElevation,
    required this.openElevation,
    required ShapeBorder closedShape,
    required this.openShape,
    this.closedBuilder,
    required this.openBuilder,
    this.hideableKey,
    this.closedBuilderKey,
    required this.transitionDuration,
    required this.transitionType,
    this.useRootNavigator = false,
    required RouteSettings? routeSettings,
    required this.closedShadows,
    required this.openShadows,
  }) : _elevationTween = Tween<double>(
         begin: closedShadows == null ? closedElevation : 0.0,
         end: openShadows == null ? openElevation : 0.0,
       ),
       _shadowsTween = _getShadowsTween(closedShadows, openShadows),
       _shapeTween = ShapeBorderTween(begin: closedShape, end: openShape),
       _colorTween = _getColorTween(
         transitionType: transitionType,
         closedColor: closedColor,
         openColor: openColor,
         middleColor: middleColor,
       ),
       _closedOpacityTween = _getClosedOpacityTween(transitionType),
       _openOpacityTween = _getOpenOpacityTween(transitionType),
       super(settings: routeSettings);

  static FlippableTweenSequence<Color?> _getColorTween({
    required ContainerTransitionType transitionType,
    required Color closedColor,
    required Color openColor,
    required Color middleColor,
  }) {
    switch (transitionType) {
      case ContainerTransitionType.fade:
        return FlippableTweenSequence<Color?>(<TweenSequenceItem<Color?>>[
          TweenSequenceItem<Color>(
            tween: ConstantTween<Color>(closedColor),
            weight: 1 / 5,
          ),
          TweenSequenceItem<Color?>(
            tween: ColorTween(begin: closedColor, end: openColor),
            weight: 1 / 5,
          ),
          TweenSequenceItem<Color>(
            tween: ConstantTween<Color>(openColor),
            weight: 3 / 5,
          ),
        ]);
      case ContainerTransitionType.fadeThrough:
        return FlippableTweenSequence<Color?>(<TweenSequenceItem<Color?>>[
          TweenSequenceItem<Color?>(
            tween: ColorTween(begin: closedColor, end: middleColor),
            weight: 1 / 5,
          ),
          TweenSequenceItem<Color?>(
            tween: ColorTween(begin: middleColor, end: openColor),
            weight: 4 / 5,
          ),
        ]);
    }
  }

  static FlippableTweenSequence<double> _getClosedOpacityTween(
    ContainerTransitionType transitionType,
  ) {
    switch (transitionType) {
      case ContainerTransitionType.fade:
        return FlippableTweenSequence<double>(<TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: ConstantTween<double>(1.0),
            weight: 1,
          ),
        ]);
      case ContainerTransitionType.fadeThrough:
        return FlippableTweenSequence<double>(<TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 1.0, end: 0.0),
            weight: 1 / 5,
          ),
          TweenSequenceItem<double>(
            tween: ConstantTween<double>(0.0),
            weight: 4 / 5,
          ),
        ]);
    }
  }

  static FlippableTweenSequence<double> _getOpenOpacityTween(
    ContainerTransitionType transitionType,
  ) {
    switch (transitionType) {
      case ContainerTransitionType.fade:
        return FlippableTweenSequence<double>(<TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: ConstantTween<double>(0.0),
            weight: 1 / 5,
          ),
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            weight: 1 / 5,
          ),
          TweenSequenceItem<double>(
            tween: ConstantTween<double>(1.0),
            weight: 3 / 5,
          ),
        ]);
      case ContainerTransitionType.fadeThrough:
        return FlippableTweenSequence<double>(<TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: ConstantTween<double>(0.0),
            weight: 1 / 5,
          ),
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            weight: 4 / 5,
          ),
        ]);
    }
  }

  /// Background color of the container while it is closed.
  final Color closedColor;

  /// Background color of the container while it is open.
  final Color openColor;

  /// The color to use for the background color during the transition.
  final Color middleColor;

  /// Elevation of the container while it is open.
  final double openElevation;

  /// Shape of the container while it is open.
  final ShapeBorder openShape;

  /// Called to obtain the child for the container in the closed state.
  final CloseContainerBuilder? closedBuilder;

  /// Called to obtain the child for the container in the open state.
  final OpenContainerBuilder<T> openBuilder;

  /// Custom shadows of the container while it is closed.
  final List<BoxShadow>? closedShadows;

  /// Custom shadows of the container while it is open.
  final List<BoxShadow>? openShadows;

  /// See [OpenContainerState.hideableKey].
  final GlobalKey<HideableState>? hideableKey;

  /// See [OpenContainerState.closedBuilderKey].
  final GlobalKey? closedBuilderKey;

  @override
  final Duration transitionDuration;

  /// The type of fade transition that the container will use.
  final ContainerTransitionType transitionType;

  /// Whether to use the root navigator.
  final bool useRootNavigator;

  final Tween<double> _elevationTween;
  final Animatable<List<BoxShadow>?> _shadowsTween;
  final ShapeBorderTween _shapeTween;
  final FlippableTweenSequence<double> _closedOpacityTween;
  final FlippableTweenSequence<double> _openOpacityTween;
  final FlippableTweenSequence<Color?> _colorTween;

  static final TweenSequence<Color?> _scrimFadeInTween =
      TweenSequence<Color?>(<TweenSequenceItem<Color?>>[
        TweenSequenceItem<Color?>(
          tween: ColorTween(begin: Colors.transparent, end: Colors.black54),
          weight: 1 / 5,
        ),
        TweenSequenceItem<Color>(
          tween: ConstantTween<Color>(Colors.black54),
          weight: 4 / 5,
        ),
      ]);
  static final Tween<Color?> _scrimFadeOutTween = ColorTween(
    begin: Colors.transparent,
    end: Colors.black54,
  );

  // Key used for the widget returned by [OpenContainer.openBuilder] to keep
  // its state when the shape of the widget tree is changed at the end of the
  // animation to remove all the craft that was necessary to make the animation
  // work.
  final GlobalKey _openBuilderKey = GlobalKey();

  // Defines the position and the size of the (opening) [OpenContainer] within
  // the bounds of the enclosing [Navigator].
  final RectTween _rectTween = RectTween();

  static Animatable<List<BoxShadow>?> _getShadowsTween(
    List<BoxShadow>? begin,
    List<BoxShadow>? end,
  ) {
    if (begin == null && end == null) {
      return ConstantTween<List<BoxShadow>?>(null);
    }
    return ShadowsTween(begin: begin, end: end);
  }

  AnimationStatus? _lastAnimationStatus;
  AnimationStatus? _currentAnimationStatus;

  bool get _isCoordinated => hideableKey != null && closedBuilderKey != null && closedBuilder != null;

  @override
  TickerFuture didPush() {
    _takeMeasurements();

    animation!.addStatusListener((AnimationStatus status) {
      _lastAnimationStatus = _currentAnimationStatus;
      _currentAnimationStatus = status;
      switch (status) {
        case AnimationStatus.dismissed:
          _toggleHideable(hide: false);
        case AnimationStatus.completed:
          _toggleHideable(hide: true);
        case AnimationStatus.forward:
        case AnimationStatus.reverse:
          break;
      }
    });

    return super.didPush();
  }

  @override
  bool didPop(T? result) {
    if (_isCoordinated) {
      _takeMeasurements(delayForSourceRoute: true);
    }
    return super.didPop(result);
  }

  @override
  void dispose() {
    if (_isCoordinated && hideableKey!.currentState?.isVisible == false) {
      // This route may be disposed without dismissing its animation if it is
      // removed by the navigator.
      SchedulerBinding.instance.addPostFrameCallback(
        (Duration d) => _toggleHideable(hide: false),
      );
    }
    super.dispose();
  }

  void _toggleHideable({required bool hide}) {
    if (_isCoordinated && hideableKey!.currentState != null) {
      hideableKey!.currentState!
        ..placeholderSize = null
        ..isVisible = !hide;
    }
  }

  void _takeMeasurements({
    bool delayForSourceRoute = false,
  }) {
    final navigatorBox =
        navigator!.context.findRenderObject()! as RenderBox;
    final Size navSize = _getSize(navigatorBox);
    _rectTween.end = Offset.zero & navSize;

    void takeMeasurementsInSourceRoute([Duration? _]) {
      if (!navigatorBox.attached || hideableKey?.currentContext == null) {
        return;
      }
      _rectTween.begin = _getRect(hideableKey!, navigatorBox);
      hideableKey!.currentState!.placeholderSize = _rectTween.begin!.size;
    }

    if (delayForSourceRoute) {
      SchedulerBinding.instance.addPostFrameCallback(
        takeMeasurementsInSourceRoute,
      );
    } else if (_isCoordinated) {
      takeMeasurementsInSourceRoute();
    }
  }

  Size _getSize(RenderBox render) {
    assert(render.hasSize);
    return render.size;
  }

  // Returns the bounds of the [RenderObject] identified by `key` in the
  // coordinate system of `ancestor`.
  Rect _getRect(GlobalKey key, RenderBox ancestor) {
    assert(key.currentContext != null);
    assert(ancestor.hasSize);
    final render = key.currentContext!.findRenderObject()! as RenderBox;
    assert(render.hasSize);
    return MatrixUtils.transformRect(
      render.getTransformTo(ancestor),
      Offset.zero & render.size,
    );
  }

  bool get _transitionWasInterrupted {
    var wasInProgress = false;
    var isInProgress = false;

    switch (_currentAnimationStatus) {
      case AnimationStatus.completed:
      case AnimationStatus.dismissed:
        isInProgress = false;
      case AnimationStatus.forward:
      case AnimationStatus.reverse:
        isInProgress = true;
      case null:
        break;
    }
    switch (_lastAnimationStatus) {
      case AnimationStatus.completed:
      case AnimationStatus.dismissed:
        wasInProgress = false;
      case AnimationStatus.forward:
      case AnimationStatus.reverse:
        wasInProgress = true;
      case null:
        break;
    }
    return wasInProgress && isInProgress;
  }

  /// Closes the container.
  void closeContainer({T? returnValue}) {
    Navigator.of(subtreeContext!).pop(returnValue);
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Align(
      alignment: Alignment.topLeft,
      child: AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          if (animation.isCompleted) {
            final Widget material = Material(
              color: openColor,
              elevation: openShadows == null ? openElevation : 0.0,
              shape: openShape,
              child: Builder(
                key: _openBuilderKey,
                builder: (BuildContext context) {
                  return openBuilder(context, closeContainer);
                },
              ),
            );

            return SizedBox.expand(
              child: openShadows == null
                  ? material
                  : DecoratedBox(
                      decoration: ShapeDecoration(
                        shape: openShape,
                        shadows: openShadows,
                      ),
                      child: material,
                    ),
            );
          }

          final Animation<double> curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.fastOutSlowIn,
            reverseCurve: _transitionWasInterrupted
                ? null
                : Curves.fastOutSlowIn.flipped,
          );
          TweenSequence<Color?>? colorTween;
          TweenSequence<double>? closedOpacityTween, openOpacityTween;
          Animatable<Color?>? scrimTween;
          switch (animation.status) {
            case AnimationStatus.dismissed:
            case AnimationStatus.forward:
              closedOpacityTween = _closedOpacityTween;
              openOpacityTween = _openOpacityTween;
              colorTween = _colorTween;
              scrimTween = _scrimFadeInTween;
            case AnimationStatus.reverse:
              if (_transitionWasInterrupted) {
                closedOpacityTween = _closedOpacityTween;
                openOpacityTween = _openOpacityTween;
                colorTween = _colorTween;
                scrimTween = _scrimFadeInTween;
                break;
              }
              closedOpacityTween = _closedOpacityTween.flipped;
              openOpacityTween = _openOpacityTween.flipped;
              colorTween = _colorTween.flipped;
              scrimTween = _scrimFadeOutTween;
            case AnimationStatus.completed:
              assert(false); // Unreachable.
          }
          assert(colorTween != null);
          assert(closedOpacityTween != null);
          assert(openOpacityTween != null);
          assert(scrimTween != null);

          final Rect? rect = _rectTween.begin == null
              ? _rectTween.end
              : _rectTween.evaluate(curvedAnimation);
          final Widget material = Material(
            clipBehavior: Clip.antiAlias,
            animationDuration: Duration.zero,
            color: colorTween!.evaluate(animation),
            shape: _shapeTween.evaluate(curvedAnimation),
            elevation: _elevationTween.evaluate(curvedAnimation),
            child: Stack(
              fit: StackFit.passthrough,
              children: <Widget>[
                // Closed child fading out.
                if (_isCoordinated)
                  FittedBox(
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: _rectTween.begin!.width,
                      height: _rectTween.begin!.height,
                      child: (hideableKey!.currentState?.isInTree ?? false)
                          ? null
                          : FadeTransition(
                              opacity: closedOpacityTween!.animate(animation),
                              child: Builder(
                                key: closedBuilderKey,
                                builder: (BuildContext context) {
                                  // Use dummy "open container" callback
                                  // since we are in the process of opening.
                                  return closedBuilder!(context, () {});
                                },
                              ),
                            ),
                    ),
                  ),

                // Open child fading in.
                FittedBox(
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: _rectTween.end!.width,
                    height: _rectTween.end!.height,
                    child: FadeTransition(
                      opacity: openOpacityTween!.animate(animation),
                      child: Builder(
                        key: _openBuilderKey,
                        builder: (BuildContext context) {
                          return openBuilder(context, closeContainer);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );

          final List<BoxShadow>? currentShadows = _shadowsTween.evaluate(
            curvedAnimation,
          );

          return SizedBox.expand(
            child: Container(
              color: scrimTween!.evaluate(curvedAnimation),
              child: Align(
                alignment: Alignment.topLeft,
                child: Transform.translate(
                  offset: rect == null ? Offset.zero : Offset(rect.left, rect.top),
                  child: SizedBox(
                    width: rect?.width ?? 0.0,
                    height: rect?.height ?? 0.0,
                    child: currentShadows == null
                        ? material
                        : DecoratedBox(
                            decoration: ShapeDecoration(
                              shape: _shapeTween.evaluate(curvedAnimation)!,
                              shadows: currentShadows,
                            ),
                            child: material,
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  bool get maintainState => true;

  @override
  Color? get barrierColor => null;

  @override
  bool get opaque => true;

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => null;
}

/// A [TweenSequence] that can be flipped.
class FlippableTweenSequence<T> extends TweenSequence<T> {
  /// Creates a [FlippableTweenSequence].
  FlippableTweenSequence(this._items) : super(_items);

  final List<TweenSequenceItem<T>> _items;
  FlippableTweenSequence<T>? _flipped;

  /// Returns a flipped version of this [TweenSequence].
  FlippableTweenSequence<T>? get flipped {
    if (_flipped == null) {
      final newItems = <TweenSequenceItem<T>>[];
      for (var i = 0; i < _items.length; i++) {
        newItems.add(
          TweenSequenceItem<T>(
            tween: _items[i].tween,
            weight: _items[_items.length - 1 - i].weight,
          ),
        );
      }
      _flipped = FlippableTweenSequence<T>(newItems);
    }
    return _flipped;
  }
}

/// A [Tween] that interpolates between two lists of [BoxShadow]s.
class ShadowsTween extends Tween<List<BoxShadow>?> {
  /// Creates a [ShadowsTween].
  ShadowsTween({super.begin, super.end});

  @override
  List<BoxShadow>? lerp(double t) {
    return BoxShadow.lerpList(begin, end, t);
  }
}

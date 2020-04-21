// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Signature for a function that creates a [Widget] to be used within an
/// [OpenContainer].
///
/// The `action` callback provided to [OpenContainer.openBuilder] can be used
/// to close the container. The `action` callback provided to
/// [OpenContainer.closedBuilder] can be used to open the container again.
typedef OpenContainerBuilder = Widget Function(
  BuildContext context,
  VoidCallback action,
);

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

/// A container that grows to fill the screen to reveal new content when tapped.
///
/// While the container is closed, it shows the [Widget] returned by
/// [closedBuilder]. When the container is tapped it grows to fill the entire
/// size of the surrounding [Navigator] while fading out the widget returned by
/// [closedBuilder] and fading in the widget returned by [openBuilder]. When the
/// container is closed again via the callback provided to [openBuilder] or via
/// Android's back button, the animation is reversed: The container shrinks back
/// to its original size while the widget returned by [openBuilder] is faded out
/// and the widget returned by [openBuilder] is faded back in.
///
/// By default, the container is in the closed state. During the transition from
/// closed to open and vice versa the widgets returned by the [openBuilder] and
/// [closedBuilder] exist in the tree at the same time. Therefore, the widgets
/// returned by these builders cannot include the same global key.
///
// TODO(goderbauer): Add example animations and sample code.
///
/// See also:
///
///  * [Transitions with animated containers](https://material.io/design/motion/choreography.html#transformation)
///    in the Material spec.
class OpenContainer extends StatefulWidget {
  /// Creates an [OpenContainer].
  ///
  /// All arguments except for [key] must not be null. The arguments
  /// [closedBuilder] and [closedBuilder] are required.
  const OpenContainer({
    Key key,
    this.closedColor = Colors.white,
    this.openColor = Colors.white,
    this.closedElevation = 1.0,
    this.openElevation = 4.0,
    this.closedShape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
    ),
    this.openShape = const RoundedRectangleBorder(),
    @required this.closedBuilder,
    @required this.openBuilder,
    this.tappable = true,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.transitionType = ContainerTransitionType.fade,
  })  : assert(closedColor != null),
        assert(openColor != null),
        assert(closedElevation != null),
        assert(openElevation != null),
        assert(closedShape != null),
        assert(openShape != null),
        assert(closedBuilder != null),
        assert(openBuilder != null),
        assert(tappable != null),
        assert(transitionType != null),
        super(key: key);

  /// Background color of the container while it is closed.
  ///
  /// When the container is opened, it will first transition from this color
  /// to [Colors.white] and then transition from there to [openColor] in one
  /// smooth animation. When the container is closed, it will transition back to
  /// this color from [openColor] via [Colors.white].
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
  /// to [Colors.white] and then transition from there to this color in one
  /// smooth animation. When the container is closed, it will transition back to
  /// [closedColor] from this color via [Colors.white].
  ///
  /// Defaults to [Colors.white].
  ///
  /// See also:
  ///
  ///  * [Material.color], which is used to implement this property.
  final Color openColor;

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

  /// Called to obtain the child for the container in the closed state.
  ///
  /// The [Widget] returned by this builder is faded out when the container
  /// opens and at the same time the widget returned by [openBuilder] is faded
  /// in while the container grows to fill the surrounding [Navigator].
  ///
  /// The `action` callback provided to the builder can be called to open the
  /// container.
  final OpenContainerBuilder closedBuilder;

  /// Called to obtain the child for the container in the open state.
  ///
  /// The [Widget] returned by this builder is faded in when the container
  /// opens and at the same time the widget returned by [closedBuilder] is
  /// faded out while the container grows to fill the surrounding [Navigator].
  ///
  /// The `action` callback provided to the builder can be called to close the
  /// container.
  final OpenContainerBuilder openBuilder;

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

  @override
  _OpenContainerState createState() => _OpenContainerState();
}

class _OpenContainerState extends State<OpenContainer> {
  // Key used in [_OpenContainerRoute] to hide the widget returned by
  // [OpenContainer.openBuilder] in the source route while the container is
  // opening/open. A copy of that widget is included in the
  // [_OpenContainerRoute] where it fades out. To avoid issues with double
  // shadows and transparency, we hide it in the source route.
  final GlobalKey<_HideableState> _hideableKey = GlobalKey<_HideableState>();

  // Key used to steal the state of the widget returned by
  // [OpenContainer.openBuilder] from the source route and attach it to the
  // same widget included in the [_OpenContainerRoute] where it fades out.
  final GlobalKey _closedBuilderKey = GlobalKey();

  void openContainer() {
    Navigator.of(context).push(_OpenContainerRoute(
      closedColor: widget.closedColor,
      openColor: widget.openColor,
      closedElevation: widget.closedElevation,
      openElevation: widget.openElevation,
      closedShape: widget.closedShape,
      openShape: widget.openShape,
      closedBuilder: widget.closedBuilder,
      openBuilder: widget.openBuilder,
      hideableKey: _hideableKey,
      closedBuilderKey: _closedBuilderKey,
      transitionDuration: widget.transitionDuration,
      transitionType: widget.transitionType,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return _Hideable(
      key: _hideableKey,
      child: GestureDetector(
        onTap: widget.tappable ? openContainer : null,
        child: Material(
          clipBehavior: Clip.antiAlias,
          color: widget.closedColor,
          elevation: widget.closedElevation,
          shape: widget.closedShape,
          child: Builder(
            key: _closedBuilderKey,
            builder: (BuildContext context) {
              return widget.closedBuilder(context, openContainer);
            },
          ),
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
class _Hideable extends StatefulWidget {
  const _Hideable({
    Key key,
    this.child,
  }) : super(key: key);

  final Widget child;

  @override
  State<_Hideable> createState() => _HideableState();
}

class _HideableState extends State<_Hideable> {
  /// When non-null the child is replaced by a [SizedBox] of the set size.
  Size get placeholderSize => _placeholderSize;
  Size _placeholderSize;
  set placeholderSize(Size value) {
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
    assert(value != null);
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
    return Opacity(
      opacity: _visible ? 1.0 : 0.0,
      child: widget.child,
    );
  }
}

class _OpenContainerRoute extends ModalRoute<void> {
  _OpenContainerRoute({
    @required this.closedColor,
    @required this.openColor,
    @required double closedElevation,
    @required this.openElevation,
    @required ShapeBorder closedShape,
    @required this.openShape,
    @required this.closedBuilder,
    @required this.openBuilder,
    @required this.hideableKey,
    @required this.closedBuilderKey,
    @required this.transitionDuration,
    @required this.transitionType,
  })  : assert(closedColor != null),
        assert(openColor != null),
        assert(closedElevation != null),
        assert(openElevation != null),
        assert(closedShape != null),
        assert(openBuilder != null),
        assert(closedBuilder != null),
        assert(hideableKey != null),
        assert(closedBuilderKey != null),
        assert(transitionType != null),
        _elevationTween = Tween<double>(
          begin: closedElevation,
          end: openElevation,
        ),
        _shapeTween = ShapeBorderTween(
          begin: closedShape,
          end: openShape,
        ),
        _colorTween = _getColorTween(
          transitionType: transitionType,
          closedColor: closedColor,
          openColor: openColor,
        ),
        _closedOpacityTween = _getClosedOpacityTween(transitionType),
        _openOpacityTween = _getOpenOpacityTween(transitionType);

  static _FlippableTweenSequence<Color> _getColorTween({
    @required ContainerTransitionType transitionType,
    @required Color closedColor,
    @required Color openColor,
  }) {
    switch (transitionType) {
      case ContainerTransitionType.fade:
        return _FlippableTweenSequence<Color>(
          <TweenSequenceItem<Color>>[
            TweenSequenceItem<Color>(
              tween: ConstantTween<Color>(closedColor),
              weight: 1 / 5,
            ),
            TweenSequenceItem<Color>(
              tween: ColorTween(begin: closedColor, end: openColor),
              weight: 1 / 5,
            ),
            TweenSequenceItem<Color>(
              tween: ConstantTween<Color>(openColor),
              weight: 3 / 5,
            ),
          ],
        );
      case ContainerTransitionType.fadeThrough:
        return _FlippableTweenSequence<Color>(
          <TweenSequenceItem<Color>>[
            TweenSequenceItem<Color>(
              tween: ColorTween(begin: closedColor, end: Colors.white),
              weight: 1 / 5,
            ),
            TweenSequenceItem<Color>(
              tween: ColorTween(begin: Colors.white, end: openColor),
              weight: 4 / 5,
            ),
          ],
        );
    }
    return null; // unreachable
  }

  static _FlippableTweenSequence<double> _getClosedOpacityTween(
      ContainerTransitionType transitionType) {
    switch (transitionType) {
      case ContainerTransitionType.fade:
        return _FlippableTweenSequence<double>(
          <TweenSequenceItem<double>>[
            TweenSequenceItem<double>(
              tween: ConstantTween<double>(1.0),
              weight: 1,
            ),
          ],
        );
        break;
      case ContainerTransitionType.fadeThrough:
        return _FlippableTweenSequence<double>(
          <TweenSequenceItem<double>>[
            TweenSequenceItem<double>(
              tween: Tween<double>(begin: 1.0, end: 0.0),
              weight: 1 / 5,
            ),
            TweenSequenceItem<double>(
              tween: ConstantTween<double>(0.0),
              weight: 4 / 5,
            ),
          ],
        );
        break;
    }
    return null; // unreachable
  }

  static _FlippableTweenSequence<double> _getOpenOpacityTween(
      ContainerTransitionType transitionType) {
    switch (transitionType) {
      case ContainerTransitionType.fade:
        return _FlippableTweenSequence<double>(
          <TweenSequenceItem<double>>[
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
          ],
        );
        break;
      case ContainerTransitionType.fadeThrough:
        return _FlippableTweenSequence<double>(
          <TweenSequenceItem<double>>[
            TweenSequenceItem<double>(
              tween: ConstantTween<double>(0.0),
              weight: 1 / 5,
            ),
            TweenSequenceItem<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              weight: 4 / 5,
            ),
          ],
        );
        break;
    }
    return null; // unreachable
  }

  final Color closedColor;
  final Color openColor;
  final double openElevation;
  final ShapeBorder openShape;
  final OpenContainerBuilder closedBuilder;
  final OpenContainerBuilder openBuilder;

  // See [_OpenContainerState._hideableKey].
  final GlobalKey<_HideableState> hideableKey;

  // See [_OpenContainerState._closedBuilderKey].
  final GlobalKey closedBuilderKey;

  @override
  final Duration transitionDuration;
  final ContainerTransitionType transitionType;

  final Tween<double> _elevationTween;
  final ShapeBorderTween _shapeTween;
  final _FlippableTweenSequence<double> _closedOpacityTween;
  final _FlippableTweenSequence<double> _openOpacityTween;
  final _FlippableTweenSequence<Color> _colorTween;

  static final TweenSequence<Color> _scrimFadeInTween = TweenSequence<Color>(
    <TweenSequenceItem<Color>>[
      TweenSequenceItem<Color>(
        tween: ColorTween(begin: Colors.transparent, end: Colors.black54),
        weight: 1 / 5,
      ),
      TweenSequenceItem<Color>(
        tween: ConstantTween<Color>(Colors.black54),
        weight: 4 / 5,
      ),
    ],
  );
  static final Tween<Color> _scrimFadeOutTween = ColorTween(
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

  AnimationStatus _lastAnimationStatus;
  AnimationStatus _currentAnimationStatus;

  @override
  TickerFuture didPush() {
    _takeMeasurements(navigatorContext: hideableKey.currentContext);

    animation.addStatusListener((AnimationStatus status) {
      _lastAnimationStatus = _currentAnimationStatus;
      _currentAnimationStatus = status;
      switch (status) {
        case AnimationStatus.dismissed:
          hideableKey.currentState
            ..placeholderSize = null
            ..isVisible = true;
          break;
        case AnimationStatus.completed:
          hideableKey.currentState
            ..placeholderSize = null
            ..isVisible = false;
          break;
        case AnimationStatus.forward:
        case AnimationStatus.reverse:
          break;
      }
    });

    return super.didPush();
  }

  @override
  bool didPop(void result) {
    _takeMeasurements(
      navigatorContext: subtreeContext,
      delayForSourceRoute: true,
    );
    return super.didPop(result);
  }

  void _takeMeasurements({
    BuildContext navigatorContext,
    bool delayForSourceRoute = false,
  }) {
    final RenderBox navigator =
        Navigator.of(navigatorContext).context.findRenderObject();
    final Size navSize = _getSize(navigator);
    _rectTween.end = Offset.zero & navSize;

    void takeMeasurementsInSourceRoute([Duration _]) {
      if (!navigator.attached || hideableKey.currentContext == null) {
        return;
      }
      _rectTween.begin = _getRect(hideableKey, navigator);
      hideableKey.currentState.placeholderSize = _rectTween.begin.size;
    }

    if (delayForSourceRoute) {
      SchedulerBinding.instance
          .addPostFrameCallback(takeMeasurementsInSourceRoute);
    } else {
      takeMeasurementsInSourceRoute();
    }
  }

  Size _getSize(RenderBox render) {
    assert(render != null && render.hasSize);
    return render.size;
  }

  // Returns the bounds of the [RenderObject] identified by `key` in the
  // coordinate system of `ancestor`.
  Rect _getRect(GlobalKey key, RenderBox ancestor) {
    assert(key.currentContext != null);
    assert(ancestor != null && ancestor.hasSize);
    final RenderBox render = key.currentContext.findRenderObject();
    assert(render != null && render.hasSize);
    return MatrixUtils.transformRect(
      render.getTransformTo(ancestor),
      Offset.zero & render.size,
    );
  }

  bool get _transitionWasInterrupted {
    bool wasInProgress = false;
    bool isInProgress = false;

    switch (_currentAnimationStatus) {
      case AnimationStatus.completed:
      case AnimationStatus.dismissed:
        isInProgress = false;
        break;
      case AnimationStatus.forward:
      case AnimationStatus.reverse:
        isInProgress = true;
        break;
    }
    switch (_lastAnimationStatus) {
      case AnimationStatus.completed:
      case AnimationStatus.dismissed:
        wasInProgress = false;
        break;
      case AnimationStatus.forward:
      case AnimationStatus.reverse:
        wasInProgress = true;
        break;
    }
    return wasInProgress && isInProgress;
  }

  void closeContainer() {
    Navigator.of(subtreeContext).pop();
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
        builder: (BuildContext context, Widget child) {
          if (animation.isCompleted) {
            return SizedBox.expand(
              child: Material(
                color: openColor,
                elevation: openElevation,
                shape: openShape,
                child: Builder(
                  key: _openBuilderKey,
                  builder: (BuildContext context) {
                    return openBuilder(context, closeContainer);
                  },
                ),
              ),
            );
          }

          final Animation<double> curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.fastOutSlowIn,
            reverseCurve:
                _transitionWasInterrupted ? null : Curves.fastOutSlowIn.flipped,
          );
          TweenSequence<Color> colorTween;
          TweenSequence<double> closedOpacityTween, openOpacityTween;
          Animatable<Color> scrimTween;
          switch (animation.status) {
            case AnimationStatus.dismissed:
            case AnimationStatus.forward:
              closedOpacityTween = _closedOpacityTween;
              openOpacityTween = _openOpacityTween;
              colorTween = _colorTween;
              scrimTween = _scrimFadeInTween;
              break;
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
              break;
            case AnimationStatus.completed:
              assert(false); // Unreachable.
              break;
          }
          assert(colorTween != null);
          assert(closedOpacityTween != null);
          assert(openOpacityTween != null);
          assert(scrimTween != null);

          final Rect rect = _rectTween.evaluate(curvedAnimation);
          return SizedBox.expand(
            child: Container(
              color: scrimTween.evaluate(curvedAnimation),
              child: Align(
                alignment: Alignment.topLeft,
                child: Transform.translate(
                  offset: Offset(rect.left, rect.top),
                  child: SizedBox(
                    width: rect.width,
                    height: rect.height,
                    child: Material(
                      clipBehavior: Clip.antiAlias,
                      animationDuration: Duration.zero,
                      color: colorTween.evaluate(animation),
                      shape: _shapeTween.evaluate(curvedAnimation),
                      elevation: _elevationTween.evaluate(curvedAnimation),
                      child: Stack(
                        fit: StackFit.passthrough,
                        children: <Widget>[
                          // Closed child fading out.
                          FittedBox(
                            fit: BoxFit.fitWidth,
                            alignment: Alignment.topLeft,
                            child: SizedBox(
                              width: _rectTween.begin.width,
                              height: _rectTween.begin.height,
                              child: hideableKey.currentState.isInTree
                                  ? null
                                  : Opacity(
                                      opacity: closedOpacityTween
                                          .evaluate(animation),
                                      child: Builder(
                                        key: closedBuilderKey,
                                        builder: (BuildContext context) {
                                          // Use dummy "open container" callback
                                          // since we are in the process of opening.
                                          return closedBuilder(context, () {});
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
                              width: _rectTween.end.width,
                              height: _rectTween.end.height,
                              child: Opacity(
                                opacity: openOpacityTween.evaluate(animation),
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
  Color get barrierColor => null;

  @override
  bool get opaque => true;

  @override
  bool get barrierDismissible => false;

  @override
  String get barrierLabel => null;
}

class _FlippableTweenSequence<T> extends TweenSequence<T> {
  _FlippableTweenSequence(this._items) : super(_items);

  final List<TweenSequenceItem<T>> _items;
  _FlippableTweenSequence<T> _flipped;

  _FlippableTweenSequence<T> get flipped {
    if (_flipped == null) {
      final List<TweenSequenceItem<T>> newItems = <TweenSequenceItem<T>>[];
      for (int i = 0; i < _items.length; i++) {
        newItems.add(TweenSequenceItem<T>(
          tween: _items[i].tween,
          weight: _items[_items.length - 1 - i].weight,
        ));
      }
      _flipped = _FlippableTweenSequence<T>(newItems);
    }
    return _flipped;
  }
}

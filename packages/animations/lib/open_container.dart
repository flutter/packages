// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Signature for a function that creates a [Widget] to be used within an
/// [OpenContainer].
///
/// The `action` callback provided to [OpenContainer.closedBuilder] can be used
/// to open the container. The `action` callback provided to
/// [OpenContainer.closedBuilder] can be used to close the container again.
typedef OpenContainerChildBuilder = Widget Function(BuildContext context, VoidCallback action);

/// Container, that grows to fill the screen to reveal new content when tapped.
///
/// While the container is closed, it shows the [Widget] returned by
/// [closedBuilder]. When the container is tapped the container opens: It grows
/// to fill the entire size of the surrounding [Navigator] while fading out the
/// [Widget] returned by [closedBuilder] and fading in the [Widget] returned by
/// [openBuilder]. When the container is closed again via the callback provided
/// to [openBuilder] or via Android's back button the animation is reversed: The
/// container shrinks back to its original size while the [Widget] returned by
/// [openBuilder] is faded out and the [Widget] returned by [openBuilder] is
/// faded back in.
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
    this.closedShape = const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))),
    @required this.closedBuilder,
    @required this.openBuilder,
    this.tappable = true,
  })  : assert(closedColor != null),
        assert(openColor != null),
        assert(closedElevation != null),
        assert(openElevation != null),
        assert(closedShape != null),
        assert(closedBuilder != null),
        assert(openBuilder != null),
        assert(tappable != null),
        super(key: key);

  /// Background color of the container while it is closed.
  ///
  /// When the container is opened, it will transition from this color to
  /// [openColor] via [Colors.white]. When the container is closed, it will
  /// transition back to this color from [openColor] via [Colors.white].
  ///
  /// Defaults to [Colors.white].
  ///
  /// See also:
  ///
  ///  * [Material.color], which is used to implement this property.
  final Color closedColor;

  /// Background color of the container while it is open.
  ///
  /// When the container is opened, it will transition from [closedColor] to
  /// this color via [Colors.white]. When the container is closed, it will
  /// transition from this color back to [closedColor] via [Colors.white].
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
  /// When the container is opened it will transition from this shape to a
  /// rectangular that fills the surrounding [Navigator]. When the container
  /// is closed, it will transition back to this shape.
  ///
  /// Defaults to a [RoundedRectangleBorder] with a [Radius.circular] of 4.0.
  ///
  /// See also:
  ///
  ///  * [Material.shape], which is used to implement this property.
  final ShapeBorder closedShape;

  /// Called to obtain the child for the container in the closed state.
  ///
  /// The [Widget] returned by this builder is faded out when the container
  /// opens and at the same time the [Widget] returned by [openBuilder] is faded
  /// in while the container grows to fill the surrounding [Navigator].
  ///
  /// The `action` callback provided to the builder can be called to open the
  /// container.
  final OpenContainerChildBuilder closedBuilder;

  /// Called to obtain the child for the container in the open state.
  ///
  /// The [Widget] returned by this builder is faded in when the container
  /// opens and at the same time the [Widget] returned by [closedBuilder] is
  /// faded out while the container grows to fill the surrounding [Navigator].
  ///
  /// The `action` callback provided to the builder can be called to close the
  /// container.
  final OpenContainerChildBuilder openBuilder;

  /// Whether the entire closed container can be tapped to open it.
  ///
  /// Defaults to true.
  ///
  /// When this is set to false the container can only be opened via the
  /// `action` callback provided to [closedBuilder].
  final bool tappable;

  @override
  _OpenContainerState createState() => _OpenContainerState();
}

class _OpenContainerState extends State<OpenContainer> {
  final GlobalKey<_HideableState> _hidableKey = GlobalKey<_HideableState>();

  void openContainer() {
    Navigator.of(context).push(_OpenContainerRoute(
      closedColor: widget.closedColor,
      openColor: widget.openColor,
      closedElevation: widget.closedElevation,
      openElevation: widget.openElevation,
      closedShape: widget.closedShape,
      openBuilder: widget.openBuilder,
      closedBuilder: widget.closedBuilder,
      hideableKey: _hidableKey,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return _Hideable(
      key: _hidableKey,
      child: GestureDetector(
        onTap: widget.tappable ? openContainer : null,
        child: Material(
          clipBehavior: Clip.antiAlias,
          color: widget.closedColor,
          elevation: widget.closedElevation,
          shape: widget.closedShape,
          child: Builder(
            builder: (BuildContext context) {
              return widget.closedBuilder(context, openContainer);
            },
          ),
        ),
      ),
    );
  }
}

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
  Size get placeholder => _placeholder;
  Size _placeholder;
  set placeholder(Size value) {
    if (_placeholder == value) {
      return;
    }
    setState(() {
      _placeholder = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _placeholder != null ? SizedBox.fromSize(size: _placeholder) : widget.child;
  }
}

class _OpenContainerRoute extends ModalRoute<void> {
  _OpenContainerRoute({
    @required Color closedColor,
    @required this.openColor,
    @required double closedElevation,
    @required this.openElevation,
    @required ShapeBorder closedShape,
    @required this.openBuilder,
    @required this.closedBuilder,
    @required this.hideableKey,
  })  : assert(closedColor != null),
        assert(openColor != null),
        assert(closedElevation != null),
        assert(openElevation != null),
        assert(closedShape != null),
        assert(openBuilder != null),
        assert(closedBuilder != null),
        assert(hideableKey != null),
        _elevationTween = Tween<double>(
          begin: closedElevation,
          end: openElevation,
        ),
        _shapeTween = ShapeBorderTween(
          begin: closedShape,
          end: const RoundedRectangleBorder(),
        ),
        _colorTween = _FlippableTweenSequence<Color>(<TweenSequenceItem<Color>>[
          TweenSequenceItem<Color>(tween: ColorTween(begin: closedColor, end: Colors.white), weight: 4 / 12),
          TweenSequenceItem<Color>(tween: ColorTween(begin: Colors.white, end: openColor), weight: 8 / 12),
        ]);

  final Color openColor;
  final double openElevation;
  final OpenContainerChildBuilder closedBuilder;
  final OpenContainerChildBuilder openBuilder;
  final GlobalKey<_HideableState> hideableKey;

  final Tween<double> _elevationTween;
  final ShapeBorderTween _shapeTween;
  final _FlippableTweenSequence<Color> _colorTween;

  final _FlippableTweenSequence<double> _closedChildOpacityTween = _FlippableTweenSequence<double>(<TweenSequenceItem<double>>[
    TweenSequenceItem<double>(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 4 / 12),
    TweenSequenceItem<double>(tween: ConstantTween<double>(0.0), weight: 8 / 12),
  ]);
  final _FlippableTweenSequence<double> _openChildOpacityTween = _FlippableTweenSequence<double>(<TweenSequenceItem<double>>[
    TweenSequenceItem<double>(tween: ConstantTween<double>(0.0), weight: 4 / 12),
    TweenSequenceItem<double>(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 8 / 12),
  ]);

  final GlobalKey _openChildKey = GlobalKey();

  // Defines the position of the container on screen.
  final RectTween _insetsTween = RectTween(end: Rect.zero);

  // Defines the size of the container on screen.
  final SizeTween _sizeTween = SizeTween();

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
          hideableKey.currentState.placeholder = null;
          break;
        case AnimationStatus.completed:
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
    final RenderBox navigator = Navigator.of(navigatorContext).context.findRenderObject();
    final Size navSize = _getSize(navigator);
    _sizeTween.end = navSize;

    void takeMeasurementsInSourceRoute([Duration _]) {
      final Rect srcRect = _getRect(hideableKey, navigator);
      _sizeTween.begin = srcRect.size;
      _insetsTween.begin = Rect.fromLTRB(
        srcRect.left,
        srcRect.top,
        navSize.width - srcRect.right,
        navSize.height - srcRect.bottom,
      );
      hideableKey.currentState.placeholder = _sizeTween.begin;
    }

    if (delayForSourceRoute) {
      SchedulerBinding.instance.addPostFrameCallback(takeMeasurementsInSourceRoute);
    } else {
      takeMeasurementsInSourceRoute();
    }
  }

  Size _getSize(RenderBox render) {
    assert(render != null && render.hasSize);
    return render.size;
  }

  Rect _getRect(GlobalKey key, RenderBox ancestor) {
    final RenderBox render = key.currentContext.findRenderObject();
    assert(render != null && render.hasSize);
    assert(ancestor != null && ancestor.hasSize);
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
          print(animation.status);
          if (animation.isCompleted) {
            return SizedBox.expand(
              child: Material(
                color: openColor,
                elevation: openElevation,
                child: Builder(
                  key: _openChildKey,
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
            reverseCurve: _transitionWasInterrupted ? null : Curves.fastOutSlowIn.flipped,
          );
          TweenSequence<Color> colorTween;
          TweenSequence<double> closedChildOpacityTween, openChildOpacityTween;
          switch (animation.status) {
            case AnimationStatus.dismissed:
            case AnimationStatus.forward:
              closedChildOpacityTween = _closedChildOpacityTween;
              openChildOpacityTween = _openChildOpacityTween;
              colorTween = _colorTween;
              break;
            case AnimationStatus.reverse:
              if (_transitionWasInterrupted) {
                closedChildOpacityTween = _closedChildOpacityTween;
                openChildOpacityTween = _openChildOpacityTween;
                colorTween = _colorTween;
                break;
              }
              closedChildOpacityTween = _closedChildOpacityTween.flipped;
              openChildOpacityTween = _openChildOpacityTween.flipped;
              colorTween = _colorTween.flipped;
              break;
            case AnimationStatus.completed:
              assert(false); // Unreachable.
              break;
          }
          final Rect rect = _insetsTween.evaluate(curvedAnimation);
          final Size size = _sizeTween.evaluate(curvedAnimation);

          return Container(
            padding: EdgeInsets.fromLTRB(rect.left, rect.top, rect.right, rect.bottom),
            child: SizedBox(
              width: size.width,
              height: size.height,
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
                        width: _sizeTween.begin.width,
                        height: _sizeTween.begin.height,
                        child: hideableKey.currentState.placeholder == null ? null : Opacity(
                          opacity: closedChildOpacityTween.evaluate(animation),
                          child: Builder(
                            builder: (BuildContext context) {
                              // Passing in a dummy "open container" callback
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
                        width: _sizeTween.end.width,
                        height: _sizeTween.end.height,
                        child: Opacity(
                          opacity: openChildOpacityTween.evaluate(animation),
                          child: Builder(
                            key: _openChildKey,
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
          );
        },
      ),
    );
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

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

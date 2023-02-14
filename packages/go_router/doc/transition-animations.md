GoRouter allows you to customize the transition animation for each GoRoute. To
configure a custom transition animation, provide a `pageBuilder` parameter
to the GoRoute constructor:

```dart
GoRoute(
  path: 'details',
  pageBuilder: (context, state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: DetailsScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Change the opacity of the screen using a Curve based on the the animation's
        // value
        return FadeTransition(
          opacity:
              CurveTween(curve: Curves.easeInOutCirc).animate(animation),
          child: child,
        );
      },
    );
  },
),
```

For a complete example, see the [transition animations
sample](https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/transition_animations.dart).

For more information on animations in Flutter, visit the
[Animations](https://docs.flutter.dev/development/ui/animations) page on
flutter.dev.
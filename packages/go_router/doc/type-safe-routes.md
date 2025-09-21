Instead of using URL strings to navigate, go_router supports
type-safe routes using the go_router_builder package.

To get started, add [go_router_builder][], [build_runner][], and
[build_verify][] to the dev_dependencies section of your pubspec.yaml:

```yaml
dev_dependencies:
  go_router_builder: any
  build_runner: any
  build_verify: any
```

Then extend the [GoRouteData](https://pub.dev/documentation/go_router/latest/go_router/GoRouteData-class.html) class for each route in your app and add the
TypedGoRoute annotation:

```dart
import 'package:go_router/go_router.dart';

part 'go_router_builder.g.dart';

@TypedGoRoute<HomeScreenRoute>(
    path: '/',
    routes: [
      TypedGoRoute<SongRoute>(
        path: 'song/:id',
      )
    ]
)
@immutable
class HomeScreenRoute extends GoRouteData with _$HomeScreenRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HomeScreen();
  }
}

@immutable
class SongRoute extends GoRouteData with _$SongRoute {
  final int id;

  const SongRoute({
    required this.id,
  });

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SongScreen(songId: id.toString());
  }
}
```

To build the generated files (ending in .g.dart), use the build_runner command:

```
flutter pub global activate build_runner
flutter pub run build_runner build
```

To navigate, construct a GoRouteData object with the required parameters and
call go():

```
TextButton(
  onPressed: () {
    const SongRoute(id: 2).go(context);
  },
  child: const Text('Go to song 2'),
),
```

For more information, visit the [go_router_builder
package documentation](https://pub.dev/documentation/go_router_builder/latest/).

[go_router_builder]: https://pub.dev/packages/go_router_builder
[build_runner]: https://pub.dev/packages/build_runner
[build_verify]: https://pub.dev/packages/build_verify

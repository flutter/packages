# Stager

Stager enables rapid Flutter development and encourages good architectural practices by allowing developers quickly launch and develop isolated portions of an app.

Stager can accelerate your development workflow for widgets that:

- Have multiple states (empty, error, loading, etc.) that would otherwise require code changes to trigger.
- Are cumbersome to navigate to.
- Are hidden behind a feature flag.
- Behave differently based on external state (e.g., the type of currently logged-in user).

A Stager app for a ListView displaying forum-style posts:

![example app demo](https://user-images.githubusercontent.com/581764/181614468-cbb89cbe-d16a-44bf-831e-47139ce3a7c0.gif)

## Concepts

### Scene

The most important class in Stager is the Scene class. A Scene is a simple, self-contained unit of UI. Scenes make it easy to focus on a single widget or page to greatly increase development velocity by isolating them from the rest of your app and allowing fine control of dependencies.

A Scene has three parts:

#### `title`

The name of the Scene.

#### `setUp`

A function that is called once before the Scene is displayed. This will generally be where you configure your widget's dependencies.

#### `build`

A function that constructs your widget.

### StagerApp

A StagerApp displays a list of Scenes, allow the user to select from all available Scenes. Because Scenes can contain their own Navigators, the StagerApp overlays a back button on top of the Scenes.

## Demo

See the example directory for a demo that highlights some of the useful things Stager allows you to do, including:

1. The ability to alter environment settings (dark/light mode, text size, etc.) that would otherwise require
a trip to the Settings app or require booting up another emulator/simulator or device.
1. The ability to reuse Scenes in widget tests. If you aren't already writing widget tests, Scenes make it **very** easy
to start.
1. The ability to quickly move between different states (empty, loading, etc.) without having to make changes to app code
to "fake" those states.
1. The ability to easily develop a hard-to-reach screens.

## Use

Imagine you have the following widget buried deep in your application:

```dart
class PostsList extends StatefulWidget {
  const PostsList({super.key});

  @override
  State<PostsList> createState() => _PostsListState();
}

class _PostsListState extends State<PostsList> {
  late Future<List<Post>> _fetchPostsFuture;

  @override
  void initState() {
    super.initState();
    // The Api dependency is injected here by package:provider.
    _fetchPostsFuture = Provider.of<Api>(context, listen: false).fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
      ),
      body: FutureBuilder(
        future: _fetchPostsFuture,
        builder: (context, snapshot) {
          // If we're waiting for the Future to complete, show a loading state.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // If the Future has an error, show an error state.
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error'),
            );
          }

          // If the Future completed successfully but there are no posts, show an empty state.
          final posts = snapshot.data;
          if (posts == null || posts.isEmpty) {
            return const Center(
              child: Text('No posts'),
            );
          }

          // If we have posts, show them in a ListView.
          return ListView.builder(
            itemBuilder: (context, index) => PostCard(
              post: posts[index],
            ),
            itemCount: posts.length,
          );
        },
      ),
    );
  }
}
```

Normally, exercising all states in this widget would involve:

1. Building and launching the full app.
2. Navigating to this page.
3. Editing the code to force display of the states we want to exercise, either by constructing a fake `Future<List<Post>>` or commenting out the various conditional checks in the FutureBuilder's `builder` function.

Scenes present a better way to do this.

### Building a Scene

We can create a Scene for each state we want to show. For example, a Scene showing the empty state might look something like:

```dart
class FakeApi implements Api {
  @override
  Future<List<Post>> fetchPosts() async => [];
}

class EmptyScene extends Scene {
  @override
  String get title => 'No Posts';

  @override
  Widget build() {
    return MaterialApp(
      home: Provider<Api>.value(
        value: FakeApi(),
        child: const PostsList(),
      ),
    );
  }
}
```

See the example project for more scenes.

### Running a StagerApp

To generate the `StagerApp`, run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate a `my_scenes.stager_app.dart` file, which contains a `main` function that creates your Scenes and launches a StagerApp. For the above Scene, it would look something like:

```dart
Future<void> main() async {
  final scenes = [
    EmptyScene(),
  ];

  if (const String.fromEnvironment('Scene').isNotEmpty) {
    const sceneName = String.fromEnvironment('Scene');
    final scene = scenes.firstWhere((scene) => scene.title == sceneName);
    await scene.setUp();
    runApp(StagerApp(scenes: [scene]));
  } else {
    runApp(StagerApp(scenes: scenes));
  }
}
```

This can be run using:

```bash
flutter run -t path/to/my_scenes.stager_app.dart
```

You can launch to a specific scene by providing the name of the scene as an argument:

```bash
flutter run -t path/to/my_scenes.stager_app.dart --dart-define='Scene=No Posts'
```

## Testing

You may notice that these names are very similar to Flutter testing functions. This is intentional – Scenes are very easy to reuse in tests. Writing Scenes for your widgets can be a great way to start writing widget tests or to expand your widget test coverage. A widget test using a Scene can be as simple as:

```dart
testWidgets('shows an empty state', (WidgetTester tester) async {
  final scene = EmptyListScene();
  await scene.setUp();

  await tester.pumpWidget(scene.build());

  expect(find.text('No posts'), findsOneWidget);
});
```

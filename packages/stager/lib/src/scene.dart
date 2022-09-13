import 'package:flutter/widgets.dart';

/// The central class of Stager, used to demonstrate a single piece of UI.
///
/// Use [setUp] to configure dependencies and [build] to create the Widget you
/// would like to develop or demo. You may find yourself wanting to use the
/// same [build] implementation with different [setUp] implementations (or vice
/// versa). In these cases, you can create a base Scene class defines the code
/// you wish to share and extend that. The following example defines a shared
/// base Scene that is extended to configure the Api dependency in different
/// ways while sharing the same [build] implementation.
///
/// ```
/// @GenerateMocks([Api])
/// abstract class BasePostsListScene extends Scene {
///   late MockApi mockApi;
///
///   @override
///   Widget build() {
///     return EnvironmentAwareApp(
///       home: Provider<Api>.value(
///         value: mockApi,
///         child: const PostsList(),
///       ),
///     );
///   }
///
///   @override
///   Future<void> setUp() async {
///     mockApi = MockApi();
///   }
/// }
///
/// class EmptyListScene extends BasePostsListScene {
///   @override
///   String get title => 'Empty List';
///
///   @override
///   Future<void> setUp() async {
///     await super.setUp();
///     when(mockApi.fetchPosts()).thenAnswer((_) async => []);
///   }
/// }
///
/// class WithPostsScene extends BasePostsListScene {
///   @override
///   String get title => 'With Posts';
///
///   @override
///   Future<void> setUp() async {
///     await super.setUp();
///     when(mockApi.fetchPosts()).thenAnswer((_) async => Post.fakePosts);
///   }
/// }
/// ```
///
abstract class Scene {
  /// This Scene's name in the [StagerApp]'s list of scenes.
  ///
  /// Scenes without a [title] will not be displayed in the [StagerApp]'s list
  /// of scenes.
  String get title;

  /// Used to configure this Scene's dependencies.
  ///
  /// Analogous to StatefulWidget's `initState`, this is called once at app
  /// launch.
  Future<void> setUp() async {}

  /// Creates the widget tree for this Scene.
  ///
  /// This is called on every rebuild, including by Hot Reload.
  Widget build();
}

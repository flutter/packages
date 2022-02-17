import 'package:adaptive_navigation/adaptive_navigation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  static const title = 'GoRouter Example: Shared Scaffold';

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
        title: title,
      );

  late final _router = GoRouter(
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => _build(const Page1View()),
      ),
      GoRoute(
        path: '/page2',
        builder: (context, state) => _build(const Page2View()),
      ),
    ],
    errorBuilder: (context, state) => _build(ErrorView(state.error!)),

    // use the navigatorBuilder to keep the SharedScaffold from being animated
    // as new pages as shown; wrappiong that in single-page Navigator at the
    // root provides an Overlay needed for the adaptive navigation scaffold and
    // a root Navigator to show the About box
    navigatorBuilder: (context, state, child) => Navigator(
      onPopPage: (route, dynamic result) {
        route.didPop(result);
        return false; // don't pop the single page on the root navigator
      },
      pages: [
        MaterialPage<void>(
          child: state.error != null
              ? ErrorScaffold(body: child)
              : SharedScaffold(
                  selectedIndex: state.subloc == '/' ? 0 : 1,
                  body: child,
                ),
        ),
      ],
    ),
  );

  // wrap the view widgets in a Scaffold to get the exit animation just right on
  // the page being replaced
  Widget _build(Widget child) => Scaffold(body: child);
}

class SharedScaffold extends StatefulWidget {
  const SharedScaffold({
    required this.selectedIndex,
    required this.body,
    Key? key,
  }) : super(key: key);

  final int selectedIndex;
  final Widget body;

  @override
  State<SharedScaffold> createState() => _SharedScaffoldState();
}

class _SharedScaffoldState extends State<SharedScaffold> {
  @override
  Widget build(BuildContext context) => AdaptiveNavigationScaffold(
        selectedIndex: widget.selectedIndex,
        destinations: const [
          AdaptiveScaffoldDestination(title: 'Page 1', icon: Icons.first_page),
          AdaptiveScaffoldDestination(title: 'Page 2', icon: Icons.last_page),
          AdaptiveScaffoldDestination(title: 'About', icon: Icons.info),
        ],
        appBar: AdaptiveAppBar(title: const Text(App.title)),
        navigationTypeResolver: (context) =>
            _drawerSize ? NavigationType.drawer : NavigationType.bottom,
        onDestinationSelected: (index) async {
          // if there's a drawer, close it
          if (_drawerSize) Navigator.pop(context);

          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/page2');
              break;
            case 2:
              final packageInfo = await PackageInfo.fromPlatform();
              showAboutDialog(
                context: context,
                applicationName: packageInfo.appName,
                applicationVersion: 'v${packageInfo.version}',
                applicationLegalese: 'Copyright © 2022, Acme, Corp.',
              );
              break;
            default:
              throw Exception('Invalid index');
          }
        },
        body: widget.body,
      );

  bool get _drawerSize => MediaQuery.of(context).size.width >= 600;
}

class Page1View extends StatelessWidget {
  const Page1View({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/page2'),
              child: const Text('Go to page 2'),
            ),
          ],
        ),
      );
}

class Page2View extends StatelessWidget {
  const Page2View({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go to home page'),
            ),
          ],
        ),
      );
}

class ErrorScaffold extends StatelessWidget {
  const ErrorScaffold({
    required this.body,
    Key? key,
  }) : super(key: key);

  final Widget body;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AdaptiveAppBar(title: const Text('Page Not Found')),
        body: body,
      );
}

class ErrorView extends StatelessWidget {
  const ErrorView(this.error, {Key? key}) : super(key: key);
  final Exception error;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SelectableText(error.toString()),
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text('Home'),
            ),
          ],
        ),
      );
}

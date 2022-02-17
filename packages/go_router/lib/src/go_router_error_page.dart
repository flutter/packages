// ignore_for_file: diagnostic_describe_all_properties

import 'package:flutter/widgets.dart';
import '../go_router.dart';

/// Default error page implementation for WidgetsApp.
class GoRouterErrorScreen extends StatelessWidget {
  /// Provide an exception to this page for it to be displayed.
  const GoRouterErrorScreen(this.error, {Key? key}) : super(key: key);

  /// The exception to be displayed.
  final Exception? error;

  static const _white = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Page Not Found',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(error?.toString() ?? 'page not found'),
              const SizedBox(height: 16),
              _Button(
                onPressed: () => context.go('/'),
                child: const Text(
                  'Go to home page',
                  style: TextStyle(color: _white),
                ),
              ),
            ],
          ),
        ),
      );
}

class _Button extends StatefulWidget {
  const _Button({
    required this.onPressed,
    required this.child,
    Key? key,
  }) : super(key: key);

  final VoidCallback onPressed;
  final Widget child;

  @override
  State<_Button> createState() => _ButtonState();
}

class _ButtonState extends State<_Button> {
  late final Color _color;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _color = (context as Element)
            .findAncestorWidgetOfExactType<WidgetsApp>()
            ?.color ??
        const Color(0xFF2196F3); // blue
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          padding: const EdgeInsets.all(8),
          color: _color,
          child: widget.child,
        ),
      );
}

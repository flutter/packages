import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

void main() {
  runApp(const MaterialApp(home: PointerInterceptorIOSExample()));
}

class _DummyPlatformView extends StatelessWidget {
  const _DummyPlatformView();

  @override
  Widget build(BuildContext context) {
    const String viewType = 'dummy_platform_view';
    final Map<String, dynamic> creationParams = <String, dynamic>{};

    return UiKitView(
      viewType: viewType,
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}

/// Example flutter app with a button overlaying the native view
class PointerInterceptorIOSExample extends StatefulWidget {
  /// Constructor
  const PointerInterceptorIOSExample({super.key});

  @override
  State<StatefulWidget> createState() {
    return _PointerInterceptorIOSExampleState();
  }
}

class _PointerInterceptorIOSExampleState
    extends State<PointerInterceptorIOSExample> {
  bool _buttonTapped = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          const _DummyPlatformView(),
          PointerInterceptor(
              child: TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: _buttonTapped
                      ? const Text('Tapped')
                      : const Text('Initial'),
                  onPressed: () {
                    setState(() {
                      _buttonTapped = !_buttonTapped;
                    });
                  })),
        ],
      ),
    ));
  }
}

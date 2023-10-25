import 'package:flutter/material.dart';
import 'package:pointer_interceptor_ios/pointer_interceptor_ios.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

void main() {
  // platformViewRegistry.registerViewFactory('plugins.flutter.dev/pointer_interceptor_ios', viewFactory)
  runApp(const MaterialApp(home: PointerInterceptorIOSExample()));
}

class DummyPlatformView extends StatelessWidget {
  const DummyPlatformView({super.key});

  @override
  Widget build(BuildContext context) {
    // This is used in the platform side to register the view.
    const String viewType = 'dummy_platform_view';
    // Pass parameters to the platform side.
    final Map<String, dynamic> creationParams = <String, dynamic>{};

    return UiKitView(
      viewType: viewType,
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}

class PointerInterceptorIOSExample extends StatefulWidget {
  const PointerInterceptorIOSExample({super.key});

  @override
  State<StatefulWidget> createState() {
    return PointerInterceptorIOSExampleState();
  }
}

class PointerInterceptorIOSExampleState
    extends State<PointerInterceptorIOSExample> {

  var buttonTapped = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          const DummyPlatformView(),
          PointerInterceptorPluginIOS().buildWidget(
              debug: true,
              child: TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: buttonTapped
                      ? const Text("Tapped")
                      : const Text("Initial"),
                  onPressed: () {
                    setState(() {
                      buttonTapped = !buttonTapped;
                    });
                  })),
        ],
      ),
    ));
  }
}

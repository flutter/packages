import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MinimalPlatformViewReproApp());
}

class MinimalPlatformViewReproApp extends StatelessWidget {
  const MinimalPlatformViewReproApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SurfaceView PlatformView Repro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ReproHome(),
    );
  }
}

class ReproHome extends StatefulWidget {
  const ReproHome({super.key});

  @override
  State<ReproHome> createState() => _ReproHomeState();
}

class _ReproHomeState extends State<ReproHome> {
  bool _useHybridComposition = true;

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    final Size size = MediaQuery.of(context).size;
    final double aspectRatio =
        orientation == Orientation.landscape ? (4 / 3) : (3 / 4);

    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    debugPrint(
      'DART REBUILD -> Orientation: $orientation, size: $size, aspectRatio: $aspectRatio (timestamp: ${nowMs}ms)',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minimal SurfaceView Repro (No Camera)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Mode: ${_useHybridComposition ? "Performance (SurfaceView / AndroidViewSurface)" : "Compatible (AndroidView)"}',
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _useHybridComposition = !_useHybridComposition;
                    });
                  },
                  child: const Text('Toggle Mode'),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Rotate your Tablet! Look for the green X / grid. If it starts smaller and expands after rotation, you will visually see the green border snap/scale.',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 3),
                  ),
                  child: _useHybridComposition
                      ? _buildHybridCompositionView()
                      : _buildStandardAndroidView(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHybridCompositionView() {
    const String viewType = 'repro_surface_view';
    const Map<String, dynamic> creationParams = <String, dynamic>{};

    return PlatformViewLink(
      viewType: viewType,
      surfaceFactory:
          (BuildContext context, PlatformViewController controller) {
            return AndroidViewSurface(
              controller: controller as AndroidViewController,
              gestureRecognizers:
                  const <Factory<OneSequenceGestureRecognizer>>{},
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
            );
          },
      onCreatePlatformView: (PlatformViewCreationParams params) {
        return PlatformViewsService.initSurfaceAndroidView(
          id: params.id,
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          onFocus: () {
            params.onFocusChanged(true);
          },
        )
          ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
          ..create();
      },
    );
  }

  Widget _buildStandardAndroidView() {
    return const AndroidView(
      viewType: 'repro_surface_view',
      layoutDirection: TextDirection.ltr,
    );
  }
}

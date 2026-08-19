import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MinimalPlatformViewReproApp());
}

enum FlutterPlatformViewMode {
  tlhc('TLHC (initSurfaceAndroidView)'),
  hc('HC (initExpensiveAndroidView)'),
  hcpp('HC++ (initAndroidView)'),
  androidView('Standard AndroidView Widget');

  const FlutterPlatformViewMode(this.label);
  final String label;
}

enum NativeViewMode {
  surfaceView('SurfaceView (Green)', 'surface'),
  textureView('TextureView (Cyan)', 'texture');

  const NativeViewMode(this.label, this.paramValue);
  final String label;
  final String paramValue;
}

enum AspectRatioPreset {
  autoOrientation('Auto (Device Orientation)'),
  ar4_3('4:3'),
  ar3_4('3:4'),
  ar16_9('16:9'),
  ar9_16('9:16'),
  ar1_1('1:1');

  const AspectRatioPreset(this.label);
  final String label;
}

class MinimalPlatformViewReproApp extends StatelessWidget {
  const MinimalPlatformViewReproApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Platform View Repro (HC / TLHC / HC++)',
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
  FlutterPlatformViewMode _platformViewMode = FlutterPlatformViewMode.tlhc;
  NativeViewMode _nativeViewMode = NativeViewMode.surfaceView;
  AspectRatioPreset _aspectRatioPreset = AspectRatioPreset.autoOrientation;
  int _viewKeyCounter = 0;

  double _getAspectRatio(Orientation orientation) {
    switch (_aspectRatioPreset) {
      case AspectRatioPreset.autoOrientation:
        return orientation == Orientation.landscape ? (4 / 3) : (3 / 4);
      case AspectRatioPreset.ar4_3:
        return 4 / 3;
      case AspectRatioPreset.ar3_4:
        return 3 / 4;
      case AspectRatioPreset.ar16_9:
        return 16 / 9;
      case AspectRatioPreset.ar9_16:
        return 9 / 16;
      case AspectRatioPreset.ar1_1:
        return 1.0;
    }
  }

  void _recreateView() {
    setState(() {
      _viewKeyCounter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    final Size size = MediaQuery.of(context).size;
    final double aspectRatio = _getAspectRatio(orientation);

    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    debugPrint(
      'DART REBUILD -> PV Mode: ${_platformViewMode.name}, Native: ${_nativeViewMode.name}, Orientation: $orientation, size: $size, aspectRatio: ${aspectRatio.toStringAsFixed(2)} (timestamp: ${nowMs}ms)',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Platform View Jank Repro'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // 1. Flutter Platform View Mode Selector
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        '1. Flutter Platform View Mode:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: FlutterPlatformViewMode.values.map((FlutterPlatformViewMode mode) {
                          final bool isSelected = _platformViewMode == mode;
                          return ChoiceChip(
                            label: Text(mode.label),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              if (selected) {
                                setState(() {
                                  _platformViewMode = mode;
                                  _viewKeyCounter++;
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Native View Type Selector
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        '2. Native View Type (matches CameraX mode):',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: NativeViewMode.values.map((NativeViewMode mode) {
                          final bool isSelected = _nativeViewMode == mode;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(mode.label),
                              selected: isSelected,
                              onSelected: (bool selected) {
                                if (selected) {
                                  setState(() {
                                    _nativeViewMode = mode;
                                    _viewKeyCounter++;
                                  });
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Aspect Ratio Selector (Dynamic resize test)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        '3. Dynamic Aspect Ratio (Test resize without rotating):',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: AspectRatioPreset.values.map((AspectRatioPreset preset) {
                          final bool isSelected = _aspectRatioPreset == preset;
                          return ChoiceChip(
                            label: Text(preset.label),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              if (selected) {
                                setState(() {
                                  _aspectRatioPreset = preset;
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Active: ${_platformViewMode.name.toUpperCase()} + ${_nativeViewMode.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  OutlinedButton.icon(
                    onPressed: _recreateView,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Recreate View'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Platform View Area
              Center(
                child: SizedBox(
                  height: 380,
                  child: AspectRatio(
                    aspectRatio: aspectRatio,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red, width: 3),
                      ),
                      child: KeyedSubtree(
                        key: ValueKey<String>(
                          'pv_${_platformViewMode.name}_${_nativeViewMode.name}_$_viewKeyCounter',
                        ),
                        child: _buildPlatformView(),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '• Red border = Flutter Container\n• Green/Cyan border & X = Native Android Surface\n• Watch for stretching/snapping when rotating device or tapping aspect ratios above.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlatformView() {
    switch (_platformViewMode) {
      case FlutterPlatformViewMode.tlhc:
        return _buildTlhcView();
      case FlutterPlatformViewMode.hc:
        return _buildHcView();
      case FlutterPlatformViewMode.hcpp:
        return _buildHcppView();
      case FlutterPlatformViewMode.androidView:
        return _buildStandardAndroidView();
    }
  }

  Map<String, dynamic> get _creationParams => <String, dynamic>{
        'nativeViewType': _nativeViewMode.paramValue,
      };

  /// TLHC (Texture Layer Hybrid Composition) -> initSurfaceAndroidView
  Widget _buildTlhcView() {
    const String viewType = 'repro_surface_view';

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
          creationParams: _creationParams,
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

  /// HC (Hybrid Composition) -> initExpensiveAndroidView
  Widget _buildHcView() {
    const String viewType = 'repro_surface_view';

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
        return PlatformViewsService.initExpensiveAndroidView(
          id: params.id,
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: _creationParams,
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

  /// HC++ (Hybrid Composition++ / initAndroidView)
  Widget _buildHcppView() {
    const String viewType = 'repro_surface_view';

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
        return PlatformViewsService.initAndroidView(
          id: params.id,
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: _creationParams,
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

  /// Standard AndroidView widget
  Widget _buildStandardAndroidView() {
    return AndroidView(
      viewType: 'repro_surface_view',
      layoutDirection: TextDirection.ltr,
      creationParams: _creationParams,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}


import 'dart:async';

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
  textureView('TextureView (Cyan)', 'texture'),
  redBox('FrameLayout (Red)', 'red_box');

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

enum LayoutContainerMode {
  cameraApp('Camera App (Expanded in Column)'),
  fixedHeight('Fixed Height (380px)');

  const LayoutContainerMode(this.label);
  final String label;
}

enum AsyncSimulationMode {
  syncMediaQuery('Synchronous (MediaQuery)'),
  delayedStream('Simulated Async Delay (100-600ms)'),
  invertedBug('Forced Inverted (Simulate Race Bug)');

  const AsyncSimulationMode(this.label);
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

class _ReproHomeState extends State<ReproHome> with WidgetsBindingObserver {
  FlutterPlatformViewMode _platformViewMode = FlutterPlatformViewMode.hcpp;
  NativeViewMode _nativeViewMode = NativeViewMode.redBox;
  AspectRatioPreset _aspectRatioPreset = AspectRatioPreset.autoOrientation;
  LayoutContainerMode _layoutMode = LayoutContainerMode.cameraApp;
  AsyncSimulationMode _asyncMode = AsyncSimulationMode.delayedStream;

  int _asyncDelayMs = 300;
  bool _recreateOnLifecycle = true;
  double _baseBufferAspectRatio = 4 / 3; // Standard 320x240 landscape camera buffer
  int _viewKeyCounter = 0;

  Orientation? _lastObservedOrientation;
  DeviceOrientation _simulatedDeviceOrientation = DeviceOrientation.landscapeLeft;
  Timer? _orientationTimer;
  String _lastLifecycleEvent = 'none';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _orientationTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lastLifecycleEvent = '${state.name} @ ${DateTime.now().toIso8601String().substring(11, 19)}';
    debugPrint('REPRO LIFECYCLE -> state: $state');
    if (_recreateOnLifecycle && state == AppLifecycleState.resumed) {
      debugPrint('REPRO LIFECYCLE -> Recreating view on resumed (simulating camera example lifecycle)');
      _recreateView();
    }
  }

  void _recreateView() {
    setState(() {
      _viewKeyCounter++;
    });
  }

  void _checkOrientationChange(Orientation currentOrientation) {
    if (_lastObservedOrientation == currentOrientation) {
      return;
    }
    _lastObservedOrientation = currentOrientation;

    if (_asyncMode == AsyncSimulationMode.syncMediaQuery) {
      _simulatedDeviceOrientation = currentOrientation == Orientation.landscape
          ? DeviceOrientation.landscapeLeft
          : DeviceOrientation.portraitUp;
    } else if (_asyncMode == AsyncSimulationMode.delayedStream) {
      _orientationTimer?.cancel();
      _orientationTimer = Timer(Duration(milliseconds: _asyncDelayMs), () {
        if (mounted) {
          setState(() {
            _simulatedDeviceOrientation = currentOrientation == Orientation.landscape
                ? DeviceOrientation.landscapeLeft
                : DeviceOrientation.portraitUp;
          });
          debugPrint('REPRO ASYNC -> Orientation stream event arrived: $_simulatedDeviceOrientation');
        }
      });
    } else if (_asyncMode == AsyncSimulationMode.invertedBug) {
      // Inverted: simulate native orientation event getting stuck or desynced
      _simulatedDeviceOrientation = currentOrientation == Orientation.landscape
          ? DeviceOrientation.portraitUp
          : DeviceOrientation.landscapeLeft;
    }
  }

  double _getFinalAspectRatio(Orientation orientation) {
    if (_aspectRatioPreset != AspectRatioPreset.autoOrientation) {
      switch (_aspectRatioPreset) {
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
        case AspectRatioPreset.autoOrientation:
          break;
      }
    }

    if (_asyncMode == AsyncSimulationMode.syncMediaQuery) {
      return orientation == Orientation.landscape
          ? _baseBufferAspectRatio
          : (1 / _baseBufferAspectRatio);
    }

    // CameraPreview formula:
    // isLandscape = [landscapeLeft, landscapeRight].contains(deviceOrientation)
    final bool isLandscape = <DeviceOrientation>[
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ].contains(_simulatedDeviceOrientation);

    return isLandscape ? _baseBufferAspectRatio : (1 / _baseBufferAspectRatio);
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    final Size size = MediaQuery.of(context).size;
    _checkOrientationChange(orientation);

    final double aspectRatio = _getFinalAspectRatio(orientation);

    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    debugPrint(
      'DART REBUILD -> PV: ${_platformViewMode.name}, Native: ${_nativeViewMode.name}, '
      'Orientation: $orientation, SimOrientation: ${_simulatedDeviceOrientation.name}, '
      'aspectRatio: ${aspectRatio.toStringAsFixed(3)} ($nowMs ms)',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Platform View Jank & Race Repro'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: <Widget>[
          IconButton(
            onPressed: _recreateView,
            icon: const Icon(Icons.refresh),
            tooltip: 'Force Recreate View',
          ),
        ],
      ),
      body: _layoutMode == LayoutContainerMode.cameraApp
          ? _buildCameraAppLayout(aspectRatio, orientation, size)
          : _buildFixedHeightLayout(aspectRatio, orientation, size),
    );
  }

  /// Full layout simulating camera_android_camerax/example:
  /// Column -> Expanded -> Container -> Center -> AspectRatio -> Stack
  Widget _buildCameraAppLayout(double aspectRatio, Orientation orientation, Size size) {
    return Column(
      children: <Widget>[
        // Telemetry header
        _buildTelemetryBanner(aspectRatio, orientation, size),

        // Camera Preview Area (Expanded inside Column with Center)
        Expanded(
          child: Container(
            color: Colors.black,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Center(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return AspectRatio(
                      aspectRatio: aspectRatio,
                      child: ClipRect(
                        child: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            KeyedSubtree(
                              key: ValueKey<String>(
                                'pv_${_platformViewMode.name}_${_nativeViewMode.name}_$_viewKeyCounter',
                              ),
                              child: _buildPlatformView(),
                            ),
                            // Real-time measurement overlay
                            Positioned(
                              top: 8,
                              left: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Container: ${constraints.maxWidth.toInt()}x${constraints.maxHeight.toInt()} | '
                                  'Ratio: ${aspectRatio.toStringAsFixed(3)}\n'
                                  'MediaQuery: ${orientation.name} | SimSensor: ${_simulatedDeviceOrientation.name}',
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),

        // Bottom Configuration Panel (Scrollable)
        Container(
          height: 250,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: _buildConfigurationControls(),
          ),
        ),
      ],
    );
  }

  /// Fixed height layout (original repro)
  Widget _buildFixedHeightLayout(double aspectRatio, Orientation orientation, Size size) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildTelemetryBanner(aspectRatio, orientation, size),
            const SizedBox(height: 8),
            _buildConfigurationControls(),
            const SizedBox(height: 12),

            // Fixed Height Platform View Area
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
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryBanner(double aspectRatio, Orientation orientation, Size size) {
    final bool isMismatch = (orientation == Orientation.landscape &&
            !_simulatedDeviceOrientation.name.contains('landscape')) ||
        (orientation == Orientation.portrait &&
            !_simulatedDeviceOrientation.name.contains('portrait'));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: isMismatch ? Colors.deepOrange : Colors.indigo.shade800,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'UI: ${orientation.name.toUpperCase()} (${size.width.toInt()}x${size.height.toInt()}) '
            '| Ratio: ${aspectRatio.toStringAsFixed(3)}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
          Text(
            isMismatch ? '⚠️ DESYNCED' : '✓ SYNCED',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurationControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // 1. Layout Mode
        const Text('1. Container Layout Constraints:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        Wrap(
          spacing: 6,
          children: LayoutContainerMode.values.map((LayoutContainerMode mode) {
            return ChoiceChip(
              label: Text(mode.label, style: const TextStyle(fontSize: 11)),
              selected: _layoutMode == mode,
              onSelected: (bool selected) {
                if (selected) setState(() => _layoutMode = mode);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 8),

        // 2. Async Simulation Mode
        const Text('2. CameraX Asynchrony Simulation:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        Wrap(
          spacing: 6,
          children: AsyncSimulationMode.values.map((AsyncSimulationMode mode) {
            return ChoiceChip(
              label: Text(mode.label, style: const TextStyle(fontSize: 11)),
              selected: _asyncMode == mode,
              onSelected: (bool selected) {
                if (selected) setState(() => _asyncMode = mode);
              },
            );
          }).toList(),
        ),
        if (_asyncMode == AsyncSimulationMode.delayedStream)
          Row(
            children: <Widget>[
              const Text('Delay: ', style: TextStyle(fontSize: 11)),
              for (final int delay in <int>[100, 300, 600, 1000])
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ActionChip(
                    label: Text('${delay}ms', style: const TextStyle(fontSize: 11)),
                    backgroundColor: _asyncDelayMs == delay ? Colors.blue.shade100 : null,
                    onPressed: () => setState(() => _asyncDelayMs = delay),
                  ),
                ),
            ],
          ),
        const SizedBox(height: 8),

        // Aspect Ratio Override
        const Text('Aspect Ratio Preset:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        Wrap(
          spacing: 6,
          children: AspectRatioPreset.values.map((AspectRatioPreset preset) {
            return ChoiceChip(
              label: Text(preset.label, style: const TextStyle(fontSize: 11)),
              selected: _aspectRatioPreset == preset,
              onSelected: (bool selected) {
                if (selected) setState(() => _aspectRatioPreset = preset);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 8),

        // 3. Lifecycle Recreate & Invert
        Row(
          children: <Widget>[
            Checkbox(
              value: _recreateOnLifecycle,
              onChanged: (bool? val) => setState(() => _recreateOnLifecycle = val ?? false),
            ),
            const Expanded(
              child: Text(
                'Recreate view on resumed (Mirrors Camera example lifecycle bug)',
                style: TextStyle(fontSize: 11),
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          children: <Widget>[
            OutlinedButton.icon(
              icon: const Icon(Icons.swap_horiz, size: 14),
              label: const Text('Invert Sensor Now', style: TextStyle(fontSize: 11)),
              onPressed: () {
                setState(() {
                  _simulatedDeviceOrientation =
                      _simulatedDeviceOrientation == DeviceOrientation.landscapeLeft
                          ? DeviceOrientation.portraitUp
                          : DeviceOrientation.landscapeLeft;
                });
              },
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.crop_rotate, size: 14),
              label: Text(
                'Base Ratio: ${_baseBufferAspectRatio == (4 / 3) ? "4:3 (Landscape)" : "3:4 (Portrait)"}',
                style: const TextStyle(fontSize: 11),
              ),
              onPressed: () {
                setState(() {
                  _baseBufferAspectRatio = _baseBufferAspectRatio == (4 / 3) ? (3 / 4) : (4 / 3);
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 4. Flutter Platform View Mode
        const Text('3. Flutter Platform View Mode:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        Wrap(
          spacing: 6,
          children: FlutterPlatformViewMode.values.map((FlutterPlatformViewMode mode) {
            return ChoiceChip(
              label: Text(mode.label, style: const TextStyle(fontSize: 11)),
              selected: _platformViewMode == mode,
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
        const SizedBox(height: 8),

        // 5. Native View Type
        const Text('4. Native View Type:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        Wrap(
          spacing: 6,
          children: NativeViewMode.values.map((NativeViewMode mode) {
            return ChoiceChip(
              label: Text(mode.label, style: const TextStyle(fontSize: 11)),
              selected: _nativeViewMode == mode,
              onSelected: (bool selected) {
                if (selected) {
                  setState(() {
                    _nativeViewMode = mode;
                    _viewKeyCounter++;
                  });
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 8),

        Text(
          'Last Lifecycle: $_lastLifecycleEvent',
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
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

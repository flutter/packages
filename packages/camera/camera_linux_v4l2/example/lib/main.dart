// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// Example app for the camera_linux_v4l2 plugin.
class MyApp extends StatefulWidget {
  /// Default Constructor
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _cameraInfo = 'Unknown';
  List<CameraDescription> _cameras = <CameraDescription>[];
  int _cameraIndex = 0;
  int _cameraId = -1;
  bool _initializing = false;
  bool _initialized = false;
  Size? _previewSize;
  ResolutionPreset _resolutionPreset = ResolutionPreset.medium;
  StreamSubscription<CameraErrorEvent>? _errorStreamSubscription;
  StreamSubscription<CameraClosingEvent>? _cameraClosingStreamSubscription;
  StreamSubscription<CameraImageData>? _imageStreamSubscription;
  int _streamedFrameCount = 0;
  String _lastFrameSummary = '';

  @override
  void initState() {
    super.initState();
    _fetchCameras();
  }

  @override
  void dispose() {
    final Future<void>? imageStreamCancellation = _imageStreamSubscription?.cancel();
    _imageStreamSubscription = null;
    unawaited(
      _disposeCurrentCamera(updateUi: false, imageStreamCancellation: imageStreamCancellation),
    );
    unawaited(_errorStreamSubscription?.cancel());
    _errorStreamSubscription = null;
    unawaited(_cameraClosingStreamSubscription?.cancel());
    _cameraClosingStreamSubscription = null;
    super.dispose();
  }

  Future<void> _fetchCameras() async {
    String cameraInfo;
    var cameras = <CameraDescription>[];
    var cameraIndex = 0;
    try {
      cameras = await CameraPlatform.instance.availableCameras();
      if (cameras.isEmpty) {
        cameraInfo = 'No available cameras';
      } else {
        cameraIndex = _cameraIndex % cameras.length;
        cameraInfo = 'Found camera: ${cameras[cameraIndex].name}';
      }
    } on CameraException catch (e) {
      cameraInfo = 'Failed to get cameras: ${e.code}: ${e.description}';
    }

    if (mounted) {
      setState(() {
        _cameraIndex = cameraIndex;
        _cameras = cameras;
        _cameraInfo = cameraInfo;
      });
    }
  }

  Future<void> _initializeCamera() async {
    if (!mounted || _cameras.isEmpty || _initialized || _initializing) {
      return;
    }
    setState(() {
      _initializing = true;
    });

    var cameraId = -1;
    try {
      final int cameraIndex = _cameraIndex % _cameras.length;
      final CameraDescription camera = _cameras[cameraIndex];

      cameraId = await CameraPlatform.instance.createCameraWithSettings(
        camera,
        MediaSettings(resolutionPreset: _resolutionPreset),
      );
      if (!mounted) {
        await CameraPlatform.instance.dispose(cameraId);
        return;
      }
      unawaited(_errorStreamSubscription?.cancel());
      _errorStreamSubscription = CameraPlatform.instance
          .onCameraError(cameraId)
          .listen(_onCameraError);

      unawaited(_cameraClosingStreamSubscription?.cancel());
      _cameraClosingStreamSubscription = CameraPlatform.instance
          .onCameraClosing(cameraId)
          .listen(_onCameraClosing);

      final Future<CameraInitializedEvent> initialized = CameraPlatform.instance
          .onCameraInitialized(cameraId)
          .first;

      await CameraPlatform.instance.initializeCamera(cameraId);

      final CameraInitializedEvent event = await initialized;
      if (!mounted) {
        await CameraPlatform.instance.dispose(cameraId);
        return;
      }
      _previewSize = Size(event.previewWidth, event.previewHeight);

      setState(() {
        _initialized = true;
        _cameraId = cameraId;
        _cameraIndex = cameraIndex;
        _cameraInfo = 'Capturing camera: ${camera.name}';
      });
    } on CameraException catch (e) {
      try {
        if (cameraId >= 0) {
          await CameraPlatform.instance.dispose(cameraId);
        }
      } on CameraException catch (disposeError) {
        debugPrint('Failed to dispose camera: ${disposeError.code}: ${disposeError.description}');
      }

      if (mounted) {
        setState(() {
          _initialized = false;
          _cameraId = -1;
          _cameraIndex = 0;
          _previewSize = null;
          _cameraInfo = 'Failed to initialize camera: ${e.code}: ${e.description}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _initializing = false;
        });
      } else {
        _initializing = false;
      }
    }
  }

  Future<void> _disposeCurrentCamera({
    bool updateUi = true,
    Future<void>? imageStreamCancellation,
  }) async {
    final int cameraId = _cameraId;
    final StreamSubscription<CameraImageData>? imageStreamSubscription = _imageStreamSubscription;
    _cameraId = -1;
    _initialized = false;
    _previewSize = null;
    _imageStreamSubscription = null;
    if (updateUi && mounted) {
      setState(() {});
    }

    try {
      await (imageStreamCancellation ?? imageStreamSubscription?.cancel());
    } on Object catch (error) {
      debugPrint('Failed to stop image stream: $error');
    }
    if (cameraId >= 0) {
      try {
        await CameraPlatform.instance.dispose(cameraId);
        if (mounted && _cameraId < 0) {
          setState(() {
            _cameraInfo = 'Camera disposed';
          });
        }
      } on CameraException catch (e) {
        if (mounted && _cameraId < 0) {
          setState(() {
            _cameraInfo = 'Failed to dispose camera: ${e.code}: ${e.description}';
          });
        }
      }
    }
  }

  Future<void> _toggleImageStream() async {
    if (_imageStreamSubscription != null) {
      await _stopImageStream();
      return;
    }
    if (!_initialized || _cameraId < 0) {
      return;
    }
    setState(() {
      _streamedFrameCount = 0;
      _lastFrameSummary = '';
      _imageStreamSubscription = CameraPlatform.instance.onStreamedFrameAvailable(_cameraId).listen(
        (CameraImageData frame) {
          if (!mounted) {
            return;
          }
          setState(() {
            _streamedFrameCount++;
            _lastFrameSummary =
                '${frame.width}x${frame.height} ${frame.format.group.name} '
                '(${frame.planes.first.bytes.length} bytes)';
          });
        },
      );
    });
  }

  Future<void> _stopImageStream() async {
    final StreamSubscription<CameraImageData>? sub = _imageStreamSubscription;
    if (sub == null) {
      return;
    }
    _imageStreamSubscription = null;
    await sub.cancel();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _switchCamera() async {
    if (!mounted || _cameras.isEmpty) {
      return;
    }
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    if (_initialized && _cameraId >= 0) {
      await _disposeCurrentCamera();
      await _fetchCameras();
      if (mounted && _cameras.isNotEmpty) {
        await _initializeCamera();
      }
    } else {
      await _fetchCameras();
    }
  }

  Future<void> _onResolutionChange(ResolutionPreset newValue) async {
    setState(() {
      _resolutionPreset = newValue;
    });
    if (_initialized && _cameraId >= 0) {
      await _disposeCurrentCamera();
      if (mounted) {
        await _initializeCamera();
      }
    }
  }

  void _onCameraError(CameraErrorEvent event) {
    if (mounted) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Error: ${event.description}')),
      );
      _disposeCurrentCamera();
      _fetchCameras();
    }
  }

  void _onCameraClosing(CameraClosingEvent event) {
    if (mounted) {
      _showInSnackBar('Camera is closing');
    }
  }

  void _showInSnackBar(String message) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuItem<ResolutionPreset>> resolutionItems = ResolutionPreset.values
        .map<DropdownMenuItem<ResolutionPreset>>((ResolutionPreset value) {
          return DropdownMenuItem<ResolutionPreset>(value: value, child: Text(value.toString()));
        })
        .toList();

    return MaterialApp(
      scaffoldMessengerKey: _scaffoldMessengerKey,
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Text(_cameraInfo),
            ),
            if (_cameras.isEmpty)
              ElevatedButton(
                onPressed: _fetchCameras,
                child: const Text('Re-check available cameras'),
              ),
            if (_cameras.isNotEmpty)
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  DropdownButton<ResolutionPreset>(
                    value: _resolutionPreset,
                    onChanged: _initializing
                        ? null
                        : (ResolutionPreset? value) {
                            if (value != null) {
                              _onResolutionChange(value);
                            }
                          },
                    items: resolutionItems,
                  ),
                  ElevatedButton(
                    onPressed: _initializing
                        ? null
                        : (_initialized ? _disposeCurrentCamera : _initializeCamera),
                    child: Text(
                      _initializing
                          ? 'Initializing camera'
                          : (_initialized ? 'Dispose camera' : 'Create camera'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _initialized ? _toggleImageStream : null,
                    child: Text(_imageStreamSubscription != null ? 'Stop stream' : 'Start stream'),
                  ),
                  ElevatedButton(
                    onPressed: !_initializing && _cameras.length > 1 ? _switchCamera : null,
                    child: const Text('Switch camera'),
                  ),
                ],
              ),
            const SizedBox(height: 5),
            if (_initialized && _cameraId >= 0 && _previewSize != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Align(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 500),
                    child: AspectRatio(
                      aspectRatio: _previewSize!.width / _previewSize!.height,
                      child: CameraPlatform.instance.buildPreview(_cameraId),
                    ),
                  ),
                ),
              ),
            if (_previewSize != null)
              Center(
                child: Text(
                  'Preview size: ${_previewSize!.width.toStringAsFixed(0)}x${_previewSize!.height.toStringAsFixed(0)}',
                ),
              ),
            if (_streamedFrameCount > 0)
              Center(child: Text('Streamed frames: $_streamedFrameCount ($_lastFrameSummary)')),
          ],
        ),
      ),
    );
  }
}

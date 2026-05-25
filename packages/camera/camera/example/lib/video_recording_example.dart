// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const VideoRecordingExampleApp());
}

/// Video Recording feature with custom output paths (`videoOutputPath`)
class VideoRecordingExampleApp extends StatefulWidget {
  /// Default Constructor.
  const VideoRecordingExampleApp({super.key});

  @override
  State<VideoRecordingExampleApp> createState() =>
      _VideoRecordingExampleAppState();
}

class _VideoRecordingExampleAppState extends State<VideoRecordingExampleApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vivid Video Recorder',
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F5FA),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF00E676),
          error: Color(0xFFFF1744),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF00E676),
          error: Color(0xFFFF1744),
          surface: Color(0xFF1E1E30),
        ),
        useMaterial3: true,
      ),
      home: VideoRecordingHome(
        themeMode: _themeMode,
        onThemeToggle: _toggleTheme,
      ),
    );
  }
}

/// Home widget hosting the video recording demo.
class VideoRecordingHome extends StatefulWidget {
  /// Default Constructor.
  const VideoRecordingHome({
    super.key,
    required this.themeMode,
    required this.onThemeToggle,
  });

  /// The active theme mode.
  final ThemeMode themeMode;

  /// Callback to toggle between light and dark themes.
  final VoidCallback onThemeToggle;

  @override
  State<VideoRecordingHome> createState() => _VideoRecordingHomeState();
}

class _VideoRecordingHomeState extends State<VideoRecordingHome>
    with SingleTickerProviderStateMixin {
  List<CameraDescription> _cameras = <CameraDescription>[];
  CameraController? _controller;
  XFile? _recordedVideo;
  VideoPlayerController? _videoPlayerController;

  bool _isInitializing = true;
  bool _useCustomPath = false;
  bool _audioEnabled = true;

  // Custom path options
  String _customFileName = 'custom_video_recording.mp4';
  late TextEditingController _customFileNameController;
  String? _resolvedCustomPath;

  // SnackBar / Error messaging helper
  void _showNotification(String message, {bool isError = false}) {
    final isDark = widget.themeMode == ThemeMode.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            Icon(
              isError ? Icons.error_outline : Icons.info_outline,
              color: isError ? Colors.redAccent : Colors.greenAccent,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _customFileNameController = TextEditingController(text: _customFileName);
    _bootstrapCameras();
  }

  Future<void> _bootstrapCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        await _initializeCameraController(_cameras.first);
      } else {
        _showNotification('No cameras detected on this device.', isError: true);
      }
    } catch (e) {
      _showNotification('Failed to detect cameras: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _initializeCameraController(
    CameraDescription description,
  ) async {
    final controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: _audioEnabled,
    );

    _controller = controller;

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showNotification('Camera error: ${e.description}', isError: true);
    }

    if (mounted) {
      setState(() {});
    }
  }

  /// Calculates the target custom output path where the video will be saved.
  Future<String> _getDestinationPath() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    // 1. Android
    // Although it is possible to use an absolute path like '/storage/emulated/0/Download/',
    // this is a fragile practice and may fail on many devices or Android versions due to
    // Scoped Storage restrictions. It is recommended to use path_provider to get a valid
    // and writable directory.
    if (Platform.isAndroid) {
      final String uniqueName = _customFileName.replaceFirst(
        '.mp4',
        '_$timestamp.mp4',
      );

      final Directory? externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        return '${externalDir.path}/$uniqueName';
      }

      final Directory fallbackDir = await getApplicationDocumentsDirectory();
      return '${fallbackDir.path}/$uniqueName';
    }

    // 3. iOS (Save to "On My iPhone" visible app folder)
    // Note: Ensure 'LSSupportsOpeningDocumentsInPlace' and 'UISupportsDocumentBrowser'
    // are set to true in your ios/Runner/Info.plist to make this folder visible in the Files app.
    if (Platform.isIOS) {
      final Directory appDocDir = await getApplicationDocumentsDirectory();

      // Setup the custom directory structure within the app's documents container
      final customDirPath = '${appDocDir.path}/Movies/flutter_test';
      final destinationDir = Directory(customDirPath);

      if (!destinationDir.existsSync()) {
        destinationDir.createSync(recursive: true);
      }

      final filePath = '${destinationDir.path}/video_$timestamp.mp4';
      return filePath;
    }

    // Default fallback general path
    final Directory fallbackDir = await getApplicationDocumentsDirectory();
    return '${fallbackDir.path}/video_$timestamp.mp4';
  }

  Future<void> _startRecording() async {
    final CameraController? controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      _showNotification('Camera is not ready yet.', isError: true);
      return;
    }

    if (controller.value.isRecordingVideo) {
      return;
    }

    try {
      String? outputPath;
      if (_useCustomPath) {
        outputPath = await _getDestinationPath();
        setState(() {
          _resolvedCustomPath = outputPath;
        });
      } else {
        setState(() {
          _resolvedCustomPath = null;
        });
      }

      // Invokes startVideoRecording with the custom path options!
      await controller.startVideoRecording(videoOutputPath: outputPath);

      _showNotification(
        _useCustomPath
            ? 'Recording started with custom output path!'
            : 'Recording started using auto-generated path.',
      );
    } on CameraException catch (e) {
      _showNotification(
        'Failed to start recording: ${e.description}',
        isError: true,
      );
    } catch (e) {
      _showNotification('Unexpected error: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _stopRecording() async {
    final CameraController? controller = _controller;
    if (controller == null || !controller.value.isRecordingVideo) {
      return;
    }

    try {
      final XFile file = await controller.stopVideoRecording();
      setState(() {
        _recordedVideo = file;
      });

      _showNotification('Recording finished successfully!');

      await _playRecordedVideo(file);
    } on CameraException catch (e) {
      _showNotification(
        'Failed to stop recording: ${e.description}',
        isError: true,
      );
    } catch (e) {
      _showNotification(
        'Unexpected error stopping recording: $e',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _pauseRecording() async {
    final CameraController? controller = _controller;
    if (controller == null || !controller.value.isRecordingVideo) {
      return;
    }

    try {
      await controller.pauseVideoRecording();
      _showNotification('Video recording paused.');
    } on CameraException catch (e) {
      _showNotification('Pause failed: ${e.description}', isError: true);
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _resumeRecording() async {
    final CameraController? controller = _controller;
    if (controller == null || !controller.value.isRecordingVideo) {
      return;
    }

    try {
      await controller.resumeVideoRecording();
      _showNotification('Video recording resumed.');
    } on CameraException catch (e) {
      _showNotification('Resume failed: ${e.description}', isError: true);
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _playRecordedVideo(XFile file) async {
    if (_videoPlayerController != null) {
      await _videoPlayerController!.dispose();
    }

    final playerController = VideoPlayerController.file(File(file.path));

    _videoPlayerController = playerController;

    try {
      await playerController.initialize();
      await playerController.setLooping(true);
      await playerController.play();
    } catch (e) {
      _showNotification(
        'Failed to load recorded video in player: $e',
        isError: true,
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _customFileNameController.dispose();
    _controller?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E1E30);

    return Scaffold(
      body: SafeArea(
        child: _isInitializing
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _buildHeader(textPrimary),
                    const SizedBox(height: 20),
                    _buildCameraView(isDark),
                    const SizedBox(height: 20),
                    _buildPathSettingsCard(isDark, textPrimary),
                    const SizedBox(height: 20),
                    _buildControlsPanel(isDark),
                    if (_recordedVideo != null) ...<Widget>[
                      const SizedBox(height: 24),
                      _buildVideoPlayerCard(screenWidth, isDark, textPrimary),
                    ],
                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(Color textPrimary) {
    final isDark = widget.themeMode == ThemeMode.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'VIVID VIDEO RECORDER',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Demonstrating custom output path validation & video recording.',
                style: TextStyle(fontSize: 12, color: Color(0xFF8F8FA0)),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          style: IconButton.styleFrom(
            backgroundColor: isDark ? const Color(0xFF1E1E30) : Colors.white,
            foregroundColor: const Color(0xFF6C63FF),
          ),
          onPressed: widget.onThemeToggle,
        ),
      ],
    );
  }

  Widget _buildCameraView(bool isDark) {
    final CameraController? controller = _controller;
    final bool isRecording = controller?.value.isRecordingVideo ?? false;
    final bool isPaused = controller?.value.isRecordingPaused ?? false;

    return Container(
      height: 380,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isRecording
              ? (isPaused ? Colors.amber : const Color(0xFFFF1744))
              : (isDark ? const Color(0xFF2C2C40) : const Color(0xFFE2E2EC)),
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: isRecording
                ? (isPaused
                      ? Colors.amber.withOpacity(0.15)
                      : const Color(0xFFFF1744).withOpacity(0.15))
                : Colors.transparent,
            blurRadius: 16,
            spreadRadius: 4,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (controller != null)
            CameraPreview(controller)
          else
            const Center(
              child: Text(
                'Camera pipeline is uninitialized.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          // Recording Status Overlay
          if (isRecording)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: (isDark ? const Color(0xFF1E1E30) : Colors.white)
                      .withOpacity(0.85),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isPaused ? Colors.amber : const Color(0xFFFF1744),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isPaused
                            ? Colors.amber
                            : const Color(0xFFFF1744),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isPaused ? 'RECORDING PAUSED' : 'LIVE RECORDING',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isPaused
                            ? Colors.amber
                            : const Color(0xFFFF1744),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPathSettingsCard(bool isDark, Color textPrimary) {
    final Color cardBgColor = isDark ? const Color(0xFF161626) : Colors.white;
    final borderBgColor = isDark
        ? const Color(0xFF2C2C40)
        : const Color(0xFFE2E2EC);
    final subBgColor = isDark
        ? const Color(0xFF0F0F1A)
        : const Color(0xFFF5F5FA);
    final textSecondary = isDark
        ? const Color(0xFF8F8FA0)
        : const Color(0xFF6E6E7E);

    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderBgColor),
        boxShadow: isDark
            ? const <BoxShadow>[]
            : <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.folder_open,
                    color: Color(0xFF6C63FF),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Custom Output Path',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              Switch.adaptive(
                value: _useCustomPath,
                activeColor: const Color(0xFF6C63FF),
                onChanged: (bool value) {
                  setState(() {
                    _useCustomPath = value;
                  });
                },
              ),
            ],
          ),
          if (_useCustomPath) ...<Widget>[
            const SizedBox(height: 12),
            TextField(
              style: TextStyle(color: textPrimary),
              decoration: InputDecoration(
                labelText: 'Filename or absolute path',
                labelStyle: TextStyle(color: textSecondary, fontSize: 13),
                hintText: 'my_video.mp4 or /storage/...',
                prefixIcon: Icon(
                  Icons.description,
                  size: 18,
                  color: textSecondary,
                ),
                filled: true,
                fillColor: subBgColor,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderBgColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF6C63FF),
                    width: 1.5,
                  ),
                ),
              ),
              controller: _customFileNameController,
              onChanged: (String val) {
                _customFileName = val;
              },
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: subBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'VALIDATION ENFORCEMENT RULES',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildValidationBullet(
                    'Must end with supported extension (.mp4)',
                    isDark,
                  ),
                  _buildValidationBullet(
                    'Cannot be an existing directory',
                    isDark,
                  ),
                  _buildValidationBullet(
                    'Parent folder must exist on device storage',
                    isDark,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildValidationBullet(String text, bool isDark) {
    final textSecondary = isDark
        ? const Color(0xFFB0B0C0)
        : const Color(0xFF5A5A6A);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.check_circle, size: 12, color: Color(0xFF00E676)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 11, color: textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsPanel(bool isDark) {
    final CameraController? controller = _controller;
    final bool isRecording = controller?.value.isRecordingVideo ?? false;
    final bool isPaused = controller?.value.isRecordingPaused ?? false;
    final Color controlBgColor = isDark
        ? const Color(0xFF1E1E30)
        : Colors.white;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        // Audio Toggle
        IconButton.filledTonal(
          icon: Icon(_audioEnabled ? Icons.mic : Icons.mic_off),
          style: IconButton.styleFrom(
            backgroundColor: controlBgColor,
            foregroundColor: _audioEnabled
                ? const Color(0xFF00E676)
                : Colors.grey,
            padding: const EdgeInsets.all(14),
            side: isDark
                ? BorderSide.none
                : const BorderSide(color: Color(0xFFE2E2EC)),
          ),
          onPressed: isRecording
              ? null
              : () {
                  setState(() {
                    _audioEnabled = !_audioEnabled;
                    if (_controller != null) {
                      _initializeCameraController(_controller!.description);
                    }
                  });
                },
        ),

        // Primary Record / Stop Button
        GestureDetector(
          onTap: isRecording ? _stopRecording : _startRecording,
          child: Container(
            height: 76,
            width: 76,
            decoration: BoxDecoration(
              color: isRecording
                  ? const Color(0xFFFF1744)
                  : const Color(0xFF6C63FF),
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color:
                      (isRecording
                              ? const Color(0xFFFF1744)
                              : const Color(0xFF6C63FF))
                          .withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              isRecording ? Icons.stop : Icons.videocam,
              size: 32,
              color: Colors.white,
            ),
          ),
        ),

        // Pause / Resume Toggle
        IconButton.filledTonal(
          icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
          style: IconButton.styleFrom(
            backgroundColor: controlBgColor,
            foregroundColor: const Color(0xFF6C63FF),
            padding: const EdgeInsets.all(14),
            side: isDark
                ? BorderSide.none
                : const BorderSide(color: Color(0xFFE2E2EC)),
          ),
          onPressed: isRecording
              ? (isPaused ? _resumeRecording : _pauseRecording)
              : null,
        ),
      ],
    );
  }

  Widget _buildVideoPlayerCard(
    double screenWidth,
    bool isDark,
    Color textPrimary,
  ) {
    final VideoPlayerController? playerController = _videoPlayerController;
    final Color cardBgColor = isDark ? const Color(0xFF161626) : Colors.white;
    final borderBgColor = isDark
        ? const Color(0xFF2C2C40)
        : const Color(0xFFE2E2EC);

    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderBgColor),
        boxShadow: isDark
            ? const <BoxShadow>[]
            : <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.video_library,
                color: Color(0xFF00E676),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Recorded Video Output',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (playerController != null && playerController.value.isInitialized)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: playerController.value.aspectRatio,
                child: VideoPlayer(playerController),
              ),
            )
          else
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: CircularProgressIndicator(color: Color(0xFF00E676)),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            'Saved Location Path:',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            _recordedVideo?.path ?? 'Unknown',
            style: const TextStyle(
              fontSize: 11,
              fontFamily: 'Courier',
              color: Color(0xFF00E676),
            ),
          ),
          if (_resolvedCustomPath != null) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              'Requested Custom Path:',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            SelectableText(
              _resolvedCustomPath!,
              style: const TextStyle(
                fontSize: 11,
                fontFamily: 'Courier',
                color: Color(0xFF6C63FF),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

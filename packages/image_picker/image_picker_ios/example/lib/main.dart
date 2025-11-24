// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:mime/mime.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Image Picker Demo',
      home: MyHomePage(title: 'Image Picker Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, this.title});

  final String? title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<XFile>? _mediaFileList;

  void _setImageFileListFromFile(XFile? value) {
    _mediaFileList = value == null ? null : <XFile>[value];
  }

  dynamic _pickImageError;
  bool _isVideo = false;

  VideoPlayerController? _controller;
  VideoPlayerController? _toBeDisposed;
  String? _retrieveDataError;

  final ImagePickerPlatform _picker = ImagePickerPlatform.instance;
  final TextEditingController maxWidthController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();
  final TextEditingController limitController = TextEditingController();

  Future<void> _playVideo(XFile? file) async {
    if (file != null && mounted) {
      await _disposeVideoController();
      final controller = VideoPlayerController.file(File(file.path));
      _controller = controller;
      await controller.setVolume(1.0);
      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();
      setState(() {});
    }
  }

  Future<void> _onImageButtonPressed(
    ImageSource source, {
    required BuildContext context,
    bool allowMultiple = false,
    bool isMedia = false,
  }) async {
    if (_controller != null) {
      await _controller!.setVolume(0.0);
    }
    if (context.mounted) {
      if (_isVideo) {
        final List<XFile> files;
        if (allowMultiple) {
          files = await _picker.getMultiVideoWithOptions();
        } else {
          final XFile? file = await _picker.getVideo(
            source: source,
            maxDuration: const Duration(seconds: 10),
          );
          files = <XFile>[if (file != null) file];
        }
        if (files.isNotEmpty && context.mounted) {
          _showPickedSnackBar(context, files);
          // Just play the first file, to keep the example simple.
          await _playVideo(files.first);
        }
      } else if (allowMultiple) {
        await _displayPickImageDialog(context, true, (
          double? maxWidth,
          double? maxHeight,
          int? quality,
          int? limit,
        ) async {
          try {
            final imageOptions = ImageOptions(
              maxWidth: maxWidth,
              maxHeight: maxHeight,
              imageQuality: quality,
            );
            final List<XFile> pickedFileList = isMedia
                ? await _picker.getMedia(
                    options: MediaOptions(
                      allowMultiple: allowMultiple,
                      imageOptions: imageOptions,
                      limit: limit,
                    ),
                  )
                : await _picker.getMultiImageWithOptions(
                    options: MultiImagePickerOptions(
                      imageOptions: imageOptions,
                      limit: limit,
                    ),
                  );
            if (pickedFileList.isNotEmpty && context.mounted) {
              _showPickedSnackBar(context, pickedFileList);
            }
            setState(() {
              _mediaFileList = pickedFileList;
            });
          } catch (e) {
            setState(() {
              _pickImageError = e;
            });
          }
        });
      } else if (isMedia) {
        await _displayPickImageDialog(context, false, (
          double? maxWidth,
          double? maxHeight,
          int? quality,
          int? limit,
        ) async {
          try {
            final pickedFileList = <XFile>[];
            final XFile? media = _firstOrNull(
              await _picker.getMedia(
                options: MediaOptions(
                  allowMultiple: allowMultiple,
                  imageOptions: ImageOptions(
                    maxWidth: maxWidth,
                    maxHeight: maxHeight,
                    imageQuality: quality,
                  ),
                ),
              ),
            );

            if (media != null) {
              pickedFileList.add(media);
              setState(() {
                _mediaFileList = pickedFileList;
              });
            }
          } catch (e) {
            setState(() => _pickImageError = e);
          }
        });
      } else {
        await _displayPickImageDialog(context, false, (
          double? maxWidth,
          double? maxHeight,
          int? quality,
          int? limit,
        ) async {
          try {
            final XFile? pickedFile = await _picker.getImageFromSource(
              source: source,
              options: ImagePickerOptions(
                maxWidth: maxWidth,
                maxHeight: maxHeight,
                imageQuality: quality,
              ),
            );
            if (pickedFile != null && context.mounted) {
              _showPickedSnackBar(context, <XFile>[pickedFile]);
            }
            setState(() => _setImageFileListFromFile(pickedFile));
          } catch (e) {
            setState(() => _pickImageError = e);
          }
        });
      }
    }
  }

  @override
  void deactivate() {
    if (_controller != null) {
      _controller!.setVolume(0.0);
      _controller!.pause();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _disposeVideoController();
    maxWidthController.dispose();
    maxHeightController.dispose();
    qualityController.dispose();
    super.dispose();
  }

  Future<void> _disposeVideoController() async {
    if (_toBeDisposed != null) {
      await _toBeDisposed!.dispose();
    }
    _toBeDisposed = _controller;
    _controller = null;
  }

  Widget _previewVideo() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_controller == null) {
      return const Text(
        'You have not yet picked a video',
        textAlign: TextAlign.center,
      );
    }
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: AspectRatioVideo(_controller),
    );
  }

  Widget _previewImages() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_mediaFileList != null) {
      return Semantics(
        label: 'image_picker_example_picked_images',
        child: ListView.builder(
          key: UniqueKey(),
          itemBuilder: (BuildContext context, int index) {
            final XFile image = _mediaFileList![index];
            final String? mime = lookupMimeType(image.path);
            return Semantics(
              label: 'image_picker_example_picked_image',
              child: mime == null || mime.startsWith('image/')
                  ? Image.file(
                      File(image.path),
                      errorBuilder:
                          (
                            BuildContext context,
                            Object error,
                            StackTrace? stackTrace,
                          ) {
                            return const Center(
                              child: Text('This image type is not supported'),
                            );
                          },
                    )
                  : _buildInlineVideoPlayer(index),
            );
          },
          itemCount: _mediaFileList!.length,
        ),
      );
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'You have not yet picked an image.',
        textAlign: TextAlign.center,
      );
    }
  }

  Widget _buildInlineVideoPlayer(int index) {
    final controller = VideoPlayerController.file(
      File(_mediaFileList![index].path),
    );
    controller.setVolume(1.0);
    controller.initialize();
    controller.setLooping(true);
    controller.play();
    return Center(child: AspectRatioVideo(controller));
  }

  Widget _handlePreview() {
    if (_isVideo) {
      return _previewVideo();
    } else {
      return _previewImages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title!)),
      body: Align(alignment: Alignment.topCenter, child: _handlePreview()),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Semantics(
            label: 'image_picker_example_from_gallery',
            child: FloatingActionButton.extended(
              key: const Key('image_picker_example_from_gallery'),
              onPressed: () {
                _isVideo = false;
                _onImageButtonPressed(ImageSource.gallery, context: context);
              },
              heroTag: 'image0',
              tooltip: 'Pick image from gallery',
              label: const Text('Pick image from gallery'),
              icon: const Icon(Icons.photo),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton.extended(
              onPressed: () {
                _isVideo = false;
                _onImageButtonPressed(
                  ImageSource.gallery,
                  context: context,
                  allowMultiple: true,
                );
              },
              heroTag: 'image1',
              tooltip: 'Pick multiple images',
              label: const Text('Pick multiple images'),
              icon: const Icon(Icons.photo_library),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton.extended(
              onPressed: () {
                _isVideo = false;
                _onImageButtonPressed(
                  ImageSource.gallery,
                  context: context,
                  isMedia: true,
                );
              },
              heroTag: 'media',
              tooltip: 'Pick item from gallery',
              label: const Text('Pick item from gallery'),
              icon: const Icon(Icons.photo_outlined),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton.extended(
              onPressed: () {
                _isVideo = false;
                _onImageButtonPressed(
                  ImageSource.gallery,
                  context: context,
                  allowMultiple: true,
                  isMedia: true,
                );
              },
              heroTag: 'multipleMedia',
              tooltip: 'Pick multiple items',
              label: const Text('Pick multiple items'),
              icon: const Icon(Icons.photo_library_outlined),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton.extended(
              onPressed: () {
                _isVideo = false;
                _onImageButtonPressed(ImageSource.camera, context: context);
              },
              heroTag: 'image2',
              tooltip: 'Take a photo',
              label: const Text('Take a photo'),
              icon: const Icon(Icons.camera_alt),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton.extended(
              backgroundColor: Colors.red,
              onPressed: () {
                _isVideo = true;
                _onImageButtonPressed(ImageSource.gallery, context: context);
              },
              heroTag: 'video',
              tooltip: 'Pick video from gallery',
              label: const Text('Pick video from gallery'),
              icon: const Icon(Icons.video_file),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton.extended(
              backgroundColor: Colors.red,
              onPressed: () {
                _isVideo = true;
                _onImageButtonPressed(
                  ImageSource.gallery,
                  context: context,
                  allowMultiple: true,
                );
              },
              heroTag: 'multiVideo',
              tooltip: 'Pick multiple videos',
              label: const Text('Pick multiple videos'),
              icon: const Icon(Icons.video_library),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton.extended(
              backgroundColor: Colors.red,
              onPressed: () {
                _isVideo = true;
                _onImageButtonPressed(ImageSource.camera, context: context);
              },
              heroTag: 'takeVideo',
              tooltip: 'Take a video',
              label: const Text('Take a video'),
              icon: const Icon(Icons.videocam),
            ),
          ),
        ],
      ),
    );
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Future<void> _displayPickImageDialog(
    BuildContext context,
    bool isMulti,
    OnPickImageCallback onPick,
  ) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add optional parameters'),
          content: Column(
            children: <Widget>[
              TextField(
                controller: maxWidthController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  hintText: 'Enter maxWidth if desired',
                ),
              ),
              TextField(
                controller: maxHeightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  hintText: 'Enter maxHeight if desired',
                ),
              ),
              TextField(
                controller: qualityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter quality if desired',
                ),
              ),
              if (isMulti)
                TextField(
                  controller: limitController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Enter limit if desired',
                  ),
                ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('PICK'),
              onPressed: () {
                final double? width = maxWidthController.text.isNotEmpty
                    ? double.parse(maxWidthController.text)
                    : null;
                final double? height = maxHeightController.text.isNotEmpty
                    ? double.parse(maxHeightController.text)
                    : null;
                final int? quality = qualityController.text.isNotEmpty
                    ? int.parse(qualityController.text)
                    : null;
                final int? limit = limitController.text.isNotEmpty
                    ? int.parse(limitController.text)
                    : null;
                onPick(width, height, quality, limit);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPickedSnackBar(BuildContext context, List<XFile> files) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Picked: ${files.map((XFile it) => it.name).join(',')}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

typedef OnPickImageCallback =
    void Function(
      double? maxWidth,
      double? maxHeight,
      int? quality,
      int? limit,
    );

class AspectRatioVideo extends StatefulWidget {
  const AspectRatioVideo(this.controller, {super.key});

  final VideoPlayerController? controller;

  @override
  AspectRatioVideoState createState() => AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController? get controller => widget.controller;
  bool initialized = false;

  void _onVideoControllerUpdate() {
    if (!mounted) {
      return;
    }
    if (initialized != controller!.value.isInitialized) {
      initialized = controller!.value.isInitialized;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    controller!.addListener(_onVideoControllerUpdate);
  }

  @override
  void dispose() {
    controller!.removeListener(_onVideoControllerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: controller!.value.aspectRatio,
          child: VideoPlayer(controller!),
        ),
      );
    } else {
      return Container();
    }
  }
}

T? _firstOrNull<T>(List<T> list) {
  return list.isEmpty ? null : list.first;
}

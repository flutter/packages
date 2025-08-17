// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

export 'camera_delegate.dart';
export 'camera_device.dart';
export 'image_options.dart';
export 'image_source.dart';
export 'lost_data_response.dart';
export 'media_options.dart';
export 'media_selection_type.dart';
export 'multi_image_picker_options.dart';
export 'multi_video_picker_options.dart';
export 'picked_file/picked_file.dart';
export 'retrieve_type.dart';

/// Denotes that an image is being picked.
const String kTypeImage = 'image';

/// Denotes that a video is being picked.
const String kTypeVideo = 'video';

/// Denotes that either a video or image is being picked.
const String kTypeMedia = 'media';

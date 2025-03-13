// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';

import 'package:flutter/cupertino.dart' show CupertinoTheme;
import 'package:flutter/material.dart' show Theme;
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;

import 'style_sheet.dart';
import 'widget.dart';

/// Type for a function that creates image widgets.
typedef ImageBuilder = Widget Function(
    Uri uri, String? imageDirectory, double? width, double? height);

/// A default image builder handling http/https, resource, data, and file URLs.
// ignore: prefer_function_declarations_over_variables
final ImageBuilder kDefaultImageBuilder = (
  Uri uri,
  String? imageDirectory,
  double? width,
  double? height,
) {
  if (uri.scheme == 'http' || uri.scheme == 'https') {
    return Image.network(
      uri.toString(),
      width: width,
      height: height,
      errorBuilder: kDefaultImageErrorWidgetBuilder,
    );
  } else if (uri.scheme == 'data') {
    return _handleDataSchemeUri(uri, width, height);
  } else if (uri.scheme == 'resource') {
    return Image.asset(
      uri.path,
      width: width,
      height: height,
      errorBuilder: kDefaultImageErrorWidgetBuilder,
    );
  } else {
    final Uri fileUri;

    if (imageDirectory != null) {
      try {
        fileUri = Uri.parse(p.join(imageDirectory, uri.toString()));
      } catch (error, stackTrace) {
        // Handle any invalid file URI's.
        return Builder(
          builder: (BuildContext context) {
            return kDefaultImageErrorWidgetBuilder(context, error, stackTrace);
          },
        );
      }
    } else {
      fileUri = uri;
    }

    if (fileUri.scheme == 'http' || fileUri.scheme == 'https') {
      return Image.network(
        fileUri.toString(),
        width: width,
        height: height,
        errorBuilder: kDefaultImageErrorWidgetBuilder,
      );
    } else {
      final String src = p.join(p.current, fileUri.toString());
      return Image.network(
        src,
        width: width,
        height: height,
        errorBuilder: kDefaultImageErrorWidgetBuilder,
      );
    }
  }
};

/// A default error widget builder for handling image errors.
// ignore: prefer_function_declarations_over_variables
final ImageErrorWidgetBuilder kDefaultImageErrorWidgetBuilder = (
  BuildContext context,
  Object error,
  StackTrace? stackTrace,
) {
  return const SizedBox();
};

/// A default style sheet generator.
final MarkdownStyleSheet Function(BuildContext, MarkdownStyleSheetBaseTheme?)
// ignore: prefer_function_declarations_over_variables
    kFallbackStyle = (
  BuildContext context,
  MarkdownStyleSheetBaseTheme? baseTheme,
) {
  final MarkdownStyleSheet result = switch (baseTheme) {
    MarkdownStyleSheetBaseTheme.platform
        when _userAgent.toDart.contains('Mac OS X') =>
      MarkdownStyleSheet.fromCupertinoTheme(CupertinoTheme.of(context)),
    MarkdownStyleSheetBaseTheme.cupertino =>
      MarkdownStyleSheet.fromCupertinoTheme(CupertinoTheme.of(context)),
    _ => MarkdownStyleSheet.fromTheme(Theme.of(context)),
  };

  return result.copyWith(
    textScaler: MediaQuery.textScalerOf(context),
  );
};

Widget _handleDataSchemeUri(
    Uri uri, final double? width, final double? height) {
  final String mimeType = uri.data!.mimeType;
  if (mimeType.startsWith('image/')) {
    return Image.memory(
      uri.data!.contentAsBytes(),
      width: width,
      height: height,
      errorBuilder: kDefaultImageErrorWidgetBuilder,
    );
  } else if (mimeType.startsWith('text/')) {
    return Text(uri.data!.contentAsString());
  }
  return const SizedBox();
}

@JS('window.navigator.userAgent')
external JSString get _userAgent;

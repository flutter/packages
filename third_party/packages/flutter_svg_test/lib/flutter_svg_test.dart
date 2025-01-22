import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';

/// Extension on common finder to have native feeling
extension CommonFinderExt on CommonFinders {
  /// Finds [SvgPicture] widgets containing `svg` equal to the `svg` argument.
  ///
  /// ## Sample code
  /// ```dart
  /// expect(find.svg(SvgPicture.asset('assets/asset_name.svg')), findsOneWidget);
  /// ```
  ///
  /// If the `skipOffstage` argument is true (the default), then this skips
  /// nodes that are [Offstage] or that are from inactive [Route]s.
  Finder svg(BytesLoader svg, {bool skipOffstage = true}) {
    return _SvgFinder(svg, skipOffstage: skipOffstage);
  }

  /// Finds widgets created by [SvgPicture.asset] with the [path] argument.
  /// ## Sample code
  /// ```dart
  /// expect(svgAssetWithPath('assets/asset_name.svg'), findsOneWidget);
  /// ```
  /// This will match [SvgPicture.asset] with the [path] 'assets/asset_name.svg'.
  /// If the `skipOffstage` argument is true (the default), then this skips
  /// nodes that are [Offstage] or that are from inactive [Route]s.
  Finder svgAssetWithPath(String path, {bool skipOffstage = true}) {
    return _SvgAssetWithPathFinder(svgPath: path, skipOffstage: skipOffstage);
  }

  /// Finds widgets created by [SvgPicture.network] with the [url] argument.
  /// ## Sample code
  /// ```dart
  /// expect(find.svgNetworkWithUrl('https://svg.dart'), findsOneWidget);
  /// ```
  /// This will match [SvgPicture.network] with the [url] https://svg.dart'.
  /// If the `skipOffstage` argument is true (the default), then this skips
  /// nodes that are [Offstage] or that are from inactive [Route]s.
  Finder svgNetworkWithUrl(String url, {bool skipOffstage = true}) {
    return _SvgNetworkWithUrlFinder(url: url, skipOffstage: skipOffstage);
  }

  /// Finds widgets created by [SvgPicture.memory] with the [bytes] argument.
  /// ## Sample code
  /// ```dart
  /// const Uint8List svgBytes = [1, 2, 3, 4];
  /// expect(find.svgMemoryWithBytes(svgBytes), findsOneWidget);
  /// ```
  /// This will match [SvgPicture.memory] with the [bytes] [1,2,3,4].
  /// If the `skipOffstage` argument is true (the default), then this skips
  /// nodes that are [Offstage] or that are from inactive [Route]s.
  Finder svgMemoryWithBytes(Uint8List bytes, {bool skipOffstage = true}) {
    return _SvgMemoryWithBytesFinder(bytes: bytes, skipOffstage: skipOffstage);
  }

  /// Finds widgets created by [SvgPicture.file] with the [path] argument.
  /// ## Sample code
  /// ```dart
  /// expect(find.svgFileWithPath('test/flutter_logo.svg'), findsOneWidget);
  /// ```
  /// This will match [SvgPicture.file] with the [path] 'test/flutter_logo.svg'.
  /// If the `skipOffstage` argument is true (the default), then this skips
  /// nodes that are [Offstage] or that are from inactive [Route]s.
  Finder svgFileWithPath(String path, {bool skipOffstage = true}) {
    return _SvgFileWithPathFinder(path: path, skipOffstage: skipOffstage);
  }
}

class _SvgFinder extends MatchFinder {
  _SvgFinder(this._svg, {super.skipOffstage});

  final BytesLoader _svg;

  @override
  String get description => "svg: '$_svg'";

  @override
  bool matches(Element candidate) {
    return _getBytesLoader(
      candidate,
      (BytesLoader loader) => loader == _svg,
    );
  }
}

class _SvgAssetWithPathFinder extends MatchFinder {
  _SvgAssetWithPathFinder({required String svgPath, super.skipOffstage})
      : _svgPath = svgPath;
  final String _svgPath;

  @override
  String get description => "Path: '$_svgPath' and created by SvgPicture.asset";

  @override
  bool matches(Element candidate) {
    return _getBytesLoader(
      candidate,
      (SvgAssetLoader loader) => loader.assetName == _svgPath,
    );
  }
}

class _SvgNetworkWithUrlFinder extends MatchFinder {
  _SvgNetworkWithUrlFinder({required String url, super.skipOffstage})
      : _url = url;
  final String _url;

  @override
  String get description => "Url: '$_url' and created by SvgPicture.network";

  @override
  bool matches(Element candidate) {
    return _getBytesLoader(
      candidate,
      (SvgNetworkLoader loader) => loader.url == _url,
    );
  }
}

class _SvgFileWithPathFinder extends MatchFinder {
  _SvgFileWithPathFinder({required String path, super.skipOffstage})
      : _path = path;
  final String _path;

  @override
  String get description => "Path: '$_path' and created by SvgPicture.file";

  @override
  bool matches(Element candidate) {
    return _getBytesLoader(
      candidate,
      (SvgFileLoader loader) => loader.file.path == _path,
    );
  }
}

class _SvgMemoryWithBytesFinder extends MatchFinder {
  _SvgMemoryWithBytesFinder({required Uint8List bytes, super.skipOffstage})
      : _bytes = bytes;
  final Uint8List _bytes;

  @override
  String get description => "Bytes: '$_bytes' and created by SvgPicture.memory";

  @override
  bool matches(Element candidate) {
    return _getBytesLoader(
      candidate,
      (SvgBytesLoader loader) => loader.bytes == _bytes,
    );
  }
}

bool _getBytesLoader<T>(
  Element candidate,
  bool Function(T loader) matcher,
) {
  bool result = false;
  final Widget widget = candidate.widget;
  if (widget is SvgPicture) {
    final BytesLoader bytesLoader = widget.bytesLoader;
    if (bytesLoader is T) {
      result = matcher(bytesLoader as T);
    }
  }
  return result;
}

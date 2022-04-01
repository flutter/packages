import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'src/listener.dart';

/// A widget that displays a [VectorGraphicsCodec] encoded asset.
///
/// This widget will ask the loader to load the bytes whenever its
/// dependencies change or it is configured with a new loader. A loader may
/// or may not choose to cache its responses, potentially resulting in multiple
/// disk or network accesses for the same bytes.
class VectorGraphic extends StatefulWidget {
  /// A widget that displays a vector graphics created via a
  /// [VectorGraphicsCodec].
  ///
  /// See [VectorGraphic].
  const VectorGraphic({
    Key? key,
    required this.loader,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
  }) : super(key: key);

  /// A delegate for fetching the raw bytes of the vector graphic.
  ///
  /// The [BytesLoader.loadBytes] method will be called with this
  /// widget's [BuildContext] whenever dependencies change or the widget
  /// configuration changes the loader.
  final BytesLoader loader;

  /// If specified, the width to use for the vector graphic. If unspecified,
  /// the vector graphic will take the width of its parent.
  final double? width;

  /// If specified, the height to use for the vector graphic. If unspecified,
  /// the vector graphic will take the height of its parent.
  final double? height;

  /// How to inscribe the picture into the space allocated during layout.
  /// The default is [BoxFit.contain].
  final BoxFit fit;

  /// How to align the picture within its parent widget.
  ///
  /// The alignment aligns the given position in the picture to the given position
  /// in the layout bounds. For example, an [Alignment] alignment of (-1.0,
  /// -1.0) aligns the image to the top-left corner of its layout bounds, while a
  /// [Alignment] alignment of (1.0, 1.0) aligns the bottom right of the
  /// picture with the bottom right corner of its layout bounds. Similarly, an
  /// alignment of (0.0, 1.0) aligns the bottom middle of the image with the
  /// middle of the bottom edge of its layout bounds.
  ///
  /// If the [alignment] is [TextDirection]-dependent (i.e. if it is a
  /// [AlignmentDirectional]), then a [TextDirection] must be available
  /// when the picture is painted.
  ///
  /// Defaults to [Alignment.center].
  ///
  /// See also:
  ///
  ///  * [Alignment], a class with convenient constants typically used to
  ///    specify an [AlignmentGeometry].
  ///  * [AlignmentDirectional], like [Alignment] for specifying alignments
  ///    relative to text direction.
  final AlignmentGeometry alignment;

  @override
  State<VectorGraphic> createState() => _VectorGraphicsWidgetState();
}

class _VectorGraphicsWidgetState extends State<VectorGraphic> {
  PictureInfo? _pictureInfo;

  @override
  void didChangeDependencies() {
    _loadAssetBytes();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant VectorGraphic oldWidget) {
    if (oldWidget.loader != widget.loader) {
      _loadAssetBytes();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _pictureInfo?.dispose();
    _pictureInfo = null;
    super.dispose();
  }

  void _loadAssetBytes() {
    widget.loader.loadBytes(context).then((ByteData data) {
      final PictureInfo pictureInfo = decodeVectorGraphics(
        data,
        locale: Localizations.maybeLocaleOf(context),
        textDirection: Directionality.maybeOf(context),
      );
      setState(() {
        _pictureInfo?.dispose();
        _pictureInfo = pictureInfo;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final PictureInfo? pictureInfo = _pictureInfo;
    if (pictureInfo == null) {
      return SizedBox(width: widget.width, height: widget.height);
    }
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: FittedBox(
        fit: widget.fit,
        alignment: widget.alignment,
        child: SizedBox.fromSize(
          size: pictureInfo.size,
          child: _RawVectorGraphicsWidget(
            pictureInfo: pictureInfo,
          ),
        ),
      ),
    );
  }
}

/// An interface that can be implemented to support decoding vector graphic
/// binary assets from different byte sources.
///
/// A bytes loader class should not be constructed directly in a build method,
/// if this is done the corresponding [VectorGraphic] widget may repeatedly
/// reload the bytes.
///
/// See also:
///   * [AssetBytesLoader], for loading from the asset bundle.
///   * [NetworkBytesLoader], for loading network bytes.
@immutable
abstract class BytesLoader {
  /// Const constructor to allow subtypes to be const.
  const BytesLoader();

  /// Load the byte data for a vector graphic binary asset.
  Future<ByteData> loadBytes(BuildContext context);
}

/// Loads vector graphics data from an asset bundle.
///
/// This loader does not cache bytes by default. The Flutter framework
/// implementations of [AssetBundle] also do not typically cache binary data.
///
/// Callers that would benefit from caching should provide a custom
/// [AssetBundle] that caches data, or should create their own implementation
/// of an asset bytes loader.
class AssetBytesLoader extends BytesLoader {
  /// A loader that retrieves bytes from an [AssetBundle].
  ///
  /// See [AssetBytesLoader].
  const AssetBytesLoader(
    this.assetName, {
    this.packageName,
    this.assetBundle,
  });

  /// The name of the asset to load.
  final String assetName;

  /// The package name to load from, if any.
  final String? packageName;

  /// The asset bundle to use.
  ///
  /// If unspecified, [DefaultAssetBundle.of] the current context will be used.
  final AssetBundle? assetBundle;

  @override
  Future<ByteData> loadBytes(BuildContext context) {
    return (assetBundle ?? DefaultAssetBundle.of(context)).load(assetName);
  }

  @override
  int get hashCode => Object.hash(assetName, packageName, assetBundle);

  @override
  bool operator ==(Object other) {
    return other is AssetBytesLoader &&
        other.assetName == assetName &&
        other.assetBundle == assetBundle &&
        other.packageName == packageName;
  }
}

/// A controller for loading vector graphics data from over the network.
///
/// This loader does not cache bytes requested from the network.
class NetworkBytesLoader extends BytesLoader {
  /// Creates a new loading context for network bytes.
  const NetworkBytesLoader(
    this.url, {
    this.headers,
    this.client,
  });

  /// The HTTP headers to use for the network request.
  final Map<String, String>? headers;

  /// The [Uri] of the resource to request.
  final Uri url;

  /// The [HttpClient] to use when making a request. By default, this will
  /// create a new [HttpClient] per request.
  final HttpClient? client;

  @override
  Future<ByteData> loadBytes(BuildContext context) async {
    final HttpClient currentClient = client ?? HttpClient();
    final HttpClientRequest request = await currentClient.getUrl(url);
    headers?.forEach(request.headers.add);

    final HttpClientResponse response = await request.close();
    if (response.statusCode != HttpStatus.ok) {
      await response.drain<List<int>>(<int>[]);
      throw Exception('Failed to load VectorGraphic: ${response.statusCode}');
    }
    final Uint8List bytes = await consolidateHttpClientResponseBytes(
      response,
    );
    return bytes.buffer.asByteData();
  }

  @override
  int get hashCode => Object.hash(url, headers, client);

  @override
  bool operator ==(Object other) {
    return other is NetworkBytesLoader &&
        other.headers == headers &&
        other.url == url &&
        other.client == client;
  }
}

class _RawVectorGraphicsWidget extends SingleChildRenderObjectWidget {
  const _RawVectorGraphicsWidget({
    Key? key,
    required this.pictureInfo,
  }) : super(key: key);

  final PictureInfo pictureInfo;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderVectorGraphics(pictureInfo);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderVectorGraphics renderObject,
  ) {
    renderObject.pictureInfo = pictureInfo;
  }
}

class _RenderVectorGraphics extends RenderBox {
  _RenderVectorGraphics(this._pictureInfo);

  PictureInfo get pictureInfo => _pictureInfo;
  PictureInfo _pictureInfo;
  set pictureInfo(PictureInfo value) {
    if (identical(value, _pictureInfo)) {
      return;
    }
    _pictureInfo = value;
    markNeedsPaint();
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.smallest;
  }

  @override
  bool get isRepaintBoundary => true;

  final Matrix4 transform = Matrix4.identity();

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    if (_scaleCanvasToViewBox(transform, size, pictureInfo.size)) {
      context.canvas.transform(transform.storage);
    }
    context.addLayer(_pictureInfo.layer!);
  }
}

bool _scaleCanvasToViewBox(
  Matrix4 matrix,
  Size desiredSize,
  Size pictureSize,
) {
  if (desiredSize == pictureSize) {
    return false;
  }
  final double scale = math.min(
    desiredSize.width / pictureSize.width,
    desiredSize.height / pictureSize.height,
  );
  final Size scaledHalfViewBoxSize = pictureSize * scale / 2.0;
  final Size halfDesiredSize = desiredSize / 2.0;
  final Offset shift = Offset(
    halfDesiredSize.width - scaledHalfViewBoxSize.width,
    halfDesiredSize.height - scaledHalfViewBoxSize.height,
  );
  matrix
    ..translate(shift.dx, shift.dy)
    ..scale(scale, scale);

  return true;
}

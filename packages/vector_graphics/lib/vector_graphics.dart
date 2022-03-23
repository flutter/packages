import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'src/listener.dart';

const VectorGraphicsCodec _codec = VectorGraphicsCodec();

/// Decode a vector graphics binary asset into a [ui.Picture].
///
/// Throws a [StateError] if the data is invalid.
PictureInfo decodeVectorGraphics(ByteData data) {
  final FlutterVectorGraphicsListener listener =
      FlutterVectorGraphicsListener();
  _codec.decode(data, listener);
  return listener.toPicture();
}

/// A widget that displays a vector_graphics formatted asset.
///
/// A bytes loader class should not be constructed directly in a build method,
/// if this is done the corresponding [VectorGraphic] widget may repeatedly
/// reload the bytes.
///
/// ```dart
/// class MyVectorGraphic extends StatefulWidget {
///
///  State<MyVectorGraphic> createState() =>
/// }
///
/// class _MyVectorGraphicState extends State<MyVectorGraphic> {
///   BytesLoader? loader;
///
///   @override
///   void initState() {
///     super.initState();
///     loader = AssetBytesLoader(assetName: 'foobar', assetBundle: DefaultAssetBundle.of(context));
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return VectorGraphic(bytesLoader: loader!);
///   }
/// }
/// ```
class VectorGraphic extends StatefulWidget {
  const VectorGraphic({
    Key? key,
    required this.bytesLoader,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
  }) : super(key: key);

  final BytesLoader bytesLoader;

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
  void initState() {
    _loadAssetBytes();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant VectorGraphic oldWidget) {
    if (oldWidget.bytesLoader != widget.bytesLoader) {
      _loadAssetBytes();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _pictureInfo?.picture.dispose();
    _pictureInfo = null;
    super.dispose();
  }

  void _loadAssetBytes() {
    widget.bytesLoader.loadBytes().then((ByteData data) {
      final PictureInfo pictureInfo = decodeVectorGraphics(data);
      setState(() {
        _pictureInfo?.picture.dispose();
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
abstract class BytesLoader {
  /// const constructor to allow subtypes to be const.
  const BytesLoader();

  /// Load the byte data for a vector graphic binary asset.
  Future<ByteData> loadBytes();
}

/// A controller for loading vector graphics data from an asset bundle.
class AssetBytesLoader extends BytesLoader {
  /// Create a new [VectorGraphicsAssetController].
  ///
  /// The default asset bundle can be acquired using [DefaultAssetBundle.of].
  const AssetBytesLoader({
    required this.assetName,
    this.packageName,
    required this.assetBundle,
  });

  final String assetName;
  final String? packageName;
  final AssetBundle assetBundle;

  @override
  Future<ByteData> loadBytes() {
    return assetBundle.load(assetName);
  }
}

/// A controller for loading vector graphics data from over the network.
class NetworkBytesLoader extends BytesLoader {
  const NetworkBytesLoader({
    required this.url,
    this.headers,
    this.client,
  });

  final Map<String, String>? headers;
  final Uri url;
  final HttpClient? client;

  @override
  Future<ByteData> loadBytes() async {
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
      BuildContext context, covariant _RenderVectorGraphics renderObject) {
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
    context.canvas.drawPicture(_pictureInfo.picture);
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

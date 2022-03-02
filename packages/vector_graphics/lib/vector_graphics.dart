import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'src/listener.dart';

const VectorGraphicsCodec _codec = VectorGraphicsCodec();

/// Decode a vector graphics binary asset into a [ui.Picture].
///
/// Throws a [StateError] if the data is invalid.
ui.Picture decodeVectorGraphics(ByteData data) {
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
  const VectorGraphic({Key? key, required this.bytesLoader}) : super(key: key);

  final BytesLoader bytesLoader;

  @override
  State<VectorGraphic> createState() => _VectorGraphicsWidgetState();
}

class _VectorGraphicsWidgetState extends State<VectorGraphic> {
  ui.Picture? _picture;

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
    _picture?.dispose();
    _picture = null;
    super.dispose();
  }

  void _loadAssetBytes() {
    widget.bytesLoader.loadBytes().then((ByteData data) {
      final ui.Picture picture = decodeVectorGraphics(data);
      setState(() {
        _picture?.dispose();
        _picture = picture;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ui.Picture? picture = _picture;
    if (picture == null) {
      return const SizedBox();
    }
    return _RawVectorGraphicsWidget(picture: picture);
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
  const _RawVectorGraphicsWidget({Key? key, required this.picture})
      : super(key: key);

  final ui.Picture picture;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderVectorGraphics(picture);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderVectorGraphics renderObject) {
    renderObject.picture = picture;
  }
}

class _RenderVectorGraphics extends RenderProxyBox {
  _RenderVectorGraphics(this._picture);

  ui.Picture get picture => _picture;
  ui.Picture _picture;
  set picture(ui.Picture value) {
    if (identical(value, _picture)) {
      return;
    }
    _picture = value;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    context.canvas.drawPicture(picture);
  }
}

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
class VectorGraphics extends StatefulWidget {
  const VectorGraphics({Key? key, required this.controller}) : super(key: key);

  final VectorGraphicsController controller;

  @override
  State<VectorGraphics> createState() => _VectorGraphicsWidgetState();
}

class _VectorGraphicsWidgetState extends State<VectorGraphics> {
  ui.Picture? _picture;

  @override
  void initState() {
    _loadAssetBytes();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant VectorGraphics oldWidget) {
    if (!oldWidget.controller.equivalent(widget.controller)) {
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
    widget.controller.loadBytes().then((ByteData data) {
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

abstract class VectorGraphicsController {
  const VectorGraphicsController();

  Future<ByteData> loadBytes();

  bool equivalent(VectorGraphicsController other) => false;
}

/// A controller for loading vector graphics data from an asset bundle.
class VectorGraphicsAssetController extends VectorGraphicsController {
  /// Create a new [VectorGraphicsAssetController].
  ///
  /// The default asset bundle can be acquired using [DefaultAssetBundle.of].
  const VectorGraphicsAssetController({
    required this.assetName,
    this.packageName,
    required this.assetBundle,
  });

  final String assetName;
  final String? packageName;
  final AssetBundle assetBundle;

  @override
  bool equivalent(VectorGraphicsController other) {
    return other is VectorGraphicsAssetController &&
        other.assetName == assetName &&
        other.packageName == packageName &&
        other.assetBundle == assetBundle;
  }

  @override
  Future<ByteData> loadBytes() {
    return assetBundle.load(assetName);
  }
}

/// A controller for loading vector graphics data from over the network.
class VectorGraphicsNetworkController extends VectorGraphicsController {
  const VectorGraphicsNetworkController({
    required this.url,
    this.headers,
    this.client,
  });

  final Map<String, String>? headers;
  final Uri url;
  final HttpClient? client;

  @override
  bool equivalent(VectorGraphicsController other) {
    // This intentionally does not use [client].
    return other is VectorGraphicsNetworkController &&
        other.url == url &&
        mapEquals(other.headers, headers);
  }

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
    context.canvas.translate(offset.dx, offset.dy);
    context.canvas.drawPicture(picture);
  }
}

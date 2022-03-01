import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'src/listener.dart';

const VectorGraphicsCodec _codec = VectorGraphicsCodec();

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
    widget.controller.load()
      .then((ui.Picture picture) {
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

  Future<ui.Picture> load();

  bool equivalent(VectorGraphicsController other) => false;
}

class VectorGraphicsAssetController extends VectorGraphicsController {
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
  Future<ui.Picture> load() {
    return assetBundle.load(assetName).then((ByteData data) {
      final FlutterVectorGraphicsListener listener =
          FlutterVectorGraphicsListener();
      _codec.decode(data, listener);
      return listener.toPicture();
    });
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
}

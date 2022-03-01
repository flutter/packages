import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'src/listener.dart';

const VectorGraphicsCodec _codec = VectorGraphicsCodec();

/// A widget that displays a vector_graphics formatted asset.
class VectorGraphicsWidget extends StatefulWidget {
  const VectorGraphicsWidget.asset({ Key? key, required this.assetName }) : super(key: key);

  /// The name of the asset to be displayed.
  final String assetName;

  @override
  State<VectorGraphicsWidget> createState() => _VectorGraphicsWidgetState();
}

class _VectorGraphicsWidgetState extends State<VectorGraphicsWidget> {
  ui.Picture? _picture;

  @override
  void initState() {
    _loadAssetBytes();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant VectorGraphicsWidget oldWidget) {
    if (oldWidget.assetName != widget.assetName) {
      _loadAssetBytes();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _picture?.dispose();
    super.dispose();
  }

  void _loadAssetBytes() {
    final AssetBundle bundle = DefaultAssetBundle.of(context);
    _picture?.dispose();
    bundle.load(widget.assetName).then((ByteData data) {
      final FlutterVectorGraphicsListener listener = FlutterVectorGraphicsListener();
      _codec.decode(data, listener);
      _picture = listener.toPicture();
    }, onError: (dynamic error, StackTrace stackTrace) {
      _picture?.dispose();
      _picture = null;
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

class _RawVectorGraphicsWidget extends SingleChildRenderObjectWidget {
  const _RawVectorGraphicsWidget({Key? key, required this.picture}) : super(key: key);

  final ui.Picture picture;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderVectorGraphics(picture);
  }

  @override
  void updateRenderObject(BuildContext context, covariant _RenderVectorGraphics renderObject) {
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

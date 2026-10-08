import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/src/engine/liquid_glass_layer.dart';
import 'package:liquid_glass_widgets/src/engine/liquid_glass_settings.dart';
import 'package:liquid_glass_widgets/src/engine/rendering/liquid_glass_render_object.dart';

void main() {
  test('deactivating push-back does not read an unlaid-out ancestor', () {
    final layer = _layer(active: true);
    final translation = RenderFractionalTranslation(
      translation: const Offset(.25, 0),
      child: layer,
    );
    final root = RenderProxyBox(translation);
    final owner = PipelineOwner()..rootNode = root;
    addTearDown(() {
      owner.rootNode = null;
      root.child = null;
      translation.child = null;
      layer.dispose();
      translation.dispose();
      root.dispose();
      owner.dispose();
    });

    expect(translation.hasSize, isFalse);
    // updateRenderObject runs before layout. Being attached is insufficient
    // for getTransformTo: FractionalTranslation needs its own size.
    expect(() => layer.pushBackActive = false, returnsNormally);
    translation.layout(BoxConstraints.tight(const Size(100, 40)));
    expect(layer.matteTransform.getTranslation().x, 25);
  });

  testWidgets(
      'paint refreshes the resting baseline between sheet presentations',
      (tester) async {
    final key = GlobalKey();
    Future<void> frame(
        {required bool active,
        required double scale,
        required double x,
        required Offset origin,
        bool selfScaled = false}) async {
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
            alignment: Alignment.topLeft,
            child: Transform.translate(
              offset: Offset(x, 0),
              child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.topLeft,
                  child: _Layer(
                      key: key,
                      active: active,
                      origin: origin,
                      selfScaled: selfScaled)),
            )),
      ));
    }

    RenderLiquidGlassLayer render() =>
        key.currentContext!.findRenderObject()! as RenderLiquidGlassLayer;
    await frame(active: false, scale: 1, x: 10, origin: const Offset(10, 20));
    await frame(active: true, scale: .9, x: 30, origin: const Offset(30, 40));
    expect(render().matteTransform[0], 1);
    expect(render().matteTransform.getTranslation().x, 10);
    expect(render().captureOriginInScreenSpace, const Offset(10, 20));

    // Dismissal moves the resting page. Its next paint must refresh BOTH
    // snapshots, rather than reusing the previous presentation's baseline.
    await frame(active: false, scale: 1, x: 50, origin: const Offset(50, 60));
    await frame(active: true, scale: .9, x: 70, origin: const Offset(70, 80));
    expect(render().matteTransform[0], 1);
    expect(render().matteTransform.getTranslation().x, 50);
    expect(render().captureOriginInScreenSpace, const Offset(50, 60));

    // Self-scaling controls and ordinary app-level scaling still use live UVs.
    await frame(
        active: true,
        scale: .8,
        x: 80,
        origin: const Offset(80, 90),
        selfScaled: true);
    expect(render().matteTransform[0], closeTo(.8, 1e-9));
    expect(render().captureOriginInScreenSpace, const Offset(80, 90));
    await frame(active: false, scale: .7, x: 90, origin: const Offset(90, 100));
    expect(render().matteTransform[0], closeTo(.7, 1e-9));
    expect(render().captureOriginInScreenSpace, const Offset(90, 100));
    expect(tester.takeException(), isNull);
  });
}

RenderLiquidGlassLayer _layer({required bool active}) => RenderLiquidGlassLayer(
      renderShader: null,
      devicePixelRatio: 1,
      settings: const LiquidGlassSettings(),
      shadows: const [],
      link: GeometryRenderLink(),
      pushBackActive: active,
    );

// Exercise the real render object without depending on Impeller availability.
// Empty geometry skips shader drawing but retains layout/paint and UV caching.
class _Layer extends SingleChildRenderObjectWidget {
  const _Layer(
      {super.key,
      required this.active,
      required this.origin,
      required this.selfScaled})
      : super(child: const SizedBox(width: 100, height: 40));
  final bool active;
  final Offset origin;
  final bool selfScaled;
  @override
  RenderLiquidGlassLayer createRenderObject(BuildContext context) =>
      _layer(active: active)
        ..captureOriginInScreenSpace = origin
        ..selfScaled = selfScaled;
  @override
  void updateRenderObject(
      BuildContext context, RenderLiquidGlassLayer renderObject) {
    renderObject
      ..captureOriginInScreenSpace = origin
      ..selfScaled = selfScaled
      ..pushBackActive = active;
  }
}

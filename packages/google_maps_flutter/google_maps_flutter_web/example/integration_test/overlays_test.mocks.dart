// Mocks generated by Mockito 5.4.3 from annotations
// in google_maps_flutter_web_integration_tests/integration_test/overlays_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:google_maps_flutter_platform_interface/src/types/types.dart'
    as _i2;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeTile_0 extends _i1.SmartFake implements _i2.Tile {
  _FakeTile_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [TileProvider].
///
/// See the documentation for Mockito's code generation for more information.
class MockTileProvider extends _i1.Mock implements _i2.TileProvider {
  @override
  _i3.Future<_i2.Tile> getTile(
    int? x,
    int? y,
    int? zoom,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #getTile,
          [
            x,
            y,
            zoom,
          ],
        ),
        returnValue: _i3.Future<_i2.Tile>.value(_FakeTile_0(
          this,
          Invocation.method(
            #getTile,
            [
              x,
              y,
              zoom,
            ],
          ),
        )),
        returnValueForMissingStub: _i3.Future<_i2.Tile>.value(_FakeTile_0(
          this,
          Invocation.method(
            #getTile,
            [
              x,
              y,
              zoom,
            ],
          ),
        )),
      ) as _i3.Future<_i2.Tile>);
}

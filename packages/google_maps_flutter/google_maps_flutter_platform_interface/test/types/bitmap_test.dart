// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$BitmapDescriptor', () {
    test('toJson / fromJson', () {
      final BitmapDescriptor descriptor =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);
      final Object json = descriptor.toJson();

      // Rehydrate a new bitmap descriptor...
      final BitmapDescriptor descriptorFromJson =
          BitmapDescriptor.fromJson(json);

      expect(descriptorFromJson, isNot(descriptor)); // New instance
      expect(descriptorFromJson.toJson(), json);
    });

    group('fromBytes constructor', () {
      test('returns BytesBitmap', () {
        final BitmapDescriptor descriptor = BitmapDescriptor.fromBytes(
          Uint8List.fromList(<int>[1, 2, 3]),
        );
        expect(descriptor, isA<BytesBitmap>());
      });

      test('with empty byte array, throws assertion error', () {
        expect(() {
          BitmapDescriptor.fromBytes(Uint8List.fromList(<int>[]));
        }, throwsAssertionError);
      });

      test('with bytes', () {
        final BitmapDescriptor descriptor = BitmapDescriptor.fromBytes(
          Uint8List.fromList(<int>[1, 2, 3]),
        );
        expect(descriptor, isA<BytesBitmap>());
        expect(
            descriptor.toJson(),
            equals(<Object>[
              'fromBytes',
              <int>[1, 2, 3],
            ]));
        descriptor as BytesBitmap;
        expect(descriptor.byteData, Uint8List.fromList(<int>[1, 2, 3]));
      });

      test('with size, not on the web, size is ignored', () {
        final BitmapDescriptor descriptor = BitmapDescriptor.fromBytes(
          Uint8List.fromList(<int>[1, 2, 3]),
          size: const Size(40, 20),
        );

        expect(
            descriptor.toJson(),
            equals(<Object>[
              'fromBytes',
              <int>[1, 2, 3],
            ]));
        descriptor as BytesBitmap;
        expect(descriptor.byteData, Uint8List.fromList(<int>[1, 2, 3]));
        expect(descriptor.size, null);
      }, skip: kIsWeb);

      test('with size, on the web, size is preserved', () {
        final BitmapDescriptor descriptor = BitmapDescriptor.fromBytes(
          Uint8List.fromList(<int>[1, 2, 3]),
          size: const Size(40, 20),
        );

        expect(
            descriptor.toJson(),
            equals(<Object>[
              'fromBytes',
              <int>[1, 2, 3],
              <int>[40, 20],
            ]));
        descriptor as BytesBitmap;
        expect(descriptor.byteData, Uint8List.fromList(<int>[1, 2, 3]));
        expect(descriptor.size, const Size(40, 20));
      }, skip: !kIsWeb);
    });

    group('fromJson validation', () {
      group('type validation', () {
        test('correct type', () {
          expect(BitmapDescriptor.fromJson(<dynamic>['defaultMarker']),
              isA<DefaultMarker>());
        });

        test('wrong type', () {
          expect(() {
            BitmapDescriptor.fromJson(<dynamic>['bogusType']);
          }, throwsAssertionError);
        });
      });
      group('defaultMarker', () {
        test('hue is null', () {
          expect(BitmapDescriptor.fromJson(<dynamic>['defaultMarker']),
              isA<DefaultMarker>());
        });

        test('hue is number', () {
          expect(BitmapDescriptor.fromJson(<dynamic>['defaultMarker', 158]),
              isA<DefaultMarker>());
        });

        test('hue is not number', () {
          expect(() {
            BitmapDescriptor.fromJson(<dynamic>['defaultMarker', 'nope']);
          }, throwsAssertionError);
        });

        test('hue is out of range', () {
          expect(() {
            BitmapDescriptor.fromJson(<dynamic>['defaultMarker', -1]);
          }, throwsAssertionError);
          expect(() {
            BitmapDescriptor.fromJson(<dynamic>['defaultMarker', 361]);
          }, throwsAssertionError);
        });
      });
      group('fromBytes', () {
        test('with bytes', () {
          expect(
              BitmapDescriptor.fromJson(<dynamic>[
                'fromBytes',
                Uint8List.fromList(<int>[1, 2, 3])
              ]),
              isA<BytesBitmap>());
        });

        test('without bytes', () {
          expect(() {
            BitmapDescriptor.fromJson(<dynamic>['fromBytes', null]);
          }, throwsAssertionError);
          expect(() {
            BitmapDescriptor.fromJson(<dynamic>['fromBytes', <dynamic>[]]);
          }, throwsAssertionError);
        });
      });
      group('fromAsset', () {
        test('name is passed', () {
          expect(
              BitmapDescriptor.fromJson(
                  <dynamic>['fromAsset', 'some/path.png']),
              isA<AssetBitmap>());
        });

        test('name cannot be null or empty', () {
          expect(() {
            BitmapDescriptor.fromJson(<dynamic>['fromAsset', null]);
          }, throwsAssertionError);
          expect(() {
            BitmapDescriptor.fromJson(<dynamic>['fromAsset', '']);
          }, throwsAssertionError);
        });

        test('package is passed', () {
          expect(
              BitmapDescriptor.fromJson(
                  <dynamic>['fromAsset', 'some/path.png', 'some_package']),
              isA<AssetBitmap>());
        });

        test('package cannot be null or empty', () {
          expect(() {
            BitmapDescriptor.fromJson(
                <dynamic>['fromAsset', 'some/path.png', null]);
          }, throwsAssertionError);
          expect(() {
            BitmapDescriptor.fromJson(
                <dynamic>['fromAsset', 'some/path.png', '']);
          }, throwsAssertionError);
        });
      });
      group('fromAssetImage', () {
        test('name and dpi passed', () {
          expect(
              BitmapDescriptor.fromJson(
                  <dynamic>['fromAssetImage', 'some/path.png', 1.0]),
              isA<AssetImageBitmap>());
        });

        test('mipmaps determines dpi', () async {
          const ImageConfiguration imageConfiguration = ImageConfiguration(
            devicePixelRatio: 3,
          );

          final BitmapDescriptor mip = await BitmapDescriptor.fromAssetImage(
            imageConfiguration,
            'red_square.png',
          );
          final BitmapDescriptor scaled = await BitmapDescriptor.fromAssetImage(
            imageConfiguration,
            'red_square.png',
            mipmaps: false,
          );

          expect((mip.toJson() as List<dynamic>)[2], 1);
          expect((scaled.toJson() as List<dynamic>)[2], 3);
        },
            // TODO(stuartmorgan): Investigate timeout on web.
            skip: kIsWeb);

        test('name cannot be null or empty', () {
          expect(() {
            BitmapDescriptor.fromJson(<dynamic>['fromAssetImage', null, 1.0]);
          }, throwsAssertionError);
          expect(() {
            BitmapDescriptor.fromJson(<dynamic>['fromAssetImage', '', 1.0]);
          }, throwsAssertionError);
        });

        test('dpi must be number', () {
          expect(() {
            BitmapDescriptor.fromJson(
                <dynamic>['fromAssetImage', 'some/path.png', null]);
          }, throwsAssertionError);
          expect(() {
            BitmapDescriptor.fromJson(
                <dynamic>['fromAssetImage', 'some/path.png', 'one']);
          }, throwsAssertionError);
        });

        test('with optional [width, height] List', () {
          expect(
              BitmapDescriptor.fromJson(<dynamic>[
                'fromAssetImage',
                'some/path.png',
                1.0,
                <dynamic>[640, 480]
              ]),
              isA<AssetImageBitmap>());
        });

        test(
            'optional [width, height] List cannot be null or not contain 2 elements',
            () {
          expect(() {
            BitmapDescriptor.fromJson(
                <dynamic>['fromAssetImage', 'some/path.png', 1.0, null]);
          }, throwsAssertionError);
          expect(() {
            BitmapDescriptor.fromJson(
                <dynamic>['fromAssetImage', 'some/path.png', 1.0, <dynamic>[]]);
          }, throwsAssertionError);
          expect(() {
            BitmapDescriptor.fromJson(<dynamic>[
              'fromAssetImage',
              'some/path.png',
              1.0,
              <dynamic>[640, 480, 1024]
            ]);
          }, throwsAssertionError);
        });
      });

      group('bytes', () {
        test('with bytes', () {
          expect(
              BitmapDescriptor.fromJson(<dynamic>[
                BytesMapBitmap.type,
                <String, Object?>{
                  'byteData': Uint8List.fromList(<int>[1, 2, 3]),
                  'bitmapScaling': MapBitmapScaling.auto.name,
                  'imagePixelRatio': 1.0,
                  'width': 1.0,
                  'height': 1.0,
                }
              ]),
              isA<BytesMapBitmap>());
        });

        test('without bytes', () {
          expect(() {
            BitmapDescriptor.fromJson(
                <dynamic>[BytesMapBitmap.type, null, 'auto', 3.0]);
          }, throwsAssertionError);
          expect(() {
            BitmapDescriptor.fromJson(
                <dynamic>[BytesMapBitmap.type, <dynamic>[], 'auto', 3.0]);
          }, throwsAssertionError);
        });
      });

      group('asset', () {
        test('name and dpi passed', () {
          expect(
              BitmapDescriptor.fromJson(<dynamic>[
                AssetMapBitmap.type,
                <String, Object?>{
                  'assetName': 'red_square.png',
                  'bitmapScaling': MapBitmapScaling.auto.name,
                  'imagePixelRatio': 1.0,
                }
              ]),
              isA<AssetMapBitmap>());
        });

        test('name cannot be null or empty', () {
          expect(() {
            BitmapDescriptor.fromJson(<dynamic>[
              AssetMapBitmap.type,
              null,
              'auto',
              1.0,
            ]);
          }, throwsAssertionError);
          expect(() {
            BitmapDescriptor.fromJson(<dynamic>[
              AssetMapBitmap.type,
              '',
              'auto',
              1.0,
            ]);
          }, throwsAssertionError);
        });

        test('dpi must be number', () {
          expect(() {
            BitmapDescriptor.fromJson(<dynamic>[
              AssetMapBitmap.type,
              <String, Object?>{
                'assetName': 'red_square.png',
                'bitmapScaling': MapBitmapScaling.auto.name,
                'imagePixelRatio': 'string',
              }
            ]);
          }, throwsAssertionError);
          expect(() {
            BitmapDescriptor.fromJson(<dynamic>[
              AssetMapBitmap.type,
              <String, Object?>{
                'assetName': 'red_square.png',
                'bitmapScaling': MapBitmapScaling.auto.name,
                'imagePixelRatio': null,
              }
            ]);
          }, throwsAssertionError);
        });

        test('with optional [width, height]', () {
          expect(
              BitmapDescriptor.fromJson(<dynamic>[
                AssetMapBitmap.type,
                <String, Object?>{
                  'assetName': 'red_square.png',
                  'bitmapScaling': MapBitmapScaling.auto.name,
                  'imagePixelRatio': 1.0,
                  'width': 1.0,
                  'height': 1.0,
                }
              ]),
              isA<AssetMapBitmap>());
        });

        test('optional width and height parameters must be in proper format',
            () {
          expect(() {
            BitmapDescriptor.fromJson(<dynamic>[
              'fromAssetImage',
              'some/path.png',
              'auto',
              1.0,
              null
            ]);
          }, throwsAssertionError);
          expect(() {
            BitmapDescriptor.fromJson(<dynamic>[
              'fromAssetImage',
              'some/path.png',
              'auto',
              1.0,
              <dynamic>[]
            ]);
          }, throwsAssertionError);
          expect(() {
            BitmapDescriptor.fromJson(<dynamic>[
              AssetMapBitmap.type,
              'some/path.png',
              <String, Object?>{
                'assetName': 'red_square.png',
                'bitmapScaling': MapBitmapScaling.auto.name,
                'imagePixelRatio': null,
                'width': null,
                'height': 1.0,
              }
            ]);
          }, throwsAssertionError);
          expect(() {
            BitmapDescriptor.fromJson(<dynamic>[
              AssetMapBitmap.type,
              'some/path.png',
              <String, Object?>{
                'assetName': 'red_square.png',
                'bitmapScaling': MapBitmapScaling.auto.name,
                'imagePixelRatio': null,
                'width': 1.0,
                'height': null,
              }
            ]);
          }, throwsAssertionError);
          expect(() {
            BitmapDescriptor.fromJson(<dynamic>[
              AssetMapBitmap.type,
              'some/path.png',
              <String, Object?>{
                'assetName': 'red_square.png',
                'bitmapScaling': MapBitmapScaling.auto.name,
                'imagePixelRatio': null,
                'width': '1.0',
              }
            ]);
          }, throwsAssertionError);
        });
      });
    });
  });

  group('AssetMapBitmap', () {
    test('construct', () async {
      final BitmapDescriptor descriptor = AssetMapBitmap(
        'red_square.png',
      );
      expect(descriptor, isA<BitmapDescriptor>());
      expect(descriptor, isA<AssetMapBitmap>());
      expect(
          descriptor.toJson(),
          equals(<Object>[
            AssetMapBitmap.type,
            <String, Object?>{
              'assetName': 'red_square.png',
              'bitmapScaling': MapBitmapScaling.auto.name,
              'imagePixelRatio': 1.0,
            }
          ]));
      descriptor as AssetMapBitmap;
      expect(descriptor.assetName, 'red_square.png');
      expect(descriptor.bitmapScaling, MapBitmapScaling.auto);
      expect(descriptor.imagePixelRatio, 1.0);
    });

    test('construct with imagePixelRatio', () async {
      final BitmapDescriptor descriptor =
          AssetMapBitmap('red_square.png', imagePixelRatio: 1.2345);

      expect(descriptor, isA<BitmapDescriptor>());
      expect(descriptor, isA<AssetMapBitmap>());
      expect(
          descriptor.toJson(),
          equals(<Object>[
            AssetMapBitmap.type,
            <String, Object?>{
              'assetName': 'red_square.png',
              'bitmapScaling': MapBitmapScaling.auto.name,
              'imagePixelRatio': 1.2345,
            }
          ]));
      descriptor as AssetMapBitmap;
      expect(descriptor.assetName, 'red_square.png');
      expect(descriptor.bitmapScaling, MapBitmapScaling.auto);
      expect(descriptor.imagePixelRatio, 1.2345);
    });

    test('construct with width', () async {
      const double width = 100;
      final BitmapDescriptor descriptor =
          AssetMapBitmap('red_square.png', width: width);

      expect(descriptor, isA<BitmapDescriptor>());
      expect(descriptor, isA<AssetMapBitmap>());
      expect(
          descriptor.toJson(),
          equals(<Object>[
            AssetMapBitmap.type,
            <String, Object?>{
              'assetName': 'red_square.png',
              'bitmapScaling': MapBitmapScaling.auto.name,
              'imagePixelRatio': 1.0,
              'width': width,
            }
          ]));
      descriptor as AssetMapBitmap;
      expect(descriptor.assetName, 'red_square.png');
      expect(descriptor.bitmapScaling, MapBitmapScaling.auto);
      expect(descriptor.imagePixelRatio, 1.0);
      expect(descriptor.width, width);
    });

    test('create', () async {
      final BitmapDescriptor descriptor = await AssetMapBitmap.create(
          ImageConfiguration.empty, 'red_square.png');
      expect(descriptor, isA<BitmapDescriptor>());
      expect(descriptor, isA<AssetMapBitmap>());
      expect(
          descriptor.toJson(),
          equals(<Object>[
            AssetMapBitmap.type,
            <String, Object>{
              'assetName': 'red_square.png',
              'bitmapScaling': MapBitmapScaling.auto.name,
              'imagePixelRatio': 1.0
            }
          ]));
      descriptor as AssetMapBitmap;
      expect(descriptor.assetName, 'red_square.png');
      expect(descriptor.bitmapScaling, MapBitmapScaling.auto);
      expect(descriptor.imagePixelRatio, 1.0);
    },
        // TODO(stuartmorgan): Investigate timeout on web.
        skip: kIsWeb);

    test('create with size', () async {
      const Size size = Size(100, 200);
      const ImageConfiguration imageConfiguration =
          ImageConfiguration(size: size);
      final BitmapDescriptor descriptor =
          await AssetMapBitmap.create(imageConfiguration, 'red_square.png');

      expect(descriptor, isA<BitmapDescriptor>());
      expect(descriptor, isA<AssetMapBitmap>());
      expect(
          descriptor.toJson(),
          equals(<Object>[
            AssetMapBitmap.type,
            <String, Object>{
              'assetName': 'red_square.png',
              'bitmapScaling': MapBitmapScaling.auto.name,
              'imagePixelRatio': 1.0,
              'width': 100.0,
              'height': 200.0
            }
          ]));
      descriptor as AssetMapBitmap;
      expect(descriptor.assetName, 'red_square.png');
      expect(descriptor.bitmapScaling, MapBitmapScaling.auto);
      expect(descriptor.imagePixelRatio, 1.0);
      expect(descriptor.width, 100.0);
      expect(descriptor.height, 200.0);
    });

    test('create with width', () async {
      const ImageConfiguration imageConfiguration = ImageConfiguration.empty;
      final BitmapDescriptor descriptor = await AssetMapBitmap.create(
          imageConfiguration, 'red_square.png',
          width: 100);

      expect(descriptor, isA<BitmapDescriptor>());
      expect(descriptor, isA<AssetMapBitmap>());
      expect(
          descriptor.toJson(),
          equals(<Object>[
            AssetMapBitmap.type,
            <String, Object>{
              'assetName': 'red_square.png',
              'bitmapScaling': MapBitmapScaling.auto.name,
              'imagePixelRatio': 1.0,
              'width': 100.0,
            }
          ]));
      descriptor as AssetMapBitmap;
      expect(descriptor.assetName, 'red_square.png');
      expect(descriptor.bitmapScaling, MapBitmapScaling.auto);
      expect(descriptor.imagePixelRatio, 1.0);
      expect(descriptor.width, 100.0);
    });

    test('create with height', () async {
      const ImageConfiguration imageConfiguration = ImageConfiguration.empty;
      final BitmapDescriptor descriptor = await AssetMapBitmap.create(
          imageConfiguration, 'red_square.png',
          height: 200);

      expect(descriptor, isA<BitmapDescriptor>());
      expect(descriptor, isA<AssetMapBitmap>());
      expect(
          descriptor.toJson(),
          equals(<Object>[
            AssetMapBitmap.type,
            <String, Object>{
              'assetName': 'red_square.png',
              'bitmapScaling': MapBitmapScaling.auto.name,
              'imagePixelRatio': 1.0,
              'height': 200.0
            }
          ]));
      descriptor as AssetMapBitmap;
      expect(descriptor.assetName, 'red_square.png');
      expect(descriptor.bitmapScaling, MapBitmapScaling.auto);
      expect(descriptor.imagePixelRatio, 1.0);
      expect(descriptor.height, 200.0);
    });
  },
      // TODO(stuartmorgan): Investigate timeout on web.
      skip: kIsWeb);

  group('BytesMapBitmap', () {
    test('construct with empty byte array, throws assertion error', () {
      expect(() {
        BytesMapBitmap(Uint8List.fromList(<int>[]));
      }, throwsAssertionError);
    });

    test('construct', () {
      final BitmapDescriptor descriptor = BytesMapBitmap(
        Uint8List.fromList(<int>[1, 2, 3]),
      );
      expect(descriptor, isA<BitmapDescriptor>());
      expect(descriptor, isA<BytesMapBitmap>());
      expect(
          descriptor.toJson(),
          equals(<Object>[
            BytesMapBitmap.type,
            <String, Object>{
              'byteData': <int>[1, 2, 3],
              'bitmapScaling': MapBitmapScaling.auto.name,
              'imagePixelRatio': 1.0,
            }
          ]));
      descriptor as BytesMapBitmap;
      expect(descriptor.byteData, Uint8List.fromList(<int>[1, 2, 3]));
      expect(descriptor.bitmapScaling, MapBitmapScaling.auto);
      expect(descriptor.imagePixelRatio, 1.0);
    });

    test('construct with width', () {
      const double width = 100;
      final BitmapDescriptor descriptor = BytesMapBitmap(
        Uint8List.fromList(<int>[1, 2, 3]),
        width: width,
      );

      expect(descriptor, isA<BytesMapBitmap>());
      expect(
          descriptor.toJson(),
          equals(<Object>[
            BytesMapBitmap.type,
            <String, Object>{
              'byteData': <int>[1, 2, 3],
              'bitmapScaling': MapBitmapScaling.auto.name,
              'imagePixelRatio': 1.0,
              'width': 100.0
            }
          ]));
      descriptor as BytesMapBitmap;
      expect(descriptor.byteData, Uint8List.fromList(<int>[1, 2, 3]));
      expect(descriptor.bitmapScaling, MapBitmapScaling.auto);
      expect(descriptor.imagePixelRatio, 1.0);
      expect(descriptor.width, 100.0);
    });

    test('construct with imagePixelRatio', () {
      final BitmapDescriptor descriptor = BytesMapBitmap(
        Uint8List.fromList(<int>[1, 2, 3]),
        imagePixelRatio: 1.2345,
      );

      expect(descriptor, isA<BytesMapBitmap>());
      expect(
          descriptor.toJson(),
          equals(<Object>[
            BytesMapBitmap.type,
            <String, Object>{
              'byteData': <int>[1, 2, 3],
              'bitmapScaling': MapBitmapScaling.auto.name,
              'imagePixelRatio': 1.2345
            }
          ]));
      descriptor as BytesMapBitmap;
      expect(descriptor.byteData, Uint8List.fromList(<int>[1, 2, 3]));
      expect(descriptor.bitmapScaling, MapBitmapScaling.auto);
      expect(descriptor.imagePixelRatio, 1.2345);
    });
  });

  group('PinConfig', () {
    test('construct with empty values, throws assertion error', () {
      expect(() => PinConfig(), throwsAssertionError);
    });

    test('construct', () {
      const PinConfig pinConfig = PinConfig(
        backgroundColor: Colors.green,
        borderColor: Colors.blue,
      );
      expect(pinConfig, isA<BitmapDescriptor>());
      expect(pinConfig.backgroundColor, Colors.green);
      expect(pinConfig.borderColor, Colors.blue);
      expect(
        pinConfig.toJson(),
        <Object>[
          PinConfig.type,
          <String, Object>{
            'backgroundColor': Colors.green.value,
            'borderColor': Colors.blue.value,
          },
        ],
      );
    });

    test('construct with glyph text', () {
      final PinConfig pinConfig = PinConfig(
        backgroundColor: Colors.green,
        borderColor: Colors.blue,
        glyph: Glyph.text('Hello', textColor: Colors.red),
      );
      expect(pinConfig.glyph?.text, 'Hello');
      expect(pinConfig.glyph?.textColor, Colors.red);
      expect(
        pinConfig.toJson(),
        <Object>[
          PinConfig.type,
          <String, Object>{
            'backgroundColor': Colors.green.value,
            'borderColor': Colors.blue.value,
            'glyphText': 'Hello',
            'glyphTextColor': Colors.red.value,
          },
        ],
      );
    });

    test('construct with glyph bitmap', () async {
      const BitmapDescriptor bitmap = AssetBitmap(name: 'red_square.png');
      final PinConfig pinConfig = PinConfig(
        backgroundColor: Colors.black,
        borderColor: Colors.red,
        glyph: Glyph.bitmap(bitmap),
      );

      expect(pinConfig.backgroundColor, Colors.black);
      expect(pinConfig.borderColor, Colors.red);
      expect(
        pinConfig.toJson(),
        <Object>[
          PinConfig.type,
          <String, Object>{
            'backgroundColor': Colors.black.value,
            'borderColor': Colors.red.value,
            'glyphBitmapDescriptor': bitmap.toJson(),
          },
        ],
      );
    });
  });

  test('mapBitmapScaling from String', () {
    expect(mapBitmapScalingFromString('auto'), MapBitmapScaling.auto);
    expect(mapBitmapScalingFromString('none'), MapBitmapScaling.none);
    expect(() => mapBitmapScalingFromString('invalid'), throwsArgumentError);
  });
}

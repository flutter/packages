// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_fonts/src/google_fonts_base.dart';
import 'package:google_fonts/src/google_fonts_descriptor.dart';
import 'package:google_fonts/src/google_fonts_variant.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

class MockHttpClient extends Mock implements http.Client {
  Future<http.Response> gets(dynamic uri, {dynamic headers}) {
    super.noSuchMethod(
      Invocation.method(
        #get,
        <Object?>[uri],
        <Symbol, Object?>{#headers: headers},
      ),
    );
    return Future<http.Response>.value(http.Response('', 200));
  }
}

class MockAssetManifest extends Mock implements AssetManifest {
  @override
  List<String> listAssets() => <String>[];
}

const String _fakeResponse = 'fake response body - success';
// The number of bytes in _fakeResponse.
const int _fakeResponseLengthInBytes = 28;
// Computed by converting _fakeResponse to bytes and getting sha 256 hash.
const String _fakeResponseHash =
    '1194f6ffe4d2f05258573616a77932c38041f3102763096c19437c3db1818a04';

final GoogleFontsFile _fakeResponseFile = GoogleFontsFile(
  _fakeResponseHash,
  _fakeResponseLengthInBytes,
);

final Map<GoogleFontsVariant, GoogleFontsFile> fakeFonts =
    <GoogleFontsVariant, GoogleFontsFile>{
      const GoogleFontsVariant(
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
          ):
          _fakeResponseFile,
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockHttpClient mockHttpClient;

  setUp(() async {
    mockHttpClient = MockHttpClient();
    httpClient = mockHttpClient;
    assetManifest = MockAssetManifest();
    GoogleFonts.config.allowRuntimeFetching = true;
    when(mockHttpClient.gets(any)).thenAnswer((_) async {
      return http.Response(_fakeResponse, 200);
    });
  });

  tearDown(() {
    clearCache();
  });

  test('pendingFonts waits for fonts to be loaded', () async {
    expect(await GoogleFonts.pendingFonts(), hasLength(0));

    googleFontsTextStyle(fontFamily: 'ab', fonts: fakeFonts);
    googleFontsTextStyle(fontFamily: 'cd', fonts: fakeFonts);

    expect(await GoogleFonts.pendingFonts(), hasLength(2));
    expect(await GoogleFonts.pendingFonts(), hasLength(0));
  });
}

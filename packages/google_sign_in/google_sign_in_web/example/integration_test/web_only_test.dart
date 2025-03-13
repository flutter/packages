// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart'
    show GoogleSignInPlugin;
import 'package:google_sign_in_web/src/gis_client.dart';
import 'package:google_sign_in_web/web_only.dart' as web;
import 'package:integration_test/integration_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart' as mockito;

import 'web_only_test.mocks.dart';

// Mock GisSdkClient so we can simulate any response from the JS side.
@GenerateMocks(<Type>[], customMocks: <MockSpec<dynamic>>[
  MockSpec<GisSdkClient>(onMissingStub: OnMissingStub.returnDefault),
])
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('non-web plugin instance', () {
    setUp(() {
      GoogleSignInPlatform.instance = NonWebImplementation();
    });

    testWidgets('renderButton throws', (WidgetTester _) async {
      expect(() {
        web.renderButton();
      }, throwsAssertionError);
    });

    testWidgets('requestServerAuthCode throws', (WidgetTester _) async {
      expect(() async {
        await web.requestServerAuthCode();
      }, throwsAssertionError);
    });
  });

  group('web plugin instance', () {
    const String someAuthCode = '50m3_4u7h_c0d3';
    late MockGisSdkClient mockGis;

    setUp(() {
      mockGis = MockGisSdkClient();
      GoogleSignInPlatform.instance = GoogleSignInPlugin(
        debugOverrideLoader: true,
        debugOverrideGisSdkClient: mockGis,
      )..initWithParams(
          const SignInInitParameters(
            clientId: 'does-not-matter',
          ),
        );
    });

    testWidgets('call reaches GIS API', (WidgetTester _) async {
      mockito
          .when(mockGis.requestServerAuthCode())
          .thenAnswer((_) => Future<String>.value(someAuthCode));

      final String? serverAuthCode = await web.requestServerAuthCode();

      expect(serverAuthCode, someAuthCode);
    });
  });
}

/// Fake non-web implementation used to verify that the web_only methods
/// throw when the wrong type of instance is configured.
class NonWebImplementation extends GoogleSignInPlatform {}

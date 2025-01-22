// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter_wkwebview/src/common/instance_manager.dart';
import 'package:webview_flutter_wkwebview/src/common/web_kit.g.dart';
import 'package:webview_flutter_wkwebview/src/foundation/foundation.dart';
import 'package:webview_flutter_wkwebview/src/foundation/foundation_api_impls.dart';

import '../common/test_web_kit.g.dart';
import 'foundation_test.mocks.dart';

@GenerateMocks(<Type>[
  TestNSObjectHostApi,
  TestNSUrlCredentialHostApi,
  TestNSUrlHostApi,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Foundation', () {
    late InstanceManager instanceManager;

    setUp(() {
      instanceManager = InstanceManager(onWeakReferenceRemoved: (_) {});
    });

    group('NSObject', () {
      late MockTestNSObjectHostApi mockPlatformHostApi;

      late NSObject object;

      setUp(() {
        mockPlatformHostApi = MockTestNSObjectHostApi();
        TestNSObjectHostApi.setUp(mockPlatformHostApi);

        object = NSObject.detached(instanceManager: instanceManager);
        instanceManager.addDartCreatedInstance(object);
      });

      tearDown(() {
        TestNSObjectHostApi.setUp(null);
      });

      test('addObserver', () async {
        final NSObject observer = NSObject.detached(
          instanceManager: instanceManager,
        );
        instanceManager.addDartCreatedInstance(observer);

        await object.addObserver(
          observer,
          keyPath: 'aKeyPath',
          options: <NSKeyValueObservingOptions>{
            NSKeyValueObservingOptions.initialValue,
            NSKeyValueObservingOptions.priorNotification,
          },
        );

        final List<NSKeyValueObservingOptionsEnumData?> optionsData =
            verify(mockPlatformHostApi.addObserver(
          instanceManager.getIdentifier(object),
          instanceManager.getIdentifier(observer),
          'aKeyPath',
          captureAny,
        )).captured.single as List<NSKeyValueObservingOptionsEnumData?>;

        expect(optionsData, hasLength(2));
        expect(
          optionsData[0]!.value,
          NSKeyValueObservingOptionsEnum.initialValue,
        );
        expect(
          optionsData[1]!.value,
          NSKeyValueObservingOptionsEnum.priorNotification,
        );
      });

      test('removeObserver', () async {
        final NSObject observer = NSObject.detached(
          instanceManager: instanceManager,
        );
        instanceManager.addDartCreatedInstance(observer);

        await object.removeObserver(observer, keyPath: 'aKeyPath');

        verify(mockPlatformHostApi.removeObserver(
          instanceManager.getIdentifier(object),
          instanceManager.getIdentifier(observer),
          'aKeyPath',
        ));
      });

      test('NSObjectHostApi.dispose', () async {
        int? callbackIdentifier;
        final InstanceManager instanceManager =
            InstanceManager(onWeakReferenceRemoved: (int identifier) {
          callbackIdentifier = identifier;
        });

        final NSObject object = NSObject.detached(
          instanceManager: instanceManager,
        );
        final int identifier = instanceManager.addDartCreatedInstance(object);

        NSObject.dispose(object);
        expect(callbackIdentifier, identifier);
      });

      test('observeValue', () async {
        final Completer<List<Object?>> argsCompleter =
            Completer<List<Object?>>();

        FoundationFlutterApis.instance = FoundationFlutterApis(
          instanceManager: instanceManager,
        );

        object = NSObject.detached(
          instanceManager: instanceManager,
          observeValue: (
            String keyPath,
            NSObject object,
            Map<NSKeyValueChangeKey, Object?> change,
          ) {
            argsCompleter.complete(<Object?>[keyPath, object, change]);
          },
        );
        instanceManager.addHostCreatedInstance(object, 1);

        FoundationFlutterApis.instance.object.observeValue(
          1,
          'keyPath',
          1,
          <NSKeyValueChangeKeyEnumData>[
            NSKeyValueChangeKeyEnumData(value: NSKeyValueChangeKeyEnum.oldValue)
          ],
          <ObjectOrIdentifier?>[
            ObjectOrIdentifier(isIdentifier: false, value: 'value'),
          ],
        );

        expect(
          argsCompleter.future,
          completion(<Object?>[
            'keyPath',
            object,
            <NSKeyValueChangeKey, Object?>{
              NSKeyValueChangeKey.oldValue: 'value',
            },
          ]),
        );
      });

      test('observeValue returns object in an `InstanceManager`', () async {
        final Completer<List<Object?>> argsCompleter =
            Completer<List<Object?>>();

        FoundationFlutterApis.instance = FoundationFlutterApis(
          instanceManager: instanceManager,
        );

        object = NSObject.detached(
          instanceManager: instanceManager,
          observeValue: (
            String keyPath,
            NSObject object,
            Map<NSKeyValueChangeKey, Object?> change,
          ) {
            argsCompleter.complete(<Object?>[keyPath, object, change]);
          },
        );
        instanceManager.addHostCreatedInstance(object, 1);

        final NSObject returnedObject = NSObject.detached(
          instanceManager: instanceManager,
        );
        instanceManager.addHostCreatedInstance(returnedObject, 2);

        FoundationFlutterApis.instance.object.observeValue(
          1,
          'keyPath',
          1,
          <NSKeyValueChangeKeyEnumData>[
            NSKeyValueChangeKeyEnumData(value: NSKeyValueChangeKeyEnum.oldValue)
          ],
          <ObjectOrIdentifier?>[
            ObjectOrIdentifier(isIdentifier: true, value: 2),
          ],
        );

        expect(
          argsCompleter.future,
          completion(<Object?>[
            'keyPath',
            object,
            <NSKeyValueChangeKey, Object?>{
              NSKeyValueChangeKey.oldValue: returnedObject,
            },
          ]),
        );
      });

      test('NSObjectFlutterApi.dispose', () {
        FoundationFlutterApis.instance = FoundationFlutterApis(
          instanceManager: instanceManager,
        );

        object = NSObject.detached(instanceManager: instanceManager);
        instanceManager.addHostCreatedInstance(object, 1);

        instanceManager.removeWeakReference(object);
        FoundationFlutterApis.instance.object.dispose(1);

        expect(instanceManager.containsIdentifier(1), isFalse);
      });
    });

    group('NSUrl', () {
      // Ensure the test host api is removed after each test run.
      tearDown(() => TestNSUrlHostApi.setUp(null));

      test('getAbsoluteString', () async {
        final MockTestNSUrlHostApi mockApi = MockTestNSUrlHostApi();
        TestNSUrlHostApi.setUp(mockApi);

        final NSUrl url = NSUrl.detached(instanceManager: instanceManager);
        instanceManager.addHostCreatedInstance(url, 0);

        when(mockApi.getAbsoluteString(0)).thenReturn('myString');

        expect(await url.getAbsoluteString(), 'myString');
      });

      test('Flutter API create', () {
        final NSUrlFlutterApi flutterApi = NSUrlFlutterApiImpl(
          instanceManager: instanceManager,
        );

        flutterApi.create(0);

        expect(instanceManager.getInstanceWithWeakReference(0), isA<NSUrl>());
      });
    });

    group('NSUrlCredential', () {
      tearDown(() {
        TestNSUrlCredentialHostApi.setUp(null);
      });

      test('HostApi createWithUser', () {
        final MockTestNSUrlCredentialHostApi mockApi =
            MockTestNSUrlCredentialHostApi();
        TestNSUrlCredentialHostApi.setUp(mockApi);

        final InstanceManager instanceManager = InstanceManager(
          onWeakReferenceRemoved: (_) {},
        );

        const String user = 'testString';
        const String password = 'testString2';

        const NSUrlCredentialPersistence persistence =
            NSUrlCredentialPersistence.permanent;

        final NSUrlCredential instance = NSUrlCredential.withUser(
          user: user,
          password: password,
          persistence: persistence,
          instanceManager: instanceManager,
        );

        verify(mockApi.createWithUser(
          instanceManager.getIdentifier(instance),
          user,
          password,
          persistence,
        ));
      });
    });

    group('NSUrlProtectionSpace', () {
      test('FlutterAPI create', () {
        final InstanceManager instanceManager = InstanceManager(
          onWeakReferenceRemoved: (_) {},
        );

        final NSUrlProtectionSpaceFlutterApiImpl api =
            NSUrlProtectionSpaceFlutterApiImpl(
          instanceManager: instanceManager,
        );

        const int instanceIdentifier = 0;

        api.create(
          instanceIdentifier,
          'testString',
          'testString',
          'testAuthenticationMethod',
        );

        expect(
          instanceManager.getInstanceWithWeakReference(instanceIdentifier),
          isA<NSUrlProtectionSpace>(),
        );
      });
    });

    group('NSUrlAuthenticationChallenge', () {
      test('FlutterAPI create', () {
        final InstanceManager instanceManager = InstanceManager(
          onWeakReferenceRemoved: (_) {},
        );

        final NSUrlAuthenticationChallengeFlutterApiImpl api =
            NSUrlAuthenticationChallengeFlutterApiImpl(
          instanceManager: instanceManager,
        );

        const int instanceIdentifier = 0;

        const int protectionSpaceIdentifier = 1;
        instanceManager.addHostCreatedInstance(
          NSUrlProtectionSpace.detached(
            host: null,
            realm: null,
            authenticationMethod: null,
            instanceManager: instanceManager,
          ),
          protectionSpaceIdentifier,
        );

        api.create(instanceIdentifier, protectionSpaceIdentifier);

        expect(
          instanceManager.getInstanceWithWeakReference(instanceIdentifier),
          isA<NSUrlAuthenticationChallenge>(),
        );
      });
    });
  });

  test('NSError', () {
    expect(
      const NSError(
        code: 0,
        domain: 'domain',
        userInfo: <String, Object?>{
          NSErrorUserInfoKey.NSLocalizedDescription: 'desc',
        },
      ).toString(),
      'desc (domain:0:{NSLocalizedDescription: desc})',
    );
    expect(
      const NSError(
        code: 0,
        domain: 'domain',
        userInfo: <String, Object?>{
          NSErrorUserInfoKey.NSLocalizedDescription: '',
        },
      ).toString(),
      'Error domain:0:{NSLocalizedDescription: }',
    );
    expect(
      const NSError(
        code: 255,
        domain: 'bar',
        userInfo: <String, Object?>{
          NSErrorUserInfoKey.NSLocalizedDescription: 'baz',
        },
      ).toString(),
      'baz (bar:255:{NSLocalizedDescription: baz})',
    );
    expect(
      const NSError(
        code: 255,
        domain: 'bar',
        userInfo: <String, Object?>{
          NSErrorUserInfoKey.NSLocalizedDescription: '',
        },
      ).toString(),
      'Error bar:255:{NSLocalizedDescription: }',
    );
  });
}

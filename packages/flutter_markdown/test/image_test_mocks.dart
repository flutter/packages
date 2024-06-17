// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:mockito/mockito.dart';

class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return createMockImageHttpClient(context);
  }
}

MockHttpClient createMockImageHttpClient(SecurityContext? _) {
  final MockHttpClient client = MockHttpClient();
  final MockHttpClientRequest request = MockHttpClientRequest();
  final MockHttpClientResponse response = MockHttpClientResponse();
  final MockHttpHeaders headers = MockHttpHeaders();

  final List<int> transparentImage = getTestImageData();

  when(client.getUrl(any))
      .thenAnswer((_) => Future<MockHttpClientRequest>.value(request));

  when(request.headers).thenReturn(headers);

  when(request.close())
      .thenAnswer((_) => Future<MockHttpClientResponse>.value(response));

  when(client.autoUncompress = any).thenAnswer((_) => null);

  when(response.contentLength).thenReturn(transparentImage.length);

  when(response.statusCode).thenReturn(HttpStatus.ok);

  when(response.compressionState)
      .thenReturn(HttpClientResponseCompressionState.notCompressed);

  // Define an image stream that streams the mock test image for all
  // image tests that request an image.
  StreamSubscription<List<int>> imageStream(Invocation invocation) {
    final void Function(List<int>)? onData =
        invocation.positionalArguments[0] as void Function(List<int>)?;
    final void Function()? onDone =
        invocation.namedArguments[#onDone] as void Function()?;
    final void Function(Object, [StackTrace?])? onError = invocation
        .namedArguments[#onError] as void Function(Object, [StackTrace?])?;
    final bool? cancelOnError =
        invocation.namedArguments[#cancelOnError] as bool?;

    return Stream<List<int>>.fromIterable(<List<int>>[transparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  when(response.listen(any,
          onError: anyNamed('onError'),
          onDone: anyNamed('onDone'),
          cancelOnError: anyNamed('cancelOnError')))
      .thenAnswer(imageStream);

  return client;
}

// A list of integers that can be consumed as image data in a stream.
final List<int> _transparentImage = <int>[
  // Image bytes.
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
];

List<int> getTestImageData() {
  return _transparentImage;
}

/// Define the "fake" data types to be used in mock data type definitions. These
/// fake data types are important in the definition of the return values of the
/// properties and methods of the mock data types for null safety.
// ignore: avoid_implementing_value_types
class _FakeDuration extends Fake implements Duration {}

class _FakeHttpClientRequest extends Fake implements HttpClientRequest {}

class _FakeUri extends Fake implements Uri {}

class _FakeHttpHeaders extends Fake implements HttpHeaders {}

class _FakeHttpClientResponse extends Fake implements HttpClientResponse {}

class _FakeSocket extends Fake implements Socket {}

class _FakeStreamSubscription<T> extends Fake
    implements StreamSubscription<T> {}

/// A class which mocks [HttpClient].
///
/// See the documentation for Mockito's code generation for more information.
class MockHttpClient extends Mock implements HttpClient {
  MockHttpClient() {
    throwOnMissingStub(this);
  }

  @override
  Duration get idleTimeout =>
      super.noSuchMethod(Invocation.getter(#idleTimeout),
          returnValue: _FakeDuration()) as Duration;

  @override
  set idleTimeout(Duration? idleTimeout) =>
      super.noSuchMethod(Invocation.setter(#idleTimeout, idleTimeout));

  @override
  bool get autoUncompress =>
      super.noSuchMethod(Invocation.getter(#autoUncompress), returnValue: false)
          as bool;

  @override
  set autoUncompress(bool? autoUncompress) =>
      super.noSuchMethod(Invocation.setter(#autoUncompress, autoUncompress));

  @override
  Future<HttpClientRequest> open(
          String? method, String? host, int? port, String? path) =>
      super.noSuchMethod(
          Invocation.method(#open, <Object?>[method, host, port, path]),
          returnValue: Future<_FakeHttpClientRequest>.value(
              _FakeHttpClientRequest())) as Future<HttpClientRequest>;

  @override
  Future<HttpClientRequest> openUrl(String? method, Uri? url) =>
      super.noSuchMethod(Invocation.method(#openUrl, <Object?>[method, url]),
          returnValue: Future<_FakeHttpClientRequest>.value(
              _FakeHttpClientRequest())) as Future<HttpClientRequest>;

  @override
  Future<HttpClientRequest> get(String? host, int? port, String? path) =>
      super.noSuchMethod(Invocation.method(#get, <Object?>[host, port, path]),
          returnValue: Future<_FakeHttpClientRequest>.value(
              _FakeHttpClientRequest())) as Future<HttpClientRequest>;

  @override
  Future<HttpClientRequest> getUrl(Uri? url) => super.noSuchMethod(
          Invocation.method(#getUrl, <Object?>[url]),
          returnValue:
              Future<_FakeHttpClientRequest>.value(_FakeHttpClientRequest()))
      as Future<HttpClientRequest>;

  @override
  Future<HttpClientRequest> post(String? host, int? port, String? path) =>
      super.noSuchMethod(Invocation.method(#post, <Object?>[host, port, path]),
          returnValue: Future<_FakeHttpClientRequest>.value(
              _FakeHttpClientRequest())) as Future<HttpClientRequest>;

  @override
  Future<HttpClientRequest> postUrl(Uri? url) => super.noSuchMethod(
          Invocation.method(#postUrl, <Object?>[url]),
          returnValue:
              Future<_FakeHttpClientRequest>.value(_FakeHttpClientRequest()))
      as Future<HttpClientRequest>;

  @override
  Future<HttpClientRequest> put(String? host, int? port, String? path) =>
      super.noSuchMethod(Invocation.method(#put, <Object?>[host, port, path]),
          returnValue: Future<_FakeHttpClientRequest>.value(
              _FakeHttpClientRequest())) as Future<HttpClientRequest>;

  @override
  Future<HttpClientRequest> putUrl(Uri? url) => super.noSuchMethod(
          Invocation.method(#putUrl, <Object?>[url]),
          returnValue:
              Future<_FakeHttpClientRequest>.value(_FakeHttpClientRequest()))
      as Future<HttpClientRequest>;

  @override
  Future<HttpClientRequest> delete(String? host, int? port, String? path) =>
      super.noSuchMethod(
          Invocation.method(#delete, <Object?>[host, port, path]),
          returnValue: Future<_FakeHttpClientRequest>.value(
              _FakeHttpClientRequest())) as Future<HttpClientRequest>;

  @override
  Future<HttpClientRequest> deleteUrl(Uri? url) => super.noSuchMethod(
          Invocation.method(#deleteUrl, <Object?>[url]),
          returnValue:
              Future<_FakeHttpClientRequest>.value(_FakeHttpClientRequest()))
      as Future<HttpClientRequest>;

  @override
  Future<HttpClientRequest> patch(String? host, int? port, String? path) =>
      super.noSuchMethod(Invocation.method(#patch, <Object?>[host, port, path]),
          returnValue: Future<_FakeHttpClientRequest>.value(
              _FakeHttpClientRequest())) as Future<HttpClientRequest>;

  @override
  Future<HttpClientRequest> patchUrl(Uri? url) => super.noSuchMethod(
          Invocation.method(#patchUrl, <Object?>[url]),
          returnValue:
              Future<_FakeHttpClientRequest>.value(_FakeHttpClientRequest()))
      as Future<HttpClientRequest>;

  @override
  Future<HttpClientRequest> head(String? host, int? port, String? path) =>
      super.noSuchMethod(Invocation.method(#head, <Object?>[host, port, path]),
          returnValue: Future<_FakeHttpClientRequest>.value(
              _FakeHttpClientRequest())) as Future<HttpClientRequest>;

  @override
  Future<HttpClientRequest> headUrl(Uri? url) => super.noSuchMethod(
          Invocation.method(#headUrl, <Object?>[url]),
          returnValue:
              Future<_FakeHttpClientRequest>.value(_FakeHttpClientRequest()))
      as Future<HttpClientRequest>;

  @override
  void addCredentials(
          Uri? url, String? realm, HttpClientCredentials? credentials) =>
      super.noSuchMethod(Invocation.method(
          #addCredentials, <Object?>[url, realm, credentials]));

  @override
  void addProxyCredentials(String? host, int? port, String? realm,
          HttpClientCredentials? credentials) =>
      super.noSuchMethod(Invocation.method(
          #addProxyCredentials, <Object?>[host, port, realm, credentials]));

  @override
  void close({bool? force = false}) => super.noSuchMethod(
      Invocation.method(#close, <Object?>[], <Symbol, Object?>{#force: force}));
}

/// A class which mocks [HttpClientRequest].
///
/// See the documentation for Mockito's code generation for more information.
class MockHttpClientRequest extends Mock implements HttpClientRequest {
  MockHttpClientRequest() {
    throwOnMissingStub(this);
  }

  @override
  bool get persistentConnection =>
      super.noSuchMethod(Invocation.getter(#persistentConnection),
          returnValue: false) as bool;

  @override
  set persistentConnection(bool? persistentConnection) => super.noSuchMethod(
      Invocation.setter(#persistentConnection, persistentConnection));

  @override
  bool get followRedirects => super
          .noSuchMethod(Invocation.getter(#followRedirects), returnValue: false)
      as bool;

  @override
  set followRedirects(bool? followRedirects) =>
      super.noSuchMethod(Invocation.setter(#followRedirects, followRedirects));

  @override
  int get maxRedirects =>
      super.noSuchMethod(Invocation.getter(#maxRedirects), returnValue: 0)
          as int;

  @override
  set maxRedirects(int? maxRedirects) =>
      super.noSuchMethod(Invocation.setter(#maxRedirects, maxRedirects));

  @override
  int get contentLength =>
      super.noSuchMethod(Invocation.getter(#contentLength), returnValue: 0)
          as int;

  @override
  set contentLength(int? contentLength) =>
      super.noSuchMethod(Invocation.setter(#contentLength, contentLength));

  @override
  bool get bufferOutput =>
      super.noSuchMethod(Invocation.getter(#bufferOutput), returnValue: false)
          as bool;

  @override
  set bufferOutput(bool? bufferOutput) =>
      super.noSuchMethod(Invocation.setter(#bufferOutput, bufferOutput));

  @override
  String get method =>
      super.noSuchMethod(Invocation.getter(#method), returnValue: '') as String;

  @override
  Uri get uri =>
      super.noSuchMethod(Invocation.getter(#uri), returnValue: _FakeUri())
          as Uri;

  @override
  HttpHeaders get headers => super.noSuchMethod(Invocation.getter(#headers),
      returnValue: _FakeHttpHeaders()) as HttpHeaders;

  @override
  List<Cookie> get cookies =>
      super.noSuchMethod(Invocation.getter(#cookies), returnValue: <Cookie>[])
          as List<Cookie>;

  @override
  Future<HttpClientResponse> get done => super.noSuchMethod(
          Invocation.getter(#done),
          returnValue:
              Future<_FakeHttpClientResponse>.value(_FakeHttpClientResponse()))
      as Future<HttpClientResponse>;

  @override
  Future<HttpClientResponse> close() => super.noSuchMethod(
          Invocation.method(#close, <Object?>[]),
          returnValue:
              Future<_FakeHttpClientResponse>.value(_FakeHttpClientResponse()))
      as Future<HttpClientResponse>;
}

/// A class which mocks [HttpClientResponse].
///
/// See the documentation for Mockito's code generation for more information.
class MockHttpClientResponse extends Mock implements HttpClientResponse {
  MockHttpClientResponse() {
    throwOnMissingStub(this);
  }

  // Include an override method for the inherited listen method. This method
  // intercepts HttpClientResponse listen calls to return a mock image.
  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
          {Function? onError, void Function()? onDone, bool? cancelOnError}) =>
      super.noSuchMethod(
              Invocation.method(
                #listen,
                <Object?>[onData],
                <Symbol, Object?>{
                  #onError: onError,
                  #onDone: onDone,
                  #cancelOnError: cancelOnError
                },
              ),
              returnValue: _FakeStreamSubscription<List<int>>())
          as StreamSubscription<List<int>>;

  @override
  int get statusCode =>
      super.noSuchMethod(Invocation.getter(#statusCode), returnValue: 0) as int;

  @override
  String get reasonPhrase =>
      super.noSuchMethod(Invocation.getter(#reasonPhrase), returnValue: '')
          as String;

  @override
  int get contentLength =>
      super.noSuchMethod(Invocation.getter(#contentLength), returnValue: 0)
          as int;

  @override
  HttpClientResponseCompressionState get compressionState =>
      super.noSuchMethod(Invocation.getter(#compressionState),
              returnValue: HttpClientResponseCompressionState.notCompressed)
          as HttpClientResponseCompressionState;

  @override
  bool get persistentConnection =>
      super.noSuchMethod(Invocation.getter(#persistentConnection),
          returnValue: false) as bool;

  @override
  bool get isRedirect =>
      super.noSuchMethod(Invocation.getter(#isRedirect), returnValue: false)
          as bool;

  @override
  List<RedirectInfo> get redirects =>
      super.noSuchMethod(Invocation.getter(#redirects),
          returnValue: <RedirectInfo>[]) as List<RedirectInfo>;

  @override
  HttpHeaders get headers => super.noSuchMethod(Invocation.getter(#headers),
      returnValue: _FakeHttpHeaders()) as HttpHeaders;

  @override
  List<Cookie> get cookies =>
      super.noSuchMethod(Invocation.getter(#cookies), returnValue: <Cookie>[])
          as List<Cookie>;

  @override
  Future<HttpClientResponse> redirect(
          [String? method, Uri? url, bool? followLoops]) =>
      super.noSuchMethod(
          Invocation.method(#redirect, <Object?>[method, url, followLoops]),
          returnValue: Future<_FakeHttpClientResponse>.value(
              _FakeHttpClientResponse())) as Future<HttpClientResponse>;

  @override
  Future<Socket> detachSocket() => super.noSuchMethod(
      Invocation.method(#detachSocket, <Object?>[]),
      returnValue: Future<_FakeSocket>.value(_FakeSocket())) as Future<Socket>;
}

/// A class which mocks [HttpHeaders].
///
/// See the documentation for Mockito's code generation for more information.
class MockHttpHeaders extends Mock implements HttpHeaders {
  MockHttpHeaders() {
    throwOnMissingStub(this);
  }

  @override
  int get contentLength =>
      super.noSuchMethod(Invocation.getter(#contentLength), returnValue: 0)
          as int;

  @override
  set contentLength(int? contentLength) =>
      super.noSuchMethod(Invocation.setter(#contentLength, contentLength));

  @override
  bool get persistentConnection =>
      super.noSuchMethod(Invocation.getter(#persistentConnection),
          returnValue: false) as bool;

  @override
  set persistentConnection(bool? persistentConnection) => super.noSuchMethod(
      Invocation.setter(#persistentConnection, persistentConnection));

  @override
  bool get chunkedTransferEncoding =>
      super.noSuchMethod(Invocation.getter(#chunkedTransferEncoding),
          returnValue: false) as bool;

  @override
  set chunkedTransferEncoding(bool? chunkedTransferEncoding) =>
      super.noSuchMethod(
          Invocation.setter(#chunkedTransferEncoding, chunkedTransferEncoding));

  @override
  List<String>? operator [](String? name) =>
      super.noSuchMethod(Invocation.method(#[], <Object?>[name]))
          as List<String>?;

  @override
  String? value(String? name) =>
      super.noSuchMethod(Invocation.method(#value, <Object?>[name])) as String?;

  @override
  void add(String? name, Object? value, {bool? preserveHeaderCase = false}) =>
      super.noSuchMethod(Invocation.method(#add, <Object?>[name, value],
          <Symbol, Object?>{#preserveHeaderCase: preserveHeaderCase}));

  @override
  void set(String? name, Object? value, {bool? preserveHeaderCase = false}) =>
      super.noSuchMethod(Invocation.method(#set, <Object?>[name, value],
          <Symbol, Object?>{#preserveHeaderCase: preserveHeaderCase}));

  @override
  void remove(String? name, Object? value) =>
      super.noSuchMethod(Invocation.method(#remove, <Object?>[name, value]));

  @override
  void removeAll(String? name) =>
      super.noSuchMethod(Invocation.method(#removeAll, <Object?>[name]));

  @override
  void forEach(void Function(String, List<String>)? action) =>
      super.noSuchMethod(Invocation.method(#forEach, <Object?>[action]));

  @override
  void noFolding(String? name) =>
      super.noSuchMethod(Invocation.method(#noFolding, <Object?>[name]));
}

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Factory class for creating [HttpRequest] instances.
class HttpRequestFactory {
  /// Creates a [HttpRequestFactory].
  const HttpRequestFactory();

  /// Creates and sends a URL request for the specified [url].
  ///
  /// Returns an `Object` (so this class can be mocked by mockito), which can be
  /// cast as [web.Response] from `package:web`.
  ///
  /// By default `request` will perform an HTTP GET request, but a different
  /// method (`POST`, `PUT`, `DELETE`, etc) can be used by specifying the
  /// [method] parameter.
  ///
  /// The Future is completed when the [web.Response] is available.
  ///
  /// If specified, [sendData] will be sent as the `body` of the fetch.
  ///
  /// The [withCredentials] parameter specified that credentials such as a cookie
  /// (already) set in the header or
  /// [authorization headers](http://tools.ietf.org/html/rfc1945#section-10.2)
  /// should be specified for the request. Details to keep in mind when using
  /// credentials:
  ///
  /// /// Using credentials is only useful for cross-origin requests.
  /// /// The `Access-Control-Allow-Origin` header of `url` cannot contain a wildcard (///).
  /// /// The `Access-Control-Allow-Credentials` header of `url` must be set to true.
  /// /// If `Access-Control-Expose-Headers` has not been set to true, only a subset of all the response headers will be returned when calling [getAllResponseHeaders].
  ///
  /// The following is equivalent to the [getString] sample above:
  ///
  /// ```dart
  /// var name = Uri.encodeQueryComponent('John');
  /// var id = Uri.encodeQueryComponent('42');
  /// HttpRequest.request('users.json?name=$name&id=$id')
  ///   .then((HttpRequest resp) {
  ///     // Do something with the response.
  /// });
  /// ```
  ///
  /// Here's an example of submitting an entire form with [FormData].
  ///
  /// ```dart
  /// var myForm = querySelector('form#myForm');
  /// var data = new FormData(myForm);
  /// HttpRequest.request('/submit', method: 'POST', sendData: data)
  ///   .then((HttpRequest resp) {
  ///     // Do something with the response.
  /// });
  /// ```
  ///
  /// Requests for `file://` URIs are only supported by Chrome extensions
  /// with appropriate permissions in their manifest. Requests to file:// URIs
  /// will also never fail- the Future will always complete successfully, even
  /// when the file cannot be found.
  ///
  /// See also: [authorization headers](http://en.wikipedia.org/wiki/Basic_access_authentication).
  Future<Object> request(
    String url, {
    String method = 'GET',
    bool withCredentials = false,
    String? mimeType,
    Map<String, String>? requestHeaders,
    Uint8List? sendData,
  }) async {
    final Map<String, String> headers = <String, String>{
      if (mimeType != null) 'content-type': mimeType,
      ...?requestHeaders,
    };
    return web.window
        .fetch(
            url.toJS,
            web.RequestInit(
              method: method,
              body: sendData?.toJS,
              credentials: withCredentials ? 'include' : 'same-origin',
              headers: headers.jsify()! as web.HeadersInit,
            ))
        .toDart;
  }
}

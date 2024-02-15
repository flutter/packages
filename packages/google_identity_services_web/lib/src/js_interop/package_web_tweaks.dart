// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

@JS()
library;

import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// This extension gives web.window a nullable getter to the `trustedTypes`
/// property, which needs to be used to check for feature support.
extension NullableTrustedTypesGetter on web.Window {
  @JS('trustedTypes')
  external TrustedTypePolicyFactory? get nullableTrustedTypes;

  external TrustedTypePolicyFactory get trustedTypes;
}

/// This extension allows setting a TrustedScriptURL as the src of a script element,
/// which currently only accepts a string.
extension TrustedTypeSrcAttribute on web.HTMLScriptElement {
  @JS('src')
  external set srcTT(TrustedScriptURL value);
}

// TODO(kevmoo): drop all of this once https://github.com/dart-lang/web/pull/173
// lands and pkg:web rolls to 0.5.1

typedef CreateHTMLCallback = JSFunction;
typedef CreateScriptCallback = JSFunction;
typedef CreateScriptURLCallback = JSFunction;
extension type TrustedHTML._(JSObject _) implements JSObject {
  external static TrustedHTML fromLiteral(JSObject templateStringsArray);
  external String toJSON();
}
extension type TrustedScript._(JSObject _) implements JSObject {
  external static TrustedScript fromLiteral(JSObject templateStringsArray);
  external String toJSON();
}
extension type TrustedScriptURL._(JSObject _) implements JSObject {
  external static TrustedScriptURL fromLiteral(JSObject templateStringsArray);
  external String toJSON();
}
extension type TrustedTypePolicyFactory._(JSObject _) implements JSObject {
  external TrustedTypePolicy createPolicy(
    String policyName, [
    TrustedTypePolicyOptions policyOptions,
  ]);
  external bool isHTML(JSAny? value);
  external bool isScript(JSAny? value);
  external bool isScriptURL(JSAny? value);
  external String? getAttributeType(
    String tagName,
    String attribute, [
    String elementNs,
    String attrNs,
  ]);
  external String? getPropertyType(
    String tagName,
    String property, [
    String elementNs,
  ]);
  external TrustedHTML get emptyHTML;
  external TrustedScript get emptyScript;
  external TrustedTypePolicy? get defaultPolicy;
}
extension type TrustedTypePolicy._(JSObject _) implements JSObject {
  external TrustedHTML createHTML(
    String input,
    JSAny? arguments,
  );
  external TrustedScript createScript(
    String input,
    JSAny? arguments,
  );
  external TrustedScriptURL createScriptURL(
    String input,
    JSAny? arguments,
  );
  @JS('createScriptURL')
  external TrustedScriptURL createScriptURLNoArgs(
    String input,
  );
  external String get name;
}
extension type TrustedTypePolicyOptions._(JSObject _) implements JSObject {
  external factory TrustedTypePolicyOptions({
    CreateHTMLCallback createHTML,
    CreateScriptCallback createScript,
    CreateScriptURLCallback createScriptURL,
  });

  external set createHTML(CreateHTMLCallback value);
  external CreateHTMLCallback get createHTML;
  external set createScript(CreateScriptCallback value);
  external CreateScriptCallback get createScript;
  external set createScriptURL(CreateScriptURLCallback value);
  external CreateScriptURLCallback get createScriptURL;
}

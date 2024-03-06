// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v17.1.1), do not edit directly.
// See also: https://pub.dev/packages/pigeon
// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import, unnecessary_parenthesis, prefer_null_aware_operators, omit_local_variable_types, unused_shown_name, unnecessary_import, no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:typed_data' show Float64List, Int32List, Int64List, Uint8List;

import 'package:flutter/foundation.dart' show ReadBuffer, WriteBuffer;
import 'package:flutter/services.dart';

PlatformException _createConnectionError(String channelName) {
  return PlatformException(
    code: 'channel-error',
    message: 'Unable to establish connection on channel: "$channelName".',
  );
}

/// Pigeon version of Java BillingClient.ProductType.
enum PlatformProductType {
  inapp,
  subs,
}

/// Pigeon version of billing_client_wrapper.dart's BillingChoiceMode.
enum PlatformBillingChoiceMode {
  /// Billing through google play.
  ///
  /// Default state.
  playBillingOnly,

  /// Billing through app provided flow.
  alternativeBillingOnly,
}

/// Pigeon version of Java Product.
class PlatformProduct {
  PlatformProduct({
    required this.productId,
    required this.productType,
  });

  String productId;

  PlatformProductType productType;

  Object encode() {
    return <Object?>[
      productId,
      productType.index,
    ];
  }

  static PlatformProduct decode(Object result) {
    result as List<Object?>;
    return PlatformProduct(
      productId: result[0]! as String,
      productType: PlatformProductType.values[result[1]! as int],
    );
  }
}

/// Pigeon version of Java BillingResult.
class PlatformBillingResult {
  PlatformBillingResult({
    required this.responseCode,
    required this.debugMessage,
  });

  int responseCode;

  String debugMessage;

  Object encode() {
    return <Object?>[
      responseCode,
      debugMessage,
    ];
  }

  static PlatformBillingResult decode(Object result) {
    result as List<Object?>;
    return PlatformBillingResult(
      responseCode: result[0]! as int,
      debugMessage: result[1]! as String,
    );
  }
}

/// Pigeon version of ProductDetailsResponseWrapper, which contains the
/// components of the Java ProductDetailsResponseListener callback.
class PlatformProductDetailsResponse {
  PlatformProductDetailsResponse({
    required this.billingResult,
    required this.productDetailsJsonList,
  });

  PlatformBillingResult billingResult;

  /// A JSON-compatible list of details, where each entry in the list is a
  /// Map<String, Object?> JSON encoding of the product details.
  List<Object?> productDetailsJsonList;

  Object encode() {
    return <Object?>[
      billingResult.encode(),
      productDetailsJsonList,
    ];
  }

  static PlatformProductDetailsResponse decode(Object result) {
    result as List<Object?>;
    return PlatformProductDetailsResponse(
      billingResult: PlatformBillingResult.decode(result[0]! as List<Object?>),
      productDetailsJsonList: (result[1] as List<Object?>?)!.cast<Object?>(),
    );
  }
}

/// Pigeon version of AlternativeBillingOnlyReportingDetailsWrapper, which
/// contains the components of the Java
/// AlternativeBillingOnlyReportingDetailsListener callback.
class PlatformAlternativeBillingOnlyReportingDetailsResponse {
  PlatformAlternativeBillingOnlyReportingDetailsResponse({
    required this.billingResult,
    required this.externalTransactionToken,
  });

  PlatformBillingResult billingResult;

  String externalTransactionToken;

  Object encode() {
    return <Object?>[
      billingResult.encode(),
      externalTransactionToken,
    ];
  }

  static PlatformAlternativeBillingOnlyReportingDetailsResponse decode(
      Object result) {
    result as List<Object?>;
    return PlatformAlternativeBillingOnlyReportingDetailsResponse(
      billingResult: PlatformBillingResult.decode(result[0]! as List<Object?>),
      externalTransactionToken: result[1]! as String,
    );
  }
}

/// Pigeon version of Java BillingFlowParams.
class PlatformBillingFlowParams {
  PlatformBillingFlowParams({
    required this.product,
    required this.prorationMode,
    this.offerToken,
    this.accountId,
    this.obfuscatedProfileId,
    this.oldProduct,
    this.purchaseToken,
  });

  String product;

  int prorationMode;

  String? offerToken;

  String? accountId;

  String? obfuscatedProfileId;

  String? oldProduct;

  String? purchaseToken;

  Object encode() {
    return <Object?>[
      product,
      prorationMode,
      offerToken,
      accountId,
      obfuscatedProfileId,
      oldProduct,
      purchaseToken,
    ];
  }

  static PlatformBillingFlowParams decode(Object result) {
    result as List<Object?>;
    return PlatformBillingFlowParams(
      product: result[0]! as String,
      prorationMode: result[1]! as int,
      offerToken: result[2] as String?,
      accountId: result[3] as String?,
      obfuscatedProfileId: result[4] as String?,
      oldProduct: result[5] as String?,
      purchaseToken: result[6] as String?,
    );
  }
}

class _InAppPurchaseApiCodec extends StandardMessageCodec {
  const _InAppPurchaseApiCodec();
  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is PlatformAlternativeBillingOnlyReportingDetailsResponse) {
      buffer.putUint8(128);
      writeValue(buffer, value.encode());
    } else if (value is PlatformBillingFlowParams) {
      buffer.putUint8(129);
      writeValue(buffer, value.encode());
    } else if (value is PlatformBillingResult) {
      buffer.putUint8(130);
      writeValue(buffer, value.encode());
    } else if (value is PlatformProduct) {
      buffer.putUint8(131);
      writeValue(buffer, value.encode());
    } else if (value is PlatformProductDetailsResponse) {
      buffer.putUint8(132);
      writeValue(buffer, value.encode());
    } else {
      super.writeValue(buffer, value);
    }
  }

  @override
  Object? readValueOfType(int type, ReadBuffer buffer) {
    switch (type) {
      case 128:
        return PlatformAlternativeBillingOnlyReportingDetailsResponse.decode(
            readValue(buffer)!);
      case 129:
        return PlatformBillingFlowParams.decode(readValue(buffer)!);
      case 130:
        return PlatformBillingResult.decode(readValue(buffer)!);
      case 131:
        return PlatformProduct.decode(readValue(buffer)!);
      case 132:
        return PlatformProductDetailsResponse.decode(readValue(buffer)!);
      default:
        return super.readValueOfType(type, buffer);
    }
  }
}

class InAppPurchaseApi {
  /// Constructor for [InAppPurchaseApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  InAppPurchaseApi({BinaryMessenger? binaryMessenger})
      : __pigeon_binaryMessenger = binaryMessenger;
  final BinaryMessenger? __pigeon_binaryMessenger;

  static const MessageCodec<Object?> pigeonChannelCodec =
      _InAppPurchaseApiCodec();

  /// Wraps BillingClient#isReady.
  Future<bool> isReady() async {
    const String __pigeon_channelName =
        'dev.flutter.pigeon.in_app_purchase_android.InAppPurchaseApi.isReady';
    final BasicMessageChannel<Object?> __pigeon_channel =
        BasicMessageChannel<Object?>(
      __pigeon_channelName,
      pigeonChannelCodec,
      binaryMessenger: __pigeon_binaryMessenger,
    );
    final List<Object?>? __pigeon_replyList =
        await __pigeon_channel.send(null) as List<Object?>?;
    if (__pigeon_replyList == null) {
      throw _createConnectionError(__pigeon_channelName);
    } else if (__pigeon_replyList.length > 1) {
      throw PlatformException(
        code: __pigeon_replyList[0]! as String,
        message: __pigeon_replyList[1] as String?,
        details: __pigeon_replyList[2],
      );
    } else if (__pigeon_replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (__pigeon_replyList[0] as bool?)!;
    }
  }

  /// Wraps BillingClient#startConnection(BillingClientStateListener).
  Future<PlatformBillingResult> startConnection(
      int callbackHandle, PlatformBillingChoiceMode billingMode) async {
    const String __pigeon_channelName =
        'dev.flutter.pigeon.in_app_purchase_android.InAppPurchaseApi.startConnection';
    final BasicMessageChannel<Object?> __pigeon_channel =
        BasicMessageChannel<Object?>(
      __pigeon_channelName,
      pigeonChannelCodec,
      binaryMessenger: __pigeon_binaryMessenger,
    );
    final List<Object?>? __pigeon_replyList = await __pigeon_channel
        .send(<Object?>[callbackHandle, billingMode.index]) as List<Object?>?;
    if (__pigeon_replyList == null) {
      throw _createConnectionError(__pigeon_channelName);
    } else if (__pigeon_replyList.length > 1) {
      throw PlatformException(
        code: __pigeon_replyList[0]! as String,
        message: __pigeon_replyList[1] as String?,
        details: __pigeon_replyList[2],
      );
    } else if (__pigeon_replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (__pigeon_replyList[0] as PlatformBillingResult?)!;
    }
  }

  /// Wraps BillingClient#endConnection(BillingClientStateListener).
  Future<void> endConnection() async {
    const String __pigeon_channelName =
        'dev.flutter.pigeon.in_app_purchase_android.InAppPurchaseApi.endConnection';
    final BasicMessageChannel<Object?> __pigeon_channel =
        BasicMessageChannel<Object?>(
      __pigeon_channelName,
      pigeonChannelCodec,
      binaryMessenger: __pigeon_binaryMessenger,
    );
    final List<Object?>? __pigeon_replyList =
        await __pigeon_channel.send(null) as List<Object?>?;
    if (__pigeon_replyList == null) {
      throw _createConnectionError(__pigeon_channelName);
    } else if (__pigeon_replyList.length > 1) {
      throw PlatformException(
        code: __pigeon_replyList[0]! as String,
        message: __pigeon_replyList[1] as String?,
        details: __pigeon_replyList[2],
      );
    } else {
      return;
    }
  }

  /// Wraps BillingClient#launchBillingFlow(Activity, BillingFlowParams).
  Future<PlatformBillingResult> launchBillingFlow(
      PlatformBillingFlowParams params) async {
    const String __pigeon_channelName =
        'dev.flutter.pigeon.in_app_purchase_android.InAppPurchaseApi.launchBillingFlow';
    final BasicMessageChannel<Object?> __pigeon_channel =
        BasicMessageChannel<Object?>(
      __pigeon_channelName,
      pigeonChannelCodec,
      binaryMessenger: __pigeon_binaryMessenger,
    );
    final List<Object?>? __pigeon_replyList =
        await __pigeon_channel.send(<Object?>[params]) as List<Object?>?;
    if (__pigeon_replyList == null) {
      throw _createConnectionError(__pigeon_channelName);
    } else if (__pigeon_replyList.length > 1) {
      throw PlatformException(
        code: __pigeon_replyList[0]! as String,
        message: __pigeon_replyList[1] as String?,
        details: __pigeon_replyList[2],
      );
    } else if (__pigeon_replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (__pigeon_replyList[0] as PlatformBillingResult?)!;
    }
  }

  /// Wraps BillingClient#acknowledgePurchase(AcknowledgePurchaseParams, AcknowledgePurchaseResponseListener).
  Future<PlatformBillingResult> acknowledgePurchase(
      String purchaseToken) async {
    const String __pigeon_channelName =
        'dev.flutter.pigeon.in_app_purchase_android.InAppPurchaseApi.acknowledgePurchase';
    final BasicMessageChannel<Object?> __pigeon_channel =
        BasicMessageChannel<Object?>(
      __pigeon_channelName,
      pigeonChannelCodec,
      binaryMessenger: __pigeon_binaryMessenger,
    );
    final List<Object?>? __pigeon_replyList =
        await __pigeon_channel.send(<Object?>[purchaseToken]) as List<Object?>?;
    if (__pigeon_replyList == null) {
      throw _createConnectionError(__pigeon_channelName);
    } else if (__pigeon_replyList.length > 1) {
      throw PlatformException(
        code: __pigeon_replyList[0]! as String,
        message: __pigeon_replyList[1] as String?,
        details: __pigeon_replyList[2],
      );
    } else if (__pigeon_replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (__pigeon_replyList[0] as PlatformBillingResult?)!;
    }
  }

  /// Wraps BillingClient#consumeAsync(ConsumeParams, ConsumeResponseListener).
  Future<PlatformBillingResult> consumeAsync(String purchaseToken) async {
    const String __pigeon_channelName =
        'dev.flutter.pigeon.in_app_purchase_android.InAppPurchaseApi.consumeAsync';
    final BasicMessageChannel<Object?> __pigeon_channel =
        BasicMessageChannel<Object?>(
      __pigeon_channelName,
      pigeonChannelCodec,
      binaryMessenger: __pigeon_binaryMessenger,
    );
    final List<Object?>? __pigeon_replyList =
        await __pigeon_channel.send(<Object?>[purchaseToken]) as List<Object?>?;
    if (__pigeon_replyList == null) {
      throw _createConnectionError(__pigeon_channelName);
    } else if (__pigeon_replyList.length > 1) {
      throw PlatformException(
        code: __pigeon_replyList[0]! as String,
        message: __pigeon_replyList[1] as String?,
        details: __pigeon_replyList[2],
      );
    } else if (__pigeon_replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (__pigeon_replyList[0] as PlatformBillingResult?)!;
    }
  }

  /// Wraps BillingClient#queryProductDetailsAsync(QueryProductDetailsParams, ProductDetailsResponseListener).
  Future<PlatformProductDetailsResponse> queryProductDetailsAsync(
      List<PlatformProduct?> products) async {
    const String __pigeon_channelName =
        'dev.flutter.pigeon.in_app_purchase_android.InAppPurchaseApi.queryProductDetailsAsync';
    final BasicMessageChannel<Object?> __pigeon_channel =
        BasicMessageChannel<Object?>(
      __pigeon_channelName,
      pigeonChannelCodec,
      binaryMessenger: __pigeon_binaryMessenger,
    );
    final List<Object?>? __pigeon_replyList =
        await __pigeon_channel.send(<Object?>[products]) as List<Object?>?;
    if (__pigeon_replyList == null) {
      throw _createConnectionError(__pigeon_channelName);
    } else if (__pigeon_replyList.length > 1) {
      throw PlatformException(
        code: __pigeon_replyList[0]! as String,
        message: __pigeon_replyList[1] as String?,
        details: __pigeon_replyList[2],
      );
    } else if (__pigeon_replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (__pigeon_replyList[0] as PlatformProductDetailsResponse?)!;
    }
  }

  /// Wraps BillingClient#isFeatureSupported(String).
  Future<bool> isFeatureSupported(String feature) async {
    const String __pigeon_channelName =
        'dev.flutter.pigeon.in_app_purchase_android.InAppPurchaseApi.isFeatureSupported';
    final BasicMessageChannel<Object?> __pigeon_channel =
        BasicMessageChannel<Object?>(
      __pigeon_channelName,
      pigeonChannelCodec,
      binaryMessenger: __pigeon_binaryMessenger,
    );
    final List<Object?>? __pigeon_replyList =
        await __pigeon_channel.send(<Object?>[feature]) as List<Object?>?;
    if (__pigeon_replyList == null) {
      throw _createConnectionError(__pigeon_channelName);
    } else if (__pigeon_replyList.length > 1) {
      throw PlatformException(
        code: __pigeon_replyList[0]! as String,
        message: __pigeon_replyList[1] as String?,
        details: __pigeon_replyList[2],
      );
    } else if (__pigeon_replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (__pigeon_replyList[0] as bool?)!;
    }
  }

  /// Wraps BillingClient#isAlternativeBillingOnlyAvailableAsync().
  Future<PlatformBillingResult> isAlternativeBillingOnlyAvailableAsync() async {
    const String __pigeon_channelName =
        'dev.flutter.pigeon.in_app_purchase_android.InAppPurchaseApi.isAlternativeBillingOnlyAvailableAsync';
    final BasicMessageChannel<Object?> __pigeon_channel =
        BasicMessageChannel<Object?>(
      __pigeon_channelName,
      pigeonChannelCodec,
      binaryMessenger: __pigeon_binaryMessenger,
    );
    final List<Object?>? __pigeon_replyList =
        await __pigeon_channel.send(null) as List<Object?>?;
    if (__pigeon_replyList == null) {
      throw _createConnectionError(__pigeon_channelName);
    } else if (__pigeon_replyList.length > 1) {
      throw PlatformException(
        code: __pigeon_replyList[0]! as String,
        message: __pigeon_replyList[1] as String?,
        details: __pigeon_replyList[2],
      );
    } else if (__pigeon_replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (__pigeon_replyList[0] as PlatformBillingResult?)!;
    }
  }

  /// Wraps BillingClient#showAlternativeBillingOnlyInformationDialog().
  Future<PlatformBillingResult>
      showAlternativeBillingOnlyInformationDialog() async {
    const String __pigeon_channelName =
        'dev.flutter.pigeon.in_app_purchase_android.InAppPurchaseApi.showAlternativeBillingOnlyInformationDialog';
    final BasicMessageChannel<Object?> __pigeon_channel =
        BasicMessageChannel<Object?>(
      __pigeon_channelName,
      pigeonChannelCodec,
      binaryMessenger: __pigeon_binaryMessenger,
    );
    final List<Object?>? __pigeon_replyList =
        await __pigeon_channel.send(null) as List<Object?>?;
    if (__pigeon_replyList == null) {
      throw _createConnectionError(__pigeon_channelName);
    } else if (__pigeon_replyList.length > 1) {
      throw PlatformException(
        code: __pigeon_replyList[0]! as String,
        message: __pigeon_replyList[1] as String?,
        details: __pigeon_replyList[2],
      );
    } else if (__pigeon_replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (__pigeon_replyList[0] as PlatformBillingResult?)!;
    }
  }

  /// Wraps BillingClient#createAlternativeBillingOnlyReportingDetailsAsync(AlternativeBillingOnlyReportingDetailsListener).
  Future<PlatformAlternativeBillingOnlyReportingDetailsResponse>
      createAlternativeBillingOnlyReportingDetailsAsync() async {
    const String __pigeon_channelName =
        'dev.flutter.pigeon.in_app_purchase_android.InAppPurchaseApi.createAlternativeBillingOnlyReportingDetailsAsync';
    final BasicMessageChannel<Object?> __pigeon_channel =
        BasicMessageChannel<Object?>(
      __pigeon_channelName,
      pigeonChannelCodec,
      binaryMessenger: __pigeon_binaryMessenger,
    );
    final List<Object?>? __pigeon_replyList =
        await __pigeon_channel.send(null) as List<Object?>?;
    if (__pigeon_replyList == null) {
      throw _createConnectionError(__pigeon_channelName);
    } else if (__pigeon_replyList.length > 1) {
      throw PlatformException(
        code: __pigeon_replyList[0]! as String,
        message: __pigeon_replyList[1] as String?,
        details: __pigeon_replyList[2],
      );
    } else if (__pigeon_replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (__pigeon_replyList[0]
          as PlatformAlternativeBillingOnlyReportingDetailsResponse?)!;
    }
  }
}

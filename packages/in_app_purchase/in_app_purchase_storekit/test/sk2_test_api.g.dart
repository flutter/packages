// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v22.6.0), do not edit directly.
// See also: https://pub.dev/packages/pigeon
// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import, unnecessary_parenthesis, unnecessary_import, no_leading_underscores_for_local_identifiers
// ignore_for_file: avoid_relative_lib_imports
import 'dart:async';
import 'dart:typed_data' show Float64List, Int32List, Int64List, Uint8List;
import 'package:flutter/foundation.dart' show ReadBuffer, WriteBuffer;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:in_app_purchase_storekit/src/sk2_pigeon.g.dart';

class _PigeonCodec extends StandardMessageCodec {
  const _PigeonCodec();
  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is int) {
      buffer.putUint8(4);
      buffer.putInt64(value);
    } else if (value is SK2ProductTypeMessage) {
      buffer.putUint8(129);
      writeValue(buffer, value.index);
    } else if (value is SK2SubscriptionOfferTypeMessage) {
      buffer.putUint8(130);
      writeValue(buffer, value.index);
    } else if (value is SK2SubscriptionOfferPaymentModeMessage) {
      buffer.putUint8(131);
      writeValue(buffer, value.index);
    } else if (value is SK2SubscriptionPeriodUnitMessage) {
      buffer.putUint8(132);
      writeValue(buffer, value.index);
    } else if (value is SK2ProductPurchaseResultMessage) {
      buffer.putUint8(133);
      writeValue(buffer, value.index);
    } else if (value is SK2SubscriptionOfferMessage) {
      buffer.putUint8(134);
      writeValue(buffer, value.encode());
    } else if (value is SK2SubscriptionPeriodMessage) {
      buffer.putUint8(135);
      writeValue(buffer, value.encode());
    } else if (value is SK2SubscriptionInfoMessage) {
      buffer.putUint8(136);
      writeValue(buffer, value.encode());
    } else if (value is SK2ProductMessage) {
      buffer.putUint8(137);
      writeValue(buffer, value.encode());
    } else if (value is SK2PriceLocaleMessage) {
      buffer.putUint8(138);
      writeValue(buffer, value.encode());
    } else if (value is SK2ProductPurchaseOptionsMessage) {
      buffer.putUint8(139);
      writeValue(buffer, value.encode());
    } else if (value is SK2TransactionMessage) {
      buffer.putUint8(140);
      writeValue(buffer, value.encode());
    } else if (value is SK2ErrorMessage) {
      buffer.putUint8(141);
      writeValue(buffer, value.encode());
    } else {
      super.writeValue(buffer, value);
    }
  }

  @override
  Object? readValueOfType(int type, ReadBuffer buffer) {
    switch (type) {
      case 129:
        final int? value = readValue(buffer) as int?;
        return value == null ? null : SK2ProductTypeMessage.values[value];
      case 130:
        final int? value = readValue(buffer) as int?;
        return value == null
            ? null
            : SK2SubscriptionOfferTypeMessage.values[value];
      case 131:
        final int? value = readValue(buffer) as int?;
        return value == null
            ? null
            : SK2SubscriptionOfferPaymentModeMessage.values[value];
      case 132:
        final int? value = readValue(buffer) as int?;
        return value == null
            ? null
            : SK2SubscriptionPeriodUnitMessage.values[value];
      case 133:
        final int? value = readValue(buffer) as int?;
        return value == null
            ? null
            : SK2ProductPurchaseResultMessage.values[value];
      case 134:
        return SK2SubscriptionOfferMessage.decode(readValue(buffer)!);
      case 135:
        return SK2SubscriptionPeriodMessage.decode(readValue(buffer)!);
      case 136:
        return SK2SubscriptionInfoMessage.decode(readValue(buffer)!);
      case 137:
        return SK2ProductMessage.decode(readValue(buffer)!);
      case 138:
        return SK2PriceLocaleMessage.decode(readValue(buffer)!);
      case 139:
        return SK2ProductPurchaseOptionsMessage.decode(readValue(buffer)!);
      case 140:
        return SK2TransactionMessage.decode(readValue(buffer)!);
      case 141:
        return SK2ErrorMessage.decode(readValue(buffer)!);
      default:
        return super.readValueOfType(type, buffer);
    }
  }
}

abstract class TestInAppPurchase2Api {
  static TestDefaultBinaryMessengerBinding? get _testBinaryMessengerBinding =>
      TestDefaultBinaryMessengerBinding.instance;
  static const MessageCodec<Object?> pigeonChannelCodec = _PigeonCodec();

  bool canMakePayments();

  Future<List<SK2ProductMessage>> products(List<String> identifiers);

  Future<SK2ProductPurchaseResultMessage> purchase(String id,
      {SK2ProductPurchaseOptionsMessage? options});

  Future<List<SK2TransactionMessage>> transactions();

  Future<void> finish(int id);

  void startListeningToTransactions();

  void stopListeningToTransactions();

  Future<void> restorePurchases();

  bool supportsStoreKit2();

  static void setUp(
    TestInAppPurchase2Api? api, {
    BinaryMessenger? binaryMessenger,
    String messageChannelSuffix = '',
  }) {
    messageChannelSuffix =
        messageChannelSuffix.isNotEmpty ? '.$messageChannelSuffix' : '';
    {
      final BasicMessageChannel<
          Object?> pigeonVar_channel = BasicMessageChannel<
              Object?>(
          'dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchase2API.canMakePayments$messageChannelSuffix',
          pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        _testBinaryMessengerBinding!.defaultBinaryMessenger
            .setMockDecodedMessageHandler<Object?>(pigeonVar_channel, null);
      } else {
        _testBinaryMessengerBinding!.defaultBinaryMessenger
            .setMockDecodedMessageHandler<Object?>(pigeonVar_channel,
                (Object? message) async {
          try {
            final bool output = api.canMakePayments();
            return <Object?>[output];
          } on PlatformException catch (e) {
            return wrapResponse(error: e);
          } catch (e) {
            return wrapResponse(
                error: PlatformException(code: 'error', message: e.toString()));
          }
        });
      }
    }
    {
      final BasicMessageChannel<
          Object?> pigeonVar_channel = BasicMessageChannel<
              Object?>(
          'dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchase2API.products$messageChannelSuffix',
          pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        _testBinaryMessengerBinding!.defaultBinaryMessenger
            .setMockDecodedMessageHandler<Object?>(pigeonVar_channel, null);
      } else {
        _testBinaryMessengerBinding!.defaultBinaryMessenger
            .setMockDecodedMessageHandler<Object?>(pigeonVar_channel,
                (Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchase2API.products was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final List<String>? arg_identifiers =
              (args[0] as List<Object?>?)?.cast<String>();
          assert(arg_identifiers != null,
              'Argument for dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchase2API.products was null, expected non-null List<String>.');
          try {
            final List<SK2ProductMessage> output =
                await api.products(arg_identifiers!);
            return <Object?>[output];
          } on PlatformException catch (e) {
            return wrapResponse(error: e);
          } catch (e) {
            return wrapResponse(
                error: PlatformException(code: 'error', message: e.toString()));
          }
        });
      }
    }
    {
      final BasicMessageChannel<
          Object?> pigeonVar_channel = BasicMessageChannel<
              Object?>(
          'dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchase2API.purchase$messageChannelSuffix',
          pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        _testBinaryMessengerBinding!.defaultBinaryMessenger
            .setMockDecodedMessageHandler<Object?>(pigeonVar_channel, null);
      } else {
        _testBinaryMessengerBinding!.defaultBinaryMessenger
            .setMockDecodedMessageHandler<Object?>(pigeonVar_channel,
                (Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchase2API.purchase was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final String? arg_id = (args[0] as String?);
          assert(arg_id != null,
              'Argument for dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchase2API.purchase was null, expected non-null String.');
          final SK2ProductPurchaseOptionsMessage? arg_options =
              (args[1] as SK2ProductPurchaseOptionsMessage?);
          try {
            final SK2ProductPurchaseResultMessage output =
                await api.purchase(arg_id!, options: arg_options);
            return <Object?>[output];
          } on PlatformException catch (e) {
            return wrapResponse(error: e);
          } catch (e) {
            return wrapResponse(
                error: PlatformException(code: 'error', message: e.toString()));
          }
        });
      }
    }
    {
      final BasicMessageChannel<
          Object?> pigeonVar_channel = BasicMessageChannel<
              Object?>(
          'dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchase2API.transactions$messageChannelSuffix',
          pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        _testBinaryMessengerBinding!.defaultBinaryMessenger
            .setMockDecodedMessageHandler<Object?>(pigeonVar_channel, null);
      } else {
        _testBinaryMessengerBinding!.defaultBinaryMessenger
            .setMockDecodedMessageHandler<Object?>(pigeonVar_channel,
                (Object? message) async {
          try {
            final List<SK2TransactionMessage> output = await api.transactions();
            return <Object?>[output];
          } on PlatformException catch (e) {
            return wrapResponse(error: e);
          } catch (e) {
            return wrapResponse(
                error: PlatformException(code: 'error', message: e.toString()));
          }
        });
      }
    }
    {
      final BasicMessageChannel<
          Object?> pigeonVar_channel = BasicMessageChannel<
              Object?>(
          'dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchase2API.finish$messageChannelSuffix',
          pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        _testBinaryMessengerBinding!.defaultBinaryMessenger
            .setMockDecodedMessageHandler<Object?>(pigeonVar_channel, null);
      } else {
        _testBinaryMessengerBinding!.defaultBinaryMessenger
            .setMockDecodedMessageHandler<Object?>(pigeonVar_channel,
                (Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchase2API.finish was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final int? arg_id = (args[0] as int?);
          assert(arg_id != null,
              'Argument for dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchase2API.finish was null, expected non-null int.');
          try {
            await api.finish(arg_id!);
            return wrapResponse(empty: true);
          } on PlatformException catch (e) {
            return wrapResponse(error: e);
          } catch (e) {
            return wrapResponse(
                error: PlatformException(code: 'error', message: e.toString()));
          }
        });
      }
    }
    {
      final BasicMessageChannel<
          Object?> pigeonVar_channel = BasicMessageChannel<
              Object?>(
          'dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchase2API.startListeningToTransactions$messageChannelSuffix',
          pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        _testBinaryMessengerBinding!.defaultBinaryMessenger
            .setMockDecodedMessageHandler<Object?>(pigeonVar_channel, null);
      } else {
        _testBinaryMessengerBinding!.defaultBinaryMessenger
            .setMockDecodedMessageHandler<Object?>(pigeonVar_channel,
                (Object? message) async {
          try {
            api.startListeningToTransactions();
            return wrapResponse(empty: true);
          } on PlatformException catch (e) {
            return wrapResponse(error: e);
          } catch (e) {
            return wrapResponse(
                error: PlatformException(code: 'error', message: e.toString()));
          }
        });
      }
    }
    {
      final BasicMessageChannel<
          Object?> pigeonVar_channel = BasicMessageChannel<
              Object?>(
          'dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchase2API.stopListeningToTransactions$messageChannelSuffix',
          pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        _testBinaryMessengerBinding!.defaultBinaryMessenger
            .setMockDecodedMessageHandler<Object?>(pigeonVar_channel, null);
      } else {
        _testBinaryMessengerBinding!.defaultBinaryMessenger
            .setMockDecodedMessageHandler<Object?>(pigeonVar_channel,
                (Object? message) async {
          try {
            api.stopListeningToTransactions();
            return wrapResponse(empty: true);
          } on PlatformException catch (e) {
            return wrapResponse(error: e);
          } catch (e) {
            return wrapResponse(
                error: PlatformException(code: 'error', message: e.toString()));
          }
        });
      }
    }
    {
      final BasicMessageChannel<
          Object?> pigeonVar_channel = BasicMessageChannel<
              Object?>(
          'dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchase2API.restorePurchases$messageChannelSuffix',
          pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        _testBinaryMessengerBinding!.defaultBinaryMessenger
            .setMockDecodedMessageHandler<Object?>(pigeonVar_channel, null);
      } else {
        _testBinaryMessengerBinding!.defaultBinaryMessenger
            .setMockDecodedMessageHandler<Object?>(pigeonVar_channel,
                (Object? message) async {
          try {
            await api.restorePurchases();
            return wrapResponse(empty: true);
          } on PlatformException catch (e) {
            return wrapResponse(error: e);
          } catch (e) {
            return wrapResponse(
                error: PlatformException(code: 'error', message: e.toString()));
          }
        });
      }
    }
    {
      final BasicMessageChannel<
          Object?> pigeonVar_channel = BasicMessageChannel<
              Object?>(
          'dev.flutter.pigeon.in_app_purchase_storekit.InAppPurchase2API.supportsStoreKit2$messageChannelSuffix',
          pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        _testBinaryMessengerBinding!.defaultBinaryMessenger
            .setMockDecodedMessageHandler<Object?>(pigeonVar_channel, null);
      } else {
        _testBinaryMessengerBinding!.defaultBinaryMessenger
            .setMockDecodedMessageHandler<Object?>(pigeonVar_channel,
                (Object? message) async {
          try {
            final bool output = api.supportsStoreKit2();
            return <Object?>[output];
          } on PlatformException catch (e) {
            return wrapResponse(error: e);
          } catch (e) {
            return wrapResponse(
                error: PlatformException(code: 'error', message: e.toString()));
          }
        });
      }
    }
  }
}

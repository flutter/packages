// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

import 'consumable_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // When using the Android plugin directly it is mandatory to register
  // the plugin as default instance as part of initializing the app.
  InAppPurchaseAndroidPlatform.registerPlatform();

  runApp(_MyApp());
}

// To try without auto-consume, change `true` to `false` here.
const bool _kAutoConsume = true;

const String _kConsumableId = 'consumable';
const String _kUpgradeId = 'upgrade';
const String _kSilverSubscriptionId = 'subscription_silver1';
const String _kGoldSubscriptionId = 'subscription_gold1';
const List<String> _kProductIds = <String>[
  _kConsumableId,
  _kUpgradeId,
  _kSilverSubscriptionId,
  _kGoldSubscriptionId,
];

class _MyApp extends StatefulWidget {
  @override
  State<_MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<_MyApp> {
  final InAppPurchasePlatform _inAppPurchasePlatform =
      InAppPurchasePlatform.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  late StreamSubscription<GooglePlayUserChoiceDetails> _userChoiceDetailsStream;
  List<String> _notFoundIds = <String>[];
  List<ProductDetails> _products = <ProductDetails>[];
  List<PurchaseDetails> _purchases = <PurchaseDetails>[];
  List<String> _consumables = <String>[];
  String _countryCode = '';
  String _isAlternativeBillingOnlyAvailableResponseCode = '';
  String _showAlternativeBillingOnlyDialogResponseCode = '';
  String _alternativeBillingOnlyReportingDetailsToken = '';
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  String? _queryProductError;
  final List<String> _userChoiceDetailsList = <String>[];

  @override
  void initState() {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchasePlatform.purchaseStream;
    _subscription =
        purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (Object error) {
      // handle error here.
    });
    initStoreInfo();
    final InAppPurchaseAndroidPlatformAddition addition =
        InAppPurchasePlatformAddition.instance!
            as InAppPurchaseAndroidPlatformAddition;
    final Stream<GooglePlayUserChoiceDetails> userChoiceDetailsUpdated =
        addition.userChoiceDetailsStream;
    _userChoiceDetailsStream =
        userChoiceDetailsUpdated.listen((GooglePlayUserChoiceDetails details) {
      deliverUserChoiceDetails(details);
    }, onDone: () {
      _userChoiceDetailsStream.cancel();
    }, onError: (Object error) {
      // handle error here.
    });
    super.initState();
  }

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _inAppPurchasePlatform.isAvailable();
    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = <ProductDetails>[];
        _purchases = <PurchaseDetails>[];
        _notFoundIds = <String>[];
        _consumables = <String>[];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    final ProductDetailsResponse productDetailResponse =
        await _inAppPurchasePlatform.queryProductDetails(_kProductIds.toSet());
    if (productDetailResponse.error != null) {
      setState(() {
        _queryProductError = productDetailResponse.error!.message;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = <PurchaseDetails>[];
        _notFoundIds = productDetailResponse.notFoundIDs;
        _consumables = <String>[];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _queryProductError = null;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = <PurchaseDetails>[];
        _notFoundIds = productDetailResponse.notFoundIDs;
        _consumables = <String>[];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    await _inAppPurchasePlatform.restorePurchases();

    final List<String> consumables = await ConsumableStore.load();
    setState(() {
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      _notFoundIds = productDetailResponse.notFoundIDs;
      _consumables = consumables;
      _purchasePending = false;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    _userChoiceDetailsStream.cancel();
    _userChoiceDetailsList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> stack = <Widget>[];
    if (_queryProductError == null) {
      stack.add(
        ListView(
          children: <Widget>[
            _buildConnectionCheckTile(),
            _buildProductList(),
            _buildConsumableBox(),
            const _FeatureCard(),
            _buildFetchButtons(),
            _buildUserChoiceDetailsDisplay(),
          ],
        ),
      );
    } else {
      stack.add(Center(
        child: Text(_queryProductError!),
      ));
    }
    if (_purchasePending) {
      stack.add(
        const Stack(
          children: <Widget>[
            Opacity(
              opacity: 0.3,
              child: ModalBarrier(dismissible: false, color: Colors.grey),
            ),
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('IAP Example'),
        ),
        body: Stack(
          children: stack,
        ),
      ),
    );
  }

  Card _buildConnectionCheckTile() {
    if (_loading) {
      return const Card(child: ListTile(title: Text('Trying to connect...')));
    }
    final Widget storeHeader = ListTile(
      leading: Icon(_isAvailable ? Icons.check : Icons.block,
          color: _isAvailable
              ? Colors.green
              : ThemeData.light().colorScheme.error),
      title:
          Text('The store is ${_isAvailable ? 'available' : 'unavailable'}.'),
    );
    final List<Widget> children = <Widget>[storeHeader];

    if (!_isAvailable) {
      children.addAll(<Widget>[
        const Divider(),
        ListTile(
          title: Text('Not connected',
              style: TextStyle(color: ThemeData.light().colorScheme.error)),
          subtitle: const Text(
              'Unable to connect to the payments processor. Has this app been configured correctly? See the example README for instructions.'),
        ),
      ]);
    }
    return Card(child: Column(children: children));
  }

  Card _buildFetchButtons() {
    const ListTile header = ListTile(title: Text('AlternativeBilling Info'));
    final List<Widget> entries = <ListTile>[];
    entries.add(ListTile(
        title: Text('User Country Code',
            style: TextStyle(color: ThemeData.light().colorScheme.primary)),
        subtitle: Text(_countryCode)));
    entries.add(ListTile(
        title: Text('isAlternativeBillingOnlyAvailable response code',
            style: TextStyle(color: ThemeData.light().colorScheme.primary)),
        subtitle: Text(_isAlternativeBillingOnlyAvailableResponseCode)));
    entries.add(ListTile(
        title: Text('showAlternativeBillingOnlyDialog response code',
            style: TextStyle(color: ThemeData.light().colorScheme.primary)),
        subtitle: Text(_showAlternativeBillingOnlyDialogResponseCode)));
    entries.add(ListTile(
        title: Text('createAlternativeBillingOnlyReportingDetails contents',
            style: TextStyle(color: ThemeData.light().colorScheme.primary)),
        subtitle: Text(_alternativeBillingOnlyReportingDetailsToken)));

    final List<Widget> buttons = <ListTile>[];
    buttons.add(ListTile(
      title: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Colors.green[800],
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          unawaited(deliverCountryCode(_inAppPurchasePlatform.countryCode()));
        },
        child: const Text('Fetch Country Code'),
      ),
    ));
    buttons.add(ListTile(
      title: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Colors.green[800],
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          final InAppPurchaseAndroidPlatformAddition addition =
              InAppPurchasePlatformAddition.instance!
                  as InAppPurchaseAndroidPlatformAddition;
          unawaited(deliverIsAlternativeBillingOnlyAvailable(
              addition.isAlternativeBillingOnlyAvailable()));
        },
        child: const Text('isAlternativeBillingOnlyAvailable'),
      ),
    ));
    buttons.add(ListTile(
      title: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Colors.green[800],
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          final InAppPurchaseAndroidPlatformAddition addition =
              InAppPurchasePlatformAddition.instance!
                  as InAppPurchaseAndroidPlatformAddition;
          unawaited(deliverShowAlternativeBillingOnlyInformationDialogResult(
              addition.showAlternativeBillingOnlyInformationDialog()));
        },
        child: const Text('showAlternativeBillingOnlyInformationDialog'),
      ),
    ));
    buttons.add(ListTile(
      title: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Colors.green[800],
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          final InAppPurchaseAndroidPlatformAddition addition =
              InAppPurchasePlatformAddition.instance!
                  as InAppPurchaseAndroidPlatformAddition;
          unawaited(addition
              .setBillingChoice(BillingChoiceMode.alternativeBillingOnly));
        },
        child: const Text('setBillingChoice alternativeBillingOnly'),
      ),
    ));
    buttons.add(ListTile(
      title: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Colors.green[800],
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          final InAppPurchaseAndroidPlatformAddition addition =
              InAppPurchasePlatformAddition.instance!
                  as InAppPurchaseAndroidPlatformAddition;
          unawaited(deliverCreateAlternativeBillingOnlyReportingDetails(
              addition.createAlternativeBillingOnlyReportingDetails()));
        },
        child: const Text('createAlternativeBillingOnlyReportingDetails'),
      ),
    ));
    return Card(
      child: Column(
        children: <Widget>[
          header,
          const Divider(),
          ...entries,
          const Divider(),
          ...buttons,
        ],
      ),
    );
  }

  Card _buildUserChoiceDetailsDisplay() {
    const ListTile header = ListTile(title: Text('UserChoiceDetails'));
    final List<Widget> entries = <ListTile>[];
    for (final String item in _userChoiceDetailsList) {
      entries.add(ListTile(
          title: Text(item,
              style: TextStyle(color: ThemeData.light().colorScheme.primary)),
          subtitle: Text(_countryCode)));
    }
    return Card(
      child: Column(
        children: <Widget>[
          header,
          const Divider(),
          ...entries,
        ],
      ),
    );
  }

  Card _buildProductList() {
    if (_loading) {
      return const Card(
          child: ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Fetching products...')));
    }
    if (!_isAvailable) {
      return const Card();
    }
    const ListTile productHeader = ListTile(title: Text('Products for Sale'));
    final List<ListTile> productList = <ListTile>[];
    if (_notFoundIds.isNotEmpty) {
      productList.add(ListTile(
          title: Text('[${_notFoundIds.join(", ")}] not found',
              style: TextStyle(color: ThemeData.light().colorScheme.error)),
          subtitle: const Text(
              'This app needs special configuration to run. Please see example/README.md for instructions.')));
    }

    // This loading previous purchases code is just a demo. Please do not use this as it is.
    // In your app you should always verify the purchase data using the `verificationData` inside the [PurchaseDetails] object before trusting it.
    // We recommend that you use your own server to verify the purchase data.
    final Map<String, PurchaseDetails> purchases =
        Map<String, PurchaseDetails>.fromEntries(
            _purchases.map((PurchaseDetails purchase) {
      if (purchase.pendingCompletePurchase) {
        _inAppPurchasePlatform.completePurchase(purchase);
      }
      return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
    }));
    productList.addAll(_products.map(
      (ProductDetails productDetails) {
        final PurchaseDetails? previousPurchase = purchases[productDetails.id];
        return ListTile(
            title: Text(
              productDetails.title,
            ),
            subtitle: Text(
              productDetails.description,
            ),
            trailing: previousPurchase != null
                ? const SizedBox.shrink()
                : TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      // NOTE: If you are making a subscription purchase/upgrade/downgrade, we recommend you to
                      // verify the latest status of you your subscription by using server side receipt validation
                      // and update the UI accordingly. The subscription purchase status shown
                      // inside the app may not be accurate.
                      final GooglePlayPurchaseDetails? oldSubscription =
                          _getOldSubscription(
                              productDetails as GooglePlayProductDetails,
                              purchases);
                      final GooglePlayPurchaseParam purchaseParam =
                          GooglePlayPurchaseParam(
                              productDetails: productDetails,
                              changeSubscriptionParam: oldSubscription != null
                                  ? ChangeSubscriptionParam(
                                      oldPurchaseDetails: oldSubscription,
                                      prorationMode: ProrationMode
                                          .immediateWithTimeProration)
                                  : null);
                      if (productDetails.id == _kConsumableId) {
                        _inAppPurchasePlatform.buyConsumable(
                            purchaseParam: purchaseParam,
                            // ignore: avoid_redundant_argument_values
                            autoConsume: _kAutoConsume);
                      } else {
                        _inAppPurchasePlatform.buyNonConsumable(
                            purchaseParam: purchaseParam);
                      }
                    },
                    child: Text(productDetails.price),
                  ));
      },
    ));

    return Card(
        child: Column(
            children: <Widget>[productHeader, const Divider()] + productList));
  }

  Card _buildConsumableBox() {
    if (_loading) {
      return const Card(
          child: ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Fetching consumables...')));
    }
    if (!_isAvailable || _notFoundIds.contains(_kConsumableId)) {
      return const Card();
    }
    const ListTile consumableHeader =
        ListTile(title: Text('Purchased consumables'));
    final List<Widget> tokens = _consumables.map((String id) {
      return GridTile(
        child: IconButton(
          icon: const Icon(
            Icons.stars,
            size: 42.0,
            color: Colors.orange,
          ),
          splashColor: Colors.yellowAccent,
          onPressed: () => consume(id),
        ),
      );
    }).toList();
    return Card(
        child: Column(children: <Widget>[
      consumableHeader,
      const Divider(),
      GridView.count(
        crossAxisCount: 5,
        shrinkWrap: true,
        padding: const EdgeInsets.all(16.0),
        children: tokens,
      )
    ]));
  }

  Future<void> consume(String id) async {
    await ConsumableStore.consume(id);
    final List<String> consumables = await ConsumableStore.load();
    setState(() {
      _consumables = consumables;
    });
  }

  void showPendingUI() {
    setState(() {
      _purchasePending = true;
    });
  }

  Future<void> deliverCountryCode(Future<String> countryCodeFuture) async {
    final String countryCode = await countryCodeFuture;
    setState(() {
      _countryCode = countryCode;
    });
  }

  Future<void> deliverIsAlternativeBillingOnlyAvailable(
      Future<BillingResultWrapper> billingOnly) async {
    final BillingResultWrapper wrapper = await billingOnly;
    setState(() {
      _isAlternativeBillingOnlyAvailableResponseCode =
          wrapper.responseCode.name;
    });
  }

  Future<void> deliverShowAlternativeBillingOnlyInformationDialogResult(
      Future<BillingResultWrapper> billingResult) async {
    final BillingResultWrapper wrapper = await billingResult;
    setState(() {
      _showAlternativeBillingOnlyDialogResponseCode = wrapper.responseCode.name;
    });
  }

  Future<void> deliverCreateAlternativeBillingOnlyReportingDetails(
      Future<AlternativeBillingOnlyReportingDetailsWrapper>
          futureWrapper) async {
    final AlternativeBillingOnlyReportingDetailsWrapper wrapper =
        await futureWrapper;
    setState(() {
      if (wrapper.responseCode == BillingResponse.ok) {
        _alternativeBillingOnlyReportingDetailsToken =
            wrapper.externalTransactionToken;
      } else {
        _alternativeBillingOnlyReportingDetailsToken =
            wrapper.responseCode.name;
      }
    });
  }

  Future<void> deliverProduct(PurchaseDetails purchaseDetails) async {
    // IMPORTANT!! Always verify purchase details before delivering the product.
    if (purchaseDetails.productID == _kConsumableId) {
      await ConsumableStore.save(purchaseDetails.purchaseID!);
      final List<String> consumables = await ConsumableStore.load();
      setState(() {
        _purchasePending = false;
        _consumables = consumables;
      });
    } else {
      setState(() {
        _purchases.add(purchaseDetails);
        _purchasePending = false;
      });
    }
  }

  void handleError(IAPError error) {
    setState(() {
      _purchasePending = false;
    });
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed.
  }

  Future<void> deliverUserChoiceDetails(
      GooglePlayUserChoiceDetails details) async {
    final String detailDescription =
        '${details.externalTransactionToken}, ${details.originalExternalTransactionId}, ${details.products.length}';
    setState(() {
      _userChoiceDetailsList.add(detailDescription);
    });
  }

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        showPendingUI();
      } else {
        final InAppPurchaseAndroidPlatformAddition addition =
            InAppPurchasePlatformAddition.instance!
                as InAppPurchaseAndroidPlatformAddition;
        if (purchaseDetails.status == PurchaseStatus.error) {
          handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          final bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            unawaited(deliverProduct(purchaseDetails));
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }

        if (!_kAutoConsume && purchaseDetails.productID == _kConsumableId) {
          await addition.consumePurchase(purchaseDetails);
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchasePlatform.completePurchase(purchaseDetails);
        }
      }
    }
  }

  GooglePlayPurchaseDetails? _getOldSubscription(
      GooglePlayProductDetails productDetails,
      Map<String, PurchaseDetails> purchases) {
    // This is just to demonstrate a subscription upgrade or downgrade.
    // This method assumes that you have only 2 subscriptions under a group, 'subscription_silver' & 'subscription_gold'.
    // The 'subscription_silver' subscription can be upgraded to 'subscription_gold' and
    // the 'subscription_gold' subscription can be downgraded to 'subscription_silver'.
    // Please remember to replace the logic of finding the old subscription Id as per your app.
    // The old subscription is only required on Android since Apple handles this internally
    // by using the subscription group feature in iTunesConnect.
    GooglePlayPurchaseDetails? oldSubscription;
    if (productDetails.id == _kSilverSubscriptionId &&
        purchases[_kGoldSubscriptionId] != null) {
      oldSubscription =
          purchases[_kGoldSubscriptionId]! as GooglePlayPurchaseDetails;
    } else if (productDetails.id == _kGoldSubscriptionId &&
        purchases[_kSilverSubscriptionId] != null) {
      oldSubscription =
          purchases[_kSilverSubscriptionId]! as GooglePlayPurchaseDetails;
    }
    return oldSubscription;
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard();

  InAppPurchaseAndroidPlatformAddition get addition =>
      InAppPurchasePlatformAddition.instance!
          as InAppPurchaseAndroidPlatformAddition;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
          const ListTile(title: Text('Available features')),
          const Divider(),
          for (final BillingClientFeature feature
              in BillingClientFeature.values)
            _buildFeatureWidget(feature),
        ]));
  }

  Widget _buildFeatureWidget(BillingClientFeature feature) {
    return FutureBuilder<bool>(
      future: addition.isFeatureSupported(feature),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        Color color = Colors.grey;
        final bool? data = snapshot.data;
        if (data != null) {
          color = data ? Colors.green : Colors.red;
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0),
          child: Text(
            _featureToString(feature),
            style: TextStyle(color: color),
          ),
        );
      },
    );
  }

  String _featureToString(BillingClientFeature feature) {
    switch (feature) {
      case BillingClientFeature.inAppItemsOnVR:
        return 'inAppItemsOnVR';
      case BillingClientFeature.priceChangeConfirmation:
        return 'priceChangeConfirmation';
      case BillingClientFeature.productDetails:
        return 'productDetails';
      case BillingClientFeature.subscriptions:
        return 'subscriptions';
      case BillingClientFeature.subscriptionsOnVR:
        return 'subscriptionsOnVR';
      case BillingClientFeature.subscriptionsUpdate:
        return 'subscriptionsUpdate';
    }
  }
}

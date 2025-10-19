// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs, unreachable_from_main

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'stateful_shell_route_initial_location_example.dart';

class OrdersRouteData extends GoRouteData with $OrdersRouteData {
  const OrdersRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const OrdersPageView(label: 'Orders page');
  }
}

class OrdersPageView extends StatelessWidget {
  const OrdersPageView({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(label));
  }
}

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of 'authentication_bloc.dart';

/// authentication event.
abstract class AuthenticationEvent extends Equatable {
  /// create authentication event
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

/// change authentication status
class AuthenticationStatusChanged extends AuthenticationEvent {
  /// create event for change authentication
  const AuthenticationStatusChanged(this.status, {this.name});

  /// authentication status
  final AuthenticationStatusType status;

  /// user name
  final String? name;

  @override
  List<Object> get props => [status, name!];
}

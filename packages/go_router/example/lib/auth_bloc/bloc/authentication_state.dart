// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of 'authentication_bloc.dart';

/// auth state.
abstract class AuthenticationState extends Equatable {
  /// create auth state
  const AuthenticationState({
    required this.status,
    this.name,
  });

  /// authentication status
  final AuthenticationStatusType? status;

  /// user name
  final String? name;
  @override
  List<Object> get props =>
      [status ?? AuthenticationStatusType.unknown, 'unknown'];
}

/// auth initial state.
class AuthenticationInitial extends AuthenticationState {
  /// create auth initial state.
  const AuthenticationInitial()
      : super(status: AuthenticationStatusType.unknown);
  @override
  List<Object> get props => [];
}

/// auth authenticated state.
class AuthenticationAuthenticated extends AuthenticationState {
  /// create auth authenticated state.
  const AuthenticationAuthenticated({required String? name})
      : super(status: AuthenticationStatusType.authenticated, name: name);
  @override
  List<Object> get props => [name!];
}

/// auth unauthenticated state.
class AuthenticationUnAuthenticated extends AuthenticationState {
  /// create auth unauthenticated state.
  const AuthenticationUnAuthenticated()
      : super(status: AuthenticationStatusType.unauthenticated);
  @override
  List<Object> get props => [];
}

/// auth unknown state.
class AuthenticationUnknown extends AuthenticationState {
  /// create auth unknown state.
  const AuthenticationUnknown()
      : super(status: AuthenticationStatusType.unknown);
  @override
  List<Object> get props => [];
}

/// error state
class AuthenticationError extends AuthenticationState {
  /// create error state
  const AuthenticationError({
    this.errorMessage = '',
  }) : super(status: AuthenticationStatusType.unknown);

  /// error message
  final String errorMessage;

  @override
  List<Object> get props => [];
}

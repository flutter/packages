import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:go_router_examples/auth_bloc/type/authentication_status_type.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

/// A [Bloc] which manages users authentication .
class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  /// Creates an [AuthenticationBloc].
  AuthenticationBloc() : super(const AuthenticationInitial()) {
    on<AuthenticationStatusChanged>((
      AuthenticationStatusChanged event,
      Emitter<AuthenticationState> emit,
    ) async {
      await _onAuthenticationStatusChanged(event, emit);
    });
  }

  Future<void> _onAuthenticationStatusChanged(
    AuthenticationStatusChanged event,
    Emitter<AuthenticationState> emit,
  ) async {
    switch (event.status) {
      case AuthenticationStatusType.unauthenticated:
        emit(const AuthenticationUnAuthenticated());
        break;
      case AuthenticationStatusType.authenticated:
        emit(AuthenticationAuthenticated(name: event.name));
        break;
      case AuthenticationStatusType.unknown:
        emit(const AuthenticationUnknown());
        break;
    }
  }
}

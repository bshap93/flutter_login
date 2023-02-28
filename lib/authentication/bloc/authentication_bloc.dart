import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

/// The bloc handling authentication statuses and events
class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({
    /// taking a repository which has a status
    required AuthenticationRepository authenticationRepository,

    /// Authentication block requires these two repositories, the User
    required UserRepository userRepository,
  })  : _authenticationRepository = authenticationRepository,
        _userRepository = userRepository,
        // initially unknown state
        super(const AuthenticationState.unknown()) {
    // handler for the status change
    on<_AuthenticationStatusChanged>(_onAuthenticationStatusChanged);
    // handler for the logout
    on<AuthenticationLogoutRequested>(_onAuthenticationLogoutRequested);
    // make a private subscription to the event of a status changing, the stream we created in the
    // repository, to therefore listen to auth changes and add these to the bloc event input
    _authenticationStatusSubscription = _authenticationRepository.status.listen(
      (status) => add(_AuthenticationStatusChanged(status)),
    );
  }

  final AuthenticationRepository _authenticationRepository;
  final UserRepository _userRepository;

  /// The stream sub used above
  late StreamSubscription<AuthenticationStatus>
      _authenticationStatusSubscription;

  @override
  Future<void> close() {
    // close up that connection to the repo
    _authenticationStatusSubscription.cancel();
    // call other tidy up features closing the bloc stream
    return super.close();
  }

  /// handle the events involving stat change
  Future<void> _onAuthenticationStatusChanged(

      /// private event type, and regular emitter
      _AuthenticationStatusChanged event,
      Emitter<AuthenticationState> emit) async {
    /// based on which status,  return emit a state
    switch (event.status) {
      // If we are not authenticated emit state
      case AuthenticationStatus.unauthenticated:
        emit(const AuthenticationState.unauthenticated());
        break;
      // if we're authed, then we should tryget user
      case AuthenticationStatus.authenticated:
        final user = await _tryGetUser();

        /// Emit authed if we succeed and get user,
        /// else emit unauthed
        emit(
          user != null
              ? AuthenticationState.authenticated(user)
              : const AuthenticationState.unauthenticated(),
        );
        break;
      case AuthenticationStatus.unknown:
        emit(const AuthenticationState.unknown());
        break;
    }
  }

  void _onAuthenticationLogoutRequested(
      AuthenticationLogoutRequested event, Emitter<AuthenticationState> emit) {
    _authenticationRepository.logOut();
  }

  Future<User?> _tryGetUser() async {
    try {
      final user = await _userRepository.getUser();
      return user;
    } catch (e) {
      return null;
    }
  }
}

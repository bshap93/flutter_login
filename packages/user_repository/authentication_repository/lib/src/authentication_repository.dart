import 'dart:async';

enum UserStatus { unknown, authenticated, unauthenticated }

class UserRepository {
  final _controller = StreamController<UserStatus>();

  Stream<UserStatus> get status async* {
    await Future<void>.delayed(const Duration(seconds: 1));
    yield UserStatus.unauthenticated;
    yield* _controller.stream;
  }

  Future<void> logIn({
    required String username,
    required String password,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: 300),
      () => _controller.add(UserStatus.authenticated),
    );
  }

  void logOut() {
    _controller.add(UserStatus.unauthenticated);
  }

  void dispose() => _controller.close();
}

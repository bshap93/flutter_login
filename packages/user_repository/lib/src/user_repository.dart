import 'dart:async';
import 'package:uuid/uuid.dart';

import 'package:user_repository/src/models/models.dart';

class UserRepository {
  /// User might be logged in or not
  User? _user;

  /// If a user is logged in then return it otherwise wait and create a user
  Future<User?> getUser() async {
    if (_user != null) return _user;
    return Future.delayed(const Duration(milliseconds: 300),
        () => _user = User(const Uuid().v4()));
  }
}

import 'package:flutter/material.dart';

import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel _user = UserModel.guest;

  UserModel get user => _user;
  bool get isLoggedIn => _user.isLoggedIn;

  void login(UserModel u) {
    _user = u.copyWith(isLoggedIn: true);
    notifyListeners();
  }

  void logout() {
    _user = UserModel.guest;
    notifyListeners();
  }

  void setGuest() {
    _user = UserModel(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      nickname: '去野探索者',
      bio: '正在探索世界',
      isLoggedIn: true,
    );
    notifyListeners();
  }

  void updateProfile(UserModel u) {
    _user = u;
    notifyListeners();
  }
}

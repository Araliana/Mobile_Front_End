import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugas_front_end_nicolas/utils/index.dart';
import '../model/user.dart';

class UserProvider with ChangeNotifier {
  List<User> userList = [
    User(
      email: "john.doer@gmail.com",
      profilePic: null,
      fullname: "JOHN DOER",
      countryCode: "CN",
      dialCode: "86",
      phone: "123456789",
      password: "Asdf1234!",
    ),
  ];

  User? currentUser;
  bool isLoading = false;

  UserProvider() {
    loadUsersFromPrefs().then((_) {
      loadCurrentUserEmailFromPrefs();
    });
  }

  Future<void> saveUsersToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedList =
        userList.map((user) => jsonEncode(user.toJson())).toList();
    await prefs.setStringList('userList', encodedList);
  }

  Future<void> loadUsersFromPrefs() async {
    isLoading = true;
    final prefs = await SharedPreferences.getInstance();
    final encodedList = prefs.getStringList('userList');
    if (encodedList != null) {
      userList =
          encodedList.map((userStr) {
            final json = jsonDecode(userStr);
            return User.fromJson(json);
          }).toList();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadCurrentUserEmailFromPrefs() async {
    isLoading = true;
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('currentEmail');
    if (email != null) {
      currentUser = userList.firstWhereOrNull((u) => u.email == email);
    }
    isLoading = false;
    notifyListeners();
  }

  void registerUser({
    required String email,
    String? profile_pic,
    required String fullname,
    required String country_code,
    required String phone,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final String dialCode =
        countries
            .firstWhereOrNull((item) => item.code == country_code)!
            .dialCode;
    final newUser = User(
      email: email.trim().toLowerCase(),
      profilePic: profile_pic,
      fullname: fullname,
      countryCode: country_code,
      dialCode: dialCode,
      phone: phone.trim(),
      password: password,
    );
    userList.add(newUser);
    currentUser = newUser;
    await prefs.setString('currentEmail', email);
    await saveUsersToPrefs();
    notifyListeners();
  }

  User? findUserByEmail(String email) {
    final user = userList.firstWhereOrNull(
      (u) => u.email == email.trim().toLowerCase(),
    );
    return user;
  }

  User? findUserByPhone(String phone, String countryCode) {
    final user = userList.firstWhereOrNull(
      (u) => u.phone == phone.trim() && u.countryCode == countryCode,
    );
    return user;
  }

  Future<int> login(User user, String password) async {
    final prefs = await SharedPreferences.getInstance();
    if (user.password == password) {
      currentUser = user;
      await prefs.setString('currentEmail', user.email);
      notifyListeners();
      return 1;
    }
    return -1;
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    currentUser = null;
    await prefs.remove('currentEmail');
    notifyListeners();
  }

  int resetPassword(User user, String newPass) {
    final result = user.resetPassword(newPass);
    saveUsersToPrefs();
    notifyListeners();
    return result;
  }

  void rateApp(int rate) {
    currentUser?.rateApp(rate);
    saveUsersToPrefs();
    notifyListeners();
  }

  void setUp2Fac() {
    currentUser?.setUp2Fac();
    saveUsersToPrefs();
    notifyListeners();
  }

  int changePassword(String oldPass, String newPass) {
    final result = currentUser?.changePassword(oldPass, newPass) ?? -1;
    saveUsersToPrefs();
    notifyListeners();
    return result;
  }

  void editProfile({
    required String fullname,
    required String email,
    required String phone,
    required String countryCode,
    String? birthDate,
    String? gender,
    String? profilePic,
  }) {
    final String dialCode =
        countries
            .firstWhereOrNull((item) => item.code == countryCode)!
            .dialCode;
    currentUser?.editProfile(
      newFullname: fullname,
      newEmail: email.toLowerCase(),
      newPhone: phone,
      newCountryCode: countryCode,
      newDialCode: dialCode,
      newBirthDate: birthDate,
      newGender: gender,
      newProfilePic: profilePic,
    );
    saveUsersToPrefs();
    notifyListeners();
  }

  int joinMember({required MemberType type, required double nominal}) {
    final result = currentUser?.joinMember(type: type, nominal: nominal) ?? -1;
    notifyListeners();
    saveUsersToPrefs();
    return result;
  }

  void topUp(double nominal) {
    currentUser?.topUp(nominal);
    saveUsersToPrefs();
    notifyListeners();
  }

  int purchase(double nominal, [bool allowedMinus = false]) {
    final result = currentUser?.purchase(nominal, allowedMinus) ?? -1;
    saveUsersToPrefs();
    notifyListeners();
    return result;
  }
}

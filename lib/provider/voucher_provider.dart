import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugas_front_end_nicolas/factory/voucher_factory.dart';
import 'package:tugas_front_end_nicolas/model/parking_lot.dart';
import 'package:tugas_front_end_nicolas/model/user.dart';
import 'package:tugas_front_end_nicolas/model/voucher.dart';
import 'package:tugas_front_end_nicolas/utils/index.dart';

class VoucherProvider with ChangeNotifier {
  List<Voucher> vouchers = voucherFactory.vouchers;
  List<UserVoucher> vouchersHistories = [];
  bool isLoading = false;

  VoucherProvider() {
    loadVoucherHistories();
    loadVoucher();
  }

  Future<void> saveVoucherHistories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList =
        vouchersHistories.map((v) => jsonEncode(v.toJson())).toList();
    await prefs.setStringList('voucherHistories', jsonList);
  }

  Future<void> loadVoucherHistories() async {
    isLoading = true;
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('voucherHistories');
    if (jsonList == null) {
      await saveVoucher();
      return;
    }

    vouchersHistories =
        jsonList.map((e) {
          final decoded = jsonDecode(e);
          return UserVoucher.fromJson(decoded);
        }).toList();

    isLoading = false;
    notifyListeners();
  }

  Future<void> saveVoucher() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = vouchers.map((v) => jsonEncode(v.toJson())).toList();
    await prefs.setStringList('voucher', jsonList);
  }

  Future<void> loadVoucher() async {
    isLoading = true;
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('voucher');
    if (jsonList == null) return;

    vouchers =
        jsonList.map((e) {
          final decoded = jsonDecode(e);
          return Voucher.fromJson(decoded);
        }).toList();

    isLoading = false;
    notifyListeners();
  }

  List<Voucher> getAvailableVoucher() {
    final now = DateTime.now();

    return vouchers
        .where(
          (voucher) =>
              voucher.validUntil.isAfter(now) ||
              voucher.validUntil.isAtSameMomentAs(now),
        )
        .toList();
  }

  List<VoucherRemain> getAvailableRemain(ParkingLot lot, int hour, User user) {
    final allAvailable =
        getAvailableVoucher().where((voucher) {
          return voucher.lot == lot &&
              (voucher.minHour == null || voucher.minHour! <= hour);
        }).toList();

    final userHistory = vouchersHistories.firstWhereOrNull(
      (history) => history.user == user,
    );

    return allAvailable.map((voucher) {
      final remainEntry = userHistory?.userVoucherhistory.firstWhereOrNull(
        (v) => v.voucher == voucher,
      );

      final remain =
          voucher.maxUse != null ? (remainEntry?.remain ?? voucher.maxUse!) : 1;

      return VoucherRemain(voucher, remain);
    }).toList();
  }

  void useVoucher(Voucher voucher, User user) {
    final index = vouchersHistories.indexWhere((v) => v.user == user);

    if (index == -1) {
      final newHistory = UserVoucher(user, []);
      newHistory.useVoucher(voucher);
      vouchersHistories.add(newHistory);
    } else {
      vouchersHistories[index].useVoucher(voucher);
    }
    saveVoucherHistories();
    notifyListeners();
  }
}

class UserVoucher {
  final User user;
  final List<VoucherRemain> userVoucherhistory;

  UserVoucher(this.user, this.userVoucherhistory);

  void useVoucher(Voucher voucher) {
    final index = userVoucherhistory.indexWhere((v) => v.voucher == voucher);
    if (voucher.maxUse != null) {
      if (index != -1) {
        userVoucherhistory[index].remain = voucher.maxUse! - 1;
      } else {
        userVoucherhistory.add(VoucherRemain(voucher, voucher.maxUse! - 1));
      }
    }
  }

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'userVoucherhistory': userVoucherhistory.map((e) => e.toJson()).toList(),
  };

  factory UserVoucher.fromJson(Map<String, dynamic> json) => UserVoucher(
    User.fromJson(json['user']),
    (json['userVoucherhistory'] as List<dynamic>)
        .map((e) => VoucherRemain.fromJson(e))
        .toList(),
  );
}

class VoucherRemain {
  final Voucher voucher;
  int remain;

  VoucherRemain(this.voucher, this.remain);

  Map<String, dynamic> toJson() => {
    'voucher': voucher.toJson(),
    'remain': remain,
  };

  factory VoucherRemain.fromJson(Map<String, dynamic> json) =>
      VoucherRemain(Voucher.fromJson(json['voucher']), json['remain']);
}

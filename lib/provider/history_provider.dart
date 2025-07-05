import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugas_front_end_nicolas/model/booking.dart';
import 'package:tugas_front_end_nicolas/model/history.dart';
import 'package:tugas_front_end_nicolas/model/parking.dart';
import 'package:tugas_front_end_nicolas/model/parking_lot.dart';
import 'package:tugas_front_end_nicolas/model/user.dart';
import 'package:tugas_front_end_nicolas/model/voucher.dart';
import 'package:tugas_front_end_nicolas/provider/activity_provider.dart';
import 'package:tugas_front_end_nicolas/provider/parking_lot_provider.dart';
import 'package:tugas_front_end_nicolas/provider/user_provider.dart';
import 'package:tugas_front_end_nicolas/utils/index.dart';

class HistoryProvider with ChangeNotifier {
  List<History> histories = [];
  bool isLoading = false;

  HistoryProvider() {
    loadHistoriesFromPrefs();
  }

  Future<void> saveHistoriesToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = histories.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList('histories', encoded);
  }

  Future<void> loadHistoriesFromPrefs() async {
    isLoading = true;
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getStringList('histories');

    if (encoded != null) {
      histories =
          encoded.map((s) {
            final json = jsonDecode(s);
            return History.fromJson(json);
          }).toList();
    }
    isLoading = false;
    notifyListeners();
  }

  Parking addParking({
    required User user,
    required ParkingLot lot,
    required String floor,
    required String code,
  }) {
    final index = histories.indexWhere((v) => v.user == user);
    final parking = Parking(
      id:
          "PARK-${lot.prefix}-${index == -1 ? 1 : histories[index].bookings.length + 1}${generateUnique()}",
      user: user,
      lot: lot,
      floor: floor,
      code: code,
    );
    parking.checkinTime = DateTime.now();
    if (index != -1) {
      histories[index].addParking(parking);
      saveHistoriesToPrefs();
      notifyListeners();
      return histories[index].parkings[0];
    } else {
      histories.add(History(user, [parking], []));
      saveHistoriesToPrefs();
      notifyListeners();
      return histories.last.parkings[0];
    }
  }

  Booking addBooking({
    required User user,
    required ParkingLot lot,
    required String floor,
    required String spot,
    required DateTime time,
  }) {
    final index = histories.indexWhere((v) => v.user == user);
    final booking = Booking(
      id:
          "BOOK-${lot.prefix}-${index == -1 ? 1 : histories[index].bookings.length + 1}${generateUnique()}",
      user: user,
      lot: lot,
      floor: floor,
      code: spot,
      bookingTime: time,
    );
    if (index != -1) {
      histories[index].addBooking(booking);
      saveHistoriesToPrefs();
      notifyListeners();
      return histories[index].bookings[0];
    } else {
      histories.add(History(user, [], [booking]));
      saveHistoriesToPrefs();
      notifyListeners();
      return histories.last.bookings[0];
    }
  }

  List<Parking>? getParking(User user) {
    return histories.firstWhereOrNull((item) => item.user == user)?.parkings;
  }

  List<Parking>? getBooking(User user) {
    return histories.firstWhereOrNull((item) => item.user == user)?.bookings;
  }

  List<Parking> getActive(User user) {
    return histories
            .firstWhereOrNull((item) => item.user == user)
            ?.getActive() ??
        [];
  }

  List<Parking> getUnresolved(User user) {
    return histories
            .firstWhereOrNull((item) => item.user == user)
            ?.getUnresolved() ??
        [];
  }

  Parking? getHistoryDetail(User user, String historyId) {
    final isBooking = historyId.startsWith("BOOK");
    final userHistory = histories.firstWhereOrNull((item) => item.user == user);

    if (userHistory == null) return null;

    if (isBooking) {
      final booking = userHistory.bookings.firstWhereOrNull(
        (item) => item.id == historyId,
      );
      return booking;
    } else {
      return userHistory.parkings.firstWhereOrNull(
        (item) => item.id == historyId,
      );
    }
  }

  List<ParkingLot>? getFrequentLots(User user) {
    final frequent =
        histories
            .firstWhereOrNull((item) => item.user == user)
            ?.getFrequentLots();

    if (frequent == null || frequent.isEmpty) {
      return null;
    }

    return frequent.take(5).toList();
  }

  void checkAllStatus(User user, BuildContext context) {
    final lotProvider = Provider.of<ParkingLotProvider>(context);
    final activityProvider = Provider.of<ActivityProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final userHistory = histories.firstWhereOrNull((item) => item.user == user);
    if (userHistory == null) return;
    userHistory.checkAllStatus();
    userHistory.bookings.forEach((item) {
      if (!item.hasAlerted &&
          [
            ActivityType.bookExp,
            ActivityType.unresolved,
          ].contains(item.status)) {
        lotProvider.freeSpot(
          lot: item.lot,
          floorNumber: item.floor,
          spotCode: item.code,
        );
        if (item.status == HistoryStatus.expired) {
          userProvider.purchase(item.noshowFee!);
        }
        activityProvider.addActivity(
          user,
          ActivityItem(
            date:
                item.status == HistoryStatus.expired
                    ? item.bookingTime.add(
                      Duration(minutes: item.isMember! ? 45 : 30),
                    )
                    : item.checkinTime!.add(Duration(hours: 20)),
            mall: item.lot.name,
            activityType:
                item.status == HistoryStatus.expired
                    ? ActivityType.bookExp
                    : ActivityType.unresolved,
          ),
        );
        item.hasAlerted = true;
      }
    });
    userHistory.parkings.forEach((item) {
      if (!item.hasAlerted && [ActivityType.unresolved].contains(item.status)) {
        lotProvider.freeSpot(
          lot: item.lot,
          floorNumber: item.floor,
          spotCode: item.code,
        );
        activityProvider.addActivity(
          user,
          ActivityItem(
            date: item.checkinTime!.add(Duration(hours: 20)),
            mall: item.lot.name,
            activityType:
                item.status == HistoryStatus.expired
                    ? ActivityType.bookExp
                    : ActivityType.unresolved,
          ),
        );
        item.hasAlerted = true;
      }
    });

    saveHistoriesToPrefs();
    notifyListeners();
  }

  HistoryStatus? checkStatus(User user, Parking history) {
    final userHistory = histories.firstWhereOrNull((item) => item.user == user);
    if (userHistory == null) return null;

    HistoryStatus? status;

    status =
        userHistory.bookings
            .firstWhereOrNull((item) => item == history)
            ?.checkStatus();

    status ??=
        userHistory.parkings
            .firstWhereOrNull((item) => item == history)
            ?.checkStatus();

    saveHistoriesToPrefs();
    notifyListeners();

    return status;
  }

  Booking? claimBooking(User user, Booking history) {
    final userHistory = histories.firstWhereOrNull((item) => item.user == user);
    if (userHistory == null) return null;

    final booking =
        userHistory.bookings
            .firstWhereOrNull((item) => item == history)
            ?.claimBooking();

    saveHistoriesToPrefs();
    notifyListeners();
    return booking;
  }

  Booking? cancelBooking(User user, Booking history) {
    final userHistory = histories.firstWhereOrNull((item) => item.user == user);
    if (userHistory == null) return null;

    final booking =
        userHistory.bookings
            .firstWhereOrNull((item) => item == history)
            ?.cancelBooking();

    saveHistoriesToPrefs();
    notifyListeners();
    return booking;
  }

  Parking? exitParking(User user, Parking history, Voucher? voucher) {
    final userHistory = histories.firstWhereOrNull((item) => item.user == user);
    if (userHistory == null) return null;

    Parking? booking;

    booking = userHistory.bookings
        .firstWhereOrNull((item) => item == history)
        ?.exitParking(voucher);

    booking ??= userHistory.parkings
        .firstWhereOrNull((item) => item == history)
        ?.exitParking(voucher);

    saveHistoriesToPrefs();
    notifyListeners();

    return booking;
  }

  Parking? resolveUnresolve(User user, Parking history) {
    final userHistory = histories.firstWhereOrNull((item) => item.user == user);
    if (userHistory == null) return null;

    Parking? booking;

    booking =
        userHistory.bookings
            .firstWhereOrNull((item) => item == history)
            ?.resolveUnresolve();

    booking ??=
        userHistory.parkings
            .firstWhereOrNull((item) => item == history)
            ?.resolveUnresolve();

    saveHistoriesToPrefs();
    notifyListeners();

    return booking;
  }
}

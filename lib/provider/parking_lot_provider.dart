import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugas_front_end_nicolas/model/parking_lot.dart';
import 'package:tugas_front_end_nicolas/model/user.dart';
import 'package:tugas_front_end_nicolas/utils/index.dart';
import 'package:tugas_front_end_nicolas/factory/lot_factory.dart';

class ParkingLotProvider with ChangeNotifier {
  List<ParkingLot> lots = lotFactory.lots;
  List<UserSearchHistory> searches = [];
  bool isLoading = false;

  UserSearchHistory? loadHistory(User user) {
    return searches.firstWhereOrNull((item) => item.user == user);
  }

  ParkingLotProvider() {
    loadSearchHistoriesFromPrefs();
    loadParkingLotFromPrefs();
  }

  Future<void> saveSearchHistoriesToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = searches.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList('searchHistories', encoded);
  }

  Future<void> loadSearchHistoriesFromPrefs() async {
    isLoading = true;
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getStringList('searchHistories');

    if (encoded != null) {
      searches =
          encoded.map((s) {
            final json = jsonDecode(s);
            return UserSearchHistory.fromJson(json);
          }).toList();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> saveParkingLotToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = lots.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList('parkingLot', encoded);
  }

  Future<void> loadParkingLotFromPrefs() async {
    isLoading = true;
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getStringList('parkingLot');

    if (encoded == null) {
      saveParkingLotToPrefs();
      return;
    }
    lots =
        encoded.map((s) {
          final json = jsonDecode(s);
          return ParkingLot.fromJson(json);
        }).toList();

    isLoading = false;
    notifyListeners();
  }

  List<ParkingLot>? searchLot(User user, String key) {
    final keyword = key.trim().toLowerCase();

    final mallKeywords = [
      'mall',
      'malls',
      'mal',
      'shopping',
      'pusat perbelanjaan',
      'shopping center',
      'shopping centre',
      'shopping mall',
      'plaza',
    ];

    final hotelKeywords = [
      'hotel',
      'hotels',
      'penginapan',
      'akomodasi',
      'inap',
      'resort',
      'motel',
    ];

    final filterLots =
        lots.where((item) {
          getAvailableSpot(item);

          final nameMatch = item.name.toLowerCase().contains(keyword);

          final buildingTypeMatch =
              (mallKeywords.contains(keyword) &&
                  item.buildingType == BuildingType.mall) ||
              (hotelKeywords.contains(keyword) &&
                  item.buildingType == BuildingType.hotel);

          return nameMatch || buildingTypeMatch;
        }).toList();

    var history = searches.firstWhereOrNull((item) => item.user == user);

    if (history == null) {
      history = UserSearchHistory(user, []);
      searches.add(history);
    }

    history.searchHistory.remove(keyword);
    history.searchHistory.insert(0, keyword);

    saveSearchHistoriesToPrefs();
    notifyListeners();
    return filterLots;
  }

  void deleteHistory(User user, String key) {
    final history = searches.firstWhereOrNull((item) => item.user == user);

    if (history == null) return;

    history.searchHistory.remove(key.trim());
    saveSearchHistoriesToPrefs();
    notifyListeners();
  }

  List<Floor> getAvailableSpot(ParkingLot lot) {
    final index = lots.indexWhere((item) => item == lot);
    final floors = lots[index].renderAllSlot();
    saveParkingLotToPrefs();
    notifyListeners();
    return floors;
  }

  Slot? occupyNearestSpot(ParkingLot lot, User user) {
    final index = lots.indexWhere((item) => item == lot);
    final slot = lots[index].occupyNearestSpot(user);
    saveParkingLotToPrefs();
    notifyListeners();
    return slot;
  }

  Slot? bookSpot({
    required ParkingLot lot,
    required User user,
    required String floorNumber,
    required String spotCode,
  }) {
    final index = lots.indexWhere((item) => item == lot);
    final slot = lots[index].bookSpot(floorNumber, spotCode, user);
    saveParkingLotToPrefs();
    notifyListeners();
    return slot;
  }

  Slot? claimSpot({
    required ParkingLot lot,
    required String floorNumber,
    required String spotCode,
  }) {
    final index = lots.indexWhere((item) => item == lot);
    final slot = lots[index].claimSpot(floorNumber, spotCode);
    saveParkingLotToPrefs();
    notifyListeners();
    return slot;
  }

  Slot? freeSpot({
    required ParkingLot lot,
    required String floorNumber,
    required String spotCode,
  }) {
    final index = lots.indexWhere((item) => item == lot);
    final slot = lots[index].freeSpot(floorNumber, spotCode);
    saveParkingLotToPrefs();
    notifyListeners();
    return slot;
  }

  SpotStatus? checkSpotStatus({
    required ParkingLot lot,
    required String floorNumber,
    required String spotCode,
  }) {
    final index = lots.indexWhere((item) => item == lot);
    final status = lots[index].checkSpotStatus(floorNumber, spotCode);
    saveSearchHistoriesToPrefs();
    notifyListeners();
    return status;
  }
}

class UserSearchHistory {
  final User user;
  final List<String> searchHistory;

  UserSearchHistory(this.user, this.searchHistory);

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'searchHistory': searchHistory,
  };

  factory UserSearchHistory.fromJson(Map<String, dynamic> json) {
    return UserSearchHistory(
      User.fromJson(json['user']),
      List<String>.from(json['searchHistory'] ?? []),
    );
  }
}

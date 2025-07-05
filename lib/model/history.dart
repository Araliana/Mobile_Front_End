import 'package:tugas_front_end_nicolas/model/booking.dart';
import 'package:tugas_front_end_nicolas/model/parking.dart';
import 'package:tugas_front_end_nicolas/model/parking_lot.dart';
import 'package:tugas_front_end_nicolas/model/user.dart';

enum HistoryStatus {
  pending,
  fixed,
  expired,
  entered,
  exited,
  cancel,
  unresolved,
}

class History {
  final User user;
  final List<Parking> parkings;
  final List<Booking> bookings;

  History(this.user, this.parkings, this.bookings);

  void checkAllStatus() {
    for (var item in parkings) {
      item.checkStatus();
    }
    for (var item in bookings) {
      item.checkStatus();
    }
  }

  void addParking(Parking parking) {
    parkings.insert(0, parking);
  }

  void addBooking(Booking booking) {
    bookings.insert(0, booking);
  }

  List<Parking> getActive() {
    final activeParking =
        parkings.where((item) => item.status == HistoryStatus.entered).toList();
    final activeBooking =
        bookings.where((item) => item.status == HistoryStatus.entered).toList();
    final combined = [...activeBooking, ...activeParking];

    combined.sort((a, b) => a.checkinTime!.compareTo(b.checkinTime!));

    return combined;
  }

  List<Parking> getUnresolved() {
    final unresolvedParking =
        parkings
            .where((item) => item.status == HistoryStatus.unresolved)
            .toList();
    final unresolvedBooking =
        bookings
            .where((item) => item.status == HistoryStatus.unresolved)
            .toList();
    final combined = [...unresolvedBooking, ...unresolvedParking];

    combined.sort((a, b) => a.checkinTime!.compareTo(b.checkinTime!));

    return combined;
  }

  List<ParkingLot> getFrequentLots() {
    final Map<ParkingLot, int> counts = {};

    for (final p in parkings) {
      if (p.status == HistoryStatus.exited) {
        counts[p.lot] = (counts[p.lot] ?? 0) + 1;
      }
    }

    for (final b in bookings) {
      if (b.status == HistoryStatus.exited) {
        counts[b.lot] = (counts[b.lot] ?? 0) + 1;
      }
    }

    final entries =
        counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return entries.map((e) => e.key).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'parkings': parkings.map((p) => p.toJson()).toList(),
      'bookings': bookings.map((b) => b.toJson()).toList(),
    };
  }

  factory History.fromJson(Map<String, dynamic> json) {
    final user = User.fromJson(json['user']);

    final parkings =
        (json['parkings'] as List<dynamic>)
            .map((e) => Parking.fromJson(e as Map<String, dynamic>))
            .toList();

    final bookings =
        (json['bookings'] as List<dynamic>)
            .map((e) => Booking.fromJson(e as Map<String, dynamic>))
            .toList();

    return History(user, parkings, bookings);
  }
}

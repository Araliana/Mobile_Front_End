import 'package:tugas_front_end_nicolas/model/history.dart';
import 'package:tugas_front_end_nicolas/model/parking.dart';

class Booking extends Parking {
  final DateTime bookingTime;
  DateTime? cancelTime;

  double? noshowFee = 0;

  Booking({
    required super.id,
    required super.user,
    required super.lot,
    required super.floor,
    super.hasAlerted = false,
    required super.code,
    required this.bookingTime,
    super.status = HistoryStatus.pending,
  });

  Booking claimBooking() {
    final now = DateTime.now();
    final diffExpired = now.difference(bookingTime).inMinutes;

    final isMember = user.checkStatusMember();
    final expiredThreshold = isMember ? 45 : 30;

    if ((status == HistoryStatus.pending || status == HistoryStatus.fixed) &&
        diffExpired > expiredThreshold) {
      status = HistoryStatus.expired;
      if (!isMember) {
        noshowFee = lot.maxTotalEarning() * 0.35;
      }
    } else {
      status = HistoryStatus.entered;
      checkinTime = DateTime.now();
    }

    return this;
  }

  Booking cancelBooking() {
    final now = DateTime.now();
    final diff = bookingTime.difference(now).inMinutes;

    final isMember = user.checkStatusMember();
    final canCancel = isMember ? diff > 15 : diff > 30;

    if (status == HistoryStatus.pending && canCancel) {
      status = HistoryStatus.cancel;
      cancelTime = now;
    } else if (status == HistoryStatus.pending) {
      status = HistoryStatus.fixed;
    }

    return this;
  }

  @override
  HistoryStatus checkStatus() {
    final now = DateTime.now();
    final diffExpired = now.difference(bookingTime).inMinutes;
    final diffFixed = bookingTime.difference(now).inMinutes;

    if (![
      HistoryStatus.cancel,
      HistoryStatus.expired,
      HistoryStatus.exited,
    ].contains(status)) {
      isMember = user.checkStatusMember();
      final expiredThreshold = isMember! ? 45 : 30;
      final fixedThreshold = isMember! ? 15 : 30;

      if ((status == HistoryStatus.pending || status == HistoryStatus.fixed) &&
          diffExpired >= expiredThreshold) {
        status = HistoryStatus.expired;
        if (!isMember!) {
          noshowFee = lot.maxTotalEarning() * 0.35;
        }
      } else if (status == HistoryStatus.pending &&
          diffFixed <= fixedThreshold) {
        status = HistoryStatus.fixed;
      } else if (status == HistoryStatus.entered && calculateHour() >= 20) {
        super.checkStatus();
      }
    }

    return status;
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();

    data['bookingTime'] = bookingTime.toIso8601String();
    if (cancelTime != null) data['cancelTime'] = cancelTime!.toIso8601String();
    if (noshowFee != null && noshowFee != 0) {
      data['noshowFee'] = noshowFee;
    }

    return data;
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    final parking = Parking.fromJson(json);

    final booking = Booking(
      id: parking.id,
      user: parking.user,
      lot: parking.lot,
      floor: parking.floor,
      code: parking.code,
      hasAlerted: parking.hasAlerted,
      bookingTime: DateTime.parse(json['bookingTime']),
    );

    booking.checkinTime = parking.checkinTime;
    booking.isMember = parking.isMember;
    booking.createdAt = parking.createdAt;
    booking.checkoutTime = parking.checkoutTime;
    booking.status = parking.status;
    booking.hours = parking.hours;
    booking.amount = parking.amount;
    booking.tax = parking.tax;
    booking.service = parking.service;
    booking.voucher = parking.voucher;
    booking.total = parking.total;
    booking.unresolvedFee = parking.unresolvedFee;

    if (json['cancelTime'] != null) {
      booking.cancelTime = DateTime.parse(json['cancelTime']);
    }

    booking.noshowFee = (json['noshowFee'] as num?)?.toDouble();

    return booking;
  }
}

import 'package:tugas_front_end_nicolas/model/history.dart';
import 'package:tugas_front_end_nicolas/model/parking_lot.dart';
import 'package:tugas_front_end_nicolas/model/user.dart';
import 'package:tugas_front_end_nicolas/model/voucher.dart';
import 'package:tugas_front_end_nicolas/utils/index.dart';

class Parking {
  final String id;
  final User user;
  final ParkingLot lot;
  bool hasAlerted;
  bool? isMember;
  DateTime? checkinTime;
  DateTime? checkoutTime;
  DateTime? cancelTime;
  DateTime createdAt = DateTime.now();
  final String floor;
  final String code;
  HistoryStatus status;

  int? hours;
  double? amount;
  double? tax;
  double? service;
  double? voucher;
  double? total;
  double? unresolvedFee = 0;

  Parking({
    required this.id,
    required this.user,
    required this.lot,
    required this.floor,
    this.hasAlerted = false,
    required this.code,
    this.status = HistoryStatus.entered,
  }) : isMember = user.checkStatusMember();

  Parking exitParking(Voucher? voucher) {
    isMember = user.checkStatusMember();
    status = HistoryStatus.exited;
    hours = calculateHour();
    amount = lot.calculateAmount(hours!);
    tax = amount! * 0.11;
    service = isMember! ? 0 : 6500;

    if (voucher != null) {
      this.voucher = voucher.useVoucher(amount!, hours!);
    } else {
      this.voucher = 0;
    }

    total = amount! + tax! + service! - this.voucher!;
    checkoutTime = DateTime.now();
    return this;
  }

  double calculateTotal(Voucher? voucher) {
    final bool member = user.checkStatusMember();
    final int hour = calculateHour();
    final double baseAmount = lot.calculateAmount(hour);
    final double tax = baseAmount * 0.11;
    final double service = member ? 0 : 6500;
    final double voucherValue = voucher?.useVoucher(baseAmount, hour) ?? 0;

    final double total = baseAmount + tax + service - voucherValue;
    return total;
  }

  HistoryStatus checkStatus() {
    if (status == HistoryStatus.entered && calculateHour() >= 20) {
      status = HistoryStatus.unresolved;
      checkoutTime = checkinTime!.add(Duration(hours: 20));
      amount = lot.calculateAmount(20);
      tax = amount! * 0.11;
    }
    return status;
  }

  Parking? resolveUnresolve() {
    if (status == HistoryStatus.unresolved) {
      isMember = user.checkStatusMember();
      status = HistoryStatus.exited;
      unresolvedFee = isMember! ? 0 : 10000;
      service = isMember! ? 0 : 6500;
      total = amount! + tax! + service!;
      return this;
    }
    return null;
  }

  int calculateHour() {
    final duration =
        status == HistoryStatus.unresolved
            ? DateTime.now().difference(checkinTime!)
            : (checkoutTime ?? DateTime.now()).difference(checkinTime!);
    final hours = duration.inMinutes / 60;

    return hours.ceil();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'id': id,
      'user': user.toJson(),
      'lot': lot.toJson(),
      'floor': floor,
      'code': code,
      'hasAlerted': hasAlerted,
      'createdAt': createdAt.toIso8601String(),
      'status': historyStatusToString(status),
    };

    if (checkinTime != null) {
      data['checkinTime'] = checkinTime!.toIso8601String();
    }
    if (checkoutTime != null) {
      data['checkoutTime'] = checkoutTime!.toIso8601String();
    }
    if (cancelTime != null) {
      data['cancelTime'] = cancelTime!.toIso8601String();
    }
    if (isMember != null) data["isMember"] = isMember;
    if (hours != null) data['hours'] = hours;
    if (amount != null) data['amount'] = amount;
    if (tax != null) data['tax'] = tax;
    if (service != null) data['service'] = service;
    if (voucher != null) data['voucher'] = voucher;
    if (total != null) data['total'] = total;
    if (unresolvedFee != null && unresolvedFee != 0) {
      data['unresolvedFee'] = unresolvedFee;
    }

    return data;
  }

  factory Parking.fromJson(Map<String, dynamic> json) {
    final parking = Parking(
      id: json["id"],
      user: User.fromJson(json['user']),
      lot: ParkingLot.fromJson(json['lot']),
      floor: json['floor'],
      code: json['code'],
      hasAlerted: json['hasAlerted'] ?? false,
    );

    parking.createdAt = DateTime.parse(json['createdAt']);
    parking.isMember = json['isMember'];
    parking.checkinTime =
        json['checkinTime'] != null
            ? DateTime.parse(json['checkinTime'])
            : null;
    parking.checkoutTime =
        json['checkoutTime'] != null
            ? DateTime.parse(json['checkoutTime'])
            : null;
    parking.cancelTime =
        json['cancelTime'] != null ? DateTime.parse(json['cancelTime']) : null;
    parking.status = historyStatusFromString(json['status']);
    parking.hours = json['hours'];
    parking.amount = (json['amount'] as num?)?.toDouble();
    parking.tax = (json['tax'] as num?)?.toDouble();
    parking.service = (json['service'] as num?)?.toDouble();
    parking.voucher = (json['voucher'] as num?)?.toDouble();
    parking.total = (json['total'] as num?)?.toDouble();
    parking.unresolvedFee = (json['unresolvedFee'] as num?)?.toDouble() ?? 0;

    return parking;
  }
}

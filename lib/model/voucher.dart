import 'package:tugas_front_end_nicolas/model/parking_lot.dart';

enum VoucherFlag { flat, percent, free }

VoucherFlag voucherFlagFromString(String value) {
  switch (value) {
    case 'flat':
      return VoucherFlag.flat;
    case 'percent':
      return VoucherFlag.percent;
    case 'free':
      return VoucherFlag.free;
    default:
      throw ArgumentError('Invalid VoucherFlag: $value');
  }
}

String voucherFlagToString(VoucherFlag flag) {
  return flag.toString().split('.').last;
}

class Voucher {
  final ParkingLot lot;
  final int? minHour;
  final String voucherName;
  final DateTime validUntil;
  final double? nominal;
  final VoucherFlag type;
  int? maxUse;

  Voucher({
    required this.lot,
    this.minHour,
    required this.voucherName,
    required this.validUntil,
    required this.nominal,
    this.type = VoucherFlag.flat,
    this.maxUse,
  });

  double calculateDiscount(double total, int hours) {
    if (DateTime.now().isAfter(validUntil)) return 0;
    if (minHour != null && hours < minHour!) return 0;
    if (maxUse != null && maxUse! <= 0) return 0;

    double discount = 0;
    switch (type) {
      case VoucherFlag.flat:
        discount = nominal ?? 0;
        break;
      case VoucherFlag.percent:
        discount = total * ((nominal ?? 0) / 100);
        break;
      case VoucherFlag.free:
        discount = total;
        break;
    }

    return discount > total ? total : discount;
  }

  double useVoucher(double total, int hours) {
    final discount = calculateDiscount(total, hours);

    if (maxUse != null) {
      maxUse = maxUse! - 1;
    }

    return discount;
  }

  Map<String, dynamic> toJson() {
    return {
      'lot': lot.toJson(),
      'minHour': minHour,
      'voucherName': voucherName,
      'validUntil': validUntil.toIso8601String(),
      'nominal': nominal,
      'type': voucherFlagToString(type),
      'maxUse': maxUse,
    };
  }

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      lot: ParkingLot.fromJson(json['lot']),
      minHour: json['minHour'],
      voucherName: json['voucherName'],
      validUntil: DateTime.parse(json['validUntil']),
      nominal: (json['nominal'] as num?)?.toDouble(),
      type: voucherFlagFromString(json['type']),
      maxUse: json['maxUse'],
    );
  }
}

import 'dart:math';
import 'package:tugas_front_end_nicolas/model/voucher.dart';
import 'package:tugas_front_end_nicolas/model/parking_lot.dart';
import 'package:tugas_front_end_nicolas/factory/lot_factory.dart';
import 'package:tugas_front_end_nicolas/utils/index.dart';

class VoucherFactory {
  List<Voucher> vouchers = [];

  final List<String> fallbackNames = [
    "Special Member Voucher",
    "Late Night Voucher",
    "Weekend Saver",
    "Holiday Discount",
    "First Time User",
    "Loyalty Bonus",
    "Rainy Day Promo",
    "Morning Deal",
    "Evening Offer",
    "Pay Less Voucher",
    "Eco-Friendly Parking",
    "Student Discount",
    "Business Hour Voucher",
    "Drive Safe Bonus",
    "Festival Promo",
  ];

  final Random _random = Random();

  VoucherFactory() {
    vouchers = generateVouchers();
  }

  List<Voucher> generateVouchers() {
    final List<ParkingLot> lots = lotFactory.lots;

    final weightedLots = <ParkingLot>[
      for (final lot in lots)
        ...List.filled(lot.buildingType == BuildingType.hotel ? 1 : 3, lot),
    ];

    return List.generate(18, (index) {
      ParkingLot randomLot = weightedLots[_random.nextInt(weightedLots.length)];

      final randomType =
          _random.nextBool() ? VoucherFlag.flat : VoucherFlag.percent;
      final now = DateTime.now();
      final endOfYear = DateTime(now.year, 12, 31);
      final differenceInDays = endOfYear.difference(now).inDays;
      final validUntil = now.add(
        Duration(days: _random.nextInt(differenceInDays + 1)),
      );

      final nominal =
          randomType == VoucherFlag.flat
              ? generateFlatNominal().toDouble()
              : generatePercentNominal().toDouble();

      final name =
          _random.nextBool()
              ? generateVoucherName(randomType, nominal)
              : fallbackNames[_random.nextInt(fallbackNames.length)];

      return Voucher(
        lot: randomLot,
        voucherName: name,
        validUntil: validUntil,
        nominal: nominal,
        type: randomType,
        minHour: _random.nextBool() ? _random.nextInt(5) + 1 : null,
        maxUse: _random.nextBool() ? _random.nextInt(10) + 1 : null,
      );
    });
  }

  int generateFlatNominal() {
    final validNominals = <int>[];

    for (int i = 2500; i <= 10000; i += 500) {
      validNominals.add(i);
    }

    return validNominals[_random.nextInt(validNominals.length)];
  }

  int generatePercentNominal() {
    final percentOptions = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60];
    return percentOptions[_random.nextInt(percentOptions.length)];
  }

  String generateVoucherName(VoucherFlag type, double nominal) {
    if (type == VoucherFlag.flat && nominal == 0) {
      return "Free Parking Voucher";
    } else if (type == VoucherFlag.percent) {
      return "Discounts ${nominal.toInt()}% Voucher";
    } else {
      return "Discounts ${formatCurrency(nominal: nominal)} Off";
    }
  }
}

final VoucherFactory voucherFactory = VoucherFactory();

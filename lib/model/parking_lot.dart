import 'package:flutter/material.dart';
import 'package:tugas_front_end_nicolas/model/user.dart';
import 'package:tugas_front_end_nicolas/utils/index.dart';

enum SpotStatus { free, occupied, booked }

enum BuildingType { hotel, mall }

class Spot {
  SpotStatus status;
  User? user;
  final String code;
  DateTime? date;

  Spot({this.user, required this.status, required this.code, this.date});

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'user': user?.toJson(),
      'code': code,
      'date': date?.toIso8601String(),
    };
  }

  factory Spot.fromJson(Map<String, dynamic> json) {
    return Spot(
      status: SpotStatus.values.firstWhere((e) => e.name == json['status']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      code: json['code'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
    );
  }
}

class Area {
  final String name;
  final List<Spot> spots;

  Area({required this.name, required this.spots});

  Spot? getFirstAvailableSpot() {
    return spots.firstWhereOrNull((spot) => spot.status == SpotStatus.free);
  }

  Spot? findSpot(String code) {
    return spots.firstWhereOrNull((spot) => spot.code == code);
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'spots': spots.map((s) => s.toJson()).toList(),
  };

  factory Area.fromJson(Map<String, dynamic> json) => Area(
    name: json['name'],
    spots: (json['spots'] as List).map((e) => Spot.fromJson(e)).toList(),
  );
}

class Floor {
  final String number;
  final List<Area> areas;

  Floor({required this.number, required this.areas});

  Spot? getFirstAvailableSpot() {
    for (final area in areas) {
      final spot = area.getFirstAvailableSpot();
      if (spot != null) return spot;
    }
    return null;
  }

  Spot? findSpot(String code) {
    for (final area in areas) {
      final spot = area.findSpot(code);
      if (spot != null) return spot;
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'number': number,
    'areas': areas.map((a) => a.toJson()).toList(),
  };

  factory Floor.fromJson(Map<String, dynamic> json) => Floor(
    number: json['number'],
    areas: (json['areas'] as List).map((e) => Area.fromJson(e)).toList(),
  );
}

class ParkingLot {
  final String prefix;
  final String name;
  final BuildingType buildingType;
  final String address;
  final TimeOfDay openTime;
  final TimeOfDay closeTime;
  final double? starterPrice;
  final double hourlyPrice;
  final String image;
  int spotCount = 0;
  final List<Floor> spots;

  ParkingLot({
    required this.prefix,
    required this.name,
    required this.buildingType,
    required this.address,
    required this.openTime,
    required this.closeTime,
    required this.hourlyPrice,
    required this.image,
    required this.spots,
    this.starterPrice,
  });

  @override
  bool operator ==(Object other) {
    return other is ParkingLot && other.prefix == prefix;
  }

  int floorWeight(String label) {
    if (label == 'G') return 0;
    if (label.startsWith('G')) return -int.parse(label.substring(1));
    return int.parse(label);
  }

  Slot? occupyNearestSpot(User user) {
    renderAllSlot();

    final aboveFloors = spots.where((f) => floorWeight(f.number) > 1).toList();
    final belowFloors = spots.where((f) => floorWeight(f.number) < 1).toList();
    final floor1 = spots.firstWhereOrNull((f) => floorWeight(f.number) == 1);

    List<Floor> orderedFloors = [];

    if (floor1 != null) {
      orderedFloors.add(floor1);
    }

    aboveFloors.sort(
      (a, b) => floorWeight(a.number).compareTo(floorWeight(b.number)),
    );
    belowFloors.sort(
      (a, b) => floorWeight(a.number).compareTo(floorWeight(b.number)),
    );

    if (aboveFloors.length >= belowFloors.length) {
      orderedFloors.addAll(aboveFloors);
      orderedFloors.addAll(belowFloors);
    } else {
      orderedFloors.addAll(belowFloors);
      orderedFloors.addAll(aboveFloors);
    }

    for (final floor in orderedFloors) {
      final spot = floor.getFirstAvailableSpot();
      if (spot != null) {
        spot.status = SpotStatus.occupied;
        spot.date = DateTime.now();
        spot.user = user;
        spotCount -= 1;
        return Slot(spot.code, floor.number);
      }
    }

    return null;
  }

  Slot? bookSpot(String floorNumber, String spotCode, User user) {
    final floor = spots.firstWhereOrNull((f) => f.number == floorNumber);
    final spot = floor?.findSpot(spotCode);
    if (spot != null && spot.status == SpotStatus.free) {
      spot.status = SpotStatus.booked;
      spot.date = DateTime.now();
      spot.user = user;
      spotCount -= 1;
      return Slot(spot.code, floor!.number);
    }
    return null;
  }

  Slot? claimSpot(String floorNumber, String spotCode) {
    final floor = spots.firstWhereOrNull((f) => f.number == floorNumber);
    final spot = floor?.findSpot(spotCode);
    if (spot != null && spot.status == SpotStatus.booked) {
      spot.status = SpotStatus.occupied;
      spot.date = DateTime.now();
      return Slot(spot.code, floor!.number);
    }
    return null;
  }

  Slot? freeSpot(String floorNumber, String spotCode) {
    final floor = spots.firstWhereOrNull((f) => f.number == floorNumber);
    final spot = floor?.findSpot(spotCode);
    if (spot != null && spot.status == SpotStatus.occupied) {
      spot.status = SpotStatus.free;
      spot.date = null;
      spot.user = null;
      spotCount += 1;
      return Slot(spot.code, floor!.number);
    }
    return null;
  }

  SpotStatus? checkSpotStatus(String floorNumber, String spotCode) {
    renderAllSlot();
    final floor = spots.firstWhereOrNull((f) => f.number == floorNumber);
    final spot = floor?.findSpot(spotCode);
    if (spot != null) {
      return spot.status;
    }
    return null;
  }

  List<Floor> renderAllSlot() {
    final now = DateTime.now();

    for (var floor in spots) {
      for (var area in floor.areas) {
        for (var spot in area.spots) {
          if (spot.status == SpotStatus.free) {
            continue;
          }

          if (spot.status == SpotStatus.booked) {
            final isMember = spot.user?.checkStatusMember() ?? false;
            final diffExpired = now.difference(spot.date!).inMinutes;
            final expiredThreshold = isMember ? 45 : 30;

            if (diffExpired >= expiredThreshold) {
              spot.status = SpotStatus.free;
              spotCount += 1;
            }
          } else if (spot.status == SpotStatus.occupied) {
            final duration = now.difference(spot.date!);
            final hours = duration.inMinutes / 60;

            if (hours.ceil() > 20) {
              spot.status = SpotStatus.free;
              spotCount += 1;
            }
          }
        }
      }
    }

    return spots;
  }

  int getFreeCount() {
    renderAllSlot();
    return spotCount;
  }

  double calculateAmount(int hour) {
    return (starterPrice ?? hourlyPrice) + (hour - 1) * hourlyPrice;
  }

  double maxTotalEarning() {
    final now = DateTime.now();

    final open = DateTime(
      now.year,
      now.month,
      now.day,
      openTime.hour,
      openTime.minute,
    );

    final close = DateTime(
      now.year,
      now.month,
      now.day,
      closeTime.hour,
      closeTime.minute,
    );

    Duration diff = close.difference(open);
    final hours = (diff.inMinutes / 60).ceil();

    return calculateAmount(hours);
  }

  Map<String, dynamic> toJson() => {
    'prefix': prefix,
    'name': name,
    'buildingType': buildingType.name,
    'address': address,
    'openTime': {'hour': openTime.hour, 'minute': openTime.minute},
    'closeTime': {'hour': closeTime.hour, 'minute': closeTime.minute},
    'starterPrice': starterPrice,
    'hourlyPrice': hourlyPrice,
    'image': image,
    'spots': spots.map((f) => f.toJson()).toList(),
    'spotCount': spotCount,
  };

  factory ParkingLot.fromJson(Map<String, dynamic> json) => ParkingLot(
    prefix: json['prefix'],
    name: json['name'],
    buildingType: BuildingType.values.firstWhere(
      (e) => e.name == json['buildingType'],
    ),
    address: json['address'],
    openTime: TimeOfDay(
      hour: json['openTime']['hour'],
      minute: json['openTime']['minute'],
    ),
    closeTime: TimeOfDay(
      hour: json['closeTime']['hour'],
      minute: json['closeTime']['minute'],
    ),
    starterPrice: (json['starterPrice'] as num?)?.toDouble(),
    hourlyPrice: (json['hourlyPrice'] as num).toDouble(),
    image: json['image'],
    spots: (json['spots'] as List).map((e) => Floor.fromJson(e)).toList(),
  )..spotCount = json['spotCount'];
}

class Slot {
  final String code;
  final String floor;

  Slot(this.code, this.floor);
}

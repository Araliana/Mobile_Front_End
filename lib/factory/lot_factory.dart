import 'dart:math';

import 'package:tugas_front_end_nicolas/model/parking_lot.dart';
import 'package:tugas_front_end_nicolas/utils/index.dart';

class LotFactory {
  final Random _random = Random();

  List<ParkingLot> lots = [];

  LotFactory() {
    lots = [
      ParkingLot(
        prefix: "MED",
        name: "Medan Mall",
        buildingType: BuildingType.mall,
        address: "Jl. M. T. Haryono No.8, Kota Medan",
        openTime: stringToTime("09:00"),
        closeTime: stringToTime("20:00"),
        hourlyPrice: 3000,
        starterPrice: 5000,
        image: "assets/images/building/Medan Mall.png",
        spots: generateFloors(firstFloor: 'G', lastFloor: '5', areaStep: 2),
      ),
      ParkingLot(
        prefix: "ARY",
        name: "Aryaduta",
        buildingType: BuildingType.hotel,
        address: "Jl. Kapten Maulana Lubis No.8, Kota Medan",
        openTime: stringToTime("06:00"),
        closeTime: stringToTime("22:30"),
        hourlyPrice: 4000,
        starterPrice: 7000,
        image: "assets/images/building/Aryaduta.png",
        spots: generateFloors(firstFloor: 'G3', lastFloor: '4', areaStep: 3),
      ),
      ParkingLot(
        prefix: "CEP",
        name: "Centre Point",
        buildingType: BuildingType.mall,
        address: "Jl. Centre Point No.15, Kota Medan",
        openTime: stringToTime("07:00"),
        closeTime: stringToTime("23:00"),
        hourlyPrice: 3500,
        starterPrice: 6000,
        image: "assets/images/building/Centre Point.png",
        spots: generateFloors(firstFloor: 'G2', lastFloor: '4', areaStep: 2),
      ),
      ParkingLot(
        prefix: "LIP",
        name: "Lippo Plaza",
        buildingType: BuildingType.mall,
        address: "Jl. Veteran No.20, Kota Medan",
        openTime: stringToTime("08:00"),
        closeTime: stringToTime("22:00"),
        hourlyPrice: 5500,
        image: "assets/images/building/Lippo Plaza.png",
        spots: generateFloors(firstFloor: 'G3', lastFloor: '3', areaStep: 2),
      ),
      ParkingLot(
        prefix: "GCH",
        name: "Grand City Hall",
        buildingType: BuildingType.hotel,
        address: "Jl. Asia No. 77, Kota Medan",
        openTime: stringToTime("07:00"),
        closeTime: stringToTime("22:00"),
        hourlyPrice: 4000,
        starterPrice: 6000,
        image: "assets/images/building/Grand City Hall.png",
        spots: generateFloors(firstFloor: 'G', lastFloor: '6', areaStep: 2),
      ),
      ParkingLot(
        prefix: "SUN",
        name: "Sun Plaza",
        buildingType: BuildingType.mall,
        address: "Jl. Gatot Subroto No. 15, Kota Medan",
        openTime: stringToTime("08:00"),
        closeTime: stringToTime("22:30"),
        hourlyPrice: 3700,
        starterPrice: 5800,
        image: "assets/images/building/Sun Plaza.png",
        spots: generateFloors(firstFloor: 'G2', lastFloor: '5', areaStep: 2),
      ),
      ParkingLot(
        prefix: "RAD",
        name: "Radisson",
        buildingType: BuildingType.hotel,
        address: "Jl. S. Parman No. 45, Kota Medan",
        openTime: stringToTime("07:00"),
        closeTime: stringToTime("23:00"),
        hourlyPrice: 4700,
        starterPrice: 6500,
        image: "assets/images/building/Radisson.png",
        spots: generateFloors(firstFloor: 'G3', lastFloor: '6', areaStep: 3),
      ),
      ParkingLot(
        prefix: "MTS",
        name: "Manhattan Time Square",
        buildingType: BuildingType.mall,
        address: "Jl. Thamrin No. 99, Kota Medan",
        openTime: stringToTime("09:00"),
        closeTime: stringToTime("22:00"),
        hourlyPrice: 3900,
        starterPrice: 6200,
        image: "assets/images/building/Manhatan Time Square.png",
        spots: generateFloors(firstFloor: 'G2', lastFloor: '3', areaStep: 1),
      ),
      ParkingLot(
        prefix: "PMF",
        name: "Plaza Medan Fair",
        buildingType: BuildingType.mall,
        address: "Jl. Gatot Subroto No. 8, Kota Medan",
        openTime: stringToTime("08:30"),
        closeTime: stringToTime("21:30"),
        hourlyPrice: 5600,
        image: "assets/images/building/Plaza Medan Fair.png",
        spots: generateFloors(firstFloor: 'G', lastFloor: '4', areaStep: 1),
      ),
      ParkingLot(
        prefix: "DEL",
        name: "Delipark",
        buildingType: BuildingType.mall,
        address: "Jl. Stasiun No. 5, Kota Medan",
        openTime: stringToTime("06:30"),
        closeTime: stringToTime("22:30"),
        hourlyPrice: 3500,
        starterPrice: 5400,
        image: "assets/images/building/Delipark.png",
        spots: generateFloors(firstFloor: 'G2', lastFloor: '5', areaStep: 2),
      ),
    ];

    for (var lot in lots) {
      lot.spotCount = _countFreeSpots(lot);
    }
  }

  List<Spot> _generateSpots(String prefix, int startIndex) {
    final codes = List.generate(
      6,
      (i) => '$prefix${(startIndex + i).toString().padLeft(2, '0')}',
    );
    SpotStatus randomStat = _randomSpotStatus();
    return codes.map((code) => Spot(code: code, status: randomStat)).toList();
  }

  List<String> _buildFloorRange(String first, String last) {
    int parseFloor(String label) {
      if (label == 'G') return -1;
      if (label.startsWith('G')) return -int.parse(label.substring(1));
      return int.parse(label);
    }

    int start = parseFloor(first);
    int end = parseFloor(last);

    List<String> groundFloors = [];
    List<String> upperFloors = [];

    List<int> allFloors = [];
    for (int i = start; i <= end; i++) {
      if (i == 0) continue;
      allFloors.add(i);
    }

    final groundOnly = allFloors.where((f) => f < 0).toList();
    final upperOnly = allFloors.where((f) => f > 0).toList();

    if (groundOnly.length == 1 && groundOnly.first == -1) {
      groundFloors.add('G');
    } else {
      for (int i = groundOnly.length - 1; i >= 0; i--) {
        groundFloors.add('G${i + 1}');
      }
    }

    for (int floor in upperOnly) {
      upperFloors.add(floor.toString());
    }

    return [...groundFloors, ...upperFloors];
  }

  List<Floor> generateFloors({
    required String firstFloor,
    required String lastFloor,
    int areaStep = 2,
  }) {
    List<Floor> floors = [];
    List<String> floorLabels = _buildFloorRange(firstFloor, lastFloor);

    int currentGroup = -1;
    int spotCounter = 1;

    for (int i = 0; i < floorLabels.length; i++) {
      String floorLabel = floorLabels[i];

      int group = i ~/ areaStep;

      if (group != currentGroup) {
        currentGroup = group;
        spotCounter = 1;
      }

      String area1 = String.fromCharCode(65 + group * 2);
      String area2 = String.fromCharCode(65 + group * 2 + 1);

      List<Area> areas = [
        Area(name: area1, spots: _generateSpots(area1, spotCounter)),
        Area(name: area2, spots: _generateSpots(area2, spotCounter)),
      ];

      spotCounter += 6;

      floors.add(Floor(number: floorLabel, areas: areas));
    }

    return floors;
  }

  SpotStatus _randomSpotStatus() {
    final double rand = _random.nextDouble();

    if (rand < 0.6) {
      return SpotStatus.free;
    } else if (rand < 0.9) {
      return SpotStatus.occupied;
    } else {
      return SpotStatus.booked;
    }
  }

  int _countFreeSpots(ParkingLot lot) {
    int count = 0;
    final now = DateTime.now();

    final openTime = DateTime(
      now.year,
      now.month,
      now.day,
      lot.openTime.hour,
      lot.openTime.minute,
    );

    final closeTimeRaw = DateTime(
      now.year,
      now.month,
      now.day,
      lot.closeTime.hour,
      lot.closeTime.minute,
    );

    // Jika jam tutup lebih kecil dari jam buka (berarti lintas hari)
    final closeTime =
        closeTimeRaw.isBefore(openTime)
            ? closeTimeRaw.add(const Duration(days: 1))
            : closeTimeRaw;

    final diffMinutes = closeTime.difference(openTime).inMinutes;
    final r = Random();

    for (var floor in lot.spots) {
      for (var area in floor.areas) {
        for (var spot in area.spots) {
          if (spot.status == SpotStatus.free) {
            count++;
          } else if (spot.status == SpotStatus.booked ||
              spot.status == SpotStatus.occupied) {
            final randomMinutes = r.nextInt(diffMinutes);
            spot.date = openTime.add(Duration(minutes: randomMinutes));
          }
        }
      }
    }

    return count;
  }
}

final LotFactory lotFactory = LotFactory();

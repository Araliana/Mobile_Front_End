import 'package:flutter/material.dart';
import 'package:tugas_front_end_nicolas/components/detail_component.dart';
import 'package:tugas_front_end_nicolas/model/parking_lot.dart';
import 'package:tugas_front_end_nicolas/utils/index.dart';

class BookingConfirm extends StatefulWidget {
  const BookingConfirm({
    required this.mall,
    required this.date,
    required this.time,
    required this.slot,
  });
  final ParkingLot mall;
  final String? date;
  final String? time;
  final String? slot;

  @override
  State<BookingConfirm> createState() => _BookingConfirmState();
}

class _BookingConfirmState extends State<BookingConfirm> {
  @override
  Widget build(BuildContext context) {
    final List<DetailItem> parkingArea = [
      DetailItem(label: "Parking Area", value: widget.mall.name),
      DetailItem(
        label: "Operate Time",
        value:
            "${timeToString(widget.mall.openTime)} - ${timeToString(widget.mall.closeTime)}",
      ),
      DetailItem(label: "Address", value: widget.mall.address),
    ];

    final List<DetailItem> rateData = [
      DetailItem(
        label: "Hourly Rate",
        value:
            "${formatCurrency(nominal: widget.mall.hourlyPrice, decimalPlace: 0)} / hour",
      ),
      DetailItem(
        label: "Entry Price",
        value: formatCurrency(
          nominal: widget.mall.starterPrice ?? widget.mall.hourlyPrice,
          decimalPlace: 0,
        ),
      ),
    ];
    final parts = widget.slot!.split("-");
    final List<DetailItem> bookDetail = [
      DetailItem(
        label: "Booked Spot",
        value: "${formatFloorLabel(parts[0])} (${parts[1]})",
      ),
      DetailItem(
        label: "Booking Date",
        value: formatDate(stringToDate(widget.date!)),
      ),
      DetailItem(label: "Booking Time", value: widget.time),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        DataCard(title: "Parking Area", listData: parkingArea),
        const SizedBox(height: 12),
        DataCard(title: "Price Booking", listData: rateData),
        const SizedBox(height: 12),
        DataCard(title: "Booking Detail", listData: bookDetail),
      ],
    );
  }
}

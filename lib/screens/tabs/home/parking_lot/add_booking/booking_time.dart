import 'package:flutter/material.dart';
import 'package:mobile_front_end/components/detail_component.dart';
import 'package:mobile_front_end/components/time_picker.dart';
import 'package:mobile_front_end/model/parking_lot.dart';
import 'package:mobile_front_end/utils/index.dart';
import 'package:mobile_front_end/utils/useform.dart';

class BookingTime extends StatefulWidget {
  const BookingTime({
    required this.mall,
    required this.setDate,
    required this.setTime,
    required this.date,
    required this.time,
  });
  final ParkingLot mall;
  final Function(String) setDate;
  final Function(String) setTime;
  final String? date;
  final String? time;

  @override
  State<BookingTime> createState() => _BookingTimeState();
}

class _BookingTimeState extends State<BookingTime> {
  final form = UseForm(fields: ["date", "time"]);

  @override
  void initState() {
    super.initState();
    form.control('date').text = (widget.date ?? "");
    form.control('time').text = (widget.time ?? "");
  }

  bool _checkBookingClose() {
    final now = DateTime.now();
    final oneHourFromNow = now.add(const Duration(hours: 1));

    final todayOpen = DateTime(
      now.year,
      now.month,
      now.day,
      widget.mall.openTime.hour,
      widget.mall.openTime.minute,
    );

    final todayClose = DateTime(
      now.year,
      now.month,
      now.day,
      widget.mall.closeTime.hour,
      widget.mall.closeTime.minute,
    );

    final isBeforeOpen = oneHourFromNow.isBefore(todayOpen);
    final isAfterClose = oneHourFromNow.isAfter(todayClose);

    return isBeforeOpen || isAfterClose;
  }

  DateTime _getMinDate() {
    final now = DateTime.now();

    if (_checkBookingClose()) {
      return DateTime(
        now.year,
        now.month,
        now.day,
      ).add(const Duration(days: 1));
    }

    return now;
  }

  TimeOfDay _calculateMinTime() {
    if (widget.date == null || widget.date!.isEmpty) {
      return widget.mall.openTime;
    }

    final selectedDate = stringToDate(widget.date!);
    final now = DateTime.now();

    final isToday =
        selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    if (isToday) {
      final oneHourFromNow = now.add(const Duration(hours: 1));
      return TimeOfDay(
        hour: oneHourFromNow.hour,
        minute: oneHourFromNow.minute,
      );
    } else {
      return widget.mall.openTime;
    }
  }

  DateTime _getSmartDefaultDateTime() {
    DateTime now = DateTime.now();
    int currentMinute = now.minute;
    int roundedMinute;
    int hourOffset = 0;

    if (_checkBookingClose()) {
      return DateTime(
        now.year,
        now.month,
        now.day,
        widget.mall.openTime.hour,
        widget.mall.openTime.minute,
      );
    }

    if (currentMinute < 5) {
      roundedMinute = 5;
      hourOffset = 1;
    } else if (currentMinute < 10) {
      roundedMinute = 10;
      hourOffset = 1;
    } else if (currentMinute < 15) {
      roundedMinute = 15;
      hourOffset = 1;
    } else if (currentMinute < 20) {
      roundedMinute = 20;
      hourOffset = 1;
    } else if (currentMinute < 25) {
      roundedMinute = 25;
      hourOffset = 1;
    } else if (currentMinute < 30) {
      roundedMinute = 30;
      hourOffset = 1;
    } else if (currentMinute < 35) {
      roundedMinute = 35;
      hourOffset = 1;
    } else if (currentMinute < 40) {
      roundedMinute = 40;
      hourOffset = 1;
    } else if (currentMinute < 45) {
      roundedMinute = 45;
      hourOffset = 1;
    } else if (currentMinute < 50) {
      roundedMinute = 50;
      hourOffset = 1;
    } else if (currentMinute < 55) {
      roundedMinute = 55;
      hourOffset = 1;
    } else {
      roundedMinute = 0;
      hourOffset = 2;
    }

    return DateTime(
      now.year,
      now.month,
      now.day,
      now.hour + hourOffset,
      roundedMinute,
    );
  }

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
      DetailItem(
        label: "Available Slots",
        value: widget.mall.getFreeCount().toString(),
      ),
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

    final List<DetailItem> timeInput = [
      DetailItem(
        label: "Booking Date",
        child: ResponsiveTimePicker(
          controller: form.control("date"),
          onChanged: widget.setDate,
          minDate: _getMinDate(),
        ),
      ),
      DetailItem(
        label: "Booking Time",
        child: ResponsiveTimePicker(
          controller: form.control("time"),
          disabled: widget.date == null || widget.date!.isEmpty,
          minTime: _calculateMinTime(),
          initialTime: _getSmartDefaultDateTime(),
          maxTime: widget.mall.closeTime,
          onChanged: widget.setTime,
          type: DatePickerType.time,
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        DataCard(title: "Parking Area", listData: parkingArea),
        const SizedBox(height: 12),
        DataCard(title: "Price Booking", listData: rateData),
        const SizedBox(height: 12),
        DataCard(title: "Select Time", listInput: timeInput),
      ],
    );
  }
}

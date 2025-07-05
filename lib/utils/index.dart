import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tugas_front_end_nicolas/model/history.dart';
import 'package:tugas_front_end_nicolas/provider/activity_provider.dart';
import 'package:tugas_front_end_nicolas/provider/language_provider.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

String translate(BuildContext context, String en, String id, String cn) {
  final langProvider = Provider.of<LanguageProvider>(context, listen: false);
  return langProvider.language == "EN"
      ? en
      : langProvider.language == "ID"
      ? id
      : cn;
}

String formatCurrency({
  required num nominal,
  int decimalPlace = 0,
  String symbol = "Rp.",
}) {
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: symbol,
    decimalDigits: decimalPlace,
  );
  return currencyFormat.format(nominal);
}

String timeToString(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return "$hour:$minute";
}

TimeOfDay stringToTime(String hhmm) {
  final parts = hhmm.split(":");
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}

DateTime stringToDate(String date, [String? time]) {
  TimeOfDay? ftime;
  if (time != null) {
    ftime = stringToTime(time);
  }
  final parts = date.split("/");
  final day = int.parse(parts[0]);
  final month = int.parse(parts[1]);
  final year = int.parse(parts[2]);
  return DateTime(year, month, day, ftime?.hour ?? 0, ftime?.minute ?? 0);
}

String formatDate(DateTime date) {
  return DateFormat('MMMM dd, yyyy', 'en_US').format(date);
}

String formatDateTime(DateTime date) {
  final datePart = DateFormat('dd MMMM yyyy, HH:mm', 'en_US').format(date);
  return datePart;
}

String formatTime(DateTime data) {
  final timePart = DateFormat('h.mm a').format(data);
  return timePart;
}

String formatPhone(String code, String phone) {
  String part1 = phone.length >= 4 ? phone.substring(0, 4) : phone;
  String part2 =
      phone.length >= 8
          ? phone.substring(4, 8)
          : (phone.length > 4 ? phone.substring(4) : '');
  String part3 = phone.length > 8 ? phone.substring(8) : '';

  final parts = [part1, part2, part3].where((p) => p.isNotEmpty).toList();
  final formattedPhone = parts.join('-');

  return '+$code $formattedPhone';
}

final key = enc.Key.fromUtf8('CYNVBEITS3E2VJYFAZEWSDEPKSF2V2TB');
final iv = enc.IV.fromLength(16);

String encryptQR(String plainText) {
  final encrypter = enc.Encrypter(enc.AES(key));
  final encrypted = encrypter.encrypt(plainText, iv: iv);
  return base64UrlEncode(encrypted.bytes);
}

String decryptQR(String encryptedBase64Url) {
  final encrypter = enc.Encrypter(enc.AES(key));
  final encryptedBytes = base64Url.decode(encryptedBase64Url);
  final encrypted = enc.Encrypted(encryptedBytes);
  return encrypter.decrypt(encrypted, iv: iv);
}

String formatDateTimeLabel(BuildContext context, DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inDays == 0) {
    if (difference.inHours == 0) {
      if (difference.inMinutes == 0) {
        return translate(context, "Just now", "Baru saja", "刚刚");
      }
      return "${difference.inMinutes}${translate(context, "m ago", "m lalu", "分钟前")}";
    }
    return "${difference.inHours}${translate(context, "h ago", "j lalu", "小时前")}";
  } else if (difference.inDays == 1) {
    return translate(context, "Yesterday", "Kemarin", "昨天");
  } else if (difference.inDays < 7) {
    return "${difference.inDays}${translate(context, "d ago", "h lalu", "天前")}";
  } else {
    return DateFormat("dd MMM yyyy").format(dateTime);
  }
}

String formatFloorLabel(String floor) {
  if (floor.startsWith('G')) {
    return "$floor Floor";
  }

  final num = int.tryParse(floor);
  if (num == null) return "$floor Floor";

  String suffix;
  if (num >= 11 && num <= 13) {
    suffix = "th";
  } else {
    switch (num % 10) {
      case 1:
        suffix = "st";
        break;
      case 2:
        suffix = "nd";
        break;
      case 3:
        suffix = "rd";
        break;
      default:
        suffix = "th";
    }
  }

  return "$num$suffix Floor";
}

String historyStatusToString(HistoryStatus status) =>
    status.toString().split('.').last;

HistoryStatus historyStatusFromString(String value) => HistoryStatus.values
    .firstWhere((e) => e.toString().split('.').last == value);

String activityTypeToString(ActivityType type) =>
    type.toString().split('.').last;

ActivityType activityTypeFromString(String value) => ActivityType.values
    .firstWhere((e) => e.toString().split('.').last == value);

Future<String> saveImageFile(File imageFile) async {
  final directory = await getApplicationDocumentsDirectory();

  final ext = p.extension(imageFile.path);
  final fileName = '${DateTime.now().millisecondsSinceEpoch}$ext';

  final savedImagePath = p.join(directory.path, fileName);

  await imageFile.copy(savedImagePath);

  return savedImagePath;
}

Future<void> deleteImage(String fileName) async {
  final dir = await getApplicationDocumentsDirectory();
  final filePath = p.join(dir.path, fileName);
  final file = File(filePath);

  if (await file.exists()) {
    await file.delete();
  }
}

String generateUnique({DateTime? dateTime, bool includeTime = false}) {
  final dt = dateTime ?? DateTime.now();

  final year = (dt.year % 100).toString().padLeft(2, '0');
  final month = dt.month.toString().padLeft(2, '0');
  final day = dt.day.toString().padLeft(2, '0');

  if (!includeTime) return '$year$month$day';

  final hour = dt.hour.toString().padLeft(2, '0');
  final minute = dt.minute.toString().padLeft(2, '0');

  return '$year$month$day$hour$minute';
}

String getStatusText(HistoryStatus status) {
  switch (status) {
    case HistoryStatus.pending:
      return "Booking Succeed";
    case HistoryStatus.fixed:
      return "Booking Confirmed"; // Tidak bisa dicancel lagi
    case HistoryStatus.entered:
      return "Currently Parking";
    case HistoryStatus.unresolved:
      return "Parking Overtime"; // Parking lebih dari waktu yang ditentukan
    case HistoryStatus.exited:
      return "Parking Completed";
    case HistoryStatus.cancel:
      return "Booking Canceled";
    case HistoryStatus.expired:
      return "Booking Expired";
  }
}

IconData getStatusIcon(HistoryStatus status) {
  switch (status) {
    case HistoryStatus.pending:
      return Icons.check_circle_outline;
    case HistoryStatus.fixed:
      return Icons.lock_outline;
    case HistoryStatus.entered:
      return Icons.local_parking_outlined;
    case HistoryStatus.unresolved:
      return Icons.warning_outlined; // Icon warning untuk overtime
    case HistoryStatus.exited:
      return Icons.exit_to_app;
    case HistoryStatus.cancel:
      return Icons.cancel_outlined;
    case HistoryStatus.expired:
      return Icons.schedule;
  }
}

Color getStatusColor(HistoryStatus status) {
  switch (status) {
    case HistoryStatus.pending:
      return const Color(0xFF4CAF50);
    case HistoryStatus.fixed:
      return const Color(0xFF607D8B);
    case HistoryStatus.entered:
      return const Color(0xFF2196F3);
    case HistoryStatus.unresolved:
      return const Color(0xFFFF5722);
    case HistoryStatus.exited:
      return const Color(0xFF9C27B0);
    case HistoryStatus.cancel:
      return const Color(0xFFF44336);
    case HistoryStatus.expired:
      return const Color(0xFFFF9800);
  }
}

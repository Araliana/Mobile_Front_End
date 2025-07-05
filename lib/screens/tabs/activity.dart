import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tugas_front_end_nicolas/model/user.dart';
import 'package:tugas_front_end_nicolas/provider/activity_provider.dart';
import 'package:tugas_front_end_nicolas/provider/history_provider.dart';
import 'package:tugas_front_end_nicolas/provider/user_provider.dart';
import 'package:tugas_front_end_nicolas/screens/tabs/park&book/history_detail.dart';
import 'package:tugas_front_end_nicolas/screens/tabs/park&book/history_list.dart';
import 'package:tugas_front_end_nicolas/utils/index.dart';
import 'package:tugas_front_end_nicolas/utils/snackbar.dart';

class Activity extends StatefulWidget {
  const Activity({super.key});

  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  String _getDateGroup(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (date == today) {
      return "Today";
    } else if (date == today.subtract(Duration(days: 1))) {
      return "Yesterday";
    } else if (date.isAfter(today.subtract(Duration(days: now.weekday - 1)))) {
      return "This Week";
    } else if (date.month == now.month && date.year == now.year) {
      return "This Month";
    } else {
      return "Earlier";
    }
  }

  String _getTranslatedDateGroup(BuildContext context, DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (date == today) {
      return translate(context, "Today", "Hari Ini", "今天");
    } else if (date == today.subtract(Duration(days: 1))) {
      return translate(context, "Yesterday", "Kemarin", "昨天");
    } else if (date.isAfter(today.subtract(Duration(days: now.weekday - 1)))) {
      return translate(context, "This Week", "Minggu Ini", "本周");
    } else if (date.month == now.month && date.year == now.year) {
      return translate(context, "This Month", "Bulan Ini", "本月");
    } else {
      return translate(context, "Earlier", "Sebelumnya", "更早");
    }
  }

  Map<String, List<ActivityItem>> _groupActivitiesByDate(
    List<ActivityItem> activitys,
  ) {
    Map<String, List<ActivityItem>> grouped = {};

    for (var activity in activitys) {
      String dateKey = _getDateGroup(activity.date);

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(activity);
    }

    // Sort activitys within each group by time (newest first)
    grouped.forEach((key, activitys) {
      activitys.sort((a, b) => b.date.compareTo(a.date));
    });

    return grouped;
  }

  List<String> _getSortedDateKeys(Map<String, List<ActivityItem>> grouped) {
    List<String> keys = grouped.keys.toList();

    // Define the order of date groups
    const groupOrder = [
      "Today",
      "Yesterday",
      "This Week",
      "This Month",
      "Earlier",
    ];

    keys.sort((a, b) {
      int indexA = groupOrder.indexOf(a);
      int indexB = groupOrder.indexOf(b);

      if (indexA == -1) indexA = groupOrder.length;
      if (indexB == -1) indexB = groupOrder.length;

      return indexA.compareTo(indexB);
    });

    return keys;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    final userProvider = Provider.of<UserProvider>(context);
    User user = userProvider.currentUser!;
    final historyProvider = Provider.of<HistoryProvider>(context);
    historyProvider.checkAllStatus(user, context);
    final activityProvider = Provider.of<ActivityProvider>(context);

    UserActivity? activities = activityProvider.getActivity(user);
    final groupedactivitys = _groupActivitiesByDate(activities?.activity ?? []);
    final sortedDateKeys = _getSortedDateKeys(groupedactivitys);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          backgroundColor: Colors.white,
          color: const Color(0xFF1F1E5B),
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 2));
            setState(() {
              activities = activityProvider.getActivity(user);
            });
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                title: Text(
                  translate(context, 'Activities', 'Aktivitas', '活动'),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: isSmall ? 25 : 30,
                  ),
                ),
                centerTitle: true,
              ),
              SliverToBoxAdapter(
                child: Column(
                  children:
                      activities != null && activities.activity.isNotEmpty
                          ? [
                            for (String dateKey in sortedDateKeys) ...[
                              NotifTitle(
                                dateTitle: _getTranslatedDateGroup(
                                  context,
                                  groupedactivitys[dateKey]!.first.date,
                                ),
                              ),
                              ...groupedactivitys[dateKey]!.map(
                                (activity) => ActivityCard(activity: activity),
                              ),
                            ],
                          ]
                          : [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.7,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Transform.translate(
                                      offset: const Offset(0, 10),
                                      child: Opacity(
                                        opacity: 0.5,
                                        child: Image.asset(
                                          'assets/images/empty/activity_empty.png',
                                          width: isSmall ? 240 : 320,
                                          height: isSmall ? 240 : 320,
                                        ),
                                      ),
                                    ),
                                    Transform.translate(
                                      offset: const Offset(0, -5),
                                      child: Text(
                                        translate(
                                          context,
                                          'No activities done yet!',
                                          'Belum ada aktivitas dilakukan!',
                                          '尚未完成任何活动！',
                                        ),
                                        style: TextStyle(
                                          color: const Color(0xFFD3D3D3),
                                          fontWeight: FontWeight.w700,
                                          fontSize: isSmall ? 20 : 25,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotifTitle extends StatelessWidget {
  final String dateTitle;

  const NotifTitle({super.key, required this.dateTitle});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: [
          Divider(
            color: const Color.fromARGB(255, 214, 214, 214),
            thickness: 1,
            indent: 5,
          ),
          SizedBox(height: isSmall ? 5 : 10),
          Row(
            children: [
              SizedBox(width: 15),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  dateTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmall ? 16 : 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ActivityCard extends StatelessWidget {
  final ActivityItem activity;

  const ActivityCard({super.key, required this.activity});

  String _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.bookSuccess:
        return 'assets/images/icons/booking.png';
      case ActivityType.bookCancel:
        return 'assets/images/icons/cancel.png';
      case ActivityType.exitLot:
        return 'assets/images/icons/exit.png';
      case ActivityType.enterLot:
        return 'assets/images/icons/enter.png';
      case ActivityType.bookExp:
        return 'assets/images/icons/expired.png';
      case ActivityType.paySuccess:
        return 'assets/images/icons/payment.png';
      case ActivityType.verify:
        return 'assets/images/icons/verification.png';
      // case ActivityType.twoFactor:
      //   return 'assets/images/icons/locked.png';
      case ActivityType.topUp:
        return 'assets/images/icons/topup.png';
      case ActivityType.unresolved:
        return 'assets/images/icons/unresolved.png';
    }
  }

  String _cardTitle(BuildContext context, ActivityType type) {
    switch (type) {
      case ActivityType.bookSuccess:
        return translate(
          context,
          'Booking Successful!',
          'Pemesanan Berhasil!',
          '预订成功！',
        );
      case ActivityType.bookCancel:
        return translate(
          context,
          'Booking Booking Canceled',
          'Pemesanan Parkir Dibatalkan',
          '停车预订已取消',
        );
      case ActivityType.exitLot:
        return translate(
          context,
          'Exit Parking Lot',
          'Keluar Area Parkir',
          '离开停车场',
        );
      case ActivityType.enterLot:
        return translate(
          context,
          'Enter Parking Lot',
          'Masuk Area Parkir',
          '进入停车场',
        );
      case ActivityType.bookExp:
        return translate(
          context,
          'Booking Has Been Expired!',
          'Pemesanan Telah Kedaluwarsa!',
          '预订已过期！',
        );
      case ActivityType.paySuccess:
        return translate(
          context,
          'Payment Successful!',
          'Pembayaran Berhasil!',
          '付款成功！',
        );
      case ActivityType.verify:
        return translate(
          context,
          '2FA Now Set Up!',
          '2FA Terpasang!',
          '2FA 现已设置!',
        );
      // case ActivityType.twoFactor:
      //   return translate(
      //     context,
      //     'Protect your account with 2FA.',
      //     'Lindungi akun Anda dengan 2FA.',
      //     '使用 2FA 保护您的账户。',
      //   );
      case ActivityType.topUp:
        return translate(
          context,
          'Top Up Successful',
          'Top Up Berhasil',
          '充值成功！',
        );
      case ActivityType.unresolved:
        return translate(
          context,
          'Unresolved Parking!',
          'Parkir Tak Selesai!',
          '未解决的停车问题！',
        );
    }
  }

  String _cardDescription(BuildContext context, ActivityType type) {
    switch (type) {
      case ActivityType.bookSuccess:
        return translate(
          context,
          'Parking booking at ${activity.mall} was successfully booked!',
          'Pemesanan parkir di ${activity.mall} berhasil dipesan!',
          '在 ${activity.mall} 的停车预订已成功预订！',
        );
      case ActivityType.bookCancel:
        return translate(
          context,
          'You have canceled booking at ${activity.mall}',
          'Anda telah membatalkan parkir di ${activity.mall}',
          '您已取消在 ${activity.mall} 的停车',
        );
      case ActivityType.exitLot:
        return translate(
          context,
          'You have exited parking lot at ${activity.mall}',
          'Anda telah keluar dari area parkir di ${activity.mall}',
          '您已离开 ${activity.mall} 的停车场',
        );
      case ActivityType.enterLot:
        return translate(
          context,
          'You have entered parking lot at ${activity.mall}',
          'Anda telah masuk dari area parkir di ${activity.mall}',
          '您已从 ${activity.mall} 的停车场进入',
        );
      case ActivityType.bookExp:
        return translate(
          context,
          'You missed your booking, no-show fee was charged.',
          'Anda melewatkan pemesanan, denda akan dikenakan.',
          '您错过了预订，已收取缺席费用。',
        );
      case ActivityType.paySuccess:
        return translate(
          context,
          'Parking booking at ${activity.mall} was successfully paid',
          'Pemesanan parkir di ${activity.mall} berhasil dibayar',
          '在 ${activity.mall} 的停车预订已成功付款',
        );
      case ActivityType.verify:
        return translate(
          context,
          'Two Factor Authenticator set up successful!',
          'Autentikator Dua Faktor berhasil terpasang!',
          '双重身份验证器设置成功!',
        );
      // case ActivityType.twoFactor:
      //   return translate(
      //     context,
      //     'Account will be more secured with 2FA setup!',
      //     'Akun akan lebih aman dengan 2FA terpasang!',
      //     '设置 2FA 后帐户将更加安全!',
      //   );
      case ActivityType.topUp:
        return translate(
          context,
          'You have successfully topped up ${formatCurrency(nominal: activity.nominal as num)} via ${activity.method}.',
          'Kamu berhasil melakukan top up sebesar ${formatCurrency(nominal: activity.nominal as num)} melalui ${activity.method}.',
          '您已成功通过 ${activity.method} 充值 ${formatCurrency(nominal: activity.nominal as num)}。',
        );
      case ActivityType.unresolved:
        return translate(
          context,
          'Your parking at ${activity.mall} has exceeded 20 hour',
          'Parkir Anda di ${activity.mall} telah melebihi 20 jam',
          '您在 ${activity.mall} 的停车时间已超过20小时',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyProvider = Provider.of<HistoryProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    User user = userProvider.currentUser!;
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isSmall ? 15 : 20,
        vertical: isSmall ? 8 : 12,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        border: Border.all(color: const Color.fromARGB(255, 221, 221, 221)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 5,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            final history =
                activity.historyId != null
                    ? historyProvider.getHistoryDetail(
                      user,
                      activity.historyId!,
                    )
                    : null;
            final historyType =
                activity.historyId != null
                    ? activity.historyId!.startsWith("BOOK")
                        ? HistoryType.booking
                        : HistoryType.parking
                    : null;

            switch (activity.activityType) {
              case ActivityType.topUp:
                showFlexibleSnackbar(
                  context,
                  "Top-up of ${formatCurrency(nominal: activity.nominal!)} via ${activity.method}",
                );
                break;

              case ActivityType.paySuccess:
              case ActivityType.bookSuccess:
              case ActivityType.bookCancel:
              case ActivityType.bookExp:
              case ActivityType.unresolved:
              case ActivityType.exitLot:
              case ActivityType.enterLot:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryDetail(history!, historyType!),
                  ),
                );
                break;

              case ActivityType.verify:
                showFlexibleSnackbar(
                  context,
                  "Two-factor authentication has been set up",
                );
                break;
            }
          },
          child: Padding(
            padding: EdgeInsets.all(10),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Image.asset(
                _getActivityIcon(activity.activityType),
                width: isSmall ? 35 : 50,
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      _cardTitle(context, activity.activityType),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: isSmall ? 14 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    formatDateTimeLabel(context, activity.date),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: isSmall ? 10 : 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                _cardDescription(context, activity.activityType),
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: isSmall ? 12 : 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

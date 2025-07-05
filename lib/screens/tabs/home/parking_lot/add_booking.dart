import 'package:flutter/material.dart';
import 'package:mobile_front_end/screens/tabs/home/parking_lot/add_booking/booking_slot.dart';
import 'package:mobile_front_end/screens/tabs/home/parking_lot/add_booking/booking_time.dart';
import 'package:provider/provider.dart';
import 'package:mobile_front_end/components/button.dart';
import 'package:mobile_front_end/model/parking_lot.dart';
import 'package:mobile_front_end/model/user.dart';
import 'package:mobile_front_end/provider/activity_provider.dart';
import 'package:mobile_front_end/provider/history_provider.dart';
import 'package:mobile_front_end/provider/parking_lot_provider.dart';
import 'package:mobile_front_end/provider/user_provider.dart';
import 'package:mobile_front_end/screens/tabs/home/parking_lot/add_booking/booking_confirm.dart';
import 'package:mobile_front_end/screens/tabs/home/parking_lot/add_booking/booking_splash.dart';
import 'package:mobile_front_end/utils/dialog.dart';
import 'package:mobile_front_end/utils/index.dart';

class AddBooking extends StatefulWidget {
  const AddBooking(this.mall, {super.key});
  final ParkingLot mall;
  @override
  State<AddBooking> createState() => _AddBookingState();
}

class _AddBookingState extends State<AddBooking> {
  final PageController _controller = PageController();

  int currentPage = 0;
  bool isLoading = false;
  String? date;
  String? time;
  late String floor;
  String? slot;

  @override
  void initState() {
    super.initState();
    floor = widget.mall.renderAllSlot()[0].number;
    _controller.addListener(() {
      setState(() {
        currentPage = _controller.page!.round();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final lotProvider = Provider.of<ParkingLotProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    User user = userProvider.currentUser!;
    final historyProvider = Provider.of<HistoryProvider>(context);
    final activityProvider = Provider.of<ActivityProvider>(context);
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    bool validateDatetime() {
      final now = DateTime.now();

      final dateParts = date!.split('/');
      final day = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final year = int.parse(dateParts[2]);
      final hourParts = time!.split(':');
      final hour = int.parse(hourParts[0]);
      final minute = int.parse(hourParts[1]);

      final bookingTime = DateTime(year, month, day, hour, minute);

      final bookingDayOpen = DateTime(
        year,
        month,
        day,
        widget.mall.openTime.hour,
        widget.mall.openTime.minute,
      );

      final bookingDayClose = DateTime(
        year,
        month,
        day,
        widget.mall.closeTime.hour,
        widget.mall.closeTime.minute,
      );

      final isWithinOpenHours =
          !bookingTime.isBefore(bookingDayOpen) &&
          bookingTime.isBefore(bookingDayClose);

      final isSameDay =
          bookingTime.year == now.year &&
          bookingTime.month == now.month &&
          bookingTime.day == now.day;

      final isAtLeastOneHourFromNow =
          !isSameDay ||
          !bookingTime.isBefore(now.add(const Duration(hours: 1)));

      return isWithinOpenHours && isAtLeastOneHourFromNow;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEFF1F8),
      body: SafeArea(
        child: RefreshIndicator(
          backgroundColor: Colors.white,
          color: const Color(0xFF1F1E5B),
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 2));
            lotProvider.getAvailableSpot(widget.mall);
          },
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmall ? 4 : 8,
                  vertical: isSmall ? 5 : 10,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (currentPage == 0) {
                              Navigator.pop(context);
                            } else {
                              if (isLoading) {
                                return;
                              }
                              _controller.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          icon: Icon(
                            Icons.arrow_back_ios,
                            size: isSmall ? 25 : 30,
                          ),
                        ),
                        SizedBox(width: isSmall ? 0 : 8),
                        Text(
                          "Create Booking",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: isSmall ? 20 : 25,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // PageView for booking steps
                    SizedBox(
                      height:
                          isSmall
                              ? currentPage == 0
                                  ? 700
                                  : currentPage == 1
                                  ? 670
                                  : 600
                              : currentPage == 0
                              ? 760
                              : currentPage == 1
                              ? 720
                              : 680,
                      child: PageView(
                        controller: _controller,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          BookingTime(
                            date: date,
                            time: time,
                            mall: widget.mall,
                            setDate: (val) => setState(() => date = val),
                            setTime: (val) => setState(() => time = val),
                          ),
                          BookingSlot(
                            floor: floor,
                            slot: slot,
                            mall: widget.mall,
                            setFloor: (val) => setState(() => floor = val),
                            setSlot: (val) => setState(() => slot = val),
                          ),
                          BookingConfirm(
                            mall: widget.mall,
                            date: date,
                            time: time,
                            slot: slot,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Continue button
                    Center(
                      child: ResponsiveButton(
                        isLoading: isLoading,
                        fontWeight: FontWeight.w600,
                        onPressed:
                            (date?.isNotEmpty ?? false) &&
                                    (time?.isNotEmpty ?? false) &&
                                    currentPage == 0
                                ? () {
                                  if (validateDatetime()) {
                                    _controller.nextPage(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                  } else {
                                    showAlertDialog(
                                      context: context,
                                      title: "Invalid Booking Time",
                                      content: Text(
                                        "Please choose a time that is within the mall's operating hours and not in the past.",
                                        style: TextStyle(
                                          fontSize: isSmall ? 14 : 16,
                                          color: Colors.grey.shade700,
                                          height: 1.4,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      icon: Icons.warning_amber_rounded,
                                      color: Colors.orange,
                                    );
                                  }
                                }
                                : (slot?.isNotEmpty ?? false) &&
                                    currentPage == 1
                                ? () async {
                                  final parts = slot!.split("-");
                                  String floor = parts[0];
                                  String spot = parts[1];
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await Future.delayed(
                                    const Duration(seconds: 1),
                                  );
                                  setState(() {
                                    isLoading = false;
                                  });
                                  bool isFree =
                                      lotProvider.checkSpotStatus(
                                        lot: widget.mall,
                                        floorNumber: floor,
                                        spotCode: spot,
                                      ) ==
                                      SpotStatus.free;
                                  if (isFree) {
                                    _controller.nextPage(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                  } else {
                                    showAlertDialog(
                                      context: context,
                                      title: "Spot Has Been Occupied",
                                      content: Text(
                                        "The selected parking spot is already taken. Please choose a other booking spot.",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                          height: 1.4,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      icon: Icons.event_busy,
                                      color: Colors.redAccent,
                                    );
                                  }
                                }
                                : currentPage == 2
                                ? () async {
                                  if (!validateDatetime()) {
                                    showAlertDialog(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        setState(() {
                                          date = null;
                                          time = null;
                                        });
                                        _controller.animateToPage(
                                          0,
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeInOut,
                                        );
                                      },
                                      context: context,
                                      title: "Invalid Booking Time",
                                      content: Text(
                                        "Please choose a time that is within the mall's operating hours and not in the past.",
                                        style: TextStyle(
                                          fontSize: isSmall ? 14 : 16,
                                          color: Colors.grey.shade700,
                                          height: 1.4,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      icon: Icons.warning_amber_rounded,
                                      color: Colors.orange,
                                    );
                                    return;
                                  }
                                  final parts = slot!.split("-");
                                  String floor = parts[0];
                                  String spot = parts[1];
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await Future.delayed(
                                    const Duration(seconds: 1),
                                  );
                                  setState(() {
                                    isLoading = false;
                                  });
                                  bool isFree =
                                      lotProvider.checkSpotStatus(
                                        lot: widget.mall,
                                        floorNumber: floor,
                                        spotCode: spot,
                                      ) ==
                                      SpotStatus.free;
                                  if (!isFree) {
                                    showAlertDialog(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _controller.animateToPage(
                                          1,
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeInOut,
                                        );
                                      },
                                      context: context,
                                      title: "Spot Has Been Occupied",
                                      content: Text(
                                        "The selected parking spot is already taken. Please choose a other booking spot.",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                          height: 1.4,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      icon: Icons.event_busy,
                                      color: Colors.redAccent,
                                    );
                                    return;
                                  }
                                  final dateTime = stringToDate(date!, time);
                                  historyProvider.addBooking(
                                    user: user,
                                    lot: widget.mall,
                                    floor: floor,
                                    spot: spot,
                                    time: dateTime,
                                  );
                                  activityProvider.addActivity(
                                    user,
                                    ActivityItem(
                                      activityType: ActivityType.bookSuccess,
                                      mall: widget.mall.name,
                                    ),
                                  );
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BookingSplash(),
                                    ),
                                  );
                                }
                                : null,
                        text: currentPage == 2 ? "Confirm Booking" : "Continue",
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

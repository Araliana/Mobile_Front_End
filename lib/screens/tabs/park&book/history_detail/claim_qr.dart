import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tugas_front_end_nicolas/components/button.dart';
import 'package:tugas_front_end_nicolas/components/detail_component.dart';
import 'package:tugas_front_end_nicolas/components/history_card.dart';
import 'package:tugas_front_end_nicolas/model/booking.dart';
import 'package:tugas_front_end_nicolas/model/history.dart';
import 'package:tugas_front_end_nicolas/model/user.dart';
import 'package:tugas_front_end_nicolas/provider/activity_provider.dart';
import 'package:tugas_front_end_nicolas/provider/history_provider.dart';
import 'package:tugas_front_end_nicolas/provider/parking_lot_provider.dart';
import 'package:tugas_front_end_nicolas/provider/user_provider.dart';
import 'package:tugas_front_end_nicolas/screens/tabs/park&book/history_list.dart';
import 'package:tugas_front_end_nicolas/utils/dialog.dart';
import 'package:tugas_front_end_nicolas/utils/index.dart';

class ClaimQr extends StatefulWidget {
  final Booking history;
  final HistoryType type;

  const ClaimQr(this.history, this.type);

  @override
  State<ClaimQr> createState() => _ClaimQrState();
}

class _ClaimQrState extends State<ClaimQr> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    User user = userProvider.currentUser!;
    final historyProvider = Provider.of<HistoryProvider>(context);
    final lotProvider = Provider.of<ParkingLotProvider>(context);
    final activityProvider = Provider.of<ActivityProvider>(context);
    final isMember = user.checkStatusMember();
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          backgroundColor: Colors.white,
          color: const Color(0xFF1F1E5B),
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 2));
            historyProvider.checkStatus(user, widget.history);
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                leading: Padding(
                  padding: EdgeInsets.only(left: 12.0),
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.all(12),
                        elevation: 1,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                  ),
                ),
                elevation: 0,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: isSmall ? 12 : 24.0,
                    left: isSmall ? 12 : 24.0,
                    right: isSmall ? 12 : 24.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFFBFBFBF)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromRGBO(0, 0, 0, 0.25),
                              blurRadius: 5,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          'Booking QR Scan',
                          style: TextStyle(
                            fontSize: isSmall ? 30 : 35,
                            color: Color(0xFF1F1E5B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: isSmall ? 10 : 30),

                      GestureDetector(
                        onTap: () async {
                          if (isLoading) {
                            return;
                          }
                          final status = historyProvider.checkStatus(
                            user,
                            widget.history,
                          );
                          if (status == HistoryStatus.expired) {
                            showAlertDialog(
                              context: context,
                              title: "Booking Expired",
                              icon: Icons.schedule_outlined,
                              color: Colors.redAccent,
                              content: Text(
                                "Unfortunately, your booking has expired and can no longer be claimed. Please make a new booking if you still wish to reserve a parking spot.",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade800,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          setState(() {
                            isLoading = true;
                          });
                          await Future.delayed(
                            const Duration(milliseconds: 800),
                          );
                          historyProvider.claimBooking(user, widget.history);
                          lotProvider.claimSpot(
                            lot: widget.history.lot,
                            floorNumber: widget.history.floor,
                            spotCode: widget.history.code,
                          );
                          showAlertDialog(
                            context: context,
                            title: "You're All Set!",
                            icon: Icons.check_circle,
                            color: Colors.green.shade600,
                            content: Text(
                              "Thank you! Your booking has been successfully claimed.\nPlease proceed to your assigned spot:\n${formatFloorLabel(widget.history.floor)} (${widget.history.code}).",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade800,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            onPressed: () {
                              activityProvider.addActivity(
                                user,
                                ActivityItem(
                                  activityType: ActivityType.enterLot,
                                  mall: widget.history.lot.name,
                                  historyId: widget.history.id,
                                ),
                              );
                            },
                          );

                          setState(() {
                            isLoading = false;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(isSmall ? 8 : 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: QrImageView(
                            data: encryptQR(widget.history.id),
                            version: QrVersions.auto,
                            size: isSmall ? 190 : 220,
                            embeddedImage: const AssetImage(
                              'assets/images/logo_no_padding.png',
                            ),
                            embeddedImageStyle: const QrEmbeddedImageStyle(
                              size: Size(35, 35),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'Booking-ID: ${widget.history.id}',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: isSmall ? 14 : 16,
                        ),
                      ),
                      SizedBox(height: isSmall ? 10 : 20),

                      DetailCard(
                        listData: [
                          DetailItem(
                            label: "Booked Spot",
                            value:
                                '${formatFloorLabel(widget.history.floor)} (${widget.history.code})',
                          ),
                        ],
                      ),

                      SizedBox(height: isSmall ? 10 : 20),

                      DetailCard(
                        title: "Parking Details",
                        listData: [
                          DetailItem(
                            label: "Parking Area",
                            value: widget.history.lot.name,
                          ),
                          DetailItem(
                            label: "Address",
                            value: widget.history.lot.address,
                          ),
                          DetailItem(
                            label: 'Booking Time',
                            value: formatDateTime(widget.history.bookingTime),
                          ),
                          DetailItem(
                            label: 'Expired Time',
                            value: formatDateTime(
                              widget.history.bookingTime.add(
                                Duration(minutes: isMember ? 45 : 30),
                              ),
                            ),
                            color: Colors.red,
                          ),
                          DetailItem(
                            label: "Current Status",
                            child: StatusDisplay(widget.history.status),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmall ? 15 : 30),
                      if (widget.history.status != HistoryStatus.fixed)
                        ResponsiveButton(
                          isLoading: isLoading,
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });
                            final status = historyProvider.checkStatus(
                              user,
                              widget.history,
                            );
                            if (status == HistoryStatus.fixed) {
                              showAlertDialog(
                                context: context,
                                title: "Booking Confirmed!",
                                icon: Icons.lock_clock,
                                color: Colors.indigo,
                                content: Text(
                                  "Your booking has been confirmed and can no longer be canceled.",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade800,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                onPressed: () {
                                  activityProvider.addActivity(
                                    user,
                                    ActivityItem(
                                      activityType: ActivityType.enterLot,
                                      mall: widget.history.lot.name,
                                      historyId: widget.history.id,
                                    ),
                                  );
                                },
                              );
                              return;
                            }
                            await Future.delayed(const Duration(seconds: 1));
                            historyProvider.cancelBooking(user, widget.history);
                            lotProvider.freeSpot(
                              lot: widget.history.lot,
                              floorNumber: widget.history.floor,
                              spotCode: widget.history.code,
                            );
                            activityProvider.addActivity(
                              user,
                              ActivityItem(
                                activityType: ActivityType.bookCancel,
                                mall: widget.history.lot.name,
                                historyId: widget.history.id,
                              ),
                            );
                            setState(() {
                              isLoading = false;
                            });
                            showAlertDialog(
                              context: context,
                              title: "Booking Cancelled",
                              icon: Icons.cancel_outlined,
                              color: Colors.redAccent,
                              content: Text(
                                "Your booking has been successfully cancelled. We hope to see you again. Feel free to book another spot anytime.",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade800,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              onPressed: () {
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop();
                                activityProvider.addActivity(
                                  user,
                                  ActivityItem(
                                    activityType: ActivityType.bookCancel,
                                    mall: widget.history.lot.name,
                                    historyId: widget.history.id,
                                  ),
                                );
                              },
                            );
                          },
                          text: "Cancel Booking",
                        ),
                      SizedBox(height: isSmall ? 10 : 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

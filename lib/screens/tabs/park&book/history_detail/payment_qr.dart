import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tugas_front_end_nicolas/components/button.dart';
import 'package:tugas_front_end_nicolas/components/detail_component.dart';
import 'package:tugas_front_end_nicolas/components/history_card.dart';
import 'package:tugas_front_end_nicolas/model/history.dart';
import 'package:tugas_front_end_nicolas/model/parking.dart';
import 'package:tugas_front_end_nicolas/model/user.dart';
import 'package:tugas_front_end_nicolas/model/voucher.dart';
import 'package:tugas_front_end_nicolas/provider/activity_provider.dart';
import 'package:tugas_front_end_nicolas/provider/history_provider.dart';
import 'package:tugas_front_end_nicolas/provider/parking_lot_provider.dart';
import 'package:tugas_front_end_nicolas/provider/user_provider.dart';
import 'package:tugas_front_end_nicolas/screens/tabs/home/topup/topup.dart';
import 'package:tugas_front_end_nicolas/screens/tabs/park&book/history_list.dart';
import 'package:tugas_front_end_nicolas/screens/tabs/park&book/history_detail/payment.dart';
import 'package:tugas_front_end_nicolas/utils/dialog.dart';
import 'package:tugas_front_end_nicolas/utils/index.dart';

class PaymentQr extends StatefulWidget {
  final Parking history;
  final HistoryType type;

  const PaymentQr(this.history, this.type);

  @override
  State<PaymentQr> createState() => _PaymentQrState();
}

class _PaymentQrState extends State<PaymentQr> {
  bool isLoading = false;
  Voucher? voucher;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    User user = userProvider.currentUser!;
    final historyProvider = Provider.of<HistoryProvider>(context);
    final lotProvider = Provider.of<ParkingLotProvider>(context);
    final activityProvider = Provider.of<ActivityProvider>(context);
    final isBooking = widget.type == HistoryType.booking;
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    void payUp() async {
      setState(() {
        isLoading = true;
      });

      await Future.delayed(const Duration(seconds: 2));
      final status = historyProvider.checkStatus(user, widget.history);

      if (status == HistoryStatus.unresolved) {
        final history = historyProvider.resolveUnresolve(user, widget.history);
        if (history != null) {
          userProvider.purchase(history.total!, true);
        }
        activityProvider.addActivity(
          user,
          ActivityItem(
            activityType: ActivityType.exitLot,
            mall: history?.lot.name,
            historyId: history?.id,
          ),
        );
        activityProvider.addActivity(
          user,
          ActivityItem(
            activityType: ActivityType.paySuccess,
            mall: history?.lot.name,
            historyId: history?.id,
          ),
        );
      } else {
        final total = widget.history.calculateTotal(voucher);
        if (user.balance < total) {
          showAlertDialog(
            context: context,
            title: "Insufficient Balance",
            icon: Icons.account_balance_wallet_outlined,
            color: Colors.redAccent,
            content: Text(
              "Your current balance is insufficient to proceed. Please top up your balance to continue.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TopUpPage()),
                ),
          );

          setState(() {
            isLoading = false;
          });
          return;
        }
        final history = historyProvider.exitParking(
          user,
          widget.history,
          voucher,
        );
        if (history != null) {
          userProvider.purchase(history.total!);
        }
        activityProvider.addActivity(
          user,
          ActivityItem(
            activityType: ActivityType.exitLot,
            mall: history?.lot.name,
            historyId: history?.id,
          ),
        );
        showAlertDialog(
          context: context,
          title: "Payment Success",
          icon: Icons.check_circle_outline,
          color: Colors.blueAccent,
          content: Text(
            "Your payment has been completed successfully. Thank you for your transaction!",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        );
      }
      lotProvider.freeSpot(
        lot: widget.history.lot,
        floorNumber: widget.history.floor,
        spotCode: widget.history.code,
      );
      setState(() {
        isLoading = false;
      });
    }

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
                          '${isBooking ? "Booking" : "Parking"} QR Scan',
                          style: TextStyle(
                            fontSize: isSmall ? 30 : 35,
                            color: Color(0xFF1F1E5B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: isSmall ? 10 : 30),

                      GestureDetector(
                        onTap: () {
                          final status = historyProvider.checkStatus(
                            user,
                            widget.history,
                          );
                          if (status == HistoryStatus.unresolved) return;
                          payUp();
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
                        'Payment-ID: ${widget.history.id}',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: isSmall ? 14 : 16,
                        ),
                      ),
                      SizedBox(height: isSmall ? 10 : 20),

                      DetailCard(
                        listData: [
                          DetailItem(
                            label: "${isBooking ? "Booked" : "Parking"} Spot",
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
                            label: "Check-in Time",
                            value: formatDateTime(widget.history.checkinTime!),
                          ),
                          DetailItem(
                            label: "Current Duration",
                            value:
                                "${widget.history.calculateHour()} ${widget.history.calculateHour() == 1 ? 'hour' : 'hours'}",
                          ),
                          DetailItem(
                            label: "Current Status",
                            child: StatusDisplay(widget.history.status),
                          ),
                          if (voucher != null)
                            DetailItem(
                              label: "Voucher",
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                              value:
                                  "${voucher!.voucherName} (${voucher!.type == VoucherFlag.flat ? formatCurrency(nominal: voucher!.nominal as double) : "${voucher!.nominal!.toInt()}%"})",
                            ),
                        ],
                      ),
                      SizedBox(height: isSmall ? 15 : 30),
                      Row(
                        children: [
                          Expanded(
                            child: ResponsiveButton(
                              isLoading: isLoading,
                              onPressed: payUp,
                              backgroundColor: Color(0xFF7573EE),
                              text:
                                  widget.history.status ==
                                          HistoryStatus.unresolved
                                      ? "Resolved Now"
                                      : "Pay Now",
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: ResponsiveButton(
                              isLoading: isLoading,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => PaymentDetail(
                                          history: widget.history,
                                          type: widget.type,
                                          selectVoucher: voucher,
                                          onSelectVoucher: (val) {
                                            setState(() {
                                              voucher = val;
                                            });
                                          },
                                          onVoucherRemove: () {
                                            setState(() {
                                              voucher = null;
                                            });
                                          },
                                        ),
                                  ),
                                );
                              },
                              text: "Price Detail",
                            ),
                          ),
                        ],
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

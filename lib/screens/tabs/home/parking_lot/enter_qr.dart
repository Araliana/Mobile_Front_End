import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tugas_front_end_nicolas/model/parking_lot.dart';
import 'package:tugas_front_end_nicolas/components/detail_component.dart';
import 'package:tugas_front_end_nicolas/model/user.dart';
import 'package:tugas_front_end_nicolas/provider/activity_provider.dart';
import 'package:tugas_front_end_nicolas/provider/history_provider.dart';
import 'package:tugas_front_end_nicolas/provider/parking_lot_provider.dart';
import 'package:tugas_front_end_nicolas/provider/user_provider.dart';
import 'package:tugas_front_end_nicolas/screens/main_layout.dart';
import 'package:tugas_front_end_nicolas/screens/tabs/park&book/history_detail.dart';
import 'package:tugas_front_end_nicolas/screens/tabs/park&book/history_list.dart';
import 'package:tugas_front_end_nicolas/utils/dialog.dart';
import 'package:tugas_front_end_nicolas/utils/index.dart';

class EnterQR extends StatefulWidget {
  final ParkingLot mall;

  const EnterQR({super.key, required this.mall});

  @override
  State<EnterQR> createState() => _EnterQRState();
}

class _EnterQRState extends State<EnterQR> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final lotProvider = Provider.of<ParkingLotProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    User user = userProvider.currentUser!;
    final historyProvider = Provider.of<HistoryProvider>(context);
    final activityProvider = Provider.of<ActivityProvider>(context);
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    final String uniqueId =
        '${widget.mall.prefix}-${generateUnique(includeTime: true)}';

    return Scaffold(
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
                          'Parking QR Scan',
                          style: TextStyle(
                            fontSize: isSmall ? 30 : 35,
                            color: Color(0xFF1F1E5B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: isSmall ? 10 : 20),

                      GestureDetector(
                        onTap: () async {
                          if (!isLoading) {
                            setState(() {
                              isLoading = true;
                            });
                            await Future.delayed(
                              const Duration(milliseconds: 800),
                            );
                            Slot? slot = lotProvider.occupyNearestSpot(
                              widget.mall,
                              user,
                            );
                            if (slot != null) {
                              showAlertDialog(
                                context: context,
                                title: "Welcome, Please Enter!",
                                icon: Icons.check_circle_outline,
                                color: Colors.lightGreen,
                                content: Text(
                                  "Please proceed to your assigned spot:\n${formatFloorLabel(slot.floor)} (${slot.code}).",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade800,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                onPressed: () {
                                  final parking = historyProvider.addParking(
                                    user: user,
                                    lot: widget.mall,
                                    floor: slot.floor,
                                    code: slot.code,
                                  );
                                  activityProvider.addActivity(
                                    user,
                                    ActivityItem(
                                      activityType: ActivityType.enterLot,
                                      mall: widget.mall.name,
                                      historyId: parking.id,
                                    ),
                                  );
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              MainLayout(TabValue.parknbook),
                                    ),
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              HistoryList(HistoryType.parking),
                                    ),
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => HistoryDetail(
                                            parking,
                                            HistoryType.parking,
                                          ),
                                    ),
                                  );
                                },
                              );
                            } else {
                              showAlertDialog(
                                context: context,
                                title: "No Slot Available",
                                icon: Icons.error_outline,
                                color: Colors.deepOrange,
                                content: Text(
                                  "There are currently no available slots. Please enter and make a U-turn, then scan the QR code at the exit gate.",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade800,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }
                          }
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
                            data: encryptQR(uniqueId),
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
                        'Lot-ID: $uniqueId',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      SizedBox(height: isSmall ? 10 : 30),

                      DetailCard(
                        title: "Parking Details",
                        listData: [
                          DetailItem(
                            label: "Parking Area",
                            value: widget.mall.name,
                          ),
                          DetailItem(
                            label: "Address",
                            value: widget.mall.address,
                          ),
                          DetailItem(
                            label: "Available Slots",
                            value: widget.mall.getFreeCount().toString(),
                          ),
                        ],
                      ),
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

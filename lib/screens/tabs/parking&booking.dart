import 'package:flutter/material.dart';
import 'package:tugas_front_end_nicolas/screens/tabs/park&book/history_list.dart';
import 'package:tugas_front_end_nicolas/utils/index.dart';

class ParkingHistory extends StatelessWidget {
  const ParkingHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              title: Text(
                translate(
                  context,
                  'Parking & Booking',
                  'Parkir & Pemesanan',
                  '停车与预订',
                ),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: isSmall ? 25 : 30,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Divider(indent: 20, thickness: 1),
                  SizedBox(height: isSmall ? 0 : 40),
                  Padding(
                    padding: EdgeInsets.only(
                      left: isSmall ? 12 : 24,
                      right: isSmall ? 12 : 24,
                    ),
                    child: Column(
                      children: [
                        //Button Parking
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        HistoryList(HistoryType.parking),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF1F1E5B),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Padding(
                                  padding:
                                      isSmall
                                          ? EdgeInsets.all(10)
                                          : EdgeInsets.only(
                                            top: 50,
                                            left: 20,
                                            right: 20,
                                            bottom: 20,
                                          ),
                                  child: Image.asset(
                                    'assets/images/others/parking_view.png',
                                  ),
                                ),
                                Positioned(
                                  top: 10,
                                  left: 15,
                                  child: Text(
                                    translate(
                                      context,
                                      'Parking',
                                      'Parkir',
                                      '停车场',
                                    ),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: isSmall ? 20 : 25,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: isSmall ? 12 : 50),
                        // Button Booking
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        HistoryList(HistoryType.booking),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF1F1E5B),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Padding(
                                  padding:
                                      isSmall
                                          ? EdgeInsets.all(35)
                                          : EdgeInsets.only(
                                            top: 70,
                                            left: 20,
                                            right: 20,
                                            bottom: 30,
                                          ),
                                  child: Image.asset(
                                    'assets/images/others/booking_view.png',
                                  ),
                                ),
                                Positioned(
                                  top: 10,
                                  left: 15,
                                  child: Text(
                                    translate(
                                      context,
                                      'Booking',
                                      'Pemesanan',
                                      '预订',
                                    ),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
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
          ],
        ),
      ),
    );
  }
}

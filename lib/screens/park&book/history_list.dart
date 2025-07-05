import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tugas_front_end_nicolas/components/history_card.dart';
import 'package:tugas_front_end_nicolas/model/parking.dart';
import 'package:tugas_front_end_nicolas/model/user.dart';
import 'package:tugas_front_end_nicolas/provider/history_provider.dart';
import 'package:tugas_front_end_nicolas/provider/user_provider.dart';

enum HistoryType { parking, booking }

class HistoryList extends StatefulWidget {
  const HistoryList(this.type);
  final HistoryType type;

  @override
  State<HistoryList> createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  @override
  @override
  Widget build(BuildContext context) {
    final historyProvider = Provider.of<HistoryProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    User user = userProvider.currentUser!;
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    final isBooking = widget.type == HistoryType.booking;
    historyProvider.checkAllStatus(user, context);
    List<Parking> historyList =
        (isBooking
            ? historyProvider.getBooking(user)
            : historyProvider.getParking(user)) ??
        [];

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          backgroundColor: Colors.white,
          color: const Color(0xFF1F1E5B),
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 2));
            setState(() {
              historyList =
                  (isBooking
                      ? historyProvider.getBooking(user)
                      : historyProvider.getParking(user)) ??
                  [];
            });
          },
          child: CustomScrollView(
            slivers: <Widget>[
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
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: isSmall ? 20.0 : 25.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          isBooking ? "Bookings" : 'Parkings',
                          style: TextStyle(
                            fontSize: isSmall ? 30 : 36,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    if (historyList.isEmpty)
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
                                    'assets/images/empty/${isBooking ? "booking" : "parking"}_empty.png',
                                    width: isSmall ? 240 : 320,
                                    height: isSmall ? 240 : 320,
                                  ),
                                ),
                              ),
                              Transform.translate(
                                offset: const Offset(0, -5),
                                child: Text(
                                  isBooking
                                      ? "No booking is made yet"
                                      : "No parking is done yet",
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
                      )
                    else
                      ...historyList.map(
                        (item) => HistoryCard(item, widget.type),
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

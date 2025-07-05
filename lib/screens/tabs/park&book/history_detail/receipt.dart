import 'package:flutter/material.dart';
import 'package:tugas_front_end_nicolas/components/button.dart';
import 'package:tugas_front_end_nicolas/components/detail_component.dart';
import 'package:tugas_front_end_nicolas/components/history_card.dart';
import 'package:tugas_front_end_nicolas/model/booking.dart';
import 'package:tugas_front_end_nicolas/model/history.dart';
import 'package:tugas_front_end_nicolas/screens/tabs/home/parking_lot/lot_detail.dart';
import 'package:tugas_front_end_nicolas/screens/tabs/park&book/history_list.dart';
import 'package:tugas_front_end_nicolas/utils/index.dart';
import 'package:tugas_front_end_nicolas/model/parking.dart';

class Receipt extends StatefulWidget {
  final Parking history;
  final HistoryType type;

  const Receipt(this.history, this.type);

  @override
  State<Receipt> createState() => _ReceiptState();
}

class _ReceiptState extends State<Receipt> {
  @override
  Widget build(BuildContext context) {
    final isBooking = widget.type == HistoryType.booking;
    final booking =
        widget.history is Booking ? widget.history as Booking : null;

    final isMember = (booking ?? widget.history).isMember!;
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    final List<DetailItem> historyInfo = [
      DetailItem(label: 'Parking Area', value: widget.history.lot.name),
      DetailItem(label: 'Address', value: widget.history.lot.address),
      DetailItem(
        label: "${isBooking ? "Booked" : "Parking"} Spot",
        value:
            "${formatFloorLabel(widget.history.floor)} (${widget.history.code})",
      ),
      if (widget.history.status == HistoryStatus.exited) ...[
        DetailItem(
          label: 'Check-in Time',
          value: formatDateTime(widget.history.checkinTime!),
        ),
        DetailItem(
          label: 'Check-out Time',
          value: formatDateTime(widget.history.checkoutTime!),
          color: Colors.red,
        ),

        DetailItem(
          label: 'Duration',
          value:
              '${widget.history.hours} ${widget.history.hours == 1 ? 'hour' : 'hours'}',
        ),
      ],
    ];

    final List<DetailItem> prices = [
      if (widget.history.status == HistoryStatus.exited) ...[
        DetailItem(
          label: 'Amount',
          value: formatCurrency(nominal: widget.history.amount!),
        ),
        if (widget.history.voucher != null)
          DetailItem(
            label: "Voucher",
            value: formatCurrency(nominal: widget.history.voucher!),
            color: Colors.red,
          ),

        DetailItem(
          label: 'Taxes (11%)',
          value: formatCurrency(nominal: widget.history.tax!),
        ),
        DetailItem(
          label: 'Service Fee',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isMember)
                DiscountDisplay(6500, 0)
              else
                Text(
                  formatCurrency(nominal: 6500),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: isSmall ? 13 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          bottomBorder: true,
        ),
        if (widget.history.unresolvedFee != null &&
            widget.history.unresolvedFee != 0)
          DetailItem(
            label: "Unresolved Fee",
            value: formatCurrency(nominal: widget.history.unresolvedFee!),
            color: Colors.red,
          ),
        if (widget.history.total != null)
          DetailItem(
            label: 'Total',
            value: formatCurrency(nominal: widget.history.total!),
          ),
      ],
    ];

    final List<DetailItem> cancelInfo =
        booking != null
            ? [
              DetailItem(label: 'Parking Area', value: booking.lot.name),
              DetailItem(label: 'Address', value: booking.lot.address),
              DetailItem(
                label: 'Booking Spot',
                value: "${formatFloorLabel(booking.floor)} (${booking.code})",
              ),
              DetailItem(
                label: 'Booking Time',
                value: formatDateTime(booking.bookingTime),
              ),
              DetailItem(
                label: 'Expired Time',
                value: formatDateTime(
                  booking.bookingTime.add(
                    Duration(minutes: isMember ? 45 : 30),
                  ),
                ),
                color: Colors.red,
              ),
              DetailItem(label: "Status", child: StatusDisplay(booking.status)),
            ]
            : [];

    final List<DetailItem> cancelExpired =
        booking != null
            ? [
              DetailItem(
                label: 'Member Status',
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmall ? 6 : 12,
                    vertical: isSmall ? 3 : 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isMember ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isMember ? Icons.check_circle : Icons.cancel,
                        color: isMember ? Colors.green : Colors.red,
                        size: isSmall ? 12 : 18,
                      ),
                      SizedBox(width: isSmall ? 3 : 6),
                      Text(
                        isMember ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: isSmall ? 12 : null,
                          color:
                              isMember
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (booking.cancelTime != null)
                DetailItem(
                  label: 'Cancel Date',
                  value: formatDateTime(booking.cancelTime!),
                  color: Colors.red,
                ),
              if (booking.noshowFee != null)
                DetailItem(
                  label: 'No-Show Fee',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isMember)
                        DiscountDisplay(booking.noshowFee!, 0)
                      else
                        Text(
                          formatCurrency(nominal: booking.noshowFee!),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: isSmall ? 13 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
            ]
            : [];

    return Scaffold(
      backgroundColor: const Color(0xFFEFF1F8),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back_ios,
                            size: isSmall ? 25 : 30,
                          ),
                        ),
                        SizedBox(width: isSmall ? 0 : 8),
                        Text(
                          '${isBooking ? "Booking" : "Parking"} Receipt',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: isSmall ? 20 : 25,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (widget.history.status == HistoryStatus.cancel &&
                        booking != null) ...[
                      DataCard(listData: cancelInfo),
                      SizedBox(height: isSmall ? 10 : 20),
                      DataCard(listData: cancelExpired),
                      SizedBox(height: isSmall ? 40 : 140),
                    ] else if (widget.history.status == HistoryStatus.expired &&
                        booking != null) ...[
                      DataCard(listData: cancelInfo),
                      SizedBox(height: isSmall ? 10 : 20),
                      DataCard(listData: cancelExpired),
                      SizedBox(height: isSmall ? 40 : 140),
                    ] else if (widget.history.status ==
                        HistoryStatus.exited) ...[
                      DataCard(listData: historyInfo),
                      SizedBox(height: isSmall ? 10 : 20),
                      DataCard(listData: prices),
                      SizedBox(height: isSmall ? 20 : 140),
                    ],

                    ResponsiveButton(
                      text: 'View Parking Area',
                      fontWeight: FontWeight.w600,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    LotDetail(mall: widget.history.lot),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

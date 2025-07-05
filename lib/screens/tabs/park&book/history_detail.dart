import 'package:flutter/material.dart';
import 'package:mobile_front_end/model/booking.dart';
import 'package:mobile_front_end/model/parking.dart';
import 'package:mobile_front_end/model/user.dart';
import 'package:mobile_front_end/provider/history_provider.dart';
import 'package:mobile_front_end/provider/user_provider.dart';
import 'package:mobile_front_end/screens/tabs/park&book/history_detail/claim_qr.dart';
import 'package:mobile_front_end/screens/tabs/park&book/history_detail/payment_qr.dart';
import 'package:mobile_front_end/screens/tabs/park&book/history_detail/receipt.dart';
import 'package:mobile_front_end/screens/tabs/park&book/history_list.dart';
import 'package:provider/provider.dart';
import 'package:mobile_front_end/model/history.dart';

class HistoryDetail extends StatefulWidget {
  final Parking history;
  final HistoryType type;

  const HistoryDetail(this.history, this.type);

  @override
  State<HistoryDetail> createState() => _HistoryDetailState();
}

class _HistoryDetailState extends State<HistoryDetail> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    User user = userProvider.currentUser!;
    return Consumer<HistoryProvider>(
      builder: (context, provider, _) {
        provider.checkStatus(user, widget.history);
        final updatedHistory =
            provider.getHistoryDetail(user, widget.history.id)!;
        // updatedHistory.lot.spots.forEach((item) {
        //   item.areas.forEach((area) {
        //     area.spots.forEach((spot) {
        //       print(spot.code);
        //       print(spot.status);
        //       print("====");
        //     });
        //   });
        // });

        switch (updatedHistory.status) {
          case HistoryStatus.exited:
          case HistoryStatus.cancel:
          case HistoryStatus.expired:
            return Receipt(updatedHistory, widget.type);

          case HistoryStatus.entered:
          case HistoryStatus.unresolved:
            return PaymentQr(updatedHistory, widget.type);

          case HistoryStatus.pending:
          case HistoryStatus.fixed:
            return ClaimQr(updatedHistory as Booking, widget.type);
        }
      },
    );
  }
}

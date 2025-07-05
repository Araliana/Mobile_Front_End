import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tugas_front_end_nicolas/components/voucher_card.dart';
import 'package:tugas_front_end_nicolas/model/parking_lot.dart';
import 'package:tugas_front_end_nicolas/model/user.dart';
import 'package:tugas_front_end_nicolas/model/voucher.dart';
import 'package:tugas_front_end_nicolas/provider/voucher_provider.dart';
import 'package:tugas_front_end_nicolas/utils/index.dart';

class VoucherDialog extends StatefulWidget {
  const VoucherDialog({
    super.key,
    required this.lot,
    required this.hour,
    required this.user,
    required this.onSelectVoucher,
    required this.selectVoucher,
  });

  final ParkingLot lot;
  final int hour;
  final User user;
  final Function(Voucher) onSelectVoucher;
  final Voucher? selectVoucher;

  @override
  State<VoucherDialog> createState() => _VoucherDialogState();
}

class _VoucherDialogState extends State<VoucherDialog> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    final voucherProvider = Provider.of<VoucherProvider>(context);
    List<VoucherRemain> voucherRemain = voucherProvider.getAvailableRemain(
      widget.lot,
      widget.hour,
      widget.user,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          backgroundColor: Colors.white,
          color: const Color(0xFF1F1E5B),
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 2));
            setState(() {
              voucherRemain = voucherProvider.getAvailableRemain(
                widget.lot,
                widget.hour,
                widget.user,
              );
            });
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Header (tanpa lengkungan)
                    Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Judul voucher
                              Expanded(
                                child: Text(
                                  translate(
                                    context,
                                    'Available Voucher',
                                    'Voucher Tersedia',
                                    '可用优惠券',
                                  ),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: isSmall ? 24 : 28,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              // Tombol silang
                              IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.close),
                                iconSize: 28,
                                splashRadius: 24,
                                tooltip: 'Close',
                              ),
                            ],
                          ),
                        ),

                        Positioned(
                          top: 8,
                          child: Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children:
                        voucherRemain.isNotEmpty
                            ? voucherRemain
                                .map(
                                  (remain) => InkWell(
                                    onTap: () {
                                      widget.onSelectVoucher.call(
                                        remain.voucher,
                                      );
                                    },
                                    child: VoucherCard(
                                      isSelected:
                                          widget.selectVoucher ==
                                          remain.voucher,
                                      listRemainVoucher: remain,
                                    ),
                                  ),
                                )
                                .toList()
                            : [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.7,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Transform.translate(
                                        offset: const Offset(0, 10),
                                        child: Image.asset(
                                          'assets/images/empty/voucher_empty.png',
                                          width: isSmall ? 240 : 320,
                                          height: isSmall ? 240 : 320,
                                        ),
                                      ),
                                      Transform.translate(
                                        offset: const Offset(0, -5),
                                        child: Text(
                                          translate(
                                            context,
                                            'No Voucher Available!',
                                            'Tidak Ada Voucher Tersedia!',
                                            '无可用优惠券！',
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

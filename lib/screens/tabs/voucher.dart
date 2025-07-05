import 'package:flutter/material.dart';
import 'package:mobile_front_end/components/voucher_card.dart';
import 'package:mobile_front_end/model/voucher.dart';
import 'package:mobile_front_end/provider/voucher_provider.dart';
import 'package:mobile_front_end/utils/index.dart';
import 'package:provider/provider.dart';

class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key});

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    final voucherProvider = Provider.of<VoucherProvider>(context);
    List<Voucher> voucherList = voucherProvider.getAvailableVoucher();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          backgroundColor: Colors.white,
          color: const Color(0xFF1F1E5B),
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 2));
            setState(() {
              voucherList = voucherProvider.getAvailableVoucher();
            });
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                centerTitle: true,
                title: Text(
                  translate(
                    context,
                    'Available Voucher',
                    'Voucher Tersedia',
                    '可用优惠券',
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: isSmall ? 25 : 30,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children:
                        voucherList.isNotEmpty
                            ? voucherList
                                .map(
                                  (voucher) =>
                                      VoucherCard(listVoucher: voucher),
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

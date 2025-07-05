import 'package:flutter/material.dart';
import 'package:tugas_front_end_nicolas/model/voucher.dart';
import 'package:tugas_front_end_nicolas/provider/voucher_provider.dart';
import 'package:tugas_front_end_nicolas/utils/index.dart';

class VoucherCard extends StatelessWidget {
  final Voucher? listVoucher;
  final VoucherRemain? listRemainVoucher;
  final bool? isSelected;

  const VoucherCard({
    super.key,
    this.listVoucher,
    this.listRemainVoucher,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    final voucher = listVoucher ?? listRemainVoucher!.voucher;

    return Card(
      elevation: isSelected! ? 8 : 5,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color:
              isSelected!
                  ? const Color(0xFF1E1E61)
                  : const Color.fromARGB(255, 217, 217, 217),
          width: isSelected! ? 2 : 1,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        voucher.voucherName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmall ? 16 : 18,
                        ),
                      ),
                      Text(
                        "${translate(context, "Valid at", "Berlaku di", "适用于")} ${voucher.lot.name}",
                        style: TextStyle(fontSize: isSmall ? 12 : 14),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E61),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          voucher.type == VoucherFlag.free
                              ? "Free"
                              : "Disc ${voucher.type == VoucherFlag.percent
                                  ? "${(voucher.nominal!.toInt())}%"
                                  : voucher.type == VoucherFlag.free
                                  ? "Free"
                                  : (formatCurrency(nominal: voucher.nominal!))}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E61),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              voucher.maxUse == null
                                  ? translate(
                                    context,
                                    "Unlimited",
                                    "Tanpa Batas",
                                    "无限制",
                                  )
                                  : translate(
                                    context,
                                    'Max Uses ${voucher.maxUse!.toString()}',
                                    'Maks ${voucher.maxUse!.toString()} Kali',
                                    '最多使用${voucher.maxUse!.toString()}次',
                                  ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          if (voucher.minHour != null)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E61),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                translate(
                                  context,
                                  "Min ${voucher.minHour} Hours",
                                  "Min ${voucher.minHour} Jam",
                                  "最少${voucher.minHour}小时",
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          translate(
                            context,
                            'Valid Until ${formatDate(voucher.validUntil)}',
                            'Berlaku Hingga ${formatDate(voucher.validUntil)}',
                            '有效期至${formatDate(voucher.validUntil)}',
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    voucher.lot.image,
                    width: isSmall ? 100 : 120,
                    height: isSmall ? 100 : 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
          // Selection indicator
          if (isSelected!)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E1E61),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
            ),
        ],
      ),
    );
  }
}

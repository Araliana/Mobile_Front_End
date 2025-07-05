import 'package:flutter/material.dart';
import 'package:tugas_front_end_nicolas/screens/tabs/home/topup/topup_detail.dart';

class TopUpPage extends StatelessWidget {
  const TopUpPage({super.key});

  void _navigateToDetail(
    BuildContext context, {
    MethodType type = MethodType.transfer,
    required TopUpMethod method,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TopUpDetailPage(type: type, method: method),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    final List<TopUpMethod> bankList = [
      TopUpMethod(
        name: 'BRI',
        image: 'assets/images/topup/bri.png',
        prefix: '88888',
        steps: [
          'Login ke BRImo',
          'Pilih menu BRIVA',
          'Masukkan nomor VA dan nominal',
          'Konfirmasi dan bayar',
        ],
        adminFee: 1500.0,
        minTo: 10000.0,
      ),
      TopUpMethod(
        name: 'BCA',
        image: 'assets/images/topup/bca.png',
        prefix: '3901',
        steps: [
          'Login ke BCA Mobile',
          'Pilih m-Transfer',
          'Pilih BCA Virtual Account',
          'Masukkan nomor VA dan bayar',
        ],
        adminFee: 1000.0,
        minTo: 10000.0,
      ),
      TopUpMethod(
        name: 'Mandiri',
        image: 'assets/images/topup/mandiri.png',
        prefix: '70012',
        steps: [
          'Masuk ke Livin by Mandiri',
          'Pilih Bayar > Multipayment',
          'Masukkan VA dan jumlah',
          'Lanjutkan pembayaran',
        ],
        adminFee: 2500.0,
        minTo: 10000.0,
      ),
      TopUpMethod(
        name: 'CIMB',
        image: 'assets/images/topup/cimb.png',
        prefix: '2849',
        steps: [
          'Buka OCTO Mobile',
          'Pilih menu Pembayaran',
          'Input nomor Virtual Account',
          'Lakukan pembayaran',
        ],
        adminFee: 1000.0,
        minTo: 20000.0,
      ),
      TopUpMethod(
        name: 'OCBC',
        image: 'assets/images/topup/ocbc.png',
        prefix: '88810',
        steps: [
          'Buka OCBC app',
          'Klik menu pembayaran',
          'Input VA dan nominal',
          'Selesaikan transaksi',
        ],
        adminFee: 2500.0,
        minTo: 10000.0,
      ),
      TopUpMethod(
        name: 'Danamon',
        image: 'assets/images/topup/danamon.png',
        prefix: '8528',
        steps: [
          'Buka D-Bank PRO',
          'Pilih Virtual Account',
          'Masukkan detail pembayaran',
          'Konfirmasi dan bayar',
        ],
        adminFee: 5000.0,
        minTo: 10000.0,
      ),
      TopUpMethod(
        name: 'BNI',
        image: 'assets/images/topup/bni.png',
        prefix: '8808',
        steps: [
          'Masuk ke BNI Mobile Banking',
          'Pilih menu Transfer VA',
          'Masukkan nomor VA dan nominal',
          'Konfirmasi pembayaran',
        ],
        adminFee: 2500.0,
        minTo: 10000.0,
      ),
      TopUpMethod(
        name: 'Panin',
        image: 'assets/images/topup/panin.jpg',
        prefix: '9009',
        steps: [
          'Masuk aplikasi Panin',
          'Pilih Virtual Account',
          'Input nomor dan jumlah',
          'Selesaikan pembayaran',
        ],
        minTo: 10000.0,
      ),
    ];

    final List<TopUpMethod> cashList = [
      TopUpMethod(
        name: 'Alfamidi',
        image: 'assets/images/topup/alfamidi.png',
        prefix: 'ALMA',
        steps: [
          'Kunjungi gerai Alfamidi terdekat',
          'Tunjukkan barcode ke kasir',
          'Sebutkan nominal top up',
          'Bayar dan simpan struk sebagai bukti',
        ],
        adminFee: 2000.0,
        minTo: 20000.0,
      ),
      TopUpMethod(
        name: 'Indomaret',
        image: 'assets/images/topup/indomaret2.png',
        prefix: 'INDO',
        steps: [
          'Kunjungi gerai Indomaret terdekat',
          'Tunjukkan barcode ke kasir',
          'Sebutkan nominal top up',
          'Bayar dan simpan struk sebagai bukti',
        ],
        adminFee: 1500.0,
        minTo: 10000.0,
      ),
      TopUpMethod(
        name: 'Alfamart',
        image: 'assets/images/topup/alfamart.png',
        prefix: 'ALFA',
        steps: [
          'Kunjungi gerai Alfamart terdekat',
          'Tunjukkan barcode ke kasir',
          'Sebutkan nominal top up',
          'Bayar dan simpan struk sebagai bukti',
        ],
        adminFee: 2000.0,
        minTo: 10000.0,
      ),
      TopUpMethod(
        name: 'Superindo',
        image: 'assets/images/topup/superindo.png',
        prefix: 'SIND',
        steps: [
          'Kunjungi gerai Superindo terdekat',
          'Tunjukkan barcode ke kasir',
          'Sebutkan nominal top up',
          'Bayar dan simpan struk sebagai bukti',
        ],
        adminFee: 1000.0,
        minTo: 50000.0,
      ),
      TopUpMethod(
        name: 'Sevel',
        image: 'assets/images/topup/sevel.png',
        prefix: 'SVEN',
        steps: [
          'Kunjungi gerai Sevel terdekat',
          'Tunjukkan barcode ke kasir',
          'Sebutkan nominal top up',
          'Bayar dan simpan struk sebagai bukti',
        ],
        minTo: 10000.0,
      ),
      TopUpMethod(
        name: 'Family Mart',
        image: 'assets/images/topup/family mart.png',
        prefix: 'FMRT',
        steps: [
          'Kunjungi gerai Family Mart terdekat',
          'Tunjukkan barcode ke kasir',
          'Sebutkan nominal top up',
          'Bayar dan simpan struk sebagai bukti',
        ],
        adminFee: 2500.0,
        minTo: 10000.0,
      ),
      TopUpMethod(
        name: 'Lawson',
        image: 'assets/images/topup/lawson.png',
        prefix: 'LAWS',
        steps: [
          'Kunjungi gerai Lawson terdekat',
          'Tunjukkan barcode ke kasir',
          'Sebutkan nominal top up',
          'Bayar dan simpan struk sebagai bukti',
        ],
        adminFee: 2000.0,
        minTo: 10000.0,
      ),
      TopUpMethod(
        name: 'K3Mart',
        image: 'assets/images/topup/K3mart.png',
        prefix: 'K3MT',
        steps: [
          'Kunjungi gerai K3Mart terdekat',
          'Tunjukkan barcode ke kasir',
          'Sebutkan nominal top up',
          'Bayar dan simpan struk sebagai bukti',
        ],
        minTo: 50000.0,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Top Up Methods",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: isSmall ? 25 : 30,
          ),
        ),
        centerTitle: true,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Via Bank (Virtual Account)",
              style: TextStyle(
                fontSize: isSmall ? 20 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: EdgeInsets.only(
                left: 12,
                right: 12,
                top: 12,
                bottom: isSmall ? 0 : 30,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color.fromARGB(255, 229, 229, 229),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 4,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children:
                    bankList.map((bank) {
                      return GestureDetector(
                        onTap: () {
                          _navigateToDetail(context, method: bank);
                        },
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 6,
                              color: const Color.fromARGB(255, 228, 239, 255),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset(
                              bank.image,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Via Cash (Scan Barcode)",
              style: TextStyle(
                fontSize: isSmall ? 20 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: EdgeInsets.only(
                left: 12,
                right: 12,
                top: 12,
                bottom: isSmall ? 0 : 30,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: const Color.fromARGB(255, 229, 229, 229),
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 4,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children:
                    cashList.map((cash) {
                      return GestureDetector(
                        onTap: () {
                          _navigateToDetail(
                            context,
                            type: MethodType.cash,
                            method: cash,
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 6,
                              color: const Color.fromARGB(255, 228, 239, 255),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset(
                              cash.image,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TopUpMethod {
  final String name;
  final String image;
  final String prefix;
  final double? minTo;
  final double? adminFee;
  final List<String> steps;

  const TopUpMethod({
    required this.name,
    required this.image,
    required this.prefix,
    this.minTo,
    this.adminFee,
    required this.steps,
  });
}

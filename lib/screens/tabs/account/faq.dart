import 'package:flutter/material.dart';

class FAQ extends StatelessWidget {
  const FAQ({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    final List<FAQItem> faqList = [
      FAQItem(
        title: 'ℹ️ About Us',
        content: [
          'Park-ID is a smart parking app where you can book in advance or park instantly. '
              'Pay only for what you use — **simple**, **fast**, and **reliable**!',
        ],
      ),
      FAQItem(
        title: '📲 Booking & Payment',
        content: [
          "➤ Book in advance or walk in — no reservation needed.",
          "➤ You may pay upon exit, or pay first and exit using the **Mall QR code** — this avoids walk time from being counted.",
          "➤ A single user may create **multiple parkings/bookings** on different devices.",
          "➤ To make a new parkings/bookings, any over-limit or unresolved parkings/bookings **must be settled first**.",
          "➤ Booking must be made **at least 1 hour before** the desired parking time.",
          "➤ Booking time must fall within **mall operational hours**.",
        ],
      ),
      FAQItem(
        title: '🅿️ Parking Rules',
        content: [
          "➤ Parking fees start from your **entry time**, not booking time.",
          "➤ Entering early will **automatically claim** your booking.",
          "➤ Leaving before check-in time still counts as a **used** booking.",
          "➤ For best results, enter only when you’re **ready to park**.",
          "➤ You will only secure a parking spot **after scanning the entry QR code**.",
          "➤ If no slots are available upon scanning, you may exit immediately using the **same entry QR** — no fee will be charged.",
          "➤ If you exit before paying (by scanning the entry QR again), parking time will **continue to count** until manually resolved.",
          "➤ Each booking is valid for a maximum of **20 hours**. Unresolved sessions beyond this limit may incur a **penalty of Rp10,000**.",
        ],
      ),
      FAQItem(
        title: '🚫 Cancel & Expired',
        content: [
          '➤ Cancel **up to 30 Minutes** before your booking — no charge.',
          '➤ Booking expires if not checked in **within 30 minutes**.',
          '➤ A **no-show fee of 35% of the spot\'s max profit** applies.',
          '➤ If balance goes negative, you must **top up** to book again.',
        ],
      ),
      FAQItem(
        title: '🎯 Become a Member',
        content: [
          'Subscribe to a Monthly, Seasonal, or Annual Plan to unlock benefits:',
          '',
          '🎉 **Current Member Perks**',
          '✔️ No service fee.',
          '✔️ No-show fee and No Unresolved fee waived.',
          '✔️ Late check-in up to **45 minutes**.',
          '✔️ Cancel up to **15 minutes** before booking.',
          '',
          '🚀 **Coming Soon**',
          '✔️ Discounted parking rates.',
          '✔️ Exclusive promos & offers.',
          '',
          '💡 Being a member means more **flexibility**, more **savings**, and fewer **penalties**.',
        ],
      ),
      FAQItem(
        title: '💰 Top Up Balance',
        content: [
          '➤ Top up via **bank transfer**, **e-wallet**, or **credit card**.',
          '➤ Balance is used for **parking fees** and **no-show charges**.',
          '➤ If balance is negative, you’ll need to **top up** before booking.',
        ],
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Static Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/images/others/FAQ.png",
              fit: BoxFit.cover,
              color: Colors.white.withValues(alpha: 0.1),
              colorBlendMode: BlendMode.dstATop,
            ),
          ),

          CustomScrollView(
            slivers: [
              SliverAppBar(
                centerTitle: true,
                title: Text(
                  'FAQ',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: isSmall ? 25 : 30,
                  ),
                ),
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
                backgroundColor: Colors.transparent,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isSmall ? 10 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "(Frequently Asked Questions)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: isSmall ? 24 : 30,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ListView.builder(
                        padding: EdgeInsets.only(bottom: 0),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: faqList.length,
                        itemBuilder: (context, index) {
                          final item = faqList[index];
                          return Card(
                            margin: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: isSmall ? 6 : 16,
                            ),
                            elevation: 3,
                            color: const Color(0xFFF2F5FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ExpansionTile(
                              tilePadding: EdgeInsets.symmetric(horizontal: 16),
                              childrenPadding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 5,
                              ),
                              title: Text(
                                item.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSmall ? 16 : 20,
                                ),
                              ),
                              // Remove divider color and behavior by overriding theme
                              backgroundColor: Colors.transparent,
                              collapsedBackgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide.none,
                              ),
                              collapsedShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide.none,
                              ),
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isSmall ? 12 : 16,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Divider(height: 0),
                                      SizedBox(height: 10),
                                      ...item.content.map(
                                        (text) => Padding(
                                          padding: EdgeInsets.only(
                                            bottom: isSmall ? 4 : 8,
                                          ),
                                          child: Text.rich(
                                            TextSpan(
                                              children: _buildTextSpans(text),
                                            ),
                                            style: TextStyle(
                                              fontSize: isSmall ? 14 : 16,
                                              height: 1.5,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Image.asset(
                          "assets/images/starting/toy car turn right blue.png",
                          width: isSmall ? 150 : 250,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FAQItem {
  final String title;
  final List<String> content;

  FAQItem({required this.title, required this.content});
}

List<TextSpan> _buildTextSpans(String text) {
  final spans = <TextSpan>[];
  final regex = RegExp(r'\*\*(.*?)\*\*');
  int currentIndex = 0;

  for (final match in regex.allMatches(text)) {
    if (match.start > currentIndex) {
      spans.add(TextSpan(text: text.substring(currentIndex, match.start)));
    }
    spans.add(
      TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
    currentIndex = match.end;
  }

  if (currentIndex < text.length) {
    spans.add(TextSpan(text: text.substring(currentIndex)));
  }

  return spans;
}

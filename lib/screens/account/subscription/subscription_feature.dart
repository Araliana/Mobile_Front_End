import 'package:flutter/material.dart';

class SubscriptionFeature extends StatelessWidget {
  const SubscriptionFeature({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return Column(
      children: [
        Center(
          child: Text(
            'Get all the facilities by upgrading your account',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmall ? 15 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: isSmall ? 15 : 30),

        //Container
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFF2F5FF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Color(0xFF4D5DFA)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: isSmall ? 10 : 20),
              Center(
                child: Text(
                  'Join Membership',
                  style: TextStyle(
                    fontSize: isSmall ? 16 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: isSmall ? 25 : 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  '✅ Current Member Benefits',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmall ? 14 : 16,
                    color: Color(0xFF1F1E5B),
                  ),
                ),
              ),
              SizedBox(height: 10),
              ...[
                'No service fee',
                'No-show fee and Unresolved fee waived',
                'Extended late check-in window (up to 45 minutes late)',
                'Shorter cancellation deadline (cancel up to 15 minutes before)',
              ].map(
                (text) => Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: isSmall ? 5 : 8,
                    horizontal: isSmall ? 10 : 20,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_box,
                        size: isSmall ? 15 : 20,
                        color: Color(0xFF4D5DFA),
                      ),
                      SizedBox(width: isSmall ? 5 : 10),
                      Expanded(
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: isSmall ? 14 : 16,
                            color: Color(0xFF1F1E5B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: isSmall ? 20 : 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  '🔜 Coming Soon for Members',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmall ? 14 : 16,
                    color: Color(0xFF1F1E5B),
                  ),
                ),
              ),
              SizedBox(height: isSmall ? 10 : 20),
              ...[
                'Discounted hourly parking rates',
                'Exclusive promos and offers',
              ].map(
                (text) => Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: isSmall ? 5 : 8,
                    horizontal: isSmall ? 10 : 20,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.hourglass_bottom,
                        size: isSmall ? 15 : 20,
                        color: Colors.grey,
                      ),
                      SizedBox(width: isSmall ? 5 : 10),
                      Expanded(
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: isSmall ? 14 : 16,
                            color: Color(0xFF1F1E5B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: isSmall ? 25 : 50),
            ],
          ),
        ),
      ],
    );
  }
}

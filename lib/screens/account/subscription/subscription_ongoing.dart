import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tugas_front_end_nicolas/model/user.dart';
import 'package:tugas_front_end_nicolas/provider/user_provider.dart';

class SubscriptionOngoing extends StatelessWidget {
  const SubscriptionOngoing({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    User user = userProvider.currentUser!;
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    final dateFormat = DateFormat('dd MMMM yyyy');

    return Padding(
      padding: EdgeInsets.all(isSmall ? 24 : 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/popup/subscription.png',
              width: isSmall ? 180 : 260,
            ),
            const SizedBox(height: 24),
            Text(
              'Membership Ongoing',
              style: TextStyle(
                color: const Color(0xFF1F1E5B),
                fontSize: isSmall ? 24 : 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isSmall ? 10 : 20),
            Text(
              'You are currently an active member. Enjoy all your benefits!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF6C6C72),
                fontSize: isSmall ? 16 : 18,
              ),
            ),
            SizedBox(height: isSmall ? 20 : 24),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isSmall ? 30 : 45),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 235, 248, 255),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF1F1E5B), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Member Since".toUpperCase(),
                          style: TextStyle(
                            color: Color(0xFF6C6C72),
                            fontSize: isSmall ? 12 : 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          dateFormat.format(user.memberSince!),
                          style: TextStyle(
                            fontSize: isSmall ? 18 : 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F1E5B),
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      height: isSmall ? 30 : 36,
                      thickness: 1,
                      color: Color(0xFFE0E0E0),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Member Until".toUpperCase(),
                          style: TextStyle(
                            color: Color(0xFF6C6C72),
                            fontSize: isSmall ? 12 : 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          dateFormat.format(user.memberUntil!),
                          style: TextStyle(
                            fontSize: isSmall ? 18 : 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F1E5B),
                          ),
                        ),
                      ],
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

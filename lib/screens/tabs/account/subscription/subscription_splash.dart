import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tugas_front_end_nicolas/screens/main_layout.dart';

class SubscriptionSplash extends StatefulWidget {
  const SubscriptionSplash({super.key});

  @override
  State<SubscriptionSplash> createState() => _SubscriptionSplashState();
}

class _SubscriptionSplashState extends State<SubscriptionSplash> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (_, __, ___) => MainLayout(TabValue.profile),
          transitionsBuilder: (_, animation, __, child) {
            var tween = Tween(
              begin: const Offset(0, -1),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOut));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 30,
              vertical: isSmall ? 30 : 50,
            ),
            child: (Center(
              child: Column(
                    children: [
                      SizedBox(height: isSmall ? 20 : 60),
                      Image.asset(
                        'assets/images/popup/subscription.png',
                        width: isSmall ? 200 : 300,
                      ),
                      SizedBox(height: isSmall ? 20 : 40),
                      Text(
                        'Payment Success',
                        style: TextStyle(
                          color: Color(0xFF1F1E5B),
                          fontSize: isSmall ? 24 : 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Congrats, you have become our member',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF9C9CA0),
                          fontSize: isSmall ? 16 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                  .animate()
                  .slideY(begin: 1, end: 0, duration: 800.ms)
                  .fadeIn(duration: 800.ms),
            )),
          ),
        ),
      ),
    );
  }
}

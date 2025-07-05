import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tugas_front_end_nicolas/screens/main_layout.dart';

class BookingSplash extends StatefulWidget {
  const BookingSplash({super.key});

  @override
  State<BookingSplash> createState() => _BookingSplashState();
}

class _BookingSplashState extends State<BookingSplash> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (_, __, ___) => MainLayout(TabValue.home),
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
        (Route<dynamic> route) => false,
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
                      SizedBox(height: isSmall ? 50 : 150),
                      Image.asset(
                        'assets/images/popup/booking made.png',
                        width: isSmall ? 200 : 300,
                      ),
                      SizedBox(height: isSmall ? 10 : 20),
                      Text(
                        'Successful!',
                        style: TextStyle(
                          color: Color(0xFF4D5DFA),
                          fontSize: isSmall ? 28 : 32,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: isSmall ? 5 : 10),
                      Text(
                        'Successfully add booking detail',
                        style: TextStyle(
                          color: Color(0xFF666262),
                          fontSize: isSmall ? 18 : 20,
                          fontWeight: FontWeight.w600,
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

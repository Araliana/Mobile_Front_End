import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tugas_front_end_nicolas/utils/index.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4F4EA2), Color(0xFF9DAFEC), Color(0xFF4F4EA2)],
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.0,
              colors: [Colors.white.withValues(alpha: 0.1), Colors.transparent],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 243, 243, 243),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(30),
                        child: Image.asset(
                          'assets/images/logo_no_padding.png',
                          height: isSmall ? 150 : 225,
                        ),
                      ),
                    )
                    .animate()
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 24),

                Text(
                      'PARK-ID',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmall ? 32 : 48,
                        fontFamily: 'Koulen',
                        letterSpacing: 2.0,
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 3),
                            blurRadius: 8.0,
                            color: Colors.black.withValues(alpha: 0.6),
                          ),
                          Shadow(
                            offset: const Offset(0, 1),
                            blurRadius: 2.0,
                            color: Colors.black.withValues(alpha: 0.8),
                          ),
                        ],
                      ),
                    )
                    .animate(delay: 300.ms)
                    .slideY(
                      begin: 0.5,
                      end: 0,
                      duration: 700.ms,
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(duration: 1000.ms),

                Text(
                      translate(
                        context,
                        "Parking Made Easier",
                        "Parkir Jadi Lebih Mudah",
                        "停车更便捷",
                      ),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: isSmall ? 35 : 45,
                        fontFamily: 'Fasthand',
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 2),
                            blurRadius: 6.0,
                            color: Colors.black.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                    )
                    .animate(delay: 600.ms)
                    .slideY(
                      begin: 0.3,
                      end: 0,
                      duration: 600.ms,
                      curve: Curves.easeOut,
                    )
                    .fadeIn(duration: 600.ms)
                    .shimmer(duration: 3000.ms, delay: 1000.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tugas_front_end_nicolas/components/button.dart';
import 'package:tugas_front_end_nicolas/components/language_modal.dart';
import 'package:tugas_front_end_nicolas/provider/language_provider.dart';
import 'package:tugas_front_end_nicolas/screens/starting/sign_in.dart';
import 'package:tugas_front_end_nicolas/screens/starting/sign_up.dart';
import 'dart:math' as math;

import 'package:tugas_front_end_nicolas/utils/index.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return Scaffold(
      body: Stack(
        children: [
          // Top Rotated Box
          Positioned(
            top: isSmall ? -250 : -240,
            left: -100,
            child: Transform.rotate(
              angle: -15 * math.pi / 180,
              child: Container(
                width: size.width * 2,
                height: 300,
                color: const Color(0xFFD3DEFF),
              ),
            ),
          ),

          // Bottom Rotated Box
          Positioned(
            bottom: isSmall ? -250 : -240,
            right: -100,
            child: Transform.rotate(
              angle: -15 * math.pi / 180,
              child: Container(
                width: size.width * 2,
                height: 300,
                color: const Color(0xFFD3DEFF),
              ),
            ),
          ),

          Positioned(
            top: isSmall ? 30 : 50,
            right: 20,
            child: InkWell(
              onTap:
                  () => showModalBottomSheet(
                    context: context,
                    builder: (context) => LanguageModal(langProvider.language),
                  ),
              borderRadius: BorderRadius.circular(25),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          "assets/images/others/${langProvider.language.toLowerCase()}.png",
                          width: isSmall ? 24 : 36,
                        ),
                        Text(
                          langProvider.language,
                          style: TextStyle(
                            fontSize: isSmall ? 14 : 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: isSmall ? 14 : 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Container(
              child: Column(
                children: [
                  SizedBox(height: isSmall ? 80 : 120),
                  Text(
                    translate(
                      context,
                      'THIS IS PARK-ID',
                      "INI PARK-ID",
                      "这是公园标识",
                    ),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmall ? 36 : 48,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isSmall ? 10 : 0),
                    child: Text(
                      translate(
                        context,
                        'The first and the best parking app in Indonesia',
                        "Aplikasi parkir pertama dan terbaik di Indonesia",
                        "印度尼西亚第一个也是最好的停车应用程序",
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isSmall ? 20 : 30,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    'assets/images/starting/lot.png',
                    height: isSmall ? 200 : 280,
                    fit: BoxFit.contain,
                  ),
                  const Spacer(),
                  ResponsiveButton(
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SignIn()),
                        ),
                    text: translate(context, 'Sign In', "Masuk", "登入"),
                  ),
                  SizedBox(height: (isSmall ? 0 : 10)),
                  ResponsiveButton(
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SignUp()),
                        ),
                    text: translate(context, 'Sign Up', "Daftar", "报名"),
                    backgroundColor: Color(0xFF4D5DFA),
                  ),
                  SizedBox(height: isSmall ? 32 : 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

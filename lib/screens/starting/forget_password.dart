import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tugas_front_end_nicolas/components/button.dart';
import 'package:tugas_front_end_nicolas/components/text_input.dart';
import 'package:tugas_front_end_nicolas/model/user.dart';
import 'package:tugas_front_end_nicolas/provider/otp_provider.dart';
import 'package:tugas_front_end_nicolas/provider/user_provider.dart';
import 'package:tugas_front_end_nicolas/screens/starting/landing_screen.dart';
import 'package:tugas_front_end_nicolas/screens/starting/reset_password.dart';
import 'package:tugas_front_end_nicolas/components/verfy_account.dart';
import 'package:tugas_front_end_nicolas/utils/index.dart';
import 'package:tugas_front_end_nicolas/utils/snackbar.dart';
import 'package:tugas_front_end_nicolas/utils/useform.dart';
import 'package:tugas_front_end_nicolas/utils/validator.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final form = UseForm(
    fields: ["email"],
    validators: {'email': (value) => validateEmail(value: value)},
  );

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final otpProvider = Provider.of<OTPProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              leading: Padding(
                padding: EdgeInsets.only(left: 12.0),
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      if (form.isLoading) {
                        return;
                      }
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
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isSmall ? 12 : 24.0),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/starting/forget_pass.png',
                      height: isSmall ? 180 : 300,
                    ),
                    SizedBox(height: isSmall ? 10 : 20),
                    Text(
                      translate(
                        context,
                        'Forgot Your Password? Enter Your Email To Get OTP!',
                        "Lupa Kata Sandi Anda? Masukkan Email Anda untuk Mendapatkan OTP",
                        "忘记密码？输入邮箱地址获取一次性密码",
                      ),
                      style: TextStyle(
                        fontSize: isSmall ? 20 : 24,
                        color: Color(0xFF4083FF),
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            offset: Offset(4, 4),
                            blurRadius: 6.0,
                            color: Color.fromRGBO(64, 131, 255, 0.25),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isSmall ? 15 : 30),

                    // Email Field
                    Column(
                      children: [
                        ResponsiveTextInput(
                          isLoading: form.isLoading,
                          controller: form.control("email"),
                          hint: 'Enter your email',
                          label: 'Email',
                          type: TextInputTypes.email,
                          errorText: form.error("email"),
                          onChanged: (value) {
                            if (form.isSubmitted) {
                              setState(() {
                                form.validate();
                              });
                            }
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: isSmall ? 15 : 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Any Questions?',
                          style: TextStyle(
                            fontSize: isSmall ? 15 : 18,
                            shadows: [
                              Shadow(
                                offset: Offset(4, 4),
                                blurRadius: 6.0,
                                color: Color.fromRGBO(24, 45, 163, 0.25),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Chat With Us',
                          style: TextStyle(
                            fontSize: isSmall ? 15 : 18,
                            color: Color(0xFF1879D4),
                            shadows: [
                              Shadow(
                                offset: Offset(4, 4),
                                blurRadius: 6.0,
                                color: Color.fromRGBO(24, 45, 163, 0.25),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),

                    SizedBox(
                      height:
                          isSmall
                              ? 120
                              : form.error('email') == null
                              ? 200
                              : 185,
                    ),

                    ResponsiveButton(
                      isLoading: form.isLoading,
                      onPressed: () {
                        bool isValid = false;
                        setState(() {
                          form.isSubmitted = true;
                          isValid = form.validate();
                        });
                        if (isValid) {
                          setState(() => form.isLoading = true);
                          Future.delayed(const Duration(seconds: 2), () {
                            User? user = userProvider.findUserByEmail(
                              form.control("email").text,
                            );
                            if (user == null) {
                              showFlexibleSnackbar(
                                context,
                                "Email not found",
                                type: SnackbarType.error,
                              );
                              setState(() => form.isLoading = false);
                              return;
                            }
                            otpProvider.email = form.control("email").text;
                            otpProvider.generateOTP();
                            setState(() => form.isLoading = false);
                            showFlexibleSnackbar(
                              context,
                              "Your OTP is ${otpProvider.OTP}",
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => VerifyAccount(
                                      onSubmit: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => LandingScreen(),
                                          ),
                                        );
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    ResetPassword(user),
                                          ),
                                        );
                                      },
                                    ),
                              ),
                            );
                          });
                        }
                      },
                      text: translate(context, "Continue", "Lanjut", "继续"),
                    ),
                    SizedBox(height: isSmall ? 10 : 20),
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

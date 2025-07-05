import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tugas_front_end_nicolas/components/button.dart';
import 'package:tugas_front_end_nicolas/components/countdown.dart';
import 'package:tugas_front_end_nicolas/components/pin_input.dart';
import 'package:tugas_front_end_nicolas/provider/otp_provider.dart';
import 'package:tugas_front_end_nicolas/utils/index.dart';
import 'package:tugas_front_end_nicolas/utils/snackbar.dart';

class VerifyAccount extends StatefulWidget {
  const VerifyAccount({super.key, required this.onSubmit, this.successMessage});
  final VoidCallback onSubmit;
  final String? successMessage;

  @override
  State<VerifyAccount> createState() => _VerifyAccountState();
}

class _VerifyAccountState extends State<VerifyAccount> {
  bool isSubmitted = false;
  bool resending = false;
  bool isLoading = false;
  int count = 0;

  TextEditingController otpController = TextEditingController();
  final pinKey = GlobalKey<ResponsivePINInputState>();

  String? otpError;

  String obscureEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final name = parts[0];
    final domain = parts[1];

    if (name.length <= 2) {
      return '${'*' * name.length}@$domain';
    }

    final lastTwo = name.substring(name.length - 2);
    final obscured = '*' * (name.length - 2) + lastTwo;

    return '$obscured@$domain';
  }

  @override
  Widget build(BuildContext context) {
    final forgotPassProvider = Provider.of<OTPProvider>(context);
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    String email = obscureEmail(forgotPassProvider.email);

    bool validate() {
      final errorOtp = otpController.text == "" ? "OTP must be filled" : null;
      setState(() {
        otpError = errorOtp;
      });

      return errorOtp == null;
    }

    void verifyOTP() {
      setState(() {
        isSubmitted = true;
      });
      final isValid = validate();
      if (isValid) {
        setState(() => isLoading = true);
        Future.delayed(const Duration(seconds: 2), () {
          final otpValid = forgotPassProvider.validateOTP(otpController.text);
          if (otpValid) {
            showFlexibleSnackbar(
              context,
              widget.successMessage ??
                  "${translate(context, "OTP Valid", "OTP Valid", "OTP 有效")}!",
            );
            widget.onSubmit.call();
          } else {
            pinKey.currentState?.resetField();
            showFlexibleSnackbar(
              context,
              "${translate(context, "OTP Invalid", "OTP Tidak Valid", "OTP 无效")}!",
              type: SnackbarType.error,
            );
          }
          setState(() {
            isLoading = false;
          });
        });
      }
    }

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
                      if (isLoading) {
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
                      'assets/images/starting/otp_send.png',
                      height: isSmall ? 180 : 300,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          translate(context, "Verify", "Verifikasi", "验证"),
                          style: TextStyle(
                            fontSize: isSmall ? 20 : 30,
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
                          translate(context, "Account", "Akun", "账户"),
                          style: TextStyle(
                            fontSize: isSmall ? 20 : 30,
                            fontWeight: FontWeight.bold,
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

                    Column(
                      children: [
                        Text(
                          translate(
                            context,
                            "Please enter the code sent to",
                            "Silakan masukkan kode yang dikirim ke",
                            "请输入发送至",
                          ),
                          style: TextStyle(
                            fontSize: isSmall ? 15 : 18,
                            color: Color(0xFFBABABA),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: isSmall ? 15 : 18,
                            color: Color(0xFFBABABA),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),

                    SizedBox(height: isSmall ? 10 : 20),

                    // OTP Field
                    ResponsivePINInput(
                      isLoading: isLoading,
                      key: pinKey,

                      errorText: otpError,
                      controller: otpController,
                      onCompleted: (value) {
                        verifyOTP();
                      },
                    ),

                    SizedBox(height: isSmall ? 18 : 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          translate(
                            context,
                            "OTP not received?",
                            "OTP tidak diterima?",
                            "没有收到 OTP？",
                          ),
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

                        GestureDetector(
                          onTap: () {
                            if (!resending && count == 0 && !isLoading) {
                              setState(() => resending = true);
                              Future.delayed(const Duration(seconds: 2), () {
                                setState(() {
                                  resending = false;
                                  count = 10;
                                });
                                showFlexibleSnackbar(
                                  context,
                                  "${translate(context, "Your OTP is", "OTP Anda adalah", "您的一次性密码是")} ${forgotPassProvider.generateOTP()}",
                                );
                              });
                            }
                          },
                          child:
                              resending
                                  ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: isSmall ? 16 : 20,
                                        height: isSmall ? 16 : 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Color(0xFF1879D4),
                                              ),
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "${translate(context, "Resending", "Mengirim ulang", "重新发送")}...",
                                        style: TextStyle(
                                          fontSize: isSmall ? 15 : 18,
                                          color: Color(0xFF1879D4),
                                          shadows: [
                                            Shadow(
                                              offset: Offset(4, 4),
                                              blurRadius: 6.0,
                                              color: Color.fromRGBO(
                                                24,
                                                45,
                                                163,
                                                0.25,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                  : count == 0
                                  ? Text(
                                    translate(
                                      context,
                                      "Resend OTP",
                                      "Kirim ulang",
                                      "重新发送OTP",
                                    ),
                                    style: TextStyle(
                                      fontSize: isSmall ? 15 : 18,
                                      color: Color(0xFF1879D4),
                                      shadows: [
                                        Shadow(
                                          offset: Offset(4, 4),
                                          blurRadius: 6.0,
                                          color: Color.fromRGBO(
                                            24,
                                            45,
                                            163,
                                            0.25,
                                          ),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  )
                                  : CountdownTimer(
                                    countLong: count,
                                    countDownFunction:
                                        (int remain) => setState(() {
                                          count = remain;
                                        }),
                                    color: Color(0xFF1879D4),
                                  ),
                        ),
                      ],
                    ),

                    SizedBox(
                      height:
                          isSmall
                              ? otpError != null
                                  ? 95
                                  : 100
                              : otpError != null
                              ? 170
                              : 180,
                    ),

                    ResponsiveButton(
                      isLoading: isLoading,
                      onPressed: verifyOTP,
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

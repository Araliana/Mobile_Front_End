import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tugas_front_end_nicolas/components/button.dart';
import 'package:tugas_front_end_nicolas/components/text_input.dart';
import 'package:tugas_front_end_nicolas/components/verfy_account.dart';
import 'package:tugas_front_end_nicolas/model/user.dart';
import 'package:tugas_front_end_nicolas/provider/otp_provider.dart';
import 'package:tugas_front_end_nicolas/provider/user_provider.dart';
import 'package:tugas_front_end_nicolas/screens/starting/forget_password.dart';
import 'package:tugas_front_end_nicolas/screens/main_layout.dart';
import 'package:tugas_front_end_nicolas/screens/starting/landing_screen.dart';
import 'package:tugas_front_end_nicolas/screens/starting/sign_up.dart';
import 'package:tugas_front_end_nicolas/utils/index.dart';
import 'package:tugas_front_end_nicolas/utils/snackbar.dart';
import 'package:tugas_front_end_nicolas/utils/useform.dart';
import 'package:tugas_front_end_nicolas/utils/validator.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final form = UseForm(
    fields: ["email", "password"],
    validators: {
      'email': (value) => validateEmail(value: value),
      'password':
          (value) => validateBasic(key: 'Password', value: value, minLength: 8),
    },
  );

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final otpProvider = Provider.of<OTPProvider>(context);
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
              elevation: 0,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isSmall ? 12 : 24.0),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/starting/park_spot.png',
                      height: isSmall ? 240 : 360,
                    ),
                    SizedBox(height: isSmall ? 10 : 20),
                    Text(
                      '${translate(context, 'Back Again? Your Perfect Spot Awaits', "Sudah Kembali? Tempat Sempurna Anda Menanti", "又回来了？完美地点等你来")}!',
                      style: TextStyle(
                        fontSize: isSmall ? 20 : 24,
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
                    SizedBox(height: isSmall ? 10 : 20),

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
                        const SizedBox(height: 12),
                        ResponsiveTextInput(
                          isLoading: form.isLoading,
                          controller: form.control("password"),
                          hint: 'Enter your password',
                          label: 'Password',
                          type: TextInputTypes.password,
                          errorText: form.error("password"),
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

                    SizedBox(height: isSmall ? 10 : 20),

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
                          Future.delayed(const Duration(seconds: 2), () async {
                            User? user = userProvider.findUserByEmail(
                              form.control("email").text,
                            );
                            if (user == null ||
                                await userProvider.login(
                                      user,
                                      form.control("password").text,
                                    ) ==
                                    -1) {
                              showFlexibleSnackbar(
                                context,
                                "${translate(context, "Invalid Credential", "Kredensial Tidak Valid", "凭证无效")}!",
                                type: SnackbarType.error,
                              );
                              setState(() => form.isLoading = false);
                              return;
                            }
                            setState(() => form.isLoading = false);
                            if (user.twoFactor) {
                              otpProvider.email = user.email;
                              otpProvider.generateOTP();
                              showFlexibleSnackbar(
                                context,
                                "Your OTP is ${otpProvider.OTP}",
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => VerifyAccount(
                                        successMessage:
                                            "${translate(context, "Welcome Back", "Selamat Datang kembali", "欢迎回来")} ${user.fullname.split(" ")[0]}!",
                                        onSubmit: () {
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => MainLayout(),
                                            ),
                                            (Route<dynamic> route) => false,
                                          );
                                        },
                                      ),
                                ),
                              );
                            } else {
                              showFlexibleSnackbar(
                                context,
                                "${translate(context, "Welcome Back", "Selamat Datang kembali", "欢迎回来")} ${user.fullname.split(" ")[0]}!",
                              );
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MainLayout(),
                                ),
                                (Route<dynamic> route) => false,
                              );
                            }
                          });
                        }
                      },
                      text: translate(context, 'Sign In', "Masuk", "登入"),
                    ),

                    // Sign In Button
                    SizedBox(height: isSmall ? 10 : 20),

                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'Or',
                            style: TextStyle(color: Colors.grey, fontSize: 18),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey)),
                      ],
                    ),

                    SizedBox(height: isSmall ? 10 : 20),

                    Text(
                      'Haven’t Sign Up?',
                      style: TextStyle(
                        color: Color(0xFF10297F),
                        fontSize: isSmall ? 16 : 20,
                      ),
                    ),

                    ResponsiveButton(
                      isLoading: form.isLoading,
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LandingScreen(),
                          ),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUp()),
                        );
                      },
                      text: translate(context, 'Sign Up', "Daftar", "报名"),
                      buttonType: ButtonTypes.outline,
                    ),

                    SizedBox(height: isSmall ? 5 : 10),
                    // Forgot password text
                    GestureDetector(
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgetPassword(),
                            ),
                          ),
                      child: Text(
                        'Forget Password?',
                        style: TextStyle(
                          color: Color(0xFF10297F),
                          fontSize: isSmall ? 18 : 25,
                        ),
                      ),
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

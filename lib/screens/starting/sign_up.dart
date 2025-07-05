import 'package:flutter/material.dart';
import 'package:mobile_front_end/components/button.dart';
import 'package:mobile_front_end/components/text_input.dart';
import 'package:mobile_front_end/model/user.dart';
import 'package:mobile_front_end/provider/user_provider.dart';
import 'package:mobile_front_end/screens/starting/landing_screen.dart';
import 'package:mobile_front_end/screens/starting/sign_in.dart';
import 'package:mobile_front_end/screens/starting/user_data.dart';
import 'package:mobile_front_end/utils/index.dart';
import 'package:mobile_front_end/utils/snackbar.dart';
import 'package:mobile_front_end/utils/useform.dart';
import 'package:mobile_front_end/utils/validator.dart';
import 'package:provider/provider.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
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
                    Text(
                      translate(
                        context,
                        'WELCOME TO PARK-ID!',
                        "SELAMAT DATANG DI PARK-ID",
                        "欢迎来到 PARK-ID",
                      ),
                      style: TextStyle(
                        fontSize: isSmall ? 30 : 50,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFA03CDD),
                        shadows: [
                          Shadow(
                            offset: Offset(4, 4),
                            blurRadius: 6.0,
                            color: Color.fromARGB(90, 11, 145, 255),
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      'assets/images/starting/enter_park.png',
                      height: isSmall ? 240 : 360,
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
                          Future.delayed(const Duration(seconds: 2), () {
                            User? user = userProvider.findUserByEmail(
                              form.control("email").text,
                            );
                            if (user != null) {
                              showFlexibleSnackbar(
                                context,
                                "${translate(context, "Email already used", "Email sudah terpakai", "电子邮件已被使用")}!",
                                type: SnackbarType.error,
                              );
                              setState(() => form.isLoading = false);
                              return;
                            }
                            setState(() => form.isLoading = false);
                            showFlexibleSnackbar(
                              context,
                              "${translate(context, "Email is available", "Email belum terpakai", "电子邮件可用")}!",
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        UserData(form.control("email").text),
                              ),
                            );
                          });
                        }
                      },
                      text: translate(context, 'Sign Up', "Daftar", "报名"),
                    ),
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
                      'Already Sign Up?',
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
                          MaterialPageRoute(builder: (context) => SignIn()),
                        );
                      },
                      buttonType: ButtonTypes.outline,
                      text: translate(context, 'Sign In', "Masuk", "登入"),
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

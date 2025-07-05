import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tugas_front_end_nicolas/components/button.dart';
import 'package:tugas_front_end_nicolas/components/text_input.dart';
import 'package:tugas_front_end_nicolas/model/user.dart';
import 'package:tugas_front_end_nicolas/provider/user_provider.dart';
import 'package:tugas_front_end_nicolas/screens/starting/sign_in.dart';
import 'package:tugas_front_end_nicolas/utils/index.dart';
import 'package:tugas_front_end_nicolas/utils/snackbar.dart';
import 'package:tugas_front_end_nicolas/utils/useform.dart';
import 'package:tugas_front_end_nicolas/utils/validator.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword(this.user, {super.key});
  final User user;

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final form = UseForm(
    fields: ["password", "conpassword"],
    validators: {"password": (value) => validatePassword(value: value)},
    match: {
      "password": [
        {"key": "conpassword", "label": "Confirm Password"},
      ],
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
                    Center(
                      child: Text(
                        'Please Input Your New Password',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isSmall ? 25 : 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFA03CDD),
                          shadows: [
                            Shadow(
                              offset: Offset(4, 4),
                              blurRadius: 6.0,
                              color: Color.fromRGBO(117, 53, 166, 0.25),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Image.asset(
                      'assets/images/starting/reset_password.png',
                      height: isSmall ? 180 : 300,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmall ? 20 : 0,
                      ),
                      child: Center(
                        child: Text(
                          'Your new password must not be the same from previous password',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isSmall ? 14 : 18,
                            color: Color(0xFF7B7B7B),
                            shadows: [
                              Shadow(
                                offset: Offset(4, 4),
                                blurRadius: 6.0,
                                color: Color.fromRGBO(100, 100, 100, 0.251),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: isSmall ? 10 : 20),

                    Column(
                      children: [
                        ResponsiveTextInput(
                          isLoading: form.isLoading,
                          controller: form.control("password"),
                          hint: 'Enter Password',
                          label: 'Password',
                          type: TextInputTypes.password,
                          errorText: form.error('password'),
                          onChanged: (value) {
                            if (form.isSubmitted) {
                              setState(() {
                                form.validate();
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        ResponsiveTextInput(
                          isLoading: form.isLoading,
                          controller: form.control("conpassword"),
                          hint: 'Enter Confirm Password',
                          label: 'Confirm Password',
                          type: TextInputTypes.password,
                          errorText: form.error('conpassword'),
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

                    SizedBox(
                      height:
                          isSmall
                              ? form.error('password') == null
                                  ? 60
                                  : 30
                              : form.error('password') == null
                              ? 150
                              : 110,
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
                            int success = userProvider.resetPassword(
                              widget.user,
                              form.control("password").text,
                            );
                            if (success == 0) {
                              showFlexibleSnackbar(
                                context,
                                "${translate(context, "Password can not be the same as old one", "Kata sandi tidak boleh sama dengan yang lama", "密码不能与旧密码相同")}!",
                                type: SnackbarType.error,
                              );
                              setState(() => form.isLoading = false);
                              return;
                            }
                            setState(() => form.isLoading = false);
                            showFlexibleSnackbar(
                              context,
                              "${translate(context, "Password has been reseted", "Kata sandi telah disetel ulang", "密码已重置")}!",
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignIn()),
                            );
                          });
                        }
                      },
                      text: translate(context, "Continue", "Lanjut", "继续"),
                    ),
                    SizedBox(height: isSmall ? 5 : 20),
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

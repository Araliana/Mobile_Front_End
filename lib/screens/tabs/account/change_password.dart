import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tugas_front_end_nicolas/components/button.dart';
import 'package:tugas_front_end_nicolas/components/text_input.dart';
import 'package:tugas_front_end_nicolas/provider/user_provider.dart';
import 'package:tugas_front_end_nicolas/utils/snackbar.dart';
import 'package:tugas_front_end_nicolas/utils/useform.dart';
import 'package:tugas_front_end_nicolas/utils/validator.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final UseForm form = UseForm(
    fields: ["oldPassword", "newPassword", "confPassword"],
    validators: {
      "oldPassword":
          (value) => validateBasic(
            key: 'Current Password',
            value: value,
            minLength: 8,
          ),
      "newPassword":
          (value) => validatePassword(key: "New Paswword", value: value),
    },
    match: {
      "newPassword": [
        {"key": "confPassword", "label": "Confirm Password"},
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
              elevation: 0,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isSmall ? 12 : 24.0),
                child: Column(
                  children: [
                    Text(
                      'Please Input Both Old and New Password!',
                      style: TextStyle(
                        fontSize: isSmall ? 20 : 24,
                        color: Color(0xFF91AFFF),
                        fontWeight: FontWeight.w800,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 3.5),
                            blurRadius: 2.0,
                            color: Color(0x3E182DA3),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Image.asset(
                      "assets/images/starting/change_pass.png",
                      height: isSmall ? 180 : 300,
                    ),
                    SizedBox(height: isSmall ? 10 : 20),
                    ResponsiveTextInput(
                      isLoading: form.isLoading,
                      controller: form.control("oldPassword"),
                      hint: 'Enter Current password',
                      label: 'Current Password',
                      type: TextInputTypes.password,
                      errorText: form.error("oldPassword"),
                      onChanged: (value) {
                        if (form.isSubmitted) {
                          setState(() {
                            form.validate();
                          });
                        }
                      },
                    ),
                    SizedBox(height: isSmall ? 10 : 20),
                    ResponsiveTextInput(
                      isLoading: form.isLoading,
                      controller: form.control("newPassword"),
                      hint: 'Enter New password',
                      label: 'New Password',
                      type: TextInputTypes.password,
                      errorText: form.error("newPassword"),
                      onChanged: (value) {
                        if (form.isSubmitted) {
                          setState(() {
                            form.validate();
                          });
                        }
                      },
                    ),
                    SizedBox(height: isSmall ? 10 : 20),
                    ResponsiveTextInput(
                      controller: form.control("confPassword"),
                      hint: 'Enter Confirm Password',
                      label: 'Confirm Password',
                      type: TextInputTypes.password,
                      errorText: form.error("confPassword"),
                      onChanged: (value) {
                        if (form.isSubmitted) {
                          setState(() {
                            form.validate();
                          });
                        }
                      },
                    ),
                    SizedBox(height: isSmall ? 40 : 70),

                    ResponsiveButton(
                      backgroundColor: const Color(0xFF1F1E5B),

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
                            int success = userProvider.changePassword(
                              form.control("oldPassword").text,
                              form.control("newPassword").text,
                            );
                            if (success == -1) {
                              showFlexibleSnackbar(
                                context,
                                "Current Password is not match!",
                                type: SnackbarType.error,
                              );
                              setState(() => form.isLoading = false);
                              return;
                            }
                            if (success == 0) {
                              showFlexibleSnackbar(
                                context,
                                "Password can not be the same as old one!",
                                type: SnackbarType.error,
                              );
                              setState(() => form.isLoading = false);
                              return;
                            }
                            setState(() => form.isLoading = false);
                            showFlexibleSnackbar(
                              context,
                              "Password has been changed!",
                            );
                            Navigator.pop(context);
                          });
                        }
                      },
                      text: "Change Password",
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

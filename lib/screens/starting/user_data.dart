import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_front_end/components/avatar_picker.dart';
import 'package:mobile_front_end/components/button.dart';
import 'package:mobile_front_end/components/phone_input.dart';
import 'package:mobile_front_end/components/text_input.dart';
import 'package:mobile_front_end/model/user.dart';
import 'package:mobile_front_end/provider/user_provider.dart';
import 'package:mobile_front_end/screens/main_layout.dart';
import 'package:mobile_front_end/utils/index.dart';
import 'package:mobile_front_end/utils/snackbar.dart';
import 'package:mobile_front_end/utils/useform.dart';
import 'package:mobile_front_end/utils/validator.dart';
import 'package:provider/provider.dart';

class UserData extends StatefulWidget {
  const UserData(this.email, {super.key});
  final String email;

  @override
  State<UserData> createState() => _UserDataState();
}

class _UserDataState extends State<UserData> {
  String country_code = "ID";
  File? profileImg;

  final form = UseForm(
    fields: ["fullname", "phone", "password", "conpassword"],
    validators: {
      "fullname": (value) => validateBasic(key: "Fullname", value: value),
      "phone":
          (value) => validateBasic(
            key: "Phone Number",
            value: value,
            minLength: 7,
            maxLength: 12,
          ),
      "password": (value) => validatePassword(value: value),
    },
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
              elevation: 0,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isSmall ? 12 : 24.0),
                child: Column(
                  children: [
                    Text(
                      translate(context, "USER DATA", "DATA PENGGUNA", "用户数据"),
                      style: TextStyle(
                        fontSize: isSmall ? 35 : 50,
                        color: Color(0xFF2C39B8),
                        shadows: [
                          Shadow(
                            offset: Offset(4, 4),
                            blurRadius: 6.0,
                            color: Color.fromRGBO(24, 45, 163, 0.25),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // Profile Image Section
                    ResponsiveAvatarPicker(
                      isLoading: form.isLoading,
                      onChanged: (val) {
                        setState(() {
                          profileImg = val;
                        });
                      },
                    ),

                    SizedBox(height: 20),
                    Column(
                      children: [
                        ResponsiveTextInput(
                          isLoading: form.isLoading,
                          controller: form.control('fullname'),
                          hint: 'Enter Fullname',
                          label: 'Fullname',
                          type: TextInputTypes.text,
                          errorText: form.error('fullname'),
                          onChanged: (value) {
                            if (form.isSubmitted) {
                              setState(() {
                                form.validate();
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        ResponsivePhoneInput(
                          isLoading: form.isLoading,
                          country_code: country_code,
                          controller: form.control("phone"),
                          hint: 'Enter Phone Number',
                          errorText: form.error('phone'),
                          onChanged: () {
                            if (form.isSubmitted) {
                              setState(() {
                                form.validate();
                              });
                            }
                          },
                          onCountryChanged:
                              (value) => setState(() {
                                country_code = value.code;
                              }),
                        ),
                        const SizedBox(height: 10),
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
                    SizedBox(height: isSmall ? 50 : 100),

                    //Continue Button
                    ResponsiveButton(
                      isLoading: form.isLoading,
                      onPressed: () async {
                        bool isValid = false;
                        setState(() {
                          form.isSubmitted = true;
                          isValid = form.validate();
                        });
                        if (isValid) {
                          setState(() => form.isLoading = true);
                          await Future.delayed(const Duration(seconds: 2));
                          User? user = userProvider.findUserByPhone(
                            form.control("phone").text,
                            country_code,
                          );
                          if (user != null) {
                            showFlexibleSnackbar(
                              context,
                              "${translate(context, "Phone Number already used", "Nomor Telepon sudah terpakai", "电话号码已被使用")}!",
                              type: SnackbarType.error,
                            );
                            setState(() => form.isLoading = false);
                            return;
                          }
                          String? path;
                          try {
                            if (profileImg != null) {
                              path = await saveImageFile(profileImg!);
                              print(">> Image saved at: $path");
                            }
                          } catch (e) {
                            print(">> Gagal menyimpan gambar: $e");
                            showFlexibleSnackbar(
                              context,
                              translate(
                                context,
                                "Failed to save image.",
                                "Gagal menyimpan gambar.",
                                "保存图像失败。",
                              ),
                            );
                            setState(() => form.isLoading = false);
                            return;
                          }

                          userProvider.registerUser(
                            email: widget.email,
                            profile_pic: path,
                            fullname: form.control("fullname").text,
                            country_code: country_code,
                            phone: form.control("phone").text,
                            password: form.control("password").text,
                          );
                          setState(() => form.isLoading = false);
                          showFlexibleSnackbar(
                            context,
                            "${translate(context, "Welcome to ParkID", "Selamat datang di ParkID", "欢迎来到 ParkID")}, ${form.control("fullname").text.split(" ")[0]}!",
                          );
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MainLayout(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        }
                      },
                      text: translate(context, "Register", "Daftar", "登记"),
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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tugas_front_end_nicolas/components/avatar_picker.dart';
import 'package:tugas_front_end_nicolas/components/button.dart';
import 'package:tugas_front_end_nicolas/components/dropdown.dart';
import 'package:tugas_front_end_nicolas/components/phone_input.dart';
import 'package:tugas_front_end_nicolas/components/text_input.dart';
import 'package:tugas_front_end_nicolas/components/time_picker.dart';
import 'package:tugas_front_end_nicolas/provider/user_provider.dart';
import 'package:tugas_front_end_nicolas/utils/dialog.dart';
import 'package:tugas_front_end_nicolas/utils/index.dart';
import 'package:tugas_front_end_nicolas/utils/snackbar.dart';
import 'package:tugas_front_end_nicolas/utils/useform.dart';
import 'package:tugas_front_end_nicolas/model/user.dart';
import 'package:tugas_front_end_nicolas/utils/validator.dart';

class EditProfile extends StatefulWidget {
  const EditProfile(this.user, {super.key});
  final User user;

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String country_code = "ID";
  File? profileImg;

  final form = UseForm(
    fields: ["fullname", "email", "phone", "birth_date", "gender"],
    validators: {
      "fullname":
          (value) =>
              validateBasic(key: "Fullname", value: value, required: true),
      'email': (value) => validateEmail(value: value),
      "phone":
          (value) => validateBasic(
            key: "Phone Number",
            value: value,
            minLength: 7,
            maxLength: 12,
          ),
      "birth_date": (value) => validateBasic(value: value, required: false),
      "gender": (value) => validateBasic(value: value, required: false),
    },
  );

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    form.control('fullname').text = (user.fullname);
    form.control('email').text = (user.email);
    form.control('phone').text = (user.phone);
    form.control('birth_date').text = (user.birthDate) ?? "";
    form.control('gender').text = (user.gender) ?? '';

    country_code = (user.countryCode);
    profileImg =
        widget.user.profilePic != null ? File(widget.user.profilePic!) : null;
  }

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
                      final hasChanged =
                          form.control("fullname").text !=
                              widget.user.fullname ||
                          form.control("email").text != widget.user.email ||
                          form.control("phone").text != widget.user.phone ||
                          (profileImg?.path) != widget.user.profilePic ||
                          country_code != widget.user.countryCode ||
                          form.control("birth_date").text !=
                              (widget.user.birthDate ?? "") ||
                          form.control("gender").text !=
                              (widget.user.gender ?? "");
                      if (form.isLoading) {
                        return;
                      }
                      if (hasChanged) {
                        showConfirmDialog(
                          context: context,
                          title: "Go Back",
                          cancelText: "Back",
                          continueText: "Discard",
                          content:
                              "Are you sure want to go back, all the changes will be discarded?",
                          icon: Icons.warning,
                          color: Color(0xFFFFC107),
                          onContinue: () {
                            Navigator.pop(context);
                            Navigator.pop(context, widget.user);
                          },
                        );
                      } else {
                        Navigator.pop(context);
                      }
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
                      'Edit Profile',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: isSmall ? 32 : 40,
                      ),
                    ),

                    ResponsiveAvatarPicker(
                      isLoading: form.isLoading,
                      onChanged: (val) {
                        setState(() {
                          profileImg = val;
                        });
                      },
                      initValue:
                          widget.user.profilePic != null
                              ? File(widget.user.profilePic!)
                              : null,
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
                        SizedBox(height: isSmall ? 10 : 20),
                        ResponsiveTextInput(
                          isLoading: form.isLoading,
                          controller: form.control('email'),
                          hint: 'Enter Email',
                          label: 'Email',
                          type: TextInputTypes.text,
                          errorText: form.error('email'),
                          onChanged: (value) {
                            if (form.isSubmitted) {
                              setState(() {
                                form.validate();
                              });
                            }
                          },
                        ),
                        SizedBox(height: isSmall ? 10 : 20),
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
                        SizedBox(height: isSmall ? 10 : 20),
                        ResponsiveTimePicker(
                          isLoading: form.isLoading,
                          type: DatePickerType.date,
                          controller: form.control("birth_date"),
                          hint: 'Select Birth Date',
                          label: 'Birth Date',
                        ),
                        SizedBox(height: isSmall ? 10 : 20),
                        ResponsiveDropdown(
                          isLoading: form.isLoading,
                          items: [
                            {"label": "Male", "value": "male"},
                            {"label": "Female", "value": "female"},
                          ],
                          controller: form.control("gender"),
                          hint: 'Select Gender',
                          label: 'Gender',
                        ),
                      ],
                    ),
                    SizedBox(height: isSmall ? 50 : 70),

                    ResponsiveButton(
                      isLoading: form.isLoading,
                      onPressed: () async {
                        final hasChanged =
                            form.control("fullname").text !=
                                widget.user.fullname ||
                            form.control("email").text != widget.user.email ||
                            form.control("phone").text != widget.user.phone ||
                            (profileImg?.path) != widget.user.profilePic ||
                            country_code != widget.user.countryCode ||
                            form.control("birth_date").text !=
                                (widget.user.birthDate ?? "") ||
                            form.control("gender").text !=
                                (widget.user.gender ?? "");
                        bool isValid = false;
                        setState(() {
                          form.isSubmitted = true;
                          isValid = form.validate();
                        });
                        if (isValid && hasChanged) {
                          setState(() => form.isLoading = true);
                          await Future.delayed(const Duration(seconds: 2));
                          User? userEmail = userProvider.findUserByEmail(
                            form.control("email").text,
                          );
                          if (userEmail != null &&
                              form.control("email").text != widget.user.email) {
                            showFlexibleSnackbar(
                              context,
                              "Email already used!",
                              type: SnackbarType.error,
                            );
                            setState(() => form.isLoading = false);
                            return;
                          }
                          User? userPhone = userProvider.findUserByPhone(
                            form.control("phone").text,
                            country_code,
                          );
                          if (userPhone != null &&
                              !(form.control("phone").text ==
                                      widget.user.phone &&
                                  country_code == widget.user.countryCode)) {
                            showFlexibleSnackbar(
                              context,
                              "Phone Number already used!",
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
                          userProvider.editProfile(
                            fullname: form.control("fullname").text,
                            email: form.control("email").text,
                            phone: form.control("phone").text,
                            countryCode: country_code,
                            profilePic: path,
                            birthDate:
                                form.control("birth_date").text == ""
                                    ? null
                                    : form.control("birth_date").text,
                            gender:
                                form.control("gender").text == ""
                                    ? null
                                    : form.control("gender").text,
                          );
                          setState(() => form.isLoading = false);
                          showFlexibleSnackbar(
                            context,
                            "Profile has been updated!",
                          );
                          Navigator.pop(context);
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      text: "Save",
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

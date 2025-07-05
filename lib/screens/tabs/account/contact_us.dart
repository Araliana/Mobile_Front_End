import 'package:flutter/material.dart';
import 'package:tugas_front_end_nicolas/components/button.dart';
import 'package:tugas_front_end_nicolas/components/dropdown.dart';
import 'package:tugas_front_end_nicolas/components/phone_input.dart';
import 'dart:math' as math;

import 'package:tugas_front_end_nicolas/components/text_input.dart';
import 'package:tugas_front_end_nicolas/utils/snackbar.dart';
import 'package:tugas_front_end_nicolas/utils/useform.dart';
import 'package:tugas_front_end_nicolas/utils/validator.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  String country_code = "ID";

  final form = UseForm(
    fields: ["fullname", "email", "phone", "subject", "comment"],
    validators: {
      "fullname": (value) => validateBasic(key: "Fullname", value: value),
      "email": (value) => validateEmail(value: value),
      "phone":
          (value) => validateBasic(
            key: "Phone Number",
            value: value,
            minLength: 7,
            maxLength: 12,
          ),
      "subject": (value) => validateBasic(key: "Subject", value: value),
    },
  );
  final List<Map<String, String>> subjects = [
    {'label': 'Support', 'value': 'Support'},
    {'label': 'Feedback', 'value': 'Feedback'},
    {'label': 'Membership', 'value': 'Membership'},
    {'label': 'Feature Request', 'value': 'Feature Request'},
    {'label': 'Complaint', 'value': 'Complaint'},
    {'label': 'Other', 'value': 'Other'},
  ];

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
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
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmall ? 12 : 24.0,
                      vertical: isSmall ? 0 : 28,
                    ),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Contact Us",
                            style: TextStyle(
                              fontSize: isSmall ? 32 : 48,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0060AF),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Column(
                          children: [
                            ResponsiveTextInput(
                              isLoading: form.isLoading,
                              mode: StyleMode.underline,
                              controller: form.control("fullname"),
                              hint: 'Enter Fullname',
                              label: 'Fullname',
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
                            ResponsiveTextInput(
                              isLoading: form.isLoading,
                              mode: StyleMode.underline,
                              controller: form.control("email"),
                              hint: 'Enter Email',
                              label: 'Email',
                              type: TextInputTypes.email,
                              errorText: form.error('email'),
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
                              mode: StyleMode.underline,
                              country_code: country_code,
                              controller: form.control("phone"),
                              hint: 'Enter Phone Number',
                              label: 'Phone',
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
                            ResponsiveDropdown(
                              isLoading: form.isLoading,
                              items: subjects,
                              mode: StyleMode.underline,
                              controller: form.control("subject"),
                              hint: 'Enter Subject',
                              label: 'Subject',
                              errorText: form.error('subject'),
                              onChanged: (val) {
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
                              mode: StyleMode.underline,
                              controller: form.control("comment"),
                              hint: 'Enter Comment',
                              maxLines: 3,
                              label: 'Comment',
                              errorText: form.error('comment'),
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
                        SizedBox(height: isSmall ? 24 : 32),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildSocialIcon(
                                'assets/images/medsos/tiktok.png',
                                isSmall,
                              ),
                              buildSocialIcon(
                                'assets/images/medsos/wa.png',
                                isSmall,
                              ),
                              buildSocialIcon(
                                'assets/images/medsos/ig.png',
                                isSmall,
                              ),
                              buildSocialIcon(
                                'assets/images/medsos/yt.png',
                                isSmall,
                              ),
                              buildSocialIcon(
                                'assets/images/medsos/x.png',
                                isSmall,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isSmall ? 32 : 48),
                        ResponsiveButton(
                          isLoading: form.isLoading,
                          onPressed: () {
                            bool isValid = false;
                            setState(() {
                              form.isSubmitted = true;
                              isValid = form.validate();
                              if (isValid) {
                                setState(() => form.isLoading = true);
                                Future.delayed(const Duration(seconds: 2), () {
                                  setState(() => form.isLoading = false);
                                  showFlexibleSnackbar(
                                    context,
                                    "Message has been sent!",
                                  );
                                  Navigator.pop(context);
                                });
                              }
                            });
                          },
                          text: "Submit",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSocialIcon(String assetPath, bool isSmall) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Image.asset(
        assetPath,
        height: isSmall ? 40 : 45,
        width: isSmall ? 40 : 45,
      ),
    );
  }
}

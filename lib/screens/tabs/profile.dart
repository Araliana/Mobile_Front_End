import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tugas_front_end_nicolas/components/language_modal.dart';
import 'package:tugas_front_end_nicolas/provider/language_provider.dart';
import 'package:tugas_front_end_nicolas/provider/user_provider.dart';
import 'package:tugas_front_end_nicolas/screens/starting/landing_screen.dart';
import 'package:tugas_front_end_nicolas/screens/tabs/account/change_password.dart';
import 'package:tugas_front_end_nicolas/screens/tabs/account/contact_us.dart';
import 'package:tugas_front_end_nicolas/screens/tabs/account/edit_profile.dart';
import 'package:tugas_front_end_nicolas/screens/tabs/account/faq.dart';
import 'package:tugas_front_end_nicolas/screens/tabs/account/rate_dialog.dart';
import 'package:tugas_front_end_nicolas/screens/tabs/account/subscription.dart';
import 'package:tugas_front_end_nicolas/utils/dialog.dart';
import 'package:tugas_front_end_nicolas/utils/index.dart';
import 'package:tugas_front_end_nicolas/utils/snackbar.dart';
import 'package:tugas_front_end_nicolas/model/user.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    User user = userProvider.currentUser!;
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    void acc_nav(Widget page) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    }

    final List<SettingButtons> accSetting = [
      SettingButtons(
        icon: "assets/images/icons/key.png",
        title: translate(context, "Change Password", "Ubah Kata Sandi", "更改密码"),
        onPressed: () => acc_nav(ChangePassword()),
      ),
      SettingButtons(
        icon: "assets/images/icons/calender.png",
        title: translate(context, "Subscriptions", "Langganan", "订阅"),
        onPressed: () => acc_nav(Subscription()),
      ),
      SettingButtons(
        icon: "assets/images/icons/language.png",
        title: translate(context, "Languages", "Bahasa", "语言"),
        onPressed:
            () => showModalBottomSheet(
              context: context,
              builder: (context) => LanguageModal(langProvider.language),
            ),
      ),
    ];

    final List<SettingButtons> helpOth = [
      SettingButtons(
        icon: "assets/images/icons/question.png",
        title: translate(context, "FAQ", "Pertanyaan Umum", "常见问题"),
        onPressed: () => acc_nav(FAQ()),
      ),
      SettingButtons(
        icon: "assets/images/icons/problem.png",
        title: translate(context, "Contact Us", "Hubungi Kami", "联系我们"),
        onPressed: () => acc_nav(ContactUsPage()),
      ),
      SettingButtons(
        icon: "assets/images/icons/star.png",
        title: translate(
          context,
          "Rate Our App",
          "Beri Rating Aplikasi",
          "为应用评分",
        ),
        onPressed:
            () => showGeneralDialog(
              context: context,
              barrierLabel: "Dialog",
              barrierDismissible: false,
              barrierColor: Colors.black.withValues(alpha: 0.5),
              transitionDuration: const Duration(milliseconds: 300),
              pageBuilder: (context, animation, secondaryAnimation) {
                return const SizedBox();
              },
              transitionBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                final curvedAnimation = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                );
                return SlideTransition(
                  position: Tween(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(curvedAnimation),
                  child: RateDialog(user.rating == null ? 0 : 2),
                );
              },
            ),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              title: Text(
                translate(context, "My Profile", "Profil Saya", "我的资料"),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: isSmall ? 25 : 30,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color.fromARGB(255, 52, 49, 145),
                          const Color.fromARGB(255, 6, 10, 70),
                          const Color.fromARGB(255, 6, 10, 70),
                          const Color.fromARGB(255, 52, 49, 145),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                          spreadRadius: 2,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: EdgeInsets.symmetric(
                      horizontal: isSmall ? 12 : 16,
                      vertical: isSmall ? 6 : 10,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: isSmall ? 50 : 60,
                            backgroundColor: Colors.white,
                            backgroundImage:
                                user.profilePic != null
                                    ? FileImage(File(user.profilePic!))
                                    : null,
                            child:
                                user.profilePic == null
                                    ? Icon(
                                      Icons.person,
                                      size: isSmall ? 50 : 60,
                                      color: Colors.grey[400],
                                    )
                                    : null,
                          ),
                        ),
                        SizedBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullname,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSmall ? 18 : 20,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: isSmall ? 14 : 16,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                formatPhone(user.dialCode, user.phone),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: isSmall ? 16 : 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.transparent,
                              child: IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: const Color(0xFF1F1E5B),
                                ),
                                onPressed: () {
                                  acc_nav(EditProfile(user));
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmall ? 12 : 16,
                      vertical: isSmall ? 4 : 8,
                    ),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            translate(
                              context,
                              "Account Settings",
                              "Pengaturan Akun",
                              "账户设置",
                            ),
                            style: TextStyle(
                              fontSize: isSmall ? 20 : 24,
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: accSetting.length,
                          itemBuilder: (BuildContext context, int index) {
                            return accSetting[index];
                          },
                        ),
                        SizedBox(height: isSmall ? 8 : 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            translate(
                              context,
                              "Help and Others",
                              "Bantuan dan Lainnya",
                              "帮助和其他",
                            ),
                            style: TextStyle(
                              fontSize: isSmall ? 20 : 24,
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: helpOth.length,
                          itemBuilder: (BuildContext context, int index) {
                            return helpOth[index];
                          },
                        ),
                        SizedBox(height: isSmall ? 8 : 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            translate(
                              context,
                              "Exit the Application",
                              "Keluar dari Aplikasi",
                              "退出应用程序",
                            ),
                            style: TextStyle(
                              fontSize: isSmall ? 20 : 24,
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SettingButtons(
                          onPressed:
                              () => {
                                showConfirmDialog(
                                  context: context,
                                  loading: true,
                                  time: 1,
                                  title: translate(
                                    context,
                                    "Logout",
                                    "Keluar",
                                    "登出",
                                  ),
                                  content: translate(
                                    context,
                                    "Are you sure you want to logout from your account?",
                                    "Apakah Anda yakin ingin keluar dari akun Anda?",
                                    "您确定要退出您的账户吗？",
                                  ),
                                  icon: Icons.logout,
                                  color: Colors.red,
                                  onContinue: () {
                                    userProvider.logout();
                                    showFlexibleSnackbar(
                                      context,
                                      translate(
                                        context,
                                        "See you next time, ${user.fullname.split(" ")[0]}!",
                                        "Sampai jumpa lagi, ${user.fullname.split(" ")[0]}!",
                                        "下次见，${user.fullname.split(" ")[0]}！",
                                      ),
                                    );
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LandingScreen(),
                                      ),
                                      (Route<dynamic> route) => false,
                                    );
                                  },
                                ),
                              },
                          title: translate(context, "Log Out", "Keluar", "登出"),
                          tail: Icons.exit_to_app_rounded,
                          tailColor: Colors.red,
                          borderColor: const Color.fromARGB(255, 253, 213, 209),
                          textColor: Colors.red,
                          tailForeground: const Color.fromRGBO(
                            244,
                            67,
                            54,
                            0.15,
                          ),
                          bgColor: Color(0xFFFFDCDC),
                          iconForeground: const Color.fromRGBO(
                            244,
                            67,
                            54,
                            0.20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingButtons extends StatelessWidget {
  const SettingButtons({
    super.key,
    this.icon,
    required this.title,
    this.onPressed,
    this.tail = Icons.arrow_forward_ios_rounded,
    this.bgColor = Colors.white,
    this.borderColor = const Color.fromARGB(255, 242, 242, 242),
    this.textColor = Colors.black,
    this.iconColor = Colors.black,
    this.iconForeground = const Color.fromRGBO(99, 101, 241, 0.1),
    this.tailColor = const Color.fromRGBO(0, 0, 0, 1),
    this.tailForeground = const Color.fromRGBO(0, 0, 0, 0.1),
  });

  final Object? icon;
  final String title;
  final IconData tail;
  final Color bgColor;
  final Color textColor;
  final Color borderColor;
  final Color tailColor;
  final Color tailForeground;
  final Color iconColor;
  final Color iconForeground;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: isSmall ? 4 : 8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 16 : 20,
            vertical: isSmall ? 12 : 16,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              width: 1,
              color: borderColor.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconForeground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:
                        icon != null
                            ? icon is String
                                ? Image.asset(
                                  icon! as String,
                                  scale: isSmall ? 32 : 25,
                                )
                                : Icon(
                                  icon! as IconData,
                                  size: isSmall ? 20 : 24,
                                  color: iconColor,
                                )
                            : SizedBox.shrink(),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: isSmall ? 16 : 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: tailForeground,
                  shape: BoxShape.circle,
                ),
                child: Icon(tail, color: tailColor, size: isSmall ? 16 : 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_front_end/provider/language_provider.dart';
import 'package:mobile_front_end/provider/activity_provider.dart';
import 'package:mobile_front_end/provider/otp_provider.dart';
import 'package:mobile_front_end/provider/parking_lot_provider.dart';
import 'package:mobile_front_end/provider/history_provider.dart';
import 'package:mobile_front_end/provider/user_provider.dart';
import 'package:mobile_front_end/provider/voucher_provider.dart';
import 'package:mobile_front_end/screens/main_layout.dart';
import 'package:mobile_front_end/screens/starting/splash_screen.dart';
import 'package:mobile_front_end/screens/starting/stepper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OTPProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ParkingLotProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => VoucherProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: MaterialApp(
        theme: ThemeData(
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            },
          ),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
          fontFamily: 'Poppins',
          popupMenuTheme: PopupMenuThemeData(color: Colors.white),
        ),
        debugShowCheckedModeBanner: false,
        home: MainApp(),
      ),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isLogin = userProvider.currentUser != null;
    if (userProvider.isLoading) {
      return const SplashScreen();
    }
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (_, __, ___) => isLogin ? MainLayout() : StepperScreen(),
          transitionsBuilder: (_, animation, __, child) {
            var tween = Tween(
              begin: const Offset(0, -1),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOut));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
        (Route<dynamic> route) => false,
      );
    });
    return const SplashScreen();
  }
}

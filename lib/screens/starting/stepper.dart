import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tugas_mobile_front_end/components/button.dart';
import 'package:tugas_mobile_front_end/screens/starting/landing_screen.dart';
import 'package:tugas_mobile_front_end/utils/index.dart';

class StepModel {
  final String title;
  final String subtitle;
  final String image;
  final String align;
  final double? offset;

  StepModel({
    required this.title,
    required this.subtitle,
    required this.image,
    this.align = 'center',
    this.offset,
  });
}

class StepperScreen extends StatefulWidget {
  const StepperScreen({super.key});

  @override
  _StepperScreenState createState() => _StepperScreenState();
}

class _StepperScreenState extends State<StepperScreen> {
  final PageController _controller = PageController();

  int currentPage = 0;

  void nextPage(BuildContext context) {
    if (currentPage < 2) {
      _controller.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // _controller.jumpToPage(0);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LandingScreen()),
      );
    }
  }

  void skipAll(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LandingScreen()),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        currentPage = _controller.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    final List<StepModel> steps = [
      StepModel(
        title: translate(
          context,
          "Find Parking Easily",
          "Temukan Parkir dengan Mudah",
          "轻松找车位",
        ),
        subtitle: translate(
          context,
          "Find parking around you easily and online",
          "Cari tempat parkir di sekitar Anda dengan mudah dan online",
          "轻松在线查找您周围的停车位",
        ),
        image: "assets/images/starting/toy car turn right blue.png",
        align: "left",
        offset: 20.0,
      ),
      StepModel(
        title: translate(
          context,
          "Book and Pay for Parking Quickly and Easily",
          "Pesan dan Bayar Parkir dengan Cepat dan Mudah",
          "快速轻松地预订和支付停车位",
        ),
        subtitle: translate(
          context,
          "Make a booking for your parking and make a payment quickly and easier",
          "Lakukan pemesanan dan pembayaran parkir dengan cepat dan mudah",
          "快速轻松地预订车位并完成支付",
        ),
        image:
            "assets/images/starting/back view of toy car turn right blue.png",
        align: "center",
      ),
      StepModel(
        title: translate(
          context,
          "Park According to the Desired Time",
          "Parkir Sesuai Waktu yang Diinginkan",
          "按需选择停车时间",
        ),
        subtitle: translate(
          context,
          "Can decide when parking time is and determine when it’s time to leave",
          "Bisa menentukan kapan waktu parkir dan kapan waktu untuk pergi",
          "您可以决定停车和离开的时间",
        ),
        image: "assets/images/starting/toy car turn left blue.png",
        align: "right",
        offset: 20.0,
      ),
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              physics: NeverScrollableScrollPhysics(),
              itemCount: steps.length,
              itemBuilder: (context, index) {
                return Center(child: LandingStepper(steps[index]));
              },
            ),
          ),
          SmoothPageIndicator(
            controller: _controller,
            count: steps.length,
            effect: WormEffect(
              dotHeight: 12,
              dotWidth: 12,
              activeDotColor: Color(0xFF4D5DFA),
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Column(
              children: [
                ResponsiveButton(
                  onPressed: () => nextPage(context),
                  text: "Next",
                  textColor: Colors.white,
                  backgroundColor: Color(0xFF4D5DFA),
                ),
                SizedBox(height: isSmall ? 0 : 10),
                ResponsiveButton(
                  onPressed: () => skipAll(context),
                  text: "Skip",
                  textColor: Color(0xFF4D5DFA),
                  backgroundColor: Color.fromARGB(255, 212, 217, 255),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LandingStepper extends StatelessWidget {
  const LandingStepper(this.step, {super.key});

  final StepModel step;

  // inside your LandingStepper class:
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isSmall ? 10 : 0),
          child: Column(
            children: [
              Text(
                step.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmall ? 30 : 40,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                step.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: isSmall ? 18 : 24,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),
        Transform.translate(
          offset: Offset(step.offset ?? 0.0, 0),
          child: Align(
            alignment:
                step.align == "left"
                    ? Alignment.centerLeft
                    : step.align == "right"
                    ? Alignment.centerRight
                    : Alignment.center,
            child: Image.asset(step.image, height: isSmall ? 160 : 240),
          ),
        ),
      ],
    );
  }
}

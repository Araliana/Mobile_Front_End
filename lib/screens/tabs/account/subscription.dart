import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tugas_front_end_nicolas/components/button.dart';
import 'package:tugas_front_end_nicolas/provider/user_provider.dart';
import 'package:tugas_front_end_nicolas/screens/tabs/account/subscription/subscription_choice.dart';
import 'package:tugas_front_end_nicolas/screens/tabs/account/subscription/subscription_feature.dart';
import 'package:tugas_front_end_nicolas/screens/tabs/account/subscription/subscription_ongoing.dart';
import 'package:tugas_front_end_nicolas/screens/tabs/account/subscription/subscription_splash.dart';
import 'package:tugas_front_end_nicolas/utils/snackbar.dart';
import 'package:tugas_front_end_nicolas/model/user.dart';

class Subscription extends StatefulWidget {
  const Subscription({super.key});

  @override
  _SubscriptionState createState() => _SubscriptionState();
}

class _SubscriptionState extends State<Subscription> {
  final PageController _controller = PageController();

  MemberChoice? selected;
  int currentPage = 0;
  bool isLoading = false;

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
    final userProvider = Provider.of<UserProvider>(context);
    User user = userProvider.currentUser!;
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              centerTitle: true,
              title: Text(
                'Member',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: isSmall ? 25 : 30,
                ),
              ),
              leading: Padding(
                padding: EdgeInsets.only(left: 12.0),
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      if (currentPage == 0) {
                        Navigator.pop(context);
                      } else {
                        if (isLoading) {
                          return;
                        }
                        _controller.previousPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                        setState(() {
                          selected = null;
                        });
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
              child:
                  user.isMember
                      ? SubscriptionOngoing()
                      : Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              isSmall
                                  ? currentPage == 0
                                      ? 30
                                      : 20
                                  : currentPage == 0
                                  ? 40
                                  : 30,
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height:
                                  isSmall
                                      ? currentPage == 0
                                          ? 500
                                          : 480
                                      : 740,
                              child: PageView(
                                controller: _controller,
                                physics: NeverScrollableScrollPhysics(),
                                children: [
                                  SubscriptionFeature(),
                                  SubscriptionChoice(
                                    (MemberChoice val) => setState(() {
                                      selected = val;
                                    }),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            // Button
                            ResponsiveButton(
                              isLoading: isLoading,
                              onPressed:
                                  (selected != null && currentPage == 1) ||
                                          currentPage == 0
                                      ? () {
                                        if (currentPage == 0) {
                                          _controller.nextPage(
                                            duration: Duration(
                                              milliseconds: 300,
                                            ),
                                            curve: Curves.easeInOut,
                                          );
                                        } else {
                                          setState(() => isLoading = true);
                                          Future.delayed(
                                            const Duration(seconds: 2),
                                            () {
                                              int success = userProvider
                                                  .joinMember(
                                                    type: selected!.value,
                                                    nominal: selected!.price,
                                                  );
                                              if (success == -1) {
                                                showFlexibleSnackbar(
                                                  context,
                                                  "Balance is not sufficient!",
                                                  type: SnackbarType.error,
                                                );
                                                setState(
                                                  () => isLoading = false,
                                                );
                                                return;
                                              }
                                              setState(() => isLoading = false);
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          SubscriptionSplash(),
                                                ),
                                              );
                                            },
                                          );
                                        }
                                      }
                                      : null,
                              text:
                                  currentPage == 0
                                      ? 'Proceed Member'
                                      : "Payment",
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

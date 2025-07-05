import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tugas_front_end_nicolas/provider/user_provider.dart';

class RateDialog extends StatefulWidget {
  const RateDialog([this.page = 0]);
  final int page;

  @override
  State<RateDialog> createState() => _RateDialogState();
}

class _RateDialogState extends State<RateDialog> {
  final PageController _controller = PageController();

  bool isLoading = false;
  int currentPage = 0;
  int selectedRating = 0;

  @override
  void initState() {
    super.initState();
    currentPage = widget.page;
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
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: EdgeInsets.symmetric(horizontal: isSmall ? 35 : 30),
      child: Padding(
        padding:
            isSmall
                ? EdgeInsets.symmetric(vertical: 15, horizontal: 30)
                : EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: isSmall ? 100 : 140,
              child: PageView(
                controller: _controller,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Rate This App",
                        style: TextStyle(
                          fontSize: isSmall ? 20 : 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: isSmall ? 10 : 20),
                      Text(
                        "If you enjoy using this app, please take a moment to rate it. "
                        "Thank you for your support!",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: isSmall ? 14 : 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Enjoying Parkir.com?",
                        style: TextStyle(
                          fontSize: isSmall ? 20 : 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: isSmall ? 10 : 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedRating = index + 1;
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                Icons.star,
                                size: isSmall ? 30 : 40,
                                color:
                                    index < selectedRating
                                        ? Colors.amber
                                        : Colors.grey.shade300,
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 8),
                      Text(
                        "Tap a star to rate!",
                        style: TextStyle(
                          fontSize: isSmall ? 14 : 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Thank you for rating",
                        style: TextStyle(
                          fontSize: isSmall ? 20 : 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: isSmall ? 10 : 20),
                      Text(
                        "Your feedback helps us evaluate our app’s quality and improve your experience.",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: isSmall ? 14 : 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment:
                  currentPage == 0
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  style: TextButton.styleFrom(foregroundColor: Colors.blue),
                  child: Text(
                    currentPage == 0
                        ? "Later"
                        : currentPage == 1
                        ? "Dismiss"
                        : "Done",
                    style: TextStyle(
                      fontSize:
                          isSmall
                              ? currentPage != 0
                                  ? 16
                                  : null
                              : currentPage != 0
                              ? 22
                              : 18,
                    ),
                  ),
                ),
                (currentPage != 2) ? SizedBox(width: 8) : SizedBox.shrink(),
                (currentPage != 2)
                    ? TextButton(
                      onPressed:
                          isLoading
                              ? null
                              : () {
                                if (currentPage == 0) {
                                  _controller.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                } else if (currentPage == 1 &&
                                    selectedRating != 0) {
                                  setState(() => isLoading = true);
                                  Future.delayed(Duration(seconds: 2), () {
                                    userProvider.rateApp(selectedRating);
                                    setState(() => isLoading = false);
                                    _controller.nextPage(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                  });
                                }
                              },
                      style: TextButton.styleFrom(foregroundColor: Colors.blue),
                      child:
                          isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color.fromARGB(255, 196, 196, 196),
                                ),
                              )
                              : Text(
                                currentPage == 0 ? "Rate Now" : "Submit",
                                style: TextStyle(
                                  fontSize:
                                      isSmall
                                          ? currentPage != 0
                                              ? 16
                                              : null
                                          : currentPage != 0
                                          ? 22
                                          : 18,
                                ),
                              ),
                    )
                    : SizedBox.shrink(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

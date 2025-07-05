import 'package:flutter/material.dart';
import 'package:tugas_front_end_nicolas/model/user.dart';
import 'package:tugas_front_end_nicolas/utils/index.dart';

class SubscriptionChoice extends StatefulWidget {
  const SubscriptionChoice(this.onChanged, {super.key});
  final Function(MemberChoice) onChanged;

  @override
  State<SubscriptionChoice> createState() => _SubscriptionChoiceState();
}

class _SubscriptionChoiceState extends State<SubscriptionChoice> {
  int? val;

  final List<MemberChoice> options = [
    MemberChoice(MemberType.annual, 780000, 'Annual', 'Pay for a full year'),
    MemberChoice(MemberType.seasonal, 195000, 'Seasonal', 'Pay for 3 months'),
    MemberChoice(
      MemberType.monthly,
      65000,
      'Monthly',
      'Pay monthly, cancel any time',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return Center(
      child: Column(
        children: [
          Image.asset(
            'assets/images/others/member.png',
            width: isSmall ? 220 : 340,
          ),
          SizedBox(height: isSmall ? 20 : 40),
          ...options.asMap().entries.map((entry) {
            final index = entry.key;
            final choice = entry.value;

            return Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color(0x80EAEAF3),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Color(0x804D5DFA)),
                  ),
                  child: RadioListTile(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: isSmall ? 5 : 10,
                      horizontal: 15,
                    ),
                    value: index,
                    groupValue: val,
                    activeColor: Color(0xFF1F1E5B),
                    onChanged: (value) {
                      setState(() {
                        val = value!;
                        widget.onChanged.call(choice);
                      });
                    },
                    title: Text(
                      choice.label,
                      style: TextStyle(
                        fontSize: isSmall ? 16 : 20,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      choice.description,
                      style: TextStyle(
                        fontSize: isSmall ? 13 : 18,
                        color: Color(0xFFAAA9A9),
                      ),
                    ),
                    secondary: Text(
                      formatCurrency(nominal: choice.price),
                      style: TextStyle(fontSize: isSmall ? 14 : 18),
                    ),
                    selected: val == index,
                  ),
                ),
                if (index != options.length - 1)
                  SizedBox(height: isSmall ? 10 : 20),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class MemberChoice {
  MemberType value;
  double price;
  String label;
  String description;

  MemberChoice(this.value, this.price, this.label, this.description);
}

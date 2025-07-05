import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_front_end/provider/language_provider.dart';

class LanguageModal extends StatefulWidget {
  const LanguageModal(this.value, {super.key});
  final String value;

  @override
  State<LanguageModal> createState() => _LanguageModalState();
}

class _LanguageModalState extends State<LanguageModal> {
  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isSmall ? 40 : 50,
            height: isSmall ? 5 : 7,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 223, 223, 223),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          Text(
            'Switch Language',
            style: TextStyle(
              fontSize: isSmall ? 20 : 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: isSmall ? 5 : 10),
          Divider(
            indent: isSmall ? 10 : 12,
            thickness: isSmall ? 1.5 : 2.2,
            color: const Color.fromARGB(255, 223, 223, 223),
          ),
          SizedBox(height: isSmall ? 15 : 22),

          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFE2EDFF),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                ...langProvider.languages.map((lang) {
                  final isSelected = langProvider.language == lang.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        Future.delayed(Duration(milliseconds: 500), () {
                          langProvider.switchLanguage(lang.value);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/others/${lang.value.toLowerCase()}.png',
                              width: isSmall ? 24 : 36,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "${lang.label} (${lang.value})",
                                style: TextStyle(
                                  fontSize: isSmall ? 14 : 18,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: Colors.lightGreenAccent,
                                size: isSmall ? 20 : 28,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

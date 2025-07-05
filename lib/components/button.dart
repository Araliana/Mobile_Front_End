import 'package:flutter/material.dart';

enum ButtonTypes { normal, outline }

class ResponsiveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? loadingText;
  final String text;
  final Color textColor;
  final FontWeight? fontWeight;
  final Color backgroundColor;
  final ButtonTypes buttonType;
  final Color borderColor;
  final bool? isLoading;

  const ResponsiveButton({
    super.key,
    this.onPressed,
    this.loadingText,
    required this.text,
    Color? textColor,
    this.fontWeight = FontWeight.w400,
    this.buttonType = ButtonTypes.normal,
    this.backgroundColor = const Color(0xFF1F1E5B),
    this.borderColor = Colors.black,
    this.isLoading = false,
  }) : textColor =
           textColor ??
           (buttonType == ButtonTypes.normal ? Colors.white : Colors.black);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    final buttonChild =
        isLoading != null && isLoading!
            ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: isSmall ? 16 : 24,
                      height: isSmall ? 16 : 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(textColor),
                      ),
                    ),
                    if (loadingText != null) ...[
                      SizedBox(width: 6),
                      Text(
                        loadingText!,
                        style: TextStyle(
                          color: textColor,
                          fontSize: isSmall ? null : 20,
                          fontWeight: fontWeight,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            )
            : Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: isSmall ? null : 20,
                fontWeight: fontWeight,
              ),
            );

    final style = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
    );

    final outlineStyle = ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      side: BorderSide(color: borderColor),
    );

    return SizedBox(
      width: isSmall ? 240 : 300,
      height: isSmall ? null : 50,
      child:
          buttonType == ButtonTypes.outline
              ? OutlinedButton(
                onPressed:
                    isLoading != null
                        ? isLoading!
                            ? null
                            : onPressed
                        : () {},
                style: outlineStyle,
                child: buttonChild,
              )
              : ElevatedButton(
                onPressed:
                    isLoading != null
                        ? isLoading!
                            ? null
                            : onPressed
                        : () {},
                style: style,
                child: buttonChild,
              ),
    );
  }
}

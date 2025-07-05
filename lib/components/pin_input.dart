import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

enum PinInputType { number, text, mixed }

class ResponsivePINInput extends StatefulWidget {
  final int pinLength;
  final TextEditingController? controller;
  final Function(String)? onCompleted;
  final String? errorText;
  final Color pinFillColor;
  final Color pinBorderColor;
  final Color pinActiveBorderColor;
  final bool? isLoading;
  final bool disabled;

  const ResponsivePINInput({
    super.key,
    this.pinLength = 6,
    this.controller,
    this.onCompleted,
    this.isLoading,
    this.disabled = false,
    this.errorText,
    this.pinFillColor = Colors.white,
    this.pinBorderColor = const Color.fromARGB(255, 182, 182, 182),
    this.pinActiveBorderColor = const Color.fromARGB(255, 54, 50, 159),
  });

  @override
  State<ResponsivePINInput> createState() => ResponsivePINInputState();
}

class ResponsivePINInputState extends State<ResponsivePINInput> {
  final FocusNode _focusNode = FocusNode();

  void resetField() {
    Future.delayed(const Duration(milliseconds: 100), () {
      widget.controller?.clear();
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PinCodeTextField(
          enabled:
              widget.isLoading != null ? !widget.isLoading! : !widget.disabled,
          appContext: context,
          length: widget.pinLength,
          controller: widget.controller,
          focusNode: _focusNode,
          autoFocus: true,
          autoDisposeControllers: false,
          animationType: AnimationType.scale,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(10),
            fieldHeight: isSmall ? 50 : 55,
            fieldWidth: isSmall ? 50 : 55,
            disabledColor: const Color(0xFFF0F0F0),
            activeFillColor:
                widget.errorText != null
                    ? const Color(0xFFFFEDED)
                    : widget.pinFillColor,
            selectedFillColor:
                widget.errorText != null
                    ? const Color(0xFFFFEDED)
                    : widget.pinFillColor,
            inactiveFillColor:
                widget.errorText != null
                    ? const Color(0xFFFFEDED)
                    : widget.pinFillColor,
            activeColor:
                widget.errorText != null
                    ? Colors.red
                    : widget.pinActiveBorderColor,
            selectedColor:
                widget.errorText != null
                    ? Colors.red
                    : widget.pinActiveBorderColor,
            inactiveColor:
                widget.errorText != null ? Colors.red : widget.pinBorderColor,
            activeBoxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            inActiveBoxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          enableActiveFill: true,
          onCompleted: (val) {
            widget.onCompleted?.call(val);
          },
          beforeTextPaste: (text) {
            return text != null &&
                text.length == 6 &&
                RegExp(r'^\d+$').hasMatch(text);
          },
        ),
        if (widget.errorText != null)
          Transform.translate(
            offset: Offset(0, -10),
            child: Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Text(
                widget.errorText!,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: isSmall ? 12 : 15,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

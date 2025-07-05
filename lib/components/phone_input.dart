import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:tugas_front_end_nicolas/components/text_input.dart';

List<String> allowedCountryCodes = [
  'ID',
  'MY',
  'SG',
  'PH',
  'BN',
  'TH',
  'VN',
  'KH',
  'LA',
  'MM',
  'JP',
  'KR',
  'CN',
  'TW',
  'HK',
];

class ResponsivePhoneInput extends StatefulWidget {
  const ResponsivePhoneInput({
    super.key,
    this.controller,
    this.onChanged,
    this.onCountryChanged,
    this.hint,
    this.label,
    this.errorText,
    this.isLoading,
    this.disabled = false,
    this.country_code,
    this.mode = StyleMode.outline,
    this.fillColor = Colors.white,
    this.borderColor = const Color(0xFF1F1E5B),
    this.borderFocusColor = const Color(0xFF505050),
  });

  final TextEditingController? controller;
  final VoidCallback? onChanged;
  final ValueChanged<Country>? onCountryChanged;
  final String? hint;
  final String? label;
  final String? errorText;
  final String? country_code;
  final Color fillColor;
  final StyleMode mode;
  final Color borderColor;
  final Color borderFocusColor;
  final bool? isLoading;
  final bool disabled;

  @override
  State<ResponsivePhoneInput> createState() => _ResponsivePhoneInputState();
}

class _ResponsivePhoneInputState extends State<ResponsivePhoneInput> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  Color _getColor() {
    if (widget.errorText != null) return Colors.red;
    if (_isFocused) return widget.borderColor;
    return widget.borderFocusColor;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.mode == StyleMode.underline
            ? Text(
              widget.label!,
              style: TextStyle(color: _getColor(), fontSize: isSmall ? 12 : 16),
            )
            : SizedBox.shrink(),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow:
                widget.mode == StyleMode.underline
                    ? null
                    : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(4, 4),
                      ),
                    ],
          ),
          child: IntlPhoneField(
            enabled:
                widget.isLoading != null
                    ? !widget.isLoading!
                    : !widget.disabled,
            focusNode: _focusNode,
            controller: widget.controller,
            onCountryChanged: widget.onCountryChanged,
            onChanged: (_) {
              widget.onChanged?.call();
            },
            keyboardType: TextInputType.number,
            countries:
                countries
                    .where((c) => allowedCountryCodes.contains(c.code))
                    .toList(),
            decoration: InputDecoration(
              hintText: widget.hint ?? 'Phone Number',
              labelText:
                  widget.mode == StyleMode.underline
                      ? null
                      : widget.label ?? 'Phone Number',
              hintStyle: TextStyle(color: _getColor()),
              labelStyle: TextStyle(color: _getColor()),
              floatingLabelStyle: TextStyle(color: _getColor()),
              filled: true,
              fillColor:
                  widget.mode == StyleMode.underline
                      ? Colors.white
                      : hasError
                      ? const Color(0xFFFFEDED)
                      : widget.fillColor,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isSmall ? 18 : 20,
                vertical: isSmall ? 12 : 16,
              ),
              border:
                  widget.mode == StyleMode.underline
                      ? const UnderlineInputBorder()
                      : OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
              focusedBorder:
                  widget.mode == StyleMode.underline
                      ? UnderlineInputBorder(
                        borderSide: BorderSide(color: _getColor(), width: 2.0),
                      )
                      : OutlineInputBorder(
                        borderSide: BorderSide(color: _getColor(), width: 2.0),
                        borderRadius: BorderRadius.circular(20),
                      ),
              enabledBorder:
                  widget.mode == StyleMode.underline
                      ? UnderlineInputBorder(
                        borderSide: BorderSide(color: _getColor()),
                      )
                      : OutlineInputBorder(
                        borderSide: BorderSide(color: _getColor()),
                        borderRadius: BorderRadius.circular(20),
                      ),
              errorBorder:
                  widget.mode == StyleMode.underline
                      ? const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      )
                      : OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(20),
                      ),
            ),
            initialCountryCode: widget.country_code,
            disableLengthCheck: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
        const SizedBox(height: 4),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              widget.errorText!,
              style: TextStyle(color: Colors.red, fontSize: isSmall ? 12 : 15),
            ),
          ),
      ],
    );
  }
}

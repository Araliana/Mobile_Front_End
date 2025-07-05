import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum TextInputTypes { password, email, text, number }

enum StyleMode { outline, underline }

class ResponsiveTextInput extends StatefulWidget {
  const ResponsiveTextInput({
    super.key,
    this.readOnly = false,
    this.controller,
    this.clearButton = false,
    this.onChanged,
    this.onClear,
    this.onTap,
    this.onSubmitted,
    this.hint,
    this.label,
    this.errorText,
    this.leading,
    this.isLoading,
    this.disabled = false,
    this.suffix,
    this.value,
    this.autoFocus = false,
    this.mode = StyleMode.outline,
    this.maxLines = 1,
    this.type = TextInputTypes.text,
    this.fillColor = Colors.white,
    this.borderColor = const Color(0xFF1F1E5B),
    this.borderFocusColor = const Color(0xFF505050),
  });

  final bool readOnly;
  final bool clearButton;
  final int maxLines;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onClear;
  final Function(String)? onSubmitted;
  final String? hint;
  final String? label;
  final String? value;
  final String? errorText;
  final StyleMode mode;
  final TextInputTypes type;
  final IconData? leading;
  final bool? isLoading;
  final bool disabled;
  final bool autoFocus;
  final Widget? suffix;
  final Color fillColor;
  final Color borderColor;
  final Color borderFocusColor;

  @override
  State<ResponsiveTextInput> createState() => _ResponsiveTextInputState();
}

class _ResponsiveTextInputState extends State<ResponsiveTextInput> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscureText = true;

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
    final isPassword = widget.type == TextInputTypes.password;

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
          child: TextField(
            autofocus: widget.autoFocus,
            enabled:
                widget.isLoading != null
                    ? !widget.isLoading!
                    : !widget.disabled,
            readOnly: widget.readOnly,
            maxLines: widget.maxLines,
            focusNode: _focusNode,
            controller: widget.controller,
            obscureText: isPassword ? _obscureText : false,
            keyboardType:
                widget.type == TextInputTypes.email
                    ? TextInputType.emailAddress
                    : widget.type == TextInputTypes.number
                    ? TextInputType.number
                    : TextInputType.text,
            onChanged: (value) {
              setState(() {
                widget.onChanged?.call(value);
              });
            },
            onTap: () {
              setState(() {
                widget.onTap?.call();
              });
            },
            onSubmitted: (value) {
              setState(() {
                widget.onSubmitted?.call(value);
              });
            },
            decoration: InputDecoration(
              hintText: widget.hint,
              labelText:
                  widget.mode == StyleMode.underline ? null : widget.label,
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
              prefixIcon:
                  widget.leading != null
                      ? Icon(widget.leading, size: isSmall ? 20 : 28)
                      : null,
              suffixIcon:
                  isPassword
                      ? IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: _getColor(),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      )
                      : widget.clearButton
                      ? (widget.isLoading == true)
                          ? Container(
                            width: 24,
                            height: 24,
                            margin: const EdgeInsets.all(12),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.grey,
                              ),
                            ),
                          )
                          : (widget.controller?.text.isNotEmpty == true)
                          ? Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                widget.controller?.clear();
                                setState(() {
                                  widget.onClear?.call();
                                });
                              },
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                          )
                          : widget.suffix
                      : widget.suffix,
              border:
                  widget.mode == StyleMode.underline
                      ? UnderlineInputBorder()
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
                      ? UnderlineInputBorder(
                        borderSide: const BorderSide(color: Colors.red),
                      )
                      : OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(20),
                      ),
            ),
            inputFormatters:
                widget.type == TextInputTypes.number
                    ? [FilteringTextInputFormatter.digitsOnly]
                    : null,
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

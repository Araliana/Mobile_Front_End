import 'package:flutter/material.dart';
import 'package:tugas_front_end_nicolas/components/text_input.dart';

class ResponsiveDropdown<T> extends StatefulWidget {
  const ResponsiveDropdown({
    super.key,
    required this.items,
    this.controller,
    this.onChanged,
    this.label,
    this.hint,
    this.errorText,
    this.isLoading,
    this.disabled = false,
    this.leading,
    this.fillColor = Colors.white,
    this.borderColor = const Color(0xFF1F1E5B),
    this.borderFocusColor = const Color(0xFF505050),
    this.mode = StyleMode.outline,
  });

  final List<Map<String, String>> items;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final String? label;
  final String? hint;
  final String? errorText;
  final IconData? leading;
  final StyleMode mode;
  final Color fillColor;
  final Color borderColor;
  final Color borderFocusColor;
  final bool? isLoading;
  final bool disabled;

  @override
  State<ResponsiveDropdown<T>> createState() => _ResponsiveDropdownState<T>();
}

class _ResponsiveDropdownState<T> extends State<ResponsiveDropdown<T>> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  String? _selectedValue;
  String? _selectedLabel;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null && widget.controller!.text.isNotEmpty) {
      _selectedValue = widget.controller!.text;
      // Find the corresponding label
      final item = widget.items.firstWhere(
        (item) => item['value'] == _selectedValue,
        orElse: () => {'label': _selectedValue!},
      );
      _selectedLabel = item['label'];
    }

    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Color _getColor() {
    if (widget.errorText != null) return Colors.red;
    if (_isFocused || _isMenuOpen) return widget.borderColor;
    return widget.borderFocusColor;
  }

  Future<void> _showDropdownMenu(bool isSmall) async {
    if (widget.isLoading != null ? !widget.isLoading! : true) {
      setState(() {
        _isFocused = true;
        _isMenuOpen = true;
      });

      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final size = renderBox.size;
      final offset = renderBox.localToGlobal(Offset.zero);

      final selectedValue = await showMenu<String>(
        context: context,
        position: RelativeRect.fromLTRB(
          offset.dx,
          offset.dy + size.height,
          offset.dx + size.width,
          offset.dy + size.height + 200,
        ),
        constraints: BoxConstraints(minWidth: size.width, maxWidth: size.width),
        items:
            widget.items.map((item) {
              final isSelected = _selectedValue == item['value'];
              return PopupMenuItem<String>(
                value: item['value'],
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? widget.borderColor.withValues(alpha: 0.1)
                            : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item['label']!,
                          style: TextStyle(
                            color:
                                isSelected
                                    ? widget.borderColor
                                    : Colors.grey[800],
                            fontWeight:
                                isSelected
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                            fontSize: isSmall ? 16 : 18,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check, color: widget.borderColor, size: 20),
                    ],
                  ),
                ),
              );
            }).toList(),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

      setState(() {
        _isFocused = false;
        _isMenuOpen = false;
      });

      if (selectedValue != null) {
        if (_selectedValue == selectedValue) {
          setState(() {
            _selectedValue = null;
            _selectedLabel = null;
            if (widget.controller != null) {
              widget.controller!.text = '';
            }
          });
        } else {
          // Select the new item
          final selectedItem = widget.items.firstWhere(
            (item) => item['value'] == selectedValue,
          );

          setState(() {
            _selectedValue = selectedValue;
            _selectedLabel = selectedItem['label'];
            if (widget.controller != null) {
              widget.controller!.text = selectedValue;
            }
          });
        }

        widget.onChanged?.call(selectedValue);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final isOutline = widget.mode == StyleMode.outline;
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    final enabled =
        widget.isLoading != null ? !widget.isLoading! : !widget.disabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isOutline && widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.label!,
              style: TextStyle(color: _getColor(), fontSize: isSmall ? 12 : 16),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            borderRadius: isOutline ? BorderRadius.circular(20) : null,
            boxShadow:
                isOutline
                    ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(4, 4),
                      ),
                    ]
                    : null,
          ),
          child: GestureDetector(
            onTap: () async {
              if ((widget.isLoading != null ? !widget.isLoading! : true) &&
                  !widget.disabled) {
                setState(() => _isFocused = true);
                await _showDropdownMenu(isSmall);
                setState(() => _isFocused = false);
              }
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: widget.label,
                hintText: widget.hint,
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
                        ? Icon(
                          widget.leading,
                          size: isSmall ? 20 : 24,
                          color: _getColor(),
                        )
                        : null,
                suffixIcon: Opacity(
                  opacity: enabled ? 1 : 0.4,
                  child: Icon(
                    _isMenuOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: _getColor(),
                  ),
                ),
                enabledBorder:
                    isOutline
                        ? OutlineInputBorder(
                          borderSide: BorderSide(color: _getColor()),
                          borderRadius: BorderRadius.circular(20),
                        )
                        : UnderlineInputBorder(
                          borderSide: BorderSide(color: _getColor()),
                        ),
                disabledBorder:
                    isOutline
                        ? OutlineInputBorder(
                          borderSide: BorderSide(color: _getColor()),
                          borderRadius: BorderRadius.circular(20),
                        )
                        : UnderlineInputBorder(
                          borderSide: BorderSide(color: _getColor()),
                        ),
                focusedBorder:
                    isOutline
                        ? OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _getColor(),
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        )
                        : UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: _getColor(),
                            width: 2.0,
                          ),
                        ),
                errorBorder:
                    isOutline
                        ? OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(20),
                        )
                        : const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                focusedErrorBorder:
                    isOutline
                        ? OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        )
                        : const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),
              ),
              isFocused: _isFocused || _isMenuOpen,
              child: Opacity(
                opacity: enabled ? 1 : 0.4,
                child: Text(
                  _selectedLabel ?? widget.hint ?? '',
                  style: TextStyle(
                    fontSize: isSmall ? 16 : 18,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ),
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

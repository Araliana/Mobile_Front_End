import 'package:flutter/material.dart';
import 'package:tugas_front_end_nicolas/components/text_input.dart';

enum DatePickerType { date, time, datetime }

class ResponsiveTimePicker extends StatefulWidget {
  ResponsiveTimePicker({
    super.key,
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
    this.type = DatePickerType.date,
    this.minTime,
    this.maxTime,
    DateTime? initialTime,
    this.disabledDates,
    this.minDate,
    this.maxDate,
  }) : initialTime = initialTime ?? minDate ?? DateTime.now();

  final TextEditingController? controller;
  final Function(String)? onChanged;
  final String? label;
  final String? hint;
  final String? errorText;
  final IconData? leading;
  final Color fillColor;
  final Color borderColor;
  final Color borderFocusColor;
  final StyleMode mode;
  final DatePickerType type;
  final bool? isLoading;
  final bool disabled;
  final DateTime initialTime;
  final TimeOfDay? minTime;
  final TimeOfDay? maxTime;
  final List<DateTime>? disabledDates;
  final DateTime? minDate;
  final DateTime? maxDate;

  @override
  State<ResponsiveTimePicker> createState() => _ResponsiveTimePickerState();
}

class _ResponsiveTimePickerState extends State<ResponsiveTimePicker> {
  bool _isFocused = false;
  String? _selectedTime;

  void _updateSelectedTime(String? newTime) {
    setState(() {
      _selectedTime = newTime;
    });

    if (widget.controller != null) {
      widget.controller!.text = newTime ?? '';
    }

    widget.onChanged?.call(newTime ?? "");
  }

  bool _isTimeInRange(TimeOfDay time) {
    if (widget.minTime == null && widget.maxTime == null) return true;

    final timeInMinutes = time.hour * 60 + time.minute;

    if (widget.minTime != null) {
      final minTimeInMinutes =
          widget.minTime!.hour * 60 + widget.minTime!.minute;
      if (timeInMinutes < minTimeInMinutes) return false;
    }

    if (widget.maxTime != null) {
      final maxTimeInMinutes =
          widget.maxTime!.hour * 60 + widget.maxTime!.minute;
      if (timeInMinutes >= maxTimeInMinutes) return false;
    }

    return true;
  }

  bool _isDateDisabled(DateTime date) {
    if (widget.disabledDates == null) return false;

    return widget.disabledDates!.any(
      (disabledDate) =>
          date.year == disabledDate.year &&
          date.month == disabledDate.month &&
          date.day == disabledDate.day,
    );
  }

  String _formatTime24Hour(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  Future<TimeOfDay?> _showTimePickerWithConstraints(
    BuildContext context,
    TimeOfDay initialTime,
  ) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF1F1E5B),
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
              primaryColor: const Color(0xFF1F1E5B),
              textTheme: ThemeData.light().textTheme.copyWith(),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(foregroundColor: Color(0xFF1F1E5B)),
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (selectedTime != null && !_isTimeInRange(selectedTime)) {
      String errorMessage = '';
      if (widget.minTime != null && widget.maxTime != null) {
        errorMessage =
            'Please select a time between ${_formatTime24Hour(widget.minTime!)} and ${_formatTime24Hour(widget.maxTime!)}';
      } else if (widget.minTime != null) {
        errorMessage =
            'Please select a time after ${_formatTime24Hour(widget.minTime!)}';
      } else if (widget.maxTime != null) {
        errorMessage =
            'Please select a time before ${_formatTime24Hour(widget.maxTime!)}';
      }

      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Invalid Time'),
              content: Text(errorMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }

      return await _showTimePickerWithConstraints(context, initialTime);
    }

    return selectedTime;
  }

  Future<void> _pickDate() async {
    DateTime initialDate;

    if (_selectedTime != null && _selectedTime!.isNotEmpty) {
      try {
        if (widget.type == DatePickerType.datetime) {
          final dateTimeParts = _selectedTime!.split(' ');
          final dateParts = dateTimeParts[0].split('/');
          final timeParts = dateTimeParts[1].split(':');

          final day = int.parse(dateParts[0]);
          final month = int.parse(dateParts[1]);
          final year = int.parse(dateParts[2]);
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);

          initialDate = DateTime(year, month, day, hour, minute);
        } else if (widget.type == DatePickerType.date) {
          final parts = _selectedTime!.split('/');
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          initialDate = DateTime(year, month, day);
        } else {
          final parts = _selectedTime!.split(':');
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          final now = DateTime.now();
          initialDate = DateTime(now.year, now.month, now.day, hour, minute);
        }
      } catch (_) {
        initialDate = widget.initialTime;
      }
    } else {
      initialDate = widget.initialTime;
    }

    if (widget.type == DatePickerType.time) {
      final TimeOfDay? pickedTime = await _showTimePickerWithConstraints(
        context,
        TimeOfDay.fromDateTime(initialDate),
      );

      if (pickedTime != null) {
        final formattedTime = _formatTime24Hour(pickedTime);
        _updateSelectedTime(formattedTime);
      }
      return;
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: widget.minDate ?? DateTime(2000),
      lastDate: widget.maxDate ?? DateTime(2100),
      selectableDayPredicate: (DateTime date) {
        return !_isDateDisabled(date);
      },
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            primaryColor: const Color(0xFF1F1E5B),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1F1E5B),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Color(0xFF1F1E5B)),
            ),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      DateTime finalDate = pickedDate;

      if (widget.type == DatePickerType.datetime) {
        final TimeOfDay? time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(initialDate),
          builder: (BuildContext context, Widget? child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(alwaysUse24HourFormat: true),
              child: Theme(
                data: ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFF1F1E5B),
                    onPrimary: Colors.white,
                    onSurface: Colors.black,
                  ),
                  primaryColor: const Color(0xFF1F1E5B),
                  textTheme: ThemeData.light().textTheme.copyWith(),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: Color(0xFF1F1E5B),
                    ),
                  ),
                ),
                child: child!,
              ),
            );
          },
        );

        if (time != null && _isTimeInRange(time)) {
          finalDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            time.hour,
            time.minute,
          );
        } else if (time != null && !_isTimeInRange(time)) {
          String errorMessage = '';
          if (widget.minTime != null && widget.maxTime != null) {
            errorMessage =
                'Please select a time between ${_formatTime24Hour(widget.minTime!)} and ${_formatTime24Hour(widget.maxTime!)}';
          } else if (widget.minTime != null) {
            errorMessage =
                'Please select a time after ${_formatTime24Hour(widget.minTime!)}';
          } else if (widget.maxTime != null) {
            errorMessage =
                'Please select a time before ${_formatTime24Hour(widget.maxTime!)}';
          }

          if (mounted) {
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('Invalid Time'),
                  content: Text(errorMessage),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
          return;
        }
      }

      String formatted;
      switch (widget.type) {
        case DatePickerType.date:
          formatted =
              "${finalDate.day.toString().padLeft(2, '0')}/"
              "${finalDate.month.toString().padLeft(2, '0')}/"
              "${finalDate.year}";
          break;

        case DatePickerType.datetime:
          formatted =
              "${finalDate.day.toString().padLeft(2, '0')}/"
              "${finalDate.month.toString().padLeft(2, '0')}/"
              "${finalDate.year} "
              "${finalDate.hour.toString().padLeft(2, '0')}:"
              "${finalDate.minute.toString().padLeft(2, '0')}";
          break;

        default:
          formatted = '';
          break;
      }

      _updateSelectedTime(formatted);
    }
  }

  void _clearDate() {
    _updateSelectedTime(null);
  }

  Color _getColor() {
    if (widget.errorText != null) return Colors.red;
    if (_isFocused) return widget.borderColor;
    return widget.borderFocusColor;
  }

  @override
  void initState() {
    super.initState();

    if (widget.controller != null && widget.controller!.text.isNotEmpty) {
      _selectedTime = widget.controller!.text;
    } else {
      _selectedTime = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    final hasError = widget.errorText != null;
    final isOutline = widget.mode == StyleMode.outline;
    final enabled =
        widget.isLoading != null ? !widget.isLoading! : !widget.disabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.centerRight,
          children: [
            widget.mode == StyleMode.underline
                ? Text(
                  widget.label ?? '',
                  style: TextStyle(
                    color: _getColor(),
                    fontSize: isSmall ? 12 : 16,
                  ),
                )
                : const SizedBox.shrink(),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
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
                    await _pickDate();
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
                            ? Icon(widget.leading, size: isSmall ? 20 : 28)
                            : null,
                    suffixIcon: Opacity(
                      opacity: enabled ? 1 : 0.4,
                      child: IconButton(
                        onPressed: () async {
                          if (_selectedTime != null ||
                              (widget.controller?.text.isNotEmpty ?? false)) {
                            _clearDate();
                          } else {
                            if ((widget.isLoading != null
                                    ? !widget.isLoading!
                                    : true) &&
                                !widget.disabled) {
                              setState(() => _isFocused = true);
                              await _pickDate();
                              setState(() => _isFocused = false);
                            }
                          }
                        },
                        icon: Icon(
                          _selectedTime != null ||
                                  (widget.controller?.text.isNotEmpty ?? false)
                              ? Icons.clear_outlined
                              : widget.type == DatePickerType.time
                              ? Icons.access_time
                              : Icons.calendar_month_sharp,
                          color: const Color(0xFF1F1E5B),
                        ),
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
                  ),
                  child: Opacity(
                    opacity: enabled ? 1 : 0.4,
                    child: Text(
                      _selectedTime ?? widget.hint ?? '',
                      style: TextStyle(
                        fontSize: isSmall ? 16 : 18,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              widget.errorText!,
              style: TextStyle(color: Colors.red, fontSize: isSmall ? 12 : 16),
            ),
          ),
      ],
    );
  }
}

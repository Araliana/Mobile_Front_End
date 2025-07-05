import 'package:flutter/material.dart';

enum SnackbarType { success, error }

enum SnackbarPostition { top, bottom }

void showFlexibleSnackbar(
  BuildContext context,
  String message, {
  SnackbarPostition position = SnackbarPostition.top,
  SnackbarType type = SnackbarType.success,
}) {
  final overlay = Overlay.of(context);
  final backgroundColor =
      type == SnackbarType.success ? Colors.green : Colors.red;
  final icon = type == SnackbarType.success ? Icons.check_circle : Icons.error;
  final isTop = position == SnackbarPostition.top ? true : false;

  final overlayEntry = OverlayEntry(
    builder:
        (context) => Positioned(
          top: isTop ? MediaQuery.of(context).padding.top + 10 : null,
          bottom: isTop ? null : 20,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: Duration(milliseconds: 300),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        message,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
  );

  overlay.insert(overlayEntry);
  Future.delayed(Duration(seconds: 3)).then((_) => overlayEntry.remove());
}

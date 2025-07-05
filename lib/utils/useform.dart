import 'package:flutter/material.dart';

class UseForm {
  bool isSubmitted = false;
  bool isLoading = false;

  final Map<String, TextEditingController> fieldControls;
  final Map<String, String?> fieldErrors;
  final Map<String, String? Function(String)> validators;
  final Map<String, List<Map<String, String>>> match;

  UseForm({
    required List<String> fields,
    this.validators = const {},
    this.match = const {},
  }) : fieldControls = {for (var f in fields) f: TextEditingController()},
       fieldErrors = {for (var f in fields) f: null};

  TextEditingController control(String field) => fieldControls[field]!;

  String? error(String field) => fieldErrors[field];

  void setError(String field, String? error) {
    fieldErrors[field] = error;
  }

  void clear() {
    fieldControls.forEach((key, controller) => controller.clear());
    fieldErrors.updateAll((key, value) => null);
  }

  void dispose() {
    fieldControls.forEach((key, controller) => controller.dispose());
  }

  bool validate() {
    bool isValid = true;

    fieldControls.forEach((field, controller) {
      final validator = validators[field];
      if (validator != null) {
        final value = controller.text;
        final error = validator(value);
        if (error != null) {
          isValid = false;
        }
        fieldErrors[field] = error;
      }
    });

    match.forEach((field, matchFields) {
      for (var matchField in matchFields) {
        final matchFieldValue = fieldControls[field]?.text;
        final fieldValue = fieldControls[matchField["key"]]?.text;

        final matchError = validateBasic(
          key: matchField["label"]!,
          match: matchFieldValue,
          value: fieldValue!,
        );
        fieldErrors[matchField["key"]!] = matchError;
        if (matchError != null) {
          isValid = false;
        }
      }
    });

    return isValid;
  }
}

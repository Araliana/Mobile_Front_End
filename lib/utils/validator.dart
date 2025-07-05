String? validatePassword({
  String key = "Password",
  String value = "",
  int? minLength,
  int? maxLength,
  bool required = true,
}) {
  final passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).+$',
  );
  if (required && value == "") {
    return "$key is required";
  }
  if (minLength != null && value.length < minLength) {
    return "$key must have at least $key characters";
  }
  if (maxLength != null && value.length > maxLength) {
    return "$key can not have more than $key characters";
  }
  if (!passwordRegex.hasMatch(value)) {
    return '$key must include uppercase, lowercase, number & symbol';
  }
  return null;
}

String? validateEmail({
  String key = "Email",
  String value = "",
  bool required = true,
}) {
  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (required && value == "") {
    return "$key is required";
  }
  if (!emailRegex.hasMatch(value)) {
    return '$key is invalid email';
  }
  return null;
}

String? validateBasic({
  String key = "Field",
  String? match,
  String value = "",
  int? minLength,
  int? maxLength,
  String? regex,
  String? regexMessage,
  bool required = true,
}) {
  final fieldRegex = regex != null ? RegExp(regex) : null;
  if (required && value == "") {
    return "$key is required";
  }
  if (match != null && value != "" && value != match) {
    return "$key is not matched";
  }
  if (minLength != null && value.length < minLength) {
    return "$key must have at least $minLength characters";
  }
  if (maxLength != null && value.length > maxLength) {
    return "$key can not have more than $maxLength characters";
  }
  if (fieldRegex != null && !fieldRegex.hasMatch(value)) {
    return regexMessage;
  }
  return null;
}

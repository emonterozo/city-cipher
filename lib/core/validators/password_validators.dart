import 'package:formz/formz.dart';

enum PasswordError { empty, tooShort, noUppercase, noSpecialChar }

class PasswordInput extends FormzInput<String, PasswordError> {
  const PasswordInput.pure() : super.pure('');
  const PasswordInput.dirty({String value = ''}) : super.dirty(value);

  @override
  PasswordError? validator(String value) {
    if (value.isEmpty) {
      return PasswordError.empty;
    }

    if (value.length < 8) {
      return PasswordError.tooShort;
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return PasswordError.noUppercase;
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\\[\]\\/+=;`~]').hasMatch(value)) {
      return PasswordError.noSpecialChar;
    }

    return null;
  }

  String? get errorMessage {
    switch (error) {
      case PasswordError.empty:
        return "Password is required";
      case PasswordError.tooShort:
        return "Must be at least 8 characters";
      case PasswordError.noUppercase:
        return "Must contain at least 1 uppercase letter";
      case PasswordError.noSpecialChar:
        return "Must contain at least 1 special character";
      default:
        return null;
    }
  }
}

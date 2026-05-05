import 'package:formz/formz.dart';

enum MobileNumberError { empty, invalidFormat }

class MobileNumberInput extends FormzInput<String, MobileNumberError> {
  const MobileNumberInput.pure() : super.pure('');
  const MobileNumberInput.dirty({String value = ''}) : super.dirty(value);

  @override
  MobileNumberError? validator(String value) {
    if (value.isEmpty) {
      return MobileNumberError.empty;
    }

    final isNumeric = RegExp(r'^[0-9]+$').hasMatch(value);

    if (!value.startsWith('09') || value.length != 11 || !isNumeric) {
      return MobileNumberError.invalidFormat;
    }

    return null;
  }

  String? get errorMessage {
    switch (error) {
      case MobileNumberError.empty:
        return "Mobile number is required";
      case MobileNumberError.invalidFormat:
        return "Enter a valid 11-digit number starting with 09";
      default:
        return null;
    }
  }
}

import 'package:formz/formz.dart';

enum NameInputError { empty, tooShort }

class NameInput extends FormzInput<String, NameInputError> {
  final String fieldName;

  const NameInput.pure({this.fieldName = "Name"}) : super.pure('');

  const NameInput.dirty({this.fieldName = "Name", String value = ''})
    : super.dirty(value);

  @override
  NameInputError? validator(String value) {
    if (value.isEmpty) return NameInputError.empty;
    if (value.length < 2) return NameInputError.tooShort;
    return null;
  }

  String? get errorMessage {
    switch (error) {
      case NameInputError.empty:
        return "$fieldName is required";
      case NameInputError.tooShort:
        return "$fieldName is too short";
      default:
        return null;
    }
  }
}
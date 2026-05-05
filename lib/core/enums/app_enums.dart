enum AppState { loading, loaded, error, initialize }

enum OtpType {
  registration('registration'),
  forgot('forgot'),
  unknown('UNKNOWN');

  final String value;
  const OtpType(this.value);

  static OtpType fromString(String value) {
    return OtpType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OtpType.unknown,
    );
  }
}

enum RewardRuleType {
  minPurchase('MIN_PURCHASE'),
  maxDiscount('MAX_DISCOUNT'),
  unknown('UNKNOWN');

  final String value;
  const RewardRuleType(this.value);

  static RewardRuleType fromString(String value) {
    return RewardRuleType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => RewardRuleType.unknown,
    );
  }
}

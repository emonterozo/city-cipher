enum AppState { loading, loaded, error }

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

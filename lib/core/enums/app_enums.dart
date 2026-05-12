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

enum Rank {
  explorer('explorer'),
  local('local'),
  elite('elite'),
  expert('expert'),
  unknown('UNKNOWN');

  final String value;
  const Rank(this.value);

  static Rank fromString(String value) {
    return Rank.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Rank.unknown,
    );
  }
}

enum UserRewardStatus {
  active('active'),
  used('used'),
  expired('expired'),
  unknown('UNKNOWN');

  final String value;
  const UserRewardStatus(this.value);

  static UserRewardStatus fromString(String value) {
    return UserRewardStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UserRewardStatus.unknown,
    );
  }

  int get tabIndex {
    switch (this) {
      case UserRewardStatus.active:
        return 0;
      case UserRewardStatus.used:
        return 1;
      case UserRewardStatus.expired:
        return 2;
      case UserRewardStatus.unknown:
        return 0;
    }
  }

  String get display {
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  static UserRewardStatus fromTabIndex(int index) {
    switch (index) {
      case 1:
        return UserRewardStatus.used;
      case 2:
        return UserRewardStatus.expired;
      default:
        return UserRewardStatus.active;
    }
  }
}

import 'package:city_cipher/models/reward/user_reward_model.dart';
import 'package:city_cipher/models/store/store_model.dart';

class UserRewardDetails {
  final UserReward userReward;
  final Store store;

  UserRewardDetails({required this.userReward, required this.store});

  factory UserRewardDetails.fromJson(Map<String, dynamic> json) {
    final rewardJson = json['reward_id'] ?? {};
    final storeJson = rewardJson['store_id'] ?? {};

    return UserRewardDetails(
      userReward: UserReward.fromJson({...json, 'reward_id': rewardJson}),
      store: Store.fromJson(storeJson),
    );
  }

  factory UserRewardDetails.empty() {
    return UserRewardDetails(
      userReward: UserReward.empty(),
      store: Store.empty(),
    );
  }
}

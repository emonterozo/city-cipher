import 'package:city_cipher/main.dart';
import 'package:city_cipher/models/reward/user_reward_details_model.dart';
import 'package:city_cipher/shared/utils/app_dialog.dart';
import 'package:city_cipher/shared/widgets/reward_detail.dart';
import 'package:city_cipher/shared/widgets/reward_detail_loading.dart';
import 'package:flutter/material.dart';
import 'package:city_cipher/core/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shimmer/shimmer.dart';
import '../core/enums/app_enums.dart';
import '../core/providers/api_service_provider.dart';
import '../shared/widgets/custom_app_bar.dart';
import '../shared/widgets/error_state_view.dart';

class UserRewardDetailsScreen extends ConsumerStatefulWidget {
  final String userRewardId;
  const UserRewardDetailsScreen({super.key, required this.userRewardId});

  @override
  ConsumerState<UserRewardDetailsScreen> createState() =>
      _UserRewardDetailsScreenState();
}

class _UserRewardDetailsScreenState
    extends ConsumerState<UserRewardDetailsScreen> {
  UserRewardDetails? userRewardDetails;
  AppState rewardState = AppState.loading;
  AppState claimedState = AppState.initialize;

  Future<void> fetchUserRewardDetails() async {
    setState(() => rewardState = AppState.loading);

    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.getUserRewardDetails(
        id: widget.userRewardId,
      );

      if (!mounted) return;

      if (response.statusCode == 401) {
        AppDialogs.sessionExpired(
          context,
          ref: ref,
          secondaryText: "Back",
          onSecondary: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => MainNavigation()),
            );
          },
        );
      }

      if (response.success) {
        setState(() {
          userRewardDetails = response.data;
          rewardState = AppState.loaded;
        });
      } else {
        setState(() => rewardState = AppState.error);
      }
    } catch (e) {
      setState(() => rewardState = AppState.error);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserRewardDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CityCipherTheme.background,
      appBar: CustomAppBar(title: "Reward Details", showBack: true),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (rewardState) {
      case AppState.loading:
        return Column(
          children: [
            Shimmer.fromColors(
              baseColor: const Color(0xFF1E293B),
              highlightColor: const Color(0xFF334155),
              child: Container(
                margin: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 10,
                  bottom: 10,
                ),
                height: 167,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: RewardDetailLoading(),
            ),
          ],
        );
      case AppState.error:
        return ErrorStateView(onRetry: () => fetchUserRewardDetails());
      case AppState.loaded:
      case AppState.initialize:
        return userRewardDetails == null
            ? const SizedBox()
            : _buildRewardContent();
    }
  }

  Widget _buildRewardContent() {
    final r = userRewardDetails;
    if (r == null) return const SizedBox();

    final bool isInactive = r.userReward.status == UserRewardStatus.active.value
        ? false
        : true;

    return Stack(
      children: [
        RefreshIndicator(
          color: CityCipherTheme.background,
          onRefresh: fetchUserRewardDetails,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: RewardDetail(reward: r.userReward.reward),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        // Stack allows the overlay to sit on top of the QR
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // The actual QR Code
                            Opacity(
                              opacity: isInactive
                                  ? 0.2
                                  : 1.0, // Fade out if inactive
                              child: QrImageView(
                                data: 'asd',
                                version: QrVersions.auto,
                                size: 300,
                                eyeStyle: QrEyeStyle(
                                  eyeShape: QrEyeShape.circle,
                                  color: CityCipherTheme.foreground.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                                dataModuleStyle: QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.circle,
                                  color: CityCipherTheme.foreground.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                              ),
                            ),
                            // The Overlay Text
                            if (isInactive)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: CityCipherTheme.background.withValues(
                                    alpha: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "Already ${UserRewardStatus.fromString(r.userReward.status).display}",
                                  style: const TextStyle(
                                    color: CityCipherTheme.foreground,
                                    fontFamily: CityCipherTheme.fontFamily,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

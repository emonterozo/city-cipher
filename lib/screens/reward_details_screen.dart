import 'package:city_cipher/core/providers/auth_provider.dart';
import 'package:city_cipher/core/providers/game_provider.dart';
import 'package:city_cipher/main.dart';
import 'package:city_cipher/shared/utils/app_dialog.dart';
import 'package:city_cipher/shared/utils/toast.dart';
import 'package:city_cipher/shared/widgets/reward_detail.dart';
import 'package:city_cipher/shared/widgets/reward_detail_loading.dart';
import 'package:flutter/material.dart';
import 'package:city_cipher/core/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../core/enums/app_enums.dart';
import '../core/providers/api_service_provider.dart';
import '../models/reward/reward_model.dart';
import '../shared/widgets/custom_app_bar.dart';
import '../shared/widgets/error_state_view.dart';

class RewardDetailsScreen extends ConsumerStatefulWidget {
  final String rewardId;
  const RewardDetailsScreen({super.key, required this.rewardId});

  @override
  ConsumerState<RewardDetailsScreen> createState() =>
      _RewardDetailsScreenState();
}

class _RewardDetailsScreenState extends ConsumerState<RewardDetailsScreen> {
  Reward? reward;
  AppState rewardState = AppState.loading;
  AppState claimedState = AppState.initialize;

  Future<void> fetchRewardDetails() async {
    setState(() => rewardState = AppState.loading);

    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.getRewardDetails(widget.rewardId);

      if (response.success) {
        setState(() {
          reward = response.data;
          rewardState = AppState.loaded;
        });
      } else {
        setState(() => rewardState = AppState.error);
      }
    } catch (e) {
      setState(() => rewardState = AppState.error);
    }
  }

  Future<void> claimedReward() async {
    setState(() => claimedState = AppState.loading);

    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.claimedReward(widget.rewardId);
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
        return;
      }

      if (response.success) {
        setState(() {
          claimedState = AppState.loaded;
        });
        fetchRewardDetails();
      } else {
        if (response.message == 'This reward is no longer available.') {
          fetchRewardDetails();
        }
        setState(() => claimedState = AppState.error);
      }
      ToastHelper.show(context, message: response.message);
    } catch (e) {
      ToastHelper.show(context);
      setState(() => claimedState = AppState.error);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRewardDetails();
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
        return ErrorStateView(onRetry: () => fetchRewardDetails());
      case AppState.loaded:
      case AppState.initialize:
        return reward == null ? const SizedBox() : _buildRewardContent();
    }
  }

  Widget _buildRewardContent() {
    final isAuthenticated = ref.watch(authProvider).isAuthenticated;
    final userGameData = ref.watch(gameProvider);
    final earnedPoints = userGameData?.earnedPoints ?? 0;
    final r = reward;
    if (r == null) return const SizedBox();

    return Stack(
      children: [
        RefreshIndicator(
          color: CityCipherTheme.background,
          onRefresh: fetchRewardDetails,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _rewardCard(),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: RewardDetail(reward: r),
                ),
              ],
            ),
          ),
        ),
        isAuthenticated &&
                earnedPoints >= r.pointsCost &&
                r.claimedQuantity < r.totalQuantity
            ? Align(
                alignment: Alignment.bottomCenter,
                child: _buildClaimButton(),
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  Widget _rewardCard() {
    final int currentClaimed = reward?.claimedQuantity ?? 0;
    final int maxSlot = reward?.totalQuantity ?? 0;
    final String pointsLabel = NumberFormat.decimalPattern().format(
      reward?.pointsCost ?? 0,
    );
    const int totalSegments = 7;

    double progress = (currentClaimed / maxSlot).clamp(0.0, 1.0);

    String leftLabel = "Claimed $currentClaimed";
    String rightLabel = "Total $maxSlot";

    int filledSegments = (progress * totalSegments).round();

    return IntrinsicHeight(
      child: Container(
        margin: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: CityCipherTheme.border.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "REQUIRED POINTS",
                      style: TextStyle(
                        color: CityCipherTheme.mutedForeground,
                        fontFamily: CityCipherTheme.fontFamily,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pointsLabel,
                      style: const TextStyle(
                        color: CityCipherTheme.primary,
                        fontFamily: CityCipherTheme.fontFamily,
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          leftLabel,
                          style: const TextStyle(
                            color: CityCipherTheme.foreground,
                            fontFamily: CityCipherTheme.fontFamily,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          rightLabel,
                          style: const TextStyle(
                            color: CityCipherTheme.foreground,
                            fontFamily: CityCipherTheme.fontFamily,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(totalSegments, (index) {
                        return Expanded(
                          child: Container(
                            height: 8,
                            margin: EdgeInsets.only(
                              right: index == totalSegments - 1 ? 0 : 6,
                            ),
                            decoration: BoxDecoration(
                              color: index < filledSegments
                                  ? CityCipherTheme.primary
                                  : CityCipherTheme.primary.withValues(
                                      alpha: 0.2,
                                    ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClaimButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: CityCipherTheme.background),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: claimedState == AppState.loading ? null : claimedReward,
          style: ElevatedButton.styleFrom(
            backgroundColor: CityCipherTheme.primary,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: claimedState == AppState.loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: CityCipherTheme.primary,
                  ),
                )
              : const Text(
                  "CLAIM REWARD",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    color: CityCipherTheme.primaryForeground,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}

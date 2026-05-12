import 'package:city_cipher/core/enums/app_enums.dart';
import 'package:city_cipher/core/providers/api_service_provider.dart';
import 'package:city_cipher/core/providers/auth_provider.dart';
import 'package:city_cipher/main.dart';
import 'package:city_cipher/models/reward/user_reward_model.dart';
import 'package:city_cipher/screens/user_reward_details_screen.dart';
import 'package:city_cipher/shared/utils/app_dialog.dart';
import 'package:city_cipher/shared/widgets/custom_app_bar.dart';
import 'package:city_cipher/shared/widgets/reward_card_loading.dart';
import 'package:city_cipher/shared/widgets/sliver_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../core/theme.dart';

class RewardsTab extends ConsumerStatefulWidget {
  const RewardsTab({super.key});

  @override
  ConsumerState<RewardsTab> createState() => RewardsTabState();
}

class RewardsTabState extends ConsumerState<RewardsTab> {
  UserRewardStatus status = UserRewardStatus.active;
  int _page = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  List<UserReward> userRewards = [];
  AppState userRewardState = AppState.initialize;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  void sessionExpired() {
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

  Future<void> fetchUserRewards({bool reset = false}) async {
    if (reset) {
      _page = 1;
      _hasMore = true;
      userRewards = [];
    }

    setState(() {
      userRewardState = AppState.loading;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.getUserRewards(
        page: _page,
        limit: 10,
        status: status,
      );

      if (response.statusCode == 401) {
        sessionExpired();
      }

      if (response.success) {
        setState(() {
          userRewards.addAll(response.data);

          _hasMore = _page < response.meta.totalPages;
          userRewardState = AppState.loaded;
        });
      } else {
        setState(() {
          userRewardState = AppState.error;
        });
      }
    } catch (e) {
      setState(() {
        userRewardState = AppState.error;
      });
    }
  }

  Future<void> fetchMoreUserRewards() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    _page++;

    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.getUserRewards(page: _page, limit: 10);

      if (response.statusCode == 401) {
        sessionExpired();
      }

      if (response.success) {
        setState(() {
          userRewards.addAll(response.data);
          _hasMore = _page < response.meta.totalPages;
        });
      }
    } catch (e) {
      _page--;
    }

    setState(() {
      _isLoadingMore = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        fetchMoreUserRewards();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: CityCipherTheme.background,
      appBar: CustomAppBar(title: "My Rewards", showBack: false),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: CityCipherTheme.background,
            elevation: 0,
            toolbarHeight: 0,
            title: const SizedBox.shrink(),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: EdgeInsetsGeometry.only(left: 15, right: 15),
                child: RewardSegmentedControl(
                  selectedIndex: status.tabIndex,
                  onChanged: (index) {
                    setState(() {
                      status = UserRewardStatus.fromTabIndex(index);
                    });

                    fetchUserRewards(reset: true);
                  },
                ),
              ),
            ),
          ),

          if (userRewardState == AppState.loading) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 25)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: Column(
                  children: [...List.generate(5, (_) => RewardCardLoading())],
                ),
              ),
            ),
          ],

          if (!user.isAuthenticated)
            SliverStateView(
              description:
                  "You’re not logged in yet. Log in to play, earn points, and claim exciting rewards!",
            ),

          if (userRewardState == AppState.error && user.isAuthenticated)
            SliverStateView(
              description: "Something went wrong.\nPlease try again.",
              onRetry: () => fetchUserRewards(reset: true),
            ),

          if (userRewardState == AppState.loaded && userRewards.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/error/error.png',
                        width: 300,
                        height: 250,
                        fit: BoxFit.contain,
                      ),
                      Text(
                        "No rewards yet. Start playing, earn points, and claim amazing rewards!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "Poppins",
                          color: CityCipherTheme.mutedForeground.withValues(
                            alpha: 0.5,
                          ),
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (userRewardState == AppState.loaded && userRewards.isNotEmpty) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 25)),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final userReward = userRewards[index];
                return Container(
                  margin: const EdgeInsets.only(
                    bottom: 16,
                    left: 24,
                    right: 24,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserRewardDetailsScreen(
                            userRewardId: userReward.id,
                          ),
                        ),
                      );
                    },
                    child: Container(
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
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.ticketPercent,
                              size: 45,
                              color: CityCipherTheme.primary,
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userReward.reward.title,
                                    style: TextStyle(
                                      color: CityCipherTheme.foreground,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      fontFamily: "Poppins",
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    status == UserRewardStatus.active
                                        ? "Expires on ${DateFormat('MMM dd, yyyy').format(userReward.expiredAt!)}"
                                        : status == UserRewardStatus.used
                                        ? "Used on ${DateFormat('MMM dd, yyyy').format(userReward.updatedAt!)}"
                                        : "Expired on ${DateFormat('MMM dd, yyyy').format(userReward.expiredAt!)}",
                                    style: TextStyle(
                                      color: CityCipherTheme.mutedForeground,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      fontFamily: "Poppins",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              LucideIcons.chevronRight,
                              size: 25,
                              color: CityCipherTheme.mutedForeground,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }, childCount: userRewards.length),
            ),
          ],
          if (_isLoadingMore && userRewardState == AppState.loaded) ...[
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: CircularProgressIndicator(
                    color: CityCipherTheme.primary,
                  ),
                ),
              ),
            ),
          ],
          if (userRewardState != AppState.error && userRewards.isNotEmpty) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 150)),
          ],
        ],
      ),
    );
  }
}

class RewardSegmentedControl extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const RewardSegmentedControl({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> tabs = ["Active", "Used", "Expired"];

    return Container(
      height: 50,
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          double tabWidth = constraints.maxWidth / tabs.length;
          return Stack(
            children: [
              // Animated Background Pill
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                left: selectedIndex * tabWidth,
                width: tabWidth,
                height: 50,
                child: Container(
                  margin: const EdgeInsets.only(
                    top: 2,
                    left: 4,
                    right: 4,
                    bottom: 6,
                  ),
                  decoration: BoxDecoration(
                    color: CityCipherTheme.primary,
                    borderRadius: BorderRadius.circular(21),
                  ),
                ),
              ),
              // Tab Labels
              Row(
                children: List.generate(tabs.length, (index) {
                  bool isSelected = selectedIndex == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onChanged(index),
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: Text(
                          tabs[index],
                          style: TextStyle(
                            fontFamily: "Poppins",
                            color: isSelected
                                ? CityCipherTheme.primaryForeground
                                : CityCipherTheme.mutedForeground,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

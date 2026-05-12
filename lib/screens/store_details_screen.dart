import 'package:city_cipher/screens/reward_details_screen.dart';
import 'package:city_cipher/shared/widgets/reward_card_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:city_cipher/core/theme.dart';
import 'package:shimmer/shimmer.dart';
import '../core/link_service.dart';
import '../core/enums/app_enums.dart';
import '../core/providers/api_service_provider.dart';
import '../core/utils/time_utils.dart';
import '../models/reward/reward_model.dart';
import '../models/store/store_model.dart';
import '../shared/widgets/error_state_view.dart';

class StoreDetailsScreen extends ConsumerStatefulWidget {
  final String storeId;
  const StoreDetailsScreen({super.key, required this.storeId});

  @override
  ConsumerState<StoreDetailsScreen> createState() => _StoreDetailsScreenState();
}

class _StoreDetailsScreenState extends ConsumerState<StoreDetailsScreen> {
  Store? store;
  AppState storeState = AppState.loading;

  int _page = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  List<Reward> rewards = [];
  final ScrollController _scrollController = ScrollController();

  Future<void> fetchStoreDetails() async {
    setState(() {
      storeState = AppState.loading;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.getStoreDetails(widget.storeId);

      setState(() {
        if (response.success) {
          store = response.store;
          setState(() {
            rewards.addAll(response.rewards);
            _hasMore = _page < response.meta.totalPages;
          });
          storeState = AppState.loaded;
        } else {
          storeState = AppState.error;
        }
      });
    } catch (e) {
      setState(() {
        storeState = AppState.error;
      });
    }
  }

  Future<void> fetchMoreRewards() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    _page++;

    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.getStoreRewards(
        page: _page,
        limit: 10,
        storeId: widget.storeId,
      );

      if (response.success) {
        setState(() {
          rewards.addAll(response.data);
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
  void initState() {
    super.initState();
    fetchStoreDetails();

    _scrollController.addListener(() {
      if (storeState == AppState.loaded &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200) {
        fetchMoreRewards();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (storeState == AppState.error) {
      return Scaffold(
        backgroundColor: CityCipherTheme.background,

        body: Stack(
          children: [
            Positioned(
              top: 64,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                child: IconButton(
                  icon: const Icon(
                    LucideIcons.chevronLeft,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            ErrorStateView(onRetry: () => fetchStoreDetails()),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: CityCipherTheme.background,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeroAppBar(store),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    [
                      Column(
                        children: [
                          storeState == AppState.loading
                              ? Shimmer.fromColors(
                                  baseColor: const Color(0xFF1E293B),
                                  highlightColor: const Color(0xFF334155),
                                  child: Container(
                                    width: double.infinity,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                )
                              : Text(
                                  store?.description ?? '',
                                  style: const TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: CityCipherTheme.mutedForeground,
                                    letterSpacing: 0.6,
                                    height: 1.5,
                                  ),
                                ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      if (storeState == AppState.loading) ...[
                        Shimmer.fromColors(
                          baseColor: const Color(0xFF1E293B),
                          highlightColor: const Color(0xFF334155),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: CityCipherTheme.border.withValues(
                                  alpha: 0.5,
                                ),
                                width: 1.5,
                              ),
                            ),

                            child: Padding(
                              padding: EdgeInsetsGeometry.only(
                                top: 12,
                                bottom: 12,
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    LucideIcons.globe,
                                    size: 20,
                                    color: CityCipherTheme.secondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                      if (store?.website != null &&
                          store!.website!.isNotEmpty &&
                          storeState == AppState.loaded) ...[
                        GestureDetector(
                          onTap: () => {
                            LinkService.openUrl(store?.website ?? ''),
                          },
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: CityCipherTheme.border.withValues(
                                  alpha: 0.5,
                                ),
                                width: 1.5,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsetsGeometry.only(
                                top: 12,
                                bottom: 12,
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    LucideIcons.globe,
                                    size: 20,
                                    color: CityCipherTheme.secondary,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Visit Website',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "Poppins",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                      Text(
                        "Branches",
                        style: const TextStyle(
                          color: CityCipherTheme.foreground,
                          fontFamily: "Poppins",
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (storeState == AppState.loading)
                        Shimmer.fromColors(
                          baseColor: const Color(0xFF1E293B),
                          highlightColor: const Color(0xFF334155),
                          child: Container(
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: CityCipherTheme.border.withValues(
                                  alpha: 0.5,
                                ),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                    ] +
                    (store?.branches ?? [])
                        .map((branch) => BranchCard(branch: branch))
                        .toList() +
                    [
                      const SizedBox(height: 30),
                      Text(
                        "Rewards",
                        style: const TextStyle(
                          color: CityCipherTheme.foreground,
                          fontFamily: "Poppins",
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (storeState == AppState.loading)
                        ...List.generate(3, (_) => RewardCardLoading()),
                      if (storeState == AppState.loaded && rewards.isEmpty) ...[
                        Center(
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
                                "No rewards available at the moment. Check back soon—we’ll notify you when new rewards arrive.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  color: CityCipherTheme.mutedForeground
                                      .withValues(alpha: 0.5),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 60),
                      ],
                    ],
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final reward = rewards[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16, left: 24, right: 24),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RewardDetailsScreen(rewardId: reward.id),
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
                                  reward.title,
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
                                  "${NumberFormat.decimalPattern().format(reward.pointsCost)} POINTS",
                                  style: TextStyle(
                                    color: CityCipherTheme.primary,
                                    fontWeight: FontWeight.w700,
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
            }, childCount: rewards.length),
          ),
          if (_isLoadingMore && storeState == AppState.loaded)
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
      ),
    );
  }

  Widget _buildHeroAppBar(Store? store) {
    if (store == null) {
      return SliverAppBar(
        expandedHeight: 330,
        backgroundColor: CityCipherTheme.background,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 4.0),
          child: IconButton(
            icon: const Icon(
              LucideIcons.chevronLeft,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        flexibleSpace: FlexibleSpaceBar(
          background: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 80,
                child: Container(
                  color: CityCipherTheme.background,
                  padding: const EdgeInsets.only(left: 125, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Color(0xFF1E293B),
                        highlightColor: Color(0xFF334155),
                        child: Container(
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Shimmer.fromColors(
                        baseColor: Color(0xFF1E293B),
                        highlightColor: Color(0xFF334155),
                        child: Container(
                          height: 20,
                          margin: EdgeInsets.only(right: 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 16,
                child: Shimmer.fromColors(
                  baseColor: Color(0xFF1E293B),
                  highlightColor: Color(0xFF334155),
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Color(0xFF131A26),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final PageController controller = PageController();
    int currentIndex = 0;

    return StatefulBuilder(
      builder: (context, setState) {
        return SliverAppBar(
          pinned: true,
          expandedHeight: 330,
          elevation: 0,
          backgroundColor: CityCipherTheme.background,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 4.0),
            child: IconButton(
              icon: const Icon(
                LucideIcons.chevronLeft,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0, top: 4.0),
              child: IconButton(
                icon: const Icon(
                  LucideIcons.share2,
                  color: CityCipherTheme.foreground,
                  size: 30,
                ),
                onPressed: () {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 4.0),
              child: IconButton(
                icon: const Icon(
                  LucideIcons.heart,
                  color: CityCipherTheme.primary,
                  size: 30,
                ),
                onPressed: () {},
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              children: [
                Positioned.fill(
                  child: PageView.builder(
                    controller: controller,
                    itemCount: store.images.length,
                    onPageChanged: (index) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final img = store.images[index];

                      return GestureDetector(
                        onTap: () {
                          _openFullScreenGallery(store, index);
                        },
                        child: Image.network(
                          img,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      );
                    },
                  ),
                ),

                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(store.images.length, (i) {
                      final isActive = i == currentIndex;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isActive ? 16 : 8,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isActive
                              ? CityCipherTheme.primary
                              : CityCipherTheme.foreground.withValues(
                                  alpha: 0.3,
                                ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }),
                  ),
                ),

                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 80,
                  child: Container(
                    color: CityCipherTheme.background,
                    padding: const EdgeInsets.only(left: 125, right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            fontFamily: "Poppins",
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          store.category.toUpperCase(),
                          style: const TextStyle(
                            color: CityCipherTheme.secondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Poppins",
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  bottom: 20,
                  left: 16,
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF131A26),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(store.logo, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openFullScreenGallery(Store store, int initialIndex) {
    int index = initialIndex;

    showDialog(
      context: context,
      barrierColor: CityCipherTheme.background,
      builder: (_) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: CityCipherTheme.background,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
          child: Scaffold(
            backgroundColor: CityCipherTheme.background,
            body: Stack(
              children: [
                PageView.builder(
                  controller: PageController(initialPage: index),
                  onPageChanged: (i) {
                    index = i;
                  },
                  itemCount: store.images.length,
                  itemBuilder: (context, i) {
                    return Center(child: Image.network(store.images[i]));
                  },
                ),
                Positioned(
                  top: 40,
                  right: 16,
                  child: SafeArea(
                    child: IconButton(
                      icon: const Icon(
                        LucideIcons.x,
                        color: CityCipherTheme.foreground,
                        size: 30,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class BranchCard extends StatefulWidget {
  final Branch branch;

  const BranchCard({super.key, required this.branch});

  @override
  State<BranchCard> createState() => _BranchCardState();
}

class _BranchCardState extends State<BranchCard> {
  bool showHours = false;

  @override
  Widget build(BuildContext context) {
    final branch = widget.branch;
    final coordinates = branch.location.coordinates;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16),
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
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    branch.address,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: "Poppins",
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 5),
                Row(
                  children: branch.socials.map((s) {
                    const socialIcons = {
                      "facebook": FontAwesomeIcons.facebook,
                      "instagram": FontAwesomeIcons.instagram,
                      "tiktok": FontAwesomeIcons.tiktok,
                    };
                    final icon = socialIcons[s.social];

                    if (icon == null) return const SizedBox();

                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: InkWell(
                        onTap: () {
                          LinkService.openUrl(s.url);
                        },
                        child: FaIcon(
                          icon,
                          size: 19,
                          color: CityCipherTheme.mutedForeground,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                LinkService.openMaps(coordinates[1], coordinates[0]);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.mapPin,
                    size: 18,
                    color: CityCipherTheme.secondary,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 1),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: CityCipherTheme.secondary,
                              width: 0.8,
                            ),
                          ),
                        ),
                        child: Text(
                          branch.address,
                          style: const TextStyle(
                            color: CityCipherTheme.secondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Poppins",
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                setState(() {
                  showHours = !showHours;
                });
              },
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.clock,
                          size: 18,
                          color: CityCipherTheme.primary,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            TimeUtils.getStatus(branch.openingHours),
                            style: const TextStyle(
                              color: CityCipherTheme.mutedForeground,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              fontFamily: "Poppins",
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    showHours ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                    size: 18,
                    color: CityCipherTheme.mutedForeground,
                  ),
                ],
              ),
            ),
            if (showHours) ...[
              const SizedBox(height: 10),
              Divider(color: CityCipherTheme.border, thickness: 1),
              const SizedBox(height: 10),
              Column(
                children: branch.openingHours.map((h) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          h.day.toUpperCase(),
                          style: const TextStyle(
                            color: CityCipherTheme.mutedForeground,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Poppins",
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "${TimeUtils.formatTime(h.open)} - ${TimeUtils.formatTime(h.close)}",
                          style: const TextStyle(
                            color: CityCipherTheme.foreground,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: "Poppins",
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

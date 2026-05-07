import 'package:city_cipher/core/providers/game_provider.dart';
import 'package:city_cipher/models/gameConfig/game_config_model.dart';
import 'package:city_cipher/screens/store_list_screen.dart';
import 'package:city_cipher/shared/widgets/store_card.dart';
import 'package:city_cipher/shared/widgets/store_card_loading_grid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/link_service.dart';
import '../core/enums/app_enums.dart';
import '../core/providers/api_service_provider.dart';
import '../core/providers/game_config_provider.dart';
import '../models/promotion/promotion_model.dart';
import '../models/store/store_model.dart';
import '../core/theme.dart';
import '../core/app_typography.dart';
import '../shared/widgets/error_state_view.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  List<Promotion> promotions = [];
  AppState promotionState = AppState.loading;

  List<Store> stores = [];
  AppState storeState = AppState.loading;

  final PageController _pageController = PageController();
  int _currentPage = 0;

  Future<void> fetchPromotions() async {
    setState(() {
      promotionState = AppState.loading;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.getPromotions();

      setState(() {
        if (response.success) {
          promotions = response.data;
          promotionState = AppState.loaded;
        } else {
          promotionState = AppState.error;
        }
      });
    } catch (e) {
      setState(() {
        promotionState = AppState.error;
      });
    }
  }

  Future<void> fetchStores() async {
    setState(() {
      storeState = AppState.loading;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.getStores(limit: 4);

      setState(() {
        if (response.success) {
          stores = response.data;
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

  @override
  void initState() {
    super.initState();
    fetchPromotions();
    fetchStores();
  }

  @override
  Widget build(BuildContext context) {
    final userGameData = ref.watch(gameProvider);
    final gameConfig = ref.read(gameConfigProvider);

    return Scaffold(
      backgroundColor: CityCipherTheme.background,
      appBar: _AppHeader(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        children: [
          _profileCard(userGameData, gameConfig),
          const SizedBox(height: 30),
          Text(
            "Featured Deals",
            style: TextStyle(
              color: CityCipherTheme.foreground,
              fontFamily: "Poppins",
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              SizedBox(
                height: 200,
                child: Builder(
                  builder: (context) {
                    if (promotionState == AppState.loading) {
                      return Shimmer.fromColors(
                        baseColor: const Color(0xFF1E293B),
                        highlightColor: const Color(0xFF334155),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (promotionState == AppState.error) {
                      return Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Something went wrong.\nPlease try again.",
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: CityCipherTheme.mutedForeground,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 13),
                              TextButton(
                                onPressed: fetchPromotions,
                                style: TextButton.styleFrom(
                                  backgroundColor: CityCipherTheme.primary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 70,
                                  ),
                                ),
                                child: Text(
                                  "Try again",
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: CityCipherTheme.background,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (promotions.isEmpty) {
                      return SizedBox(
                        width: double.infinity,
                        child: _promoBanner(
                          Promotion(
                            id: "1",
                            label: "No promo",
                            title: "No available promo",
                            banner:
                                "https://i.ibb.co/rKgCNqhq/Gemini-Generated-Image-j8zca1j8zca1j8zc.png",
                            url: "",
                          ),
                        ),
                      );
                    }

                    return PageView.builder(
                      controller: _pageController,
                      itemCount: promotions.length,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      itemBuilder: (context, index) {
                        return _promoBanner(promotions[index]);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  promotions.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? CityCipherTheme.primary
                          : CityCipherTheme.foreground.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Partner Stores",
                style: TextStyle(
                  color: CityCipherTheme.foreground,
                  fontFamily: "Poppins",
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StoreListScreen()),
                  );
                },
                iconAlignment: IconAlignment.end,
                icon: const Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: CityCipherTheme.secondary,
                ),
                label: const Text(
                  "View All",
                  style: TextStyle(
                    color: CityCipherTheme.secondary,
                    fontFamily: "Poppins",
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (storeState == AppState.loading) StoreCardLoadingGrid(),
          if (storeState == AppState.error) ...[
            ErrorStateView(onRetry: fetchStores),
            const SizedBox(height: 150),
          ],
          if (storeState == AppState.loaded) ...[
            _storeGrid(),
            const SizedBox(height: 50),
          ],
        ],
      ),
    );
  }

  Widget _profileCard(GameState userGameData, GameConfig? gameConfig) {
    final int currentUserLevel = userGameData.currentLevel;
    final rankConfig = gameConfig?.getRankByLevel(currentUserLevel);

    final int maxGameLevel = gameConfig?.globalSettings.totalLevels ?? 0;
    final String pointsLabel = NumberFormat.decimalPattern().format(
      userGameData.earnedPoints,
    );
    const int step = 50;
    const int totalSegments = 5;

    double progress;
    String leftLabel;
    String rightLabel;
    String currentRank = rankConfig?.rank.value ?? '';

    if (currentUserLevel >= maxGameLevel) {
      leftLabel = "Lvl $maxGameLevel";
      rightLabel = "MAX";
      progress = 1.0;
    } else {
      int floorLevel = (currentUserLevel ~/ step) * step;
      int ceilingLevel = floorLevel + step;

      leftLabel = "Lvl $currentUserLevel";
      rightLabel = "Lvl $ceilingLevel";

      progress = ((currentUserLevel - floorLevel) / step).clamp(0.0, 1.0);
    }

    int filledSegments = (progress * totalSegments).round();

    return IntrinsicHeight(
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
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TOTAL POINTS",
                      style: TextStyle(
                        color: CityCipherTheme.mutedForeground,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pointsLabel,
                      style: TextStyle(
                        color: CityCipherTheme.primary,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w700,
                        fontSize: 40,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          leftLabel,
                          style: const TextStyle(
                            color: CityCipherTheme.foreground,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          rightLabel,
                          style: const TextStyle(
                            color: CityCipherTheme.foreground,
                            fontFamily: "Poppins",
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
              const SizedBox(width: 5),
              VerticalDivider(
                color: CityCipherTheme.border,
                thickness: 2,
                indent: 10,
                endIndent: 10,
              ),

              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CityCipherTheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.star,
                        color: CityCipherTheme.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentRank.toUpperCase(),
                      style: const TextStyle(
                        color: CityCipherTheme.foreground,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      "RANK",
                      style: TextStyle(
                        color: CityCipherTheme.mutedForeground,
                        fontFamily: "Poppins",
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
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

  Widget _promoBanner(Promotion promotion) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                promotion.banner,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[100],
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.imageOff,
                        color: CityCipherTheme.mutedForeground,
                        size: 45,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Image failed to load",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          color: CityCipherTheme.mutedForeground,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: InkWell(
                onTap: () {
                  LinkService.openUrl(promotion.url);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: CityCipherTheme.background.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        "Learn More",
                        style: TextStyle(
                          color: CityCipherTheme.foreground,
                          fontFamily: "Poppins",
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        LucideIcons.chevronRight,
                        color: CityCipherTheme.foreground,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: CityCipherTheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      promotion.label.toUpperCase(),
                      style: TextStyle(
                        fontFamily: "Poppins",
                        color: CityCipherTheme.primaryForeground,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    promotion.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: "Poppins",
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _storeGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 0.88,
      children: stores.map((s) => StoreCard(store: s)).toList(),
    );
  }
}

class _AppHeader extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {},
              child: Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: CityCipherTheme.background,
                  shape: BoxShape.circle,
                  border: Border.all(color: CityCipherTheme.accent, width: 3),
                ),
                child: const Icon(
                  LucideIcons.user,
                  color: CityCipherTheme.foreground,
                  size: 24,
                ),
              ),
            ),
            Text("CITY CIPHER", style: AppTypography.titleLarge),
            Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    LucideIcons.bell,
                    size: 32,
                    color: CityCipherTheme.foreground,
                  ),
                  onPressed: () {},
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 10,
                      minHeight: 10,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: CityCipherTheme.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: CityCipherTheme.border,
          height: 1,
          width: double.infinity,
        ),
      ),
    );
  }
}

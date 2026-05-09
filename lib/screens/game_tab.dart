import 'dart:io';
import 'package:city_cipher/core/providers/game_provider.dart';
import 'package:city_cipher/main.dart';
import 'package:city_cipher/models/gameConfig/game_config_model.dart';
import 'package:city_cipher/shared/utils/toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart' as format;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:math' as math;
import '../core/enums/app_enums.dart' as app;
import '../core/providers/api_service_provider.dart';
import '../core/providers/game_config_provider.dart';
import '../core/theme.dart';
import '../models/game/game_level_model.dart';
import '../models/user/game_data_model.dart';

class GameTab extends ConsumerStatefulWidget {
  const GameTab({super.key});

  @override
  ConsumerState<GameTab> createState() => _GameTabState();
}

class _GameTabState extends ConsumerState<GameTab> {
  BannerAd? _bannerAd;
  bool _isBannerAdLoading = false;
  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;

  final bannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  final rewardedAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';

  final interstitialAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

  app.AppState gameState = app.AppState.initialize;
  List<GameLevel> allLevels = [];
  List<int> _selectedIndices = [];
  Offset? _currentDragPoint;
  late List<String> _shuffledLetters;
  List<Offset> _hintedOffsets = [];

  void _loadBannerAd() {
    setState(() {
      _isBannerAdLoading = true;
    });
    final bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: bannerAdUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _isBannerAdLoading = false;
          });
        },
        onAdFailedToLoad: (ad, error) {
          _bannerAd = null;
          Future.delayed(const Duration(seconds: 5), () {
            _loadBannerAd();
          });
        },
      ),
    );

    // Start loading.
    bannerAd.load();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _rewardedAd = null;

          Future.delayed(const Duration(seconds: 5), () {
            _loadRewardedAd();
          });
        },
      ),
    );
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;

          Future.delayed(const Duration(seconds: 5), () {
            _loadInterstitialAd();
          });
        },
      ),
    );
  }

  void _showRewardedAd() {
    if (_rewardedAd == null) {
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewardedAd();
      },

      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadRewardedAd();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        final userGameData = ref.read(gameProvider);
        final config = ref.watch(gameConfigProvider);
        final currentLevel = userGameData?.currentLevel ?? 1;
        final rankConfig = config?.getRankByLevel(currentLevel);
        _useHint(userGameData!, rankConfig!, 0);
      },
    );

    _rewardedAd = null;
  }

  void _showInterstitialAd(int level) {
    if (_interstitialAd == null) return;

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();

        ref.read(gameProvider.notifier).updateInterstitialAd(level);
        _loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadInterstitialAd();
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null;
  }

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _loadRewardedAd();
    _loadInterstitialAd();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchLevels();
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  Future<void> fetchLevels() async {
    setState(() {
      gameState = app.AppState.loading;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final userGameData = ref.read(gameProvider);

      final response = await apiService.getGameLevels(
        currentLevel: userGameData?.currentLevel ?? 0,
        limit: 4,
      );

      if (!mounted) return;

      if (response.success) {
        setState(() {
          allLevels = response.data;
          gameState = app.AppState.loaded;
        });

        _initLevel();
      } else {
        setState(() {
          gameState = app.AppState.error;
        });
      }
    } catch (e) {
      setState(() {
        gameState = app.AppState.error;
      });
    }
  }

  void _initLevel() {
    if (gameState != app.AppState.loaded) return;
    if (allLevels.isEmpty) return;

    final userGameData = ref.read(gameProvider);
    final level = allLevels.first;

    if ((userGameData?.hintedOffsets.isEmpty ?? false) &&
        level.preFilled.isNotEmpty) {
      ref.read(gameProvider.notifier).storeLevelPrefilled(level.preFilled);
    }

    final List<Offset> nextHints =
        (userGameData?.hintedOffsets.isNotEmpty ?? false)
        ? userGameData!.hintedOffsets
        : level.preFilled;

    final List<String> shuffled = List.from(level.letters)..shuffle();

    setState(() {
      _shuffledLetters = shuffled;
      _hintedOffsets = nextHints;
      _selectedIndices = [];
      gameState = app.AppState.loaded;
    });
  }

  void _shuffle() => setState(() => _shuffledLetters.shuffle());

  void _checkLevelComplete(GameLevel level, RankConfig rankConfig) {
    final userGameData = ref.read(gameProvider);
    Set<Offset> requiredPoints = {};
    for (var item in level.grid) {
      String word = item.word;
      for (int i = 0; i < word.length; i++) {
        int cx = item.dir == 'h' ? item.x + i : item.x;
        int cy = item.dir == 'v' ? item.y + i : item.y;
        requiredPoints.add(Offset(cx.toDouble(), cy.toDouble()));
      }
    }

    // 2. Check if every point is covered by either a found word or a hint
    bool allFilled = requiredPoints.every((p) {
      bool coveredByWord = level.grid.any(
        (item) =>
            userGameData!.currentLevelWordsFound.contains(item.word) &&
            _isPointInWord(p, item),
      );
      bool coveredByHint = _hintedOffsets.contains(p);
      return coveredByWord || coveredByHint;
    });

    if (allFilled) {
      if (userGameData!.currentLevel - userGameData.interstitialAdsShownLevel >=
          rankConfig.adFrequency) {
        _showInterstitialAd(userGameData.currentLevel);
      }
      _proceedToNextLevel(userGameData, rankConfig);
    }
  }

  void _proceedToNextLevel(GameData userGameData, RankConfig rankConfig) {
    if (gameState == app.AppState.loading) return;

    setState(() {
      gameState = app.AppState.loading;
    });

    Future.delayed(const Duration(milliseconds: 600), () async {
      if (!mounted) return;

      ref
          .read(gameProvider.notifier)
          .updateHearts(userGameData.currentHearts - 1);
      ref.read(gameProvider.notifier).completedLevel(rankConfig.rewardPerLevel);

      if (allLevels.isNotEmpty) {
        setState(() {
          allLevels.removeAt(0);
          _hintedOffsets = [];
        });
      }

      if (allLevels.length <= 3) {
        await fetchLevels();
        return;
      }

      setState(() {
        gameState = app.AppState.loaded;
      });

      _initLevel();
    });
  }

  void _handleHint(GameData userGameData, RankConfig rankConfig, bool isFree) {
    if (userGameData.levelHintsUsed < rankConfig.hintPerLevelLimit) {
      if (!isFree && userGameData.earnedPoints >= rankConfig.hintCost) {
        _useHint(userGameData, rankConfig, rankConfig.hintCost);
      } else {
        _showAdDialog();
      }
    } else {
      ToastHelper.show(
        context,
        message:
            "You've used all hints for this level. Keep going — you can solve it!",
      );
    }
  }

  void _useHint(GameData userGameData, RankConfig rankConfig, int points) {
    final level = allLevels.first;

    List<Offset> hiddenCoords = [];

    // Find all still-hidden coordinates
    for (var item in level.grid) {
      String word = item.word;

      for (int i = 0; i < word.length; i++) {
        int cx = item.dir == 'h' ? item.x + i : item.x;
        int cy = item.dir == 'v' ? item.y + i : item.y;

        Offset p = Offset(cx.toDouble(), cy.toDouble());

        bool isVisible =
            userGameData.currentLevelWordsFound.contains(word) ||
            _hintedOffsets.contains(p) ||
            level.grid.any(
              (other) =>
                  userGameData.currentLevelWordsFound.contains(other.word) &&
                  _isPointInWord(p, other),
            );

        if (!isVisible && !hiddenCoords.contains(p)) {
          hiddenCoords.add(p);
        }
      }
    }

    // Reveal random hidden coordinate
    if (hiddenCoords.isNotEmpty) {
      final randomPoint =
          hiddenCoords[math.Random().nextInt(hiddenCoords.length)];

      setState(() {
        _hintedOffsets.add(randomPoint);
      });

      ref.read(gameProvider.notifier).useHint(points, randomPoint);

      // Check if any word became fully visible
      for (final item in level.grid) {
        bool fullyVisible = true;

        for (int i = 0; i < item.word.length; i++) {
          int cx = item.dir == 'h' ? item.x + i : item.x;
          int cy = item.dir == 'v' ? item.y + i : item.y;

          Offset point = Offset(cx.toDouble(), cy.toDouble());

          bool visible =
              _hintedOffsets.contains(point) ||
              userGameData.currentLevelWordsFound.contains(item.word);

          if (!visible) {
            fullyVisible = false;
            break;
          }
        }

        // Auto-add word if fully revealed by hints
        if (fullyVisible &&
            !userGameData.currentLevelWordsFound.contains(item.word)) {
          ref.read(gameProvider.notifier).addFoundWord(item.word);
        }
      }

      _checkLevelComplete(level, rankConfig);
    }
  }

  bool _isPointInWord(Offset p, WordPlacement item) {
    String word = item.word;
    for (int i = 0; i < word.length; i++) {
      int cx = item.dir == 'h' ? item.x + i : item.x;
      int cy = item.dir == 'v' ? item.y + i : item.y;
      if (p.dx == cx && p.dy == cy) return true;
    }
    return false;
  }

  void _updateSelection(Offset pos) {
    setState(() {
      _currentDragPoint = pos;
      const double size = 160;
      const double centerX = size / 2;
      const double centerY = size / 2;
      const double letterRadius = size * 0.45;

      for (int i = 0; i < _shuffledLetters.length; i++) {
        double angle =
            (i * 2 * math.pi / _shuffledLetters.length) - (math.pi / 2);
        Offset p = Offset(
          centerX + letterRadius * math.cos(angle),
          centerY + letterRadius * math.sin(angle),
        );
        if ((pos - p).distance < 35 && !_selectedIndices.contains(i)) {
          _selectedIndices.add(i);
        }
      }
    });
  }

  void _onPanEnd(
    GameLevel level,
    GameData userGameData,
    RankConfig rankConfig,
  ) {
    String word = _selectedIndices.map((i) => _shuffledLetters[i]).join("");
    if (level.grid.any((e) => e.word == word) &&
        !userGameData.currentLevelWordsFound.contains(word)) {
      ref.read(gameProvider.notifier).addFoundWord(word);
      _checkLevelComplete(level, rankConfig);
    }
    setState(() {
      _selectedIndices = [];
      _currentDragPoint = null;
    });
  }

  Widget _buildGrid(GameLevel level, GameData userGameData) {
    int minX = level.cols;
    int maxX = 0;
    int minY = level.rows;
    int maxY = 0;

    // Compute active bounds
    for (final item in level.grid) {
      final word = item.word;

      final endX = item.dir == 'h' ? item.x + word.length - 1 : item.x;

      final endY = item.dir == 'v' ? item.y + word.length - 1 : item.y;

      minX = math.min(minX, item.x);
      maxX = math.max(maxX, endX);

      minY = math.min(minY, item.y);
      maxY = math.max(maxY, endY);
    }

    // Active dimensions
    int activeCols = (maxX - minX + 1) + 1;
    int activeRows = (maxY - minY + 1) + 1;

    int displaySide = math.max(activeCols, activeRows);

    // Prevent overly tiny cells
    displaySide = displaySide.clamp(4, 8);

    final offsetX = minX - ((displaySide - (maxX - minX + 1)) ~/ 2);

    final offsetY = minY - ((displaySide - (maxY - minY + 1)) ~/ 2);

    // Dynamic sizing
    final spacing = displaySide >= 8 ? 3.0 : 6.0;

    final fontSize = math.max(14.0, 32.0 - (displaySide * 2));

    // Precompute cells
    final Map<String, String> cellChars = {};
    final Set<String> visibleCells = {};

    for (final item in level.grid) {
      for (int i = 0; i < item.word.length; i++) {
        final x = item.dir == 'h' ? item.x + i : item.x;

        final y = item.dir == 'v' ? item.y + i : item.y;

        final key = '$x,$y';

        cellChars[key] = item.word[i];

        final isFound = userGameData.currentLevelWordsFound.contains(item.word);

        final isHinted = _hintedOffsets.contains(
          Offset(x.toDouble(), y.toDouble()),
        );

        if (isFound || isHinted) {
          visibleCells.add(key);
        }
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: AspectRatio(
        aspectRatio: 1,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displaySide * displaySide,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: displaySide,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
          ),
          itemBuilder: (context, index) {
            final x = (index % displaySide) + offsetX;
            final y = (index ~/ displaySide) + offsetY;

            final key = '$x,$y';

            final char = cellChars[key];

            final isVisible = visibleCells.contains(key);

            // Keep invisible cells stable
            if (char == null) {
              return const SizedBox.shrink();
            }

            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: isVisible
                    ? CityCipherTheme.primary
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: isVisible ? 1 : 0,
                  child: Text(
                    char,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userGameData = ref.watch(gameProvider);
    final config = ref.watch(gameConfigProvider);
    final currentLevel = userGameData?.currentLevel ?? 1;
    final rankConfig = config?.getRankByLevel(currentLevel);

    if (gameState == app.AppState.loading && allLevels.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (allLevels.isEmpty || userGameData!.currentHearts == 0) {
      return Scaffold(
        backgroundColor: CityCipherTheme.background,
        appBar: _appBar(userGameData!),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
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
                  allLevels.isEmpty
                      ? 'You’ve reached the highest available level for now. More levels are coming soon!'
                      : "You’re out of energy! Please come back later once it has recharged.",
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
      );
    }

    final level = allLevels.first;

    return Scaffold(
      backgroundColor: CityCipherTheme.background,
      appBar: _appBar(userGameData),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 25),
            Expanded(
              flex: 7,
              child: Center(child: _buildGrid(level, userGameData)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                _selectedIndices.map((i) => _shuffledLetters[i]).join(""),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCircleBtn(
                          LucideIcons.shuffle,
                          CityCipherTheme.foreground,
                          _shuffle,
                          "",
                        ),
                        const SizedBox(height: 15),
                        _buildCircleBtn(
                          LucideIcons.lightbulb,
                          CityCipherTheme.primary,
                          _shuffle,
                          "${userGameData.levelHintsUsed}/${rankConfig?.hintPerLevelLimit}",
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: GestureDetector(
                        onPanStart: (d) => _updateSelection(d.localPosition),
                        onPanUpdate: (d) => _updateSelection(d.localPosition),
                        onPanEnd: (d) =>
                            _onPanEnd(level, userGameData, rankConfig!),
                        child: CustomPaint(
                          painter: WheelPainter(
                            letters: _shuffledLetters,
                            selectedIndices: _selectedIndices,
                            currentDragPoint: _currentDragPoint,
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCircleBtn(
                          LucideIcons.lightbulb,
                          CityCipherTheme.primary,
                          () {
                            _handleHint(userGameData, rankConfig!, false);
                          },
                          "${rankConfig?.hintCost} pts",
                        ),
                        const SizedBox(height: 15),
                        _buildCircleBtn(
                          Icons.ads_click,
                          CityCipherTheme.secondary,
                          () {
                            _handleHint(userGameData, rankConfig!, true);
                          },
                          "FREE",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            bannerAd(),
          ],
        ),
      ),
    );
  }

  Widget bannerAd() {
    if (_isBannerAdLoading) {
      return Container(
        height: 60,
        color: CityCipherTheme.background,
        child: const Center(
          child: Text(
            "Loading ad...",
            style: TextStyle(
              fontSize: 12,
              fontFamily: CityCipherTheme.fontFamily,
              color: CityCipherTheme.foreground,
            ),
          ),
        ),
      );
    }

    if (_bannerAd == null) {
      return Container(
        height: 60,
        color: CityCipherTheme.background,
        child: const Center(child: Text("")),
      );
    }

    return SizedBox(
      height: _bannerAd!.size.height.toDouble(),
      width: double.infinity,
      child: AdWidget(ad: _bannerAd!),
    );
  }

  PreferredSizeWidget _appBar(GameData userGameData) {
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      backgroundColor: CityCipherTheme.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      //toolbarHeight: 90,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(
                LucideIcons.x,
                color: CityCipherTheme.foreground,
              ),
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => MainNavigation()),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 6),
                Row(
                  children: [
                    _chip(
                      LucideIcons.zap,
                      CityCipherTheme.primary,
                      userGameData.currentHearts.toString(),
                    ),
                    const SizedBox(width: 6),
                    _chip(
                      LucideIcons.award,
                      CityCipherTheme.primary,
                      "Level ${userGameData.currentLevel}",
                    ),
                    const SizedBox(width: 6),
                    _chip(
                      LucideIcons.coins,
                      CityCipherTheme.primary,
                      format.NumberFormat.decimalPattern().format(
                        userGameData.earnedPoints,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
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

  Widget _chip(IconData icon, Color col, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CityCipherTheme.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: col, size: 17),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: CityCipherTheme.foreground,
              fontWeight: FontWeight.bold,
              fontFamily: CityCipherTheme.fontFamily,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleBtn(
    IconData icon,
    Color col,
    VoidCallback tap, [
    String? label,
  ]) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: tap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CityCipherTheme.accent,
              border: Border.all(color: CityCipherTheme.border),
            ),
            child: Icon(icon, color: col, size: 24),
          ),
        ),
        if (label != null) ...[
          SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: CityCipherTheme.mutedForeground,
              fontSize: 12,
              fontFamily: CityCipherTheme.fontFamily,
            ),
          ),
        ],
      ],
    );
  }

  void _showAdDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: CityCipherTheme.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: CityCipherTheme.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.lightbulb,
                  color: CityCipherTheme.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "Free Hint",
                style: TextStyle(
                  color: CityCipherTheme.foreground,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: CityCipherTheme.fontFamily,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Watch a short ad to reveal a letter in the puzzle.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CityCipherTheme.foreground.withValues(alpha: 0.7),
                  fontSize: 15,
                  height: 1.4,
                  fontFamily: CityCipherTheme.fontFamily,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: CityCipherTheme.foreground,
                          fontFamily: CityCipherTheme.fontFamily,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CityCipherTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _showRewardedAd();
                      },
                      icon: const Icon(
                        LucideIcons.play,
                        size: 18,
                        color: CityCipherTheme.primaryForeground,
                      ),
                      label: const Text(
                        "Watch Ad",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: CityCipherTheme.primaryForeground,
                          fontFamily: CityCipherTheme.fontFamily,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Keep the WheelPainter class from the previous code block at the bottom
class WheelPainter extends CustomPainter {
  final List<String> letters;
  final List<int> selectedIndices;
  final Offset? currentDragPoint;

  WheelPainter({
    required this.letters,
    required this.selectedIndices,
    this.currentDragPoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double centerX = size.width / 2;
    double centerY = size.height / 2;
    Offset center = Offset(centerX, centerY);

    // --- DYNAMIC CALCULATIONS ---
    int count = letters.length;

    // 1. Smaller circles if there are more letters
    // 3-5 letters = ~28px, 8 letters = ~22px, 10 letters = ~18px
    double circleRadius = count <= 5 ? 28 : (count <= 8 ? 22 : 18);

    // 2. Smaller font for more letters
    double fontSize = count <= 5 ? 22 : (count <= 8 ? 18 : 14);

    // 3. Keep letters at the edge
    double letterRadius = size.width * 0.46;

    Paint linePaint = Paint()
      ..color = CityCipherTheme.primary.withOpacity(0.9)
      ..strokeWidth = count > 7
          ? 7
          : 10 // Thinner lines for crowded wheels
      ..strokeCap = StrokeCap.round;

    List<Offset> pts = List.generate(count, (i) {
      double angle = (i * 2 * math.pi / count) - (math.pi / 2);
      return center +
          Offset(
            letterRadius * math.cos(angle),
            letterRadius * math.sin(angle),
          );
    });

    // Draw lines
    for (int i = 0; i < selectedIndices.length; i++) {
      if (i + 1 < selectedIndices.length) {
        canvas.drawLine(
          pts[selectedIndices[i]],
          pts[selectedIndices[i + 1]],
          linePaint,
        );
      } else if (currentDragPoint != null) {
        canvas.drawLine(pts[selectedIndices[i]], currentDragPoint!, linePaint);
      }
    }

    // Draw Letters
    for (int i = 0; i < pts.length; i++) {
      bool isSelected = selectedIndices.contains(i);

      canvas.drawCircle(
        pts[i],
        circleRadius,
        Paint()..color = isSelected ? CityCipherTheme.primary : Colors.white,
      );

      final tp = TextPainter(
        text: TextSpan(
          text: letters[i],
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, pts[i] - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant WheelPainter oldDelegate) => true;
}

import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'partner_store_detail_screen.dart';
import 'core/theme.dart';
import 'core/app_typography.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _featuredDeals = [
    {
      "imageUrl":
          "https://i.ibb.co/1GhGJ01R/campbell-3-ZUs-NJhi-Ik-unsplash.jpg",
    },
    {
      "imageUrl":
          "https://i.ibb.co/yms5VmZF/alexander-schimmeck-o-M-Sb-HRa-DMQ-unsplash.jpg",
    },
    {
      "imageUrl":
          "https://i.ibb.co/XfTmGbWC/bruce-mars-g-Jt-Dg6-Wf-Ml-Q-unsplash.jpg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CityCipherTheme.background,
      appBar: _AppHeader(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        children: [
          _profileCard(),
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
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _featuredDeals.length,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: _promoBanner(_featuredDeals[index]),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _featuredDeals.length,
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
                onPressed: () {},
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
          _storeGrid(),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _profileCard() {
    final int currentUserLevel = 125;
    final int maxGameLevel = 1000;
    final String pointsLabel = "23,450";
    const int step = 50;
    const int totalSegments = 5;

    double progress;
    String leftLabel;
    String rightLabel;
    String tierName;

    // 1. Determine Tier Name
    if (currentUserLevel < 500) {
      tierName = "Starter";
    } else if (currentUserLevel < 1000) {
      tierName = "Novice";
    } else {
      tierName = "Expert";
    }

    // 2. Determine Labels and Progress (50-level chunks)
    if (currentUserLevel >= maxGameLevel) {
      leftLabel = "Lvl $maxGameLevel";
      rightLabel = "MAX";
      progress = 1.0;
    } else {
      // Finds the lower bound (e.g., if level is 125, floor is 100)
      int floorLevel = (currentUserLevel ~/ step) * step;
      int ceilingLevel = floorLevel + step;

      leftLabel = "Lvl $currentUserLevel";
      rightLabel = "Lvl $ceilingLevel";

      // Calculate progress within that 50-level chunk
      progress = ((currentUserLevel - floorLevel) / step).clamp(0.0, 1.0);
    }

    // Calculate filled segments (e.g., if progress is 0.5, 2.5 rounded is 3 bars)
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
                      tierName.toUpperCase(),
                      style: const TextStyle(
                        color: CityCipherTheme.foreground,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
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

  Widget _promoBanner(Map<String, dynamic> deal) {
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
                deal['imageUrl'] as String,
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
                    child: const Text(
                      "LIMITED",
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
                    deal['title'] ?? "Special Promotion",
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
    final stores = [
      {
        "name": "Red Line Detailing & Auto Spa",
        "logo":
            "https://i.ibb.co/bjG1JGxn/Gemini-Generated-Image-ggwrmdggwrmdggwr.png",
        "badge": "2× pts today",
        "active": true,
      },
      {
        "name": "Apex Fitness",
        "logo":
            "https://i.ibb.co/Z1dgTL7c/Gemini-Generated-Image-oqc5oqc5oqc5oqc5.png",
        "badge": "New deal",
        "active": false,
      },
      {
        "name": "Volt Electric Bikes",
        "logo":
            "https://i.ibb.co/KpxSRmNM/Gemini-Generated-Image-wdgwlswdgwlswdgw.png",
        "badge": "Always on",
        "active": null,
      },
      {
        "name": "Luxe Detailing Studio Garage",
        "logo":
            "https://i.ibb.co/xqcVQQM0/Gemini-Generated-Image-wq0uolwq0uolwq0u.png",
        "badge": "3× pts weekend",
        "active": true,
      },
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 0.88,
      children: stores.map((s) => _storeCard(context, s)).toList(),
    );
  }

  Widget _storeCard(BuildContext context, Map<String, dynamic> store) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PartnerStoreDetailScreen(storeId: "store123"),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
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
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: CityCipherTheme.background,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: CityCipherTheme.mutedForeground,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      store['logo'] as String,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          LucideIcons.store,
                          size: 40,
                          color: CityCipherTheme.mutedForeground,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          (store['name'] as String),
                          style: const TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: CityCipherTheme.foreground,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AppHeader extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                    size: 30,
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

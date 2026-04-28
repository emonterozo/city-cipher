import 'package:flutter/material.dart';
import 'partner_store_detail_screen.dart';
import 'core_theme.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final PageController _pageController = PageController();
  int _activePage = 0;

  // Sample Data for Banners
  final List<Map<String, dynamic>> _featuredDeals = [
    {
      "imageUrl":
          "https://i.ibb.co/vxVdGBy8/Gemini-Generated-Image-x4iiv3x4iiv3x4ii.png",
    },
    {
      "imageUrl":
          "https://i.ibb.co/tpLTj4kz/Gemini-Generated-Image-qauqg2qauqg2qauq.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F3),
      appBar: AppBar(
        leading: _buildProfileIcon(),
        leadingWidth: 64,
        title: Text(
          "CITY CIPHER",
          style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
            letterSpacing: 3.5,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [_buildNotificationIcon(), const SizedBox(width: 16)],
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(color: Colors.black.withOpacity(0.07), height: 0.5),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          _buildPointsCard(context),
          const SizedBox(height: 25),

          _buildSectionLabel(context, "FEATURED DEALS"),
          

          // --- HORIZONTAL SCROLL BANNERS ---
          SizedBox(
            height: 160,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) => setState(() => _activePage = page),
              itemCount: _featuredDeals.length,
              itemBuilder: (context, index) {
                return _buildPromoBanner(_featuredDeals[index]);
              },
            ),
          ),

          // --- PAGE INDICATOR ---
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _featuredDeals.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _activePage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _activePage == index
                      ? CityCipherTheme.primaryRed
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          const SizedBox(height: 25),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionLabel(context, "PARTNER STORES"),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.only(bottom: 12),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  "VIEW ALL",
                  style: TextStyle(
                    color: CityCipherTheme.primaryRed,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),

         
          _buildStoreGrid(),
          const SizedBox(
            height: 100,
          ), // Bottom padding for the navigation bar notch
        ],
      ),
    );
  }

  // --- NEW PROFILE ICON WIDGET ---
  Widget _buildProfileIcon() {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Center(
        child: GestureDetector(
          onTap: () {
            // Navigate to Profile Settings or login check
          },
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.black.withOpacity(0.05),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.black87,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
          color: Colors.black38,
        ),
      ),
    );
  }

  Widget _buildPromoBanner(Map<String, dynamic> deal) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          deal['imageUrl'],
          fit: BoxFit.cover, // This ensures the 2:1 image fills your 160 height
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
                Icon(Icons.broken_image, color: Colors.grey, size: 40),
                Text(
                  "Image failed to load",
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPointsCard(BuildContext context) {
    // --- DATA ---
    final int currentUserLevel = 1000;
    final int maxGameLevel = 1000;

    // --- PROGRESS & TEXT LOGIC ---
    double progress;
    String leftLabel;
    String rightLabel;
    String tierName;

    if (currentUserLevel < 10) {
      tierName = "Starter";
      leftLabel = "Starter";
      rightLabel = "Novice";
      progress = (currentUserLevel / 10).clamp(0.0, 1.0);
    } else if (currentUserLevel < 50) {
      tierName = "Novice";
      leftLabel = "Novice";
      rightLabel = "Expert";
      progress = ((currentUserLevel - 10) / (50 - 10)).clamp(0.0, 1.0);
    } else if (currentUserLevel >= maxGameLevel) {
      // PHASE: MAX LEVEL REACHED
      tierName = "Expert";
      leftLabel = "Lvl 990";
      rightLabel = "Lvl 1000"; // Or "Lvl 1000"
      progress = 1.0; // Keep the bar full
    } else {
      // PHASE: Expert (Level 50+)
      tierName = "Expert";
      int floorLevel = (currentUserLevel ~/ 10) * 10;
      int ceilingLevel = floorLevel + 10;

      if (ceilingLevel > maxGameLevel) ceilingLevel = maxGameLevel;

      leftLabel = "Lvl $floorLevel";
      rightLabel = "Lvl $ceilingLevel";
      progress = ((currentUserLevel - floorLevel) / 10).clamp(0.0, 1.0);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "CURRENT BALANCE",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                        color: Colors.black45,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "8,249",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1.5,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "points",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 75,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: CityCipherTheme.primaryRed,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: CityCipherTheme.primaryRed.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.military_tech_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tierName.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: Colors.black.withOpacity(0.07),
              valueColor: const AlwaysStoppedAnimation<Color>(
                CityCipherTheme.primaryRed,
              ),
            ),
          ),
          const SizedBox(height: 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                leftLabel,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withOpacity(0.35),
                ),
              ),
              Text(
                rightLabel,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withOpacity(0.35),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(
            Icons.notifications_none_rounded,
            size: 28,
            color: Colors.black87,
          ),
          onPressed: () {},
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: CityCipherTheme.primaryRed,
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: const Text(
              '3',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoreGrid() {
    final stores = [
      {
        "name": "DAILY GRIND",
        "logo":
            "https://i.ibb.co/bjG1JGxn/Gemini-Generated-Image-ggwrmdggwrmdggwr.png",
        "badge": "2× pts today",
        "active": true,
      },
      {
        "name": "APEX FITNESS",
        "logo":
            "https://i.ibb.co/Z1dgTL7c/Gemini-Generated-Image-oqc5oqc5oqc5oqc5.png",
        "badge": "New deal",
        "active": false,
      },
      {
        "name": "VOLT ELECTRICS",
        "logo":
            "https://i.ibb.co/KpxSRmNM/Gemini-Generated-Image-wdgwlswdgwlswdgw.png",
        "badge": "Always on",
        "active": null,
      },
      {
        "name": "LUXE DETAILING",
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
    // Wrap the entire design in an InkWell to make it clickable
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PartnerStoreDetailScreen(storeId: "dasd"),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16), // Match your container radius
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Center(
                  child: Image.network(
                    store['logo'] as String,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          (store['name'] as String).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

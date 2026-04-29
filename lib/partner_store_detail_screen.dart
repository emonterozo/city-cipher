import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:city_cipher/core/theme.dart';

class StoreSocials {
  final String? facebook;
  final String? instagram;
  final String? tiktok;

  StoreSocials({this.facebook, this.instagram, this.tiktok});
}

class StoreHour {
  final String day;
  final String time;

  StoreHour({required this.day, required this.time});
}

class Branch {
  final String locationName;
  final String address;
  final double latitude;
  final double longitude;
  final List<StoreHour> hours;
  final StoreSocials socials;

  Branch({
    required this.locationName,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.hours,
    required this.socials,
  });
}

class PartnerStoreDetailScreen extends StatefulWidget {
  final String storeId;
  const PartnerStoreDetailScreen({super.key, required this.storeId});

  @override
  State<PartnerStoreDetailScreen> createState() =>
      _PartnerStoreDetailScreenState();
}

class _PartnerStoreDetailScreenState extends State<PartnerStoreDetailScreen> {
  Map<String, dynamic>? storeData;
  List<Branch> branches = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStoreDetails();
  }

  Future<void> _fetchStoreDetails() async {
    try {
      setState(() => isLoading = true);
      // Simulate API Latency
      await Future.delayed(const Duration(milliseconds: 800));

      final mockBranches = [
        Branch(
          locationName: "Quezon City HQ",
          address: "123 Katipunan Ave, Quezon City",
          latitude: 14.6327,
          longitude: 121.0732,
          hours: [
            StoreHour(day: "Monday", time: "8AM - 6PM"),
            StoreHour(day: "Tuesday", time: "8AM - 6PM"),
            StoreHour(day: "Wednesday", time: "8AM - 6PM"),
            StoreHour(day: "Thursday", time: "8AM - 6PM"),
            StoreHour(day: "Friday", time: "8AM - 6PM"),
            StoreHour(day: "Saturday", time: "9AM - 4PM"),
            StoreHour(day: "Sunday", time: "Closed"),
          ],
          socials: StoreSocials(
            facebook: "https://facebook.com",
            instagram: "https://instagram.com",
            tiktok: "https://tiktok.com",
          ),
        ),
        Branch(
          locationName: "Caloocan City",
          address: "123 Katipunan Ave, Quezon City",
          latitude: 14.6327,
          longitude: 121.0732,
          hours: [
            StoreHour(day: "Monday", time: "8AM - 6PM"),
            StoreHour(day: "Tuesday", time: "8AM - 6PM"),
            StoreHour(day: "Wednesday", time: "8AM - 6PM"),
            StoreHour(day: "Thursday", time: "8AM - 6PM"),
            StoreHour(day: "Friday", time: "8AM - 6PM"),
            StoreHour(day: "Saturday", time: "9AM - 4PM"),
            StoreHour(day: "Sunday", time: "Closed"),
          ],
          socials: StoreSocials(
            facebook: "https://facebook.com",
            instagram: "https://instagram.com",
            tiktok: "https://tiktok.com",
          ),
        ),
      ];

      setState(() {
        storeData = {
          "name": "Red Line Detailing",
          "website": "https://redlinedetailing.com",
          "bannerUrl":
              "https://images.unsplash.com/photo-1552933529-e359b2477252?q=80&w=2070&auto=format&fit=crop",
          "description":
              "Premium automotive restoration and protection specialists specializing in paint correction and ceramic coatings.",
          "rewards": [
            {"title": "Full Exterior Waxing & Buffing Package", "points": 500},
            {"title": "Interior Deep Clean & Sanitation", "points": 1200},
            {"title": "Engine Bay Degreasing", "points": 800},
          ],
        };
        branches = mockBranches;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: CityCipherTheme.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: CityCipherTheme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeroAppBar(storeData),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    [
                      Column(
                        children: [
                          Text(
                            "Artisan coffee roasted in-house with a selection of premium hand-crafted pastries. Every cup earned gets you closer to exclusive rewards.",
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
                      GestureDetector(
                        onTap: () => {},
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
                    ] +
                    branches.map((branch) {
                      return BranchCard(branch: branch);
                    }).toList() +
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
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
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
                                      "50% sample product",
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
                                      "1,500 POINTS",
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
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
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
                                      "50% sample product",
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
                                      "1,500 POINTS",
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
                      const SizedBox(height: 50),
                    ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroAppBar(Map<String, dynamic>? storeData) {
    final bannerUrl =
        storeData?['bannerUrl'] ?? "https://example.com/fallback-banner.jpg";
    final storeName = storeData?['name'] ?? "Brew & Co.";
    final category = storeData?['category'] ?? "COFFEE & BAKERY";
    final logoIcon = storeData?['logoIcon'] ?? Icons.coffee;

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
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(bannerUrl, fit: BoxFit.cover),
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
                      storeName,
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
                      category.toUpperCase(),
                      style: const TextStyle(
                        color: CityCipherTheme.secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Poppins",
                        letterSpacing: 0.8,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      'https://i.ibb.co/bjG1JGxn/Gemini-Generated-Image-ggwrmdggwrmdggwr.png',
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
          ],
        ),
      ),
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
                    branch.locationName,
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
                Row(
                  children: [
                    if (branch.socials.facebook != null)
                      const FaIcon(
                        FontAwesomeIcons.facebook,
                        size: 19,
                        color: CityCipherTheme.mutedForeground,
                      ),
                    const SizedBox(width: 12),
                    if (branch.socials.instagram != null)
                      const FaIcon(
                        FontAwesomeIcons.instagram,
                        size: 19,
                        color: CityCipherTheme.mutedForeground,
                      ),
                    const SizedBox(width: 12),
                    if (branch.socials.tiktok != null)
                      const FaIcon(
                        FontAwesomeIcons.tiktok,
                        size: 19,
                        color: CityCipherTheme.mutedForeground,
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                print("Opening Maps...");
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
                            "Open until 9:00 PM",
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
                children: branch.hours.map((h) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          h.day,
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
                          h.time,
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

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:city_cipher/core_theme.dart';
import 'dart:io';
import 'dart:ui';

// --- MODELS ---

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

// --- SCREEN ---

class PartnerStoreDetailScreen extends StatefulWidget {
  final String storeId;
  const PartnerStoreDetailScreen({super.key, required this.storeId});

  @override
  State<PartnerStoreDetailScreen> createState() => _PartnerStoreDetailScreenState();
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
      ];

      setState(() {
        storeData = {
          "name": "Red Line Detailing",
          "website": "https://redlinedetailing.com",
          "bannerUrl": "https://images.unsplash.com/photo-1552933529-e359b2477252?q=80&w=2070&auto=format&fit=crop",
          "description": "Premium automotive restoration and protection specialists specializing in paint correction and ceramic coatings.",
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
        body: Center(child: CircularProgressIndicator(color: CityCipherTheme.primaryRed)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeroAppBar(),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderSection(),
                    const SizedBox(height: 35),
                    _buildSectionLabel("LOCATIONS"),
                    ...branches.map((b) => ModernBranchCard(branch: b)),
                    const SizedBox(height: 35),
                    _buildSectionLabel("REWARDS TEASER"),
                    ...((storeData?['rewards'] as List?) ?? []).map((r) => _buildRewardTeaserTile(r)),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black26,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Image.network(storeData?['bannerUrl'] ?? "", fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildHeaderSection() {
    final String? website = storeData?['website'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                (storeData?['name'] ?? "").toUpperCase(),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1),
              ),
            ),
            if (website != null)
              IconButton(
                onPressed: () => _launchUrl(website),
                icon: const Icon(Icons.public, color: Colors.black54),
                tooltip: "Visit Website",
              ),
          ],
        ),
       
        Text(
          storeData?['description'] ?? "",
          style: TextStyle(fontSize: 15, color: Colors.black.withOpacity(0.6), height: 1.5),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2, color: Colors.black38),
      ),
    );
  }

  Widget _buildRewardTeaserTile(Map<String, dynamic> reward) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // TODO: Navigator.push(context, MaterialPageRoute(builder: (context) => RewardsListScreen()));
          debugPrint("Redirecting to Rewards Details for: ${reward['title']}");
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: CityCipherTheme.primaryRed.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.card_giftcard_rounded, color: CityCipherTheme.primaryRed, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward['title'] ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    Text(
                      "${reward['points'] ?? 0} Points",
                      style: TextStyle(color: Colors.black.withOpacity(0.4), fontWeight: FontWeight.w600, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.black.withOpacity(0.2)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch $url");
    }
  }
}

// --- BRANCH CARD COMPONENT ---

class ModernBranchCard extends StatefulWidget {
  final Branch branch;
  const ModernBranchCard({super.key, required this.branch});

  @override
  State<ModernBranchCard> createState() => _ModernBranchCardState();
}

class _ModernBranchCardState extends State<ModernBranchCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
        ],
        border: Border.all(color: _isExpanded ? CityCipherTheme.primaryRed.withOpacity(0.3) : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(widget.branch.locationName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17))),
                    _buildSocials(widget.branch.socials),
                  ],
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _openMap(widget.branch.latitude, widget.branch.longitude),
                  child: Text(
                    widget.branch.address,
                    style: const TextStyle(color: Colors.blueAccent, fontSize: 13, decoration: TextDecoration.underline),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("VIEW STORE HOURS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black45)),
                      Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 16, color: Colors.black26),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: _buildHoursList(),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildHoursList() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 10),
          ...widget.branch.hours.map((h) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(h.day, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                Text(h.time, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: h.time.toLowerCase().contains("closed") ? Colors.red : Colors.black54)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSocials(StoreSocials socials) {
    return Row(
      children: [
        if (socials.facebook != null) _socialIcon(Icons.facebook, socials.facebook!, const Color(0xFF1877F2)),
        if (socials.instagram != null) _socialIcon(Icons.camera_alt_rounded, socials.instagram!, const Color(0xFFE4405F)),
        if (socials.tiktok != null) _socialIcon(Icons.music_note_rounded, socials.tiktok!, Colors.black),
      ],
    );
  }

  Widget _socialIcon(IconData icon, String url, Color color) {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }

  Future<void> _openMap(double lat, double lng) async {
    Uri uri = Platform.isIOS ? Uri.parse('apple_maps://?q=$lat,$lng') : Uri.parse('geo:$lat,$lng?q=$lat,$lng');
    if (!await launchUrl(uri)) debugPrint("Could not launch maps");
  }
}
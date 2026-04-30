import 'package:city_cipher/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../core/theme.dart';

class RewardsTab extends StatefulWidget {
  const RewardsTab({super.key});

  @override
  State<RewardsTab> createState() => _RewardsTabState();
}

class _RewardsTabState extends State<RewardsTab> {
  int _selectedSegment = 0; // 0: Active, 1: Used, 2: Expired

  // Mock data partitioned by status
  final Map<int, List<Map<String, String>>> _voucherData = {
    0: [
      {
        "title": "10% OFF Full Detail",
        "code": "RED10-XXXX",
        "expiry": "Expires on May 20, 2026",
      },
      {
        "title": "Free Coating Wax",
        "code": "WAX-YYYY",
        "expiry": "Expires on June 05, 2026",
      },
       {
        "title": "10% OFF Full Detail",
        "code": "RED10-XXXX",
        "expiry": "Expires on May 20, 2026",
      },
      {
        "title": "Free Coating Wax",
        "code": "WAX-YYYY",
        "expiry": "Expires on June 05, 2026",
      },
       {
        "title": "10% OFF Full Detail",
        "code": "RED10-XXXX",
        "expiry": "Expires on May 20, 2026",
      },
      {
        "title": "Free Coating Wax",
        "code": "WAX-YYYY",
        "expiry": "Expires on June 05, 2026",
      },
       {
        "title": "10% OFF Full Detail",
        "code": "RED10-XXXX",
        "expiry": "Expires on May 20, 2026",
      },
      {
        "title": "Free Coating Wax",
        "code": "WAX-YYYY",
        "expiry": "Expires on June 05, 2026",
      },
    ],
    1: [
      {
        "title": "Interior Deep Clean",
        "code": "DONE-123",
        "expiry": "Used onApril 01, 2026",
      },
    ],
    2: [], // Empty state example
  };

  @override
  Widget build(BuildContext context) {
    final currentVouchers = _voucherData[_selectedSegment] ?? [];

    return Scaffold(
      backgroundColor: CityCipherTheme.background,
      appBar: CustomAppBar(title: "My Rewards", showBack: false,),
      body: Column(
        children: [
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: RewardSegmentedControl(
              selectedIndex: _selectedSegment,
              onChanged: (index) {
                setState(() => _selectedSegment = index);
              },
            ),
          ),
          // List Content
          Expanded(
            child: currentVouchers.isEmpty
                ? _emptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: currentVouchers.length,
                    itemBuilder: (context, index) {
                      return _voucherCard(currentVouchers[index]);
                    },
                  ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _voucherCard(Map<String, String> voucher) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                    voucher["title"] ?? "",
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
                    voucher["expiry"] ?? "",
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
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.packageOpen,
            size: 70,
            color: CityCipherTheme.mutedForeground.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "Nothing here yet",
            style: TextStyle(
              fontFamily: "Poppins",
              color: CityCipherTheme.mutedForeground.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
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

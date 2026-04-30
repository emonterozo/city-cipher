import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:city_cipher/core/theme.dart';
import 'core/link_service.dart';
import 'core/state/app_state.dart';
import 'core/utils/time_utils.dart';
import 'models/store/store_model.dart';
import 'services/api_service.dart';

class StoreDetailScreen extends StatefulWidget {
  final String storeId;
  const StoreDetailScreen({super.key, required this.storeId});

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  final ApiService apiService = ApiService();
  Store? store;
  AppState storeState = AppState.loading;

  @override
  void initState() {
    super.initState();
    fetchStoreDetails();
  }

  Future<void> fetchStoreDetails() async {
    setState(() {
      storeState = AppState.loading;
    });

    try {
      final response = await apiService.getStoreDetails(widget.storeId);

      setState(() {
        if (response.success) {
          store = response.data;
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
  Widget build(BuildContext context) {
    if (storeState == AppState.loading) {
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
                          Text(
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
                      if (store?.website != null &&
                          store!.website!.isNotEmpty) ...[
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

  Widget _buildHeroAppBar(Store? store) {
    if (store == null) {
      return const SliverAppBar(
        expandedHeight: 330,
        backgroundColor: CityCipherTheme.background,
        flexibleSpace: Center(child: CircularProgressIndicator()),
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

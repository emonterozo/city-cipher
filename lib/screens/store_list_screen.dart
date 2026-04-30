import 'package:flutter/material.dart';
import 'package:city_cipher/core/theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';
import '../core/state/app_state.dart';
import '../models/store/store_model.dart';
import '../services/api_service.dart';
import '../shared/widgets/custom_app_bar.dart';
import '../shared/widgets/store_card.dart';

class StoreListScreen extends StatefulWidget {
  const StoreListScreen({super.key});

  @override
  State<StoreListScreen> createState() => _StoreListScreenState();
}

class _StoreListScreenState extends State<StoreListScreen> {
  final ApiService apiService = ApiService();
  int _page = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  List<Store> stores = [];
  String _searchQuery = "";
  AppState storeState = AppState.loading;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  Future<void> fetchStores({bool reset = false}) async {
    if (reset) {
      _page = 1;
      _hasMore = true;
      stores = [];
    }

    setState(() {
      storeState = AppState.loading;
    });

    try {
      final response = await apiService.getStores(
        page: _page,
        limit: 10,
        search: _searchQuery,
      );

      if (response.success) {
        setState(() {
          stores.addAll(response.data);

          _hasMore = _page < response.meta.totalPages;
          storeState = AppState.loaded;
        });
      } else {
        setState(() {
          storeState = AppState.error;
        });
      }
    } catch (e) {
      setState(() {
        storeState = AppState.error;
      });
    }
  }

  Future<void> fetchMoreStores() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    _page++;

    try {
      final response = await apiService.getStores(
        page: _page,
        limit: 10,
        search: _searchQuery,
      );

      if (response.success) {
        setState(() {
          stores.addAll(response.data);
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
    fetchStores();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        fetchMoreStores();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CityCipherTheme.background,
      appBar: CustomAppBar(title: "Discover Stores"),
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
              preferredSize: const Size.fromHeight(66),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 5, 16, 5),
                child: SizedBox(
                  width: double.infinity,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      _searchQuery = value;
                    },
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: "Poppins",
                    ),
                    cursorColor: CityCipherTheme.primary,
                    decoration: InputDecoration(
                      hintText: "Search stores...",
                      hintStyle: TextStyle(
                        color: CityCipherTheme.mutedForeground,
                        fontSize: 16,
                        fontFamily: "Poppins",
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF334155),
                          width: 1,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: CityCipherTheme.primary,
                          width: 2,
                        ),
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              LucideIcons.search,
                              size: 22,
                              color: CityCipherTheme.mutedForeground,
                            ),
                            onPressed: () {
                              if (_searchQuery.isNotEmpty) {
                                fetchStores(reset: true);
                              }
                            },
                          ),
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(
                                LucideIcons.x,
                                size: 22,
                                color: CityCipherTheme.mutedForeground,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _searchQuery = "";
                                fetchStores(reset: true);
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (storeState == AppState.loading)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.88,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: Shimmer.fromColors(
                              baseColor: const Color(0xFF1E293B),
                              highlightColor: const Color(0xFF334155),
                              child: Container(
                                width: 83,
                                height: 88,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Shimmer.fromColors(
                          baseColor: const Color(0xFF1E293B),
                          highlightColor: const Color(0xFF334155),
                          child: Container(
                            height: 12,
                            width: 80,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }, childCount: 10),
              ),
            ),

          if (storeState == AppState.error)
            SliverStateView(
              description: "Something went wrong.\nPlease try again.",
              onRetry: () => fetchStores(reset: true),
            ),

          if (storeState == AppState.loaded && stores.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.store,
                        size: 80,
                        color: CityCipherTheme.mutedForeground.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "We couldn’t find any stores matching your search. Try refining your search.",
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
          if (storeState == AppState.loaded)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.88,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  return StoreCard(store: stores[index]);
                }, childCount: stores.length),
              ),
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
}

class SliverStateView extends StatelessWidget {
  final String description;
  final String? buttonText;
  final VoidCallback? onRetry;

  const SliverStateView({
    super.key,
    required this.description,
    this.buttonText,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/error/error.png',
                width: 300,
                height: 250,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CityCipherTheme.mutedForeground,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 13),
                TextButton(
                  onPressed: onRetry,
                  style: TextButton.styleFrom(
                    backgroundColor: CityCipherTheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 70),
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
            ],
          ),
        ),
      ),
    );
  }
}

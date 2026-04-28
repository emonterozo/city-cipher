import 'package:flutter/material.dart';
import 'game_tab.dart';
import 'home_tab.dart';
import 'rewards_tab.dart';
import 'core_theme.dart';

void main() => runApp(const CityCipherApp());

class CityCipherApp extends StatelessWidget {
  const CityCipherApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentTabIndex = 0;
  bool _isGameActive = false;

  late final List<Widget> _pages = [const HomeTab(), const RewardsTab()];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          extendBody: true,
          body: IndexedStack(index: _currentTabIndex, children: _pages),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: CityCipherTheme.primaryRed.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () => setState(() => _isGameActive = true),
              backgroundColor: CityCipherTheme.primaryRed,
              elevation: 0,
              shape: const CircleBorder(),
              child: const Icon(
                Icons.games_outlined,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            height: 70,
            color: Colors.white,
            shape: const CircularNotchedRectangle(),
            notchMargin: 8.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  label: "Home",
                ),

                const SizedBox(width: 48),
                _buildTabItem(
                  index: 1,
                  icon: Icons.card_giftcard_outlined,
                  label: "Rewards",
                ),
              ],
            ),
          ),
        ),
        if (_isGameActive)
          Positioned.fill(
            child: GameTab(
              isFullView: true,
              onClose: () => setState(() => _isGameActive = false),
            ),
          ),
      ],
    );
  }

  Widget _buildTabItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    bool isSelected = _currentTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentTabIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? CityCipherTheme.primaryRed : Colors.grey,
            size: 28,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? CityCipherTheme.primaryRed : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

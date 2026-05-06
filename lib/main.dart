import 'package:city_cipher/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'core/providers/auth_provider.dart';
import 'screens/game_tab.dart';
import 'screens/home_tab.dart';
import 'screens/rewards_tab.dart';
import 'core/theme.dart';

void main() => runApp(const ProviderScope(child: CityCipherApp()));

class CityCipherApp extends StatelessWidget {
  const CityCipherApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: CityCipherTheme.darkTheme,
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});
  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _currentTabIndex = 0;

  late final List<Widget> _pages = [const HomeTab(), const RewardsTab()];

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (prev, next) {
      if (next.isAuthenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => GameTab()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      }
    });
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentTabIndex, children: _pages),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: CityCipherTheme.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () async {
            //final storage = FlutterSecureStorage();
            //await storage.deleteAll();

            await ref.read(authProvider.notifier).loadAuth();
          },
          backgroundColor: CityCipherTheme.primary,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(
            LucideIcons.gamepad2,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 70,
        color: CityCipherTheme.foreground,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTabItem(index: 0, icon: LucideIcons.house, label: "Home"),
            const SizedBox(width: 48),
            _buildTabItem(index: 1, icon: LucideIcons.gift, label: "Rewards"),
          ],
        ),
      ),
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
            color: isSelected
                ? CityCipherTheme.primary
                : CityCipherTheme.mutedForeground,
            size: 28,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 10,
              color: isSelected
                  ? CityCipherTheme.primary
                  : CityCipherTheme.mutedForeground,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

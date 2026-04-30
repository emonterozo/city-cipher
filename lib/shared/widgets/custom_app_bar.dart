import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/app_typography.dart';
import '../../core/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final bool showBack;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      backgroundColor: CityCipherTheme.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: showBack ? 5 : 0),
        child: Row(
          children: [
            if (showBack)
              IconButton(
                onPressed: onBack ?? () => Navigator.pop(context),
                icon: const Icon(LucideIcons.chevronLeft),
                iconSize: 30,
                color: CityCipherTheme.foreground,
              )
            else
              const SizedBox(width: 30),
            const SizedBox(width: 3),
            Text(title, style: AppTypography.titleLarge),
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

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

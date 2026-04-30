import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme.dart';
import '../../models/store/store_model.dart';
import '../../screens/store_detail_screen.dart';

class StoreCard extends StatelessWidget {
  final Store store;
  final VoidCallback? onTap;

  const StoreCard({
    super.key,
    required this.store,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    StoreDetailScreen(storeId: store.id),
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
        padding: const EdgeInsets.all(16),
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
                      store.logo,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Icon(
                          LucideIcons.store,
                          size: 40,
                          color: CityCipherTheme.mutedForeground,
                        );
                      },
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
            Text(
              store.name,
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
          ],
        ),
      ),
    );
  }
}
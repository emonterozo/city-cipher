import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme.dart';

class StoreCardLoadingGrid extends StatelessWidget  {
  final int itemCount;


  const StoreCardLoadingGrid({
    super.key,
    this.itemCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.88,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Shimmer.fromColors(
              baseColor: const Color(0xFF1E293B),
              highlightColor: const Color(0xFF334155),
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
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(height: 12, width: 80, color: Colors.white),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


}

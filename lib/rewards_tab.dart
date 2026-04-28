import 'package:flutter/material.dart';
import 'core_theme.dart';

class RewardsTab extends StatelessWidget {
  const RewardsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for purchased vouchers
    final List<Map<String, String>> myVouchers = [
      {"title": "10% OFF Full Detail", "code": "RED10-XXXX", "expiry": "May 20, 2026"},
      {"title": "Free Ceramic Coating Wax", "code": "WAX-YYYY", "expiry": "June 05, 2026"},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("MY VOUCHERS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: myVouchers.isEmpty 
        ? _buildEmptyState() 
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: myVouchers.length,
            itemBuilder: (context, index) {
              return _buildVoucherCard(myVouchers[index]);
            },
          ),
    );
  }

  Widget _buildVoucherCard(Map<String, String> voucher) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: CityCipherTheme.primaryRed.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.confirmation_number_rounded, color: CityCipherTheme.primaryRed),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(voucher['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("Expires: ${voucher['expiry']}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(voucher['code']!, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, letterSpacing: 1)),
                ElevatedButton(
                  onPressed: () { /* Show QR or Code logic */ },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CityCipherTheme.primaryRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("USE NOW"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("No vouchers yet", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Play levels and redeem points to see them here!", style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
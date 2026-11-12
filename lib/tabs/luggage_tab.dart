import 'package:flutter/material.dart';
import '../models/packing_item.dart';
import '../models/trip.dart';

class LuggageTab extends StatelessWidget {
  final Trip trip;
  final ValueChanged<double> onMaxWeightChanged;

  const LuggageTab({
    super.key,
    required this.trip,
    required this.onMaxWeightChanged,
  });

  static const List<double> airlinePresets = [7.0, 10.0, 23.0, 32.0];

  String _presetTitle(double w) {
    if (w == 7.0) return '7 kg';
    if (w == 10.0) return '10 kg';
    if (w == 23.0) return '23 kg';
    if (w == 32.0) return '32 kg';
    return '${w.toStringAsFixed(0)} kg';
  }

  String _presetSubtitle(double w) {
    if (w == 7.0) return 'Cabin Bag';
    if (w == 10.0) return 'Budget Cabin';
    if (w == 23.0) return 'Checked Bag';
    if (w == 32.0) return 'Max / Business';
    return 'Custom';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final totalWeight = trip.totalWeightKg;
    final maxWeight = trip.maxWeightKg;
    final weightRatio = (maxWeight > 0 ? (totalWeight / maxWeight) : 0.0)
        .clamp(0.0, 1.0);
    final isOverweight = trip.isOverweight;
    final isWarning = !isOverweight && weightRatio > 0.85;

    final Color statusColor = isOverweight
        ? const Color(0xFFEF4444)
        : isWarning
            ? const Color(0xFFF59E0B)
            : const Color(0xFF10B981);

    // Compute category weight breakdown
    final Map<String, double> categoryWeights = {};
    for (final item in trip.items) {
      final w = item.weightKg * item.quantity;
      categoryWeights[item.category] = (categoryWeights[item.category] ?? 0.0) + w;
    }
    final sortedCategories = categoryWeights.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Heaviest items
    final heaviestItems = List<PackingItem>.from(trip.items)
      ..sort((a, b) => (b.weightKg * b.quantity).compareTo(a.weightKg * a.quantity));
    final topHeaviest = heaviestItems.where((i) => i.weightKg > 0).take(5).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Main Luggage Gauge Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.scale_rounded,
                        size: 22,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estimated Luggage Weight',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            isOverweight
                                ? 'Exceeds baggage limit!'
                                : 'Within airline baggage limit',
                            style: TextStyle(
                              fontSize: 11,
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Weight Counter Big Display
                Center(
                  child: Column(
                    children: [
                      RichText(
                        text: TextSpan(
                          text: totalWeight.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                          children: [
                            TextSpan(
                              text: ' / ${maxWeight.toStringAsFixed(0)} kg',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isOverweight
                            ? '⚠️ +${trip.excessWeightKg.toStringAsFixed(1)} kg over limit'
                            : '${trip.remainingWeightKg.toStringAsFixed(1)} kg weight allowance remaining',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isOverweight ? Colors.red : (isDark ? Colors.grey[300] : Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: weightRatio,
                    minHeight: 12,
                    backgroundColor: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
                const SizedBox(height: 12),

                // Packed vs Planned breakdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Packed Weight: ${trip.packedWeightKg.toStringAsFixed(1)} kg',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Planned Weight: ${(totalWeight - trip.packedWeightKg).toStringAsFixed(1)} kg',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Airline Limit Presets
        const Text(
          'Select Airline Baggage Allowance',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: airlinePresets.map((w) {
            final isSelected = (trip.maxWeightKg - w).abs() < 0.1;
            return Expanded(
              child: GestureDetector(
                onTap: () => onMaxWeightChanged(w),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withValues(alpha: 0.12)
                        : (isDark ? const Color(0xFF1E293B) : Colors.white),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _presetTitle(w),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? theme.colorScheme.primary : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _presetSubtitle(w),
                        style: TextStyle(
                          fontSize: 9,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : (isDark ? Colors.grey[400] : Colors.grey[600]),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Category Weight Breakdown
        const Text(
          'Weight by Category',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: sortedCategories.isEmpty
                ? const Center(child: Text('No weighted items yet'))
                : Column(
                    children: sortedCategories.map((entry) {
                      final catRatio = totalWeight > 0 ? (entry.value / totalWeight) : 0.0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${entry.value.toStringAsFixed(1)} kg (${(catRatio * 100).toInt()}%)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: catRatio,
                                minHeight: 6,
                                backgroundColor: isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFE2E8F0),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ),
        const SizedBox(height: 20),

        // Heaviest Items
        if (topHeaviest.isNotEmpty) ...[
          const Text(
            'Heaviest Packed Items',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topHeaviest.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, idx) {
                final item = topHeaviest[idx];
                final itemTotal = item.weightKg * item.quantity;
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 12,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                    child: Text(
                      '${idx + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  title: Text(
                    item.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    '${item.category} • Qty: ${item.quantity}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: Text(
                    '${itemTotal.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

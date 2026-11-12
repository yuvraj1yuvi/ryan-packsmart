import 'package:flutter/material.dart';
import '../models/trip.dart';

class WeightTrackerCard extends StatelessWidget {
  final Trip trip;
  final ValueChanged<double> onMaxWeightChanged;

  const WeightTrackerCard({
    super.key,
    required this.trip,
    required this.onMaxWeightChanged,
  });

  static const List<double> airlinePresets = [7.0, 10.0, 23.0, 32.0];

  String _presetLabel(double weight) {
    if (weight == 7.0) return '7kg (Cabin)';
    if (weight == 10.0) return '10kg (Budget)';
    if (weight == 23.0) return '23kg (Checked)';
    if (weight == 32.0) return '32kg (Max)';
    return '${weight.toStringAsFixed(1)}kg';
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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.scale_rounded,
                    size: 18,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Luggage Weight Tracker',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Estimates based on items',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${totalWeight.toStringAsFixed(1)} / ${maxWeight.toStringAsFixed(0)} kg',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Horizontal linear bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: weightRatio,
                minHeight: 10,
                backgroundColor: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
            const SizedBox(height: 8),

            // Overweight warning or safe summary
            if (isOverweight) ...[
              Container(
                margin: const EdgeInsets.only(top: 4, bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFDC2626),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Overweight by +${trip.excessWeightKg.toStringAsFixed(1)} kg! May incur airport excess fees.',
                        style: const TextStyle(
                          color: Color(0xFF991B1B),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Packed: ${trip.packedWeightKg.toStringAsFixed(1)} kg',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${trip.remainingWeightKg.toStringAsFixed(1)} kg remaining allowance',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),

            // Airline Preset chips
            Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Airline Limits:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                ...airlinePresets.map((weight) {
                  final isSelected = (trip.maxWeightKg - weight).abs() < 0.1;
                  return ChoiceChip(
                    label: Text(
                      _presetLabel(weight),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) => onMaxWeightChanged(weight),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

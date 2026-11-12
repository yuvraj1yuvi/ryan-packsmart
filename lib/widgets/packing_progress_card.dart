import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../models/trip.dart';

class PackingProgressCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback onEditTrip;
  final VoidCallback? onResetAll;
  final VoidCallback? onPackAll;

  const PackingProgressCard({
    super.key,
    required this.trip,
    required this.onEditTrip,
    this.onResetAll,
    this.onPackAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final percentage = trip.packedPercentage;
    final percentageInt = (percentage * 100).toInt();

    final Color ringColor = percentage >= 1.0
        ? const Color(0xFF10B981)
        : percentage >= 0.5
            ? const Color(0xFF007F73)
            : const Color(0xFFF59E0B);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                // Circular percentage widget
                CircularPercentIndicator(
                  radius: 46.0,
                  lineWidth: 8.5,
                  animation: true,
                  animationDuration: 700,
                  percent: percentage,
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: ringColor,
                  backgroundColor: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFE2E8F0),
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$percentageInt%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ringColor,
                        ),
                      ),
                      Text(
                        'PACKED',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),

                // Trip Information & Countdown
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              trip.title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            onPressed: onEditTrip,
                            tooltip: 'Edit Trip Details',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      if (trip.destination.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 13,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                trip.destination,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.grey[300]
                                      : Colors.grey[700],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 6),

                      // Countdown chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 11,
                              color: isDark ? Colors.grey[300] : Colors.grey[700],
                            ),
                            const SizedBox(width: 5),
                            Text(
                              trip.daysUntilDeparture <= 0
                                  ? '🎉 Departure today!'
                                  : '🛫 ${trip.daysUntilDeparture} days to departure',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.grey[200]
                                    : Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Item counts & quick action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatBadge(
                  context,
                  'Packed',
                  '${trip.packedItems}',
                  const Color(0xFF10B981),
                ),
                _buildStatBadge(
                  context,
                  'Pending',
                  '${trip.remainingItems}',
                  const Color(0xFFF59E0B),
                ),
                _buildStatBadge(
                  context,
                  'Total Items',
                  '${trip.totalItems}',
                  theme.colorScheme.primary,
                ),
                if (trip.totalItems > 0)
                  PopupMenuButton<String>(
                    tooltip: 'Quick Actions',
                    icon: const Icon(Icons.more_horiz_rounded),
                    onSelected: (val) {
                      if (val == 'pack_all') onPackAll?.call();
                      if (val == 'reset_all') onResetAll?.call();
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'pack_all',
                        child: Row(
                          children: [
                            Icon(Icons.done_all_rounded, size: 18),
                            SizedBox(width: 8),
                            Text('Mark All as Packed'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'reset_all',
                        child: Row(
                          children: [
                            Icon(Icons.restart_alt_rounded, size: 18),
                            SizedBox(width: 8),
                            Text('Reset / Unpack All'),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[400]
                : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

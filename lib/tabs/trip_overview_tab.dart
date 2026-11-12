import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../models/trip.dart';
import '../screens/export_screen.dart';
import '../services/pdf_service.dart';

class TripOverviewTab extends StatelessWidget {
  final Trip trip;
  final VoidCallback onEditTrip;
  final VoidCallback onPackAll;
  final VoidCallback onResetAll;

  const TripOverviewTab({
    super.key,
    required this.trip,
    required this.onEditTrip,
    required this.onPackAll,
    required this.onResetAll,
  });

  static final DateFormat _dateFormat = DateFormat('EEE, MMM dd, yyyy');

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

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Departure Countdown Card
        Card(
          color: theme.colorScheme.primary,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        trip.templateType,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
                      onPressed: onEditTrip,
                      tooltip: 'Edit Trip Details',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  trip.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (trip.destination.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 15,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trip.destination,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.flight_takeoff_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        trip.daysUntilDeparture <= 0
                            ? '🎉 Departure day has arrived!'
                            : '🛫 ${trip.daysUntilDeparture} days until departure (${_dateFormat.format(trip.departureDate)})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Packing Readiness KPI Ring Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Packing Readiness',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                CircularPercentIndicator(
                  radius: 54.0,
                  lineWidth: 10.0,
                  animation: true,
                  animationDuration: 800,
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
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: ringColor,
                        ),
                      ),
                      Text(
                        'PACKED',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol(context, 'Packed', '${trip.packedItems}', const Color(0xFF10B981)),
                    _buildStatCol(context, 'To Pack', '${trip.remainingItems}', const Color(0xFFF59E0B)),
                    _buildStatCol(context, 'Total Items', '${trip.totalItems}', theme.colorScheme.primary),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.done_all_rounded, size: 16),
                      label: const Text('Mark All Packed'),
                      onPressed: onPackAll,
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.restart_alt_rounded, size: 16),
                      label: const Text('Unpack All'),
                      onPressed: onResetAll,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Export & Share Checklist Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.share_rounded,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Export & Share Checklist',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Print or share with travel companions',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                        label: const Text('Preview PDF'),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ExportScreen(trip: trip),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.message_outlined, size: 16),
                        label: const Text('Share Text'),
                        onPressed: () => PdfService.shareAsText(trip),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('Copy Checklist to Clipboard'),
                    onPressed: () {
                      final text = PdfService.getShareableText(trip);
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Checklist copied to clipboard!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStatCol(BuildContext context, String label, String val, Color color) {
    return Column(
      children: [
        Text(
          val,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
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

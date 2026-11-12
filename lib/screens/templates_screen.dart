import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/template.dart';
import '../models/trip.dart';

class TemplatesScreen extends StatelessWidget {
  final ValueChanged<Trip> onTripCreated;
  final bool isTab;

  const TemplatesScreen({
    super.key,
    required this.onTripCreated,
    this.isTab = false,
  });

  void _showCreateFromTemplateSheet(BuildContext context, TripTemplate template) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _CreateTripSheet(
        template: template,
        onCreated: (trip) {
          Navigator.of(ctx).pop(); // close sheet
          if (!isTab) {
            Navigator.of(context).pop(); // return to home if pushed as route
          }
          onTripCreated(trip);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final body = ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0FDFA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFF99F6E4),
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/logo.jpg',
                    width: 38,
                    height: 38,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    'Select a curated template to instantly generate a complete, ready-to-pack checklist.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...AppTemplates.all.map((template) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: template.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            template.icon,
                            color: template.color,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                template.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                template.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _buildBadge(
                          context,
                          '${template.defaultItems.length} items',
                          Icons.checklist_rounded,
                        ),
                        _buildBadge(
                          context,
                          '${template.defaultMaxWeightKg.toStringAsFixed(0)} kg limit',
                          Icons.scale_rounded,
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Use Template'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () =>
                              _showCreateFromTemplateSheet(context, template),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      );

    if (isTab) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Templates'),
      ),
      body: body,
    );
  }

  Widget _buildBadge(BuildContext context, String text, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateTripSheet extends StatefulWidget {
  final TripTemplate template;
  final ValueChanged<Trip> onCreated;

  const _CreateTripSheet({
    required this.template,
    required this.onCreated,
  });

  @override
  State<_CreateTripSheet> createState() => _CreateTripSheetState();
}

class _CreateTripSheetState extends State<_CreateTripSheet> {
  late TextEditingController _titleController;
  late TextEditingController _destController;
  DateTime _departureDate = DateTime.now().add(const Duration(days: 7));
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.template.name);
    _destController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _destController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _departureDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() => _departureDate = picked);
    }
  }

  void _submit() {
    final title = _titleController.text.trim();
    final newTrip = widget.template.createTrip(
      title: title.isEmpty ? widget.template.name : title,
      destination: _destController.text.trim(),
      departureDate: _departureDate,
    );
    widget.onCreated(newTrip);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'New Trip: ${widget.template.name}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Trip Name',
              hintText: 'e.g. Cancun Beach Holiday',
              prefixIcon: Icon(Icons.flight_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _destController,
            decoration: const InputDecoration(
              labelText: 'Destination (Optional)',
              hintText: 'e.g. Cancun, Mexico',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF334155)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFCBD5E1),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Departure Date:'),
                  Text(
                    _dateFormat.format(_departureDate),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              child: const Text('Start Packing'),
            ),
          ),
        ],
      ),
    );
  }
}

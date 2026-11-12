import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trip.dart';

class TripEditDialog extends StatefulWidget {
  final Trip trip;
  final ValueChanged<Trip> onSave;
  final VoidCallback? onDelete;

  const TripEditDialog({
    super.key,
    required this.trip,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<TripEditDialog> createState() => _TripEditDialogState();
}

class _TripEditDialogState extends State<TripEditDialog> {
  late TextEditingController _titleController;
  late TextEditingController _destController;
  late TextEditingController _weightController;
  late DateTime _departureDate;
  DateTime? _returnDate;

  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.trip.title);
    _destController = TextEditingController(text: widget.trip.destination);
    _weightController = TextEditingController(
      text: widget.trip.maxWeightKg.toStringAsFixed(0),
    );
    _departureDate = widget.trip.departureDate;
    _returnDate = widget.trip.returnDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _destController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickDepartureDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _departureDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() {
        _departureDate = picked;
        if (_returnDate != null && _returnDate!.isBefore(_departureDate)) {
          _returnDate = _departureDate.add(const Duration(days: 7));
        }
      });
    }
  }

  Future<void> _pickReturnDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _returnDate ?? _departureDate.add(const Duration(days: 7)),
      firstDate: _departureDate,
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() => _returnDate = picked);
    }
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final weight = double.tryParse(_weightController.text.trim()) ?? 23.0;

    final updated = widget.trip.copyWith(
      title: title,
      destination: _destController.text.trim(),
      departureDate: _departureDate,
      returnDate: _returnDate,
      maxWeightKg: weight,
    );

    widget.onSave(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Trip Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Trip Name',
                  hintText: 'e.g. Summer in Tokyo',
                  prefixIcon: Icon(Icons.flight_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _destController,
                decoration: const InputDecoration(
                  labelText: 'Destination',
                  hintText: 'e.g. Tokyo, Japan',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDepartureDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Departure',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _dateFormat.format(_departureDate),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: _pickReturnDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Return',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _returnDate != null
                                  ? _dateFormat.format(_returnDate!)
                                  : 'Optional',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: _returnDate != null
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Baggage Allowance Limit',
                  suffixText: 'kg',
                  prefixIcon: Icon(Icons.scale_outlined),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save Trip Details'),
                ),
              ),
              if (widget.onDelete != null) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete This Trip'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onDelete?.call();
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

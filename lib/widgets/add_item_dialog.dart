import 'package:flutter/material.dart';
import '../models/packing_item.dart';

class AddItemDialog extends StatefulWidget {
  final PackingItem? initialItem;
  final List<String> existingCategories;
  final ValueChanged<PackingItem> onSave;

  const AddItemDialog({
    super.key,
    this.initialItem,
    required this.existingCategories,
    required this.onSave,
  });

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  late TextEditingController _nameController;
  late TextEditingController _weightController;
  late String _selectedCategory;
  late int _quantity;

  static const List<String> _defaultCategories = [
    'Clothing',
    'Electronics',
    'Toiletries',
    'Documents',
    'Gear',
    'Health & Essentials',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    _nameController = TextEditingController(text: item?.name ?? '');
    _weightController = TextEditingController(
      text: item != null && item.weightKg > 0
          ? item.weightKg.toString()
          : '0.2',
    );
    _quantity = item?.quantity ?? 1;

    final categories = _allCategories;
    if (item != null && categories.contains(item.category)) {
      _selectedCategory = item.category;
    } else {
      _selectedCategory = categories.first;
    }
  }

  List<String> get _allCategories {
    final set = <String>{..._defaultCategories, ...widget.existingCategories};
    return set.toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final weight = double.tryParse(_weightController.text.trim()) ?? 0.0;

    final updated = PackingItem(
      id: widget.initialItem?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      category: _selectedCategory,
      isPacked: widget.initialItem?.isPacked ?? false,
      weightKg: weight,
      quantity: _quantity,
      notes: widget.initialItem?.notes,
    );

    widget.onSave(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialItem != null;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Item' : 'Add Packing Item',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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

              // Item Name
              TextField(
                controller: _nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  hintText: 'e.g. Universal Travel Adapter',
                  prefixIcon: Icon(Icons.luggage_outlined),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Category Picker
              const Text(
                'Category',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _allCategories.map((cat) {
                  final isSelected = cat == _selectedCategory;
                  return ChoiceChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = cat);
                    },
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Quantity & Weight Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quantity
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quantity',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFCBD5E1),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 16),
                                onPressed: _quantity > 1
                                    ? () => setState(() => _quantity--)
                                    : null,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                              Text(
                                '$_quantity',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 16),
                                onPressed: () => setState(() => _quantity++),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Weight
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Weight (kg)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _weightController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            suffixText: 'kg',
                            hintText: '0.2',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Quick Weight presets
              Wrap(
                spacing: 6,
                children: [0.1, 0.3, 0.5, 1.0].map((w) {
                  return ActionChip(
                    label: Text('${w}kg', style: const TextStyle(fontSize: 10)),
                    onPressed: () {
                      _weightController.text = w.toString();
                    },
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(isEditing ? 'Save Changes' : 'Add to Checklist'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

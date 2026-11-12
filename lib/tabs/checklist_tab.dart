import 'package:flutter/material.dart';
import '../models/packing_item.dart';
import '../models/trip.dart';
import '../widgets/item_card.dart';

class ChecklistTab extends StatefulWidget {
  final Trip trip;
  final Function(PackingItem, bool) onTogglePacked;
  final Function(PackingItem) onEditItem;
  final Function(PackingItem) onDeleteItem;
  final VoidCallback onAddItem;

  const ChecklistTab({
    super.key,
    required this.trip,
    required this.onTogglePacked,
    required this.onEditItem,
    required this.onDeleteItem,
    required this.onAddItem,
  });

  @override
  State<ChecklistTab> createState() => _ChecklistTabState();
}

class _ChecklistTabState extends State<ChecklistTab> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _statusFilter = 'All'; // 'All', 'Pending', 'Packed'

  List<PackingItem> get _filteredItems {
    var list = widget.trip.items;

    // Search query filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((i) => i.name.toLowerCase().contains(q)).toList();
    }

    // Status filter
    if (_statusFilter == 'Pending') {
      list = list.where((i) => !i.isPacked).toList();
    } else if (_statusFilter == 'Packed') {
      list = list.where((i) => i.isPacked).toList();
    }

    // Category filter
    if (_selectedCategory != 'All') {
      list = list.where((i) => i.category == _selectedCategory).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final trip = widget.trip;
    final items = _filteredItems;

    return Column(
      children: [
        // Top Mini Progress Strip
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 16,
                        color: trip.packedPercentage >= 1.0
                            ? const Color(0xFF10B981)
                            : theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${(trip.packedPercentage * 100).toInt()}% Packed',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: trip.packedPercentage >= 1.0
                              ? const Color(0xFF10B981)
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${trip.packedItems} of ${trip.totalItems} items',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: trip.packedPercentage,
                  minHeight: 6,
                  backgroundColor: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    trip.packedPercentage >= 1.0
                        ? const Color(0xFF10B981)
                        : theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Search & Filter Controls
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // Search input
              TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search items (e.g. passport, shoes)...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => setState(() => _searchQuery = ''),
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Filter Tabs (All / To Pack / Packed)
              Row(
                children: [
                  _buildStatusFilterChip('All', trip.totalItems),
                  const SizedBox(width: 8),
                  _buildStatusFilterChip(
                    'Pending',
                    trip.remainingItems,
                    label: 'To Pack',
                  ),
                  const SizedBox(width: 8),
                  _buildStatusFilterChip(
                    'Packed',
                    trip.packedItems,
                    label: 'Packed',
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Categories Horizontal Scroll Bar
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('All Categories'),
                      selected: _selectedCategory == 'All',
                      onSelected: (sel) {
                        if (sel) setState(() => _selectedCategory = 'All');
                      },
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 6),
                    ...trip.categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (sel) {
                            setState(() {
                              _selectedCategory = sel ? cat : 'All';
                            });
                          },
                          visualDensity: VisualDensity.compact,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Items List
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 48,
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'No items match "$_searchQuery"'
                            : 'No items in this category',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Item'),
                        onPressed: widget.onAddItem,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80, top: 4),
                  itemCount: items.length,
                  itemBuilder: (ctx, idx) {
                    final item = items[idx];
                    return ItemCard(
                      item: item,
                      onTogglePacked: (val) =>
                          widget.onTogglePacked(item, val ?? false),
                      onEdit: () => widget.onEditItem(item),
                      onDelete: () => widget.onDeleteItem(item),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatusFilterChip(String key, int count, {String? label}) {
    final isSelected = _statusFilter == key;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => setState(() => _statusFilter = key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
                : (Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
              ),
              Text(
                label ?? key,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

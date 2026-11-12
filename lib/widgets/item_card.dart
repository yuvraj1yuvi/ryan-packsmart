import 'package:flutter/material.dart';
import '../models/packing_item.dart';

class ItemCard extends StatelessWidget {
  final PackingItem item;
  final ValueChanged<bool?> onTogglePacked;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ItemCard({
    super.key,
    required this.item,
    required this.onTogglePacked,
    required this.onEdit,
    required this.onDelete,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'documents':
        return Icons.description_outlined;
      case 'clothing':
        return Icons.checkroom_rounded;
      case 'toiletries':
        return Icons.spa_outlined;
      case 'electronics':
        return Icons.devices_rounded;
      case 'gear':
        return Icons.backpack_outlined;
      case 'health & essentials':
      case 'medical':
        return Icons.medication_outlined;
      case 'essentials':
        return Icons.verified_user_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isPacked = item.isPacked;

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: const Color(0xFFEF4444),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPacked
                ? (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
                : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onTogglePacked(!isPacked),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                // Custom Checkbox
                Transform.scale(
                  scale: 1.1,
                  child: Checkbox(
                    value: isPacked,
                    onChanged: onTogglePacked,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    activeColor: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 4),

                // Item Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isPacked ? FontWeight.normal : FontWeight.w600,
                          decoration:
                              isPacked ? TextDecoration.lineThrough : null,
                          color: isPacked
                              ? (isDark ? Colors.grey[500] : Colors.grey[400])
                              : (isDark ? Colors.white : const Color(0xFF0F172A)),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            _getCategoryIcon(item.category),
                            size: 11,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.category,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          if (item.quantity > 1) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Qty: ${item.quantity}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.grey[300] : Colors.grey[800],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Weight Tag
                if (item.weightKg > 0)
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
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
                          Icons.scale_outlined,
                          size: 10,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${(item.weightKg * item.quantity).toStringAsFixed(1)} kg',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Popup menu for edit/delete
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    size: 18,
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onSelected: (val) {
                    if (val == 'edit') onEdit();
                    if (val == 'delete') onDelete();
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 16),
                          SizedBox(width: 8),
                          Text('Edit Item'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red, size: 16),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/packing_item.dart';
import '../models/trip.dart';
import '../services/storage_service.dart';
import '../tabs/checklist_tab.dart';
import '../tabs/luggage_tab.dart';
import '../tabs/trip_overview_tab.dart';
import '../widgets/add_item_dialog.dart';
import '../widgets/trip_edit_dialog.dart';
import 'templates_screen.dart';
import 'export_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();

  List<Trip> _trips = [];
  Trip? _activeTrip;
  bool _isLoading = true;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final trips = await _storageService.loadTrips();
    final activeId = await _storageService.getActiveTripId();

    Trip? active;
    if (trips.isNotEmpty) {
      active = trips.firstWhere(
        (t) => t.id == activeId,
        orElse: () => trips.first,
      );
    }

    setState(() {
      _trips = trips;
      _activeTrip = active;
      _isLoading = false;
    });
  }

  Future<void> _saveCurrentState() async {
    if (_activeTrip == null) return;
    final index = _trips.indexWhere((t) => t.id == _activeTrip!.id);
    if (index != -1) {
      _trips[index] = _activeTrip!;
    } else {
      _trips.add(_activeTrip!);
    }
    await _storageService.saveTrips(_trips);
    await _storageService.setActiveTripId(_activeTrip!.id);
  }

  void _switchTrip(Trip trip) {
    setState(() {
      _activeTrip = trip;
    });
    _storageService.setActiveTripId(trip.id);
  }

  void _onAddNewTrip(Trip newTrip) {
    setState(() {
      _trips.insert(0, newTrip);
      _activeTrip = newTrip;
      _currentTabIndex = 0; // Switch to checklist of the new trip
    });
    _saveCurrentState();
  }

  void _deleteCurrentTrip() async {
    if (_activeTrip == null) return;
    setState(() {
      _trips.removeWhere((t) => t.id == _activeTrip!.id);
      _activeTrip = _trips.isNotEmpty ? _trips.first : null;
    });
    await _storageService.saveTrips(_trips);
    if (_activeTrip != null) {
      await _storageService.setActiveTripId(_activeTrip!.id);
    }
  }

  void _toggleItemPacked(PackingItem item, bool isPacked) {
    if (_activeTrip == null) return;
    final updatedItems = _activeTrip!.items.map((i) {
      if (i.id == item.id) {
        return i.copyWith(isPacked: isPacked);
      }
      return i;
    }).toList();

    setState(() {
      _activeTrip = _activeTrip!.copyWith(items: updatedItems);
    });
    _saveCurrentState();
  }

  void _addOrEditItem(PackingItem item, {bool isEdit = false}) {
    if (_activeTrip == null) return;
    List<PackingItem> updatedItems;
    if (isEdit) {
      updatedItems = _activeTrip!.items.map((i) {
        return i.id == item.id ? item : i;
      }).toList();
    } else {
      updatedItems = [item, ..._activeTrip!.items];
    }

    setState(() {
      _activeTrip = _activeTrip!.copyWith(items: updatedItems);
    });
    _saveCurrentState();
  }

  void _deleteItem(PackingItem item) {
    if (_activeTrip == null) return;
    final updatedItems =
        _activeTrip!.items.where((i) => i.id != item.id).toList();

    setState(() {
      _activeTrip = _activeTrip!.copyWith(items: updatedItems);
    });
    _saveCurrentState();
  }

  void _packAllItems() {
    if (_activeTrip == null) return;
    final updated = _activeTrip!.items
        .map((i) => i.copyWith(isPacked: true))
        .toList();
    setState(() {
      _activeTrip = _activeTrip!.copyWith(items: updated);
    });
    _saveCurrentState();
  }

  void _resetAllItems() {
    if (_activeTrip == null) return;
    final updated = _activeTrip!.items
        .map((i) => i.copyWith(isPacked: false))
        .toList();
    setState(() {
      _activeTrip = _activeTrip!.copyWith(items: updated);
    });
    _saveCurrentState();
  }

  void _showAddDialog([PackingItem? existingItem]) {
    if (_activeTrip == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AddItemDialog(
        initialItem: existingItem,
        existingCategories: _activeTrip!.categories,
        onSave: (item) => _addOrEditItem(item, isEdit: existingItem != null),
      ),
    );
  }

  void _showEditTripDialog() {
    if (_activeTrip == null) return;
    showDialog(
      context: context,
      builder: (ctx) => TripEditDialog(
        trip: _activeTrip!,
        onSave: (updated) {
          setState(() => _activeTrip = updated);
          _saveCurrentState();
        },
        onDelete: _trips.length > 1 ? _deleteCurrentTrip : null,
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                'assets/images/logo.jpg',
                width: 84,
                height: 84,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'PackSmart',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF007F73).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'v1.0.0',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF007F73),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Smart travel packing checklist & luggage weight tracker designed to keep your journeys organized and stress-free.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTripPickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Switch Trip',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Trip'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    setState(() => _currentTabIndex = 3); // Switch to Templates tab
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _trips.length,
                itemBuilder: (ctx, idx) {
                  final t = _trips[idx];
                  final isSelected = t.id == _activeTrip?.id;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[200],
                      child: Icon(
                        Icons.flight_takeoff_rounded,
                        color: isSelected ? Colors.white : Colors.grey[700],
                        size: 18,
                      ),
                    ),
                    title: Text(
                      t.title,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      '${t.packedItems}/${t.totalItems} Packed • ${t.totalWeightKg.toStringAsFixed(1)} kg',
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Color(0xFF10B981))
                        : null,
                    onTap: () {
                      _switchTrip(t);
                      Navigator.of(ctx).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final trip = _activeTrip;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: _showTripPickerSheet,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Image.asset(
                    'assets/images/logo.jpg',
                    width: 26,
                    height: 26,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    trip?.title ?? 'PackSmart',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, size: 18),
              ],
            ),
          ),
        ),
        actions: [
          if (trip != null)
            IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: 'Export & Share PDF',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ExportScreen(trip: trip),
                  ),
                );
              },
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'More Options',
            onSelected: (val) {
              if (val == 'theme') widget.onToggleTheme();
              if (val == 'about') _showAboutDialog();
              if (val == 'edit_trip') _showEditTripDialog();
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'theme',
                child: Row(
                  children: [
                    Icon(
                      widget.isDarkMode
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(widget.isDarkMode ? 'Light Mode' : 'Dark Mode'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'edit_trip',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 20),
                    SizedBox(width: 10),
                    Text('Trip Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'about',
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 20),
                    SizedBox(width: 10),
                    Text('About PackSmart'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: _currentTabIndex == 0 && trip != null
          ? FloatingActionButton.extended(
              onPressed: () => _showAddDialog(),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text(
                'Add Item',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTabIndex,
        onDestinationSelected: (idx) {
          setState(() => _currentTabIndex = idx);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist_rounded),
            label: 'Checklist',
          ),
          NavigationDestination(
            icon: Icon(Icons.scale_outlined),
            selectedIcon: Icon(Icons.scale_rounded),
            label: 'Luggage',
          ),
          NavigationDestination(
            icon: Icon(Icons.flight_outlined),
            selectedIcon: Icon(Icons.flight_takeoff_rounded),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome_rounded),
            label: 'Templates',
          ),
        ],
      ),
      body: trip == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/logo.jpg',
                      width: 84,
                      height: 84,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('No trips created yet!'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _currentTabIndex = 3);
                    },
                    child: const Text('Choose a Template'),
                  ),
                ],
              ),
            )
          : IndexedStack(
              index: _currentTabIndex,
              children: [
                // Tab 0: Checklist (Packing)
                ChecklistTab(
                  trip: trip,
                  onTogglePacked: _toggleItemPacked,
                  onEditItem: (item) => _showAddDialog(item),
                  onDeleteItem: _deleteItem,
                  onAddItem: () => _showAddDialog(),
                ),

                // Tab 1: Luggage & Weight
                LuggageTab(
                  trip: trip,
                  onMaxWeightChanged: (newLimit) {
                    setState(() {
                      _activeTrip = trip.copyWith(maxWeightKg: newLimit);
                    });
                    _saveCurrentState();
                  },
                ),

                // Tab 2: Trip Overview & Readiness
                TripOverviewTab(
                  trip: trip,
                  onEditTrip: _showEditTripDialog,
                  onPackAll: _packAllItems,
                  onResetAll: _resetAllItems,
                ),

                // Tab 3: Templates Catalog
                TemplatesScreen(
                  isTab: true,
                  onTripCreated: _onAddNewTrip,
                ),
              ],
            ),
    );
  }
}

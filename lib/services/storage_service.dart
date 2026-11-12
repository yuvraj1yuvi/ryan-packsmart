import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trip.dart';
import '../models/template.dart';

class StorageService {
  static const String _keyTrips = 'packsmart_trips_data';
  static const String _keyActiveTripId = 'packsmart_active_trip_id';

  Future<List<Trip>> loadTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final rawData = prefs.getString(_keyTrips);

    if (rawData == null || rawData.isEmpty) {
      // First launch: Seed initial sample trip from International Flight template
      final initialTrip = AppTemplates.all.first.createTrip(
        title: 'European Summer Vacation',
        destination: 'Paris & Rome',
        departureDate: DateTime.now().add(const Duration(days: 6)),
        returnDate: DateTime.now().add(const Duration(days: 18)),
        customMaxWeightKg: 23.0,
      );

      // Pre-pack a few items to demonstrate the progress ring immediately
      final updatedItems = initialTrip.items.map((item) {
        if (item.name.contains('Passport') ||
            item.name.contains('Universal Travel Adapter') ||
            item.name.contains('Boarding Pass')) {
          return item.copyWith(isPacked: true);
        }
        return item;
      }).toList();

      final seededTrip = initialTrip.copyWith(items: updatedItems);
      await saveTrips([seededTrip]);
      await setActiveTripId(seededTrip.id);
      return [seededTrip];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(rawData) as List<dynamic>;
      return jsonList
          .map((item) => Trip.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Fallback in case of parsing corruption
      return [];
    }
  }

  Future<void> saveTrips(List<Trip> trips) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = trips.map((t) => t.toJson()).toList();
    await prefs.setString(_keyTrips, jsonEncode(jsonList));
  }

  Future<String?> getActiveTripId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyActiveTripId);
  }

  Future<void> setActiveTripId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyActiveTripId, id);
  }
}

import 'package:flutter/material.dart';
import 'packing_item.dart';
import 'trip.dart';

class TripTemplate {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final double defaultMaxWeightKg;
  final List<PackingItem> defaultItems;

  const TripTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.defaultMaxWeightKg,
    required this.defaultItems,
  });

  Trip createTrip({
    required String title,
    required String destination,
    required DateTime departureDate,
    DateTime? returnDate,
    double? customMaxWeightKg,
  }) {
    return Trip(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.isEmpty ? name : title,
      destination: destination,
      departureDate: departureDate,
      returnDate: returnDate,
      templateType: name,
      maxWeightKg: customMaxWeightKg ?? defaultMaxWeightKg,
      items: defaultItems
          .map((item) => item.copyWith(
                id: '${DateTime.now().millisecondsSinceEpoch}_${item.name.hashCode}',
                isPacked: false,
              ))
          .toList(),
    );
  }
}

class AppTemplates {
  static const List<TripTemplate> all = [
    TripTemplate(
      id: 'international_flight',
      name: 'International Flight',
      description: 'Comprehensive essentials for global long-haul flights & multi-day stays.',
      icon: Icons.flight_takeoff_rounded,
      color: Color(0xFF028090),
      defaultMaxWeightKg: 23.0,
      defaultItems: [
        // Documents
        PackingItem(id: 'if_1', name: 'Passport & Visa Copies', category: 'Documents', weightKg: 0.1, quantity: 1),
        PackingItem(id: 'if_2', name: 'Boarding Pass & Tickets', category: 'Documents', weightKg: 0.05, quantity: 1),
        PackingItem(id: 'if_3', name: 'Travel Insurance Documents', category: 'Documents', weightKg: 0.05, quantity: 1),
        PackingItem(id: 'if_4', name: 'Credit Cards & Local Currency', category: 'Documents', weightKg: 0.1, quantity: 1),
        // Electronics
        PackingItem(id: 'if_5', name: 'Universal Travel Adapter', category: 'Electronics', weightKg: 0.2, quantity: 1),
        PackingItem(id: 'if_6', name: 'Smartphone & Charger', category: 'Electronics', weightKg: 0.3, quantity: 1),
        PackingItem(id: 'if_7', name: 'Power Bank (Carry-on safe)', category: 'Electronics', weightKg: 0.35, quantity: 1),
        PackingItem(id: 'if_8', name: 'Noise-Canceling Headphones', category: 'Electronics', weightKg: 0.25, quantity: 1),
        PackingItem(id: 'if_9', name: 'Laptop / Tablet & Charger', category: 'Electronics', weightKg: 1.8, quantity: 1),
        // Clothing
        PackingItem(id: 'if_10', name: 'T-Shirts & Tops (x5)', category: 'Clothing', weightKg: 1.0, quantity: 5),
        PackingItem(id: 'if_11', name: 'Pants & Jeans (x2)', category: 'Clothing', weightKg: 1.2, quantity: 2),
        PackingItem(id: 'if_12', name: 'Underwear & Socks (x7)', category: 'Clothing', weightKg: 0.6, quantity: 7),
        PackingItem(id: 'if_13', name: 'Light Weather Jacket', category: 'Clothing', weightKg: 0.8, quantity: 1),
        PackingItem(id: 'if_14', name: 'Comfortable Walking Shoes', category: 'Clothing', weightKg: 0.9, quantity: 1),
        PackingItem(id: 'if_15', name: 'Sleepwear / Loungewear', category: 'Clothing', weightKg: 0.4, quantity: 2),
        // Toiletries
        PackingItem(id: 'if_16', name: 'TSA Travel Bottles Kit (Liquids <100ml)', category: 'Toiletries', weightKg: 0.5, quantity: 1),
        PackingItem(id: 'if_17', name: 'Toothbrush & Travel Toothpaste', category: 'Toiletries', weightKg: 0.15, quantity: 1),
        PackingItem(id: 'if_18', name: 'Deodorant & Skincare', category: 'Toiletries', weightKg: 0.3, quantity: 1),
        // Health & Gear
        PackingItem(id: 'if_19', name: 'Prescription & Emergency Meds', category: 'Health & Essentials', weightKg: 0.25, quantity: 1),
        PackingItem(id: 'if_20', name: 'Memory Foam Neck Pillow', category: 'Health & Essentials', weightKg: 0.3, quantity: 1),
        PackingItem(id: 'if_21', name: 'TSA Luggage Lock', category: 'Health & Essentials', weightKg: 0.1, quantity: 2),
      ],
    ),
    TripTemplate(
      id: 'beach_vacation',
      name: 'Beach & Island Holiday',
      description: 'Sun, sand, swimming, and warm-weather resort essentials.',
      icon: Icons.beach_access_rounded,
      color: Color(0xFFF77F00),
      defaultMaxWeightKg: 15.0,
      defaultItems: [
        PackingItem(id: 'bv_1', name: 'Swimwear & Trunks (x3)', category: 'Clothing', weightKg: 0.45, quantity: 3),
        PackingItem(id: 'bv_2', name: 'Linen Shirts & Shorts', category: 'Clothing', weightKg: 0.8, quantity: 4),
        PackingItem(id: 'bv_3', name: 'Flip-flops & Beach Slides', category: 'Clothing', weightKg: 0.4, quantity: 1),
        PackingItem(id: 'bv_4', name: 'UV Sun Hat & Cap', category: 'Clothing', weightKg: 0.15, quantity: 1),
        PackingItem(id: 'bv_5', name: 'Polarized Sunglasses', category: 'Essentials', weightKg: 0.1, quantity: 1),
        PackingItem(id: 'bv_6', name: 'High SPF Sunscreen (Reef-safe)', category: 'Toiletries', weightKg: 0.3, quantity: 1),
        PackingItem(id: 'bv_7', name: 'After-Sun Soothing Aloe Gel', category: 'Toiletries', weightKg: 0.25, quantity: 1),
        PackingItem(id: 'bv_8', name: 'Quick-Dry Microfiber Beach Towel', category: 'Gear', weightKg: 0.35, quantity: 1),
        PackingItem(id: 'bv_9', name: 'Waterproof Phone Dry Bag', category: 'Gear', weightKg: 0.1, quantity: 1),
        PackingItem(id: 'bv_10', name: 'Snorkel Mask & Goggles', category: 'Gear', weightKg: 0.5, quantity: 1),
        PackingItem(id: 'bv_11', name: 'Portable Bluetooth Speaker', category: 'Electronics', weightKg: 0.4, quantity: 1),
      ],
    ),
    TripTemplate(
      id: 'business_trip',
      name: 'Business & Conference',
      description: 'Tailored for sharp presentation, meetings, and fast carry-on travel.',
      icon: Icons.business_center_rounded,
      color: Color(0xFF003049),
      defaultMaxWeightKg: 10.0,
      defaultItems: [
        PackingItem(id: 'bt_1', name: 'Suit Jacket / Blazer', category: 'Clothing', weightKg: 1.2, quantity: 1),
        PackingItem(id: 'bt_2', name: 'Pressed Dress Shirts (x3)', category: 'Clothing', weightKg: 0.75, quantity: 3),
        PackingItem(id: 'bt_3', name: 'Formal Trousers / Slacks', category: 'Clothing', weightKg: 0.9, quantity: 2),
        PackingItem(id: 'bt_4', name: 'Formal Leather Shoes & Belt', category: 'Clothing', weightKg: 1.1, quantity: 1),
        PackingItem(id: 'bt_5', name: 'Work Laptop & Power Brick', category: 'Electronics', weightKg: 2.1, quantity: 1),
        PackingItem(id: 'bt_6', name: 'Presentation Clicker & HDMI Hub', category: 'Electronics', weightKg: 0.2, quantity: 1),
        PackingItem(id: 'bt_7', name: 'Noise-Canceling Earbuds', category: 'Electronics', weightKg: 0.1, quantity: 1),
        PackingItem(id: 'bt_8', name: 'Business Cards & Notepad', category: 'Essentials', weightKg: 0.2, quantity: 1),
        PackingItem(id: 'bt_9', name: 'Compact Garment Steamer', category: 'Gear', weightKg: 0.7, quantity: 1),
        PackingItem(id: 'bt_10', name: 'Breath Mints & Grooming Kit', category: 'Toiletries', weightKg: 0.25, quantity: 1),
      ],
    ),
    TripTemplate(
      id: 'camping_hiking',
      name: 'Camping & Outdoor Trek',
      description: 'Rugged gear, weather defense, and backcountry survival items.',
      icon: Icons.terrain_rounded,
      color: Color(0xFF2D6A4F),
      defaultMaxWeightKg: 16.0,
      defaultItems: [
        PackingItem(id: 'ch_1', name: 'Lightweight 2-Person Tent', category: 'Gear', weightKg: 2.4, quantity: 1),
        PackingItem(id: 'ch_2', name: 'Sleeping Bag & Insulated Mat', category: 'Gear', weightKg: 1.6, quantity: 1),
        PackingItem(id: 'ch_3', name: 'Waterproof Hiking Boots', category: 'Clothing', weightKg: 1.4, quantity: 1),
        PackingItem(id: 'ch_4', name: 'Moisture-Wicking Thermal Base Layer', category: 'Clothing', weightKg: 0.5, quantity: 2),
        PackingItem(id: 'ch_5', name: 'Breathable Rain Jacket', category: 'Clothing', weightKg: 0.45, quantity: 1),
        PackingItem(id: 'ch_6', name: 'Water Filtration Bottle / Tablets', category: 'Health & Essentials', weightKg: 0.3, quantity: 1),
        PackingItem(id: 'ch_7', name: 'Headlamp with Extra Batteries', category: 'Gear', weightKg: 0.2, quantity: 1),
        PackingItem(id: 'ch_8', name: 'Swiss Multi-Tool Knife', category: 'Gear', weightKg: 0.25, quantity: 1),
        PackingItem(id: 'ch_9', name: 'Wilderness First Aid & Blister Kit', category: 'Health & Essentials', weightKg: 0.4, quantity: 1),
        PackingItem(id: 'ch_10', name: 'Camp Stove & Titanium Cookpot', category: 'Gear', weightKg: 0.7, quantity: 1),
        PackingItem(id: 'ch_11', name: 'High-Deet Insect Repellent', category: 'Toiletries', weightKg: 0.2, quantity: 1),
      ],
    ),
    TripTemplate(
      id: 'weekend_getaway',
      name: 'Weekend City Break',
      description: 'Light, quick 2-3 day city getaway for carry-on only travel.',
      icon: Icons.location_city_rounded,
      color: Color(0xFF6B4E71),
      defaultMaxWeightKg: 7.0,
      defaultItems: [
        PackingItem(id: 'wg_1', name: 'Casual Outfits (x2)', category: 'Clothing', weightKg: 0.7, quantity: 2),
        PackingItem(id: 'wg_2', name: 'Evening / Dinner Outfit', category: 'Clothing', weightKg: 0.5, quantity: 1),
        PackingItem(id: 'wg_3', name: 'Comfortable Sneakers', category: 'Clothing', weightKg: 0.8, quantity: 1),
        PackingItem(id: 'wg_4', name: 'Undergarments & Socks (x3)', category: 'Clothing', weightKg: 0.3, quantity: 3),
        PackingItem(id: 'wg_5', name: 'Compact Folding Umbrella', category: 'Essentials', weightKg: 0.3, quantity: 1),
        PackingItem(id: 'wg_6', name: 'Phone Charger & Mini Power Bank', category: 'Electronics', weightKg: 0.3, quantity: 1),
        PackingItem(id: 'wg_7', name: 'Mini Toiletries & Toothbrush', category: 'Toiletries', weightKg: 0.35, quantity: 1),
        PackingItem(id: 'wg_8', name: 'Crossbody Daypack', category: 'Gear', weightKg: 0.4, quantity: 1),
      ],
    ),
    TripTemplate(
      id: 'winter_ski',
      name: 'Winter & Snow Vacation',
      description: 'Cold weather layering, snow gear, and cozy insulation.',
      icon: Icons.ac_unit_rounded,
      color: Color(0xFF1D3557),
      defaultMaxWeightKg: 23.0,
      defaultItems: [
        PackingItem(id: 'ws_1', name: 'Insulated Waterproof Ski Jacket', category: 'Clothing', weightKg: 1.5, quantity: 1),
        PackingItem(id: 'ws_2', name: 'Snow Pants / Bibs', category: 'Clothing', weightKg: 1.1, quantity: 1),
        PackingItem(id: 'ws_3', name: 'Merino Wool Thermal Layers', category: 'Clothing', weightKg: 0.7, quantity: 3),
        PackingItem(id: 'ws_4', name: 'Ski / Snowboard Goggles', category: 'Gear', weightKg: 0.3, quantity: 1),
        PackingItem(id: 'ws_5', name: 'Waterproof Winter Gloves & Liners', category: 'Clothing', weightKg: 0.35, quantity: 1),
        PackingItem(id: 'ws_6', name: 'Wool Beanie & Neck Gaiter', category: 'Clothing', weightKg: 0.2, quantity: 2),
        PackingItem(id: 'ws_7', name: 'Thermal Wool Socks (x4)', category: 'Clothing', weightKg: 0.4, quantity: 4),
        PackingItem(id: 'ws_8', name: 'Winter Snow Boots', category: 'Clothing', weightKg: 1.6, quantity: 1),
        PackingItem(id: 'ws_9', name: 'Moisturizing Cream & SPF Lip Balm', category: 'Toiletries', weightKg: 0.2, quantity: 1),
        PackingItem(id: 'ws_10', name: 'Chemical Hand & Toe Warmers', category: 'Gear', weightKg: 0.3, quantity: 4),
      ],
    ),
  ];
}

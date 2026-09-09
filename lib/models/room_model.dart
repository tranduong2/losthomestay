enum RoomStatus { available, occupied, maintenance }

enum CleaningStatus { clean, dirty, cleaning }

class RoomModel {
  final String id;
  final String name;
  final String description;
  final double pricePerNight;
  final String imageUrl;
  final int maxGuests;
  final List<String> amenities;
  RoomStatus status;
  CleaningStatus cleaningStatus;
  final double rating;

  // Demo categories shared by the search form and the room catalog.
  String get category => maxGuests >= 8
      ? 'Suite'
      : maxGuests >= 5
          ? 'VIP'
          : maxGuests >= 3
              ? 'Superior'
              : 'Deluxe';

  RoomModel({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerNight,
    required this.imageUrl,
    required this.maxGuests,
    required this.amenities,
    this.status = RoomStatus.available,
    this.cleaningStatus = CleaningStatus.clean,
    this.rating = 4.8,
  });
}


import 'dart:convert';
import 'dart:io';
import '../lib/data/mock_data.dart';

// Export only public catalog data; demo passwords and users never leave the app.
void main() {
  final data = {
    'rooms': {
      for (final r in MockData.rooms)
        r.id: {
          'name': r.name,
          'description': r.description,
          'pricePerNight': r.pricePerNight,
          'imageUrl': r.imageUrl,
          'maxGuests': r.maxGuests,
          'amenities': r.amenities,
          'status': r.status.name,
          'cleaningStatus': r.cleaningStatus.name,
          'rating': r.rating,
        },
    },
    'discounts': {
      for (final d in MockData.discounts)
        d.code: {
          'code': d.code,
          'percent': d.percent,
          'expiry': d.expiry.toUtc().toIso8601String(),
          'active': d.active,
        },
    },
  };
  File('firebase/seed.json')
    ..parent.createSync(recursive: true)
    ..writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(data)}\n');
  stdout.writeln('Exported ${MockData.rooms.length} rooms and ${MockData.discounts.length} discounts.');
}

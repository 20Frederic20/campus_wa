import 'package:campus_wa/domain/models/classroom.dart';
import 'package:campus_wa/domain/models/university.dart';
import 'package:latlong2/latlong.dart';

double _toDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

extension LocationExtension on University {
  LatLng get coords => LatLng(_toDouble(lat), _toDouble(lng));
}

extension ClassroomLocationExtension on Classroom {
  LatLng get coords => LatLng(_toDouble(lat), _toDouble(lng));
}
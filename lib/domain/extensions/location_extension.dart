import 'package:campus_wa/domain/models/classroom.dart';
import 'package:campus_wa/domain/models/university.dart';
import 'package:latlong2/latlong.dart';

extension LocationExtension on University {
  LatLng get coords => LatLng(lat, lng);
}

extension ClassroomLocationExtension on Classroom {
  LatLng get coords => LatLng(lat, lng);
}
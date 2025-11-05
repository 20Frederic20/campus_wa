import 'package:campus_wa/domain/entities/searchable_item.dart';
import 'package:campus_wa/domain/models/university.dart';

class UniversityAdapter implements SearchableItem {
  UniversityAdapter(this._university);
  final University _university;

  @override
  String get id => _university.id;

  @override
  String get name => _university.name;

  @override
  String get slug => _university.slug;

  @override
  String get type => 'university';

  University get university => _university;
}

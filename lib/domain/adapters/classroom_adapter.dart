import 'package:campus_wa/domain/entities/searchable_item.dart';
import 'package:campus_wa/domain/models/classroom.dart';

class ClassroomAdapter implements SearchableItem {
  ClassroomAdapter(this._classroom);
  final Classroom _classroom;

  @override
  String get id => _classroom.id;

  @override
  String get name => _classroom.name;

  @override
  String get slug => _classroom.slug;

  @override
  String get type => 'classroom';

  Classroom get classroom => _classroom;
}

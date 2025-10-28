class Classroom {
  final String id;
  final String nom;
  final String slug;
  final double lng;
  final double lat ;
  final List<String>? imageUrls;

  Classroom({
    required this.id,
    required this.nom,
    required this.slug,
    required this.lng,
    required this.lat,
    this.imageUrls,
  });
}
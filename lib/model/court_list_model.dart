class CourtListModel {
  final String name;
  final String vicinity;

  CourtListModel({
    required this.name,
    required this.vicinity,
  });

  factory CourtListModel.fromJson(Map<String, dynamic> j) {
    return CourtListModel(
      name: j['name'] as String? ?? 'Unknown Court',
      vicinity: j['vicinity'] as String? ?? 'No address available', 
    );
  }
}
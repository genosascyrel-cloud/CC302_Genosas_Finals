class Place {
  final String id;
  final String name;
  final String description;
  final String category;
  final String? imageUrl;
  final String? wikiUrl;
  final bool isCustom;
  final String note;

  const Place({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.imageUrl,
    this.wikiUrl,
    this.isCustom = false,
    this.note = '',
  });

  /// Larger version of the Wikipedia thumbnail for the detail screen.
  String? get largeImageUrl =>
      imageUrl?.replaceFirst(RegExp(r'/\d+px-'), '/960px-');

  factory Place.fromWikiSummary(Map<String, dynamic> json, String category) {
    final thumb = json['thumbnail'] as Map?;
    final urls = json['content_urls'] as Map?;
    final desktop = urls?['desktop'] as Map?;
    return Place(
      id: (json['title'] ?? '') as String,
      name: (json['title'] ?? 'Unknown') as String,
      description: (json['extract'] ?? 'No description available.') as String,
      category: category,
      imageUrl: thumb?['source'] as String?,
      wikiUrl: desktop?['page'] as String?,
    );
  }

  factory Place.fromJson(Map<String, dynamic> j) => Place(
        id: j['id'] as String,
        name: j['name'] as String,
        description: j['description'] as String,
        category: j['category'] as String,
        imageUrl: j['imageUrl'] as String?,
        wikiUrl: j['wikiUrl'] as String?,
        isCustom: (j['isCustom'] ?? false) as bool,
        note: (j['note'] ?? '') as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'category': category,
        'imageUrl': imageUrl,
        'wikiUrl': wikiUrl,
        'isCustom': isCustom,
        'note': note,
      };

  Place copyWith({String? note}) => Place(
        id: id,
        name: name,
        description: description,
        category: category,
        imageUrl: imageUrl,
        wikiUrl: wikiUrl,
        isCustom: isCustom,
        note: note ?? this.note,
      );
}

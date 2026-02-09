class Hymn {
  final int id;
  final String number;
  final String title;
  final String page;
  final List<String> content;
  final String? translation;
  final String? category;
  final bool isFavorite; // <--- ADDED FIELD

  Hymn({
    required this.id,
    required this.number,
    required this.title,
    required this.page,
    required this.content,
    this.translation,
    this.category,
    this.isFavorite = false, // <--- INITIALIZED FIELD
  });

  // --- 1. ADD copyWith METHOD (CRITICAL FOR STATE MANAGEMENT) ---
  Hymn copyWith({
    int? id,
    String? number,
    String? title,
    String? page,
    List<String>? content,
    String? translation,
    String? category,
    bool? isFavorite,
  }) {
    return Hymn(
      id: id ?? this.id,
      number: number ?? this.number,
      title: title ?? this.title,
      page: page ?? this.page,
      content: content ?? this.content,
      translation: translation ?? this.translation,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  // --- 2. UPDATED toMap (For future persistence, e.g., database/json saving) ---
  Map<String, dynamic> toMap() => {
        'id': id,
        'number': number,
        'title': title,
        'page': page,
        'content': content,
        'translation': translation,
        'category': category,
        'isFavorite': isFavorite ? 1 : 0, // Store as 1 or 0 in map/database
      };

  // --- 3. UPDATED fromMap (To read favorite status from data source) ---
  factory Hymn.fromMap(Map<String, dynamic> map) {
    // Helper to safely parse isFavorite
    final bool parsedIsFavorite = map['isFavorite'] == 1 || map['isFavorite'] == true;

    return Hymn(
        id: map['id'] is int ? map['id'] : int.tryParse(map['id']?.toString() ?? '0') ?? 0,
        number: map['number']?.toString() ?? '',
        title: map['title']?.toString() ?? '',
        page: (map['pages'] is List ? map['pages']?.first : map['page'])?.toString() ?? '',
        content: map['content'] is List
            ? List<String>.from(map['content'] ?? [])
            : (map['content']?.toString() ?? '').split('\n\n'),
        translation: map['translation']?.toString() ?? map['subtitle']?.toString(),
        category: map['category']?.toString(),
        isFavorite: parsedIsFavorite, // <--- ADDED INITIALIZATION
    );
  }
}
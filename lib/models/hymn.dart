class Hymn {
  final int id;
  final String number;
  final String title;
  final String page;
  final List<String> content;
  final String? translation;
  final String? category;
  final String? reference;
  final bool isFavorite;

  Hymn({
    required this.id,
    required this.number,
    required this.title,
    required this.page,
    required this.content,
    this.translation,
    this.category,
    this.reference,
    this.isFavorite = false,
  });

  Hymn copyWith({
    int? id,
    String? number,
    String? title,
    String? page,
    List<String>? content,
    String? translation,
    String? category,
    String? reference,
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
      reference: reference ?? this.reference,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'number': number,
        'title': title,
        'page': page,
        'content': content,
        'translation': translation,
        'category': category,
        'reference': reference,
        'isFavorite': isFavorite ? 1 : 0,
      };

  factory Hymn.fromMap(Map<String, dynamic> map) {
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
      reference: map['reference']?.toString(),
      isFavorite: parsedIsFavorite,
    );
  }
}

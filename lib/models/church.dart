class Church {
  final String id;
  final String name;
  final String townCity;
  final String presbytery;
  final String locationDescription;
  final String googleMapsUrl;
  final String minister;
  final String contactPhone;
  final String activities; // raw multi-line string
  final String uploadedBy; // congregation name of uploader
  final DateTime? createdAt;

  const Church({
    required this.id,
    required this.name,
    required this.townCity,
    required this.presbytery,
    required this.locationDescription,
    required this.googleMapsUrl,
    required this.minister,
    required this.contactPhone,
    required this.activities,
    required this.uploadedBy,
    this.createdAt,
  });

  /// Parse the raw activities string into a structured list of day/time lines.
  List<Map<String, String>> get parsedActivities {
    final lines = activities
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    return lines.map((line) {
      final colonIdx = line.indexOf(':');
      if (colonIdx != -1) {
        return {
          'day': line.substring(0, colonIdx).trim(),
          'detail': line.substring(colonIdx + 1).trim(),
        };
      }
      return {'day': '', 'detail': line};
    }).toList();
  }

  /// Whether the given congregation name can edit this church record.
  bool canEdit(String? userCongregation) {
    if (userCongregation == null || userCongregation.trim().isEmpty) return false;
    return uploadedBy.trim().toLowerCase() ==
        userCongregation.trim().toLowerCase();
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'townCity': townCity,
        'presbytery': presbytery,
        'locationDescription': locationDescription,
        'googleMapsUrl': googleMapsUrl,
        'minister': minister,
        'contactPhone': contactPhone,
        'activities': activities,
        'uploadedBy': uploadedBy,
        'createdAt': createdAt?.toIso8601String(),
      };

  factory Church.fromMap(Map<String, dynamic> map) => Church(
        id: map['id'] as String? ?? '',
        name: map['name'] as String? ?? '',
        townCity: map['townCity'] as String? ?? '',
        presbytery: map['presbytery'] as String? ?? '',
        locationDescription: map['locationDescription'] as String? ?? '',
        googleMapsUrl: map['googleMapsUrl'] as String? ?? '',
        minister: map['minister'] as String? ?? '',
        contactPhone: map['contactPhone'] as String? ?? '',
        activities: map['activities'] as String? ?? '',
        uploadedBy: map['uploadedBy'] as String? ?? '',
        createdAt: map['createdAt'] != null
            ? DateTime.tryParse(map['createdAt'] as String)
            : null,
      );
}

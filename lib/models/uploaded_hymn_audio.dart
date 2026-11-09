class UploadedHymnAudio {
  final String id;
  final String hymnNumber;
  final String hymnTitle;
  final String filePath;
  final String fileName;
  final String audioType;
  final String? uploaderName;
  final String? notes;
  final int fileSizeBytes;
  final DateTime uploadedAt;

  UploadedHymnAudio({
    required this.id,
    required this.hymnNumber,
    required this.hymnTitle,
    required this.filePath,
    required this.fileName,
    required this.audioType,
    this.uploaderName,
    this.notes,
    required this.fileSizeBytes,
    required this.uploadedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'hymn_number': hymnNumber,
        'hymn_title': hymnTitle,
        'file_path': filePath,
        'file_name': fileName,
        'audio_type': audioType,
        'uploader_name': uploaderName,
        'notes': notes,
        'file_size': fileSizeBytes,
        'uploaded_at': uploadedAt.toIso8601String(),
      };

  factory UploadedHymnAudio.fromMap(Map<String, dynamic> map) {
    return UploadedHymnAudio(
      id: map['id']?.toString() ?? '',
      hymnNumber: map['hymn_number']?.toString() ?? map['hymnNumber']?.toString() ?? '',
      hymnTitle: map['hymn_title']?.toString() ?? map['hymnTitle']?.toString() ?? '',
      filePath: map['file_path']?.toString() ?? map['filePath']?.toString() ?? '',
      fileName: map['file_name']?.toString() ?? map['fileName']?.toString() ?? '',
      audioType: map['audio_type']?.toString() ?? map['audioType']?.toString() ?? 'Keyboard / Organ Play',
      uploaderName: map['uploader_name']?.toString() ?? map['uploaderName']?.toString(),
      notes: map['notes']?.toString(),
      fileSizeBytes: (map['file_size'] is int)
          ? map['file_size'] as int
          : int.tryParse(map['file_size']?.toString() ?? '0') ?? 0,
      uploadedAt: map['uploaded_at'] != null
          ? DateTime.tryParse(map['uploaded_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

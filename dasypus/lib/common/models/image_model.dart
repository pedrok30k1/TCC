class ImageModel {
  final String id;
  final String originalName;
  final String filename;
  final String uploadPath;
  final String fileType;
  final int fileSize;
  final String uploadDate;
  final String userId;
  final String description;
  final String url;

  ImageModel({
    required this.id,
    required this.originalName,
    required this.filename,
    required this.uploadPath,
    required this.fileType,
    required this.fileSize,
    required this.uploadDate,
    required this.userId,
    required this.description,
    required this.url,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'] ?? '',
      originalName: json['original_name'] ?? '',
      filename: json['filename'] ?? '',
      uploadPath: json['upload_path'] ?? '',
      fileType: json['file_type'] ?? '',
      fileSize: json['file_size'] ?? 0,
      uploadDate: json['upload_date'] ?? '',
      userId: json['user_id'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'original_name': originalName,
      'filename': filename,
      'upload_path': uploadPath,
      'file_type': fileType,
      'file_size': fileSize,
      'upload_date': uploadDate,
      'user_id': userId,
      'description': description,
      'url': url,
    };
  }

  String get formattedFileSize {
    if (fileSize < 1024) {
      return '${fileSize} B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  String get formattedDate {
    try {
      final date = DateTime.parse(uploadDate);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return uploadDate;
    }
  }
}

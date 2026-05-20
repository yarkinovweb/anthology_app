class UploadWorkParams {
  final String creatorId;
  final String title;
  final String? description;
  final String? contentText;
  final String? filePath;
  final String? fileName;

  const UploadWorkParams({
    required this.creatorId,
    required this.title,
    this.description,
    this.contentText,
    this.filePath,
    this.fileName,
  });

  bool get hasFile => filePath != null && filePath!.isNotEmpty;
}

class ArchivoChatIa {
  String fileUri;
  String mimeType;
  String fileUrl;

  ArchivoChatIa({
    required this.fileUri,
    required this.mimeType,
    required this.fileUrl,
  });

  factory ArchivoChatIa.fromJson(Map<String, dynamic> json) {
    return ArchivoChatIa(
      fileUri: json['fileUri'],
      mimeType: json['mimeType'],
      fileUrl: json["fileUrl"],
    );
  }

  Map<String, dynamic> toJson() {
    return {'fileUri': fileUri, 'mimeType': mimeType, 'fileUrl': fileUrl};
  }
}

import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';

class MindsaveFileSaver {
  const MindsaveFileSaver._();

  static Future<String?> saveAs({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) {
    final separator = fileName.lastIndexOf('.');
    if (separator <= 0 || separator == fileName.length - 1) {
      throw ArgumentError.value(fileName, 'fileName', 'Debe incluir extensión');
    }

    final name = fileName.substring(0, separator);
    final extension = fileName.substring(separator + 1).toLowerCase();
    final fileMimeType = switch (extension) {
      'pdf' => MimeType.pdf,
      'xlsx' => MimeType.microsoftExcel,
      _ => MimeType.custom,
    };

    return FileSaver.instance.saveAs(
      name: name,
      bytes: bytes,
      fileExtension: extension,
      mimeType: fileMimeType,
      customMimeType: fileMimeType == MimeType.custom ? mimeType : null,
    );
  }
}

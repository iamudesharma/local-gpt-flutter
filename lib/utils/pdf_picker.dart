import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

Future<dynamic> pdfPicker() async {
  FilePickerResult? result = await FilePicker.platform
      .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

  if (result != null) {
    if (kIsWeb) {
      final fileBytes = result.files.first.bytes;
      print(fileBytes);
      return fileBytes!;
    } else {
      File file = File(result.files.single.path!);
      print(file.path);
      return file;
    }
  } else {}
}

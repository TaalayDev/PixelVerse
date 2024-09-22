import 'dart:io';

import 'package:dio/dio.dart';

extension FileExtensions on File {
  MultipartFile toMultipartFileSync() {
    return MultipartFile.fromFileSync(
      path,
      filename: path.split('/').last,
    );
  }

  Future<MultipartFile> toMultipartFile() {
    return MultipartFile.fromFile(
      path,
      filename: path.split('/').last,
    );
  }
}

extension FileListExtensions on List<File> {
  List<MultipartFile> toMultipartFilesSync() {
    return map((file) => file.toMultipartFileSync()).toList();
  }

  Future<List<MultipartFile>> toMultipartFiles() async {
    return Future.wait(map((file) => file.toMultipartFile()).toList());
  }
}

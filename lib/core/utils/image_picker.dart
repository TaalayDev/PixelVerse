import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart' as imp;

class ImagePicker {
  static Future<List<File>> pickImages({bool multiple = true}) async {
    final result = await imp.ImagePicker().pickMultiImage();
    return result.map((e) => File(e.path)).toList();
    /*FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: multiple,
      withData: true,
    );

    return result?.files.map((e) => File(e.path!)).toList() ?? [];*/
  }

  static Future<File?> pickImageFromCamera() async {
    final picker = imp.ImagePicker();
    final result = await picker.pickImage(source: imp.ImageSource.camera);

    return result != null ? File(result.path) : null;
  }

  static Future<File?> pickImageFromGallery() async {
    final picker = imp.ImagePicker();
    final result = await picker.pickImage(source: imp.ImageSource.gallery);

    return result != null ? File(result.path) : null;
  }

  static Future<File?> pickImage(
    BuildContext context,
    imp.ImageSource source,
  ) async {
    final file = source == imp.ImageSource.gallery
        ? await pickImageFromGallery()
        : await pickImageFromCamera();

    return file != null ? cropImage(context, file.path) : null;
  }

  static Future<File?> cropImage(
    BuildContext context,
    String path, {
    List<CropAspectRatioPreset>? presets,
    CropStyle? cropStyle,
    int? compressQuality,
    CropAspectRatio? aspectRatio,
  }) async {
    final aspectRationPresets = presets ??
        [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9,
        ];
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      compressQuality: compressQuality ?? 90,
      aspectRatio: aspectRatio,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'MedApp',
          toolbarColor: Theme.of(context).primaryColor,
          toolbarWidgetColor: Theme.of(context).colorScheme.onPrimary,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          cropStyle: cropStyle ?? CropStyle.rectangle,
          aspectRatioPresets: aspectRationPresets,
        ),
        IOSUiSettings(
          title: 'MedApp',
          cropStyle: cropStyle ?? CropStyle.rectangle,
          aspectRatioPresets: aspectRationPresets,
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );

    return croppedFile != null ? File(croppedFile.path) : null;
  }
}

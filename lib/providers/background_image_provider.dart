import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'background_image_provider.freezed.dart';
part 'background_image_provider.g.dart';

@freezed
class BackgroundImageState with _$BackgroundImageState {
  const BackgroundImageState._();
  const factory BackgroundImageState({
    final Uint8List? image,
    @Default(0.3) final double opacity,
  }) = _BackgroundImageState;
}

@riverpod
class BackgroundImage extends _$BackgroundImage {
  @override
  BackgroundImageState build() => const BackgroundImageState(
        image: null,
        opacity: 0.3,
      );

  void update(BackgroundImageState Function(BackgroundImageState state) fn) {
    state = fn(state);
  }
}

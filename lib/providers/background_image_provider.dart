import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../pixel/pixel_draw_state.dart';

part 'background_image_provider.g.dart';

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

  void setOpacity(double opacity) {
    state = state.copyWith(opacity: opacity.clamp(0.0, 1.0));
  }

  void setScale(double scale) {
    state = state.copyWith(scale: scale.clamp(0.1, 5.0));
  }

  void setOffset(Offset offset) {
    state = state.copyWith(offset: offset);
  }

  void resetTransform() {
    state = state.copyWith(
      scale: 1.0,
      offset: Offset.zero,
    );
  }

  void fitToCanvas(double canvasWidth, double canvasHeight) {
    if (state.image != null) {
      // This would require getting image dimensions - implement based on your image handling
      // For now, just reset to fit
      state = state.copyWith(
        scale: 1.0,
        offset: Offset.zero,
      );
    }
  }
}

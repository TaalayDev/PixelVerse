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
}

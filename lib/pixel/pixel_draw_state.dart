import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'pixel_point.dart';
import 'tools.dart';
import '../data/models/animation_frame_model.dart';
import '../data/models/layer.dart';
import '../data/models/selection_model.dart';

part 'pixel_draw_state.freezed.dart';

@freezed
class PixelDrawState with _$PixelDrawState {
  const PixelDrawState._();

  const factory PixelDrawState({
    required final int width,
    required final int height,
    required final List<AnimationStateModel> animationStates,
    required final List<AnimationFrame> frames,
    @Default(0) final int currentAnimationStateIndex,
    @Default(0) final int currentFrameIndex,
    @Default(0) final int currentLayerIndex,
    required final Color currentColor,
    required final PixelTool currentTool,
    required final MirrorAxis mirrorAxis,
    final List<PixelPoint<int>>? selectionRect,
    @Default(false) final bool canUndo,
    @Default(false) final bool canRedo,
    @Default(PixelModifier.none) final PixelModifier currentModifier,
  }) = _PixelDrawState;

  // Computed properties
  AnimationStateModel get currentAnimationState => animationStates[currentAnimationStateIndex];
  List<AnimationFrame> get currentFrames => frames.where((frame) => frame.stateId == currentAnimationState.id).toList();
  AnimationFrame get currentFrame => currentFrames[currentFrameIndex];
  Layer get currentLayer => currentFrame.layers[currentLayerIndex];
  List<Layer> get layers => currentFrame.layers;

  List<Uint32List> get pixels => currentFrame.layers.fold(
        [],
        (List<Uint32List> acc, layer) {
          acc.add(layer.processedPixels);
          return acc;
        },
      );
}

@freezed
class BackgroundImageState with _$BackgroundImageState {
  const BackgroundImageState._();

  const factory BackgroundImageState({
    final Uint8List? image,
    @Default(0.3) final double opacity,
    @Default(1.0) final double scale,
    @Default(Offset.zero) final Offset offset,
  }) = _BackgroundImageState;
}

sealed class PixelDrawEvent {
  const PixelDrawEvent();
}

class ClosePenPathEvent extends PixelDrawEvent {
  const ClosePenPathEvent();
}

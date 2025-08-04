import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';

part 'brightness_effect.dart';
part 'contrast_effect.dart';
part 'emboss_effect.dart';
part 'grayscale_effect.dart';
part 'invert_effect.dart';
part 'noise_effect.dart';
part 'pixelate_effect.dart';
part 'sepia_effect.dart';
part 'sharpen_effect.dart';
part 'threshold_effect.dart';
part 'vignette_effect.dart';
part 'blur_effect.dart';
part 'color_balance_effect.dart';
part 'dithering_effect.dart';
part 'outline_effect.dart';
part 'palette_reduction_effect.dart';
part 'watercolor_effect.dart';
part 'halftone_effect.dart';
part 'glow_effect.dart';
part 'oil_paint_effect.dart';
part 'gradient_effect.dart';
part 'fire_effect.dart';
part 'wood_effect.dart';
part 'rain_effect.dart';
part 'crystal_effect.dart';

enum EffectType {
  brightness,
  contrast,
  invert,
  grayscale,
  sepia,
  threshold,
  pixelate,
  blur,
  sharpen,
  emboss,
  vignette,
  noise,
  colorBalance,
  dithering,
  outline,
  paletteReduction,
  watercolor,
  halftone,
  glow,
  oilPaint,
  gradient,
  fire,
  wood,
  rain,
  crystal,
}

/// Base abstract class for all effects
abstract class Effect {
  final EffectType type;
  final Map<String, dynamic> parameters;

  const Effect(this.type, this.parameters);

  /// Apply the effect to the given pixels
  Uint32List apply(Uint32List pixels, int width, int height);

  /// Get the default parameters for this effect
  Map<String, dynamic> getDefaultParameters();
  Map<String, dynamic> getMetadata();

  String get name => type.name;

  @override
  String toString() => '$name: $parameters';
}

/// Utility class to manage effects
class EffectsManager {
  /// Apply a single effect to pixels
  static Uint32List applyEffect(
    Uint32List pixels,
    int width,
    int height,
    Effect effect,
  ) {
    return effect.apply(pixels, width, height);
  }

  /// Apply multiple effects in sequence
  static Uint32List applyMultipleEffects(
    Uint32List pixels,
    int width,
    int height,
    List<Effect> effects,
  ) {
    Uint32List result = Uint32List.fromList(pixels);

    for (final effect in effects) {
      result = effect.apply(result, width, height);
    }

    return result;
  }

  /// Create an effect instance based on type
  static Effect createEffect(EffectType type, [Map<String, dynamic>? params]) {
    switch (type) {
      case EffectType.brightness:
        return BrightnessEffect(params);
      case EffectType.contrast:
        return ContrastEffect(params);
      case EffectType.invert:
        return InvertEffect(params);
      case EffectType.grayscale:
        return GrayscaleEffect(params);
      case EffectType.sepia:
        return SepiaEffect(params);
      case EffectType.threshold:
        return ThresholdEffect(params);
      case EffectType.pixelate:
        return PixelateEffect(params);
      case EffectType.blur:
        return BlurEffect(params);
      case EffectType.sharpen:
        return SharpenEffect(params);
      case EffectType.emboss:
        return EmbossEffect(params);
      case EffectType.vignette:
        return VignetteEffect(params);
      case EffectType.noise:
        return NoiseEffect(params);
      case EffectType.colorBalance:
        return ColorBalanceEffect(params);
      case EffectType.dithering:
        return DitheringEffect(params);
      case EffectType.outline:
        return OutlineEffect(params);
      case EffectType.paletteReduction:
        return PaletteReductionEffect(params);
      case EffectType.watercolor:
        return WatercolorEffect(params);
      case EffectType.halftone:
        return HalftoneEffect(params);
      case EffectType.glow:
        return GlowEffect(params);
      case EffectType.oilPaint:
        return OilPaintEffect(params);
      case EffectType.gradient:
        return GradientEffect(params);
      case EffectType.fire:
        return FireEffect(params);
      case EffectType.wood:
        return WoodEffect(params);
      case EffectType.rain:
        return RainEffect(params);
      case EffectType.crystal:
        return CrystalEffect(params);
    }
  }

  static Effect? effectFromJson(Map<String, dynamic> json) {
    try {
      final type = EffectType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => EffectType.brightness,
      );
      return createEffect(type, Map<String, dynamic>.from(json['parameters']));
    } catch (e) {
      return null;
    }
  }
}

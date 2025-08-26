part of 'effects.dart';

/// Effect that creates smooth rotation animation around a center point
class RotateEffect extends Effect {
  RotateEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.rotate,
          parameters ??
              const {
                'speed': 0.5, // Rotation speed (0-1)
                'direction': 1, // 1 = clockwise, -1 = counterclockwise
                'centerX': 0.5, // Rotation center X (0-1)
                'centerY': 0.5, // Rotation center Y (0-1)
                'interpolation': 1, // 0 = nearest, 1 = bilinear
                'backgroundMode': 0, // 0 = transparent, 1 = repeat, 2 = mirror
                'zoom': 1.0, // Scale factor during rotation (0.5-2.0)
                'time': 0.0, // Animation time parameter (0-1)
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'speed': 0.5,
      'direction': 1,
      'centerX': 0.5,
      'centerY': 0.5,
      'interpolation': 1,
      'backgroundMode': 0,
      'zoom': 1.0,
      'time': 0.0,
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'speed': {
        'label': 'Rotation Speed',
        'description': 'How fast the image rotates.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'direction': {
        'label': 'Direction',
        'description': 'Rotation direction.',
        'type': 'select',
        'options': {
          1: 'Clockwise',
          -1: 'Counter-clockwise',
        },
      },
      'centerX': {
        'label': 'Center X',
        'description': 'Horizontal center of rotation (0 = left, 1 = right).',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'centerY': {
        'label': 'Center Y',
        'description': 'Vertical center of rotation (0 = top, 1 = bottom).',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'interpolation': {
        'label': 'Interpolation',
        'description': 'Pixel sampling method for smoother rotation.',
        'type': 'select',
        'options': {
          0: 'Nearest (Pixelated)',
          1: 'Bilinear (Smooth)',
        },
      },
      'backgroundMode': {
        'label': 'Background Mode',
        'description': 'How to handle areas outside the original image.',
        'type': 'select',
        'options': {
          0: 'Transparent',
          1: 'Repeat Pattern',
          2: 'Mirror',
        },
      },
      'zoom': {
        'label': 'Zoom Level',
        'description': 'Scale factor applied during rotation.',
        'type': 'slider',
        'min': 0.5,
        'max': 2.0,
        'divisions': 100,
      },
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final speed = parameters['speed'] as double;
    final direction = parameters['direction'] as int;
    final centerX = parameters['centerX'] as double;
    final centerY = parameters['centerY'] as double;
    final interpolation = parameters['interpolation'] as int;
    final backgroundMode = parameters['backgroundMode'] as int;
    final zoom = parameters['zoom'] as double;
    final time = parameters['time'] as double;

    // Calculate current rotation angle (positive for clockwise when direction=1)
    final angle = time * speed * direction * 2 * pi;

    // Calculate rotation center in pixels
    final rotCenterX = centerX * width;
    final rotCenterY = centerY * height;

    return PixelUtils.applyRotation(
      pixels,
      width,
      height,
      angle,
      rotCenterX,
      rotCenterY,
      zoom,
      interpolation,
      backgroundMode,
    );
  }
}

part of 'effects.dart';

/// Effect that creates smooth floating/bobbing animation with vertical movement
class FloatEffect extends Effect {
  FloatEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.float,
          parameters ??
              const {
                'amplitude': 0.3, // Floating range (0-1)
                'speed': 0.5, // Floating speed (0-1)
                'direction': 0, // 0=vertical, 1=horizontal, 2=diagonal, 3=circular
                'waveType': 0, // 0=sine, 1=bounce, 2=elastic, 3=pendulum
                'phase': 0.0, // Starting phase offset (0-1)
                'dampening': 0.0, // Motion dampening over time (0-1)
                'secondaryMotion': 0.2, // Secondary motion intensity (0-1)
                'backgroundMode': 0, // 0=transparent, 1=stretch, 2=repeat
                'time': 0.0, // Animation time parameter (0-1)
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'amplitude': 0.3,
      'speed': 0.5,
      'direction': 0,
      'waveType': 0,
      'phase': 0.0,
      'dampening': 0.0,
      'secondaryMotion': 0.2,
      'backgroundMode': 0,
      'time': 0.0,
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'amplitude': {
        'label': 'Float Amplitude',
        'description': 'How far the image moves during floating motion.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'speed': {
        'label': 'Float Speed',
        'description': 'How fast the floating motion occurs.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'direction': {
        'label': 'Float Direction',
        'description': 'Direction of the floating motion.',
        'type': 'select',
        'options': {
          0: 'Vertical (Up/Down)',
          1: 'Horizontal (Left/Right)',
          2: 'Diagonal',
          3: 'Circular',
        },
      },
      'waveType': {
        'label': 'Motion Type',
        'description': 'Type of floating motion pattern.',
        'type': 'select',
        'options': {
          0: 'Smooth (Sine)',
          1: 'Bouncy',
          2: 'Elastic',
          3: 'Pendulum',
        },
      },
      'phase': {
        'label': 'Phase Offset',
        'description': 'Starting position in the animation cycle.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'dampening': {
        'label': 'Dampening',
        'description': 'Gradually reduces motion over time for settling effect.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'secondaryMotion': {
        'label': 'Secondary Motion',
        'description': 'Adds subtle secondary movement for more natural motion.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'backgroundMode': {
        'label': 'Background Mode',
        'description': 'How to handle empty areas created by movement.',
        'type': 'select',
        'options': {
          0: 'Transparent',
          1: 'Stretch Edges',
          2: 'Repeat Pattern',
        },
      },
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final amplitude = parameters['amplitude'] as double;
    final speed = parameters['speed'] as double;
    final direction = parameters['direction'] as int;
    final waveType = parameters['waveType'] as int;
    final phase = parameters['phase'] as double;
    final dampening = parameters['dampening'] as double;
    final secondaryMotion = parameters['secondaryMotion'] as double;
    final backgroundMode = parameters['backgroundMode'] as int;
    final time = parameters['time'] as double;

    final result = Uint32List(pixels.length);

    // Calculate animation time with phase offset
    final animTime = (time * speed * 4 + phase * 2 * pi);

    // Calculate dampening factor (exponential decay)
    final dampenFactor = dampening > 0 ? exp(-dampening * time * 5) : 1.0;

    // Calculate primary motion based on wave type
    final primaryMotion = _calculateMotion(animTime, waveType) * dampenFactor;

    // Calculate secondary motion (different frequency for natural feel)
    final secondaryTime = animTime * 1.7 + pi / 3; // Different phase and frequency
    final secondaryValue = sin(secondaryTime) * secondaryMotion * 0.3 * dampenFactor;

    // Calculate movement offsets based on direction
    final (offsetX, offsetY) = _calculateOffsets(direction, primaryMotion, secondaryValue, amplitude, width, height);

    // Apply the floating transformation
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final destIndex = y * width + x;

        // Calculate source position (reverse the movement)
        final sourceX = x - offsetX;
        final sourceY = y - offsetY;

        // Sample pixel based on background mode
        result[destIndex] = _samplePixel(pixels, width, height, sourceX, sourceY, backgroundMode);
      }
    }

    return result;
  }

  /// Calculate motion value based on wave type
  double _calculateMotion(double time, int waveType) {
    switch (waveType) {
      case 0: // Smooth sine wave
        return sin(time);

      case 1: // Bouncy motion
        final t = (time / (2 * pi)) % 1.0;
        if (t < 0.5) {
          // Bounce up
          return sin(t * pi);
        } else {
          // Bounce down with gravity effect
          final bounceTime = (t - 0.5) * 2;
          return sin(bounceTime * pi) * (1 - bounceTime * 0.3);
        }

      case 2: // Elastic motion
        final t = (time / (2 * pi)) % 1.0;
        if (t < 0.8) {
          // Main motion
          return sin(t * pi / 0.8);
        } else {
          // Elastic overshoot
          final elasticTime = (t - 0.8) / 0.2;
          return sin(elasticTime * pi * 3) * (1 - elasticTime) * 0.3;
        }

      case 3: // Pendulum motion (ease in/out)
        return sin(time) * (0.5 + 0.5 * cos(time * 0.5));

      default:
        return sin(time);
    }
  }

  /// Calculate X and Y offsets based on direction and motion values
  (double, double) _calculateOffsets(
      int direction, double primaryMotion, double secondaryValue, double amplitude, int width, int height) {
    final maxMovement = amplitude * min(width, height) * 0.2;

    switch (direction) {
      case 0: // Vertical
        return (
          secondaryValue * maxMovement * 0.5, // Slight horizontal drift
          primaryMotion * maxMovement
        );

      case 1: // Horizontal
        return (
          primaryMotion * maxMovement,
          secondaryValue * maxMovement * 0.5 // Slight vertical drift
        );

      case 2: // Diagonal
        final diagonalMotion = primaryMotion * maxMovement * 0.707; // sqrt(2)/2
        return (
          diagonalMotion + secondaryValue * maxMovement * 0.3,
          diagonalMotion + secondaryValue * maxMovement * 0.2
        );

      case 3: // Circular
        final radius = maxMovement;
        final angle = primaryMotion; // Use motion value as angle
        return (
          cos(angle) * radius + secondaryValue * maxMovement * 0.2,
          sin(angle) * radius + secondaryValue * maxMovement * 0.1
        );

      default:
        return (0.0, primaryMotion * maxMovement);
    }
  }

  /// Sample pixel with different background handling modes
  int _samplePixel(Uint32List pixels, int width, int height, double x, double y, int backgroundMode) {
    final intX = x.round();
    final intY = y.round();

    // Check if we're within bounds
    if (intX >= 0 && intX < width && intY >= 0 && intY < height) {
      final index = intY * width + intX;
      return index < pixels.length ? pixels[index] : 0;
    }

    // Handle out-of-bounds based on background mode
    switch (backgroundMode) {
      case 0: // Transparent
        return 0;

      case 1: // Stretch edges
        final clampedX = intX.clamp(0, width - 1);
        final clampedY = intY.clamp(0, height - 1);
        final index = clampedY * width + clampedX;
        return index < pixels.length ? pixels[index] : 0;

      case 2: // Repeat pattern
        final wrappedX = intX % width;
        final wrappedY = intY % height;
        final safeX = wrappedX < 0 ? wrappedX + width : wrappedX;
        final safeY = wrappedY < 0 ? wrappedY + height : wrappedY;
        final index = safeY * width + safeX;
        return index < pixels.length ? pixels[index] : 0;

      default:
        return 0;
    }
  }
}

/// Lightweight floating effect optimized for performance
class SimpleFloatEffect extends Effect {
  SimpleFloatEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.simpleFloat,
          parameters ??
              const {
                'amplitude': 0.2, // Floating range (0-1)
                'speed': 0.4, // Floating speed (0-1)
                'verticalOnly': true, // Only vertical movement for simplicity
                'smoothness': 0.8, // How smooth the motion is (0-1)
                'time': 0.0, // Animation time parameter (0-1)
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'amplitude': 0.2,
      'speed': 0.4,
      'verticalOnly': true,
      'smoothness': 0.8,
      'time': 0.0,
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'amplitude': {
        'label': 'Float Distance',
        'description': 'How far the image floats up and down.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'speed': {
        'label': 'Float Speed',
        'description': 'Speed of the floating motion.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'verticalOnly': {
        'label': 'Vertical Only',
        'description': 'Restricts movement to vertical direction only.',
        'type': 'bool',
      },
      'smoothness': {
        'label': 'Motion Smoothness',
        'description': 'How smooth and gentle the floating motion is.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final amplitude = parameters['amplitude'] as double;
    final speed = parameters['speed'] as double;
    final verticalOnly = parameters['verticalOnly'] as bool;
    final smoothness = parameters['smoothness'] as double;
    final time = parameters['time'] as double;

    final result = Uint32List(pixels.length);

    // Calculate smooth floating motion
    final animTime = time * speed * 3;
    final smoothedMotion = sin(animTime) * smoothness + sin(animTime * 0.5) * (1 - smoothness);

    // Calculate movement
    final maxMovement = amplitude * height * 0.15;
    final offsetY = smoothedMotion * maxMovement;
    final offsetX = verticalOnly ? 0.0 : smoothedMotion * maxMovement * 0.3;

    // Simple pixel shifting
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final destIndex = y * width + x;

        final sourceX = (x - offsetX).round();
        final sourceY = (y - offsetY).round();

        if (sourceX >= 0 && sourceX < width && sourceY >= 0 && sourceY < height) {
          final sourceIndex = sourceY * width + sourceX;
          result[destIndex] = pixels[sourceIndex];
        } else {
          result[destIndex] = 0; // Transparent
        }
      }
    }

    return result;
  }
}

/// Advanced floating effect with physics simulation
class PhysicsFloatEffect extends Effect {
  PhysicsFloatEffect([Map<String, dynamic>? parameters])
      : super(
          EffectType.physicsFloat,
          parameters ??
              const {
                'buoyancy': 0.6, // Upward force strength (0-1)
                'gravity': 0.3, // Downward force strength (0-1)
                'airResistance': 0.4, // Drag coefficient (0-1)
                'turbulence': 0.2, // Random air currents (0-1)
                'mass': 0.5, // Object mass affects motion (0-1)
                'windX': 0.0, // Horizontal wind force (-1 to 1)
                'windY': 0.0, // Vertical wind force (-1 to 1)
                'time': 0.0, // Animation time parameter (0-1)
              },
        );

  @override
  Map<String, dynamic> getDefaultParameters() {
    return {
      'buoyancy': 0.6,
      'gravity': 0.3,
      'airResistance': 0.4,
      'turbulence': 0.2,
      'mass': 0.5,
      'windX': 0.0,
      'windY': 0.0,
      'time': 0.0,
    };
  }

  @override
  Map<String, dynamic> getMetadata() {
    return {
      'buoyancy': {
        'label': 'Buoyancy Force',
        'description': 'Upward floating force (like being underwater).',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'gravity': {
        'label': 'Gravity',
        'description': 'Downward gravitational force.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'airResistance': {
        'label': 'Air Resistance',
        'description': 'Drag force that slows down movement.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'turbulence': {
        'label': 'Air Turbulence',
        'description': 'Random air currents for natural movement.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'mass': {
        'label': 'Object Mass',
        'description': 'Heavier objects move more slowly.',
        'type': 'slider',
        'min': 0.0,
        'max': 1.0,
        'divisions': 100,
      },
      'windX': {
        'label': 'Horizontal Wind',
        'description': 'Left/right wind force.',
        'type': 'slider',
        'min': -1.0,
        'max': 1.0,
        'divisions': 100,
      },
      'windY': {
        'label': 'Vertical Wind',
        'description': 'Up/down wind force.',
        'type': 'slider',
        'min': -1.0,
        'max': 1.0,
        'divisions': 100,
      },
    };
  }

  @override
  Uint32List apply(Uint32List pixels, int width, int height) {
    final buoyancy = parameters['buoyancy'] as double;
    final gravity = parameters['gravity'] as double;
    final airResistance = parameters['airResistance'] as double;
    final turbulence = parameters['turbulence'] as double;
    final mass = parameters['mass'] as double;
    final windX = parameters['windX'] as double;
    final windY = parameters['windY'] as double;
    final time = parameters['time'] as double;

    final result = Uint32List(pixels.length);

    // Physics simulation
    final dt = 0.016; // ~60fps time step
    final massEffect = 1.0 / (mass + 0.1); // Prevent division by zero

    // Calculate forces
    final buoyancyForce = buoyancy * massEffect;
    final gravityForce = gravity * (mass + 0.5);
    final turbulenceX = sin(time * 13.7) * cos(time * 8.3) * turbulence;
    final turbulenceY = cos(time * 11.2) * sin(time * 6.1) * turbulence;

    // Net forces
    final netForceX = windX + turbulenceX;
    final netForceY = buoyancyForce - gravityForce + windY + turbulenceY;

    // Calculate position based on integrated motion
    final positionX = sin(time * 2 + netForceX) * width * 0.1;
    final positionY = (sin(time * 1.5) * buoyancyForce - cos(time * 2) * gravityForce) * height * 0.1;

    // Apply air resistance (dampening)
    final dampedX = positionX * (1.0 - airResistance);
    final dampedY = positionY * (1.0 - airResistance);

    // Apply transformation
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final destIndex = y * width + x;

        final sourceX = (x - dampedX).round();
        final sourceY = (y - dampedY).round();

        if (sourceX >= 0 && sourceX < width && sourceY >= 0 && sourceY < height) {
          final sourceIndex = sourceY * width + sourceX;
          result[destIndex] = pixels[sourceIndex];
        } else {
          result[destIndex] = 0;
        }
      }
    }

    return result;
  }
}

import "dart:typed_data";
import "lzw.dart" as lzw;

const int maxColorBits = 8;
const int maxColors = 1 << maxColorBits;

/// Creates a GIF from per-pixel rgba data, with alpha channel support.
/// Returns a list of bytes. Throws an exception if the image has too many colors.
Uint8List makeGif(int width, int height, List<int> rgba) {
  final b = GifBuffer(width, height)..add(rgba);
  return b.build(1);
}

/// An incomplete GIF, possibly animated, with transparency support.
class GifBuffer {
  final int width;
  final int height;
  final _colors = _ColorTableBuilder();
  final _frames = <Uint8List>[];

  GifBuffer(this.width, this.height);

  /// Adds a frame to the animation. The pixels are specified as rgba data.
  /// Transparent pixels (alpha < 128) will be marked as transparent in the GIF.
  void add(List<int> rgba) {
    _frames.add(_colors.indexImage(width, height, rgba));
  }

  /// Returns the bytes of the GIF. If more than one frame has been added, it will be animated.
  Uint8List build(int framesPerSecond) {
    final colors = _colors.build();
    int delay = 100 ~/ framesPerSecond;
    if (delay < 6) {
      delay = 6;
    }

    final bytes = <List<int>>[]
      ..add(_header(width, height, colors.bits))
      ..add(colors.table);

    // Determine if we have a transparent color
    final transparentIndex = colors.transparentIndex;

    if (_frames.length <= 1) {
      // not animated
      if (_frames.length == 1) {
        bytes
          ..add(_graphicsControl(delay, transparentIndex))
          ..add(_startImage(0, 0, width, height))
          ..add(lzw.compress(_frames[0], colors.bits));
      }
    } else {
      bytes.add(_loop(0));

      for (int i = 0; i < _frames.length; i++) {
        final frame = _frames[i];
        bytes
          ..add(_graphicsControl(delay, transparentIndex))
          ..add(_startImage(0, 0, width, height))
          ..add(lzw.compress(frame, colors.bits));
      }
    }
    bytes.add(_trailer());

    int len = 0;
    for (var chunk in bytes) {
      len += chunk.length;
    }

    final result = Uint8List(len);
    int offset = 0;
    for (var chunk in bytes) {
      result.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }
    assert(offset == len);
    return result;
  }
}

class _ColorTableBuilder {
  final List<int> table = <int>[];
  final Map<int, int> colorToIndex = <int, int>{};
  int? _transparentIndex;
  int? bits;

  /// Given rgba data, add each color to the color table.
  /// Returns the same pixels as color indexes.
  /// Pixels with alpha < 128 are treated as transparent and map to a special transparent index.
  Uint8List indexImage(int width, int height, List<int> rgba) {
    final pixels = Uint8List(width * height);
    assert(pixels.length == rgba.length / 4);

    for (int i = 0; i < rgba.length; i += 4) {
      final int alpha = rgba[i + 3];

      // Treat pixels with alpha < 128 as transparent
      if (alpha < 128) {
        // Ensure we have a transparent color in our table
        if (_transparentIndex == null) {
          _transparentIndex = table.length ~/ 3;
          colorToIndex[0] = _transparentIndex!;
          table
            ..add(0) // R
            ..add(0) // G
            ..add(0); // B
        }
        pixels[i >> 2] = _transparentIndex!;
      } else {
        // Opaque pixel - add to color table
        final int color = rgba[i] << 16 | rgba[i + 1] << 8 | rgba[i + 2];
        int? index = colorToIndex[color];

        if (index == null) {
          if (colorToIndex.length == maxColors) {
            throw Exception("image has more than $maxColors colors");
          }
          index = table.length ~/ 3;
          colorToIndex[color] = index;
          table
            ..add(rgba[i])
            ..add(rgba[i + 1])
            ..add(rgba[i + 2]);
        }
        pixels[i >> 2] = index;
      }
    }
    return pixels;
  }

  /// Pads the color table with zeros to the next power of 2 and sets bits.
  _ColorTable build() {
    for (int bits = 1; bits <= 8; bits++) {
      final int colors = 1 << bits;
      if (colors * 3 >= table.length) {
        final copy = Uint8List(colors * 3)..setRange(0, table.length, table);
        return _ColorTable(bits, copy, _transparentIndex);
      }
    }
    throw Exception("internal error; too many colors");
  }
}

class _ColorTable {
  final int bits;
  final Uint8List table;
  final int? transparentIndex;

  _ColorTable(this.bits, this.table, this.transparentIndex);

  int get numColors => table.length ~/ 3;
}

List<int> _header(int width, int height, int colorBits) {
  const _headerBlock = [0x47, 0x49, 0x46, 0x38, 0x39, 0x61]; // GIF 89a

  final bytes = <int>[..._headerBlock];
  _addShort(bytes, width);
  _addShort(bytes, height);
  bytes
    ..add(0xF0 | colorBits - 1)
    ..add(0)
    ..add(0);
  return bytes;
}

List<int> _loop(int reps) {
  final bytes = <int>[0x21, 0xff, 0x0B]
    ..addAll("NETSCAPE2.0".codeUnits)
    ..addAll([3, 1]);
  _addShort(bytes, reps);
  bytes.add(0);
  return bytes;
}

/// Graphics Control Extension - handles transparency and frame delay
List<int> _graphicsControl(int centiseconds, int? transparentIndex) {
  final bytes = <int>[
    0x21, // Extension Introducer
    0xF9, // Graphics Control Label
    4, // Block Size
  ];

  // Packed field format (1 byte):
  // Bits 0: Transparent Color Flag
  // Bits 1: User Input Flag
  // Bits 2-4: Disposal Method
  //   0 = No disposal specified
  //   1 = Do not dispose (keep)
  //   2 = Restore to background (clear frame)
  //   3 = Restore to previous
  // Bits 5-7: Reserved

  final hasTransparency = transparentIndex != null;
  final disposalMethod = 2; // Restore to background - prevents frame stacking
  final packedField = (disposalMethod << 2) | (hasTransparency ? 0x01 : 0x00);
  bytes.add(packedField); // Will be 0x09 with transparency, 0x08 without

  _addShort(bytes, centiseconds); // Delay time
  bytes.add(transparentIndex ?? 0); // Transparent color index
  bytes.add(0); // Block terminator

  return bytes;
}

List<int> _startImage(int left, int top, int width, int height) {
  final bytes = <int>[0x2C];
  _addShort(bytes, left);
  _addShort(bytes, top);
  _addShort(bytes, width);
  _addShort(bytes, height);
  bytes.add(0);
  return bytes;
}

List<int> _trailer() => [0x3b];

void _addShort(List<int> dest, int n) {
  if (n < 0 || n > 0xFFFF) throw Exception("out of range for short: $n");
  dest
    ..add(n & 0xff)
    ..add(n >> 8);
}

import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';

class DragUtils {
  final int width;
  final int height;

  DragUtils({
    required this.width,
    required this.height,
  });

  List<Point<int>> _getConnectedPixels(Uint32List pixels, int x, int y) {
    final visited = <Point<int>>{};
    final queue = Queue<Point<int>>();
    final startColor = pixels[y * width + x];
    if (startColor == 0) return []; // Transparent pixel

    queue.add(Point(x, y));
    visited.add(Point(x, y));

    while (queue.isNotEmpty) {
      final p = queue.removeFirst();
      final px = p.x;
      final py = p.y;

      // Check neighboring pixels (4-connected)
      for (var dx = -1; dx <= 1; dx++) {
        for (var dy = -1; dy <= 1; dy++) {
          if ((dx.abs() + dy.abs()) != 1) continue; // Skip diagonals and self
          final nx = px + dx;
          final ny = py + dy;
          if (nx >= 0 && nx < width && ny >= 0 && ny < height) {
            final np = Point(nx, ny);
            if (!visited.contains(np)) {
              final color = pixels[ny * width + nx];
              if (color != 0) {
                visited.add(np);
                queue.add(np);
              }
            }
          }
        }
      }
    }

    return visited.toList();
  }
}

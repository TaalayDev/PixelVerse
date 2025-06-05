import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../data.dart';

extension ListIntX on List<int> {
  int max() {
    if (isEmpty) return 0;
    return reduce((value, element) => value > element ? value : element);
  }

  int min() {
    if (isEmpty) return 0;
    return reduce((value, element) => value < element ? value : element);
  }

  double average() {
    if (isEmpty) return 0;
    return fold(0, (sum, element) => sum + element) / length;
  }
}

extension ListX<T> on List<T> {
  List<T> mapIndexed(T Function(int index, T item) f) {
    return asMap().entries.map((e) => f(e.key, e.value)).toList();
  }
}

extension Uint32ListX on Uint32List {
  /// Creates a deep copy of the Uint32List
  Uint32List copy() {
    return Uint32List.fromList(this);
  }

  /// Copies a section of pixels from source to destination
  void copyArea({
    required Uint32List source,
    required int sourceWidth,
    required int destWidth,
    required int srcX,
    required int srcY,
    required int destX,
    required int destY,
    required int width,
    required int height,
  }) {
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final srcIndex = (srcY + y) * sourceWidth + (srcX + x);
        final destIndex = (destY + y) * destWidth + (destX + x);

        // Check bounds for both source and destination
        if (srcIndex >= 0 && srcIndex < source.length && destIndex >= 0 && destIndex < this.length) {
          this[destIndex] = source[srcIndex];
        }
      }
    }
  }

  /// Clears a rectangular area by setting all pixels to transparent
  void clearArea({
    required int canvasWidth,
    required int x,
    required int y,
    required int width,
    required int height,
  }) {
    for (int iy = 0; iy < height; iy++) {
      for (int ix = 0; ix < width; ix++) {
        final index = (y + iy) * canvasWidth + (x + ix);
        if (index >= 0 && index < this.length) {
          this[index] = 0; // Transparent
        }
      }
    }
  }

  /// Extract pixels in a selection area into a separate Uint32List
  Uint32List extractArea(
      {required int canvasWidth, required int x, required int y, required int width, required int height}) {
    final result = Uint32List(width * height);
    for (int iy = 0; iy < height; iy++) {
      for (int ix = 0; ix < width; ix++) {
        final sourceIndex = (y + iy) * canvasWidth + (x + ix);
        final targetIndex = iy * width + ix;
        if (sourceIndex >= 0 && sourceIndex < this.length && targetIndex >= 0 && targetIndex < result.length) {
          result[targetIndex] = this[sourceIndex];
        }
      }
    }
    return result;
  }
}

extension PointX on Point<int> {
  /// Checks if this point is inside the given rectangle
  bool isInRect(int x, int y, int width, int height) {
    return this.x >= x && this.x < x + width && this.y >= y && this.y < y + height;
  }

  /// Offsets a point by given delta
  Point<int> offset(int dx, int dy) {
    return Point<int>(this.x + dx, this.y + dy);
  }
}

/// Extension for selection-related operations
extension SelectionOps on SelectionModel {
  /// Check if the selection contains a point
  bool containsPoint(int x, int y) {
    return x >= this.x && x < this.x + this.width && y >= this.y && y < this.y + this.height;
  }

  /// Creates a new selection model offset by dx, dy
  SelectionModel offsetBy(int dx, int dy) {
    return SelectionModel(
      x: this.x + dx,
      y: this.y + dy,
      width: this.width,
      height: this.height,
      canvasSize: this.canvasSize,
    );
  }

  /// Ensures the selection stays within the canvas bounds
  SelectionModel constrainToCanvas(int canvasWidth, int canvasHeight) {
    int newX = x;
    int newY = y;

    // Adjust x to keep the selection within the canvas bounds
    if (newX < 0) newX = 0;
    if (newX + width > canvasWidth) newX = canvasWidth - width;

    // Adjust y to keep the selection within the canvas bounds
    if (newY < 0) newY = 0;
    if (newY + height > canvasHeight) newY = canvasHeight - height;

    return SelectionModel(
      x: newX,
      y: newY,
      width: width,
      height: height,
      pixels: pixels,
      canvasSize: Size(canvasWidth.toDouble(), canvasHeight.toDouble()),
    );
  }

  /// Returns true if the point is close to the selection border
  bool isNearBorder(double x, double y, double tolerance) {
    final rect = this.rect;
    final minDistance = tolerance;

    // Calculate distance to each edge
    final distanceToLeft = (x - rect.left).abs();
    final distanceToRight = (x - rect.right).abs();
    final distanceToTop = (y - rect.top).abs();
    final distanceToBottom = (y - rect.bottom).abs();

    // Return true if any distance is less than the tolerance
    return distanceToLeft < minDistance ||
        distanceToRight < minDistance ||
        distanceToTop < minDistance ||
        distanceToBottom < minDistance;
  }

  /// Returns the position where this selection can be docked to another selection
  SelectionModel dockTo(SelectionModel other, double snapDistance) {
    // Try to dock to the edges of the other selection
    final myRect = this.rect;
    final otherRect = other.rect;

    // Calculate distances between edges
    final leftDiff = (myRect.left - otherRect.right).abs();
    final rightDiff = (myRect.right - otherRect.left).abs();
    final topDiff = (myRect.top - otherRect.bottom).abs();
    final bottomDiff = (myRect.bottom - otherRect.top).abs();

    // Find the closest edge
    if (leftDiff < snapDistance && leftDiff < rightDiff && leftDiff < topDiff && leftDiff < bottomDiff) {
      return SelectionModel(
        x: otherRect.right.toInt(),
        y: this.y,
        width: this.width,
        height: this.height,
        canvasSize: this.canvasSize,
      );
    } else if (rightDiff < snapDistance && rightDiff < topDiff && rightDiff < bottomDiff) {
      return SelectionModel(
        x: otherRect.left.toInt() - this.width,
        y: this.y,
        width: this.width,
        height: this.height,
        canvasSize: this.canvasSize,
      );
    } else if (topDiff < snapDistance && topDiff < bottomDiff) {
      return SelectionModel(
        x: this.x,
        y: otherRect.bottom.toInt(),
        width: this.width,
        height: this.height,
        canvasSize: this.canvasSize,
      );
    } else if (bottomDiff < snapDistance) {
      return SelectionModel(
        x: this.x,
        y: otherRect.top.toInt() - this.height,
        width: this.width,
        height: this.height,
        canvasSize: this.canvasSize,
      );
    }

    // No docking needed
    return this;
  }

  /// Returns the same selection as Rect for easier Flutter interop
  Rect asRect() => this.rect;
}

extension StringX on String {
  String capitalize() {
    return isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
  }
}

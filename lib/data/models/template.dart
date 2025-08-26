import 'dart:typed_data';
import 'package:equatable/equatable.dart';

/// Represents a pixel art template that can be applied to the canvas
class Template extends Equatable {
  final String name;
  final int width;
  final int height;
  final List<int> pixels;

  const Template({
    required this.name,
    required this.width,
    required this.height,
    required this.pixels,
  });

  /// Create Template from JSON
  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
      name: json['name'] as String,
      width: json['width'] as int,
      height: json['height'] as int,
      pixels: List<int>.from(json['pixels'] as List),
    );
  }

  /// Convert Template to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'width': width,
      'height': height,
      'pixels': pixels,
    };
  }

  /// Convert template pixels to Uint32List for layer creation
  Uint32List get pixelsAsUint32List {
    return Uint32List.fromList(pixels);
  }

  /// Check if template is empty (all transparent pixels)
  bool get isEmpty {
    return pixels.every((pixel) => pixel == 0);
  }

  /// Get preview pixel at specific position
  int getPixelAt(int x, int y) {
    if (x < 0 || x >= width || y < 0 || y >= height) {
      return 0; // Transparent
    }
    final index = y * width + x;
    if (index < 0 || index >= pixels.length) {
      return 0;
    }
    return pixels[index];
  }

  @override
  List<Object?> get props => [name, width, height, pixels];

  @override
  String toString() => 'Template(name: $name, ${width}x$height, ${pixels.length} pixels)';
}

/// Collection of templates loaded from assets
class TemplateCollection extends Equatable {
  final List<Template> templates;

  const TemplateCollection({
    required this.templates,
  });

  /// Create TemplateCollection from JSON
  factory TemplateCollection.fromJson(List<dynamic> json) {
    return TemplateCollection(
      templates: json.map((item) => Template.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }

  /// Convert TemplateCollection to JSON
  List<Map<String, dynamic>> toJson() {
    return templates.map((template) => template.toJson()).toList();
  }

  /// Get template by name
  Template? getByName(String name) {
    try {
      return templates.firstWhere((template) => template.name == name);
    } catch (e) {
      return null;
    }
  }

  /// Get templates filtered by size
  List<Template> getBySize({int? width, int? height}) {
    return templates.where((template) {
      if (width != null && template.width != width) return false;
      if (height != null && template.height != height) return false;
      return true;
    }).toList();
  }

  /// Get non-empty templates
  List<Template> get nonEmpty {
    return templates.where((template) => !template.isEmpty).toList();
  }

  @override
  List<Object?> get props => [templates];

  @override
  String toString() => 'TemplateCollection(${templates.length} templates)';
}

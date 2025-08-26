import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../data.dart';
import '../../data/models/template.dart';

/// Service for managing pixel art templates
class TemplateService {
  static final TemplateService _instance = TemplateService._internal();
  factory TemplateService() => _instance;
  TemplateService._internal();

  TemplateCollection? _templates;
  bool _isLoading = false;

  /// Get templates, loading them if necessary
  Future<TemplateCollection> getTemplates() async {
    if (_templates != null) {
      return _templates!;
    }
    return await loadTemplates();
  }

  /// Load templates from assets
  Future<TemplateCollection> loadTemplates() async {
    if (_isLoading) {
      // Wait for current loading to complete
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _templates ?? const TemplateCollection(templates: []);
    }

    _isLoading = true;
    try {
      final String jsonString = await rootBundle.loadString('assets/data/templates.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

      _templates = TemplateCollection.fromJson(jsonList);
      debugPrint('Loaded ${_templates!.templates.length} templates');

      return _templates!;
    } catch (e) {
      debugPrint('Error loading templates: $e');
      // Return empty collection if loading fails
      _templates = const TemplateCollection(templates: []);
      return _templates!;
    } finally {
      _isLoading = false;
    }
  }

  /// Create a layer from a template
  Future<Layer> createLayerFromTemplate({
    required Template template,
    required int projectId,
    required int frameId,
    required int canvasWidth,
    required int canvasHeight,
    String? layerName,
  }) async {
    // Calculate position to center the template on the canvas
    final offsetX = (canvasWidth - template.width) ~/ 2;
    final offsetY = (canvasHeight - template.height) ~/ 2;

    // Create canvas-sized pixel array
    final canvasPixels = Uint32List(canvasWidth * canvasHeight);

    // Place template pixels at calculated offset
    for (int ty = 0; ty < template.height; ty++) {
      for (int tx = 0; tx < template.width; tx++) {
        final templateIndex = ty * template.width + tx;
        if (templateIndex >= template.pixels.length) continue;

        final pixel = template.pixels[templateIndex];
        if (pixel == 0) continue; // Skip transparent pixels

        final canvasX = offsetX + tx;
        final canvasY = offsetY + ty;

        if (canvasX >= 0 && canvasX < canvasWidth && canvasY >= 0 && canvasY < canvasHeight) {
          final canvasIndex = canvasY * canvasWidth + canvasX;
          canvasPixels[canvasIndex] = pixel;
        }
      }
    }

    // Create layer with template data
    final layer = Layer(
      layerId: 0, // Will be assigned by the database
      id: const Uuid().v4(),
      name: layerName ?? template.name,
      pixels: canvasPixels,
      isVisible: true,
      order: 0, // Will be set appropriately when added to frame
    );

    return layer;
  }

  /// Apply template directly to existing layer at specified position
  Uint32List applyTemplateToLayer({
    required Template template,
    required Uint32List layerPixels,
    required int layerWidth,
    required int layerHeight,
    int? positionX,
    int? positionY,
    bool replacePixels = false,
  }) {
    final newPixels = Uint32List.fromList(layerPixels);

    // Default to center position if not specified
    final offsetX = positionX ?? (layerWidth - template.width) ~/ 2;
    final offsetY = positionY ?? (layerHeight - template.height) ~/ 2;

    for (int ty = 0; ty < template.height; ty++) {
      for (int tx = 0; tx < template.width; tx++) {
        final templateIndex = ty * template.width + tx;
        if (templateIndex >= template.pixels.length) continue;

        final templatePixel = template.pixels[templateIndex];
        if (templatePixel == 0 && !replacePixels) continue; // Skip transparent pixels

        final layerX = offsetX + tx;
        final layerY = offsetY + ty;

        if (layerX >= 0 && layerX < layerWidth && layerY >= 0 && layerY < layerHeight) {
          final layerIndex = layerY * layerWidth + layerX;
          newPixels[layerIndex] = templatePixel;
        }
      }
    }

    return newPixels;
  }

  /// Get template categories for grouping
  List<String> getTemplateCategories() {
    if (_templates == null) return [];

    final categories = <String>{};
    for (final template in _templates!.templates) {
      // Extract category from template name (e.g., "Character - Warrior" -> "Character")
      final parts = template.name.split(' - ');
      if (parts.length > 1) {
        categories.add(parts[0]);
      } else {
        categories.add('General');
      }
    }

    return categories.toList()..sort();
  }

  /// Get templates by category
  List<Template> getTemplatesByCategory(String category) {
    if (_templates == null) return [];

    return _templates!.templates.where((template) {
      if (category == 'General') {
        return !template.name.contains(' - ');
      }
      return template.name.startsWith('$category - ');
    }).toList();
  }

  /// Search templates by name
  List<Template> searchTemplates(String query) {
    if (_templates == null || query.isEmpty) return [];

    final lowercaseQuery = query.toLowerCase();
    return _templates!.templates.where((template) {
      return template.name.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Check if templates are loaded
  bool get isLoaded => _templates != null;

  /// Get number of available templates
  int get templateCount => _templates?.templates.length ?? 0;

  /// Reload templates from assets
  Future<TemplateCollection> reloadTemplates() async {
    _templates = null;
    return await loadTemplates();
  }
}

import 'dart:typed_data';
import 'package:equatable/equatable.dart';

import '../../config/constants.dart';

/// Represents a pixel art template that can be applied to the canvas
class Template extends Equatable {
  final int? id;
  final String name;
  final int width;
  final int height;
  final List<int> pixels;
  final String? description;
  final String? category;
  final List<String> tags;
  final bool isPublic;
  final bool isLocal; // True if stored locally, false if from server
  final String? authorName;
  final String? authorId;
  final String? thumbnailUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int likeCount;
  final int downloadCount;
  final bool isLiked;

  const Template({
    this.id,
    required this.name,
    required this.width,
    required this.height,
    required this.pixels,
    this.description,
    this.category,
    this.tags = const [],
    this.isPublic = true,
    this.isLocal = true,
    this.authorName,
    this.authorId,
    this.thumbnailUrl,
    this.createdAt,
    this.updatedAt,
    this.likeCount = 0,
    this.downloadCount = 0,
    this.isLiked = false,
  });

  /// Create Template from JSON
  factory Template.fromJson(Map<String, dynamic> json) {
    final width = int.tryParse(json['width'].toString()) ?? 0;
    final height = int.tryParse(json['height'].toString()) ?? 0;
    return Template(
      id: int.tryParse(json['id'].toString()),
      name: json['name'] as String,
      width: width,
      height: height,
      pixels: () {
        if (json['pixels'] == null) return List<int>.filled(width * height, 0);
        if (json['pixels'] is String) {
          return (json['pixels'] as String).split(',').map((p) => int.parse(p.trim())).toList();
        }
        return List<int>.from(json['pixels'] as List);
      }(),
      description: json['description'] as String?,
      category: json['category'] as String?,
      tags: json['tags'] is String
          ? (json['tags'] as String).split(',').map((t) => t.trim()).toList()
          : List<String>.from(json['tags'] ?? []),
      isPublic: json['is_public'] ?? true,
      isLocal: json['is_local'] ?? (json['id'] == null),
      authorName: json['author_name'] as String?,
      authorId: json['author_id'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      likeCount: int.tryParse(json['like_count'].toString()) ?? 0,
      downloadCount: int.tryParse(json['download_count'].toString()) ?? 0,
      isLiked: int.tryParse(json['is_liked'].toString()) == 1,
    );
  }

  /// Convert Template to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'width': width,
      'height': height,
      'pixels': pixels,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      'tags': tags,
      'is_public': isPublic,
      'is_local': isLocal,
      if (authorName != null) 'author_name': authorName,
      if (authorId != null) 'author_id': authorId,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      'like_count': likeCount,
      'download_count': downloadCount,
      'is_liked': isLiked,
    };
  }

  Template copyWith({
    int? id,
    String? name,
    int? width,
    int? height,
    List<int>? pixels,
    String? description,
    String? category,
    List<String>? tags,
    bool? isPublic,
    bool? isLocal,
    String? authorName,
    String? authorId,
    String? thumbnailUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likeCount,
    int? downloadCount,
    bool? isLiked,
  }) {
    return Template(
      id: id ?? this.id,
      name: name ?? this.name,
      width: width ?? this.width,
      height: height ?? this.height,
      pixels: pixels ?? this.pixels,
      description: description ?? this.description,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      isPublic: isPublic ?? this.isPublic,
      isLocal: isLocal ?? this.isLocal,
      authorName: authorName ?? this.authorName,
      authorId: authorId ?? this.authorId,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likeCount: likeCount ?? this.likeCount,
      downloadCount: downloadCount ?? this.downloadCount,
      isLiked: isLiked ?? this.isLiked,
    );
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

  String get sizeString => '$width×$height';

  String get categoryDisplayName {
    if (category == null) return 'Uncategorized';
    return category!.split('-').map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  bool matchesSearch(String query) {
    final searchQuery = query.toLowerCase();
    return name.toLowerCase().contains(searchQuery) ||
        (description?.toLowerCase().contains(searchQuery) ?? false) ||
        tags.any((tag) => tag.toLowerCase().contains(searchQuery)) ||
        (category?.toLowerCase().contains(searchQuery) ?? false);
  }

  String? get thumbnailImageUrl {
    if (id == null || id! <= 0) return null;
    return '${Constants.baseUrl}/api/v1/templates/$id/thumbnail';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        width,
        height,
        pixels,
        description,
        category,
        tags,
        isPublic,
        isLocal,
        authorName,
        authorId,
        thumbnailUrl,
        createdAt,
        updatedAt,
        likeCount,
        downloadCount,
        isLiked
      ];

  @override
  String toString() => 'Template(id: $id, name: $name, ${width}x$height, ${pixels.length} pixels, local: $isLocal)';
}

/// Collection of templates loaded from assets
class TemplateCollection extends Equatable {
  final List<Template> templates;
  final int total;
  final int page;
  final int limit;
  final bool hasMore;

  const TemplateCollection({
    required this.templates,
    this.total = 0,
    this.page = 1,
    this.limit = 20,
    this.hasMore = false,
  });

  /// Create TemplateCollection from JSON
  factory TemplateCollection.fromJson(List<dynamic> json) {
    return TemplateCollection(
      templates: json.map((item) => Template.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }

  factory TemplateCollection.fromApiResponse(Map<String, dynamic> json) {
    return TemplateCollection(
      templates: (json['templates'] as List).map((item) => Template.fromJson(item as Map<String, dynamic>)).toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      hasMore: json['has_more'] ?? false,
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

  Template? getById(int id) {
    try {
      return templates.firstWhere((template) => template.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Template> getByCategory(String category) {
    return templates.where((template) => template.category == category).toList();
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

  /// Get local templates only
  List<Template> get localTemplates {
    return templates.where((template) => template.isLocal).toList();
  }

  /// Get remote templates only
  List<Template> get remoteTemplates {
    return templates.where((template) => !template.isLocal).toList();
  }

  /// Search templates by query
  List<Template> search(String query) {
    return templates.where((template) => template.matchesSearch(query)).toList();
  }

  /// Get templates by tags
  List<Template> getByTags(List<String> tags) {
    return templates.where((template) {
      return tags.any((tag) => template.tags.contains(tag));
    }).toList();
  }

  /// Merge with another collection (useful for combining local + API results)
  TemplateCollection merge(TemplateCollection other) {
    final mergedTemplates = <Template>[];
    final seenNames = <String>{};

    // Add templates from this collection first
    for (final template in templates) {
      if (!seenNames.contains(template.name)) {
        mergedTemplates.add(template);
        seenNames.add(template.name);
      }
    }

    // Add templates from other collection that don't conflict
    for (final template in other.templates) {
      if (!seenNames.contains(template.name)) {
        mergedTemplates.add(template);
        seenNames.add(template.name);
      }
    }

    return TemplateCollection(
      templates: mergedTemplates,
      total: total + other.total,
      page: page,
      limit: limit,
      hasMore: hasMore || other.hasMore,
    );
  }

  @override
  List<Object?> get props => [templates, total, page, limit, hasMore];

  @override
  String toString() => 'TemplateCollection(${templates.length} templates)';
}

/// Template category for organizing templates
class TemplateCategory extends Equatable {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final int templateCount;
  final String? iconName;
  final String? color;

  const TemplateCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.templateCount,
    this.iconName,
    this.color,
  });

  factory TemplateCategory.fromJson(Map<String, dynamic> json) {
    return TemplateCategory(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      templateCount: int.tryParse(json['template_count'].toString()) ?? 0,
      iconName: json['icon_name'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      if (description != null) 'description': description,
      'template_count': templateCount,
      if (iconName != null) 'icon_name': iconName,
      if (color != null) 'color': color,
    };
  }

  @override
  List<Object?> get props => [id, name, slug, description, templateCount, iconName, color];

  @override
  String toString() => 'TemplateCategory(id: $id, name: $name, count: $templateCount)';
}

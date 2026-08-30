class CommunicatorContentModel {
  final List<CommCategoryModel> categories;
  final List<CommQuickSpeakModel> quickSpeaks;
  final int totalCategories;
  final int totalQuickSpeaks;

  CommunicatorContentModel({
    required this.categories,
    required this.quickSpeaks,
    required this.totalCategories,
    required this.totalQuickSpeaks,
  });

  factory CommunicatorContentModel.fromJson(Map<String, dynamic> json, {String lang = 'en'}) {
    var data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    if (data['content'] is Map) {
      data = Map<String, dynamic>.from(data['content'] as Map);
    }
    final qsRaw = data['quickspeaks'] ??
        data['quick_speaks'] ??
        data['quickSpeaks'] ??
        data['quick_speak'] ??
        const [];
    return CommunicatorContentModel(
      categories: (data['categories'] as List? ?? data['category_list'] as List? ?? [])
          .whereType<Map>()
          .map((e) => CommCategoryModel.fromJson(Map<String, dynamic>.from(e), lang: lang))
          .where((c) => !c.isDeleted && c.isActive)
          .toList(),
      quickSpeaks: (qsRaw is List ? qsRaw : const [])
          .whereType<Map>()
          .map((e) => CommQuickSpeakModel.fromJson(Map<String, dynamic>.from(e), lang: lang))
          .where((q) => !q.isDeleted)
          .toList(),
      totalCategories: data['total_categories'] ?? 0,
      totalQuickSpeaks: data['total_quickspeaks'] ?? data['total_quick_speaks'] ?? 0,
    );
  }
}

// Helper: resolve name/speak from translations
String _resolveName(Map<String, dynamic> json, String lang) {
  final translations = json['translations'];
  if (translations is Map) {
    final t = translations[lang];
    if (t is Map && t['name'] != null && (t['name'] as String).isNotEmpty) {
      return t['name'] as String;
    }
  }
  return json['name'] ?? '';
}

String? _resolveSpeak(Map<String, dynamic> json, String lang) {
  final translations = json['translations'];
  if (translations is Map) {
    final t = translations[lang];
    if (t is Map && t['speak'] != null) {
      return t['speak'] as String?;
    }
  }
  return json['speak'];
}

String? _resolveWord(Map<String, dynamic> json, String lang) {
  final translations = json['translations'];
  if (translations is Map) {
    final langData = translations[lang];
    if (langData is Map) {
      final word = langData['word'];
      if (word != null && (word as String).isNotEmpty) return word;
      final name = langData['name'];
      if (name != null && (name as String).isNotEmpty) return name as String;
    }
    final enData = translations['en'];
    if (enData is Map) {
      return (enData['word'] ?? enData['name']) as String?;
    }
  }
  return json['word'] ?? json['name'];
}


class CommCategoryModel {
  final int id;
  final String name;
  final String? speak;
  final String color;
  final String? imageIcon;
  final int order;
  final bool isActive;
  final bool isDeleted;
  final List<CommSubCategoryModel> subCategories;
  final List<CommItemModel> items;
  final int subCategoriesCount;

  CommCategoryModel({
    required this.id,
    required this.name,
    this.speak,
    required this.color,
    this.imageIcon,
    required this.order,
    required this.isActive,
    required this.isDeleted,
    required this.subCategories,
    required this.items,
    required this.subCategoriesCount,
  });

  factory CommCategoryModel.fromJson(Map<String, dynamic> json, {String lang = 'en'}) {
    return CommCategoryModel(
      id: json['id'] ?? 0,
      name: _resolveName(json, lang),
      speak: _resolveSpeak(json, lang),
      color: json['color'] ?? '#B5CFD1',
      imageIcon: json['image_icon'],
      order: json['order'] ?? 0,
      isActive: json['is_active'] ?? true,
      isDeleted: json['is_deleted'] ?? false,
      subCategoriesCount: json['sub_categories_count'] ?? 0,
      subCategories: (json['sub_categories'] as List? ?? json['subcategories'] as List? ?? [])
          .whereType<Map>()
          .map((e) => CommSubCategoryModel.fromJson(Map<String, dynamic>.from(e), lang: lang))
          .where((s) => !s.isDeleted && s.isActive)
          .toList(),
      items: (json['items'] as List? ?? json['direct_items'] as List? ?? [])
          .whereType<Map>()
          .map((e) => CommItemModel.fromJson(Map<String, dynamic>.from(e), lang: lang))
          .where((i) => !i.isDeleted && i.isActive)
          .toList(),
    );
  }
}


class CommSubCategoryModel {
  final int id;
  final int? mainCategory;
  final String name;
  final String? speak;
  final String color;
  final String? imageIcon;
  final int order;
  final bool isActive;
  final bool isDeleted;
  final List<CommItemModel> items;
  final int itemsCount;

  CommSubCategoryModel({
    required this.id,
    this.mainCategory,
    required this.name,
    this.speak,
    required this.color,
    this.imageIcon,
    required this.order,
    required this.isActive,
    required this.isDeleted,
    required this.items,
    required this.itemsCount,
  });

  factory CommSubCategoryModel.fromJson(Map<String, dynamic> json, {String lang = 'en'}) {
    return CommSubCategoryModel(
      id: json['id'] ?? 0,
      mainCategory: json['main_category'],
      name: _resolveName(json, lang),
      speak: _resolveSpeak(json, lang),
      color: json['color'] ?? '#B5CFD1',
      imageIcon: json['image_icon'],
      order: json['order'] ?? 0,
      isActive: json['is_active'] ?? true,
      isDeleted: json['is_deleted'] ?? false,
      itemsCount: json['items_count'] ?? 0,
      items: (json['items'] as List? ?? json['direct_items'] as List? ?? [])
          .whereType<Map>()
          .map((e) => CommItemModel.fromJson(Map<String, dynamic>.from(e), lang: lang))
          .where((i) => !i.isDeleted && i.isActive)
          .toList(),
    );
  }
}


class CommItemModel {
  final int id;
  final int? category;
  final String? word;
  final String? speak;
  final String color;
  final String? imageIcon;
  final int order;
  final bool isActive;
  final bool isDeleted;

  CommItemModel({
    required this.id,
    this.category,
    this.word,
    this.speak,
    required this.color,
    this.imageIcon,
    required this.order,
    required this.isActive,
    required this.isDeleted,
  });

  factory CommItemModel.fromJson(Map<String, dynamic> json, {String lang = 'en'}) {
    return CommItemModel(
      id: json['id'] ?? 0,
      category: json['category'],
      word: _resolveWord(json, lang) ?? json['word'],
      speak: _resolveSpeak(json, lang),
      color: json['color'] ?? '#FFD700',
      imageIcon: json['image_icon'],
      order: json['order'] ?? 0,
      isActive: json['is_active'] ?? true,
      isDeleted: json['is_deleted'] ?? false,
    );
  }
}


class CommQuickSpeakModel {
  final int id;
  final String? word;
  final String? speak;
  final String color;
  final String? imageIcon;
  final int order;
  final bool isActive;
  final bool isDeleted;

  CommQuickSpeakModel({
    required this.id,
    this.word,
    this.speak,
    required this.color,
    this.imageIcon,
    required this.order,
    required this.isActive,
    required this.isDeleted,
  });

  factory CommQuickSpeakModel.fromJson(Map<String, dynamic> json, {String lang = 'en'}) {
    return CommQuickSpeakModel(
      id: json['id'] ?? 0,
      word: _resolveWord(json, lang) ?? json['word'],
      speak: _resolveSpeak(json, lang),
      color: json['color'] ?? '#FFD700',
      imageIcon: json['image_icon'],
      order: json['order'] ?? 0,
      isActive: json['is_active'] ?? true,
      isDeleted: json['is_deleted'] ?? false,
    );
  }
}

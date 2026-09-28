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


class CommCategoryListResponse {
  final bool isCustomized;
  final bool isBuddyMode;
  final String? updatedAt;
  final String? etag;
  final List<CommCategoryLite> categories;
  final List<CommQuickSpeakModel> quickSpeaks;
  final int totalCategories;
  final int totalQuickSpeaks;

  CommCategoryListResponse({
    required this.isCustomized,
    required this.isBuddyMode,
    this.updatedAt,
    this.etag,
    required this.categories,
    required this.quickSpeaks,
    required this.totalCategories,
    required this.totalQuickSpeaks,
  });

  factory CommCategoryListResponse.fromJson(Map<String, dynamic> json,
      {String lang = 'en'}) {
    final data = json['data'] ?? json;
    return CommCategoryListResponse(
      isCustomized: data['is_customized'] ?? false,
      isBuddyMode: data['is_buddy_mode'] ?? false,
      updatedAt: data['updated_at'],
      etag: data['etag'],
      categories: (data['categories'] as List? ?? [])
          .whereType<Map>()
          .map((e) => CommCategoryLite.fromJson(Map<String, dynamic>.from(e),
          lang: lang))
          .toList(),
      quickSpeaks:
      (data['quick_speaks'] as List? ?? data['quickspeaks'] as List? ?? [])
          .whereType<Map>()
          .map((e) => CommQuickSpeakModel.fromJson(
          Map<String, dynamic>.from(e),
          lang: lang))
          .toList(),
      totalCategories: data['total_categories'] ?? 0,
      totalQuickSpeaks: data['total_quickspeaks'] ?? 0,
    );
  }
}

class CommCategoryLite {
  final int id;
  final String name;
  final String? imageIcon;
  final String color;
  final int order;
  final int itemsCount;
  final int subCategoriesCount;

  CommCategoryLite({
    required this.id,
    required this.name,
    this.imageIcon,
    required this.color,
    required this.order,
    required this.itemsCount,
    required this.subCategoriesCount,
  });

  factory CommCategoryLite.fromJson(Map<String, dynamic> json,
      {String lang = 'en'}) {
    return CommCategoryLite(
      id: json['id'] ?? 0,
      name: _resolveName(json, lang),
      imageIcon: json['image_icon'],
      color: json['color'] ?? '#B5CFD1',
      order: json['order'] ?? 0,
      itemsCount: json['items_count'] ?? 0,
      subCategoriesCount: json['sub_categories_count'] ?? 0,
    );
  }
}

class CommSubCategoryLite {
  final int id;
  final String name;
  final String? imageIcon;
  final String color;
  final int order;
  final int itemsCount;

  CommSubCategoryLite({
    required this.id,
    required this.name,
    this.imageIcon,
    required this.color,
    required this.order,
    required this.itemsCount,
  });

  factory CommSubCategoryLite.fromJson(Map<String, dynamic> json,
      {String lang = 'en'}) {
    return CommSubCategoryLite(
      id: json['id'] ?? 0,
      name: _resolveName(json, lang),
      imageIcon: json['image_icon'],
      color: json['color'] ?? '#B5CFD1',
      order: json['order'] ?? 0,
      itemsCount: json['items_count'] ?? 0,
    );
  }
}

class CommItemLite {
  final int id;
  final String? word;
  final String? imageIcon;
  final String? speak;
  final String color;
  final int order;

  CommItemLite({
    required this.id,
    this.word,
    this.imageIcon,
    this.speak,
    required this.color,
    required this.order,
  });

  factory CommItemLite.fromJson(Map<String, dynamic> json, {String lang = 'en'}) {
    return CommItemLite(
      id: json['id'] ?? 0,
      word: _resolveWord(json, lang) ?? json['word'],
      imageIcon: json['image_icon'],
      speak: _resolveSpeak(json, lang) ?? json['speak'],
      color: json['color'] ?? '#FFD700',
      order: json['order'] ?? 0,
    );
  }
}

class CommCategoryItemsResponse {
  final CommCategoryLite category;
  final List<CommItemLite> items;
  final List<CommSubCategoryLite> subCategories;
  final int totalItems;
  final int totalSubCategories;

  CommCategoryItemsResponse({
    required this.category,
    required this.items,
    required this.subCategories,
    required this.totalItems,
    required this.totalSubCategories,
  });

  factory CommCategoryItemsResponse.fromJson(Map<String, dynamic> json,
      {String lang = 'en'}) {
    final data = json['data'] ?? json;
    final catJson = Map<String, dynamic>.from(data['category'] ?? {});
    final itemsJson = (data['items'] as List? ?? []);
    final subsJson = (data['sub_categories'] as List? ?? []);
    return CommCategoryItemsResponse(
      category: CommCategoryLite(
        id: catJson['id'] ?? 0,
        name: _resolveName(catJson, lang),
        imageIcon: catJson['image_icon'],
        color: catJson['color'] ?? '#B5CFD1',
        order: catJson['order'] ?? 0,
        itemsCount: data['total_items'] ?? itemsJson.length,
        subCategoriesCount: data['total_sub_categories'] ?? subsJson.length,
      ),
      items: itemsJson
          .whereType<Map>()
          .map((e) =>
          CommItemLite.fromJson(Map<String, dynamic>.from(e), lang: lang))
          .toList(),
      subCategories: subsJson
          .whereType<Map>()
          .map((e) => CommSubCategoryLite.fromJson(
          Map<String, dynamic>.from(e),
          lang: lang))
          .toList(),
      totalItems: data['total_items'] ?? itemsJson.length,
      totalSubCategories: data['total_sub_categories'] ?? subsJson.length,
    );
  }
}

class CommSubCategoryItemsResponse {
  final CommSubCategoryLite subCategory;
  final List<CommItemLite> items;
  final int totalItems;

  CommSubCategoryItemsResponse({
    required this.subCategory,
    required this.items,
    required this.totalItems,
  });

  factory CommSubCategoryItemsResponse.fromJson(Map<String, dynamic> json,
      {String lang = 'en'}) {
    final data = json['data'] ?? json;
    final subJson = Map<String, dynamic>.from(data['sub_category'] ?? {});
    final itemsJson = (data['items'] as List? ?? []);
    return CommSubCategoryItemsResponse(
      subCategory: CommSubCategoryLite(
        id: subJson['id'] ?? 0,
        name: _resolveName(subJson, lang),
        imageIcon: subJson['image_icon'],
        color: subJson['color'] ?? '#B5CFD1',
        order: subJson['order'] ?? 0,
        itemsCount: data['total_items'] ?? itemsJson.length,
      ),
      items: itemsJson
          .whereType<Map>()
          .map((e) =>
          CommItemLite.fromJson(Map<String, dynamic>.from(e), lang: lang))
          .toList(),
      totalItems: data['total_items'] ?? itemsJson.length,
    );
  }
}

class CommSearchItemResult {
  final int id;
  final String? word;
  final String? imageIcon;
  final String? speak;
  final String color;
  final int order;
  final int? categoryId;
  final String? categoryName;

  CommSearchItemResult({
    required this.id,
    this.word,
    this.imageIcon,
    this.speak,
    required this.color,
    required this.order,
    this.categoryId,
    this.categoryName,
  });

  factory CommSearchItemResult.fromJson(Map<String, dynamic> json,
      {String lang = 'en'}) {
    return CommSearchItemResult(
      id: json['id'] ?? 0,
      word: _resolveWord(json, lang) ?? json['word'],
      imageIcon: json['image_icon'],
      speak: _resolveSpeak(json, lang) ?? json['speak'],
      color: json['color'] ?? '#FFD700',
      order: json['order'] ?? 0,
      categoryId: json['category_id'],
      categoryName: json['category_name'],
    );
  }
}

class CommSearchResponse {
  final String query;
  final List<CommSearchItemResult> items;
  final List<CommQuickSpeakModel> quickSpeaks;
  final int totalResults;

  CommSearchResponse({
    required this.query,
    required this.items,
    required this.quickSpeaks,
    required this.totalResults,
  });

  factory CommSearchResponse.fromJson(Map<String, dynamic> json,
      {String lang = 'en'}) {
    final data = json['data'] ?? json;
    return CommSearchResponse(
      query: data['search_query'] ?? '',
      items: (data['items'] as List? ?? [])
          .whereType<Map>()
          .map((e) => CommSearchItemResult.fromJson(
          Map<String, dynamic>.from(e),
          lang: lang))
          .toList(),
      quickSpeaks:
      (data['quickspeaks'] as List? ?? data['quick_speaks'] as List? ?? [])
          .whereType<Map>()
          .map((e) => CommQuickSpeakModel.fromJson(
          Map<String, dynamic>.from(e),
          lang: lang))
          .toList(),
      totalResults: data['total_results'] ?? 0,
    );
  }
}
// Helper: resolve name/word/speak from translations
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


class UserContentModel {
  final bool isCustomized;
  final List<CategoryModel> categories;
  final List<QuickSpeakModel> quickSpeaks;

  UserContentModel({
    required this.isCustomized,
    required this.categories,
    required this.quickSpeaks,
  });

  factory UserContentModel.fromJson(Map<String, dynamic> json, {String lang = 'en'}) {
    final data = json['data'] ?? json;
    return UserContentModel(
      isCustomized: data['is_customized'] ?? false,
      categories: (data['categories'] as List? ?? data['category_list'] as List? ?? [])
          .whereType<Map>()
          .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e), lang: lang))
          .toList(),
      quickSpeaks: (data['quickspeaks'] as List? ?? data['quick_speaks'] as List? ?? [])
          .whereType<Map>()
          .map((e) => QuickSpeakModel.fromJson(Map<String, dynamic>.from(e), lang: lang))
          .toList(),
    );
  }
}

class CategoryModel {
  final int id;
  final String name;
  final String? imageIcon;
  final String? speak;
  final String color;
  final int order;
  final bool isActive;
  final List<SubCategoryModel> subCategories;
  final List<ItemModel> items;

  CategoryModel({
    required this.id,
    required this.name,
    this.imageIcon,
    this.speak,
    required this.color,
    required this.order,
    required this.isActive,
    required this.subCategories,
    required this.items,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json, {String lang = 'en'}) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: _resolveName(json, lang),
      imageIcon: json['image_icon'],
      speak: _resolveSpeak(json, lang),
      color: json['color'] ?? '#B5CFD1',
      order: json['order'] ?? 0,
      isActive: json['is_active'] ?? true,
      subCategories: (json['sub_categories'] as List? ?? json['subcategories'] as List? ?? [])
          .whereType<Map>()
          .map((e) => SubCategoryModel.fromJson(Map<String, dynamic>.from(e), lang: lang))
          .toList(),
      items: (json['items'] as List? ?? json['direct_items'] as List? ?? [])
          .whereType<Map>()
          .map((e) => ItemModel.fromJson(Map<String, dynamic>.from(e), lang: lang))
          .toList(),
    );
  }
}

class SubCategoryModel {
  final int id;
  final int mainCategory;
  final String name;
  final String? imageIcon;
  final String? speak;
  final String color;
  final int order;
  final bool isActive;
  final List<ItemModel> items;

  SubCategoryModel({
    required this.id,
    required this.mainCategory,
    required this.name,
    this.imageIcon,
    this.speak,
    required this.color,
    required this.order,
    required this.isActive,
    required this.items,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json, {String lang = 'en'}) {
    return SubCategoryModel(
      id: json['id'] ?? 0,
      mainCategory: json['main_category'] ?? 0,
      name: _resolveName(json, lang),
      imageIcon: json['image_icon'],
      speak: _resolveSpeak(json, lang),
      color: json['color'] ?? '#B5CFD1',
      order: json['order'] ?? 0,
      isActive: json['is_active'] ?? true,
      items: (json['items'] as List? ?? json['direct_items'] as List? ?? [])
          .whereType<Map>()
          .map((e) => ItemModel.fromJson(Map<String, dynamic>.from(e), lang: lang))
          .toList(),
    );
  }
}

class ItemModel {
  final int id;
  final int category;
  final String? word;
  final String? imageIcon;
  final String? speak;
  final String color;
  final int order;
  final bool isActive;

  ItemModel({
    required this.id,
    required this.category,
    this.word,
    this.imageIcon,
    this.speak,
    required this.color,
    required this.order,
    required this.isActive,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json, {String lang = 'en'}) {
    return ItemModel(
      id: json['id'] ?? 0,
      category: json['category'] ?? 0,
      word: _resolveWord(json, lang) ?? json['word'],
      imageIcon: json['image_icon'],
      speak: _resolveSpeak(json, lang),
      color: json['color'] ?? '#FFD700',
      order: json['order'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }
}

class QuickSpeakModel {
  final int id;
  final String? word;
  final String? imageIcon;
  final String? speak;
  final String color;
  final int order;
  final bool isActive;

  QuickSpeakModel({
    required this.id,
    this.word,
    this.imageIcon,
    this.speak,
    required this.color,
    required this.order,
    required this.isActive,
  });

  factory QuickSpeakModel.fromJson(Map<String, dynamic> json, {String lang = 'en'}) {
    return QuickSpeakModel(
      id: json['id'] ?? 0,
      word: _resolveWord(json, lang) ?? json['word'],
      imageIcon: json['image_icon'],
      speak: _resolveSpeak(json, lang),
      color: json['color'] ?? '#FFD700',
      order: json['order'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Lightweight / lazy-loaded models — new granular endpoints.
// NOTE: image_icon/speak here arrive as FULL URLs already (not relative
// paths), unlike the legacy models above. Do NOT pass these through
// AppUrl.mediaUrl() again — use imageIcon / speak directly.
// ══════════════════════════════════════════════════════════════════

class CategoryListResponse {
  final bool isCustomized;
  final bool isBuddyMode;
  final String? updatedAt;
  final String? etag;
  final List<CategoryLite> categories;
  final List<QuickSpeakModel> quickSpeaks;
  final int totalCategories;
  final int totalQuickSpeaks;

  CategoryListResponse({
    required this.isCustomized,
    required this.isBuddyMode,
    this.updatedAt,
    this.etag,
    required this.categories,
    required this.quickSpeaks,
    required this.totalCategories,
    required this.totalQuickSpeaks,
  });

  factory CategoryListResponse.fromJson(Map<String, dynamic> json,
      {String lang = 'en'}) {
    final data = json['data'] ?? json;
    return CategoryListResponse(
      isCustomized: data['is_customized'] ?? false,
      isBuddyMode: data['is_buddy_mode'] ?? false,
      updatedAt: data['updated_at'],
      etag: data['etag'],
      categories: (data['categories'] as List? ?? [])
          .whereType<Map>()
          .map((e) =>
          CategoryLite.fromJson(Map<String, dynamic>.from(e), lang: lang))
          .toList(),
      quickSpeaks:
      (data['quick_speaks'] as List? ?? data['quickspeaks'] as List? ?? [])
          .whereType<Map>()
          .map((e) => QuickSpeakModel.fromJson(
          Map<String, dynamic>.from(e),
          lang: lang))
          .toList(),
      totalCategories: data['total_categories'] ?? 0,
      totalQuickSpeaks: data['total_quickspeaks'] ?? 0,
    );
  }
}

class CategoryLite {
  final int id;
  final String name;
  final String? imageIcon;
  final String color;
  final int order;
  final int itemsCount;
  final int subCategoriesCount;

  CategoryLite({
    required this.id,
    required this.name,
    this.imageIcon,
    required this.color,
    required this.order,
    required this.itemsCount,
    required this.subCategoriesCount,
  });

  factory CategoryLite.fromJson(Map<String, dynamic> json,
      {String lang = 'en'}) {
    return CategoryLite(
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

class SubCategoryLite {
  final int id;
  final String name;
  final String? imageIcon;
  final String color;
  final int order;
  final int itemsCount;

  SubCategoryLite({
    required this.id,
    required this.name,
    this.imageIcon,
    required this.color,
    required this.order,
    required this.itemsCount,
  });

  factory SubCategoryLite.fromJson(Map<String, dynamic> json,
      {String lang = 'en'}) {
    return SubCategoryLite(
      id: json['id'] ?? 0,
      name: _resolveName(json, lang),
      imageIcon: json['image_icon'],
      color: json['color'] ?? '#B5CFD1',
      order: json['order'] ?? 0,
      itemsCount: json['items_count'] ?? 0,
    );
  }
}

class ItemLite {
  final int id;
  final String? word;
  final String? imageIcon;
  final String? speak;
  final String color;
  final int order;

  ItemLite({
    required this.id,
    this.word,
    this.imageIcon,
    this.speak,
    required this.color,
    required this.order,
  });

  factory ItemLite.fromJson(Map<String, dynamic> json, {String lang = 'en'}) {
    return ItemLite(
      id: json['id'] ?? 0,
      word: _resolveWord(json, lang) ?? json['word'],
      imageIcon: json['image_icon'],
      speak: _resolveSpeak(json, lang) ?? json['speak'],
      color: json['color'] ?? '#FFD700',
      order: json['order'] ?? 0,
    );
  }
}

class CategoryItemsResponse {
  final CategoryLite category;
  final List<ItemLite> items;
  final List<SubCategoryLite> subCategories;
  final int totalItems;
  final int totalSubCategories;

  CategoryItemsResponse({
    required this.category,
    required this.items,
    required this.subCategories,
    required this.totalItems,
    required this.totalSubCategories,
  });

  factory CategoryItemsResponse.fromJson(Map<String, dynamic> json,
      {String lang = 'en'}) {
    final data = json['data'] ?? json;
    final catJson = Map<String, dynamic>.from(data['category'] ?? {});
    final itemsJson = (data['items'] as List? ?? []);
    final subsJson = (data['sub_categories'] as List? ?? []);
    return CategoryItemsResponse(
      category: CategoryLite(
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
          ItemLite.fromJson(Map<String, dynamic>.from(e), lang: lang))
          .toList(),
      subCategories: subsJson
          .whereType<Map>()
          .map((e) => SubCategoryLite.fromJson(Map<String, dynamic>.from(e),
          lang: lang))
          .toList(),
      totalItems: data['total_items'] ?? itemsJson.length,
      totalSubCategories: data['total_sub_categories'] ?? subsJson.length,
    );
  }
}

class SubCategoryItemsResponse {
  final SubCategoryLite subCategory;
  final List<ItemLite> items;
  final int totalItems;

  SubCategoryItemsResponse({
    required this.subCategory,
    required this.items,
    required this.totalItems,
  });

  factory SubCategoryItemsResponse.fromJson(Map<String, dynamic> json,
      {String lang = 'en'}) {
    final data = json['data'] ?? json;
    final subJson = Map<String, dynamic>.from(data['sub_category'] ?? {});
    final itemsJson = (data['items'] as List? ?? []);
    return SubCategoryItemsResponse(
      subCategory: SubCategoryLite(
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
          ItemLite.fromJson(Map<String, dynamic>.from(e), lang: lang))
          .toList(),
      totalItems: data['total_items'] ?? itemsJson.length,
    );
  }
}

class SearchItemResult {
  final int id;
  final String? word;
  final String? imageIcon;
  final String? speak;
  final String color;
  final int order;
  final int? categoryId;
  final String? categoryName;

  SearchItemResult({
    required this.id,
    this.word,
    this.imageIcon,
    this.speak,
    required this.color,
    required this.order,
    this.categoryId,
    this.categoryName,
  });

  factory SearchItemResult.fromJson(Map<String, dynamic> json,
      {String lang = 'en'}) {
    return SearchItemResult(
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

class SearchResponse {
  final String query;
  final List<SearchItemResult> items;
  final List<QuickSpeakModel> quickSpeaks;
  final int totalResults;

  SearchResponse({
    required this.query,
    required this.items,
    required this.quickSpeaks,
    required this.totalResults,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json,
      {String lang = 'en'}) {
    final data = json['data'] ?? json;
    return SearchResponse(
      query: data['search_query'] ?? '',
      items: (data['items'] as List? ?? [])
          .whereType<Map>()
          .map((e) => SearchItemResult.fromJson(Map<String, dynamic>.from(e),
          lang: lang))
          .toList(),
      quickSpeaks:
      (data['quickspeaks'] as List? ?? data['quick_speaks'] as List? ?? [])
          .whereType<Map>()
          .map((e) => QuickSpeakModel.fromJson(
          Map<String, dynamic>.from(e),
          lang: lang))
          .toList(),
      totalResults: data['total_results'] ?? 0,
    );
  }
}
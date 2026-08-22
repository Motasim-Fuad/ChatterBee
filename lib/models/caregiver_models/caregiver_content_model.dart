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

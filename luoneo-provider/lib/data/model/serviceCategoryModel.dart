class ServiceCategoryModel {
  ServiceCategoryModel({
    this.id,
    this.name,
    this.translatedName,
    this.slug,
    this.parentId,
    this.parentCategoryName,
    this.categoryImage,
  });

  ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString() ?? '';
    name = json['name']?.toString() ?? '';
    translatedName = json['translated_name']?.toString() ?? '';
    slug = json['slug']?.toString() ?? '';
    parentId = json['parent_id']?.toString() ?? '';
    parentCategoryName = json['parent_category_name']?.toString() ?? '';
    categoryImage = json['category_image']?.toString() ?? '';
  }
  String? id;
  String? name;
  String? translatedName;
  String? slug;
  String? parentId;
  String? parentCategoryName;
  String? categoryImage;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['translated_name'] = translatedName;
    data['slug'] = slug;
    data['parent_id'] = parentId;
    data['parent_category_name'] = parentCategoryName;
    data['category_image'] = categoryImage;
    return data;
  }
}

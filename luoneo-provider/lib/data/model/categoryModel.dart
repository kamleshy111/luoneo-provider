class CategoryModel {
  CategoryModel({
    this.id,
    this.name,
    this.translatedName,
    this.slug,
    this.parentId,
    this.parentCategoryName,
    this.categoryImage,
    this.adminCommission,
    this.status,
  });

  CategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString() ?? '';
    name = json['name']?.toString() ?? '';
    translatedName = (json['translated_name']?.toString() ?? '').isNotEmpty
        ? json['translated_name'].toString()
        : name;
    slug = json['slug']?.toString() ?? '';
    parentId = json['parent_id']?.toString() ?? '';
    parentCategoryName = json['parent_category_name']?.toString() ?? '';
    categoryImage = json['category_image']?.toString() ?? '';
    adminCommission = json['admin_commission']?.toString() ?? '';
    status = json['status']?.toString() ?? '';
  }
  String? id;
  String? name;
  String? translatedName;
  String? slug;
  String? parentId;
  String? parentCategoryName;
  String? categoryImage;
  String? adminCommission;
  String? status;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['translated_name'] = translatedName;
    data['slug'] = slug;
    data['parent_id'] = parentId;
    data['parent_category_name'] = parentCategoryName;
    data['category_image'] = categoryImage;
    data['admin_commission'] = adminCommission;
    data['status'] = status;
    return data;
  }
}

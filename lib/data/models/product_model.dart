import 'product_image_model.dart';
import 'product_variant_model.dart';

/// Modèle de produit
class ProductModel {
  final String id;
  final String name;
  final String? brandId;
  final String? categoryId;
  final String? description;
  final double price;
  final double? rating;
  final bool isNew;
  final bool isTop;
  final String? concentration;
  final String? season;
  final String? occasion;
  final String? topNotes;
  final String? heartNotes;
  final String? baseNotes;
  final DateTime? createdAt;
  
  // Relations (chargées séparément)
  List<ProductImageModel> images;
  List<ProductVariantModel> variants;
  
  ProductModel({
    required this.id,
    required this.name,
    this.brandId,
    this.categoryId,
    this.description,
    required this.price,
    this.rating,
    this.isNew = false,
    this.isTop = false,
    this.concentration,
    this.season,
    this.occasion,
    this.topNotes,
    this.heartNotes,
    this.baseNotes,
    this.createdAt,
    this.images = const [],
    this.variants = const [],
  });
  
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      brandId: json['brand_id'] as String?,
      categoryId: json['category_id'] as String?,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      isNew: json['is_new'] as bool? ?? false,
      isTop: json['is_top'] as bool? ?? false,
      concentration: json['concentration'] as String?,
      season: json['season'] as String?,
      occasion: json['occasion'] as String?,
      topNotes: json['top_notes'] as String?,
      heartNotes: json['heart_notes'] as String?,
      baseNotes: json['base_notes'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
      images: [],
      variants: [],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand_id': brandId,
      'category_id': categoryId,
      'description': description,
      'price': price,
      'rating': rating,
      'is_new': isNew,
      'is_top': isTop,
      'concentration': concentration,
      'season': season,
      'occasion': occasion,
      'top_notes': topNotes,
      'heart_notes': heartNotes,
      'base_notes': baseNotes,
      'created_at': createdAt?.toIso8601String(),
    };
  }
  
  /// Image de couverture
  ProductImageModel? get coverImage {
    return images.firstWhere(
      (img) => img.isCover,
      orElse: () => images.isNotEmpty ? images.first : ProductImageModel(
        id: '',
        productId: id,
        imageUrl: '',
        isCover: false,
      ),
    );
  }
  
  /// Prix minimum (avec variantes)
  double get minPrice {
    if (variants.isEmpty) return price;
    return variants
        .map((v) => v.getTotalPrice(price))
        .reduce((a, b) => a < b ? a : b);
  }
  
  /// Prix maximum (avec variantes)
  double get maxPrice {
    if (variants.isEmpty) return price;
    return variants
        .map((v) => v.getTotalPrice(price))
        .reduce((a, b) => a > b ? a : b);
  }
}

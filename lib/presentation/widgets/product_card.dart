import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/product_model.dart';
import '../../core/utils/price_formatter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/text_styles.dart';

/// Carte de produit réutilisable
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;
  
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onFavoriteTap,
    this.isFavorite = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final coverImage = product.coverImage;
    final imageUrl = coverImage?.imageUrl;
    
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du produit
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.backgroundCard,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.goldPrimary,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.backgroundCard,
                            child: Icon(
                              Icons.image_not_supported,
                              color: AppColors.textSecondary,
                              size: 32,
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.backgroundCard,
                          child: Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: AppColors.textSecondary,
                          ),
                        ),
                ),
                // Badge nouveau (discret)
                if (product.isNew)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundPrimary.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.goldPrimary,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'NOUVEAU',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: AppColors.goldPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                // Badge top vente (discret)
                if (product.isTop)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundPrimary.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.goldPrimary,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'TOP',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: AppColors.goldPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                // Bouton favori (gold discret)
                if (onFavoriteTap != null)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundPrimary.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? AppColors.goldPrimary : AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: onFavoriteTap,
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ),
              ],
            ),
            // Informations du produit
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.productTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (product.rating != null) ...[
                        Icon(
                          Icons.star,
                          size: 14,
                          color: AppColors.goldPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          product.rating!.toStringAsFixed(1),
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Text(
                          PriceFormatter.format(product.price),
                          style: AppTextStyles.priceSmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

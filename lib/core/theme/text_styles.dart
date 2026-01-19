import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';

/// Styles de texte personnalisés pour le design luxe
class AppTextStyles {
  // Titres produits (SemiBold)
  static TextStyle productTitle = GoogleFonts.playfairDisplay(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );
  
  // Prix (Bold + Gold)
  static TextStyle price = GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.goldPrimary,
    letterSpacing: 0.5,
  );
  
  static TextStyle priceSmall = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.goldPrimary,
    letterSpacing: 0.5,
  );
  
  // Description (Light)
  static TextStyle description = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w300,
    color: AppColors.textSecondary,
    height: 1.6,
  );
  
  // Boutons (Uppercase, LetterSpacing +1.2)
  static TextStyle button = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
  );
  
  // Section titles
  static TextStyle sectionTitle = GoogleFonts.playfairDisplay(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );
  
  // Labels
  static TextStyle label = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );
}

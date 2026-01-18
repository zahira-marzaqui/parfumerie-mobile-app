import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Utilitaire pour formater les prix
class PriceFormatter {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '${AppConstants.currencySymbol} ',
    decimalDigits: 2,
  );
  
  /// Formate un prix en MAD
  static String format(double price) {
    return _currencyFormat.format(price);
  }
  
  /// Formate un prix sans symbole
  static String formatWithoutSymbol(double price) {
    return NumberFormat('#,##0.00').format(price);
  }
}

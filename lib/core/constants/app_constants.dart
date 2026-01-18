/// Constantes de l'application
class AppConstants {
  // Devise
  static const String currency = 'MAD';
  static const String currencySymbol = 'DH';
  
  // Frais de livraison
  static const double standardShippingFee = 30.0;
  static const double expressShippingFee = 50.0;
  
  // Rôles utilisateur
  static const String roleClient = 'client';
  static const String roleAdmin = 'admin';
  
  // Statuts de commande
  static const String orderStatusPending = 'pending';
  static const String orderStatusPaid = 'paid';
  static const String orderStatusShipped = 'shipped';
  static const String orderStatusDelivered = 'delivered';
  static const String orderStatusCancelled = 'cancelled';
  
  // Modes de livraison
  static const String deliveryModeStandard = 'standard';
  static const String deliveryModeExpress = 'express';
  
  // Méthodes de paiement
  static const String paymentMethodCOD = 'COD'; // Cash on Delivery
  
  // Concentrations
  static const List<String> concentrations = [
    'EDT', // Eau de Toilette
    'EDP', // Eau de Parfum
    'Parfum',
  ];
  
  // Volumes courants
  static const List<int> commonVolumes = [50, 100, 150, 200];
  
  // Catégories
  static const List<String> categories = [
    'Homme',
    'Femme',
    'Unisexe',
    'Coffrets',
    'Marques',
  ];
}

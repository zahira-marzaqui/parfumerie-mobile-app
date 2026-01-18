import '../../core/constants/app_constants.dart';

/// Modèle de profil utilisateur
class UserProfileModel {
  final String id; // Même ID que auth.users.id
  final String? fullName;
  final String? phone;
  final String role;
  final DateTime? createdAt;
  
  UserProfileModel({
    required this.id,
    this.fullName,
    this.phone,
    this.role = AppConstants.roleClient,
    this.createdAt,
  });
  
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? AppConstants.roleClient,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'role': role,
      'created_at': createdAt?.toIso8601String(),
    };
  }
  
  bool get isAdmin => role == AppConstants.roleAdmin;
  bool get isClient => role == AppConstants.roleClient;
}

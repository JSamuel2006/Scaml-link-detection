class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String status;
  final int scanCount;
  final int loginCount;
  final String createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.scanCount,
    required this.loginCount,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        role: json['role'] ?? 'user',
        status: json['status'] ?? 'active',
        scanCount: json['scan_count'] ?? 0,
        loginCount: json['login_count'] ?? 0,
        createdAt: json['created_at'] ?? '',
      );
}

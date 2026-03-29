import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService extends ChangeNotifier {
  String? _role;
  String? _name;
  bool _isLoggedIn = false;

  String? get role => _role;
  String? get name => _name;
  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin => _role == 'admin';

  Future<void> init() async {
    final token = await StorageService.getToken();
    if (token != null) {
      _role = await StorageService.getRole();
      _name = await StorageService.getName();
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await ApiService.login({'email': email, 'password': password});
      final data = res.data as Map<String, dynamic>;
      await StorageService.saveToken(data['access_token']);
      await StorageService.saveRole(data['role']);
      await StorageService.saveName(data['name']);
      await StorageService.saveUserId(data['user_id']);
      _role = data['role'];
      _name = data['name'];
      _isLoggedIn = true;
      notifyListeners();
      return {'success': true, 'role': _role};
    } on DioException catch (e) {
      final msg = e.response?.data?['detail'] ?? 'Login failed';
      return {'success': false, 'message': msg};
    }
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      await ApiService.register({'name': name, 'email': email, 'password': password});
      return {'success': true};
    } on DioException catch (e) {
      final msg = e.response?.data?['detail'] ?? 'Registration failed';
      return {'success': false, 'message': msg};
    }
  }

  Future<void> logout() async {
    await StorageService.clearAll();
    _role = null;
    _name = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}

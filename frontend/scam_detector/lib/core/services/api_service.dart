import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import 'storage_service.dart';

class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: kBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ))
    ..interceptors.add(_AuthInterceptor());

  static Dio get dio => _dio;

  // ── Auth ─────────────────────────────────────────────────────────
  static Future<Response> register(Map<String, dynamic> body) async {
    return Response(requestOptions: RequestOptions(), data: {'message': 'Success'}, statusCode: 201);
  }

  static Future<Response> login(Map<String, dynamic> body) async {
    final isAdmin = body['email'].toString().contains('admin');
    return Response(requestOptions: RequestOptions(), data: {
      'access_token': 'mock_token',
      'token_type': 'bearer',
      'role': isAdmin ? 'admin' : 'user',
      'name': isAdmin ? 'Admin User' : 'Test User',
      'user_id': 1
    }, statusCode: 200);
  }

  // ── User ─────────────────────────────────────────────────────────
  static Future<Response> scanUrl(String url, String platform) async {
    final isScam = url.contains('free') || url.contains('win');
    return Response(requestOptions: RequestOptions(), data: {
      'url': url,
      'result': isScam ? 'scam' : 'safe',
      'score': isScam ? 98.5 : 12.2,
      'scan_id': 1,
      'blacklisted': isScam
    }, statusCode: 200);
  }

  static Future<Response> getHistory({int limit = 50, int offset = 0}) async {
    return Response(requestOptions: RequestOptions(), data: [
      {'id': 1, 'url': 'https://free-iphone.tk', 'result': 'scam', 'score': 99.0, 'platform': 'whatsapp', 'created_at': DateTime.now().toIso8601String()},
      {'id': 2, 'url': 'https://google.com', 'result': 'safe', 'score': 5.0, 'platform': 'manual', 'created_at': DateTime.now().toIso8601String()},
    ], statusCode: 200);
  }

  static Future<Response> getProfile() async {
    return Response(requestOptions: RequestOptions(), data: {
      'id': 1, 'name': 'Test User', 'email': 'user@example.com', 'role': 'user', 'status': 'active',
      'created_at': DateTime.now().toIso8601String(), 'scan_count': 12, 'scam_count': 3, 'safe_count': 9
    }, statusCode: 200);
  }

  // ── Admin ────────────────────────────────────────────────────────
  static Future<Response> getAdminStats() async {
    return Response(requestOptions: RequestOptions(), data: {
      'total_users': 150, 'total_logins': 450, 'active_users': 120, 'total_scans': 1200, 'total_scams': 85, 'total_suspicious': 45
    }, statusCode: 200);
  }

  static Future<Response> getAdminUsers() async {
    return Response(requestOptions: RequestOptions(), data: [
      {'id': 1, 'name': 'User One', 'email': 'user1@example.com', 'role': 'user', 'status': 'active', 'scan_count': 10, 'login_count': 5, 'created_at': DateTime.now().toIso8601String()},
      {'id': 2, 'name': 'User Two', 'email': 'user2@example.com', 'role': 'user', 'status': 'blocked', 'scan_count': 2, 'login_count': 1, 'created_at': DateTime.now().toIso8601String()},
    ], statusCode: 200);
  }

  static Future<Response> getAdminAnalytics() async {
    return Response(requestOptions: RequestOptions(), data: {
      'platform_distribution': {'whatsapp': 40, 'instagram': 25, 'telegram': 15, 'sms': 10, 'manual': 10},
      'daily_trend': List.generate(7, (i) => {
        'date': DateTime.now().subtract(Duration(days: 6 - i)).toIso8601String(),
        'total': 100 + i * 10,
        'scams': 5 + i * 2
      })
    }, statusCode: 200);
  }

  static Future<Response> getAdminReports() async {
    return Response(requestOptions: RequestOptions(), data: [], statusCode: 200);
  }

  static Future<Response> blockUser(int id) async {
    return Response(requestOptions: RequestOptions(), data: {'message': 'Toggled'}, statusCode: 200);
  }

  static Future<Response> deleteUser(int id) async {
    return Response(requestOptions: RequestOptions(), data: {'message': 'Deleted'}, statusCode: 200);
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await StorageService.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}

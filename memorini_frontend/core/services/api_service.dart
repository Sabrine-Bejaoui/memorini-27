import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api.dart';
import '../../models/product_model.dart';

class ApiService {
  static const _tokenKey = 'access_token';
  static const _userIdKey = 'user_id';
  static const _userNameKey = 'user_name';

  static Future<Map<String, String>> _buildHeaders({bool withAuth = false}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (withAuth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Map<String, dynamic> _decodeBody(http.Response response) {
    if (response.body.isEmpty) {
      return <String, dynamic>{};
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return {'data': decoded};
  }

  static void _ensureSuccess(http.Response response, {String action = 'requête'}) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      try {
        final body = _decodeBody(response);
        throw Exception(body['detail']?.toString() ?? 'Erreur API pendant $action');
      } catch (_) {
        throw Exception('Erreur API (${response.statusCode}) pendant $action');
      }
    }
  }

  static Future<void> _storeAuth(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = data['access_token']?.toString();
    final user = data['user'] as Map<String, dynamic>?;
    if (token != null) {
      await prefs.setString(_tokenKey, token);
    }
    if (user != null) {
      final userId = user['id'];
      if (userId is int) {
        await prefs.setInt(_userIdKey, userId);
      }
      final userName = user['full_name']?.toString();
      if (userName != null) {
        await prefs.setString(_userNameKey, userName);
      }
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
  }

  static Future<List<ProductModel>> getProducts() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/products'),
    );

    _ensureSuccess(response, action: 'chargement produits');
    final List data = jsonDecode(response.body) as List;
    return data.map((item) => ProductModel.fromJson(item)).toList();
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login'),
      headers: await _buildHeaders(),
      body: jsonEncode({'email': email, 'password': password}),
    );

    _ensureSuccess(response, action: 'connexion');
    final data = _decodeBody(response);
    await _storeAuth(data);
    return data;
  }

  static Future<Map<String, dynamic>> register(
    String fullName,
    String email,
    String password, {
    String? phone,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/register'),
      headers: await _buildHeaders(),
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'password': password,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      }),
    );

    _ensureSuccess(response, action: 'inscription');
    return _decodeBody(response);
  }

  static Future<Map<String, dynamic>> createOrder({
    required String fullName,
    required String address,
    required String city,
    required String phone1,
    String? phone2,
    required double totalPrice,
    required List<Map<String, dynamic>> items,
  }) async {
    final userId = await getUserId();
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/orders'),
      headers: await _buildHeaders(withAuth: true),
      body: jsonEncode({
        'user_id': userId,
        'full_name': fullName,
        'address': address,
        'city': city,
        'phone1': phone1,
        if (phone2 != null && phone2.isNotEmpty) 'phone2': phone2,
        'total_price': totalPrice,
        'items': jsonEncode(items),
      }),
    );

    _ensureSuccess(response, action: 'création commande');
    return _decodeBody(response);
  }

  static Future<List<Map<String, dynamic>>> getMyOrders() async {
    final userId = await getUserId();
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/orders/my-orders/$userId'),
      headers: await _buildHeaders(withAuth: true),
    );
    _ensureSuccess(response, action: 'chargement commandes');
    final data = jsonDecode(response.body) as List;
    return data.cast<Map<String, dynamic>>();
  }

  static Future<Map<String, dynamic>> createPayment({
    required int orderId,
    required double amount,
    String method = 'cash_on_delivery',
  }) async {
    final userId = await getUserId();
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/payments'),
      headers: await _buildHeaders(withAuth: true),
      body: jsonEncode({
        'order_id': orderId,
        'user_id': userId,
        'amount': amount,
        'method': method,
      }),
    );
    _ensureSuccess(response, action: 'création paiement');
    return _decodeBody(response);
  }
}
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/product_model.dart';
import '../constants/api.dart';

class ApiService {
  static const _tokenKey = 'access_token';
  static const _userIdKey = 'user_id';
  static const _userNameKey = 'user_name';
  static const _userRoleKey = 'user_role';
  static final ValueNotifier<int> authStateVersion = ValueNotifier<int>(0);

  static void _notifyAuthStateChanged() {
    authStateVersion.value = authStateVersion.value + 1;
  }

  static Future<Map<String, String>> _buildHeaders({
    bool withAuth = false,
  }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (withAuth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static dynamic _decodeRaw(http.Response response) {
    if (response.body.isEmpty) return {};
    return jsonDecode(response.body);
  }

  static Map<String, dynamic> _decodeMap(http.Response response) {
    final decoded = _decodeRaw(response);
    if (decoded is Map<String, dynamic>) {
      if (decoded.containsKey('success') && decoded.containsKey('data')) {
        final data = decoded['data'];
        if (data is Map<String, dynamic>) return data;
        return {'data': data};
      }
      return decoded;
    }
    return {'data': decoded};
  }

  static void _ensureSuccess(http.Response response, {required String action}) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    final decoded = _decodeRaw(response);
    if (decoded is Map<String, dynamic> && decoded['detail'] != null) {
      throw Exception(decoded['detail'].toString());
    }
    throw Exception('Erreur API (${response.statusCode}) pendant $action');
  }

  static Future<void> _storeAuth(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = data['access_token']?.toString();
    final user = data['user'] as Map<String, dynamic>?;
    if (token != null) await prefs.setString(_tokenKey, token);
    if (user != null) {
      if (user['id'] is int) await prefs.setInt(_userIdKey, user['id'] as int);
      if (user['full_name'] != null) {
        await prefs.setString(_userNameKey, user['full_name'].toString());
      }
      if (user['role'] != null) {
        await prefs.setString(_userRoleKey, user['role'].toString());
      }
    }
    _notifyAuthStateChanged();
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

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  static Future<bool> isAdmin() async {
    final role = await getUserRole();
    return role == 'admin';
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userRoleKey);
    _notifyAuthStateChanged();
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login'),
      headers: await _buildHeaders(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    _ensureSuccess(response, action: 'connexion');
    final data = _decodeMap(response);
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
    return _decodeMap(response);
  }

  static Future<Map<String, dynamic>> createAdmin({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/users/admins'),
      headers: await _buildHeaders(withAuth: true),
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'password': password,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      }),
    );
    _ensureSuccess(response, action: 'création admin');
    return _decodeMap(response);
  }

  static Future<List<ProductModel>> getProducts() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/products'),
      headers: await _buildHeaders(withAuth: true),
    );
    _ensureSuccess(response, action: 'chargement des produits');
    final decoded = _decodeRaw(response);
    List rawList = [];
    if (decoded is Map<String, dynamic> &&
        decoded.containsKey('success') &&
        decoded.containsKey('data')) {
      if (decoded['data'] is List) {
        rawList = decoded['data'];
      }
    } else if (decoded is List) {
      rawList = decoded;
    }
    return rawList
        .whereType<Map<String, dynamic>>()
        .map(ProductModel.fromJson)
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getMyOrders() async {
    final userId = await getUserId();
    if (userId == null) throw Exception('Utilisateur non connecté');
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/orders/my-orders/$userId'),
      headers: await _buildHeaders(withAuth: true),
    );
    _ensureSuccess(response, action: 'chargement commandes');
    final decoded = _decodeRaw(response);
    List rawList = [];
    if (decoded is Map<String, dynamic> &&
        decoded.containsKey('data') &&
        decoded['data'] is List) {
      rawList = decoded['data'];
    } else if (decoded is List) {
      rawList = decoded;
    }
    return rawList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Future<List<Map<String, dynamic>>> getAllOrders() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/orders'),
      headers: await _buildHeaders(withAuth: true),
    );
    _ensureSuccess(response, action: 'chargement des commandes admin');
    final decoded = _decodeRaw(response);
    List rawList = [];
    if (decoded is Map<String, dynamic> &&
        decoded.containsKey('data') &&
        decoded['data'] is List) {
      rawList = decoded['data'];
    } else if (decoded is List) {
      rawList = decoded;
    }
    return rawList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Future<Map<String, dynamic>> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/orders/$orderId/status?status=$status'),
      headers: await _buildHeaders(withAuth: true),
    );
    _ensureSuccess(response, action: 'mise à jour du statut de commande');
    return _decodeMap(response);
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
    if (userId == null) throw Exception('Utilisateur non connecté');
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
    _ensureSuccess(response, action: 'création de commande');
    return _decodeMap(response);
  }

  static Future<Map<String, dynamic>> createPayment({
    required int orderId,
    required double amount,
    String method = 'cash_on_delivery',
  }) async {
    final userId = await getUserId();
    if (userId == null) throw Exception('Utilisateur non connecté');
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
    return _decodeMap(response);
  }

  static Future<ProductModel> createProduct({
    required String name,
    required String category,
    required String description,
    required double price,
    required String mainImage,
    String? images,
    String stockMode = 'none',
    int? stock,
    List<Map<String, dynamic>>? variantStock,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/products'),
      headers: await _buildHeaders(withAuth: true),
      body: jsonEncode({
        'name': name,
        'category': category,
        'description': description,
        'price': price,
        'main_image': mainImage,
        if (images != null && images.isNotEmpty) 'images': images,
        'stock_mode': stockMode,
        if (stock != null) 'stock': stock,
        if (variantStock != null) 'variant_stock': variantStock,
      }),
    );
    _ensureSuccess(response, action: 'création de produit');
    return ProductModel.fromJson(_decodeMap(response));
  }

  static Future<ProductModel> updateProduct({
    required int productId,
    required String name,
    required String category,
    required String description,
    required double price,
    required String mainImage,
    String? images,
    String? stockMode,
    int? stock,
    List<Map<String, dynamic>>? variantStock,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/products/$productId'),
      headers: await _buildHeaders(withAuth: true),
      body: jsonEncode({
        'name': name,
        'category': category,
        'description': description,
        'price': price,
        'main_image': mainImage,
        ...?(images == null ? null : {'images': images}),
        ...?(stockMode == null ? null : {'stock_mode': stockMode}),
        ...?(stock == null ? null : {'stock': stock}),
        ...?(variantStock == null ? null : {'variant_stock': variantStock}),
      }),
    );
    _ensureSuccess(response, action: 'mise à jour de produit');
    return ProductModel.fromJson(_decodeMap(response));
  }

  static Future<void> deleteProduct(int productId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/products/$productId'),
      headers: await _buildHeaders(withAuth: true),
    );
    _ensureSuccess(response, action: 'suppression de produit');
  }

  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/users'),
      headers: await _buildHeaders(withAuth: true),
    );
    _ensureSuccess(response, action: 'chargement utilisateurs');
    final decoded = _decodeRaw(response);
    List rawList = [];
    if (decoded is Map<String, dynamic> &&
        decoded.containsKey('data') &&
        decoded['data'] is List) {
      rawList = decoded['data'];
    } else if (decoded is List) {
      rawList = decoded;
    }
    return rawList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Future<Map<String, dynamic>> updateUserRole({
    required int userId,
    required String role,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/users/$userId/role'),
      headers: await _buildHeaders(withAuth: true),
      body: jsonEncode({'role': role}),
    );
    _ensureSuccess(response, action: 'mise à jour rôle utilisateur');
    return _decodeMap(response);
  }

  static Future<Map<String, dynamic>> updateUserStatus({
    required int userId,
    required bool isActive,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/users/$userId/status'),
      headers: await _buildHeaders(withAuth: true),
      body: jsonEncode({'is_active': isActive}),
    );
    _ensureSuccess(response, action: 'mise à jour statut utilisateur');
    return _decodeMap(response);
  }

  static Future<Map<String, dynamic>> updateUser({
    required int userId,
    String? fullName,
    String? email,
    String? phone,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/users/$userId'),
      headers: await _buildHeaders(withAuth: true),
      body: jsonEncode({
        if (fullName != null) 'full_name': fullName,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
      }),
    );
    _ensureSuccess(response, action: 'mise à jour utilisateur');
    if (fullName != null && fullName.trim().isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userNameKey, fullName.trim());
      _notifyAuthStateChanged();
    }
    return _decodeMap(response);
  }

  static Future<void> deleteUser(int userId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/users/$userId'),
      headers: await _buildHeaders(withAuth: true),
    );
    _ensureSuccess(response, action: 'suppression utilisateur');
  }

  static Future<void> deleteOrder(int orderId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/orders/$orderId'),
      headers: await _buildHeaders(withAuth: true),
    );
    _ensureSuccess(response, action: 'suppression commande');
  }
}

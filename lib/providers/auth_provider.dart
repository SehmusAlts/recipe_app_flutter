import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/mysql_service.dart';

class AuthProvider with ChangeNotifier {
  final MySqlService _mysqlService = MySqlService();
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId != null) {
      // User bilgilerini veritabanından yükle
      // Şimdilik sadece ID'yi saklıyoruz
    }
  }

  Future<void> _saveUserToStorage(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', user.id);
    await prefs.setString('username', user.username);
    await prefs.setString('email', user.email);
  }

  Future<void> _clearUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('username');
    await prefs.remove('email');
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    String? fullName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _mysqlService.connect();
      final user = await _mysqlService.register(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
      );

      if (user != null) {
        _currentUser = user;
        await _saveUserToStorage(user);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> login(String usernameOrEmail, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _mysqlService.connect();
      final user = await _mysqlService.login(usernameOrEmail, password);

      if (user != null) {
        _currentUser = user;
        await _saveUserToStorage(user);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await _clearUserFromStorage();
    await _mysqlService.close();
    notifyListeners();
  }
}


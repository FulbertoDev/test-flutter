import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/order.dart';
import '../services/mock_api_service.dart';

class AuthProvider extends ChangeNotifier {
  final MockApiService _apiService = MockApiService();

  User? _currentUser;
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    loadUser();
  }

  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _apiService.getCurrentUser();
      if (_currentUser != null) {
        await loadOrders();
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOrders() async {
    try {
      _orders = await _apiService.getOrders();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    _orders = [];
    notifyListeners();
  }
}

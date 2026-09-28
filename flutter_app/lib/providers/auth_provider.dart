import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final StorageService _storageService;

  bool _isAuthenticated = false;
  String? _inspectorId;
  String? _inspectorName;

  bool get isAuthenticated => _isAuthenticated;
  String? get inspectorId => _inspectorId;
  String? get inspectorName => _inspectorName;

  AuthProvider(this._storageService) {
    _loadSession();
  }

  void _loadSession() {
    _inspectorId = _storageService.getSavedInspectorId();
    _inspectorName = _storageService.getSavedInspectorName();
    _isAuthenticated = _inspectorId != null && _inspectorId!.isNotEmpty;
    notifyListeners();
  }

  Future<void> login(String inspectorId, String inspectorName) async {
    await _storageService.saveInspectorProfile(inspectorId, inspectorName);
    _inspectorId = inspectorId;
    _inspectorName = inspectorName;
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await _storageService.saveInspectorProfile('', '');
    await _storageService.clearAuthToken();
    _inspectorId = null;
    _inspectorName = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}

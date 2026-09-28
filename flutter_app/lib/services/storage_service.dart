import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  static const String batchesBoxName = 'onion_batches_box';
  static const String inspectionsBoxName = 'onion_inspections_box';
  static const String pendingSyncBoxName = 'pending_sync_box';
  static const String pendingAiQueueBoxName = 'pending_ai_queue_box';

  static const String prefBaseUrlKey = 'pref_api_base_url';
  static const String prefLanguageKey = 'pref_app_language';
  static const String prefInspectorIdKey = 'pref_inspector_id';
  static const String prefInspectorNameKey = 'pref_inspector_name';

  static const String defaultApiUrl = 'http://10.0.2.2:8000'; // Standard Android emulator localhost

  late Box<String> _batchesBox;
  late Box<String> _inspectionsBox;
  late Box<String> _pendingSyncBox;
  late Box<String> _pendingAiQueueBox;
  late SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> init() async {
    await Hive.initFlutter();
    _batchesBox = await Hive.openBox<String>(batchesBoxName);
    _inspectionsBox = await Hive.openBox<String>(inspectionsBoxName);
    _pendingSyncBox = await Hive.openBox<String>(pendingSyncBoxName);
    _pendingAiQueueBox = await Hive.openBox<String>(pendingAiQueueBoxName);
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Batches ---
  List<OnionBatch> getAllBatches() {
    return _batchesBox.values.map((raw) {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return OnionBatch.fromJson(json);
    }).toList();
  }

  Future<void> saveBatch(OnionBatch batch) async {
    await _batchesBox.put(batch.id, jsonEncode(batch.toJson()));
  }

  Future<void> deleteBatch(String batchId) async {
    await _batchesBox.delete(batchId);
  }

  // --- Inspections ---
  List<OnionInspection> getAllInspections() {
    return _inspectionsBox.values.map((raw) {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return OnionInspection.fromJson(json);
    }).toList();
  }

  Future<void> saveInspection(OnionInspection inspection) async {
    await _inspectionsBox.put(inspection.id, jsonEncode(inspection.toJson()));
  }

  // --- Pending Sync Queue (Offline-first data replication) ---
  List<Map<String, dynamic>> getPendingSyncItems() {
    return _pendingSyncBox.values.map((raw) {
      return jsonDecode(raw) as Map<String, dynamic>;
    }).toList();
  }

  Future<void> queuePendingSync({
    required String entityType, // 'batch' | 'inspection'
    required String entityId,
    required Map<String, dynamic> payload,
  }) async {
    final item = {
      'sync_id': '${entityType}_$entityId',
      'entity_type': entityType,
      'entity_id': entityId,
      'payload': payload,
      'queued_at': DateTime.now().toIso8601String(),
    };
    await _pendingSyncBox.put('${entityType}_$entityId', jsonEncode(item));
  }

  Future<void> removePendingSync(String syncId) async {
    await _pendingSyncBox.delete(syncId);
  }

  // --- Pending AI Analysis Queue (Offline heap capture) ---
  List<Map<String, dynamic>> getPendingAiQueue() {
    return _pendingAiQueueBox.values.map((raw) {
      return jsonDecode(raw) as Map<String, dynamic>;
    }).toList();
  }

  Future<void> queueAiAnalysis({
    required String queueId,
    required String imageFilePath,
    required String batchId,
    required double sampleWeightKg,
  }) async {
    final item = {
      'queue_id': queueId,
      'image_path': imageFilePath,
      'batch_id': batchId,
      'sample_weight_kg': sampleWeightKg,
      'created_at': DateTime.now().toIso8601String(),
    };
    await _pendingAiQueueBox.put(queueId, jsonEncode(item));
  }

  Future<void> removePendingAi(String queueId) async {
    await _pendingAiQueueBox.delete(queueId);
  }

  // --- Settings & SharedPreferences ---
  String getApiBaseUrl() {
    return _prefs.getString(prefBaseUrlKey) ?? defaultApiUrl;
  }

  Future<void> setApiBaseUrl(String url) async {
    await _prefs.setString(prefBaseUrlKey, url.trim());
  }

  String getSelectedLanguage() {
    return _prefs.getString(prefLanguageKey) ?? 'en';
  }

  Future<void> setSelectedLanguage(String langCode) async {
    await _prefs.setString(prefLanguageKey, langCode);
  }

  String? getSavedInspectorId() => _prefs.getString(prefInspectorIdKey);
  String? getSavedInspectorName() => _prefs.getString(prefInspectorNameKey);

  Future<void> saveInspectorProfile(String id, String name) async {
    await _prefs.setString(prefInspectorIdKey, id);
    await _prefs.setString(prefInspectorNameKey, name);
  }

  // Secure Token storage
  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(key: 'auth_jwt_token', value: token);
  }

  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: 'auth_jwt_token');
  }

  Future<void> clearAuthToken() async {
    await _secureStorage.delete(key: 'auth_jwt_token');
  }
}

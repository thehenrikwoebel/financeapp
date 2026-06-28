import 'package:flutter/foundation.dart';
import 'package:frontend/repositories/database_repository.dart';
import 'package:frontend/repositories/local_web_database_repository.dart';
import 'package:frontend/repositories/local_mobile_database_repository.dart';
import 'package:frontend/services/api_service.dart';
import 'package:material_symbols_icons/symbols.dart';

class RepositoryProvider {
  static DatabaseRepository? _instance;
  static bool _isWeb = false;
  static bool _isMobileWithLocalDB = false;

  static bool get _isMobile =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  static Future<void> initialize() async {
    if (_isWeb) {
      final repo = LocalWebDatabaseRepository();
      repo.addNewCategory("Sample Category", Symbols.question_mark);
      await repo.db;
      _instance = repo;
    } else if (_isMobile && _isMobileWithLocalDB) {
      final repo = LocalMobileDatabaseRepository();
      await repo.db;
      _instance = repo;
    } else {
      _instance = ApiService();
    }
  }

  static DatabaseRepository get instance {
    if (_instance != null) return _instance!;
    if (_isWeb) return _instance = LocalWebDatabaseRepository();
    if (_isMobile && _isMobileWithLocalDB)
      return _instance = LocalMobileDatabaseRepository();
    return _instance = ApiService();
  }

  static void setLocalMode(bool local) {
    _isWeb = local;
    _instance = null;
  }

  static void setMobileLocalMode(bool local) {
    _isMobileWithLocalDB = local;
    _instance = null;
  }
}

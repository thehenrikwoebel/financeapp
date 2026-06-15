import 'package:frontend/repositories/database_repository.dart';
import 'package:frontend/repositories/local_web_database_repository.dart';
import 'package:frontend/services/api_service.dart';

class RepositoryProvider {
  static DatabaseRepository? _instance;
  static bool _isLocal = false;

  static Future<void> initialize() async {
    if (_isLocal) {
      final repo = LocalWebDatabaseRepository();
      await repo.db;
      _instance = repo;
    } else {
      _instance = ApiService();
    }
  }

  static DatabaseRepository get instance {
    _instance ??= _isLocal ? LocalWebDatabaseRepository() : ApiService();
    return _instance!;
  }

  static void setLocalMode(bool local) {
    _isLocal = local;
    _instance = null; // new init
  }
}

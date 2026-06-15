import 'package:frontend/models/category.dart';
import 'package:frontend/models/expense.dart';
import 'package:frontend/models/monthlyBalance.dart';

class CacheEntry<T> {
  T? value;
  DateTime? _lastFetched;
  final Duration ttl;

  CacheEntry({this.ttl = const Duration(minutes: 5)});

  bool get isValid =>
      value != null &&
      _lastFetched != null &&
      DateTime.now().difference(_lastFetched!) < ttl;

  void update(T val) {
    value = val;
    _lastFetched = DateTime.now();
  }

  void invalidate() {
    value = null;
    _lastFetched = null;
  }
}

class AppCache {
  // singleton pattern
  static final AppCache _instance = AppCache._internal();
  factory AppCache() => _instance;
  AppCache._internal();

  final expenses = CacheEntry<List<Expense>>();
  final monthlyBalance =
      CacheEntry<MonthlyBalance>(); // current value for home screen
  final monthlyBalances =
      CacheEntry<List<MonthlyBalance>>(); // list for statistics screen
  final categories = CacheEntry<List<Category>>();
}

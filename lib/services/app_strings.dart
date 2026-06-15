import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStrings extends ChangeNotifier {
  static final AppStrings _instance = AppStrings._internal();
  factory AppStrings() => _instance;
  AppStrings._internal();

  static const _de = {
    'title': 'Finanzen',
    'date': 'Datum',
    'name': 'Name',
    'amount': 'Betrag',
    'search': 'Suchen...',
    'category': 'Kategorie',
    'new_category': 'Neue Kategorie',
    'categories': 'Kategorien',
    'all_categories': 'Alle Kategorien',
    'bilances': 'Bilanzen',
    'bilance': 'Bilanz',
    'expenses': 'Ausgaben',
    'statistic': 'Statistik',
    'new_expense': 'Neue Ausgabe',
    'delete': 'Löschen',
    'save': 'Speichern',
    'error': 'Fehler',
    'abort': 'Abbrechen',
    'select_icon': 'Icon auswählen',
    'selected': 'ausgewählt',
    'currency_symbol': '€',
    'confirm_delete_text':
        'Möchtest du diese Einträge wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.',
    'choose_date': 'Datum wählen',
    'date_format': 'dd.MM.yyyy',
    'more_button_text': 'mehr',
    'no_data': 'Keine Daten vorhanden',
    'january': 'Januar',
    'february': 'Februar',
    'march': 'März',
    'april': 'April',
    'may': 'Mai',
    'june': 'Juni',
    'july': 'Juli',
    'august': 'August',
    'september': 'September',
    'october': 'Oktober',
    'november': 'November',
    'december': 'Dezember',
    'jan': 'Jan',
    'feb': 'Feb',
    'mar': 'Mär',
    'apr': 'Apr',
    'may_short': 'Mai',
    'jun': 'Jun',
    'jul': 'Jul',
    'aug': 'Aug',
    'sep': 'Sep',
    'oct': 'Okt',
    'nov': 'Nov',
    'dec': 'Dez',
    'select_language': 'Wähle eine Sprache',
    'settings': 'Einstellungen',
    'confirm_delete_title': 'Einträge löschen?',
  };

  static const _en = {
    // us english
    'title': 'Finances',
    'date': 'Date',
    'name': 'Name',
    'amount': 'Amount',
    'search': 'Search...',
    'category': 'Category',
    'categories': 'Categories',
    'new_category': 'New category',
    'all_categories': 'All categories',
    'bilances': 'Bilances',
    'bilance': 'Bilance',
    'expenses': 'Expenses',
    'statistic': 'Statistic',
    'new_expense': 'New expense',
    'delete': 'Delete',
    'save': 'Save',
    'error': 'Error',
    'abort': 'Cancel',
    'select_icon': 'Select icon',
    'selected': 'selected',
    'currency_symbol': '\$',
    'confirm_delete_text':
        'Are you sure you want to delete these entries? This action cannot be undone.',
    'choose_date': 'Choose date',
    'date_format': 'MM/dd/yyyy',
    'more_button_text': 'more',
    'no_data': 'No data',
    'january': 'January',
    'february': 'February',
    'march': 'March',
    'april': 'April',
    'may': 'May',
    'june': 'June',
    'july': 'July',
    'august': 'August',
    'september': 'September',
    'october': 'October',
    'november': 'November',
    'december': 'December',
    'jan': 'Jan',
    'feb': 'Feb',
    'mar': 'Mar',
    'apr': 'Apr',
    'may_short': 'May',
    'jun': 'Jun',
    'jul': 'Jul',
    'aug': 'Aug',
    'sep': 'Sep',
    'oct': 'Oct',
    'nov': 'Nov',
    'dec': 'Dec',
    'select_language': 'Select a language',
    'settings': 'Settings',
    'confirm_delete_title': 'Delete entries?',
  };

  static const languageToShorthand = {'German': 'de', 'English': 'en'};

  static Map<String, String> _current = _en;
  static String currentLanguage = "en";

  static Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('language') ?? 'en';
    setLanguage(saved);
  }

  static Future<void> setLanguage(String lang) async {
    _current = lang == 'en' ? _en : _de;
    currentLanguage = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    _instance.notifyListeners();
  }

  static String get(String key) => _current[key] ?? key;
}

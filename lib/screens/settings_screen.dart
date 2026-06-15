import 'package:flutter/material.dart';
import 'package:frontend/services/app_strings.dart';
import 'package:frontend/widgets/app_bar_top.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const List<String> languages = ["German", "English"];

  String get _selectedLanguage => AppStrings.languageToShorthand.entries
      .firstWhere((e) => e.value == AppStrings.currentLanguage)
      .key;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarTop(
        onRefresh: _reload,
        showSearch: false,
        isSearching: false,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppStrings.get('select_language')),
                  SizedBox(width: 30),
                  DropdownButton<String>(
                    value: _selectedLanguage,
                    items: languages
                        .map(
                          (lang) =>
                              DropdownMenuItem(value: lang, child: Text(lang)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setLanguage(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void setLanguage(String value) {
    AppStrings.setLanguage(AppStrings.languageToShorthand[value]!);
    setState(() {}); // reload screen
  }

  void _reload() {
    print("TODO");
  }
}

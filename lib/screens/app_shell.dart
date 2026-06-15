import 'package:flutter/material.dart';
import 'package:frontend/screens/categories_screen.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/settings_screen.dart';
import 'package:frontend/screens/statistics_screen.dart';
import 'package:frontend/services/app_strings.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const StatisticsScreen(),
    const CategoriesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStrings(),
      builder: (context, _) {
        return Scaffold(
          body: _pages[_selectedIndex],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) =>
                setState(() => _selectedIndex = index),
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.list_outlined),
                selectedIcon: Icon(Icons.list),
                label: AppStrings.get('expenses'),
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart),
                label: AppStrings.get('statistic'),
              ),
              NavigationDestination(
                icon: Icon(Icons.category_outlined),
                selectedIcon: Icon(Icons.category),
                label: AppStrings.get('categories'),
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: AppStrings.get('settings'),
              ),
            ],
          ),
        );
      },
    );
  }
}

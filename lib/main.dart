import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/repositories/repository_provider.dart';
import 'package:frontend/services/app_strings.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStrings.loadLanguage();
  RepositoryProvider.setLocalMode(kIsWeb);
  RepositoryProvider.setMobileLocalMode(true);
  await RepositoryProvider.initialize();
  runApp(const MyApp());
}

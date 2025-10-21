import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Core imports
import 'core/themes/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'services/storage_service.dart';

// Feature imports
import 'features/auth/providers/auth_provider.dart';
import 'features/mood/providers/mood_provider.dart';
import 'features/tools/providers/tools_provider.dart';
import 'features/ai_assistant/providers/ai_provider.dart';
import 'features/therapy/providers/therapy_provider.dart';

// Screen imports
import 'features/auth/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final prefs = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage();
  final storageService = StorageService(prefs, secureStorage);

  runApp(SakinaApp(storageService: storageService));
}

class SakinaApp extends StatelessWidget {
  final StorageService storageService;

  const SakinaApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (context) => MoodProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (context) => ToolsProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => AIAssistantProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => TherapyProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'سكينة',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ar', 'SA'),
          Locale('en', 'US'),
        ],
        home: const SplashScreen(),
      ),
    );
  }
}

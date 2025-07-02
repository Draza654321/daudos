import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/database_service.dart';
import 'services/firebase_service.dart';
import 'services/sync_service.dart';
import 'viewmodels/dashboard_viewmodel.dart';
import 'viewmodels/mood_viewmodel.dart';
import 'viewmodels/task_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'viewmodels/analytics_viewmodel.dart';
import 'views/splash_screen.dart';
import 'views/main_navigation.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize services
  await DatabaseService().database;
  await FirebaseService().initialize();
  await SyncService().initialize();
  
  runApp(DaudOSApp());
}

class DaudOSApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => MoodViewModel()),
        ChangeNotifierProvider(create: (_) => TaskViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => AnalyticsViewModel()),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settingsViewModel, child) {
          return MaterialApp(
            title: 'DaudOS',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getTheme(settingsViewModel.currentUIMode),
            home: SplashScreen(),
            routes: {
              '/main': (context) => MainNavigation(),
            },
          );
        },
      ),
    );
  }
}


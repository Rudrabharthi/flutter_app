import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

// Providers
import './providers/authentication_provider.dart';

// Services
import './services/navigation_service.dart';
import './services/media_service.dart';
import './services/database_service.dart';
import './services/cloud_storage_service.dart';

// Pages
import './pages/login_page.dart';
import './pages/register_page.dart';
import './pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Initialize Firebase ONLY ONCE, ignore duplicate-app error
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') {
      rethrow;
    }
  }

  _setupServices();
  runApp(const MyApp());
}

void _setupServices() {
  GetIt.I.registerSingleton<NavigationService>(NavigationService());
  GetIt.I.registerSingleton<MediaService>(MediaService());
  GetIt.I.registerSingleton<DatabaseService>(DatabaseService());
  GetIt.I.registerSingleton<CloudStorageService>(CloudStorageService());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late FirebaseAnalytics analytics;

  @override
  void initState() {
    super.initState();
    analytics = FirebaseAnalytics.instance;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthenticationProvider>(
          create: (_) => AuthenticationProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Chatify',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: const Color.fromARGB(255, 50, 48, 75),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color.fromRGBO(30, 29, 37, 1.0),
          ),
        ),
        navigatorKey: NavigationService.navigatorKey,
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginPage(),
          '/register': (context) => RegisterPage(),
          '/home': (context) => HomePage(),
        },
      ),
    );
  }
}

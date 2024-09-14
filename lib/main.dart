import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

import 'screen/splash_screen.dart';
import 'services/app_service.dart';
import 'theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  AppService activeChangeProvider = AppService();

  @override
  void initState() {
    getCurrentActive();
    super.initState();
  }

  void getCurrentActive() async {
    activeChangeProvider.setIsOpenActive = await activeChangeProvider.activePrefs.getActive();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => activeChangeProvider,
      child: MaterialApp(
        title: 'CourtFinder',
        theme: lightMode,
        darkTheme: darkMode,
        home: const SplashScreen(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'services/data_service.dart';
import 'services/local_data_service.dart';
import 'screens/shared/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // This gives the whole app access to our DataService
        Provider<DataService>(
          create: (_) => LocalDataService(),
        ),
      ],
      child: const FarmLinkApp(),
    ),
  );
}

class FarmLinkApp extends StatelessWidget {
  const FarmLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FarmLink',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const SplashScreen(),
    );
  }
}
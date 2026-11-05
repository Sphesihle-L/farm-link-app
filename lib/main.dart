import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // <-- NEW
import 'firebase_options.dart'; // <-- NEW
import 'theme.dart';
import 'services/data_service.dart';
import 'services/firebase_data_service.dart'; 
import 'screens/shared/splash_screen.dart';

Future<void> main() async {
  // 1. Ensure Flutter is ready
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Initialize Firebase with the options we just generated
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<DataService>(
          create: (_) => FirebaseDataService(), // We are still using local for now
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
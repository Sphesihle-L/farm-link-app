import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../services/data_service.dart';
import '../auth/login_screen.dart';
import '../worker/worker_dashboard.dart';
import '../farmer/farmer_dashboard.dart';
import '../../models/app_user.dart'; // Needed for UserRole

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // 1. Wait for 2 seconds (2000 milliseconds) so the user sees the logo
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    // 2. Check if a user is already logged in
    final dataService = Provider.of<DataService>(context, listen: false);
    final currentUser = await dataService.getCurrentUser();

    if (!mounted) return;

    // 3. Navigate based on login status
        if (currentUser != null) {
      // User is logged in! Send them to the correct dashboard based on their role.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => currentUser.role == UserRole.farmer
              ? const FarmerDashboard()
              : const WorkerDashboard(),
        ),
      );
    } else {
      // User is not logged in. Go to Login Screen.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary, // Dark forest green
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.agriculture,
              size: 100,
              color: AppColors.vibrantGreen,
            ),
            SizedBox(height: 24),
            Text(
              'FarmLink',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../services/data_service.dart';
import '../../models/app_user.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';
import '../worker/worker_skills_screen.dart';
import '../worker/worker_availability_screen.dart';
import '../worker/worker_preferences_screen.dart';
import '../farmer/farmer_location_screen.dart';
import '../farmer/farmer_job_preferences_screen.dart'; // <-- New Import
import '../farmer/about_farm_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AppUser? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = await Provider.of<DataService>(
      context,
      listen: false,
    ).getCurrentUser();
    if (user != null) {
      setState(() {
        _user = user;
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await Provider.of<DataService>(context, listen: false).signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final isWorker = _user!.role == UserRole.worker;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.agriculture,
                          color: AppColors.vibrantGreen,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'FarmLink',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 1,
                          height: 24,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isWorker ? 'Worker Profile' : 'Farmer Profile',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Avatar with Verified Badge
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          _user!.displayName.isNotEmpty
                              ? _user!.displayName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 45,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified,
                            color: AppColors.vibrantGreen,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _user!.displayName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Location
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.muted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_user!.area.isNotEmpty ? _user!.area : "Daggakraal"} • 8 km',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bio
                  Text(
                    _user!.bio.isNotEmpty
                        ? _user!.bio
                        : (isWorker
                              ? 'Hardworking, reliable and always willing to learn. I enjoy working outdoors and helping with farm work.'
                              : 'We grow maize and vegetables. We support local communities and are always looking for hardworking people.'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats Row
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn(
                          isWorker ? 'Applications' : 'Jobs Posted',
                          isWorker ? '3' : '12',
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey.shade200,
                        ),
                        _buildStatColumn(
                          isWorker ? 'Selected' : 'Workers Hired',
                          isWorker ? '1' : '8',
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey.shade200,
                        ),
                        _buildStatColumn(
                          isWorker ? 'Rejected' : 'Rating',
                          isWorker ? '0' : '4.8',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Quick Links Title
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Quick links',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Quick Links
                  _buildQuickLink(
                    Icons.edit_outlined,
                    'Edit profile',
                    () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                      if (result == true) _loadProfile();
                    },
                  ),

                  // Skills / About Farm Link
                  _buildQuickLink(
                    isWorker ? Icons.star_outline : Icons.info_outline,
                    isWorker ? 'Skills & experience' : 'About the farm',
                    () async {
                      if (isWorker) {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WorkerSkillsScreen(),
                          ),
                        );
                        if (result == true) _loadProfile();
                      } else {
                        // FARMER ABOUT FARM LINK
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AboutFarmScreen(),
                          ),
                        );
                        if (result == true) _loadProfile();
                      }
                    },
                  ),

                  // Availability / Location
                  _buildQuickLink(
                    isWorker
                        ? Icons.calendar_month
                        : Icons.location_on_outlined,
                    isWorker ? 'Availability' : 'Location & reach',
                    () async {
                      if (isWorker) {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const WorkerAvailabilityScreen(),
                          ),
                        );
                        if (result == true) _loadProfile();
                      } else {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FarmerLocationScreen(),
                          ),
                        );
                        if (result == true) _loadProfile();
                      }
                    },
                  ),

                  // Preferences / Job Preferences
                  _buildQuickLink(
                    isWorker ? Icons.tune : Icons.work_outline,
                    isWorker ? 'Preferences' : 'Job preferences',
                    () async {
                      if (isWorker) {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const WorkerPreferencesScreen(),
                          ),
                        );
                        if (result == true) _loadProfile();
                      } else {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const FarmerJobPreferencesScreen(),
                          ),
                        );
                        if (result == true) _loadProfile();
                      }
                    },
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Logout
                  _buildQuickLink(
                    Icons.logout,
                    'Log out',
                    _logout,
                    isDestructive: true,
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.muted),
        ),
      ],
    );
  }

  Widget _buildQuickLink(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: isDestructive ? Colors.red : AppColors.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isDestructive ? Colors.red : AppColors.text,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, size: 20, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

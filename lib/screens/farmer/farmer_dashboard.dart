import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../services/data_service.dart';
import '../../models/app_user.dart';
import '../../models/job.dart';
import '../../models/job_application.dart';
import 'post_job_screen.dart';
import '../shared/splash_screen.dart';
import '../shared/profile_screen.dart';
import 'farmer_jobs_screen.dart'; // <-- New Import
import '../shared/chat_screen.dart';

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({super.key});

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  AppUser? _user;
  List<Job> _myJobs = [];
  List<JobApplication> _allApplications = [];
  bool _isLoading = true;

  int _currentIndex = 0;

  // Stats
  int _openJobsCount = 0;
  int _totalApplicants = 0;
  int _selectedWorkers = 0;
  int _positionsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dataService = Provider.of<DataService>(context, listen: false);
    final user = await dataService.getCurrentUser();

    if (user != null) {
      final jobs = await dataService.getFarmerJobs(user.id);

      int open = 0;
      int applicants = 0;
      int selected = 0;
      int remaining = 0;
      List<JobApplication> allApps = [];

      for (var job in jobs) {
        if (job.status == JobStatus.open) {
          open++;
          remaining += job.workersNeeded;
        }

        final apps = await dataService.getJobApplications(job.id);
        allApps.addAll(apps);
        applicants += apps.length;

        for (var app in apps) {
          if (app.status == ApplicationStatus.selected) {
            selected++;
            if (job.status == JobStatus.open) {
              remaining--;
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _user = user;
          _myJobs = jobs;
          _allApplications = allApps;
          _openJobsCount = open;
          _totalApplicants = applicants;
          _selectedWorkers = selected;
          _positionsRemaining = remaining > 0 ? remaining : 0;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildCurrentTab(),

      // Floating Oval Bottom Nav
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
              _buildNavItem(1, Icons.work_outline, Icons.work, 'My Jobs'),
              _buildNavItem(
                2,
                Icons.people_outline,
                Icons.people,
                'Applicants',
              ),
              _buildNavItem(3, Icons.person_outline, Icons.person, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return FarmerJobsScreen(
          onManageJob: () {
            setState(() {
              _currentIndex = 2; // Switches to Applicants tab
            });
          },
        ); // <-- The new screen!
      case 2:
        return _buildApplicantsTab();
      case 3:
        return const ProfileScreen();
      default:
        return _buildHomeTab();
    }
  }

  // --- HOME TAB ---
  Widget _buildHomeTab() {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.agriculture,
                  color: AppColors.vibrantGreen,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FarmLink',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'HIRER DASHBOARD',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 10,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () async {
                    await Provider.of<DataService>(
                      context,
                      listen: false,
                    ).signOut();
                    if (mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SplashScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning, ${_user?.displayName.split(" ").first ?? "Farmer"}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Here's what's happening with your jobs.",
                      style: TextStyle(color: AppColors.muted, fontSize: 14),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PostJobScreen(),
                            ),
                          );
                          _loadData();
                        },
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Post a New Job'),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Open jobs',
                            _openJobsCount.toString(),
                            'Currently hiring',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Applicants',
                            _totalApplicants.toString(),
                            'Across your jobs',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Workers selected',
                            _selectedWorkers.toString(),
                            'For your jobs',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Need workers',
                            _positionsRemaining.toString(),
                            'Positions remaining',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Jobs needing attention',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() => _currentIndex = 1);
                          },
                          child: const Text(
                            'View all',
                            style: TextStyle(color: AppColors.vibrantGreen),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    _myJobs.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text(
                                'You have not posted any jobs yet.',
                                style: TextStyle(color: AppColors.muted),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _myJobs.length,
                            itemBuilder: (context, index) {
                              final job = _myJobs[index];

                              int jobApps = _allApplications
                                  .where((a) => a.jobId == job.id)
                                  .length;
                              int selectedForJob = _allApplications
                                  .where(
                                    (a) =>
                                        a.jobId == job.id &&
                                        a.status == ApplicationStatus.selected,
                                  )
                                  .length;
                              double progress = job.workersNeeded > 0
                                  ? (selectedForJob / job.workersNeeded)
                                  : 0;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            job.title,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              jobStatusLabel(job.status),
                                              style: const TextStyle(
                                                color: Colors.orange,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${job.area} • Starts ${job.startDate.day}/${job.startDate.month}',
                                        style: const TextStyle(
                                          color: AppColors.muted,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.people_outline,
                                            size: 16,
                                            color: AppColors.muted,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$selectedForJob of ${job.workersNeeded} positions filled',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.text,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      LinearProgressIndicator(
                                        value: progress,
                                        backgroundColor: Colors.grey.shade200,
                                        color: AppColors.vibrantGreen,
                                        minHeight: 6,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      const SizedBox(height: 16),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '$jobApps interested workers',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.muted,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              setState(() => _currentIndex = 2);
                                            },
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              minimumSize: Size.zero,
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: const Text(
                                              'Review applicants',
                                              style: TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- APPLICANTS TAB ---
  Widget _buildApplicantsTab() {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.people,
                  color: AppColors.vibrantGreen,
                  size: 32,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Applicants',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _allApplications.isEmpty
                ? const Center(
                    child: Text(
                      'No applications yet.',
                      style: TextStyle(color: AppColors.muted, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _allApplications.length,
                    itemBuilder: (context, index) {
                      final app = _allApplications[index];

                      final job = _myJobs.firstWhere(
                        (j) => j.id == app.jobId,
                        orElse: () => _myJobs.first,
                      );

                      Color statusColor;
                      if (app.status == ApplicationStatus.selected) {
                        statusColor = Colors.green;
                      } else if (app.status == ApplicationStatus.notSelected) {
                        statusColor = Colors.red;
                      } else {
                        statusColor = Colors.orange;
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    app.workerName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      applicationStatusLabel(app.status),
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Applied for: ${job.title}',
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Phone: ${app.workerPhone}',
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 14,
                                ),
                              ),

                              if (app.status == ApplicationStatus.pending) ...[
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          await Provider.of<DataService>(
                                            context,
                                            listen: false,
                                          ).updateApplicationStatus(
                                            app.id,
                                            ApplicationStatus.notSelected,
                                          );
                                          _loadData();
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          side: const BorderSide(
                                            color: Colors.red,
                                          ),
                                        ),
                                        child: const Text('Decline'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: FilledButton(
                                        onPressed: () async {
                                          await Provider.of<DataService>(
                                            context,
                                            listen: false,
                                          ).updateApplicationStatus(
                                            app.id,
                                            ApplicationStatus.selected,
                                          );
                                          _loadData();
                                        },
                                        style: FilledButton.styleFrom(
                                          backgroundColor:
                                              AppColors.vibrantGreen,
                                        ),
                                        child: const Text('Select'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: isSelected
                ? const EdgeInsets.symmetric(horizontal: 20, vertical: 6)
                : const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.vibrantGreen.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.vibrantGreen : Colors.white54,
              size: 24,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white54,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../services/data_service.dart';
import '../../models/app_user.dart';
import '../../models/job.dart';
import '../../models/job_application.dart';
import 'job_details_screen.dart';
import '../shared/splash_screen.dart';
import '../auth/login_screen.dart'; 
import '../shared/profile_screen.dart';

class WorkerDashboard extends StatefulWidget {
  const WorkerDashboard({super.key});

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  AppUser? _user;
  List<Job> _jobs = [];
  List<JobApplication> _myApplications = [];
  bool _isLoading = true;
  
  int _currentIndex = 0; 

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dataService = Provider.of<DataService>(context, listen: false);
    final user = await dataService.getCurrentUser();
    
    if (user != null) {
      final jobs = await dataService.getOpenJobs();
      final apps = await dataService.getWorkerApplications(user.id);
      
      if (mounted) {
        setState(() {
          _user = user;
          _jobs = jobs;
          _myApplications = apps;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
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
              _buildNavItem(1, Icons.search, Icons.search, 'Find Jobs'),
              _buildNavItem(2, Icons.assignment_outlined, Icons.assignment, 'Applications'),
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
        return _buildPlaceholderTab('Find Jobs (Coming Soon)');
      case 2:
        return _buildApplicationsTab();
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded( 
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.agriculture, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded( // <--- Added Expanded here to prevent header text overflow
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('FarmLink', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                            Text('Find work close to home', style: TextStyle(color: AppColors.muted, fontSize: 12), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () {},
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),

            // Greeting & Location
            Text('Good morning, ${_user?.displayName.split(" ").first ?? "Worker"}!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: AppColors.muted),
                  const SizedBox(width: 4),
                  Flexible( // <--- Added Flexible here to prevent location text overflow
                    child: Text(
                      '${_user?.area.isNotEmpty == true ? _user!.area : "Daggakraal"} • Within 10 km', 
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text('Change', style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'e.g. harvesting, planting...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              ),
            ),
            const SizedBox(height: 16),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All jobs', true),
                  _buildFilterChip('Harvesting', false),
                  _buildFilterChip('Planting', false),
                  _buildFilterChip('General work', false),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Jobs List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Jobs near you', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () { setState(() => _currentIndex = 1); },
                  child: const Text('View all', style: TextStyle(color: AppColors.vibrantGreen)),
                )
              ],
            ),
            
            if (_jobs.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: Text('No jobs available right now.', style: TextStyle(color: AppColors.muted))),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _jobs.length,
                itemBuilder: (context, index) {
                  final job = _jobs[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.agriculture, color: Colors.green),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text('${job.area} • Approximately 3 km away', style: const TextStyle(color: AppColors.muted, fontSize: 12), overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(color: AppColors.vibrantGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                      child: const Text('Applications open', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded( // <--- Added Expanded to prevent pay details from overflowing into the button
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('R${job.payAmount?.toStringAsFixed(0) ?? 0}/day', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
                                    const SizedBox(height: 4),
                                    Text('${job.startDate.day}-${job.endDate.day} November', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 14, color: AppColors.muted),
                                      const SizedBox(width: 4),
                                      Text('${job.startTime} - ${job.endTime}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: 36,
                                    child: FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        minimumSize: Size.zero, 
                                      ),
                                      onPressed: () async {
                                        await Navigator.push(context, MaterialPageRoute(builder: (context) => JobDetailsScreen(job: job)));
                                        _loadData(); 
                                      },
                                      child: const Text('View Job', style: TextStyle(fontSize: 12)),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.people_outline, size: 16, color: AppColors.muted),
                              const SizedBox(width: 4),
                              Text('${job.workersNeeded} workers needed', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 32),
            const Text('Your applications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _myApplications.isEmpty
                ? const Text('You have not applied for any jobs yet.', style: TextStyle(color: AppColors.muted, fontSize: 14))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _myApplications.length,
                    itemBuilder: (context, index) {
                      final app = _myApplications[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        // Replaced ListTile with InkWell to fix the console warnings
                        child: InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.work_outline, color: AppColors.text),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(app.jobTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      const SizedBox(height: 4),
                                      const Text('Applied recently', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                                    ],
                                  ),
                                ),
                                Text(
                                  applicationStatusLabel(app.status),
                                  style: TextStyle(
                                    color: app.status == ApplicationStatus.selected ? Colors.green : (app.status == ApplicationStatus.notSelected ? Colors.red : Colors.orange),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 80), 
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationsTab() {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Row(
              children: [
                const Icon(Icons.assignment, color: AppColors.vibrantGreen, size: 32),
                const SizedBox(width: 12),
                const Text('My Applications', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: _myApplications.isEmpty
                ? const Center(child: Text('No applications yet.', style: TextStyle(color: AppColors.muted)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _myApplications.length,
                    itemBuilder: (context, index) {
                      final app = _myApplications[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(app.jobTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: app.status == ApplicationStatus.selected ? Colors.green.withOpacity(0.1) : (app.status == ApplicationStatus.notSelected ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1)),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      applicationStatusLabel(app.status),
                                      style: TextStyle(
                                        color: app.status == ApplicationStatus.selected ? Colors.green : (app.status == ApplicationStatus.notSelected ? Colors.red : Colors.orange),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Applied on: ${app.appliedAt.day}/${app.appliedAt.month}/${app.appliedAt.year}', style: const TextStyle(color: AppColors.muted, fontSize: 13)),
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

  Widget _buildPlaceholderTab(String title) {
    return Center(
      child: Text(title, style: const TextStyle(color: AppColors.text, fontSize: 20)),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? AppColors.primary : const Color(0xFFE5E7EB)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.muted,
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
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
              color: isSelected ? AppColors.vibrantGreen.withOpacity(0.2) : Colors.transparent,
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
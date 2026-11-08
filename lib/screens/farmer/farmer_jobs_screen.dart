import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../services/data_service.dart';
import '../../models/app_user.dart';
import '../../models/job.dart';
import 'post_job_screen.dart'; // <-- Needed for the + button

class FarmerJobsScreen extends StatefulWidget {
  final VoidCallback? onManageJob; // <-- Added this

  const FarmerJobsScreen({super.key, this.onManageJob}); // <-- Added this

  @override
  State<FarmerJobsScreen> createState() => _FarmerJobsScreenState();
}

class _FarmerJobsScreenState extends State<FarmerJobsScreen> {
  AppUser? _user;
  List<Job> _myJobs = [];
  bool _isLoading = true;

  // Search and Filter state
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Active',
    'Drafts',
    'Completed',
    'Closed',
  ];

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    final dataService = Provider.of<DataService>(context, listen: false);
    final user = await dataService.getCurrentUser();

    if (user != null) {
      final jobs = await dataService.getFarmerJobs(user.id);
      if (mounted) {
        setState(() {
          _user = user;
          _myJobs = jobs;
          _isLoading = false;
        });
      }
    }
  }

  // Filter Logic
  List<Job> get _filteredJobs {
    return _myJobs.where((job) {
      final matchesSearch = job.title.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );

      bool matchesFilter = false;
      if (_selectedFilter == 'All') {
        matchesFilter = true;
      } else if (_selectedFilter == 'Active') {
        matchesFilter = job.status == JobStatus.open;
      } else if (_selectedFilter == 'Closed') {
        matchesFilter =
            job.status == JobStatus.closed || job.status == JobStatus.filled;
      } else {
        matchesFilter = false;
      }

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 20.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My Jobs',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage your job advertisements',
                        style: TextStyle(fontSize: 13, color: AppColors.muted),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PostJobScreen(),
                          ),
                        );
                        _loadJobs();
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Search & Filters
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Column(
                children: [
                  TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search job title...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.muted,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected)
                                setState(() => _selectedFilter = filter);
                            },
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.text,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primary
                                  : const Color(0xFFE5E7EB),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // List Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'YOUR ADVERTISEMENTS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.muted,
                  letterSpacing: 1.1,
                ),
              ),
            ),

            // Jobs List
            Expanded(
              child: _filteredJobs.isEmpty
                  ? const Center(
                      child: Text(
                        'No jobs found.',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filteredJobs.length,
                      itemBuilder: (context, index) {
                        final job = _filteredJobs[index];

                        // Fake stats for visual matching (in a real app, you'd fetch these)
                        int applicants = 9;
                        int positionsFilled = 3;
                        int positionsRemaining =
                            job.workersNeeded - positionsFilled;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Status & Menu
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: job.status == JobStatus.open
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        job.status == JobStatus.open
                                            ? 'Active'
                                            : jobStatusLabel(job.status),
                                        style: TextStyle(
                                          color: job.status == JobStatus.open
                                              ? Colors.green
                                              : AppColors.muted,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.more_horiz,
                                      color: AppColors.muted,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Title & Location
                                Text(
                                  job.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${job.area} • ${job.startDate.day}-${job.endDate.day} November',
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 13,
                                  ),
                                ),

                                const SizedBox(height: 20),
                                const Divider(),
                                const SizedBox(height: 12),

                                // Stats Row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildStat('$applicants', 'Applicants'),
                                    _buildStat(
                                      '$positionsFilled/${job.workersNeeded}',
                                      'Positions filled',
                                    ),
                                    _buildStat(
                                      'R${job.payAmount?.toStringAsFixed(0)}',
                                      'Per day',
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 12),

                                // Footer (Remaining & Manage)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '$positionsRemaining positions remaining',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        // Trigger the callback to switch tabs in the dashboard
                                        if (widget.onManageJob != null) {
                                          widget.onManageJob!();
                                        }
                                      },
                                      child: const Text(
                                        'Manage Job →',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.muted),
        ),
      ],
    );
  }
}

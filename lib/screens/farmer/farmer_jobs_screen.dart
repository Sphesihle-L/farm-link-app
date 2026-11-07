import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../services/data_service.dart';
import '../../models/app_user.dart';
import '../../models/job.dart';

class FarmerJobsScreen extends StatefulWidget {
  const FarmerJobsScreen({super.key});

  @override
  State<FarmerJobsScreen> createState() => _FarmerJobsScreenState();
}

class _FarmerJobsScreenState extends State<FarmerJobsScreen> {
  AppUser? _user;
  List<Job> _myJobs = [];
  bool _isLoading = true;

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

  Future<void> _updateStatus(Job job, JobStatus newStatus) async {
    final dataService = Provider.of<DataService>(context, listen: false);
    await dataService.updateJobStatus(job.id, newStatus);
    _loadJobs(); // Refresh the list
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Job marked as ${jobStatusLabel(newStatus)}'),
          backgroundColor: AppColors.vibrantGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Row(
              children: [
                const Icon(Icons.work, color: AppColors.vibrantGreen, size: 32),
                const SizedBox(width: 12),
                const Text(
                  'My Jobs',
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
            child: _myJobs.isEmpty
                ? const Center(
                    child: Text(
                      'You have not posted any jobs yet.',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _myJobs.length,
                    itemBuilder: (context, index) {
                      final job = _myJobs[index];
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
                                  Expanded(
                                    child: Text(
                                      job.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: job.status == JobStatus.open
                                          ? Colors.orange.withOpacity(0.1)
                                          : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      jobStatusLabel(job.status),
                                      style: TextStyle(
                                        color: job.status == JobStatus.open
                                            ? Colors.orange
                                            : AppColors.muted,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${job.area} • ${job.workersNeeded} workers needed',
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Status Update Buttons
                              if (job.status == JobStatus.open) ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => _updateStatus(
                                          job,
                                          JobStatus.closed,
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          side: const BorderSide(
                                            color: Colors.red,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: const Text('Close Job'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: FilledButton(
                                        onPressed: () => _updateStatus(
                                          job,
                                          JobStatus.filled,
                                        ),
                                        style: FilledButton.styleFrom(
                                          backgroundColor:
                                              AppColors.vibrantGreen,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: const Text('Mark Filled'),
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
}

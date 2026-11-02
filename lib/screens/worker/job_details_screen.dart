import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../models/job.dart';
import '../../services/data_service.dart';
import '../../models/job_application.dart';

class JobDetailsScreen extends StatefulWidget {
  final Job job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  bool _isLoading = false;

  Future<void> _apply() async {
    setState(() => _isLoading = true);

    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final user = await dataService.getCurrentUser();

      if (user == null) throw Exception("Not logged in");

      final application = JobApplication(
        id: "${widget.job.id}_${user.id}", // Unique ID prevents double applying
        jobId: widget.job.id,
        workerId: user.id,
        farmerId: widget.job.farmerId,
        workerName: user.displayName,
        workerPhone: user.phone,
        workerSkills: user.skills,
        jobTitle: widget.job.title,
        appliedAt: DateTime.now(),
      );

      await dataService.applyForJob(application);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application sent successfully!'),
            backgroundColor: AppColors.vibrantGreen,
          ),
        );
        Navigator.pop(context); // Go back to dashboard
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Job Details'),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.vibrantGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    jobStatusLabel(job.status),
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Posted by ${job.farmerName}',
              style: const TextStyle(color: AppColors.muted, fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Info Cards
            _buildInfoRow(Icons.location_on, 'Location', job.area),
            _buildInfoRow(Icons.calendar_month, 'Dates', job.dateRangeDisplay),
            _buildInfoRow(Icons.payments, 'Pay', job.payDisplay),
            _buildInfoRow(Icons.people, 'Workers Needed', '${job.workersNeeded} people'),
            
            const SizedBox(height: 24),
            const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(job.description, style: const TextStyle(fontSize: 16, height: 1.5)),
            
            const SizedBox(height: 32),
            
            // Apply Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _isLoading ? null : _apply,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('I am Interested', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          )
        ],
      ),
    );
  }
}
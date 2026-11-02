import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme.dart';
import '../../models/job.dart';

class JobPreviewScreen extends StatelessWidget {
  final Job job;
  final String jobType;

  const JobPreviewScreen({
    super.key,
    required this.job,
    required this.jobType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Preview Job', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tags
            Row(
              children: [
                _buildTag('Ready to publish', AppColors.primary.withOpacity(0.1), AppColors.primary),
                const SizedBox(width: 8),
                _buildTag(jobType, AppColors.vibrantGreen.withOpacity(0.2), AppColors.primary),
              ],
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              job.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            // Location
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: AppColors.muted),
                const SizedBox(width: 4),
                Text('${job.area} • Approximately 5 km away', style: const TextStyle(color: AppColors.muted)),
              ],
            ),
            const SizedBox(height: 24),

            // Pay
            const Text('Pay', style: TextStyle(color: AppColors.muted, fontSize: 12)),
            Text(
              'R${job.payAmount?.toStringAsFixed(0) ?? "0"}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.vibrantGreen),
            ),
            const Text('/day', style: TextStyle(color: AppColors.muted, fontSize: 14)),
            const SizedBox(height: 24),

            // Grid of Details
            Row(
              children: [
                Expanded(child: _buildInfoCard('Work dates', '${DateFormat('d MMM').format(job.startDate)} - ${DateFormat('d MMM').format(job.endDate)}', Icons.calendar_today)),
                const SizedBox(width: 12),
                Expanded(child: _buildInfoCard('Working hours', '${job.startTime} - ${job.endTime}', Icons.access_time)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildInfoCard('Workers needed', '${job.workersNeeded} people', Icons.people_outline)),
                const SizedBox(width: 12),
                Expanded(child: _buildInfoCard('Apply before', '8 November', Icons.event_available)), // Hardcoded for visual
              ],
            ),
            
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            // Description
            const Text('About this job', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(job.description, style: const TextStyle(fontSize: 14, height: 1.5)),
            
            const SizedBox(height: 24),

            // Requirements
            const Text('Requirements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...job.requirements.map((req) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline, size: 18, color: AppColors.vibrantGreen),
                  const SizedBox(width: 8),
                  Expanded(child: Text(req, style: const TextStyle(fontSize: 14))),
                ],
              ),
            )),

            const SizedBox(height: 24),

            // Additional Info
            const Text('Additional information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.directions, 'Farm location and directions', 'Farm near the main road, Daggakraal'),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.payments_outlined, 'Payment', 'Paid at the end of each workday'),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            // Worker View Note
            Row(
              children: [
                const Icon(Icons.visibility_outlined, size: 18, color: AppColors.muted),
                const SizedBox(width: 8),
                const Text('Worker view', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.muted)),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Workers will be able to read these details and apply. This preview does not mean the job has been published.',
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: () {
                  // Pass 'true' back to the post job screen to trigger the save
                  Navigator.pop(context, true); 
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Publish Job', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.text,
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Edit Job Details', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {
                  // Function to save as draft could go here in the future
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draft saving coming soon!')));
                },
                child: const Text('Save as Draft', style: TextStyle(color: AppColors.muted)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.muted),
              const SizedBox(width: 4),
              Text(title, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.muted),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
            ],
          ),
        )
      ],
    );
  }
}
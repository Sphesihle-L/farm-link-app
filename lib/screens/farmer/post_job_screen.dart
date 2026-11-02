import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme.dart';
import '../../services/data_service.dart';
import '../../models/job.dart';
import '../../models/app_user.dart'; // Added to use AppUser in the helper method
import 'job_preview_screen.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Section 1: Details
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _jobType = 'Harvesting';

  // Section 2: Schedule
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 2));
  TimeOfDay _startTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 16, minute: 0);
  int _workersNeeded = 1;

  // Section 3: Payment
  final _payController = TextEditingController();
  String _payBasis = 'perDay';
  String _paymentTiming = 'At the end of each workday';

  // Section 4: Location
  final _areaController = TextEditingController();
  final _directionsController = TextEditingController();

  // Section 5: Requirements
  String _experienceLevel = 'Preferred, but not required';
  String _providedItems = 'Protective equipment';
  final _instructionsController = TextEditingController();

  // Section 6: Final Details
  DateTime _deadline = DateTime.now().add(const Duration(days: 1));
  final _contactController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = await Provider.of<DataService>(context, listen: false).getCurrentUser();
      if (user != null && user.phone.isNotEmpty) {
        setState(() => _contactController.text = user.phone);
      }
    });
  }

  // --- HELPER METHOD TO BUILD THE JOB OBJECT ---
  Job _buildJobObject(AppUser user) {
    final fullDescription = "Job Type: $_jobType\n\n${_descController.text}\n\nPayment: $_paymentTiming\nDirections: ${_directionsController.text}";
    
    final requirementsList = [
      "Experience: $_experienceLevel",
      "Provided: $_providedItems",
      "Instructions: ${_instructionsController.text}",
      "Contact: ${_contactController.text}",
    ];

    return Job(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      farmerId: user.id,
      farmerName: user.displayName,
      title: _titleController.text.trim(),
      description: fullDescription,
      area: _areaController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      startTime: _startTime.format(context),
      endTime: _endTime.format(context),
      workersNeeded: _workersNeeded,
      payAmount: double.tryParse(_payController.text) ?? 0,
      payBasis: PayBasis.perDay,
      requirements: requirementsList,
      contactInstructions: _contactController.text,
      createdAt: DateTime.now(),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final user = await dataService.getCurrentUser();
      if (user == null) throw Exception("Not logged in");

      final newJob = _buildJobObject(user);

      await dataService.createJob(newJob);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job posted successfully!'), backgroundColor: AppColors.vibrantGreen),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Post a New Job', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SECTION 1 ---
              _buildSectionHeader('SECTION 1 — JOB DETAILS'),
              _buildLabel('What work needs to be done?'),
              _buildTextField(_titleController, 'Job title', 'Harvesting maize'),
              const SizedBox(height: 16),
              _buildLabel('Type of work'),
              DropdownButtonFormField<String>(
                value: _jobType,
                decoration: _inputDecoration(),
                items: ['Harvesting', 'Planting', 'Weeding', 'Packing', 'General farm work']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => _jobType = val!),
              ),
              const SizedBox(height: 16),
              _buildLabel('Job description'),
              _buildTextField(_descController, 'Job description', 'Help harvest maize and sort the crop...', maxLines: 4),
              
              const SizedBox(height: 32),

              // --- SECTION 2 ---
              _buildSectionHeader('SECTION 2 — WORK SCHEDULE'),
              Row(
                children: [
                  Expanded(child: _buildDatePicker('Start date', _startDate, (d) => setState(() => _startDate = d))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDatePicker('End date', _endDate, (d) => setState(() => _endDate = d))),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTimePicker('Start time', _startTime, (t) => setState(() => _startTime = t))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTimePicker('End time', _endTime, (t) => setState(() => _endTime = t))),
                ],
              ),
              const SizedBox(height: 24),
              _buildLabel('Number of workers needed'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () { if (_workersNeeded > 1) setState(() => _workersNeeded--); },
                    ),
                    Text('$_workersNeeded', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => setState(() => _workersNeeded++),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // --- SECTION 3 ---
              _buildSectionHeader('SECTION 3 — PAYMENT'),
              _buildLabel('How much will workers be paid?'),
              _buildTextField(_payController, 'Amount (R)', '250', keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildLabel('Payment basis'),
              DropdownButtonFormField<String>(
                value: _payBasis,
                decoration: _inputDecoration(),
                items: ['perDay', 'perHour', 'perJob']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e == 'perDay' ? 'Per day' : e == 'perHour' ? 'Per hour' : 'Per job'))).toList(),
                onChanged: (val) => setState(() => _payBasis = val!),
              ),
              const SizedBox(height: 16),
              _buildLabel('When will workers be paid?'),
              DropdownButtonFormField<String>(
                value: _paymentTiming,
                decoration: _inputDecoration(),
                items: ['At the end of each workday', 'At the end of the job', 'Weekly']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => _paymentTiming = val!),
              ),

              const SizedBox(height: 32),

              // --- SECTION 4 ---
              _buildSectionHeader('SECTION 4 — FARM LOCATION'),
              _buildLabel('Community or area'),
              _buildTextField(_areaController, 'Area', 'Daggakraal'),
              const SizedBox(height: 16),
              _buildLabel('Farm name or directions'),
              _buildTextField(_directionsController, 'Directions', 'Example: Farm near the main road...'),
              
              const SizedBox(height: 32),

              // --- SECTION 5 ---
              _buildSectionHeader('SECTION 5 — REQUIREMENTS'),
              _buildLabel('Do workers need previous experience?'),
              _buildRadioGroup(['Yes, experience is required', 'Preferred, but not required', 'No experience needed'], _experienceLevel, (val) => setState(() => _experienceLevel = val)),
              const SizedBox(height: 16),
              _buildLabel('What will you provide?'),
              _buildRadioGroup(['Transport to the farm', 'Meals or drinking water', 'Protective equipment'], _providedItems, (val) => setState(() => _providedItems = val)),
              const SizedBox(height: 16),
              _buildLabel('Additional instructions'),
              _buildTextField(_instructionsController, 'Instructions', 'For example, what workers should bring or wear.'),

              const SizedBox(height: 32),

              // --- SECTION 6 ---
              _buildSectionHeader('SECTION 6 — FINAL DETAILS'),
              _buildLabel('Application deadline'),
              _buildDatePicker('Select closing date', _deadline, (d) => setState(() => _deadline = d)),
              const SizedBox(height: 16),
              _buildLabel('Contact number'),
              _buildTextField(_contactController, 'Contact number', 'Your registered phone number', keyboardType: TextInputType.phone),

              const SizedBox(height: 32),
              
              // Publish Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Ready to publish?',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Check the dates, pay, number of workers and location before making the job visible to workers.',
                      style: TextStyle(color: AppColors.muted, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    
                    // Preview Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill in all required fields before previewing.'), backgroundColor: Colors.red),
                            );
                            return;
                          }

                          final user = await Provider.of<DataService>(context, listen: false).getCurrentUser();
                          if (user == null) return;

                          final previewJob = _buildJobObject(user);

                          if (!mounted) return;
                          // Navigate to the new full-screen preview
                          final bool? shouldPublish = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JobPreviewScreen(
                                job: previewJob,
                                jobType: _jobType,
                              ),
                            ),
                          );

                          // If they clicked Publish in the preview screen, submit the form!
                          if (shouldPublish == true) {
                            _submit();
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary, 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Preview Job', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Publish Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: AppColors.primary)
                            : const Text(
                                'Publish Job',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ], 
          ), 
        ), 
      ), 
    ); 
  } 

  // --- HELPER WIDGETS ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1),
          ),
          const Divider(color: Color(0xFFE5E7EB)),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: _inputDecoration().copyWith(hintText: hint),
      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildDatePicker(String label, DateTime date, Function(DateTime) onPicked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) onPicked(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('dd/MM/yyyy').format(date)),
                const Icon(Icons.calendar_today, size: 18, color: AppColors.muted),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay time, Function(TimeOfDay) onPicked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        InkWell(
          onTap: () async {
            final picked = await showTimePicker(context: context, initialTime: time);
            if (picked != null) onPicked(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(time.format(context)),
                const Icon(Icons.access_time, size: 18, color: AppColors.muted),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioGroup(List<String> options, String selected, Function(String) onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: options.map((opt) {
          return RadioListTile<String>(
            title: Text(opt, style: const TextStyle(fontSize: 14)),
            value: opt,
            groupValue: selected,
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
            dense: true,
            onChanged: (val) => onChanged(val!),
          );
        }).toList(),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../services/data_service.dart';
import '../../models/app_user.dart';

class WorkerPreferencesScreen extends StatefulWidget {
  const WorkerPreferencesScreen({super.key});

  @override
  State<WorkerPreferencesScreen> createState() => _WorkerPreferencesScreenState();
}

class _WorkerPreferencesScreenState extends State<WorkerPreferencesScreen> {
  AppUser? _user;
  bool _isLoading = true;
  bool _isSaving = false;

  // State Variables
  String _preferredDistance = 'Within 10 km';
  bool _hasTransport = false;
  final _notesController = TextEditingController();

  final List<String> _distances = ['Within 5 km', 'Within 10 km', 'Within 25 km', 'Anywhere in the region'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await Provider.of<DataService>(context, listen: false).getCurrentUser();
    if (user != null) {
      setState(() {
        _user = user;
        _preferredDistance = user.preferredDistance;
        _hasTransport = user.hasTransport;
        _notesController.text = user.additionalNotes;
        _isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final updatedUser = _user!.copyWith(
        preferredDistance: _preferredDistance,
        hasTransport: _hasTransport,
        additionalNotes: _notesController.text.trim(),
      );

      await dataService.updateUserProfile(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferences updated successfully!'), backgroundColor: AppColors.vibrantGreen),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Preferences', style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.white,
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
            // Distance
            const Text('Distance you can travel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _preferredDistance,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: _distances.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() => _preferredDistance = newValue!);
                  },
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Transport
            const Text('Do you have transport?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 8),
            RadioListTile<bool>(
              title: const Text('Yes', style: TextStyle(fontSize: 14)),
              value: true,
              groupValue: _hasTransport,
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
              dense: true,
              onChanged: (val) => setState(() => _hasTransport = val!),
            ),
            RadioListTile<bool>(
              title: const Text('No', style: TextStyle(fontSize: 14)),
              value: false,
              groupValue: _hasTransport,
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
              dense: true,
              onChanged: (val) => setState(() => _hasTransport = val!),
            ),

            const SizedBox(height: 32),

            // Additional Notes
            const Text('Additional notes (optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Happy to travel a bit further if needed.',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _isSaving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save Changes', style: TextStyle(fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
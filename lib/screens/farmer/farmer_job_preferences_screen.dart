import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../services/data_service.dart';
import '../../models/app_user.dart';

class FarmerJobPreferencesScreen extends StatefulWidget {
  const FarmerJobPreferencesScreen({super.key});

  @override
  State<FarmerJobPreferencesScreen> createState() =>
      _FarmerJobPreferencesScreenState();
}

class _FarmerJobPreferencesScreenState
    extends State<FarmerJobPreferencesScreen> {
  AppUser? _user;
  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> _selectedWorkTypes = [];
  String _preferredPay = 'Daily';
  final _notesController = TextEditingController();

  final List<String> _allWorkTypes = [
    'Harvesting',
    'Planting',
    'Weeding',
    'General work',
    'Packing / sorting',
  ];
  final List<String> _payOptions = ['Hourly', 'Daily', 'Per job'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await Provider.of<DataService>(
      context,
      listen: false,
    ).getCurrentUser();
    if (user != null) {
      setState(() {
        _user = user;
        _selectedWorkTypes.addAll(user.offeredWorkTypes);
        // Assuming we have a preferredPay field, but for now we'll just default to Daily
        // _preferredPay = user.preferredPay;
        _notesController.text =
            user.additionalNotes; // Using same notes field for now
        _isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final updatedUser = _user!.copyWith(
        offeredWorkTypes: _selectedWorkTypes,
        // preferredPay: _preferredPay,
        // additionalNotes: _notesController.text.trim(),
      );

      await dataService.updateUserProfile(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job preferences updated!'),
            backgroundColor: AppColors.vibrantGreen,
          ),
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
        title: const Text('Job Preferences', style: TextStyle(fontSize: 18)),
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
            const Text(
              'Types of work you offer',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allWorkTypes.map((type) {
                final isSelected = _selectedWorkTypes.contains(type);
                return FilterChip(
                  label: Text(type),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.text,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedWorkTypes.add(type);
                      } else {
                        _selectedWorkTypes.remove(type);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            const Text(
              'Preferred pay basis',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
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
                  value: _preferredPay,
                  items: _payOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() => _preferredPay = newValue!);
                  },
                ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

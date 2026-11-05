import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../services/data_service.dart';
import '../../models/app_user.dart';

class WorkerSkillsScreen extends StatefulWidget {
  const WorkerSkillsScreen({super.key});

  @override
  State<WorkerSkillsScreen> createState() => _WorkerSkillsScreenState();
}

class _WorkerSkillsScreenState extends State<WorkerSkillsScreen> {
  AppUser? _user;
  bool _isLoading = true;
  bool _isSaving = false;

  List<String> _selectedSkills = [];
  String _experienceLevel = 'Some experience';
  final _previousWorkController = TextEditingController();

  final List<String> _availableSkills = [
    'Harvesting', 'Planting', 'Weeding', 'General farm work',
    'Team work', 'Packing / sorting', 'Driver', 'Tractor operation'
  ];

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
        _selectedSkills = List.from(user.skills);
        _experienceLevel = user.experience;
        _previousWorkController.text = user.previousWork;
        _isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final updatedUser = _user!.copyWith(
        skills: _selectedSkills,
        experience: _experienceLevel,
        previousWork: _previousWorkController.text.trim(),
      );

      await dataService.updateUserProfile(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Skills updated successfully!'), backgroundColor: AppColors.vibrantGreen),
        );
        Navigator.pop(context, true); // Return true so ProfileScreen reloads
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
        title: const Text('Skills & Experience', style: TextStyle(fontSize: 18)),
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
            // Skills Section
            const Text('Skills', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableSkills.map((skill) {
                final isSelected = _selectedSkills.contains(skill);
                return FilterChip(
                  label: Text(skill),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.text,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  side: BorderSide(color: isSelected ? AppColors.primary : const Color(0xFFE5E7EB)),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedSkills.add(skill);
                      } else {
                        _selectedSkills.remove(skill);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 32),

            // Experience Section
            const Text('Experience', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 12),
            _buildExperienceOption('No experience'),
            _buildExperienceOption('Some experience'),
            _buildExperienceOption('Experienced'),

            const SizedBox(height: 32),

            // Previous Work Section
            const Text('Previous work (optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _previousWorkController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Worked on a local farm for 1 season (vegetable picking).',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text('${_previousWorkController.text.length}/500', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            ),

            const SizedBox(height: 40),

            // Save Button
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

  Widget _buildExperienceOption(String title) {
    return RadioListTile<String>(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      value: title,
      groupValue: _experienceLevel,
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
      dense: true,
      onChanged: (val) => setState(() => _experienceLevel = val!),
    );
  }
}
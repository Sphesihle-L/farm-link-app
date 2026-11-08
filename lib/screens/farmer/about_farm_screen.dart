import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../services/data_service.dart';
import '../../models/app_user.dart';

class AboutFarmScreen extends StatefulWidget {
  const AboutFarmScreen({super.key});

  @override
  State<AboutFarmScreen> createState() => _AboutFarmScreenState();
}

class _AboutFarmScreenState extends State<AboutFarmScreen> {
  AppUser? _user;
  bool _isLoading = true;
  bool _isSaving = false;

  final _descriptionController = TextEditingController();
  final _sizeController = TextEditingController();

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
        _descriptionController.text = user.farmDescription;
        _sizeController.text = user.farmSize;
        _isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final updatedUser = _user!.copyWith(
        farmDescription: _descriptionController.text.trim(),
        farmSize: _sizeController.text.trim(),
      );

      await dataService.updateUserProfile(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Farm details updated!'),
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
        title: const Text('About the Farm', style: TextStyle(fontSize: 18)),
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
            // Farm Size
            const Text(
              'Farm Size',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _sizeController,
              decoration: InputDecoration(
                hintText: 'e.g., 50 hectares',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Farm Description
            const Text(
              'Farm Description',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText:
                    'Tell workers about your farm, what you grow, and what it is like to work there...',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
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

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../core/constants.dart';

class UserDetailsScreen extends StatefulWidget {
  final String currentName;
  final Function(String) onSave;

  const UserDetailsScreen({
    super.key,
    required this.currentName,
    required this.onSave,
  });

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _quoteController;

  @override
  void initState() {
    super.initState();
    final settingsBox = Hive.box('settings');
    _nameController = TextEditingController(text: widget.currentName);
    _quoteController = TextEditingController(
      text: settingsBox.get(
        'motivationQuote',
        defaultValue: 'One task at a time. One step closer.',
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quoteController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    final settingsBox = Hive.box('settings');
    String newName = _nameController.text.trim();
    String newQuote = _quoteController.text.trim();

    if (newName.isNotEmpty) {
      await settingsBox.put('userName', newName);
    }
    await settingsBox.put('motivationQuote', newQuote);

    widget.onSave(newName);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('User Name', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              const Text('Motivation Quote', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _quoteController,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
              // مسافة لرفع الزر قليلاً عن الحافة والأزرار السفليّة
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
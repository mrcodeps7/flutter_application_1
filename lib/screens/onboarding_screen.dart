import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../core/constants.dart';
import 'main_layout.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _nameController = TextEditingController();

  void _getStarted() async {
    String enteredName = _nameController.text.trim();
    if (enteredName.isEmpty) {
      enteredName = 'Rand irany';
    }

    final settingsBox = Hive.box('settings');
    await settingsBox.put('userName', enteredName);
    await settingsBox.put('isFirstTime', false);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainLayout(userName: enteredName),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        
                        // 1. اللوجو واسم التطبيق
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle, color: AppColors.primary, size: 30),
                            const SizedBox(width: 8),
                            Text(
                              'Tasky',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // 2. صورة الـ Onboarding
                        Center(
                          child: Image.asset(
                            'assets/images/onboarding.png',
                            height: 200,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 180,
                                width: 180,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.task_alt,
                                  size: 90,
                                  color: AppColors.primary,
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 3. الترحيب
                        Text(
                          'Welcome To Tasky',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.textDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your productivity journey starts here.',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : AppColors.greyText,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 24),

                        // 4. حقل إدخال الاسم
                        Text(
                          'Full Name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? Colors.white70 : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'e.g. Sarah Khalid',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),

                        // يدفع الزر للأسفل باحترافية، ويرتفع بسلاسة مع الكيبورد
                        const Spacer(),

                        const SizedBox(height: 24),

                        // 5. زر البدء
                        ElevatedButton(
                          onPressed: _getStarted,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Let's Get Started",
                            style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
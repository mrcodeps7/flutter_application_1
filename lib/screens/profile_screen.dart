import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants.dart';
import 'user_details_screen.dart';
import 'onboarding_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  final Function(String) onNameUpdated;

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.onNameUpdated,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  // دالة اختيار الصورة (سواء من المعرض أو الكاميرا)
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80, // لضغط الصورة قليلاً والحفاظ على الأداء
      );

      if (pickedFile != null) {
        final settingsBox = Hive.box('settings');
        await settingsBox.put('profileImagePath', pickedFile.path);
        setState(() {}); // إعادة بناء الواجهة لعرض الصورة الجديدة
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء اختيار الصورة: $e')),
        );
      }
    }
  }

  // نافذة الخيارات عند الضغط على صورة البروفايل
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Wrap(
              children: [
                const ListTile(
                  title: Text(
                    'تغيير الصورة الشخصية',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: AppColors.primary),
                  title: const Text('اختيار من المعرض (Gallery)'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                  title: const Text('التقاط صورة بالكاميرا (Camera)'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                // خيار حذف الصورة الحالية وإرجاع الإيقونة الافتراضية
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('حذف الصورة الحالية', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(context);
                    final settingsBox = Hive.box('settings');
                    await settingsBox.delete('profileImagePath');
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleDarkMode(bool value) async {
    final settingsBox = Hive.box('settings');
    await settingsBox.put('isDarkMode', value);
  }

  void _logout() async {
    final settingsBox = Hive.box('settings');
    await settingsBox.put('isFirstTime', true);

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        (route) => false,
      );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsBox = Hive.box('settings');

    return ValueListenableBuilder(
      valueListenable: settingsBox.listenable(keys: ['isDarkMode', 'motivationQuote', 'profileImagePath']),
      builder: (context, Box box, _) {
        bool isDarkMode = box.get('isDarkMode', defaultValue: false);
        String quote = box.get('motivationQuote', defaultValue: 'One task at a time. One step closer.');
        String? imagePath = box.get('profileImagePath');

        // التحقق مما إذا كانت الصورة موجودة وملفها الصوري فعلياً على الجهاز
        bool hasValidImage = imagePath != null && File(imagePath).existsSync();

        return Scaffold(
          appBar: AppBar(title: const Text('My Profile')),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // صورة البروفايل القابلة للتعديل
                  GestureDetector(
                    onTap: _showImagePickerOptions,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primary,
                          // إذا وجدت صورة صحيحة يتم عرضها، وإلا يتم ترك الـ backgroundImage فارغاً لتظهر الأيقونة الافتراضية داخل الـ child
                          backgroundImage: hasValidImage ? FileImage(File(imagePath)) : null,
                          child: !hasValidImage
                              ? const Icon(
                                  Icons.person,
                                  size: 55,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        // أيقونة الكاميرا الصغيرة للتوضيح أن الصورة قابلة للضغط
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.userName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quote,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: isDarkMode ? Colors.grey[400] : AppColors.greyText),
                  ),
                  const SizedBox(height: 24),

                  // الخيارات
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('User Details'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserDetailsScreen(
                            currentName: widget.userName,
                            onSave: widget.onNameUpdated,
                          ),
                        ),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.dark_mode_outlined),
                    title: const Text('Dark Mode'),
                    trailing: Switch(
                      value: isDarkMode,
                      activeThumbColor: AppColors.primary,
                      onChanged: _toggleDarkMode,
                    ),
                  ),

                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Log Out', style: TextStyle(color: Colors.red)),
                    onTap: _showLogoutDialog,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
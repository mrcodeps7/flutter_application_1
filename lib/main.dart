import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants.dart';
import 'models/task_model.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  Hive.registerAdapter(TaskModelAdapter());
  await Hive.openBox<TaskModel>('tasks');
  await Hive.openBox('settings');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsBox = Hive.box('settings');

    return ValueListenableBuilder(
      valueListenable: settingsBox.listenable(keys: ['isDarkMode', 'isFirstTime', 'userName']),
      builder: (context, Box box, _) {
        bool isDarkMode = box.get('isDarkMode', defaultValue: false);
        bool isFirstTime = box.get('isFirstTime', defaultValue: true);
        String userName = box.get('userName', defaultValue: 'Rand irany');

        return MaterialApp(
          title: 'Tasky',
          debugShowCheckedModeBanner: false,
          // إعداد الثيم الفاتح والداكن
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: AppColors.backgroundLight,
            fontFamily: 'Inter',
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: const Color(0xFF121212),
            cardColor: const Color(0xFF1E1E1E),
            fontFamily: 'Inter',
          ),
          home: isFirstTime 
              ? const OnboardingScreen() 
              : MainLayout(userName: userName),
        );
      },
    );
  }
}
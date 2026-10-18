import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'home_screen.dart';
import 'to_do_screen.dart';
import 'completed_screen.dart';
import 'profile_screen.dart';

class MainLayout extends StatefulWidget {
  final String userName;

  const MainLayout({super.key, required this.userName});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  late String _currentUserName;

  @override
  void initState() {
    super.initState();
    _currentUserName = widget.userName;
  }

  void _updateUserName(String newName) {
    setState(() {
      _currentUserName = newName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(userName: _currentUserName),
      const ToDoScreen(),
      const CompletedScreen(),
      ProfileScreen(
        userName: _currentUserName,
        onNameUpdated: _updateUserName,
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      // إضافة Padding سفلي لرفع الشريط عن أزرار النظام
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.greyText,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'To Do',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline),
              activeIcon: Icon(Icons.check_circle),
              label: 'Completed',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
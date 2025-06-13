import 'package:flutter/material.dart';
import 'package:study_mate/pages/HomePage.dart';
import 'package:study_mate/pages/Profile.dart';
import 'package:study_mate/pages/aibot.dart';
import 'package:study_mate/pages/questionlist.dart';
import 'package:study_mate/pages/upload.dart';
import 'package:study_mate/utilities/color_theme.dart';

class Mainpage extends StatefulWidget {
  const Mainpage({super.key});

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    const Homepage(),
    const ChatbotPage(),
    const QuestionListPage(),
    const Profile()
  ];

  @override
  Widget build(BuildContext context) {
    bool keyboardIsOpened = MediaQuery.of(context).viewInsets.bottom != 0.0;
    return SafeArea(
      child: Scaffold(
        body: _pages[_selectedIndex],
        floatingActionButton: !keyboardIsOpened
            ? FloatingActionButton(
                heroTag: null,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UploadNotesPage()));
                },
                backgroundColor: Colors.amber,
                shape: const CircleBorder(),
                child: const Icon(Icons.add, color: Colors.black),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.background,
                offset: Offset(0, -10), // negative y for shadow above
                blurRadius: 17,
                spreadRadius: 25,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: BottomAppBar(
              color: AppTheme.card,
              shape: const CircularNotchedRectangle(),
              notchMargin: 10,
              child: SizedBox(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTabItem(icon: Icons.home, index: 0),
                    _buildTabItem(icon: Icons.calendar_today, index: 1),
                    const SizedBox(width: 40), // Space for FAB
                    _buildTabItem(icon: Icons.chat_bubble_outline, index: 2),
                    _buildTabItem(icon: Icons.person_outline, index: 3),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({required IconData icon, required int index}) {
    final isSelected = _selectedIndex == index;
    return IconButton(
      icon: Icon(
        icon,
        color: isSelected ? Colors.amber : Colors.white54,
      ),
      onPressed: () => _onItemTapped(index),
    );
  }
}

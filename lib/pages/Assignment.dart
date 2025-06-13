// ignore: file_names
import 'package:flutter/material.dart';
import 'package:study_mate/Components/Online_Section.dart';
import 'package:study_mate/Components/Saved_section.dart';
import 'package:study_mate/utilities/color_theme.dart';

class AssignmentPage extends StatelessWidget {
  const AssignmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: AppTheme.background,
            title: const Text(
              'Assignments',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            bottom: const TabBar(
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: "Available Assignments"),
                Tab(text: "Saved Assignments"),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              NotesSection(notePrefix: "Available Note"),
              NotesSection(notePrefix: "Saved Note"),
            ],
          ),
        ),
      ),
    );
  }
}

class NotesSection extends StatelessWidget {
  final String notePrefix;
  const NotesSection({super.key, required this.notePrefix});

  @override
  Widget build(BuildContext context) {
    if (notePrefix == "Available Note") {
      return online_section(notePrefix: notePrefix);
    } else {
      return const SavedSectionLoader(
          fpath: '/storage/emulated/0/Download/StudyMate/Assignments/');
    }
  }
}

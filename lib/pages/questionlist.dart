import 'package:flutter/material.dart';
import 'package:study_mate/utilities/color_theme.dart';

class QuestionListPage extends StatefulWidget {
  const QuestionListPage({super.key});

  @override
  State<QuestionListPage> createState() => _QuestionListPageState();
}

class _QuestionListPageState extends State<QuestionListPage> {
  // All questions
  final List<Map<String, String>> allQuestions = [
    {"title": "Question 1", "date": "October 25, 2023"},
    {"title": "Question 2", "date": "October 24, 2023"},
    {"title": "Question 3", "date": "October 23, 2023"},
    {"title": "Question 4", "date": "October 22, 2023"},
    {"title": "Question 5", "date": "October 21, 2023"},
    {"title": "Question 6", "date": "October 20, 2023"},
    {"title": "Question 7", "date": "October 19, 2023"},
  ];

  List<Map<String, String>> visibleQuestions = [];

  bool showLoadMore = true;

  @override
  void initState() {
    super.initState();

    visibleQuestions = allQuestions.take(5).toList();
  }

  void loadMoreQuestions() {
    setState(() {
      visibleQuestions = allQuestions;
      showLoadMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.account_circle,
              size: 32, color: AppTheme.accentYellow),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                size: 30, color: AppTheme.accentYellow),
            onPressed: () {
              // Add question functionality
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: [
            ...visibleQuestions.map((q) => QuestionCard(
                  title: q["title"]!,
                  date: q["date"]!,
                )),
            const SizedBox(height: 10),
            if (showLoadMore)
              Center(
                child: TextButton(
                  onPressed: loadMoreQuestions,
                  child: const Text(
                    "Load more",
                    style: TextStyle(
                      color: AppTheme.accentYellow,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class QuestionCard extends StatelessWidget {
  final String title;
  final String date;

  const QuestionCard({required this.title, required this.date, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.card,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.image, size: 50, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Text(
              overflow: TextOverflow.ellipsis,
              title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              date,
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}

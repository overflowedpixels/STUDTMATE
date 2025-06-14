import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_mate/utilities/color_theme.dart';

// Question Model
class Question {
  final String id;
  final String title;
  final String postedBy;
  final String? image;
  final DateTime created;
  final bool hasReplies;

  Question({
    required this.id,
    required this.title,
    required this.postedBy,
    this.image,
    required this.created,
    required this.hasReplies,
  });

  factory Question.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Question(
      id: doc.id,
      title: data['title'] ?? '',
      postedBy: data['postedBy'] ?? '',
      image: data['image'],
      created: (data['created'] as Timestamp).toDate(),
      hasReplies: data['hasReplies'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'postedBy': postedBy,
      'image': image,
      'created': created,
      'hasReplies': hasReplies,
    };
  }
}

// Question Service
class QuestionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _questionsRef => _firestore.collection('questions');

  Future<void> addQuestion({
    required String title,
    required String postedBy,
    String? imageUrl,
  }) async {
    await _questionsRef.add({
      'title': title,
      'postedBy': postedBy,
      'image': imageUrl,
      'created': FieldValue.serverTimestamp(),
      'hasReplies': false,
    });
  }

  Stream<List<Question>> getQuestionsStream({int limit = 5}) {
    return _questionsRef
        .orderBy('created', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Question.fromFirestore(doc)).toList();
    });
  }

  Future<List<Question>> loadMoreQuestions({
    required DocumentSnapshot lastVisible,
    int limit = 5,
  }) async {
    final snapshot = await _questionsRef
        .orderBy('created', descending: true)
        .startAfterDocument(lastVisible)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => Question.fromFirestore(doc)).toList();
  }
}

// Main Question List Page
class QuestionListPage extends StatefulWidget {
  const QuestionListPage({super.key});

  @override
  State<QuestionListPage> createState() => _QuestionListPageState();
}

class _QuestionListPageState extends State<QuestionListPage> {
  final QuestionService _questionService = QuestionService();
  final List<Question> _questions = [];
  DocumentSnapshot? _lastVisible;
  bool _isLoading = false;
  bool _hasMore = true;
  final int _perPage = 5;

  @override
  void initState() {
    super.initState();
    _loadInitialQuestions();
  }

  Future<void> _loadInitialQuestions() async {
    setState(() => _isLoading = true);
    final questions = await _questionService.getQuestionsStream(limit: _perPage).first;
    if (questions.isNotEmpty) {
      _lastVisible = await _questionService._questionsRef.doc(questions.last.id).get();
    }
    setState(() {
      _questions.addAll(questions);
      _isLoading = false;
      _hasMore = questions.length == _perPage;
    });
  }

  Future<void> _loadMoreQuestions() async {
    if (!_hasMore || _isLoading) return;
    
    setState(() => _isLoading = true);
    final newQuestions = await _questionService.loadMoreQuestions(
      lastVisible: _lastVisible!,
      limit: _perPage,
    );
    
    if (newQuestions.isNotEmpty) {
      _lastVisible = await _questionService._questionsRef.doc(newQuestions.last.id).get();
    }
    
    setState(() {
      _questions.addAll(newQuestions);
      _isLoading = false;
      _hasMore = newQuestions.length == _perPage;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _extractUsername(String email) {
    return email.split('@')[0];
  }

  Future<void> _addNewQuestion() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AddQuestionDialog(),
    );
    
    if (result != null && result.isNotEmpty) {
      const currentUserEmail = 'current.user@student.edu'; // Replace with actual user email
      await _questionService.addQuestion(
        title: result,
        postedBy: currentUserEmail,
      );
      _questions.clear();
      await _loadInitialQuestions();
    }
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
          child: Icon(Icons.account_circle, size: 32, color: AppTheme.accentYellow),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 30, color: AppTheme.accentYellow),
            onPressed: _addNewQuestion,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _questions.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < _questions.length) {
                    final question = _questions[index];
                    return QuestionCard(
                      title: question.title,
                      created: _formatDate(question.created),
                      image: question.image,
                      postedBy: _extractUsername(question.postedBy),
                      hasReplies: question.hasReplies,
                      onReply: () {
                        // Navigate to replies page
                        print("Reply to: ${question.title}");
                      },
                      onReport: () {
                        // Handle report
                        print("Report: ${question.title}");
                      },
                    );
                  } else {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: _loadMoreQuestions,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentYellow,
                          ),
                          child: const Text(
                            'Load More',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            if (_isLoading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

// Question Card Widget
class QuestionCard extends StatelessWidget {
  final String title;
  final String created;
  final String? image;
  final String postedBy;
  final bool hasReplies;
  final VoidCallback onReply;
  final VoidCallback onReport;

  const QuestionCard({
    required this.title,
    required this.created,
    this.image,
    required this.postedBy,
    required this.hasReplies,
    required this.onReply,
    required this.onReport,
    super.key,
  });

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
            if (image != null) ...[
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    image!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.image, size: 50, color: Colors.grey[600]);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  created,
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.person, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  postedBy,
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onReply,
                    icon: Icon(
                      hasReplies ? Icons.reply_all : Icons.reply,
                      size: 18,
                      color: AppTheme.accentYellow,
                    ),
                    label: Text(
                      hasReplies ? "View Replies" : "Reply",
                      style: const TextStyle(
                        color: AppTheme.accentYellow,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onReport,
                    icon: const Icon(
                      Icons.flag_outlined,
                      size: 18,
                      color: Colors.redAccent,
                    ),
                    label: const Text(
                      "Report",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Add Question Dialog
class AddQuestionDialog extends StatefulWidget {
  const AddQuestionDialog({super.key});

  @override
  State<AddQuestionDialog> createState() => _AddQuestionDialogState();
}

class _AddQuestionDialogState extends State<AddQuestionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.card,
      title: const Text('Ask a Question', style: TextStyle(color: Colors.white)),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _questionController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter your question...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.accentYellow),
            ),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a question';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _questionController.text);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentYellow,
          ),
          child: const Text('Post', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}

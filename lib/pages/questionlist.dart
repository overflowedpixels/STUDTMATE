import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_mate/utilities/color_theme.dart';

// Enhanced Question Model with Replies
class Question {
  final String id;
  final String title;
  final String postedBy;
  final String? image;
  final DateTime created;
  final List<Reply> replies;

  Question({
    required this.id,
    required this.title,
    required this.postedBy,
    this.image,
    required this.created,
    required this.replies,
  });

  factory Question.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Question(
      id: doc.id,
      title: data['title'] ?? '',
      postedBy: data['postedBy'] ?? '',
      image: data['image'],
      created: (data['created'] as Timestamp).toDate(),
      replies: (data['replies'] as List<dynamic>? ?? [])
          .map((reply) => Reply.fromMap(reply))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'postedBy': postedBy,
      'image': image,
      'created': created,
      'replies': replies.map((reply) => reply.toMap()).toList(),
    };
  }

  bool get hasReplies => replies.isNotEmpty;
}

class Reply {
  final String id;
  final String content;
  final String postedBy;
  final DateTime created;
  final bool isReported;

  Reply({
    required this.id,
    required this.content,
    required this.postedBy,
    required this.created,
    this.isReported = false,
  });

  factory Reply.fromMap(Map<String, dynamic> map) {
    return Reply(
      id: map['id'] ?? '',
      content: map['content'] ?? '',
      postedBy: map['postedBy'] ?? '',
      created: (map['created'] as Timestamp).toDate(),
      isReported: map['isReported'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'postedBy': postedBy,
      'created': created,
      'isReported': isReported,
    };
  }
}

// Enhanced Question Service
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
      'replies': [],
    });
  }

  Future<void> addReply({
    required String questionId,
    required String content,
    required String postedBy,
  }) async {
    final reply = Reply(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      postedBy: postedBy,
      created: DateTime.now(),
    );

    await _questionsRef.doc(questionId).update({
      'replies': FieldValue.arrayUnion([reply.toMap()]),
    });
  }

  Future<void> reportReply({
    required String questionId,
    required String replyId,
  }) async {
    final questionDoc = await _questionsRef.doc(questionId).get();
    if (questionDoc.exists) {
      final question = Question.fromFirestore(questionDoc);
      final updatedReplies = question.replies.map((reply) {
        if (reply.id == replyId) {
          return reply..isReported = true;
        }
        return reply;
      }).toList();

      await _questionsRef.doc(questionId).update({
        'replies': updatedReplies.map((reply) => reply.toMap()).toList(),
      });
    }
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

  Future<Question?> getQuestion(String id) async {
    final doc = await _questionsRef.doc(id).get();
    return doc.exists ? Question.fromFirestore(doc) : null;
  }
}

// Main Question List Page with Enhanced Features
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
    try {
      final questions = await _questionService.getQuestionsStream(limit: _perPage).first;
      if (questions.isNotEmpty) {
        _lastVisible = await _questionService._questionsRef.doc(questions.last.id).get();
      }
      setState(() {
        _questions.addAll(questions);
        _isLoading = false;
        _hasMore = questions.length == _perPage;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading questions: $e')),
      );
    }
  }

  Future<void> _loadMoreQuestions() async {
    if (!_hasMore || _isLoading) return;
    
    setState(() => _isLoading = true);
    try {
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
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading more questions: $e')),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
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
      // In a real app, get current user email from auth
      const currentUserEmail = 'current.user@student.edu';
      
      try {
        await _questionService.addQuestion(
          title: result,
          postedBy: currentUserEmail,
        );
        _questions.clear();
        await _loadInitialQuestions();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post question: $e')),
        );
      }
    }
  }

  void _navigateToQuestionDetails(Question question) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionDetailsPage(
          question: question,
          questionService: _questionService,
          onReplyAdded: () {
            _questions.clear();
            _loadInitialQuestions();
          },
        ),
      ),
    );
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
                    return GestureDetector(
                      onTap: () => _navigateToQuestionDetails(question),
                      child: QuestionCard(
                        title: question.title,
                        created: _formatDate(question.created),
                        image: question.image,
                        postedBy: _extractUsername(question.postedBy),
                        hasReplies: question.hasReplies,
                        onReply: () => _navigateToQuestionDetails(question),
                        onReport: () {
                          // Handle report for the question itself
                          print("Report question: ${question.title}");
                        },
                      ),
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

// Question Details Page
class QuestionDetailsPage extends StatefulWidget {
  final Question question;
  final QuestionService questionService;
  final VoidCallback onReplyAdded;

  const QuestionDetailsPage({
    required this.question,
    required this.questionService,
    required this.onReplyAdded,
    super.key,
  });

  @override
  State<QuestionDetailsPage> createState() => _QuestionDetailsPageState();
}

class _QuestionDetailsPageState extends State<QuestionDetailsPage> {
  late Question _question;
  final TextEditingController _replyController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _question = widget.question;
    _loadQuestion();
  }

  Future<void> _loadQuestion() async {
    final updatedQuestion = await widget.questionService.getQuestion(_question.id);
    if (updatedQuestion != null) {
      setState(() {
        _question = updatedQuestion;
      });
    }
  }

  Future<void> _addReply() async {
    if (_replyController.text.isEmpty) return;
    
    setState(() => _isSubmitting = true);
    try {
      // In a real app, get current user email from auth
      const currentUserEmail = 'current.user@student.edu';
      
      await widget.questionService.addReply(
        questionId: _question.id,
        content: _replyController.text,
        postedBy: currentUserEmail,
      );
      
      _replyController.clear();
      await _loadQuestion();
      widget.onReplyAdded();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post reply: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _reportReply(String replyId) async {
    try {
      await widget.questionService.reportReply(
        questionId: _question.id,
        replyId: replyId,
      );
      await _loadQuestion();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reply reported successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to report reply: $e')),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _extractUsername(String email) {
    return email.split('@')[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.accentYellow),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Question Details',
          style: TextStyle(color: AppTheme.accentYellow),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Card
                  Card(
                    color: AppTheme.card,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_question.image != null) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                _question.image!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 200,
                                    color: Colors.grey[800],
                                    child: const Center(
                                      child: Icon(Icons.image, size: 50, color: Colors.grey),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          Text(
                            _question.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.person, size: 16, color: Colors.grey[400]),
                              const SizedBox(width: 4),
                              Text(
                                _extractUsername(_question.postedBy),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[400],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(Icons.access_time, size: 16, color: Colors.grey[400]),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(_question.created),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Replies Section
                  Text(
                    'Replies (${_question.replies.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  if (_question.replies.isEmpty)
                    const Center(
                      child: Text(
                        'No replies yet. Be the first to reply!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    ..._question.replies.map((reply) => _buildReplyCard(reply)).toList(),
                ],
              ),
            ),
          ),
          
          // Reply Input Section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.card,
              border: Border(top: BorderSide(color: Colors.grey[700]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Write a reply...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[800],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: 3,
                    minLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.send, color: AppTheme.accentYellow),
                  onPressed: _isSubmitting ? null : _addReply,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyCard(Reply reply) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _extractUsername(reply.postedBy),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Report'),
                      onTap: () => _reportReply(reply.id),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              reply.content,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(reply.created),
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
            if (reply.isReported)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(Icons.flag, size: 16, color: Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      'Reported',
                      style: TextStyle(
                        color: Colors.red[300],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Question Card Widget (updated)
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
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  image!,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(Icons.image, size: 50, color: Colors.grey),
                      ),
                    );
                  },
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
                Icon(Icons.person, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  postedBy,
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  created,
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

// Add Question Dialog (updated)
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
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
            const SizedBox(height: 16),
            // You can add image upload functionality here if needed
          ],
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

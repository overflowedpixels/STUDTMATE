import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utilities/color_theme.dart';

class OnlineSection extends StatefulWidget {
  const OnlineSection({super.key, required this.notePrefix});

  final String notePrefix;

  @override
  State<OnlineSection> createState() => _OnlineSectionState();
}

class _OnlineSectionState extends State<OnlineSection>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final List<DocumentSnapshot> _allDocuments = [];
  List<DocumentSnapshot> _displayedDocuments = [];

  final Map<int, double> _downloadProgress = {};
  final Map<int, bool> _isDownloading = {};

  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDoc;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _loadNotes();
    _searchController.addListener(_filterNotes);
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);
    final path = widget.notePrefix == 'Available Study Note'
          ? 'notes'
          : 'assignments';
    Query query = FirebaseFirestore.instance
        .collection(path)
        .orderBy('createdAt', descending: true)
        .limit(10);

    if (_lastDoc != null) {
      query = query.startAfterDocument(_lastDoc!);
    }

    final snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      _lastDoc = snapshot.docs.last;
      _allDocuments.addAll(snapshot.docs);
      _filterNotes();
    } else {
      _hasMore = false;
    }

    setState(() => _isLoading = false);
  }

  void _filterNotes() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      _displayedDocuments = query.isEmpty
          ? List.from(_allDocuments)
          : _allDocuments.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final title = (data['title'] ?? '').toString().toLowerCase();
              return title.contains(query);
            }).toList();
    });
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown date';
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> downloadFileWithProgress({
    required String filePathInStorage,
    required String fileName,
    required void Function(double) onProgressUpdate,
    required void Function(String? error) onDownloadComplete,
  }) async {
    try {
      final status = await Permission.storage.request();
      final status2 = await Permission.manageExternalStorage.request();

      if (!status.isGranted && !status2.isGranted) {
        onDownloadComplete('Storage permission denied');
        return;
      }

      final baseDir = await getExternalStorageDirectory();
      if (baseDir == null) {
        onDownloadComplete('Unable to access external storage');
        return;
      }

      final subDirName = widget.notePrefix == 'Available Study Note'
          ? 'Notes'
          : 'Assignments';

      final downloadDir = Directory('${baseDir.path}/StudyMate/$subDirName');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      final file = File('${downloadDir.path}/$fileName');

      final ref = FirebaseStorage.instance.ref(filePathInStorage);
      final downloadUrl = await ref.getDownloadURL();

      final dio = Dio();
      await dio.download(
        downloadUrl,
        file.path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgressUpdate(received / total);
          }
        },
      );

      onDownloadComplete(null);
    } catch (e) {
      onDownloadComplete(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _displayedDocuments.isEmpty && !_isLoading
                  ? _buildEmptyState()
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount:
                            _displayedDocuments.length + (_hasMore ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index < _displayedDocuments.length) {
                            final data =
                                _displayedDocuments[index].data()
                                    as Map<String, dynamic>;
                            return _buildNoteCard(data, index);
                          } else {
                            return _buildLoadMoreButton();
                          }
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Search your notes...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
              prefixIcon: Container(
                padding: const EdgeInsets.all(12),
                child: const Iconify(
                  Ic.round_search,
                  color: AppTheme.accentYellow,
                  size: 20,
                ),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: _searchController.clear,
                      icon: const Icon(
                        Icons.clear,
                        color: Colors.grey,
                        size: 20,
                      ),
                    )
                  : null,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[800]!, width: 1),
                borderRadius: BorderRadius.circular(16),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: AppTheme.accentYellow,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: AppTheme.card,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(Map<String, dynamic> data, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.accentYellow.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Iconify(
                                Ic.round_insert_drive_file,
                                color: AppTheme.accentYellow,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${data['title'] ?? 'Untitled'}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(data['createdAt']),
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'Contributed:@${data['userId']}',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.accentYellow.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                onPressed: _isDownloading[index] == true
                                    ? null
                                    : () => _downloadNote(data, index),
                                icon: const Iconify(
                                  Ic.round_file_download,
                                  color: AppTheme.accentYellow,
                                  size: 20,
                                ),
                                tooltip: 'Download Note',
                              ),
                            ),
                          ],
                        ),
                        if (_isDownloading[index] == true) ...[
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: _downloadProgress[index] ?? 0,
                            backgroundColor: Colors.grey[800],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.accentYellow,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _downloadNote(Map<String, dynamic> data, int index) async {
    setState(() {
      _isDownloading[index] = true;
      _downloadProgress[index] = 0.0;
    });

    final String? filePath = data['path'];
    final String fileName = (data['fileName'] ?? 'note.pdf')
        .toString()
        .replaceAll(" ", "");

    if (filePath == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Missing file path')));
      return;
    }

    await downloadFileWithProgress(
      filePathInStorage: filePath,
      fileName: fileName,
      onProgressUpdate: (prog) {
        setState(() {
          _downloadProgress[index] = prog;
        });
      },
      onDownloadComplete: (error) {
        setState(() {
          _isDownloading[index] = false;
        });

        final msg = error == null
            ? 'Download complete!'
            : 'Download failed: $error';

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text('No notes found.', style: TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildLoadMoreButton() {
    return TextButton(onPressed: _loadNotes, child: const Text("Load More"));
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'package:study_mate/firebaseservices/storageservice.dart';

class UploadNotesPage extends StatefulWidget {
  const UploadNotesPage({super.key});

  @override
  State<UploadNotesPage> createState() => _UploadNotesPageState();
}

class _UploadNotesPageState extends State<UploadNotesPage> {
  final TextEditingController _titleController = TextEditingController();
  String _selectedNoteType = 'Study Notes';
  File? _selectedFile;
  String? _fileName;
  bool _isUploading = false;

  final List<String> _noteTypes = ['Study Notes', 'Assignment'];

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _fileName = result.files.single.name;
        });
      }
    } catch (e) {
      _showSnackBar('Error picking file: $e', isError: true);
    }
  }

  Future<void> _uploadNote() async {
    if (_selectedFile == null || _titleController.text.trim().isEmpty) {
      _showSnackBar('Select file and enter description', isError: true);
      return;
    }

    setState(() => _isUploading = true);
    final uploader = NoteUploader();

    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId =
          user?.email?.replaceFirst('@gmail.com', '') ?? 'unknown_user';

      await uploader.uploadNote(
        file: _selectedFile!,
        title: _titleController.text.trim(),
        noteType: _selectedNoteType,
        userId: userId,
        fileName: _fileName,
      );

      // Attach progress listener AFTER uploadNote is called and uploadTask is initialized
      uploader.uploadTask?.snapshotEvents.listen((taskSnapshot) {
        final progress =
            taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
        print('Progress: ${(progress * 100).toStringAsFixed(2)}%');
      });

      _showSnackBar('Note uploaded successfully!');
      _resetForm();
    } catch (e) {
      _showSnackBar('Upload failed: $e', isError: true);
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _resetForm() {
    setState(() {
      _selectedFile = null;
      _fileName = null;
      _titleController.clear();
      _selectedNoteType = 'Study Notes';
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Upload Notes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Share your study materials with others',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),

            const SizedBox(height: 30),

            // Note Type Selection
            const Text(
              'Type',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[700]!, width: 1),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedNoteType,
                dropdownColor: const Color(0xFF1E1E1E),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFFFFD700),
                ),
                items: _noteTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedNoteType = newValue;
                    });
                  }
                },
              ),
            ),

            const SizedBox(height: 25),

            // File Selection
            const Text(
              'Select File',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedFile != null
                        ? const Color(0xFFFFD700)
                        : Colors.grey[700]!,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _selectedFile != null
                          ? Icons.check_circle_outline
                          : Icons.add_circle_outline,
                      size: 40,
                      color: _selectedFile != null
                          ? const Color(0xFFFFD700)
                          : Colors.grey[500],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _selectedFile != null
                          ? _fileName ?? 'File Selected'
                          : 'Tap to select file',
                      style: TextStyle(
                        color: _selectedFile != null
                            ? const Color(0xFFFFD700)
                            : Colors.grey[400],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_selectedFile == null) ...[
                      const SizedBox(height: 5),
                      Text(
                        'Supported: PDF, DOC, DOCX, TXT, JPG, PNG',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Description Input
            const Text(
              'Title',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[700]!, width: 1),
              ),
              child: TextField(
                controller: _titleController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Add a title to your notes...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Upload Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _uploadNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.black,
                          ),
                        ),
                      )
                    : const Text(
                        'Upload Note',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // Reset Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton(
                onPressed: _resetForm,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFFD700), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Reset Form',
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}

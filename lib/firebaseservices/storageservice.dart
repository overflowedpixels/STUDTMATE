import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class NoteUploader {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UploadTask? _uploadTask;

  /// Expose the current upload task for progress monitoring.
  UploadTask? get uploadTask => _uploadTask;

  /// Uploads the note file to Firebase Storage and stores metadata in Firestore.
  ///
  /// Returns the download URL of the uploaded file.
  Future<String> uploadNote({
    required File file,
    required String title,
    required String noteType,
    required String userId,
    String? fileName,

  }) async {
    final extension = file.path.split('.').last;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final storagePath = 'uploads/${noteType.toLowerCase().replaceAll(' ', '_')}/$timestamp.$extension';

    try {
      // Begin upload
      final ref = _storage.ref().child(storagePath);
      _uploadTask = ref.putFile(file);

      final snapshot = await _uploadTask!;
      final fileUrl = await snapshot.ref.getDownloadURL();
      final path = noteType == 'Study Notes'
          ? 'notes'
          : 'assignments';
      // Save note metadata
      await _firestore.collection(path).add({
        'type': noteType,
        'title': title.trim(),
        'fileName': fileName ?? file.path.split('/').last,
        'fileUrl': fileUrl,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'path':storagePath
      });

      return fileUrl;
    } catch (e) {
      rethrow;
    } finally {
      _uploadTask = null;
    }
  }
}

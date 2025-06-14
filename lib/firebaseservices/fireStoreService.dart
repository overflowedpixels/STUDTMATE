import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔵 Create Document
  Future<void> createDocument(String collection, String docId, Map<String, dynamic> data) async {
    await _db.collection(collection).doc(docId).set(data);
  }

  // 🔵 Read All Documents (Stream)
  Stream<List<Map<String, dynamic>>> readCollection(String collection) {
    return _db.collection(collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    });
  }

  // 🔵 Read Single Document (Future)
  Future<Map<String, dynamic>?> readDocument(String collection, String docId) async {
    final doc = await _db.collection(collection).doc(docId).get();
    return doc.exists ? doc.data() : null;
  }

  // 🔵 Update Document
  Future<void> updateDocument(String collection, String docId, Map<String, dynamic> newData) async {
    await _db.collection(collection).doc(docId).update(newData);
  }

  // 🔵 Delete Document
  Future<void> deleteDocument(String collection, String docId) async {
    await _db.collection(collection).doc(docId).delete();
  }
}

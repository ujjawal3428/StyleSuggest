import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection name in Firestore
  final String collection = 'clothes';

  Future<void> addClothingItem(Map<String, dynamic> data) async {
    await _db.collection(collection).add(data);
  }

  Future<void> updateClothingItem(String docId, Map<String, dynamic> data) async {
    await _db.collection(collection).doc(docId).update(data);
  }

  Future<void> deleteClothingItem(String docId) async {
    await _db.collection(collection).doc(docId).delete();
  }

  Stream<QuerySnapshot> getClothingItemsStream() {
    return _db.collection(collection).snapshots();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/devotional_video.dart';
import 'backend_state.dart';

class CatalogService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  static Stream<List<DevotionalVideo>> videos() {
    if (!BackendState.firebaseReady) return Stream.value(demoVideos);
    return _db.collection('videos')
        .where('isPublished', isEqualTo: true)
        .where('moderationStatus', isEqualTo: 'approved')
        .orderBy('publishedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(DevotionalVideo.fromSnapshot).toList());
  }

  static Stream<List<VideoCategory>> categories() {
    if (!BackendState.firebaseReady) return Stream.value(demoCategories);
    return _db.collection('categories')
        .where('isPublished', isEqualTo: true)
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(VideoCategory.fromSnapshot).toList());
  }

  static Future<void> toggleFavorite(String uid, String videoId, bool isFavorite) async {
    if (!BackendState.firebaseReady) return;
    final ref = _db.collection('users').doc(uid).collection('favorites').doc(videoId);
    if (isFavorite) {
      await ref.set({'videoId': videoId, 'savedAt': FieldValue.serverTimestamp()});
    } else {
      await ref.delete();
    }
  }
}

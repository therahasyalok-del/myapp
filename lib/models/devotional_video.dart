import 'package:cloud_firestore/cloud_firestore.dart';

class DevotionalVideo {
  const DevotionalVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.videoUrl,
    this.thumbnailUrl = '',
    this.durationSeconds = 0,
    this.featured = false,
    this.views = 0,
  });

  final String id, title, description, categoryId, categoryName, videoUrl, thumbnailUrl;
  final int durationSeconds, views;
  final bool featured;

  factory DevotionalVideo.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return DevotionalVideo(
      id: snapshot.id,
      title: data['title'] as String? ?? 'Untitled Darshan',
      description: data['description'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      categoryName: data['categoryName'] as String? ?? 'Devotion',
      videoUrl: data['videoUrl'] as String? ?? '',
      thumbnailUrl: data['thumbnailUrl'] as String? ?? '',
      durationSeconds: (data['durationSeconds'] as num?)?.toInt() ?? 0,
      featured: data['featured'] as bool? ?? false,
      views: (data['views'] as num?)?.toInt() ?? 0,
    );
  }
}

class VideoCategory {
  const VideoCategory({required this.id, required this.name, this.icon = '✨'});
  final String id, name, icon;

  factory VideoCategory.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return VideoCategory(id: snapshot.id, name: data['name'] as String? ?? snapshot.id, icon: data['icon'] as String? ?? '✨');
  }
}

const demoCategories = <VideoCategory>[
  VideoCategory(id: 'krishna-bhakti', name: 'Krishna Bhakti', icon: '🦚'),
  VideoCategory(id: 'radha-krishna', name: 'Radha Krishna', icon: '💛'),
  VideoCategory(id: 'mahadev', name: 'Mahadev', icon: '🔱'),
  VideoCategory(id: 'shri-ram', name: 'Shri Ram', icon: '🏹'),
  VideoCategory(id: 'hanuman', name: 'Hanuman Ji', icon: '🙏'),
  VideoCategory(id: 'maa-durga', name: 'Maa Durga', icon: '🌺'),
  VideoCategory(id: 'morning-darshan', name: 'Morning Darshan', icon: '🌅'),
  VideoCategory(id: 'aarti-bhajans', name: 'Aarti & Bhajans', icon: '🪔'),
  VideoCategory(id: 'spiritual-stories', name: 'Spiritual Stories', icon: '📿'),
  VideoCategory(id: 'temple-darshan', name: 'Temple Darshan', icon: '🛕'),
];

const demoVideos = <DevotionalVideo>[
  DevotionalVideo(id: 'demo-1', title: 'A peaceful morning with Shri Krishna', description: 'Begin your day with a moment of devotion, gratitude and peace.', categoryId: 'krishna-bhakti', categoryName: 'Krishna Bhakti', videoUrl: '', durationSeconds: 864, featured: true, views: 12800),
  DevotionalVideo(id: 'demo-2', title: 'Divine Vrindavan Darshan', description: 'A gentle glimpse into the timeless beauty of Vrindavan.', categoryId: 'temple-darshan', categoryName: 'Temple Darshan', videoUrl: '', durationSeconds: 642, views: 8400),
  DevotionalVideo(id: 'demo-3', title: 'Evening Aarti at the temple', description: 'Let the sound of the aarti bring calm to your evening.', categoryId: 'aarti-bhajans', categoryName: 'Aarti & Bhajans', videoUrl: '', durationSeconds: 510, views: 6700),
  DevotionalVideo(id: 'demo-4', title: 'Shiv Shambhu — a moment of stillness', description: 'A devotional offering to Mahadev.', categoryId: 'mahadev', categoryName: 'Mahadev', videoUrl: '', durationSeconds: 731, views: 5100),
];

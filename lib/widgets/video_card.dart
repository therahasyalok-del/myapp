import 'package:flutter/material.dart';
import '../models/devotional_video.dart';
import '../theme/app_theme.dart';

class VideoCard extends StatelessWidget {
  const VideoCard({super.key, required this.video, required this.onTap, this.isFavorite = false, this.onFavorite});
  final DevotionalVideo video;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback? onFavorite;

  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(fit: StackFit.expand, children: [
                _Thumbnail(url: video.thumbnailUrl, category: video.categoryName),
                Positioned(right: 10, bottom: 10, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.black.withValues(alpha: .72), borderRadius: BorderRadius.circular(8)), child: Text(_duration(video.durationSeconds), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)))),
                if (onFavorite != null) Positioned(right: 8, top: 8, child: IconButton.filledTonal(onPressed: onFavorite, icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.redAccent : Colors.white), style: IconButton.styleFrom(backgroundColor: Colors.black45))),
                const Center(child: CircleAvatar(radius: 23, backgroundColor: Colors.white70, child: Icon(Icons.play_arrow_rounded, color: AppTheme.deepSaffron, size: 32))),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(video.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, height: 1.25)),
                const SizedBox(height: 6),
                Text('${video.categoryName}  ·  ${_views(video.views)} views', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ]),
            ),
          ]),
        ),
      );

  static String _duration(int seconds) => '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
  static String _views(int count) => count >= 1000 ? '${(count / 1000).toStringAsFixed(1)}k' : '$count';
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.url, required this.category});
  final String url, category;
  @override
  Widget build(BuildContext context) => url.isNotEmpty
      ? Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallback(context))
      : _fallback(context);

  Widget _fallback(BuildContext context) => Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFF6D6A7), Color(0xFFD77D47)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: Stack(alignment: Alignment.center, children: [
          Positioned(right: -16, top: -34, child: Icon(Icons.wb_sunny_rounded, size: 150, color: Colors.white.withValues(alpha: .20))),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [const ShaligramMark(size: 48), const SizedBox(height: 8), Text(category, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, shadows: [Shadow(color: Colors.black26, blurRadius: 6)]))]),
        ]),
      );
}

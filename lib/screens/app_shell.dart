import 'package:flutter/material.dart';
import '../models/devotional_video.dart';
import '../services/backend_state.dart';
import '../services/catalog_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/video_card.dart';
import 'video_player_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0;
  final Set<String> _favorites = {};

  void _openVideo(DevotionalVideo video) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => VideoPlayerScreen(video: video, isFavorite: _favorites.contains(video.id), onFavorite: () => _toggleFavorite(video))));

  Future<void> _toggleFavorite(DevotionalVideo video) async {
    final next = !_favorites.contains(video.id);
    setState(() => next ? _favorites.add(video.id) : _favorites.remove(video.id));
    final user = AuthService.currentUser;
    if (user != null) {
      try { await CatalogService.toggleFavorite(user.uid, video.id, next); }
      catch (_) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not sync this favorite. Please try again.'))); }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign in to sync favorites across devices.')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(child: StreamBuilder<List<DevotionalVideo>>(
          stream: CatalogService.videos(),
          builder: (context, snapshot) {
            final videos = snapshot.data ?? (BackendState.firebaseReady ? const <DevotionalVideo>[] : demoVideos);
            final categories = demoCategories;
            if (snapshot.hasError && videos.isEmpty) return _problem(context, 'We could not load devotional videos.', () => setState(() {}));
            if (snapshot.connectionState == ConnectionState.waiting && videos.isEmpty) return const Center(child: CircularProgressIndicator());
            final pages = [
              _HomePage(videos: videos, categories: categories, favorites: _favorites, openVideo: _openVideo, toggleFavorite: _toggleFavorite, explore: () => setState(() => _tab = 1)),
              _ExplorePage(videos: videos, categories: categories, openVideo: _openVideo, favorites: _favorites, toggleFavorite: _toggleFavorite),
              _FavoritesPage(videos: videos.where((v) => _favorites.contains(v.id)).toList(), openVideo: _openVideo, favorites: _favorites, toggleFavorite: _toggleFavorite),
              const _ProfilePage(),
            ];
            return IndexedStack(index: _tab, children: pages);
          },
        )),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (index) => setState(() => _tab = index),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore_rounded), label: 'Explore'),
            NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Favorites'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      );

  Widget _problem(BuildContext context, String message, VoidCallback retry) => Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.cloud_off_rounded, size: 48), const SizedBox(height: 12), Text(message, textAlign: TextAlign.center), const SizedBox(height: 12), FilledButton(onPressed: retry, child: const Text('Try again'))])));
}

class _HomePage extends StatelessWidget {
  const _HomePage({required this.videos, required this.categories, required this.favorites, required this.openVideo, required this.toggleFavorite, required this.explore});
  final List<DevotionalVideo> videos;
  final List<VideoCategory> categories;
  final Set<String> favorites;
  final ValueChanged<DevotionalVideo> openVideo;
  final ValueChanged<DevotionalVideo> toggleFavorite;
  final VoidCallback explore;

  @override
  Widget build(BuildContext context) {
    final feature = videos.where((v) => v.featured).firstOrNull ?? (videos.isEmpty ? null : videos.first);
    return CustomScrollView(slivers: [
      SliverPadding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 8), sliver: SliverToBoxAdapter(child: Row(children: [const ShaligramMark(), const SizedBox(width: 11), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('SHALIGRAM', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.5)), Text('A little more devotion, every day', style: Theme.of(context).textTheme.bodySmall)]), const Spacer(), IconButton(onPressed: explore, icon: const Icon(Icons.search_rounded, size: 27))]))),
      SliverPadding(padding: const EdgeInsets.fromLTRB(20, 10, 20, 18), sliver: SliverToBoxAdapter(child: Text('Namaste 🙏\nFind a moment of peace.', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, height: 1.2)))),
      if (feature != null) SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 20), sliver: SliverToBoxAdapter(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const _SectionTitle(title: 'Today’s blessing', subtitle: 'A moment just for you'), const SizedBox(height: 10), _FeaturedCard(video: feature, onTap: () => openVideo(feature))]))),
      SliverPadding(padding: const EdgeInsets.fromLTRB(20, 24, 20, 0), sliver: SliverToBoxAdapter(child: Row(children: [const Expanded(child: _SectionTitle(title: 'Explore by devotion', subtitle: 'Find what speaks to your heart')), TextButton(onPressed: explore, child: const Text('See all'))]))),
      SliverToBoxAdapter(child: SizedBox(height: 92, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), scrollDirection: Axis.horizontal, itemCount: categories.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) => _CategoryChip(category: categories[i], onTap: explore)))),
      SliverPadding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 0), sliver: SliverToBoxAdapter(child: _SectionTitle(title: 'Daily Darshan', subtitle: 'Let serenity find you today'))),
      if (videos.isEmpty) const SliverToBoxAdapter(child: _EmptyState(message: 'Your daily darshan is on its way.')) else SliverPadding(padding: const EdgeInsets.fromLTRB(20, 10, 20, 0), sliver: SliverToBoxAdapter(child: SizedBox(height: 240, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: videos.length > 4 ? 4 : videos.length, separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (context, index) => SizedBox(width: 275, child: VideoCard(video: videos[index], onTap: () => openVideo(videos[index]), isFavorite: favorites.contains(videos[index].id), onFavorite: () => toggleFavorite(videos[index]))))))),
      SliverPadding(padding: const EdgeInsets.fromLTRB(20, 24, 20, 8), sliver: const SliverToBoxAdapter(child: _SectionTitle(title: 'Popular videos', subtitle: 'Beloved by our community'))),
      if (videos.isEmpty) const SliverToBoxAdapter(child: _EmptyState(message: 'New devotional videos will appear here.')) else SliverPadding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 24), sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) { final video = videos[index]; return Padding(padding: const EdgeInsets.only(bottom: 14), child: VideoCard(video: video, onTap: () => openVideo(video), isFavorite: favorites.contains(video.id), onFavorite: () => toggleFavorite(video))); }, childCount: videos.length > 5 ? 5 : videos.length))),
    ]);
  }
}

class _ExplorePage extends StatefulWidget {
  const _ExplorePage({required this.videos, required this.categories, required this.openVideo, required this.favorites, required this.toggleFavorite});
  final List<DevotionalVideo> videos; final List<VideoCategory> categories; final ValueChanged<DevotionalVideo> openVideo; final Set<String> favorites; final ValueChanged<DevotionalVideo> toggleFavorite;
  @override State<_ExplorePage> createState() => _ExplorePageState();
}
class _ExplorePageState extends State<_ExplorePage> {
  String _query = ''; String? _category;
  @override Widget build(BuildContext context) {
    final filtered = widget.videos.where((v) => (_category == null || v.categoryId == _category) && ('${v.title} ${v.categoryName} ${v.description}'.toLowerCase().contains(_query.toLowerCase()))).toList();
    return CustomScrollView(slivers: [
      SliverPadding(padding: const EdgeInsets.fromLTRB(20, 24, 20, 14), sliver: SliverToBoxAdapter(child: Text('Explore', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)))),
      SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 20), sliver: SliverToBoxAdapter(child: TextField(onChanged: (value) => setState(() => _query = value), decoration: const InputDecoration(hintText: 'Search videos, temples, bhajans…', prefixIcon: Icon(Icons.search))))),
      SliverToBoxAdapter(child: SizedBox(height: 60, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.fromLTRB(20, 12, 20, 0), children: [Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: const Text('All'), selected: _category == null, onSelected: (_) => setState(() => _category = null))), ...widget.categories.map((c) => Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text('${c.icon} ${c.name}'), selected: _category == c.id, onSelected: (_) => setState(() => _category = c.id))))]))),
      if (filtered.isEmpty) const SliverFillRemaining(hasScrollBody: false, child: _EmptyState(message: 'No videos found. Try another search.')) else SliverPadding(padding: const EdgeInsets.fromLTRB(20, 10, 20, 24), sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) { final video = filtered[index]; return Padding(padding: const EdgeInsets.only(bottom: 14), child: VideoCard(video: video, onTap: () => widget.openVideo(video), isFavorite: widget.favorites.contains(video.id), onFavorite: () => widget.toggleFavorite(video))); }, childCount: filtered.length))),
    ]);
  }
}

class _FavoritesPage extends StatelessWidget {
  const _FavoritesPage({required this.videos, required this.openVideo, required this.favorites, required this.toggleFavorite});
  final List<DevotionalVideo> videos; final ValueChanged<DevotionalVideo> openVideo; final Set<String> favorites; final ValueChanged<DevotionalVideo> toggleFavorite;
  @override Widget build(BuildContext context) => CustomScrollView(slivers: [SliverPadding(padding: const EdgeInsets.fromLTRB(20, 24, 20, 18), sliver: SliverToBoxAdapter(child: Text('Your favorites', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)))), if (videos.isEmpty) const SliverFillRemaining(hasScrollBody: false, child: _EmptyState(message: 'Save videos you love and find them here.')) else SliverPadding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 24), sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) { final v = videos[index]; return Padding(padding: const EdgeInsets.only(bottom: 14), child: VideoCard(video: v, onTap: () => openVideo(v), isFavorite: favorites.contains(v.id), onFavorite: () => toggleFavorite(v))); }, childCount: videos.length)))]);
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();
  @override Widget build(BuildContext context) { final user = AuthService.currentUser; return Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(children: [const ShaligramMark(size: 76), const SizedBox(height: 18), Text(user?.displayName ?? 'Welcome, devotee', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 6), Text(user?.email ?? 'Your peaceful space for daily devotion', textAlign: TextAlign.center), const SizedBox(height: 24), if (user == null) FilledButton.icon(onPressed: () => showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => const _SignInSheet()), icon: const Icon(Icons.login), label: const Text('Sign in or create account')) else OutlinedButton.icon(onPressed: () async { await AuthService.signOut(); (context as Element).markNeedsBuild(); }, icon: const Icon(Icons.logout), label: const Text('Sign out')), const SizedBox(height: 16), Text('Browse and watch freely — an account is optional.', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center), if (!BackendState.firebaseReady) const Padding(padding: EdgeInsets.only(top: 18), child: _SetupNotice())]))); }
}

class _SignInSheet extends StatefulWidget { const _SignInSheet(); @override State<_SignInSheet> createState() => _SignInSheetState(); }
class _SignInSheetState extends State<_SignInSheet> {
  final _email = TextEditingController(); final _password = TextEditingController(); bool _register = false, _loading = false; String? _error;
  @override void dispose() { _email.dispose(); _password.dispose(); super.dispose(); }
  Future<void> _run(Future<void> Function() action) async { setState(() { _loading = true; _error = null; }); try { await action(); if (mounted) Navigator.pop(context); } catch (e) { setState(() => _error = e.toString().replaceFirst('Exception: ', '')); } finally { if (mounted) setState(() => _loading = false); } }
  @override Widget build(BuildContext context) => Padding(padding: EdgeInsets.fromLTRB(22, 24, 22, MediaQuery.of(context).viewInsets.bottom + 24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [Text(_register ? 'Create your account' : 'Welcome back', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 16), if (!BackendState.firebaseReady) const _SetupNotice(), TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')), const SizedBox(height: 10), TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Password (6+ characters)')), if (_error != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(_error!, style: const TextStyle(color: Colors.red))), const SizedBox(height: 14), FilledButton(onPressed: _loading || !BackendState.firebaseReady ? null : () => _run(() async { if (_register) { await AuthService.emailRegister(_email.text, _password.text); } else { await AuthService.emailSignIn(_email.text, _password.text); } }), child: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Text(_register ? 'Create account' : 'Sign in')), OutlinedButton.icon(onPressed: _loading || !BackendState.firebaseReady ? null : () => _run(() async { await AuthService.googleSignIn(); }), icon: const Icon(Icons.g_mobiledata), label: const Text('Continue with Google')), TextButton(onPressed: () => setState(() => _register = !_register), child: Text(_register ? 'Already have an account? Sign in' : 'New here? Create an account'))]));
}

class _SetupNotice extends StatelessWidget { const _SetupNotice(); @override Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.gold.withValues(alpha: .16), borderRadius: BorderRadius.circular(14)), child: const Text('Firebase is not connected yet. Add your platform configuration to enable account features and the live video catalog.', style: TextStyle(fontSize: 13))); }

class _FeaturedCard extends StatelessWidget { const _FeaturedCard({required this.video, required this.onTap}); final DevotionalVideo video; final VoidCallback onTap; @override Widget build(BuildContext context) => ClipRRect(borderRadius: BorderRadius.circular(24), child: InkWell(onTap: onTap, child: SizedBox(height: 220, child: Stack(fit: StackFit.expand, children: [_HeroArtwork(category: video.categoryName, url: video.thumbnailUrl), Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xDD321809)], stops: [.25, 1]))), Positioned(left: 18, right: 18, bottom: 18, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('FEATURED DARSHAN', style: TextStyle(color: Color(0xFFFFD98A), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.6)), const SizedBox(height: 5), Text(video.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 19)), const SizedBox(height: 9), Row(children: [const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 23), const SizedBox(width: 7), Text('Watch now  ·  ${video.categoryName}', style: const TextStyle(color: Colors.white, fontSize: 12))])]))])))); }
class _HeroArtwork extends StatelessWidget { const _HeroArtwork({required this.category, required this.url}); final String category, url; @override Widget build(BuildContext context) => url.isNotEmpty ? Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _paint()) : _paint(); Widget _paint() => Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFE7AE5D), Color(0xFF9B4025)], begin: Alignment.topLeft, end: Alignment.bottomRight)), child: Stack(alignment: Alignment.center, children: [Positioned(right: 12, top: -65, child: Icon(Icons.wb_sunny_rounded, size: 260, color: Colors.white.withValues(alpha: .20))), const ShaligramMark(size: 88)])); }
class _SectionTitle extends StatelessWidget { const _SectionTitle({required this.title, this.subtitle}); final String title; final String? subtitle; @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)), if (subtitle != null) Padding(padding: const EdgeInsets.only(top: 3), child: Text(subtitle!, style: Theme.of(context).textTheme.bodySmall))]); }
class _CategoryChip extends StatelessWidget { const _CategoryChip({required this.category, required this.onTap}); final VideoCategory category; final VoidCallback onTap; @override Widget build(BuildContext context) => ActionChip(onPressed: onTap, avatar: Text(category.icon), label: Text(category.name), backgroundColor: Colors.white, side: BorderSide.none, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))); }
class _EmptyState extends StatelessWidget { const _EmptyState({required this.message}); final String message; @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.all(30), child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const ShaligramMark(size: 56), const SizedBox(height: 14), Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge)]))); }

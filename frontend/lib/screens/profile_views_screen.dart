import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/user.dart';
import '../services/profile_view_service.dart';
import '../services/match_service.dart';

class ProfileViewsScreen extends StatefulWidget {
  const ProfileViewsScreen({super.key});

  @override
  State<ProfileViewsScreen> createState() => _ProfileViewsScreenState();
}

class _ProfileViewsScreenState extends State<ProfileViewsScreen> {
  final _profileViewService = ProfileViewService();
  final _matchService = MatchService();
  List<User> _viewers = [];
  int _totalCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadViewers();
  }

  Future<void> _handleLike(User user) async {
    try {
      final result = await _matchService.swipe(
        targetUserId: user.id!,
        swipeType: 'LIKE',
      );
      if (result['matched'] == true && mounted) {
        // TODO: Navigate to chat or show match dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("It's a match!"),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> _loadViewers() async {
    try {
      final result = await _profileViewService.getWhoViewedMe();
      setState(() {
        _viewers = (result['viewers'] as List?)
                ?.map((j) => User.fromJson(j))
                .toList() ??
            [];
        _totalCount = result['totalCount'] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Who Viewed You',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryPink),
            )
          : RefreshIndicator(
              onRefresh: _loadViewers,
              color: AppTheme.primaryPink,
              child: _viewers.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.visibility_off_rounded,
                                  size: 80,
                                  color: AppTheme.textSecondary.withOpacity(0.4),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'No profile views yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Keep swiping! When someone likes you,\nthey\'ll show up here.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _viewers.length,
                      itemBuilder: (context, index) {
                        final user = _viewers[index];
                        return _ViewerCard(
                          user: user,
                          onLike: () => _handleLike(user),
                        );
                      },
                    ),
            ),
    );
  }
}

class _ViewerCard extends StatelessWidget {
  final User user;
  final VoidCallback onLike;

  const _ViewerCard({required this.user, required this.onLike});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: AppTheme.surfaceColor,
          backgroundImage: user.photos.isNotEmpty
              ? NetworkImage(user.photos.first.url)
              : null,
          child: user.photos.isEmpty
              ? const Icon(Icons.person_rounded, color: AppTheme.textSecondary)
              : null,
        ),
        title: Text(
          user.name,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          '${user.age} years old',
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
          ),
        ),
        trailing: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextButton(
            onPressed: onLike,
            child: const Text(
              'Like',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../models/user.dart';

class MatchCard extends StatefulWidget {
  final User user;
  final VoidCallback? onTap;
  final bool showOnlineStatus;

  const MatchCard({
    super.key,
    required this.user,
    this.onTap,
    this.showOnlineStatus = true,
  });

  @override
  State<MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 140,
          margin: const EdgeInsets.only(right: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImage(),
              const SizedBox(height: 8),
              _buildInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final photoUrl =
        widget.user.photos.isNotEmpty ? widget.user.photos.first : '';

    return Stack(
      children: [
        Container(
          width: 140,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: AppTheme.mediumRadius,
            gradient: AppTheme.primaryGradient,
          ),
          child: ClipRRect(
            borderRadius: AppTheme.mediumRadius,
            child: photoUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: photoUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
          ),
        ),
        // Gradient Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: AppTheme.mediumRadius,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                ],
                stops: const [0.6, 1.0],
              ),
            ),
          ),
        ),
        // Online Status
        if (widget.showOnlineStatus && widget.user.isOnline)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppTheme.successGreen,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
        // Verified Badge
        if (widget.user.isVerified)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.verified,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfo() {
    final age = _calculateAge(widget.user.dateOfBirth);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${widget.user.name}, $age',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        if (widget.user.city != null)
          Text(
            widget.user.city!,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  int _calculateAge(DateTime? birthDate) {
    if (birthDate == null) return 0;
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}

class ConversationCard extends StatelessWidget {
  final User user;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final VoidCallback? onTap;

  const ConversationCard({
    super.key,
    required this.user,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTime(lastMessageTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: unreadCount > 0
                              ? AppTheme.primaryPink
                              : AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          style: TextStyle(
                            fontSize: 14,
                            color: unreadCount > 0
                                ? AppTheme.textPrimary
                                : AppTheme.textSecondary,
                            fontWeight: unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final photoUrl = user.photos.isNotEmpty ? user.photos.first : '';

    return Stack(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.primaryGradient,
          ),
          child: ClipOval(
            child: photoUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: photoUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30,
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30,
                    ),
                  )
                : const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 30,
                  ),
          ),
        ),
        if (user.isOnline)
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppTheme.successGreen,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.darkBackground,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) return 'Yesterday';
      if (difference.inDays < 7) return '${difference.inDays}d ago';
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Now';
    }
  }
}

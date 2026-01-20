import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../models/user.dart';

class ProfileCard extends StatefulWidget {
  final User user;
  final VoidCallback? onLike;
  final VoidCallback? onPass;
  final VoidCallback? onSuperLike;
  final VoidCallback? onTap;
  final bool showActions;

  const ProfileCard({
    super.key,
    required this.user,
    this.onLike,
    this.onPass,
    this.onSuperLike,
    this.onTap,
    this.showActions = true,
  });

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  int _currentPhotoIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextPhoto() {
    if (widget.user.photos.isNotEmpty) {
      setState(() {
        _currentPhotoIndex =
            (_currentPhotoIndex + 1) % widget.user.photos.length;
      });
    }
  }

  void _previousPhoto() {
    if (widget.user.photos.isNotEmpty) {
      setState(() {
        _currentPhotoIndex = _currentPhotoIndex > 0
            ? _currentPhotoIndex - 1
            : widget.user.photos.length - 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight * 0.7;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: cardHeight,
          decoration: BoxDecoration(
            borderRadius: AppTheme.largeRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: AppTheme.largeRadius,
            child: Stack(
              children: [
                // Background Image
                _buildBackgroundImage(),

                // Gradient Overlay
                _buildGradientOverlay(),

                // Photo Indicators
                if (widget.user.photos.length > 1) _buildPhotoIndicators(),

                // User Info
                _buildUserInfo(),

                // Action Buttons
                if (widget.showActions) _buildActionButtons(),

                // Photo Navigation Areas
                if (widget.user.photos.length > 1) _buildPhotoNavigation(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    final photoUrl = widget.user.photos.isNotEmpty
        ? widget.user.photos[_currentPhotoIndex]
        : '';

    return Positioned.fill(
      child: photoUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: photoUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppTheme.surfaceColor,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryPink,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppTheme.surfaceColor,
                child: const Icon(
                  Icons.person,
                  size: 100,
                  color: AppTheme.textSecondary,
                ),
              ),
            )
          : Container(
              color: AppTheme.surfaceColor,
              child: const Icon(
                Icons.person,
                size: 100,
                color: AppTheme.textSecondary,
              ),
            ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.8),
            ],
            stops: const [0.4, 0.7, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoIndicators() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Row(
        children: List.generate(
          widget.user.photos.length,
          (index) => Expanded(
            child: Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: index == _currentPhotoIndex
                    ? Colors.white
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    final age = _calculateAge(widget.user.dateOfBirth);
    final distance = widget.user.distance?.toStringAsFixed(1) ?? '?';

    return Positioned(
      bottom: 80,
      left: 20,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and Age
          Row(
            children: [
              Expanded(
                child: Text(
                  '${widget.user.name}, $age',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.user.isVerified)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Location and Distance
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.user.city ?? 'Unknown'} • $distance km away',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Bio
          if (widget.user.bio != null && widget.user.bio!.isNotEmpty)
            Text(
              widget.user.bio!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 8,
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 12),

          // Interests
          if (widget.user.interests.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.user.interests.take(3).map((interest) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    interest,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pass Button
          _ActionButton(
            icon: Icons.close,
            color: AppTheme.errorRed,
            size: 60,
            onPressed: widget.onPass ?? () {},
          ),
          const SizedBox(width: 16),

          // Super Like Button
          _ActionButton(
            icon: Icons.star,
            color: AppTheme.accentBlue,
            size: 50,
            onPressed: widget.onSuperLike ?? () {},
          ),
          const SizedBox(width: 16),

          // Like Button
          _ActionButton(
            icon: Icons.favorite,
            color: AppTheme.successGreen,
            size: 60,
            onPressed: widget.onLike ?? () {},
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoNavigation() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _previousPhoto,
            child: Container(color: Colors.transparent),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: _nextPhoto,
            child: Container(color: Colors.transparent),
          ),
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

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.size,
    required this.onPressed,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
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
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            color: widget.color,
            size: widget.size * 0.5,
          ),
        ),
      ),
    );
  }
}

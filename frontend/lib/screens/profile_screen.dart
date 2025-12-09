import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userService = UserService();
  final _authService = AuthService();
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = await _userService.getProfile();
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.darkBackground, AppTheme.cardBackground],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _user == null
                ? const Center(child: Text('Failed to load profile'))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Profile Picture
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppTheme.primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryPink.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: _user!.photos.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    _user!.photos.first.url,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(Icons.person, size: 80, color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                        
                        // Name and Age
                        Text(
                          '${_user!.name}, ${_user!.age}',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _user!.email,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 30),
                        
                        // Bio
                        if (_user!.bio != null) ...[
                          _InfoCard(
                            title: 'About Me',
                            content: _user!.bio!,
                          ),
                          const SizedBox(height: 20),
                        ],
                        
                        // Interests
                        if (_user!.interests.isNotEmpty) ...[
                          _InfoCard(
                            title: 'Interests',
                            content: _user!.interests.join(', '),
                          ),
                          const SizedBox(height: 20),
                        ],
                        
                        // Location
                        if (_user!.city != null) ...[
                          _InfoCard(
                            title: 'Location',
                            content: '${_user!.city}, ${_user!.country ?? ""}',
                          ),
                          const SizedBox(height: 20),
                        ],
                        
                        // Preferences
                        _InfoCard(
                          title: 'Preferences',
                          content: 'Looking for ${_user!.interestedInGender ?? "anyone"}, '
                              'Age ${_user!.minAge ?? 18}-${_user!.maxAge ?? 100}, '
                              'Within ${_user!.maxDistance ?? 50} km',
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String content;

  const _InfoCard({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryPink,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

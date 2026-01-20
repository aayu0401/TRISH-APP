import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../services/block_service.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({Key? key}) : super(key: key);

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  final BlockService _blockService = BlockService();
  List<dynamic> _blockedUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    setState(() => _isLoading = true);
    final users = await _blockService.getBlockedUsers();
    setState(() {
      _blockedUsers = users;
      _isLoading = false;
    });
  }

  Future<void> _unblockUser(int userId, String userName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: Text(
          'Unblock $userName?',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: Text(
          'They will be able to see your profile and message you again.',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.white60),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Unblock',
              style: GoogleFonts.poppins(
                color: const Color(0xFFff6b9d),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await _blockService.unblockUser(userId);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$userName unblocked'),
            backgroundColor: Colors.green,
          ),
        );
        _loadBlockedUsers();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0f0c29), Color(0xFF302b63), Color(0xFF24243e)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Blocked Users',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFff6b9d),
                        ),
                      )
                    : _blockedUsers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.block_outlined,
                                  size: 80,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No blocked users',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _blockedUsers.length,
                            itemBuilder: (context, index) {
                              final block = _blockedUsers[index];
                              final blockedUser = block['blocked'];
                              
                              return FadeInUp(
                                delay: Duration(milliseconds: index * 50),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(12),
                                    leading: CircleAvatar(
                                      radius: 28,
                                      backgroundColor: Colors.grey[800],
                                      backgroundImage: blockedUser['photos'] != null &&
                                              (blockedUser['photos'] as List).isNotEmpty
                                          ? NetworkImage(
                                              blockedUser['photos'][0]['url'])
                                          : null,
                                      child: blockedUser['photos'] == null ||
                                              (blockedUser['photos'] as List).isEmpty
                                          ? Text(
                                              blockedUser['name'][0].toUpperCase(),
                                              style: GoogleFonts.poppins(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            )
                                          : null,
                                    ),
                                    title: Text(
                                      blockedUser['name'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Blocked',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.red,
                                      ),
                                    ),
                                    trailing: TextButton(
                                      onPressed: () => _unblockUser(
                                        blockedUser['id'],
                                        blockedUser['name'],
                                      ),
                                      style: TextButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFff6b9d).withOpacity(0.2),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        'Unblock',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFFff6b9d),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

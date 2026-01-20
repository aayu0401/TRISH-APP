import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'type': 'NEW_MATCH',
      'title': 'New Match! 💖',
      'body': 'You matched with Sarah!',
      'time': '2 min ago',
      'isRead': false,
    },
    {
      'type': 'NEW_MESSAGE',
      'title': 'New Message',
      'body': 'Emma sent you a message',
      'time': '1 hour ago',
      'isRead': false,
    },
    {
      'type': 'PROFILE_LIKED',
      'title': 'Someone likes you!',
      'body': 'Someone liked your profile',
      'time': '3 hours ago',
      'isRead': true,
    },
  ];

  IconData _getIconForType(String type) {
    switch (type) {
      case 'NEW_MATCH':
        return Icons.favorite;
      case 'NEW_MESSAGE':
        return Icons.message;
      case 'PROFILE_LIKED':
        return Icons.thumb_up;
      case 'GIFT_RECEIVED':
        return Icons.card_giftcard;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'NEW_MATCH':
        return const Color(0xFFff6b9d);
      case 'NEW_MESSAGE':
        return const Color(0xFF4facfe);
      case 'PROFILE_LIKED':
        return const Color(0xFFfeca57);
      case 'GIFT_RECEIVED':
        return const Color(0xFFee5a6f);
      default:
        return const Color(0xFF9b59b6);
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
                      'Notifications',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          for (var notification in _notifications) {
                            notification['isRead'] = true;
                          }
                        });
                      },
                      child: Text(
                        'Mark all read',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFff6b9d),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Notifications list
              Expanded(
                child: _notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 80,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No notifications yet',
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
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          return FadeInUp(
                            delay: Duration(milliseconds: index * 50),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: notification['isRead']
                                    ? Colors.white.withOpacity(0.03)
                                    : Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: notification['isRead']
                                      ? Colors.white.withOpacity(0.05)
                                      : _getColorForType(notification['type'])
                                          .withOpacity(0.3),
                                  width: notification['isRead'] ? 1 : 2,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        _getColorForType(notification['type']),
                                        _getColorForType(notification['type'])
                                            .withOpacity(0.6),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getIconForType(notification['type']),
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  notification['title'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      notification['body'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      notification['time'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.white38,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: !notification['isRead']
                                    ? Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: _getColorForType(
                                              notification['type']),
                                          shape: BoxShape.circle,
                                        ),
                                      )
                                    : null,
                                onTap: () {
                                  setState(() {
                                    notification['isRead'] = true;
                                  });
                                },
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

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/user.dart';
import '../models/match.dart';
import '../services/video_call_service.dart';
import '../services/auth_service.dart';
import '../utils/app_snackbar.dart';

enum CallState {
  idle,
  connecting,
  ringing,
  inCall,
  ended,
  failed,
}

class VideoCallScreen extends StatefulWidget {
  final Match match;
  final bool isInitiator;
  final int? callId;

  const VideoCallScreen({
    super.key,
    required this.match,
    this.isInitiator = true,
    this.callId,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final _videoCallService = VideoCallService();
  final _authService = AuthService();
  CallState _callState = CallState.idle;
  int? _callId;
  String _statusText = '';

  late User _otherUser;

  @override
  void initState() {
    super.initState();
    _otherUser = widget.match.user1;
    _authService.getUserId().then((id) {
      if (mounted) {
        setState(() {
          _otherUser = widget.match.getOtherUser(id ?? 0);
        });
      }
    });

    if (widget.isInitiator) {
      _startCall();
    } else {
      _callId = widget.callId;
      setState(() {
        _callState = _callId != null ? CallState.ringing : CallState.failed;
        _statusText = _callId != null ? 'Incoming call...' : 'Call session expired';
      });
    }
  }

  Future<void> _startCall() async {
    setState(() {
      _callState = CallState.connecting;
      _statusText = 'Connecting...';
    });

    try {
      final receiverId = _otherUser.id ?? 0;
      final result = await _videoCallService.startCall(receiverId);

      if (result['success'] == true && result['call'] != null) {
        final call = result['call'] as Map<String, dynamic>;
        _callId = call['id'] is int ? call['id'] as int : int.tryParse(call['id'].toString());
        setState(() {
          _callState = CallState.ringing;
          _statusText = 'Ringing...';
        });
      } else {
        _setFailed('Could not start call');
      }
    } catch (e) {
      _setFailed('Call failed. Video calling requires WebRTC integration.');
      if (mounted) {
        AppSnackBar.info(
          context,
          'Video call API is ready. Add Agora/Twilio SDK for full functionality.',
        );
      }
    }
  }

  Future<void> _answerCall() async {
    if (_callId == null) return;
    setState(() {
      _callState = CallState.connecting;
      _statusText = 'Connecting...';
    });

    try {
      final result = await _videoCallService.answerCall(_callId!);
      if (result['success'] == true) {
        setState(() {
          _callState = CallState.inCall;
          _statusText = 'Connected';
        });
      }
    } catch (e) {
      _setFailed('Could not answer');
    }
  }

  Future<void> _endCall() async {
    if (_callId != null) {
      try {
        await _videoCallService.endCall(_callId!, reason: 'User ended');
      } catch (_) {}
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _rejectCall() async {
    if (_callId != null) {
      try {
        await _videoCallService.rejectCall(_callId!);
      } catch (_) {}
    }
    if (mounted) Navigator.pop(context);
  }

  void _setFailed(String msg) {
    setState(() {
      _callState = CallState.failed;
      _statusText = msg;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.darkBackground.withOpacity(0.95),
                    Colors.black,
                  ],
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                CircleAvatar(
                  radius: 60,
                  backgroundColor: AppTheme.surfaceColor,
                  backgroundImage: _otherUser.photos.isNotEmpty
                      ? NetworkImage(_otherUser.photos.first.url)
                      : null,
                  child: _otherUser.photos.isEmpty
                      ? const Icon(Icons.person, size: 60, color: AppTheme.textSecondary)
                      : null,
                ),
                const SizedBox(height: 24),
                Text(
                  _otherUser.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _statusText,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const Spacer(flex: 2),
                _buildCallButtons(),
                const SizedBox(height: 48),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButtons() {
    if (_callState == CallState.failed) {
      return Column(
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (_callState == CallState.ringing && !widget.isInitiator) ...[
          _CallButton(
            icon: Icons.call_end_rounded,
            color: AppTheme.errorRed,
            onPressed: _rejectCall,
          ),
          _CallButton(
            icon: Icons.call_rounded,
            color: AppTheme.successGreen,
            onPressed: _answerCall,
          ),
        ] else ...[
          _CallButton(
            icon: Icons.call_end_rounded,
            color: AppTheme.errorRed,
            onPressed: _endCall,
          ),
        ],
      ],
    );
  }
}

class _CallButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _CallButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 36),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';

class AIAssistantOverlay extends StatefulWidget {
  final String context;
  
  const AIAssistantOverlay({super.key, this.context = 'general'});

  @override
  State<AIAssistantOverlay> createState() => _AIAssistantOverlayState();
}

class _AIAssistantOverlayState extends State<AIAssistantOverlay> {
  bool _isOpen = false;

  final Map<String, List<String>> _tips = {
    'home': [
      'Quality over quantity: AI matches are prioritized by compatibility.',
      'Try a Super Like to get 3x higher response rate.',
      'Your profile is currently being boosted by the Neural Engine.'
    ],
    'chat': [
      'Ask about their weekend plans to keep it casual.',
      'Safety check: This conversation is end-to-end encrypted.',
      'Use an AI Icebreaker to start a conversation.'
    ],
    'profile': [
      'Users with more than 3 photos get 70% more matches.',
      'Your bio is great, but adding interests helps AI matching.',
      'Verification badge increases trust score by 40%.'
    ],
    'general': [
      'TRISH AI learns from your preferences over time.',
      'Complete your personality audit for better accuracy.',
      'Upgrade to Premium for advanced neural filters.'
    ]
  };

  @override
  Widget build(BuildContext context) {
    final tips = _tips[widget.context] ?? _tips['general']!;
    
    return Stack(
      children: [
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _isOpen = false),
              child: Container(color: Colors.black54),
            ),
          ),
        Positioned(
          right: 20,
          bottom: 100, // Above bottom nav
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isOpen)
                FadeInUp(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    width: 280,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.glassmorphicDecoration(
                      borderRadius: AppTheme.mediumRadius,
                      color: AppTheme.cardBackground.withOpacity(0.9),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.psychology, color: AppTheme.primaryPink, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Neural Insights',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...tips.map((tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(color: AppTheme.primaryPink, fontWeight: FontWeight.bold)),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        )),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryPink.withOpacity(0.2),
                              foregroundColor: AppTheme.primaryPink,
                              elevation: 0,
                            ),
                            child: const Text('Ask AI Anything', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              GestureDetector(
                onTap: () => setState(() => _isOpen = !_isOpen),
                child: Hero(
                  tag: 'ai_assistant',
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryPink.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isOpen ? Icons.close : Icons.psychology,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

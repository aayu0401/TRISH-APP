import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import '../services/personality_service.dart';
import 'enhanced_home_screen.dart';

class PersonalityScreen extends StatefulWidget {
  const PersonalityScreen({super.key});

  @override
  State<PersonalityScreen> createState() => _PersonalityScreenState();
}

class _PersonalityScreenState extends State<PersonalityScreen> {
  final _personalityService = PersonalityService();
  int _currentQuestion = 0;
  final Map<String, dynamic> _answers = {};
  bool _isCompleted = false;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _result;

  // Expanded question set for a better "demo" feel
  final List<Map<String, dynamic>> _questions = [
    {
      'id': 'weekend_activity',
      'question': "It's Saturday night. Where can we find you?",
      'options': [
        "Exploring a hidden speakeasy",
        "Cozying up with a book or movie", 
        "Hosting a dinner party", 
        "Late night drive with music"
      ],
      'icons': [Icons.local_bar_rounded, Icons.menu_book_rounded, Icons.dinner_dining_rounded, Icons.directions_car_rounded]
    },
    {
      'id': 'decision_style',
      'question': "When making a big life decision, you trust:",
      'options': [
        "Pure hard logic & data", 
        "Your gut instinct & feelings", 
        "Advice from trusted friends", 
        "Signs from the universe"
      ],
      'icons': [Icons.analytics_rounded, Icons.volunteer_activism_rounded, Icons.people_alt_rounded, Icons.auto_awesome_rounded]
    },
    {
      'id': 'vacation_style',
      'question': "Pick your dream vacation vibe:",
      'options': [
        "Backpacking through mountains", 
        "Luxury resort & spa", 
        "Cultural city tour & museums", 
        "Foodie tour across Italy"
      ],
      'icons': [Icons.hiking_rounded, Icons.spa_rounded, Icons.museum_rounded, Icons.restaurant_rounded]
    },
    {
      'id': 'relationship_priority',
      'question': "In a partner, what matters most?",
      'options': [
        "Deep intellectual conversations", 
        "Shared sense of adventure", 
        "Emotional support & cuddling", 
        "Ambition & drive"
      ],
      'icons': [Icons.psychology_rounded, Icons.explore_rounded, Icons.favorite_rounded, Icons.rocket_launch_rounded]
    }
  ];

  void _handleAnswer(String questionId, String option) {
    setState(() {
      _answers[questionId] = option;
      if (_currentQuestion < _questions.length - 1) {
        _currentQuestion++;
      } else {
        _analyzePersonality();
      }
    });
  }

  Future<void> _analyzePersonality() async {
    setState(() {
      _isCompleted = true;
      _isAnalyzing = true;
    });

    // In a real scenario, we would send _answers to the backend
    // await _personalityService.takePersonalityTest(testType: 'lite', answers: _answers);
    
    // Simulating AI Analysis with a delay
    await Future.delayed(const Duration(seconds: 3));

    // Simple deterministic result for demo purposes
    // Logic: If they chose "Exploring" or "Backpacking" -> Adventurer, etc.
    String type = "The Visionary";
    String description = "You are imaginative, curious, and open-minded. You see possibilities where others see roadblocks. You need a partner who can keep up with your big ideas.";
    
    // Very basic mapping logic for demo variety
    final answersList = _answers.values.toList();
    if (answersList.toString().contains("Cozy") || answersList.toString().contains("Luxury")) {
      type = "The Nurturer";
      description = "You deeply value comfort, connection, and peace. You are the grounding force in your relationships, seeking a partner who values stability and genuine affection.";
    } else if (answersList.toString().contains("Hosting") || answersList.toString().contains("Ambition")) {
      type = "The Commander";
      description = "Bold, ambitious, and charismatic. You know what you want and go after it. You need a partner who is confident enough to stand beside you, not behind you.";
    }

    if (mounted) {
      setState(() {
        _result = {
          'type': type,
          'desc': description,
        };
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // Light Background Image
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1516541196182-6bdb0516ed27?w=1600', // Soft abstract aesthetic
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
             child: Container(
               decoration: BoxDecoration(
                 gradient: LinearGradient(
                   begin: Alignment.topCenter,
                   end: Alignment.bottomCenter,
                   colors: [
                     Colors.white.withOpacity(0.9),
                     Colors.white.withOpacity(0.7),
                   ],
                 ),
               ),
             ),
          ),

          SafeArea(
            child: !_isCompleted 
                ? _buildQuiz() 
                : _isAnalyzing 
                    ? _buildLoading() 
                    : _buildResult(),
          ),
          
          // Back button if not completed
          if (!_isCompleted)
            Positioned(
              top: 50,
              left: 20,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary),
                onPressed: () {
                   if (_currentQuestion > 0) {
                     setState(() => _currentQuestion--);
                   } else {
                     Navigator.pop(context);
                   }
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuiz() {
    final question = _questions[_currentQuestion];
    final options = question['options'] as List<String>;
    final icons = question['icons'] as List<IconData>;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 80),
          // Progress Bar
          Row(
            children: [
              Text(
                'Question ${_currentQuestion + 1}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryPink,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '/ ${_questions.length}',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentQuestion + 1) / _questions.length,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryPink),
              minHeight: 6,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Question Text
          FadeInDown(
            key: ValueKey(_currentQuestion), // Animate when question changes
            child: Text(
              question['question'],
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppTheme.textPrimary,
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Options
          Expanded(
            child: ListView.separated(
              itemCount: options.length,
              separatorBuilder: (c, i) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return FadeInUp(
                  delay: Duration(milliseconds: 100 * index),
                  child:  _buildOptionCard(
                    options[index], 
                    icons[index],
                    () => _handleAnswer(question['id'], options[index])
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(String text, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
          border: Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryPink.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryPink, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPink.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              color: AppTheme.primaryPink,
              strokeWidth: 4,
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Analyzing Your Soul...',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Our AI is finding your perfect archetype',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: FadeInUp(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPink.withOpacity(0.4),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 60),
              ),
              const SizedBox(height: 32),
              Text(
                'YOU ARE',
                style: TextStyle(
                  fontSize: 14,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondary.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _result!['type'].toUpperCase(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPink.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Text(
                  _result!['desc'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    height: 1.6,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const EnhancedHomeScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPink,
                    elevation: 10,
                    shadowColor: AppTheme.primaryPink.withOpacity(0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'FIND MY MATCHES',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                 onPressed: () {
                   setState(() {
                     _isCompleted = false;
                     _currentQuestion = 0;
                     _answers.clear();
                   });
                 },
                 child: const Text('Retake Test', style: TextStyle(color: AppTheme.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

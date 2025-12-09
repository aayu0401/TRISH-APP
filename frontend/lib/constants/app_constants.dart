class AppConstants {
  // App Info
  static const String appName = 'Trish';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'AI-Powered Dating with Heart';
  
  // API Endpoints
  static const String authEndpoint = '/api/auth';
  static const String userEndpoint = '/api/users';
  static const String matchEndpoint = '/api/matches';
  static const String messageEndpoint = '/api/messages';
  static const String walletEndpoint = '/api/wallet';
  static const String giftEndpoint = '/api/gifts';
  static const String kycEndpoint = '/api/kyc';
  static const String personalityEndpoint = '/api/personality';
  static const String subscriptionEndpoint = '/api/subscription';
  static const String aiEndpoint = '/api/ai';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String notificationsKey = 'notifications_enabled';
  
  // Validation
  static const int minAge = 18;
  static const int maxAge = 100;
  static const int minBioLength = 10;
  static const int maxBioLength = 500;
  static const int maxPhotos = 6;
  static const int minPhotos = 2;
  static const double maxDistanceKm = 100;
  static const double minDistanceKm = 1;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;
  
  // File Upload
  static const int maxImageSizeMB = 10;
  static const int maxVideoSizeMB = 50;
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> allowedVideoFormats = ['mp4', 'mov', 'avi'];
  
  // Subscription Plans
  static const Map<String, dynamic> freePlan = {
    'name': 'Free',
    'price': 0,
    'features': [
      'Basic matching',
      '5 likes per day',
      'Limited filters',
      'Standard support',
    ],
  };
  
  static const Map<String, dynamic> basicPlan = {
    'name': 'Basic',
    'price': 499,
    'duration': '1 month',
    'features': [
      'Unlimited likes',
      'See who liked you',
      'Advanced filters',
      'Priority support',
      '5 super likes per week',
    ],
  };
  
  static const Map<String, dynamic> premiumPlan = {
    'name': 'Premium',
    'price': 999,
    'duration': '1 month',
    'features': [
      'All Basic features',
      'Unlimited super likes',
      'Profile boost',
      'Read receipts',
      'AI chat assistance',
      'Personality insights',
      'No ads',
    ],
  };
  
  static const Map<String, dynamic> platinumPlan = {
    'name': 'Platinum',
    'price': 1999,
    'duration': '1 month',
    'features': [
      'All Premium features',
      'Priority matching',
      'Exclusive badges',
      'Advanced analytics',
      'Relationship coaching',
      'Video chat',
      'Gift vouchers',
    ],
  };
  
  // Gift Categories
  static const List<String> giftCategories = [
    'Flowers',
    'Chocolates',
    'Jewelry',
    'Gadgets',
    'Experiences',
    'Subscription',
    'Virtual',
    'Other',
  ];
  
  // Personality Traits
  static const List<String> personalityTraits = [
    'Adventurous',
    'Ambitious',
    'Artistic',
    'Athletic',
    'Caring',
    'Creative',
    'Curious',
    'Empathetic',
    'Energetic',
    'Funny',
    'Generous',
    'Honest',
    'Intelligent',
    'Kind',
    'Loyal',
    'Optimistic',
    'Passionate',
    'Patient',
    'Reliable',
    'Romantic',
  ];
  
  // Interests
  static const List<String> commonInterests = [
    'Travel',
    'Music',
    'Movies',
    'Sports',
    'Fitness',
    'Cooking',
    'Reading',
    'Photography',
    'Art',
    'Gaming',
    'Dancing',
    'Yoga',
    'Hiking',
    'Cycling',
    'Swimming',
    'Meditation',
    'Writing',
    'Fashion',
    'Technology',
    'Food',
  ];
  
  // Love Languages
  static const List<String> loveLanguages = [
    'Words of Affirmation',
    'Quality Time',
    'Physical Touch',
    'Acts of Service',
    'Receiving Gifts',
  ];
  
  // Communication Styles
  static const List<String> communicationStyles = [
    'Direct',
    'Thoughtful',
    'Playful',
    'Emotional',
    'Logical',
  ];
  
  // Attachment Styles
  static const List<String> attachmentStyles = [
    'Secure',
    'Anxious',
    'Avoidant',
    'Fearful-Avoidant',
  ];
  
  // Safety Tips
  static const List<String> safetyTips = [
    'Meet in public places for first dates',
    'Tell a friend about your plans',
    'Don\'t share personal information too soon',
    'Trust your instincts',
    'Use in-app messaging initially',
    'Verify profiles before meeting',
    'Report suspicious behavior',
    'Keep your location private',
  ];
  
  // Red Flags
  static const List<String> redFlags = [
    'Asking for money',
    'Pressuring for personal info',
    'Inconsistent stories',
    'Avoiding video calls',
    'Moving too fast',
    'Disrespectful behavior',
    'Refusing to meet in public',
    'Excessive compliments',
  ];
  
  // Icebreaker Categories
  static const List<String> icebreakerCategories = [
    'Fun & Quirky',
    'Deep & Meaningful',
    'Travel & Adventure',
    'Food & Drinks',
    'Hobbies & Interests',
    'Life Goals',
    'Entertainment',
    'Hypothetical',
  ];
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 2);
  
  // Error Messages
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String authError = 'Authentication failed. Please login again.';
  static const String validationError = 'Please check your input and try again.';
  static const String unknownError = 'Something went wrong. Please try again.';
  
  // Success Messages
  static const String profileUpdated = 'Profile updated successfully!';
  static const String messageSent = 'Message sent successfully!';
  static const String matchFound = 'It\'s a match! 🎉';
  static const String giftSent = 'Gift sent successfully!';
  static const String paymentSuccess = 'Payment completed successfully!';
  static const String kycSubmitted = 'KYC submitted for verification!';
  
  // Regex Patterns
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp phoneRegex = RegExp(
    r'^\+?[1-9]\d{1,14}$',
  );
  static final RegExp aadharRegex = RegExp(
    r'^\d{12}$',
  );
  static final RegExp panRegex = RegExp(
    r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$',
  );
}

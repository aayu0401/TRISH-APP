# TRISH Dating App - Quick Component Reference

## 🎨 Premium UI Components

### PremiumButton

```dart
import '../widgets/premium_button.dart';

// Primary Button
PremiumButton(
  text: 'Sign In',
  type: ButtonType.primary,
  onPressed: () {},
)

// Gradient Button
PremiumButton(
  text: 'Get Started',
  type: ButtonType.gradient,
  icon: Icons.arrow_forward,
  onPressed: () {},
)

// Outline Button
PremiumButton(
  text: 'Cancel',
  type: ButtonType.outline,
  onPressed: () {},
)

// Glass Button
PremiumButton(
  text: 'Continue',
  type: ButtonType.glass,
  isFullWidth: true,
  onPressed: () {},
)

// Loading State
PremiumButton(
  text: 'Loading...',
  type: ButtonType.primary,
  isLoading: true,
  onPressed: () {},
)
```

### ProfileCard

```dart
import '../widgets/profile_card.dart';

ProfileCard(
  user: userObject,
  showActions: true,
  onLike: () {
    // Handle like
  },
  onPass: () {
    // Handle pass
  },
  onSuperLike: () {
    // Handle super like
  },
  onTap: () {
    // View full profile
  },
)
```

### ChatBubble

```dart
import '../widgets/chat_bubble.dart';

// Sent Message
ChatBubble(
  message: messageObject,
  isMe: true,
  showAvatar: true,
  avatarUrl: 'https://...',
)

// Received Message
ChatBubble(
  message: messageObject,
  isMe: false,
  showAvatar: true,
  avatarUrl: 'https://...',
)

// Typing Indicator
TypingIndicator()
```

### Loading States

```dart
import '../widgets/loading_widgets.dart';

// Shimmer Loading
LoadingShimmers.profileCard()
LoadingShimmers.matchCard()
LoadingShimmers.chatMessage(isMe: false)
LoadingShimmers.listItem()
LoadingShimmers.gridItem()

// Loading Overlay
LoadingOverlay(
  isLoading: _isLoading,
  message: 'Please wait...',
  child: YourWidget(),
)

// Pulse Animation
PulseAnimation(
  duration: Duration(milliseconds: 1000),
  child: YourWidget(),
)
```

### Match Widgets

```dart
import '../widgets/match_widgets.dart';

// Match Card
MatchCard(
  user: userObject,
  showOnlineStatus: true,
  onTap: () {
    // Navigate to chat
  },
)

// Conversation Card
ConversationCard(
  user: userObject,
  lastMessage: 'Hey, how are you?',
  lastMessageTime: DateTime.now(),
  unreadCount: 3,
  onTap: () {
    // Open chat
  },
)
```

### Card Widgets

```dart
import '../widgets/card_widgets.dart';

// Glass Card
GlassCard(
  padding: EdgeInsets.all(16),
  child: Text('Content'),
  onTap: () {},
)

// Gradient Card
GradientCard(
  gradient: AppTheme.primaryGradient,
  child: Text('Content'),
)

// Stat Card
StatCard(
  title: 'Total Matches',
  value: '42',
  icon: Icons.favorite,
  gradient: AppTheme.primaryGradient,
  onTap: () {},
)

// Feature Card
FeatureCard(
  title: 'Premium Features',
  description: 'Unlock all features',
  icon: Icons.star,
  gradient: AppTheme.goldGradient,
  onTap: () {},
)

// Info Badge
InfoBadge(
  text: 'Verified',
  gradient: AppTheme.primaryGradient,
  icon: Icons.verified,
)

// Progress Card
ProgressCard(
  title: 'Profile Completion',
  progress: 0.75,
  progressText: '75%',
  gradient: AppTheme.primaryGradient,
)
```

## 🎨 Theme Usage

```dart
import '../theme/app_theme.dart';

// Colors
AppTheme.primaryPink
AppTheme.primaryPurple
AppTheme.accentOrange
AppTheme.accentBlue
AppTheme.darkBackground
AppTheme.cardBackground
AppTheme.surfaceColor
AppTheme.textPrimary
AppTheme.textSecondary
AppTheme.successGreen
AppTheme.errorRed

// Gradients
AppTheme.primaryGradient
AppTheme.accentGradient
AppTheme.blueGradient
AppTheme.goldGradient
AppTheme.darkGradient

// Shadows
AppTheme.cardShadow
AppTheme.glowShadow

// Border Radius
AppTheme.smallRadius
AppTheme.mediumRadius
AppTheme.largeRadius
AppTheme.extraLargeRadius

// Helper Methods
AppTheme.gradientBoxDecoration(
  gradient: AppTheme.primaryGradient,
  borderRadius: AppTheme.mediumRadius,
  boxShadow: AppTheme.cardShadow,
)

AppTheme.glassmorphicDecoration(
  color: AppTheme.surfaceColor,
  borderRadius: AppTheme.mediumRadius,
  blur: 10,
)
```

## 🔄 Common Patterns

### Animated Button Press

```dart
class MyButton extends StatefulWidget {
  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton>
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
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: YourWidget(),
      ),
    );
  }
}
```

### Gradient Text

```dart
ShaderMask(
  shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
  child: Text(
    'TRISH',
    style: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
)
```

### Glassmorphic Container

```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: AppTheme.glassmorphicDecoration(),
  child: YourContent(),
)
```

### Gradient Background

```dart
Container(
  decoration: BoxDecoration(
    gradient: AppTheme.primaryGradient,
  ),
  child: YourContent(),
)
```

### Card with Shadow

```dart
Container(
  decoration: BoxDecoration(
    color: AppTheme.cardBackground,
    borderRadius: AppTheme.mediumRadius,
    boxShadow: AppTheme.cardShadow,
  ),
  child: YourContent(),
)
```

## 📱 Screen Layouts

### Standard Screen Layout

```dart
Scaffold(
  body: Container(
    decoration: BoxDecoration(
      gradient: AppTheme.darkGradient,
    ),
    child: SafeArea(
      child: Column(
        children: [
          // Header
          _buildHeader(),
          
          // Content
          Expanded(
            child: _buildContent(),
          ),
          
          // Bottom Actions
          _buildBottomActions(),
        ],
      ),
    ),
  ),
)
```

### List with Loading

```dart
_isLoading
  ? ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => LoadingShimmers.listItem(),
    )
  : ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => YourListItem(items[index]),
    )
```

### Grid with Loading

```dart
_isLoading
  ? GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => LoadingShimmers.gridItem(),
    )
  : GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => YourGridItem(items[index]),
    )
```

## 🎬 Animations

### Fade In

```dart
import 'package:animate_do/animate_do.dart';

FadeIn(
  duration: Duration(milliseconds: 600),
  child: YourWidget(),
)
```

### Slide In

```dart
FadeInUp(
  delay: Duration(milliseconds: 200),
  duration: Duration(milliseconds: 600),
  child: YourWidget(),
)

FadeInDown(
  duration: Duration(milliseconds: 600),
  child: YourWidget(),
)
```

### Zoom In

```dart
ZoomIn(
  duration: Duration(milliseconds: 500),
  child: YourWidget(),
)
```

### Bounce

```dart
BounceInDown(
  duration: Duration(milliseconds: 800),
  child: YourWidget(),
)
```

## 🔔 Notifications

### Success Snackbar

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(
      children: [
        Icon(Icons.check_circle, color: Colors.white),
        SizedBox(width: 12),
        Expanded(child: Text('Success!')),
      ],
    ),
    backgroundColor: AppTheme.successGreen,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
);
```

### Error Snackbar

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(
      children: [
        Icon(Icons.error_outline, color: Colors.white),
        SizedBox(width: 12),
        Expanded(child: Text('Error occurred')),
      ],
    ),
    backgroundColor: AppTheme.errorRed,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
);
```

## 🎯 Best Practices

1. **Always use theme colors** instead of hardcoded values
2. **Add loading states** for better UX
3. **Use animations** for smooth transitions
4. **Implement error handling** with user-friendly messages
5. **Test on different screen sizes**
6. **Optimize images** with CachedNetworkImage
7. **Use const constructors** where possible
8. **Follow Material Design** guidelines
9. **Keep widgets small** and reusable
10. **Add accessibility** labels

## 📚 Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Material Design](https://material.io/design)
- [Animate Do Package](https://pub.dev/packages/animate_do)
- [Shimmer Package](https://pub.dev/packages/shimmer)
- [Cached Network Image](https://pub.dev/packages/cached_network_image)

---

**Quick Start**: Import the widget you need and follow the examples above!

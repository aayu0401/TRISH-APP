import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  final List<NavItem> _items = [
    NavItem(icon: Icons.explore, label: 'Discover'),
    NavItem(icon: Icons.favorite, label: 'Matches'),
    NavItem(icon: Icons.chat_bubble, label: 'Messages'),
    NavItem(icon: Icons.person, label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _items.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    // Animate current index
    _controllers[widget.currentIndex].forward();
  }

  @override
  void didUpdateWidget(CustomBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _controllers[oldWidget.currentIndex].reverse();
      _controllers[widget.currentIndex].forward();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onItemTapped(int index) {
    HapticFeedback.lightImpact();
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1a1a2e).withOpacity(0.95),
            const Color(0xFF16213e).withOpacity(0.98),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        child: Stack(
          children: [
            // Animated indicator
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: (MediaQuery.of(context).size.width / _items.length) *
                      widget.currentIndex +
                  (MediaQuery.of(context).size.width / _items.length / 2) -
                  20,
              top: 5,
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFff6b9d), Color(0xFFfeca57)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFff6b9d).withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),

            // Nav items
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                final isSelected = widget.currentIndex == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onItemTapped(index),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 8),
                          AnimatedBuilder(
                            animation: _animations[index],
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _animations[index].value,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: isSelected
                                      ? BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFff6b9d),
                                              Color(0xFFc06c84),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFFff6b9d)
                                                  .withOpacity(0.3),
                                              blurRadius: 12,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        )
                                      : null,
                                  child: Icon(
                                    item.icon,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.5),
                                    size: 24,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? const Color(0xFFff6b9d)
                                  : Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;

  NavItem({required this.icon, required this.label});
}

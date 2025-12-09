import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import '../models/gift.dart';
import '../services/gift_service.dart';

class GiftsScreen extends StatefulWidget {
  final String? matchId;
  
  const GiftsScreen({super.key, this.matchId});

  @override
  State<GiftsScreen> createState() => _GiftsScreenState();
}

class _GiftsScreenState extends State<GiftsScreen> with SingleTickerProviderStateMixin {
  final GiftService _giftService = GiftService();
  late TabController _tabController;
  
  List<Gift> _gifts = [];
  List<GiftTransaction> _sentGifts = [];
  List<GiftTransaction> _receivedGifts = [];
  GiftCategory? _selectedCategory;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadGifts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadGifts() async {
    setState(() => _isLoading = true);
    
    final gifts = await _giftService.getAllGifts(category: _selectedCategory);
    final sent = await _giftService.getSentGifts();
    final received = await _giftService.getReceivedGifts();
    
    setState(() {
      _gifts = gifts;
      _sentGifts = sent;
      _receivedGifts = received;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.darkGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildCategoryFilter(),
              _buildTabBar(),
              Expanded(child: _buildTabBarView()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Gift Store',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              // Show cart
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: GiftCategory.values.length,
        itemBuilder: (context, index) {
          final category = GiftCategory.values[index];
          final isSelected = _selectedCategory == category;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_getCategoryLabel(category)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = selected ? category : null;
                });
                _loadGifts();
              },
              backgroundColor: AppTheme.cardBackground,
              selectedColor: AppTheme.primaryPink,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: AppTheme.mediumRadius,
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: AppTheme.mediumRadius,
          ),
          labelColor: Colors.white,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'Browse'),
            Tab(text: 'Sent'),
            Tab(text: 'Received'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildGiftGrid(),
        _buildSentGiftsList(),
        _buildReceivedGiftsList(),
      ],
    );
  }

  Widget _buildGiftGrid() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_gifts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_giftcard_outlined,
              size: 80,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No gifts available',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _gifts.length,
      itemBuilder: (context, index) {
        final gift = _gifts[index];
        return FadeInUp(
          delay: Duration(milliseconds: 50 * index),
          child: _buildGiftCard(gift),
        );
      },
    );
  }

  Widget _buildGiftCard(Gift gift) {
    return InkWell(
      onTap: () => _showGiftDetails(gift),
      borderRadius: AppTheme.mediumRadius,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: AppTheme.mediumRadius,
          border: Border.all(
            color: AppTheme.textTertiary.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gift Image
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getGiftIcon(gift.category),
                    size: 60,
                    color: AppTheme.primaryPink,
                  ),
                ),
              ),
            ),
            // Gift Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gift.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${gift.currency} ${gift.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppTheme.primaryPink,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: gift.type == GiftType.virtual
                              ? AppTheme.accentBlue.withOpacity(0.2)
                              : AppTheme.accentOrange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          gift.type == GiftType.virtual ? 'Virtual' : 'Physical',
                          style: TextStyle(
                            color: gift.type == GiftType.virtual
                                ? AppTheme.accentBlue
                                : AppTheme.accentOrange,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentGiftsList() {
    if (_sentGifts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.send_outlined,
              size: 80,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No gifts sent yet',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _sentGifts.length,
      itemBuilder: (context, index) {
        return _buildGiftTransactionCard(_sentGifts[index], isSent: true);
      },
    );
  }

  Widget _buildReceivedGiftsList() {
    if (_receivedGifts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_giftcard,
              size: 80,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No gifts received yet',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _receivedGifts.length,
      itemBuilder: (context, index) {
        return _buildGiftTransactionCard(_receivedGifts[index], isSent: false);
      },
    );
  }

  Widget _buildGiftTransactionCard(GiftTransaction transaction, {required bool isSent}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: AppTheme.mediumRadius,
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getGiftIcon(transaction.gift.category),
              color: AppTheme.primaryPink,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.gift.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isSent ? 'Sent to match' : 'Received from match',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                if (transaction.message != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    transaction.message!,
                    style: TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          _buildGiftStatusChip(transaction.status),
        ],
      ),
    );
  }

  Widget _buildGiftStatusChip(GiftTransactionStatus status) {
    Color color;
    String label;
    
    switch (status) {
      case GiftTransactionStatus.delivered:
        color = AppTheme.successGreen;
        label = 'Delivered';
        break;
      case GiftTransactionStatus.shipped:
        color = AppTheme.infoBlue;
        label = 'Shipped';
        break;
      case GiftTransactionStatus.processing:
        color = AppTheme.warningYellow;
        label = 'Processing';
        break;
      default:
        color = AppTheme.textTertiary;
        label = status.toString().split('.').last;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showGiftDetails(Gift gift) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Icon(
              _getGiftIcon(gift.category),
              size: 100,
              color: AppTheme.primaryPink,
            ),
            const SizedBox(height: 24),
            Text(
              gift.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              gift.description,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              '${gift.currency} ${gift.price.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryPink,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _sendGift(gift);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: AppTheme.mediumRadius,
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: const Text(
                        'Send Gift',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendGift(Gift gift) async {
    if (widget.matchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a match to send gift')),
      );
      return;
    }

    final result = await _giftService.sendGift(
      receiverId: widget.matchId!,
      giftId: gift.id,
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gift sent successfully! 🎁')),
      );
      _loadGifts();
    }
  }

  String _getCategoryLabel(GiftCategory category) {
    return category.toString().split('.').last.replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(0)}',
        ).trim();
  }

  IconData _getGiftIcon(GiftCategory category) {
    switch (category) {
      case GiftCategory.flowers:
        return Icons.local_florist;
      case GiftCategory.chocolates:
        return Icons.cake;
      case GiftCategory.jewelry:
        return Icons.diamond;
      case GiftCategory.gadgets:
        return Icons.devices;
      case GiftCategory.experiences:
        return Icons.celebration;
      case GiftCategory.subscription:
        return Icons.card_membership;
      case GiftCategory.virtual:
        return Icons.stars;
      default:
        return Icons.card_giftcard;
    }
  }
}

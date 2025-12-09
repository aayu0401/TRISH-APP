import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/wallet.dart';
import '../services/wallet_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> with SingleTickerProviderStateMixin {
  final WalletService _walletService = WalletService();
  late TabController _tabController;
  
  Wallet? _wallet;
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadWalletData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadWalletData() async {
    setState(() => _isLoading = true);
    
    final wallet = await _walletService.getWallet();
    final transactions = await _walletService.getTransactions();
    
    setState(() {
      _wallet = wallet;
      _transactions = transactions;
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
              _buildBalanceCard(),
              _buildActionButtons(),
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
              'My Wallet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Show transaction history
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return FadeInDown(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: AppTheme.largeRadius,
          boxShadow: AppTheme.glowShadow,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Available Balance',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                if (_wallet?.isVerified ?? false)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified, size: 16, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _wallet?.currency ?? 'INR',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  NumberFormat('#,##,###.00').format(_wallet?.balance ?? 0),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return FadeInUp(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.add_circle_outline,
                label: 'Add Money',
                gradient: AppTheme.primaryGradient,
                onTap: () => _showAddMoneyDialog(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                icon: Icons.send_outlined,
                label: 'Withdraw',
                gradient: AppTheme.blueGradient,
                onTap: () => _showWithdrawDialog(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppTheme.mediumRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: AppTheme.mediumRadius,
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
            Tab(text: 'Transactions'),
            Tab(text: 'Statistics'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildTransactionsList(),
        _buildStatistics(),
      ],
    );
  }

  Widget _buildTransactionsList() {
    if (_transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions yet',
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
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final transaction = _transactions[index];
        return FadeInUp(
          delay: Duration(milliseconds: 50 * index),
          child: _buildTransactionCard(transaction),
        );
      },
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final isCredit = transaction.type == TransactionType.credit ||
        transaction.type == TransactionType.giftReceived;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: AppTheme.mediumRadius,
        border: Border.all(
          color: AppTheme.textTertiary.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: isCredit ? AppTheme.blueGradient : AppTheme.accentGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ?? _getTransactionTypeLabel(transaction.type),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy • hh:mm a').format(transaction.createdAt),
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '+' : '-'} ${transaction.currency} ${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: isCredit ? AppTheme.successGreen : AppTheme.errorRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              _buildStatusChip(transaction.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(TransactionStatus status) {
    Color color;
    String label;
    
    switch (status) {
      case TransactionStatus.completed:
        color = AppTheme.successGreen;
        label = 'Completed';
        break;
      case TransactionStatus.pending:
        color = AppTheme.warningYellow;
        label = 'Pending';
        break;
      case TransactionStatus.failed:
        color = AppTheme.errorRed;
        label = 'Failed';
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

  Widget _buildStatistics() {
    return Center(
      child: Text(
        'Statistics Coming Soon',
        style: TextStyle(color: AppTheme.textSecondary),
      ),
    );
  }

  String _getTransactionTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.credit:
        return 'Money Added';
      case TransactionType.debit:
        return 'Money Withdrawn';
      case TransactionType.giftPurchase:
        return 'Gift Purchased';
      case TransactionType.giftReceived:
        return 'Gift Received';
      case TransactionType.subscription:
        return 'Subscription Payment';
      case TransactionType.boost:
        return 'Profile Boost';
      case TransactionType.superLike:
        return 'Super Like';
      default:
        return 'Transaction';
    }
  }

  void _showAddMoneyDialog() {
    final TextEditingController amountController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Money'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount',
            prefixText: '₹ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context);
                final success = await _walletService.addMoney(amount, 'razorpay');
                if (success) {
                  _loadWalletData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Money added successfully!')),
                    );
                  }
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog() {
    final TextEditingController amountController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw Money'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount',
            prefixText: '₹ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context);
                final success = await _walletService.withdraw(amount, {});
                if (success) {
                  _loadWalletData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Withdrawal initiated!')),
                    );
                  }
                }
              }
            },
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }
}

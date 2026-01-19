import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../widgets/add_transaction_dialog.dart';
import '../widgets/glass_card.dart';
import '../widgets/stats_summary.dart';
import '../widgets/transaction_card.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({Key? key}) : super(key: key);

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💰 Gelir & Gider'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).primaryColor,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tümü'),
            Tab(text: '💰 Gelir'),
            Tab(text: '💸 Gider'),
          ],
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Theme.of(context).primaryColor,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddTransactionDialog(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('İşlem Ekle'),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllTransactionsTab(),
          _buildIncomeTab(),
          _buildExpenseTab(),
        ],
      ),
    );
  }

  Widget _buildAllTransactionsTab() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final transactions = provider.transactions;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Summary
              const StatsSummary(),
              const SizedBox(height: 24),
              // Transactions List
              if (transactions.isEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Henüz işlem yok',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gelir veya gider ekleyerek başlayın',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Son İşlemler',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...transactions.asMap().entries.map((entry) {
                      final transaction = entry.value;
                      return Column(
                        children: [
                          TransactionCard(
                            transaction: transaction,
                            onDelete: () {
                              provider.deleteTransaction(transaction.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('İşlem silindi')),
                              );
                            },
                            onEdit: () {
                              showDialog(
                                context: context,
                                builder: (context) => AddTransactionDialog(
                                  initialTransaction: transaction,
                                ),
                              );
                            },
                          ),
                          if (entry.key < transactions.length - 1)
                            const SizedBox(height: 12),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIncomeTab() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final incomes = provider.incomes;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Income Summary
              GlassCard(
                backgroundColor: Colors.green[50]?.withAlpha(150),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Toplam Gelir',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₺${provider.totalIncome.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${incomes.length} işlem',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.green[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Category Breakdown
              if (incomes.isNotEmpty) ...[
                Text(
                  'Kategoriler',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ..._buildCategoryBreakdown(context, provider, true),
                const SizedBox(height: 24),
              ],
              // Transactions List
              if (incomes.isEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Icon(
                        Icons.trending_up,
                        size: 64,
                        color: Colors.green[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Henüz gelir yok',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tüm Gelirler',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...incomes.asMap().entries.map((entry) {
                      final transaction = entry.value;
                      return Column(
                        children: [
                          TransactionCard(
                            transaction: transaction,
                            onDelete: () {
                              provider.deleteTransaction(transaction.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('İşlem silindi')),
                              );
                            },
                            onEdit: () {
                              showDialog(
                                context: context,
                                builder: (context) => AddTransactionDialog(
                                  initialTransaction: transaction,
                                ),
                              );
                            },
                          ),
                          if (entry.key < incomes.length - 1)
                            const SizedBox(height: 12),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpenseTab() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final expenses = provider.expenses;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Expense Summary
              GlassCard(
                backgroundColor: Colors.red[50]?.withAlpha(150),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Toplam Gider',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₺${provider.totalExpense.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${expenses.length} işlem',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.red[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Category Breakdown
              if (expenses.isNotEmpty) ...[
                Text(
                  'Kategoriler',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ..._buildCategoryBreakdown(context, provider, false),
                const SizedBox(height: 24),
              ],
              // Transactions List
              if (expenses.isEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Icon(
                        Icons.trending_down,
                        size: 64,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Henüz gider yok',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tüm Giderler',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...expenses.asMap().entries.map((entry) {
                      final transaction = entry.value;
                      return Column(
                        children: [
                          TransactionCard(
                            transaction: transaction,
                            onDelete: () {
                              provider.deleteTransaction(transaction.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('İşlem silindi')),
                              );
                            },
                            onEdit: () {
                              showDialog(
                                context: context,
                                builder: (context) => AddTransactionDialog(
                                  initialTransaction: transaction,
                                ),
                              );
                            },
                          ),
                          if (entry.key < expenses.length - 1)
                            const SizedBox(height: 12),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildCategoryBreakdown(
    BuildContext context,
    TransactionProvider provider,
    bool isIncome,
  ) {
    final categories = isIncome
        ? TransactionCategory.values.where((cat) => cat.isIncome).toList()
        : TransactionCategory.values.where((cat) => cat.isExpense).toList();

    final items = <Widget>[];

    for (final category in categories) {
      final total = provider.getCategoryTotal(category);
      final transactions = provider.getTransactionsByCategory(category);

      if (total > 0) {
        items.add(
          GlassCard(
            backgroundColor: isIncome
                ? Colors.green[50]?.withAlpha(50)
                : Colors.red[50]?.withAlpha(50),
            child: Row(
              children: [
                Text(category.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.label,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${transactions.length} işlem',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₺${total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isIncome ? Colors.green[700] : Colors.red[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
        items.add(const SizedBox(height: 12));
      }
    }

    return items;
  }
}

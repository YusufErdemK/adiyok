import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/card_model.dart';
import '../providers/wallet_provider.dart';
import '../providers/transaction_provider.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text('Cüzdanım'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.account_balance_wallet), text: 'Bakiye'),
            Tab(icon: Icon(Icons.credit_card), text: 'Kartlarım'),
            Tab(icon: Icon(Icons.account_balance), text: 'Hesaplar'),
            Tab(icon: Icon(Icons.savings), text: 'Kumbara'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _BalanceTab(),
          _CardsTab(),
          _AccountsTab(),
          _PiggyBankTab(),
        ],
      ),
    );
  }
}

// ── BAKİYE SEKMESİ ────────────────────────────────────────────────────────────

class _BalanceTab extends StatefulWidget {
  const _BalanceTab();

  @override
  State<_BalanceTab> createState() => _BalanceTabState();
}

class _BalanceTabState extends State<_BalanceTab> {
  final _balanceController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final wallet = context.read<WalletProvider>();
    if (wallet.manualBalance > 0) {
      _balanceController.text = wallet.manualBalance.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final txProvider = context.watch<TransactionProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    final autoBalance = txProvider.netIncome;
    final displayBalance = wallet.useManualBalance
        ? wallet.manualBalance - txProvider.totalExpense
        : autoBalance;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mevcut Bakiye',
                    style: TextStyle(
                      color: colorScheme.onPrimary.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${displayBalance.toStringAsFixed(2)} ₺',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    wallet.useManualBalance
                        ? 'Başlangıç: ${wallet.manualBalance.toStringAsFixed(2)} ₺'
                        : 'İşlemlerden otomatik hesaplanıyor',
                    style: TextStyle(
                      color: colorScheme.onPrimary.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Başlangıç bakiyesi gir',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Switch(
                        value: wallet.useManualBalance,
                        onChanged: (v) => wallet.setUseManualBalance(v),
                      ),
                    ],
                  ),
                  if (wallet.useManualBalance) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Uygulamadaki harcamalar bu tutardan düşülecek.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _balanceController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Mevcut para (₺)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              suffixText: '₺',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            final val = double.tryParse(
                              _balanceController.text,
                            );
                            if (val != null) {
                              wallet.setManualBalance(val);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Bakiye kaydedildi!'),
                                ),
                              );
                            }
                          },
                          child: const Text('Kaydet'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── KARTLARIM SEKMESİ ─────────────────────────────────────────────────────────

class _CardsTab extends StatelessWidget {
  const _CardsTab();

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final txProvider = context.watch<TransactionProvider>();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const _AddCardDialog(),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Kart Ekle'),
      ),
      body: wallet.cards.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.credit_card_off,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz kart eklenmedi',
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: wallet.cards.length,
              itemBuilder: (context, i) {
                final card = wallet.cards[i];
                final cardExpenses = txProvider.transactions
                    .where((t) => t.isExpense && t.cardId == card.id)
                    .fold(0.0, (sum, t) => sum + t.amount * t.quantity);
                return _CardTile(card: card, totalExpense: cardExpenses);
              },
            ),
    );
  }
}

class _CardTile extends StatelessWidget {
  final CardModel card;
  final double totalExpense;
  const _CardTile({required this.card, required this.totalExpense});

  @override
  Widget build(BuildContext context) {
    final wallet = context.read<WalletProvider>();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  card.bank.emoji,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    card.bank.label,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  if (!card.isAnonymous && card.lastFourDigits != null)
                    Text(
                      '**** **** **** ${card.lastFourDigits}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${totalExpense.toStringAsFixed(2)} ₺',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'harcama',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => wallet.removeCard(card.id),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── HESAPLAR SEKMESİ ──────────────────────────────────────────────────────────

class _AccountsTab extends StatelessWidget {
  const _AccountsTab();

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final txProvider = context.watch<TransactionProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const _AddAccountDialog(),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Hesap Ekle'),
      ),
      body: wallet.rootAccounts.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_balance,
                    size: 64,
                    color: colorScheme.onSurface.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz hesap eklenmedi',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: wallet.rootAccounts.length,
              itemBuilder: (context, i) => _AccountNode(
                account: wallet.rootAccounts[i],
                depth: 0,
                transactions: txProvider.transactions,
              ),
            ),
    );
  }
}

class _AccountNode extends StatefulWidget {
  final Account account;
  final int depth;
  final List<dynamic> transactions;

  const _AccountNode({
    required this.account,
    required this.depth,
    required this.transactions,
  });

  @override
  State<_AccountNode> createState() => _AccountNodeState();
}

class _AccountNodeState extends State<_AccountNode> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final children = wallet.childrenOf(widget.account.id);
    final colorScheme = Theme.of(context).colorScheme;

    final accountTx = widget.transactions
        .where((t) => t.accountId == widget.account.id)
        .toList();
    final totalExpense = accountTx
        .where((t) => t.isExpense)
        .fold(0.0, (s, t) => s + t.amount * t.quantity);
    final totalIncome = accountTx
        .where((t) => t.isIncome)
        .fold(0.0, (s, t) => s + t.amount * t.quantity);

    final linkedCard = widget.account.linkedCardId != null
        ? wallet.getCard(widget.account.linkedCardId!)
        : null;

    return Padding(
      padding: EdgeInsets.only(left: widget.depth * 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (children.isNotEmpty)
                        GestureDetector(
                          onTap: () => setState(() => _expanded = !_expanded),
                          child: Icon(
                            _expanded ? Icons.expand_less : Icons.expand_more,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                        )
                      else if (widget.depth > 0)
                        const SizedBox(width: 20),
                      if (children.isNotEmpty || widget.depth > 0)
                        const SizedBox(width: 4),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            linkedCard != null
                                ? linkedCard.bank.emoji
                                : widget.account.type.emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.account.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              widget.account.type.label,
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                            if (linkedCard != null)
                              Text(
                                '🔗 ${linkedCard.name}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.primary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          size: 18,
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                        onSelected: (value) {
                          if (value == 'add_child') {
                            showDialog(
                              context: context,
                              builder: (_) => _AddAccountDialog(
                                parentId: widget.account.id,
                              ),
                            );
                          } else if (value == 'delete') {
                            final error = wallet.canRemoveAccount(
                              widget.account.id,
                              widget.transactions,
                            );
                            if (error != null) {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Silinemez'),
                                  content: Text(error),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Tamam'),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              wallet.removeAccount(widget.account.id);
                            }
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'add_child',
                            child: Row(
                              children: [
                                Icon(Icons.add, size: 16),
                                SizedBox(width: 8),
                                Text('Alt Hesap Ekle'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  size: 16,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Sil',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniStat(
                          label: 'Gelir',
                          value: totalIncome,
                          color: const Color(0xFF34C759),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MiniStat(
                          label: 'Gider',
                          value: totalExpense,
                          color: const Color(0xFFFF3B30),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MiniStat(
                          label: 'Net',
                          value: totalIncome - totalExpense,
                          color: totalIncome >= totalExpense
                              ? const Color(0xFF34C759)
                              : const Color(0xFFFF3B30),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_expanded && children.isNotEmpty)
            ...children.map(
              (child) => _AccountNode(
                account: child,
                depth: widget.depth + 1,
                transactions: widget.transactions,
              ),
            ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          Text(
            '${value.toStringAsFixed(0)} ₺',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── HESAP EKLEME DİALOGU ─────────────────────────────────────────────────────

class _AddAccountDialog extends StatefulWidget {
  final String? parentId;
  const _AddAccountDialog({this.parentId});

  @override
  State<_AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends State<_AddAccountDialog> {
  final _nameController = TextEditingController();
  AccountType _selectedType = AccountType.bank;
  String? _selectedCardId;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(widget.parentId != null ? 'Alt Hesap Ekle' : 'Hesap Ekle'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.parentId != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_tree,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${wallet.getAccount(widget.parentId!)?.name ?? ''} altına eklenecek',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Hesap Adı',
                hintText: 'Örn: Ana Hesabım',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<AccountType>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'Hesap Türü',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: AccountType.values
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Row(
                        children: [
                          Text(t.emoji),
                          const SizedBox(width: 8),
                          Text(t.label),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() {
                _selectedType = v!;
                _selectedCardId = null;
              }),
            ),
            if (wallet.cards.isNotEmpty) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                value: _selectedCardId,
                decoration: InputDecoration(
                  labelText: 'Karta Bağla (isteğe bağlı)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Kart seçme'),
                  ),
                  ...wallet.cards.map(
                    (c) => DropdownMenuItem(
                      value: c.id,
                      child: Row(
                        children: [
                          Text(c.bank.emoji),
                          const SizedBox(width: 8),
                          Text(c.name),
                        ],
                      ),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _selectedCardId = v),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.trim().isEmpty) return;
            context.read<WalletProvider>().addAccount(
              Account(
                name: _nameController.text.trim(),
                type: _selectedType,
                linkedCardId: _selectedCardId,
                parentId: widget.parentId,
              ),
            );
            Navigator.pop(context);
          },
          child: const Text('Ekle'),
        ),
      ],
    );
  }
}

// ── KUMBARA SEKMESİ ───────────────────────────────────────────────────────────

class _PiggyBankTab extends StatelessWidget {
  const _PiggyBankTab();

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const _AddPiggyBankDialog(),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Kumbara Ekle'),
      ),
      body: wallet.piggyBanks.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🐷', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz kumbara eklenmedi',
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: wallet.piggyBanks.length,
              itemBuilder: (context, i) =>
                  _PiggyBankTile(piggyBank: wallet.piggyBanks[i]),
            ),
    );
  }
}

class _PiggyBankTile extends StatelessWidget {
  final PiggyBank piggyBank;
  const _PiggyBankTile({required this.piggyBank});

  @override
  Widget build(BuildContext context) {
    final wallet = context.read<WalletProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final pct = piggyBank.percentage;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(piggyBank.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        piggyBank.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '${piggyBank.savedAmount.toStringAsFixed(2)} / ${piggyBank.targetAmount.toStringAsFixed(2)} ₺',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (piggyBank.isCompleted)
                  const Text('✅', style: TextStyle(fontSize: 22)),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                  onPressed: () => wallet.removePiggyBank(piggyBank.id),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 10,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  piggyBank.isCompleted ? Colors.green : colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${(pct * 100).toStringAsFixed(0)}% tamamlandı',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showAmountDialog(context, wallet, true),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Para Ekle'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: piggyBank.savedAmount > 0
                        ? () => _showAmountDialog(context, wallet, false)
                        : null,
                    icon: const Icon(Icons.remove, size: 16),
                    label: const Text('Para Çek'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAmountDialog(
    BuildContext context,
    WalletProvider wallet,
    bool isAdding,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAdding ? 'Para Ekle' : 'Para Çek'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Tutar (₺)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null && val > 0) {
                if (isAdding)
                  wallet.addToPiggyBank(piggyBank.id, val);
                else
                  wallet.removeFromPiggyBank(piggyBank.id, val);
                Navigator.pop(context);
              }
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}

// ── KUMBARA EKLEME DİALOGU ───────────────────────────────────────────────────

class _AddPiggyBankDialog extends StatefulWidget {
  const _AddPiggyBankDialog();

  @override
  State<_AddPiggyBankDialog> createState() => _AddPiggyBankDialogState();
}

class _AddPiggyBankDialogState extends State<_AddPiggyBankDialog> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  String _selectedEmoji = '🐷';
  final _emojis = ['🐷', '🎯', '🏠', '✈️', '🚗', '💍', '📱', '💻', '🎓', '💰'];

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Kumbara Ekle'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Kumbara Adı',
                hintText: 'Örn: Tatil Parası',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _targetController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Hedef Tutar (₺)',
                hintText: '5000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixText: '₺',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Emoji Seç',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _emojis.map((e) {
                final isSelected = e == _selectedEmoji;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = e),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                      ),
                    ),
                    child: Text(e, style: const TextStyle(fontSize: 24)),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.trim().isEmpty) return;
            final target = double.tryParse(_targetController.text);
            if (target == null || target <= 0) return;
            context.read<WalletProvider>().addPiggyBank(
              PiggyBank(
                name: _nameController.text.trim(),
                targetAmount: target,
                emoji: _selectedEmoji,
              ),
            );
            Navigator.pop(context);
          },
          child: const Text('Ekle'),
        ),
      ],
    );
  }
}

// ── KART EKLEME DİALOGU ──────────────────────────────────────────────────────

class _AddCardDialog extends StatefulWidget {
  const _AddCardDialog();

  @override
  State<_AddCardDialog> createState() => _AddCardDialogState();
}

class _AddCardDialogState extends State<_AddCardDialog> {
  final _nameController = TextEditingController();
  final _holderController = TextEditingController();
  final _lastFourController = TextEditingController();
  BankName _selectedBank = BankName.other;
  bool _isAnonymous = false;
  bool _isCredit = false;

  @override
  void dispose() {
    _nameController.dispose();
    _holderController.dispose();
    _lastFourController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Kart Ekle'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Kart Adı',
                hintText: 'Örn: Maaş Kartım',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<BankName>(
              value: _selectedBank,
              decoration: InputDecoration(
                labelText: 'Banka',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: BankName.values
                  .map(
                    (b) => DropdownMenuItem(
                      value: b,
                      child: Row(
                        children: [
                          Text(b.emoji),
                          const SizedBox(width: 8),
                          Text(b.label),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedBank = v!),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Anonim tut'),
              subtitle: const Text('Kart bilgileri gizlenir'),
              value: _isAnonymous,
              onChanged: (v) => setState(() => _isAnonymous = v),
              contentPadding: EdgeInsets.zero,
            ),
            if (!_isAnonymous) ...[
              TextField(
                controller: _holderController,
                decoration: InputDecoration(
                  labelText: 'Kart Sahibi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _lastFourController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: InputDecoration(
                  labelText: 'Son 4 Hane',
                  hintText: '1234',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
            SwitchListTile(
              title: const Text('Kredi Kartı'),
              value: _isCredit,
              onChanged: (v) => setState(() => _isCredit = v),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.trim().isEmpty) return;
            context.read<WalletProvider>().addCard(
              CardModel(
                name: _nameController.text.trim(),
                bank: _selectedBank,
                isAnonymous: _isAnonymous,
                cardHolder: _isAnonymous ? null : _holderController.text.trim(),
                lastFourDigits: _isAnonymous
                    ? null
                    : _lastFourController.text.trim(),
                isCredit: _isCredit,
              ),
            );
            Navigator.pop(context);
          },
          child: const Text('Ekle'),
        ),
      ],
    );
  }
}

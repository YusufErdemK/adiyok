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

class _WalletScreenState extends State<WalletScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _BalanceTab(),
          _CardsTab(),
        ],
      ),
    );
  }
}

// ── BAKİYE SEKMESI ────────────────────────────────────────────────────────────

class _BalanceTab extends StatelessWidget {
  const _BalanceTab();

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
          // Bakiye kartı
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mevcut Bakiye',
                      style: TextStyle(color: colorScheme.onPrimary.withOpacity(0.8), fontSize: 14)),
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
                    style: TextStyle(color: colorScheme.onPrimary.withOpacity(0.7), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Manuel bakiye ayarı
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Başlangıç bakiyesi gir',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
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
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Mevcut para (₺)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              suffixText: '₺',
                            ),
                            onSubmitted: (v) {
                              final val = double.tryParse(v);
                              if (val != null) wallet.setManualBalance(val);
                            },
                            controller: TextEditingController(
                              text: wallet.manualBalance > 0 ? wallet.manualBalance.toStringAsFixed(2) : '',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {},
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
        onPressed: () => _showAddCardDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Kart Ekle'),
      ),
      body: wallet.cards.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.credit_card_off, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('Henüz kart eklenmedi',
                      style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: wallet.cards.length,
              itemBuilder: (context, i) {
                final card = wallet.cards[i];
                // Bu karta ait harcamalar
                final cardExpenses = txProvider.transactions
                    .where((t) => t.isExpense && t.cardId == card.id)
                    .fold(0.0, (sum, t) => sum + t.amount * t.quantity);

                return _CardTile(card: card, totalExpense: cardExpenses);
              },
            ),
    );
  }

  void _showAddCardDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => const _AddCardDialog());
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
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(card.bank.emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(card.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(card.bank.label,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  if (!card.isAnonymous && card.lastFourDigits != null)
                    Text('**** **** **** ${card.lastFourDigits}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${totalExpense.toStringAsFixed(2)} ₺',
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15)),
                Text('harcama', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => wallet.removeCard(card.id),
                  child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── KART EKLEME DİALOGU ───────────────────────────────────────────────────────

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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<BankName>(
              value: _selectedBank,
              decoration: InputDecoration(
                labelText: 'Banka',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: BankName.values.map((b) {
                return DropdownMenuItem(
                  value: b,
                  child: Row(
                    children: [
                      Text(b.emoji),
                      const SizedBox(width: 8),
                      Text(b.label),
                    ],
                  ),
                );
              }).toList(),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
            context.read<WalletProvider>().addCard(CardModel(
              name: _nameController.text.trim(),
              bank: _selectedBank,
              isAnonymous: _isAnonymous,
              cardHolder: _isAnonymous ? null : _holderController.text.trim(),
              lastFourDigits: _isAnonymous ? null : _lastFourController.text.trim(),
              isCredit: _isCredit,
            ));
            Navigator.pop(context);
          },
          child: const Text('Ekle'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../models/tree_node.dart';
import '../models/card_model.dart';
import '../providers/transaction_provider.dart';
import '../providers/tree_provider.dart';
import '../providers/wallet_provider.dart';
import '../services/sound_service.dart';
import 'glass_card.dart';

class AddTransactionDialog extends StatefulWidget {
  final Transaction? initialTransaction;
  const AddTransactionDialog({Key? key, this.initialTransaction})
    : super(key: key);

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _quantityController;
  late TextEditingController _descriptionController;
  late TextEditingController _notesController;

  late TransactionCategory _selectedCategory;
  String? _selectedTreeNodeId;
  String? _selectedTreeNodeName;
  late DateTime _selectedDate;
  late bool _isIncome;

  String? _selectedCardId;
  bool _isCash = false;
  String? _selectedAccountId;

  List<TreeNode> _flattenNodes(List<TreeNode> roots) {
    final result = <TreeNode>[];
    void traverse(TreeNode node) {
      result.add(node);
      for (final child in node.children) traverse(child);
    }

    for (final root in roots) traverse(root);
    return result;
  }

  @override
  void initState() {
    super.initState();
    final t = widget.initialTransaction;
    if (t != null) {
      _titleController = TextEditingController(text: t.title);
      _amountController = TextEditingController(
        text: t.amount.toStringAsFixed(2),
      );
      _quantityController = TextEditingController(text: t.quantity.toString());
      _descriptionController = TextEditingController(text: t.description);
      _notesController = TextEditingController(text: t.notes);
      _selectedCategory = t.category;
      _selectedTreeNodeId = t.treeNodeId;
      _selectedTreeNodeName = t.treeNodeName;
      _selectedDate = t.date;
      _isIncome = t.isIncome;
      _selectedCardId = t.cardId;
      _isCash = t.isCash;
      _selectedAccountId = t.accountId;
    } else {
      _titleController = TextEditingController();
      _amountController = TextEditingController();
      _quantityController = TextEditingController(text: '1');
      _descriptionController = TextEditingController();
      _notesController = TextEditingController();
      _selectedCategory = TransactionCategory.salary;
      _selectedTreeNodeId = null;
      _selectedTreeNodeName = null;
      _selectedDate = DateTime.now();
      _isIncome = true;
      _selectedCardId = null;
      _isCash = false;
      _selectedAccountId = null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String get _dropdownValue {
    if (_selectedTreeNodeId != null) return 't:$_selectedTreeNodeId';
    return 'e:${_selectedCategory.name}';
  }

  @override
  Widget build(BuildContext context) {
    final incomeCategories = TransactionCategory.values
        .where((c) => c.isIncome)
        .toList();
    final expenseCategories = TransactionCategory.values
        .where((c) => c.isExpense)
        .toList();
    final currentEnumCategories = _isIncome
        ? incomeCategories
        : expenseCategories;
    final cards = context.watch<WalletProvider>().cards;
    final accounts = context.watch<WalletProvider>().accounts;
    final allNodes = _flattenNodes(context.watch<TreeProvider>().roots);

    if (_selectedTreeNodeId == null &&
        !currentEnumCategories.contains(_selectedCategory)) {
      _selectedCategory = currentEnumCategories.first;
    }

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.initialTransaction != null
                        ? 'İşlemi Düzenle'
                        : 'Yeni İşlem Ekle',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      SoundService.playClick();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Gelir/Gider toggle
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        SoundService.playClick();
                        setState(() {
                          _isIncome = true;
                          _selectedTreeNodeId = null;
                          _selectedTreeNodeName = null;
                          _selectedCategory = TransactionCategory.salary;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isIncome
                              ? Colors.green[100]
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: _isIncome
                                ? Colors.green[400]!
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '💰 Gelir',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _isIncome
                                  ? Colors.green[700]
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        SoundService.playClick();
                        setState(() {
                          _isIncome = false;
                          _selectedTreeNodeId = null;
                          _selectedTreeNodeName = null;
                          _selectedCategory = TransactionCategory.rent;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isIncome
                              ? Colors.red[100]
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: !_isIncome
                                ? Colors.red[400]!
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '💸 Gider',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: !_isIncome
                                  ? Colors.red[700]
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Başlık
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Başlık',
                  hintText: _isIncome ? 'Örn: Maaş' : 'Örn: Kira Ödemesi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 16),

              // Tutar
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Tutar (₺)',
                  hintText: '0.00',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.money),
                ),
              ),
              const SizedBox(height: 16),

              // Adet
              TextField(
                controller: _quantityController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Adet (İsteğe bağlı)',
                  hintText: '1',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.format_list_numbered),
                ),
              ),
              const SizedBox(height: 16),

              // Kategori
              DropdownButtonFormField<String>(
                value: _dropdownValue,
                isExpanded: true,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    if (value.startsWith('t:')) {
                      final nodeId = value.substring(2);
                      final node = allNodes.firstWhere((n) => n.id == nodeId);
                      _selectedTreeNodeId = node.id;
                      _selectedTreeNodeName = node.name;
                    } else {
                      _selectedTreeNodeId = null;
                      _selectedTreeNodeName = null;
                      _selectedCategory = TransactionCategory.fromString(
                        value.substring(2),
                      );
                    }
                  });
                },
                items: [
                  DropdownMenuItem(
                    enabled: false,
                    value: '__enum_header__',
                    child: Text(
                      '── Standart Kategoriler ──',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  ...currentEnumCategories.map(
                    (cat) => DropdownMenuItem(
                      value: 'e:${cat.name}',
                      child: Row(
                        children: [
                          Text(cat.emoji),
                          const SizedBox(width: 8),
                          Text(cat.label),
                        ],
                      ),
                    ),
                  ),
                  if (allNodes.isNotEmpty) ...[
                    DropdownMenuItem(
                      enabled: false,
                      value: '__tree_header__',
                      child: Text(
                        '── Ağaç Elemanları ──',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    ...allNodes.map(
                      (node) => DropdownMenuItem(
                        value: 't:${node.id}',
                        child: Row(
                          children: [
                            const Text('🌳'),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                node.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.category),
                ),
              ),
              const SizedBox(height: 16),

              // ── Hesap seçimi
              if (accounts.isNotEmpty) ...[
                DropdownButtonFormField<String?>(
                  value: _selectedAccountId,
                  isExpanded: true,
                  hint: const Text('Hesap seç (isteğe bağlı)'),
                  onChanged: (v) => setState(() => _selectedAccountId = v),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Hesap seçilmedi'),
                    ),
                    ...accounts.map(
                      (a) => DropdownMenuItem(
                        value: a.id,
                        child: Row(
                          children: [
                            Text(a.type.emoji),
                            const SizedBox(width: 8),
                            Text(a.name),
                          ],
                        ),
                      ),
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Hesap',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.account_balance),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Kart seçimi + Nakit
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      value: _isCash ? null : _selectedCardId,
                      isExpanded: true,
                      hint: const Text('Kart seç'),
                      onChanged: _isCash
                          ? null
                          : (value) => setState(() => _selectedCardId = value),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Kart seçilmedi'),
                        ),
                        ...cards.map(
                          (card) => DropdownMenuItem(
                            value: card.id,
                            child: Row(
                              children: [
                                Text(card.bank.emoji),
                                const SizedBox(width: 8),
                                Text(card.name),
                              ],
                            ),
                          ),
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Kart',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.credit_card),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    children: [
                      Checkbox(
                        value: _isCash,
                        onChanged: (v) => setState(() {
                          _isCash = v ?? false;
                          if (_isCash) _selectedCardId = null;
                        }),
                      ),
                      const Text('Nakit', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tarih
              GestureDetector(
                onTap: () async {
                  SoundService.playClick();
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (selectedDate != null)
                    setState(() => _selectedDate = selectedDate);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.grey[600]),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('dd.MM.yyyy', 'tr_TR').format(_selectedDate),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Açıklama
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Açıklama (İsteğe bağlı)',
                  hintText: 'Detaylı bilgi girin...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // İşletme
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'İşletme (İsteğe bağlı)',
                  hintText: 'Örn: Migros, Emlakçı vb.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.note),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Butonlar
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        SoundService.playClick();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.grey[300],
                      ),
                      child: Text(
                        'İptal',
                        style: TextStyle(color: Colors.grey[800]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveTransaction,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Kaydet'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTransaction() {
    if (_titleController.text.trim().isEmpty) {
      SoundService.playClick();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen başlık girin')));
      return;
    }
    if (_amountController.text.trim().isEmpty) {
      SoundService.playClick();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen tutar girin')));
      return;
    }

    try {
      final amount = double.parse(_amountController.text);
      if (amount <= 0) throw Exception();
      final quantity = double.tryParse(_quantityController.text) ?? 1.0;

      final transaction = Transaction(
        id: widget.initialTransaction?.id,
        title: _titleController.text.trim(),
        amount: amount,
        quantity: quantity,
        category: _selectedCategory,
        treeNodeId: _selectedTreeNodeId,
        treeNodeName: _selectedTreeNodeName,
        date: _selectedDate,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        cardId: _isCash ? null : _selectedCardId,
        isCash: _isCash,
        accountId: _selectedAccountId,
      );

      if (widget.initialTransaction != null) {
        context.read<TransactionProvider>().updateTransaction(
          widget.initialTransaction!.id,
          transaction,
        );
      } else {
        context.read<TransactionProvider>().addTransaction(transaction);
      }

      SoundService.playSuccess();
      Navigator.pop(context);
    } catch (e) {
      SoundService.playClick();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen geçerli bir tutar girin')),
      );
    }
  }
}

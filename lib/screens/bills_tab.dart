import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bill_provider.dart';

class BillsTab extends StatefulWidget {
  const BillsTab({Key? key}) : super(key: key);

  @override
  State<BillsTab> createState() => _BillsTabState();
}

class _BillsTabState extends State<BillsTab> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
  }

  void _prevMonth() => setState(() {
        if (_month == 1) {
          _month = 12;
          _year--;
        } else {
          _month--;
        }
      });

  void _nextMonth() => setState(() {
        if (_month == 12) {
          _month = 1;
          _year++;
        } else {
          _month++;
        }
      });

  static const _monthNames = [
    '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BillProvider>();
    final bills = provider.bills;
    final colorScheme = Theme.of(context).colorScheme;

    final unpaid = bills.where((b) => !b.isPaidForMonth(_year, _month)).toList();
    final paid = bills.where((b) => b.isPaidForMonth(_year, _month)).toList();

    // Gecikmiş ve yaklaşanları öne al
    unpaid.sort((a, b) {
      final sa = a.statusForMonth(_year, _month);
      final sb = b.statusForMonth(_year, _month);
      return sb.compareTo(sa);
    });

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const _AddBillDialog(),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Süreli Ekle'),
      ),
      body: Column(
        children: [
          // Ay navigasyonu
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _prevMonth,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  '${_monthNames[_month]} $_year',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                  onPressed: _nextMonth,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),

          // Özet
          if (bills.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _SummaryChip(
                    label: 'Ödenmedi',
                    count: unpaid.length,
                    color: unpaid.isEmpty
                        ? const Color(0xFF34C759)
                        : const Color(0xFFFF3B30),
                  ),
                  const SizedBox(width: 8),
                  _SummaryChip(
                    label: 'Ödendi',
                    count: paid.length,
                    color: const Color(0xFF34C759),
                  ),
                  const Spacer(),
                  Text(
                    'Toplam: ${bills.fold(0.0, (s, b) => s + b.amount).toStringAsFixed(0)} ₺',
                    style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.5)),
                  ),
                ],
              ),
            ),

          Expanded(
            child: bills.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🧾', style: const TextStyle(fontSize: 56)),
                        const SizedBox(height: 16),
                        Text('Henüz süreli işlem eklenmedi',
                            style: TextStyle(
                                fontSize: 16,
                                color: colorScheme.onSurface.withValues(alpha: 0.4))),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    children: [
                      if (unpaid.isNotEmpty) ...[
                        _SectionHeader(
                            title: 'Ödenmeyenler (${unpaid.length})'),
                        ...unpaid.map((b) => _BillCard(
                              bill: b,
                              year: _year,
                              month: _month,
                            )),
                      ],
                      if (paid.isNotEmpty) ...[
                        _SectionHeader(title: 'Ödenenler (${paid.length})'),
                        ...paid.map((b) => _BillCard(
                              bill: b,
                              year: _year,
                              month: _month,
                            )),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Text(title,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _SummaryChip(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('$count $label',
          style: TextStyle(
              fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _BillCard extends StatelessWidget {
  final Bill bill;
  final int year;
  final int month;
  const _BillCard({required this.bill, required this.year, required this.month});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<BillProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final isPaid = bill.isPaidForMonth(year, month);
    final status = bill.statusForMonth(year, month);
    final dueDate = bill.dueDateForMonth(year, month);

    Color statusColor;
    String statusText;
    if (isPaid) {
      statusColor = const Color(0xFF34C759);
      statusText = 'Ödendi';
    } else if (status == 2) {
      statusColor = const Color(0xFFFF3B30);
      statusText = 'Gecikmiş!';
    } else if (status == 1) {
      statusColor = const Color(0xFFFF9500);
      statusText = '${dueDate.difference(DateTime.now()).inDays + 1} gün kaldı';
    } else {
      statusColor = colorScheme.onSurface.withValues(alpha: 0.4);
      statusText = '${dueDate.day}. gün son gün';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Emoji
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: isPaid
                    ? const Color(0xFF34C759).withValues(alpha: 0.1)
                    : status == 2
                        ? const Color(0xFFFF3B30).withValues(alpha: 0.1)
                        : colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(bill.type.emoji,
                    style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),

            // Bilgi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bill.name,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          decoration: isPaid ? TextDecoration.lineThrough : null,
                          color: isPaid
                              ? colorScheme.onSurface.withValues(alpha: 0.4)
                              : null)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(statusText,
                          style: TextStyle(fontSize: 11, color: statusColor)),
                      if (bill.isRecurring) ...[
                        const SizedBox(width: 6),
                        Text('• aylık',
                            style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.onSurface.withValues(alpha: 0.35))),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Tutar
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${bill.amount.toStringAsFixed(0)} ₺',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isPaid
                            ? colorScheme.onSurface.withValues(alpha: 0.4)
                            : colorScheme.onSurface)),
                const SizedBox(height: 4),
                // Ödendi / Geri al butonu
                GestureDetector(
                  onTap: () {
                    if (isPaid) {
                      provider.markUnpaid(bill.id, year, month);
                    } else {
                      provider.markPaid(bill.id, year, month);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? colorScheme.onSurface.withValues(alpha: 0.08)
                          : const Color(0xFF34C759).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isPaid ? 'Geri al' : 'Ödendi',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isPaid
                              ? colorScheme.onSurface.withValues(alpha: 0.5)
                              : const Color(0xFF34C759)),
                    ),
                  ),
                ),
              ],
            ),

            // Sil
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => provider.removeBill(bill.id),
              child: Icon(Icons.delete_outline,
                  size: 18,
                  color: colorScheme.onSurface.withValues(alpha: 0.25)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── FATURA EKLEME DİALOGU ────────────────────────────────────────────────────

class _AddBillDialog extends StatefulWidget {
  const _AddBillDialog();

  @override
  State<_AddBillDialog> createState() => _AddBillDialogState();
}

class _AddBillDialogState extends State<_AddBillDialog> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  BillType _type = BillType.electricity;
  int _dueDay = 1;
  bool _isRecurring = true;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Süreli İşlem Ekle'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tür seçimi — emoji grid
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: BillType.values.map((t) {
                final selected = t == _type;
                return GestureDetector(
                  onTap: () => setState(() {
                    _type = t;
                    if (_nameController.text.isEmpty ||
                        BillType.values.any((bt) => bt.label == _nameController.text)) {
                      _nameController.text = t.label;
                    }
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(t.emoji),
                      const SizedBox(width: 4),
                      Text(t.label, style: const TextStyle(fontSize: 12)),
                    ]),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Süreli İşlem Adı',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Tutar (₺)',
                suffixText: '₺',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Son ödeme günü:', style: TextStyle(fontSize: 13)),
                const Spacer(),
                IconButton(
                  onPressed: () => setState(() => _dueDay = (_dueDay - 1).clamp(1, 31)),
                  icon: const Icon(Icons.remove, size: 18),
                ),
                Text('$_dueDay', style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () => setState(() => _dueDay = (_dueDay + 1).clamp(1, 31)),
                  icon: const Icon(Icons.add, size: 18),
                ),
              ],
            ),
            SwitchListTile(
              title: const Text('Aylık tekrarlansın', style: TextStyle(fontSize: 13)),
              value: _isRecurring,
              onChanged: (v) => setState(() => _isRecurring = v),
              contentPadding: EdgeInsets.zero,
              dense: true,
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
            final amount = double.tryParse(_amountController.text) ?? 0;
            context.read<BillProvider>().addBill(Bill(
              name: _nameController.text.trim(),
              type: _type,
              amount: amount,
              dueDayOfMonth: _dueDay,
              isRecurring: _isRecurring,
            ));
            Navigator.pop(context);
          },
          child: const Text('Ekle'),
        ),
      ],
    );
  }
}

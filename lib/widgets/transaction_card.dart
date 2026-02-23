import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../services/sound_service.dart';
import 'glass_card.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const TransactionCard({
    Key? key,
    required this.transaction,
    this.onDelete,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;
    final amountColor = isIncome ? Colors.green[600] : Colors.red[600];
    final iconColor = isIncome ? Colors.green[400] : Colors.red[400];
    final backgroundColor = isIncome ? Colors.green[50] : Colors.red[50];
    final totalAmount = transaction.amount * transaction.quantity;

    return GlassCard(
      backgroundColor: backgroundColor?.withAlpha(100),
      child: Row(
        children: [
          // Icon/Category
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor?.withAlpha(50),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              transaction.displayEmoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.title,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            transaction.quantity > 1
                                ? '${transaction.displayCategory} · ${transaction.quantity} adet'
                                : transaction.displayCategory,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isIncome ? '+' : '-'}₺${totalAmount.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: amountColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        if (transaction.quantity > 1)
                          Text(
                            '₺${transaction.amount.toStringAsFixed(2)} × ${transaction.quantity}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.grey[500],
                                  fontSize: 11,
                                ),
                          ),
                        Text(
                          DateFormat(
                            'dd.MM.yyyy',
                            'tr_TR',
                          ).format(transaction.date),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[500], fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
                if (transaction.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    transaction.description!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Action Buttons
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                SoundService.playDelete();
                onDelete?.call();
              } else if (value == 'edit') {
                SoundService.playClick();
                onEdit?.call();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Düzenle'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Sil', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

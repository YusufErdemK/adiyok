import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum BillType {
  electricity('Elektrik', '⚡'),
  water('Su', '💧'),
  gas('Doğalgaz', '🔥'),
  internet('İnternet', '🌐'),
  phone('Telefon', '📱'),
  rent('Kira', '🏠'),
  custom('Özel', '📄');

  final String label;
  final String emoji;
  const BillType(this.label, this.emoji);

  static BillType fromString(String v) => BillType.values.firstWhere(
        (e) => e.name == v,
        orElse: () => BillType.custom,
      );
}

class BillPayment {
  final int year;
  final int month;
  final DateTime paidAt;

  BillPayment({required this.year, required this.month, DateTime? paidAt})
      : paidAt = paidAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'year': year,
        'month': month,
        'paidAt': paidAt.toIso8601String(),
      };

  static BillPayment fromJson(Map<String, dynamic> json) => BillPayment(
        year: json['year'] as int,
        month: json['month'] as int,
        paidAt: DateTime.parse(json['paidAt'] as String),
      );
}

class Bill {
  final String id;
  final String name;
  final BillType type;
  final double amount;
  final int dueDayOfMonth;
  final bool isRecurring;
  final List<BillPayment> payments;

  Bill({
    String? id,
    required this.name,
    required this.type,
    required this.amount,
    required this.dueDayOfMonth,
    this.isRecurring = true,
    List<BillPayment>? payments,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        payments = payments ?? [];

  bool isPaidForMonth(int year, int month) =>
      payments.any((p) => p.year == year && p.month == month);

  DateTime dueDateForMonth(int year, int month) {
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, dueDayOfMonth.clamp(1, lastDay));
  }

  /// 0=normal, 1=yaklaşıyor (≤3 gün), 2=gecikmiş
  int statusForMonth(int year, int month) {
    if (isPaidForMonth(year, month)) return 0;
    final diff = dueDateForMonth(year, month).difference(DateTime.now()).inDays;
    if (diff < 0) return 2;
    if (diff <= 3) return 1;
    return 0;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'amount': amount,
        'dueDayOfMonth': dueDayOfMonth,
        'isRecurring': isRecurring,
        'payments': payments.map((p) => p.toJson()).toList(),
      };

  static Bill fromJson(Map<String, dynamic> json) => Bill(
        id: json['id'] as String,
        name: json['name'] as String,
        type: BillType.fromString(json['type'] as String? ?? 'custom'),
        amount: (json['amount'] as num).toDouble(),
        dueDayOfMonth: json['dueDayOfMonth'] as int? ?? 1,
        isRecurring: json['isRecurring'] as bool? ?? true,
        payments: (json['payments'] as List? ?? [])
            .map((e) => BillPayment.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Bill copyWith({
    String? name,
    BillType? type,
    double? amount,
    int? dueDayOfMonth,
    bool? isRecurring,
    List<BillPayment>? payments,
  }) =>
      Bill(
        id: id,
        name: name ?? this.name,
        type: type ?? this.type,
        amount: amount ?? this.amount,
        dueDayOfMonth: dueDayOfMonth ?? this.dueDayOfMonth,
        isRecurring: isRecurring ?? this.isRecurring,
        payments: payments ?? List.from(this.payments),
      );
}

class BillProvider extends ChangeNotifier {
  static const String _key = 'bills_data';
  List<Bill> _bills = [];

  List<Bill> get bills => _bills;

  int get unpaidCountThisMonth {
    final now = DateTime.now();
    return _bills.where((b) => !b.isPaidForMonth(now.year, now.month)).length;
  }

  BillProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json != null) {
      final list = jsonDecode(json) as List;
      _bills = list.map((e) => Bill.fromJson(e as Map<String, dynamic>)).toList();
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_bills.map((b) => b.toJson()).toList()));
  }

  Future<void> addBill(Bill bill) async {
    _bills.add(bill);
    notifyListeners();
    await _save();
  }

  Future<void> removeBill(String id) async {
    _bills.removeWhere((b) => b.id == id);
    notifyListeners();
    await _save();
  }

  Future<void> markPaid(String billId, int year, int month) async {
    final i = _bills.indexWhere((b) => b.id == billId);
    if (i == -1) return;
    if (_bills[i].isPaidForMonth(year, month)) return;
    _bills[i] = _bills[i].copyWith(
      payments: [..._bills[i].payments, BillPayment(year: year, month: month)],
    );
    notifyListeners();
    await _save();
  }

  Future<void> markUnpaid(String billId, int year, int month) async {
    final i = _bills.indexWhere((b) => b.id == billId);
    if (i == -1) return;
    _bills[i] = _bills[i].copyWith(
      payments: _bills[i]
          .payments
          .where((p) => !(p.year == year && p.month == month))
          .toList(),
    );
    notifyListeners();
    await _save();
  }
}

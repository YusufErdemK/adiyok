import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/card_model.dart';

// ── KUMBARA ───────────────────────────────────────────────────────────────────

class PiggyBank {
  final String id;
  final String name;
  final double targetAmount;
  double savedAmount;
  final String emoji;

  PiggyBank({
    String? id,
    required this.name,
    required this.targetAmount,
    this.savedAmount = 0,
    this.emoji = '🐷',
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  double get percentage =>
      targetAmount > 0 ? (savedAmount / targetAmount).clamp(0, 1) : 0;
  bool get isCompleted => savedAmount >= targetAmount;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'targetAmount': targetAmount,
    'savedAmount': savedAmount,
    'emoji': emoji,
  };

  static PiggyBank fromJson(Map<String, dynamic> json) => PiggyBank(
    id: json['id'] as String,
    name: json['name'] as String,
    targetAmount: (json['targetAmount'] as num).toDouble(),
    savedAmount: (json['savedAmount'] as num).toDouble(),
    emoji: json['emoji'] as String? ?? '🐷',
  );
}

// ── HESAP ─────────────────────────────────────────────────────────────────────

enum AccountType {
  cash('Nakit', '💵'),
  bank('Banka Hesabı', '🏦'),
  credit('Kredi Kartı', '💳'),
  prepaid('Ön Ödemeli Kart', '💜'),
  gift('Hediye Kartı', '🎁');

  final String label;
  final String emoji;
  const AccountType(this.label, this.emoji);

  static AccountType fromString(String v) => AccountType.values.firstWhere(
    (e) => e.name == v,
    orElse: () => AccountType.cash,
  );
}

class Account {
  final String id;
  final String name;
  final AccountType type;
  final String? linkedCardId;
  final String? parentId;

  Account({
    String? id,
    required this.name,
    required this.type,
    this.linkedCardId,
    this.parentId,
  }) : id = id ?? '${DateTime.now().millisecondsSinceEpoch}';

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'linkedCardId': linkedCardId,
    'parentId': parentId,
  };

  static Account fromJson(Map<String, dynamic> json) => Account(
    id: json['id'] as String,
    name: json['name'] as String,
    type: AccountType.fromString(json['type'] as String? ?? 'cash'),
    linkedCardId: json['linkedCardId'] as String?,
    parentId: json['parentId'] as String?,
  );

  Account copyWith({
    String? name,
    AccountType? type,
    String? linkedCardId,
    String? parentId,
    bool clearLinkedCard = false,
    bool clearParent = false,
  }) => Account(
    id: id,
    name: name ?? this.name,
    type: type ?? this.type,
    linkedCardId: clearLinkedCard ? null : (linkedCardId ?? this.linkedCardId),
    parentId: clearParent ? null : (parentId ?? this.parentId),
  );
}

// ── PROVIDER ──────────────────────────────────────────────────────────────────

class WalletProvider extends ChangeNotifier {
  static const String _cardsKey = 'wallet_cards';
  static const String _manualBalanceKey = 'wallet_manual_balance';
  static const String _useManualBalanceKey = 'wallet_use_manual';
  static const String _piggyBanksKey = 'wallet_piggy_banks';
  static const String _accountsKey = 'wallet_accounts';

  List<CardModel> _cards = [];
  double _manualBalance = 0;
  bool _useManualBalance = false;
  List<PiggyBank> _piggyBanks = [];
  List<Account> _accounts = [];

  List<CardModel> get cards => _cards;
  double get manualBalance => _manualBalance;
  bool get useManualBalance => _useManualBalance;
  List<PiggyBank> get piggyBanks => _piggyBanks;
  List<Account> get accounts => _accounts;

  List<Account> get rootAccounts =>
      _accounts.where((a) => a.parentId == null).toList();

  List<Account> childrenOf(String parentId) =>
      _accounts.where((a) => a.parentId == parentId).toList();

  WalletProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    final cardsJson = prefs.getString(_cardsKey);
    if (cardsJson != null) {
      final list = jsonDecode(cardsJson) as List;
      _cards = list
          .map((e) => CardModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final piggyJson = prefs.getString(_piggyBanksKey);
    if (piggyJson != null) {
      final list = jsonDecode(piggyJson) as List;
      _piggyBanks = list
          .map((e) => PiggyBank.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final accountsJson = prefs.getString(_accountsKey);
    if (accountsJson != null) {
      final list = jsonDecode(accountsJson) as List;
      _accounts = list
          .map((e) => Account.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    _manualBalance = prefs.getDouble(_manualBalanceKey) ?? 0;
    _useManualBalance = prefs.getBool(_useManualBalanceKey) ?? false;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cardsKey,
      jsonEncode(_cards.map((c) => c.toJson()).toList()),
    );
    await prefs.setDouble(_manualBalanceKey, _manualBalance);
    await prefs.setBool(_useManualBalanceKey, _useManualBalance);
    await prefs.setString(
      _piggyBanksKey,
      jsonEncode(_piggyBanks.map((p) => p.toJson()).toList()),
    );
    await prefs.setString(
      _accountsKey,
      jsonEncode(_accounts.map((a) => a.toJson()).toList()),
    );
  }

  // ── Kart işlemleri
  Future<void> addCard(CardModel card) async {
    _cards.add(card);
    notifyListeners();
    await _save();
  }

  Future<void> removeCard(String id) async {
    _cards.removeWhere((c) => c.id == id);
    for (int i = 0; i < _accounts.length; i++) {
      if (_accounts[i].linkedCardId == id) {
        _accounts[i] = _accounts[i].copyWith(clearLinkedCard: true);
      }
    }
    notifyListeners();
    await _save();
  }

  CardModel? getCard(String id) {
    try {
      return _cards.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Bakiye işlemleri
  Future<void> setManualBalance(double value) async {
    _manualBalance = value;
    notifyListeners();
    await _save();
  }

  Future<void> setUseManualBalance(bool value) async {
    _useManualBalance = value;
    notifyListeners();
    await _save();
  }

  // ── Kumbara işlemleri
  Future<void> addPiggyBank(PiggyBank piggyBank) async {
    _piggyBanks.add(piggyBank);
    notifyListeners();
    await _save();
  }

  Future<void> removePiggyBank(String id) async {
    _piggyBanks.removeWhere((p) => p.id == id);
    notifyListeners();
    await _save();
  }

  Future<void> addToPiggyBank(String id, double amount) async {
    final index = _piggyBanks.indexWhere((p) => p.id == id);
    if (index == -1) return;
    _piggyBanks[index].savedAmount += amount;
    notifyListeners();
    await _save();
  }

  Future<void> removeFromPiggyBank(String id, double amount) async {
    final index = _piggyBanks.indexWhere((p) => p.id == id);
    if (index == -1) return;
    _piggyBanks[index].savedAmount = (_piggyBanks[index].savedAmount - amount)
        .clamp(0, double.infinity);
    notifyListeners();
    await _save();
  }

  // ── Hesap işlemleri
  Future<void> addAccount(Account account) async {
    _accounts.add(account);
    notifyListeners();
    await _save();
  }

  /// Silme engeli kontrolü — hata mesajı döner, yoksa null
  String? canRemoveAccount(String id, List<dynamic> transactions) {
    if (childrenOf(id).isNotEmpty) {
      return 'Bu hesabın alt hesapları var.\nÖnce alt hesapları silin.';
    }
    final hasTx = transactions.any((t) => t.accountId == id);
    if (hasTx) {
      return 'Bu hesaba bağlı işlemler var.\nHesap silinemez.';
    }
    return null;
  }

  Future<void> removeAccount(String id) async {
    _accounts.removeWhere((a) => a.id == id);
    notifyListeners();
    await _save();
  }

  Account? getAccount(String id) {
    try {
      return _accounts.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}

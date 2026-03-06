import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/card_model.dart';

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

class WalletProvider extends ChangeNotifier {
  static const String _cardsKey = 'wallet_cards';
  static const String _manualBalanceKey = 'wallet_manual_balance';
  static const String _useManualBalanceKey = 'wallet_use_manual';
  static const String _piggyBanksKey = 'wallet_piggy_banks';

  List<CardModel> _cards = [];
  double _manualBalance = 0;
  bool _useManualBalance = false;
  List<PiggyBank> _piggyBanks = [];

  List<CardModel> get cards => _cards;
  double get manualBalance => _manualBalance;
  bool get useManualBalance => _useManualBalance;
  List<PiggyBank> get piggyBanks => _piggyBanks;

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
  }

  Future<void> addCard(CardModel card) async {
    _cards.add(card);
    notifyListeners();
    await _save();
  }

  Future<void> removeCard(String id) async {
    _cards.removeWhere((c) => c.id == id);
    notifyListeners();
    await _save();
  }

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

  CardModel? getCard(String id) {
    try {
      return _cards.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

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
}

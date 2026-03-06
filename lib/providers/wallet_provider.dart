import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/card_model.dart';

class WalletProvider extends ChangeNotifier {
  static const String _cardsKey = 'wallet_cards';
  static const String _manualBalanceKey = 'wallet_manual_balance';
  static const String _useManualBalanceKey = 'wallet_use_manual';

  List<CardModel> _cards = [];
  double _manualBalance = 0;
  bool _useManualBalance = false;

  List<CardModel> get cards => _cards;
  double get manualBalance => _manualBalance;
  bool get useManualBalance => _useManualBalance;

  WalletProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    final cardsJson = prefs.getString(_cardsKey);
    if (cardsJson != null) {
      final list = jsonDecode(cardsJson) as List;
      _cards = list.map((e) => CardModel.fromJson(e as Map<String, dynamic>)).toList();
    }

    _manualBalance = prefs.getDouble(_manualBalanceKey) ?? 0;
    _useManualBalance = prefs.getBool(_useManualBalanceKey) ?? false;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cardsKey, jsonEncode(_cards.map((c) => c.toJson()).toList()));
    await prefs.setDouble(_manualBalanceKey, _manualBalance);
    await prefs.setBool(_useManualBalanceKey, _useManualBalance);
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
}

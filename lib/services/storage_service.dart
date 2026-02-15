import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tree_node.dart';
import '../models/transaction.dart';

class StorageService {
  static const String _treeDataKey = 'tree_data';
  static const String _transactionDataKey = 'transaction_data';

  static late SharedPreferences _prefs;

  // Initialize shared preferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save tree data
  static Future<void> saveTreeData(List<TreeNode> roots) async {
    final jsonList = roots.map((root) => root.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _prefs.setString(_treeDataKey, jsonString);
  }

  // Load tree data
  static Future<List<TreeNode>> loadTreeData() async {
    final jsonString = _prefs.getString(_treeDataKey);
    if (jsonString == null) return [];

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => TreeNode.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading tree data: $e');
      return [];
    }
  }

  // Save transaction data
  static Future<void> saveTransactionData(
    List<Transaction> transactions,
  ) async {
    final jsonList = transactions.map((t) => t.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _prefs.setString(_transactionDataKey, jsonString);
  }

  // Load transaction data
  static Future<List<Transaction>> loadTransactionData() async {
    final jsonString = _prefs.getString(_transactionDataKey);
    if (jsonString == null) return [];

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading transaction data: $e');
      return [];
    }
  }

  // Clear all data
  static Future<void> clearAllData() async {
    await _prefs.remove(_treeDataKey);
    await _prefs.remove(_transactionDataKey);
  }
}

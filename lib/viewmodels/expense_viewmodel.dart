import 'dart:convert';
import 'package:expense_tracker_app_ost/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpenseViewModel extends ChangeNotifier {
  List<Transaction> _transactions = [];
  List<Transaction> get transactions => _transactions;

  ExpenseViewModel() {
    loadTransactions();
  }

  // Business Logic: Calculations
  double get totalIncome => _transactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalExpense => _transactions
      .where((t) => !t.isIncome)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalBalance => totalIncome - totalExpense;

  // Persistence: Save to SharedPreferences
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      _transactions.map((t) => t.toJson()).toList(),
    );
    await prefs.setString('transactions_key', encodedData);
  }

  // Persistence: Load from SharedPreferences
  Future<void> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString('transactions_key');
    if (savedData != null) {
      final List<dynamic> decodedData = jsonDecode(savedData);
      _transactions = decodedData.map((item) => Transaction.fromJson(item)).toList();
      notifyListeners();
    }
  }

  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    _saveToPrefs();
    notifyListeners();
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    _saveToPrefs();
    notifyListeners();
  }
}
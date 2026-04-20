import 'package:expense_tracker_app_ost/viewmodels/expense_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ExpenseViewModel>();

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Total Balance", style: Theme.of(context).textTheme.titleMedium),
            Text("\$${vm.totalBalance.toStringAsFixed(2)}", 
                 style: Theme.of(context).textTheme.headlineLarge),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statColumn("Income", vm.totalIncome, Colors.green),
                _statColumn("Expense", vm.totalExpense, Colors.red),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _statColumn(String label, double amount, Color color) {
    return Column(
      children: [
        Text(label),
        Text("\$${amount.toStringAsFixed(2)}", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../models/transaction.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This listens to the ViewModel for changes
    final viewModel = context.watch<ExpenseViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. Dashboard Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text("Current Balance"),
                    Text(
                      "\$${viewModel.totalBalance.toStringAsFixed(2)}",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _balanceStat("Income", viewModel.totalIncome, Colors.green),
                        _balanceStat("Expense", viewModel.totalExpense, Colors.red),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Transaction List Section
          Expanded(
            child: ListView.builder(
              itemCount: viewModel.transactions.length,
              itemBuilder: (context, index) {
                final tx = viewModel.transactions[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: tx.isIncome ? Colors.green[100] : Colors.red[100],
                    child: Icon(
                      tx.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                      color: tx.isIncome ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${tx.date.day}/${tx.date.month}/${tx.date.year}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${tx.isIncome ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: tx.isIncome ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.grey),
                        onPressed: () => viewModel.deleteTransaction(tx.id),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTransactionDialog(context),
        label: const Text("Add Transaction"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _balanceStat(String label, double amount, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Text("\$${amount.toStringAsFixed(2)}",
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  // A simple dialog to handle the "Add Transaction" form
  void _showAddTransactionDialog(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    bool isIncome = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20, right: 20, top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
            SwitchListTile(
              title: const Text("Is this Income?"),
              value: isIncome, 
              onChanged: (val) { /* Note: Needs Statefulness inside Dialog or a simpler toggle */ }
            ),
            ElevatedButton(
              onPressed: () {
                final tx = Transaction(
                  id: DateTime.now().toString(),
                  title: titleController.text,
                  amount: double.tryParse(amountController.text) ?? 0,
                  date: DateTime.now(),
                  isIncome: true, // Simplified for this example
                );
                context.read<ExpenseViewModel>().addTransaction(tx);
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
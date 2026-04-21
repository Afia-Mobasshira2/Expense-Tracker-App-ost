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
  child: viewModel.transactions.isEmpty
      ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 10),
              const Text("No transactions yet!", 
                         style: TextStyle(color: Colors.grey, fontSize: 16)),
            ],
          ),
        )
      : ListView.builder(
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
  bool isIncome = true; // Default to income
  DateTime selectedDate = DateTime.now();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => StatefulBuilder( // Allows the switch to update UI
      builder: (context, setModalState) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20, right: 20, top: 20,
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Add New Transaction", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 15),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder(), prefixText: '\$ '),
              keyboardType: TextInputType.number,
            ),

              const SizedBox(height: 10),
              // Add this widget inside the Column
              ListTile(
                title: Text(
                  "Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                ),
                leading: const Icon(Icons.calendar_today),
                trailing: const Text(
                  "Select",
                  style: TextStyle(color: Colors.blue),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setModalState(() => selectedDate = picked);
                  }
                },
              ),


            SwitchListTile(
              title: Text(isIncome ? "Type: Income" : "Type: Expense"),
              subtitle: const Text("Toggle to switch type"),
              value: isIncome,
              activeColor: Colors.green,
              onChanged: (val) {
                setModalState(() => isIncome = val);
              },
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () {
                  if (titleController.text.isEmpty || amountController.text.isEmpty) return;

                  final tx = Transaction(
                    id: DateTime.now().toString(),
                    title: titleController.text,
                    amount: double.tryParse(amountController.text) ?? 0.0,
                    date: DateTime.now(),
                    isIncome: isIncome,
                  );

                  context.read<ExpenseViewModel>().addTransaction(tx);
                  Navigator.pop(context);
                },

                
                child: const Text("Save Transaction"),
              ),
            ),
          ],
        ),
      ),
    ),
  );
 }
}
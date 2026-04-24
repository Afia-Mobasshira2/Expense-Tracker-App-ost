import 'package:expense_tracker_app_ost/views/widgets/dashboard_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../models/transaction.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExpenseViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. Dashboard Section
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: DashboardCard(),
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

                      // Eye-catching Staggered Animation
                      return TweenAnimationBuilder<double>(
                       duration: const Duration(milliseconds: 500),
                       tween: Tween(begin: 0.8, end: 1.0), // Scales from 80% to 100%
                       curve: Curves.elasticOut, // This gives it a "bouncy" fun feel!
                       builder: (context, value, child) {
                         return Transform.scale(
                           scale: value,
                           child: child,
                         );
                       },
                        child: Dismissible(
                          key: Key(tx.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: Colors.redAccent,
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (direction) {
                            viewModel.deleteTransaction(tx.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("${tx.title} removed")),
                            );
                          },
                          child: ListTile(
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
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text("Delete Transaction"),
                                        content: const Text("Are you sure you want to remove this item?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              viewModel.deleteTransaction(tx.id);
                                              Navigator.pop(ctx);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text("Transaction deleted")),
                                              );
                                            },
                                            child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
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

  void _showAddTransactionDialog(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    bool isIncome = true;
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
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
              const SizedBox(height: 15),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Quick Tags:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ["Food", "Transport", "Rent", "Salary", "Gift"].map((tag) {
                  return ActionChip(
                    label: Text(tag),
                    onPressed: () => setModalState(() => titleController.text = tag),
                  );
                }).toList(),
              ),
              ListTile(
                title: Text("Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
                leading: const Icon(Icons.calendar_today),
                trailing: const Text("Select", style: TextStyle(color: Colors.blue)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setModalState(() => selectedDate = picked);
                },
              ),
              SwitchListTile(
                title: Text(isIncome ? "Type: Income" : "Type: Expense"),
                value: isIncome,
                activeColor: Colors.green,
                onChanged: (val) => setModalState(() => isIncome = val),
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
                   if (titleController.text.isEmpty ||
                        amountController.text.isEmpty)
                      return;

                    final tx = Transaction(
                      id: DateTime.now().toString(),
                      title: titleController.text,
                      amount: double.tryParse(amountController.text) ?? 0.0,
                      date: selectedDate,
                      isIncome: isIncome,
                    );

                    context.read<ExpenseViewModel>().addTransaction(tx);
                    Navigator.pop(context);

                    // --- THE FUN PART: Animated Success Feedback ---
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 10),
                            Text("${tx.title} added successfully!"),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
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
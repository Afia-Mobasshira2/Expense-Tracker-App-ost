import 'package:expense_tracker_app_ost/views/widgets/dashboard_card.dart';
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
           
           

           //Slidable List Actions
           return Dismissible(
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
                                icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                // 1. Trigger the confirmation dialog
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text("Delete Transaction"),
                                    content: const Text(
                                      "Are you sure you want to remove this item? This action cannot be undone.",
                                    ),
                                    actions: [
                                      // 2. The 'Cancel' button just closes the dialog
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text("Cancel"),
                                      ),
                                      // 3. The 'Delete' button calls the ViewModel and then closes the dialog
                                      TextButton(
                                        onPressed: () {
                                          viewModel.deleteTransaction(tx.id);
                                          Navigator.pop(
                                            ctx,
                                          ); // Close dialog after deleting

                                          // Optional: Show a quick confirmation message at the bottom
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Transaction deleted",
                                              ),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          "Delete",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                         )
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
                     // 1. Better Validation with SnackBar feedback
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter a title")),
                      );
                      return;
                    }

                    double? amount = double.tryParse(amountController.text);
                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter a valid amount"),
                        ),
                      );
                      return;
                    }

                    // 2. Create Transaction using 'selectedDate' (NOT DateTime.now)
                    final tx = Transaction(
                      id: DateTime.now().toString(),
                      title: titleController.text.trim(),
                      amount: amount,
                      date:
                          selectedDate, // Use the variable from your DatePicker!
                      isIncome: isIncome,
                    );

                    // 3. Save and Close
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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/expense_viewmodel.dart';

class DashboardCard extends StatelessWidget {
  const DashboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExpenseViewModel>();

    // Logic for the "Extraordinary" Progress Bar
    double spendingRatio = viewModel.totalIncome > 0 
        ? (viewModel.totalExpense / viewModel.totalIncome).clamp(0.0, 1.0) 
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        // Glassmorphism Gradient
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              "Current Balance",
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.6),
                    letterSpacing: 1.1,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "\$${viewModel.totalBalance.toStringAsFixed(2)}",
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
            
            const SizedBox(height: 20),

            // --- PROGRESS BAR (Visual UI Upgrade) ---
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: spendingRatio,
                minHeight: 10,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  spendingRatio > 0.8 ? Colors.orangeAccent : Colors.greenAccent,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "${(spendingRatio * 100).toStringAsFixed(0)}% of income utilized",
              style: TextStyle(
                fontSize: 10, 
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
              ),
            ),

            const SizedBox(height: 24),

            // Statistics Row
            Row(
              children: [
                _buildStatItem(
                  context,
                  label: "Income",
                  amount: viewModel.totalIncome,
                  color: Colors.greenAccent[700]!,
                  icon: Icons.arrow_downward_rounded,
                ),
                // Vertical Divider
                Container(
                  height: 30,
                  width: 1.5,
                  color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.1),
                ),
                _buildStatItem(
                  context,
                  label: "Expense",
                  amount: viewModel.totalExpense,
                  color: Colors.redAccent,
                  icon: Icons.arrow_upward_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,{ 
    required String label,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.6),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "\$${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
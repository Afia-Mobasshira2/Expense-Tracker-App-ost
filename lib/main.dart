import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Add this
import 'viewmodels/expense_viewmodel.dart'; // Add this
import 'views/home_screen.dart'; // Add this

void main() {
  runApp(
    // This is the "Parent" that provides data to the whole app
    ChangeNotifierProvider(
      create: (context) => ExpenseViewModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      // This is the "Child" that will now be able to find the Provider
      home: const HomeScreen(),
    );
  }
}
class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final bool isIncome; // true for Income, false for Expense

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
  });

  // Convert object to Map for JSON encoding
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'date': date.toIso8601String(),
        'isIncome': isIncome,
      };

  // Create object from Map (after JSON decoding)
  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'],
        title: json['title'],
        amount: json['amount'],
        date: DateTime.parse(json['date']),
        isIncome: json['isIncome'],
      );
}
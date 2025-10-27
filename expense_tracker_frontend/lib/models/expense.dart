class Expense {
  final int? id;
  final String? username;
  final String? receiptImage;
  final String? merchantName;
  final double amount;
  final String currency;
  final String category;
  final String paymentMethod;
  final DateTime date;
  final String? description;
  final List<ExpenseItem>? items;
  final double tax;
  final double tip;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Expense({
    this.id,
    this.username,
    this.receiptImage,
    this.merchantName,
    required this.amount,
    this.currency = 'USD',
    this.category = 'other',
    this.paymentMethod = 'cash',
    required this.date,
    this.description,
    this.items,
    this.tax = 0.0,
    this.tip = 0.0,
    this.createdAt,
    this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      username: json['username'],
      receiptImage: json['receipt_image'],
      merchantName: json['merchant_name'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      currency: json['currency'] ?? 'USD',
      category: json['category'] ?? 'other',
      paymentMethod: json['payment_method'] ?? 'cash',
      date: DateTime.parse(json['date']),
      description: json['description'],
      items: json['items'] != null
          ? (json['items'] as List).map((i) => ExpenseItem.fromJson(i)).toList()
          : null,
      tax: double.tryParse(json['tax'].toString()) ?? 0.0,
      tip: double.tryParse(json['tip'].toString()) ?? 0.0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'receipt_image': receiptImage,
      'merchant_name': merchantName,
      'amount': amount,
      'currency': currency,
      'category': category,
      'payment_method': paymentMethod,
      'date': date.toIso8601String(),
      'description': description,
      'items': items?.map((i) => i.toJson()).toList(),
      'tax': tax,
      'tip': tip,
    };
  }
}

class ExpenseItem {
  final String name;
  final String? quantity;
  final double? price;
  final double? total;

  ExpenseItem({
    required this.name,
    this.quantity,
    this.price,
    this.total,
  });

  factory ExpenseItem.fromJson(Map<String, dynamic> json) {
    return ExpenseItem(
      name: json['name'],
      quantity: json['quantity']?.toString(),
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
      total: json['total'] != null ? double.tryParse(json['total'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
      'total': total,
    };
  }
}

class Budget {
  final int? id;
  final String? username;
  final String category;
  final double amount;
  final String period;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Budget({
    this.id,
    this.username,
    required this.category,
    required this.amount,
    this.period = 'monthly',
    this.createdAt,
    this.updatedAt,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      username: json['username'],
      category: json['category'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      period: json['period'] ?? 'monthly',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'category': category,
      'amount': amount,
      'period': period,
    };
  }
}

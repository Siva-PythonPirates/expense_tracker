import 'package:flutter/material.dart';

const Map<String, IconData> categoryIcons = {
  'food': Icons.restaurant,
  'transport': Icons.directions_car,
  'shopping': Icons.shopping_bag,
  'entertainment': Icons.movie,
  'utilities': Icons.home,
  'healthcare': Icons.local_hospital,
  'education': Icons.school,
  'other': Icons.category,
};

const Map<String, Color> categoryColors = {
  'food': Colors.orange,
  'transport': Colors.blue,
  'shopping': Colors.pink,
  'entertainment': Colors.purple,
  'utilities': Colors.green,
  'healthcare': Colors.red,
  'education': Colors.indigo,
  'other': Colors.grey,
};

const Map<String, String> categoryLabels = {
  'food': 'Food & Dining',
  'transport': 'Transportation',
  'shopping': 'Shopping',
  'entertainment': 'Entertainment',
  'utilities': 'Utilities',
  'healthcare': 'Healthcare',
  'education': 'Education',
  'other': 'Other',
};

const Map<String, String> paymentMethodLabels = {
  'cash': 'Cash',
  'credit_card': 'Credit Card',
  'debit_card': 'Debit Card',
  'upi': 'UPI',
  'other': 'Other',
};

const List<String> categories = [
  'food',
  'transport',
  'shopping',
  'entertainment',
  'utilities',
  'healthcare',
  'education',
  'other',
];

const List<String> paymentMethods = [
  'cash',
  'credit_card',
  'debit_card',
  'upi',
  'other',
];

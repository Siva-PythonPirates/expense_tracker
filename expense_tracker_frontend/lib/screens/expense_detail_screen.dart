import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../utils/constants.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final Expense expense;

  const ExpenseDetailScreen({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final category = categoryLabels[expense.category] ?? 'Other';
    final icon = categoryIcons[expense.category] ?? Icons.category;
    final color = categoryColors[expense.category] ?? Colors.grey;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Receipt image (if available)
            if (expense.receiptImage != null)
              Container(
                height: 300,
                color: Colors.grey[200],
                child: Image.network(
                  expense.receiptImage!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                    );
                  },
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: color.withOpacity(0.2),
                          child: Icon(icon, size: 40, color: color),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '\$${expense.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          category,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),

                  // Details
                  _buildDetailRow('Merchant', expense.merchantName ?? 'Unknown'),
                  _buildDetailRow('Date', DateFormat('MMM dd, yyyy - hh:mm a').format(expense.date)),
                  _buildDetailRow('Payment Method', paymentMethodLabels[expense.paymentMethod] ?? 'Other'),
                  _buildDetailRow('Currency', expense.currency),
                  
                  if (expense.tax > 0)
                    _buildDetailRow('Tax', '\$${expense.tax.toStringAsFixed(2)}'),
                  
                  if (expense.tip > 0)
                    _buildDetailRow('Tip', '\$${expense.tip.toStringAsFixed(2)}'),

                  if (expense.description != null && expense.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(expense.description!),
                  ],

                  if (expense.items != null && expense.items!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Items',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...expense.items!.map((item) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: item.quantity != null
                            ? Text('Quantity: ${item.quantity}')
                            : null,
                        trailing: item.total != null
                            ? Text(
                                '\$${item.total!.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                    )),
                  ],

                  const SizedBox(height: 16),
                  const Divider(),
                  
                  if (expense.createdAt != null)
                    Text(
                      'Created: ${DateFormat('MMM dd, yyyy - hh:mm a').format(expense.createdAt!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

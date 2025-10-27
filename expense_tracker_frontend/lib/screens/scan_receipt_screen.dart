import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../models/expense.dart';
import '../utils/constants.dart';
import 'package:intl/intl.dart';

class ScanReceiptScreen extends StatefulWidget {
  const ScanReceiptScreen({super.key});

  @override
  State<ScanReceiptScreen> createState() => ScanReceiptScreenState();
}

class ScanReceiptScreenState extends State<ScanReceiptScreen> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();
  
  File? _imageFile;
  bool _isScanning = false;
  Expense? _scannedExpense;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
        _scanReceipt();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _scanReceipt() async {
    if (_imageFile == null) return;

    setState(() {
      _isScanning = true;
    });

    try {
      print('📸 Starting receipt scan...');
      print('📁 Image file: ${_imageFile!.path}');
      
      final result = await _apiService.scanReceipt(_imageFile!);
      
      print('✅ Scan result received: $result');
      
      setState(() {
        _scannedExpense = Expense.fromJson(result['expense']);
        _isScanning = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Receipt scanned successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ Scan failed: $e');
      print('Stack trace: $stackTrace');
      
      setState(() {
        _isScanning = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to scan receipt: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Receipt'),
        actions: [
          if (_scannedExpense != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image preview
              if (_imageFile != null)
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _imageFile!,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No image selected'),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Scan button
              ElevatedButton.icon(
                onPressed: _isScanning ? null : _showImageSourceDialog,
                icon: const Icon(Icons.camera_alt),
                label: Text(_imageFile == null ? 'Select Receipt Image' : 'Change Image'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Loading indicator
              if (_isScanning)
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Scanning receipt...'),
                    ],
                  ),
                ),
              
              // Extracted data
              if (_scannedExpense != null && !_isScanning)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Extracted Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        _buildInfoRow('Merchant', _scannedExpense!.merchantName ?? 'Unknown'),
                        _buildInfoRow('Amount', '\$${_scannedExpense!.amount.toStringAsFixed(2)}'),
                        _buildInfoRow('Currency', _scannedExpense!.currency),
                        _buildInfoRow('Category', categoryLabels[_scannedExpense!.category] ?? 'Other'),
                        _buildInfoRow('Payment Method', paymentMethodLabels[_scannedExpense!.paymentMethod] ?? 'Other'),
                        _buildInfoRow('Date', DateFormat('MMM dd, yyyy').format(_scannedExpense!.date)),
                        if (_scannedExpense!.tax > 0)
                          _buildInfoRow('Tax', '\$${_scannedExpense!.tax.toStringAsFixed(2)}'),
                        if (_scannedExpense!.tip > 0)
                          _buildInfoRow('Tip', '\$${_scannedExpense!.tip.toStringAsFixed(2)}'),
                        if (_scannedExpense!.description != null)
                          _buildInfoRow('Description', _scannedExpense!.description!),
                        
                        if (_scannedExpense!.items != null && _scannedExpense!.items!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Items',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._scannedExpense!.items!.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.name}${item.quantity != null ? ' (${item.quantity})' : ''}',
                                  ),
                                ),
                                if (item.total != null)
                                  Text('\$${item.total!.toStringAsFixed(2)}'),
                              ],
                            ),
                          )),
                        ],
                        
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            child: const Text('Done'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

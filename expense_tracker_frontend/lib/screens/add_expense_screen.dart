import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => AddExpenseScreenState();
}

class AddExpenseScreenState extends State<AddExpenseScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  
  final _merchantController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _category = 'other';
  String _paymentMethod = 'cash';
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animationController.forward();
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6C5CE7),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final expense = Expense(
        merchantName: _merchantController.text,
        amount: double.parse(_amountController.text),
        category: _category,
        paymentMethod: _paymentMethod,
        date: _selectedDate,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      );

      await _apiService.createExpense(expense);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Expense added successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add expense: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F6FA),
      body: Stack(
        children: [
          // Gradient Header
          Container(
            height: 220,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
                    : [const Color(0xFF6C5CE7), const Color(0xFFA29BFE)],
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // App Bar
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Add Expense',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Form
                Expanded(
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeOut,
                    )),
                    child: FadeTransition(
                      opacity: _animationController,
                      child: Container(
                        margin: const EdgeInsets.only(top: 20),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF121212) : const Color(0xFFF5F6FA),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildLabel('Merchant Name', isDark),
                                TextFormField(
                                  controller: _merchantController,
                                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                                  decoration: InputDecoration(
                                    hintText: 'Where did you spend?',
                                    hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                                    prefixIcon: Icon(
                                      Icons.store_rounded,
                                      color: isDark ? const Color(0xFF8B7FE8) : const Color(0xFF6C5CE7),
                                    ),
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF1e1e2e) : Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter merchant name';
                                    }
                                    return null;
                                  },
                                ),
                                
                                const SizedBox(height: 20),
                                
                                _buildLabel('Amount', isDark),
                                TextFormField(
                                  controller: _amountController,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black87,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '0.00',
                                    hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                                    prefixIcon: Container(
                                      padding: const EdgeInsets.all(14),
                                      child: Text(
                                        '\$',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? const Color(0xFF8B7FE8) : const Color(0xFF6C5CE7),
                                        ),
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF1e1e2e) : Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter amount';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Please enter valid amount';
                                    }
                                    return null;
                                  },
                                ),
                                
                                const SizedBox(height: 20),
                                
                                _buildLabel('Category', isDark),
                                Container(
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1e1e2e) : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    value: _category,
                                    dropdownColor: isDark ? const Color(0xFF1e1e2e) : Colors.white,
                                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                      prefixIcon: Icon(
                                        Icons.category_rounded,
                                        color: isDark ? const Color(0xFF8B7FE8) : const Color(0xFF6C5CE7),
                                      ),
                                    ),
                                    items: categories.map((category) {
                                      return DropdownMenuItem(
                                        value: category,
                                        child: Row(
                                          children: [
                                            Icon(categoryIcons[category], size: 20, color: categoryColors[category]),
                                            const SizedBox(width: 12),
                                            Text(
                                              categoryLabels[category]!,
                                              style: GoogleFonts.poppins(
                                                color: isDark ? Colors.white : Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _category = value!;
                                      });
                                    },
                                  ),
                                ),
                                
                                const SizedBox(height: 20),
                                
                                _buildLabel('Payment Method', isDark),
                                Container(
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1e1e2e) : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    value: _paymentMethod,
                                    dropdownColor: isDark ? const Color(0xFF1e1e2e) : Colors.white,
                                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                      prefixIcon: Icon(
                                        Icons.payment_rounded,
                                        color: isDark ? const Color(0xFF8B7FE8) : const Color(0xFF6C5CE7),
                                      ),
                                    ),
                                    items: paymentMethods.map((method) {
                                      return DropdownMenuItem(
                                        value: method,
                                        child: Text(
                                          paymentMethodLabels[method]!,
                                          style: GoogleFonts.poppins(
                                            color: isDark ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _paymentMethod = value!;
                                      });
                                    },
                                  ),
                                ),
                                
                                const SizedBox(height: 20),
                                
                                _buildLabel('Date', isDark),
                                InkWell(
                                  onTap: () => selectDate(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1e1e2e) : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_rounded,
                                          color: isDark ? const Color(0xFF8B7FE8) : const Color(0xFF6C5CE7),
                                        ),
                                        const SizedBox(width: 16),
                                        Text(
                                          DateFormat('MMMM dd, yyyy').format(_selectedDate),
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            color: isDark ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 20),
                                
                                _buildLabel('Description (Optional)', isDark),
                                TextFormField(
                                  controller: _descriptionController,
                                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                                  decoration: InputDecoration(
                                    hintText: 'Add a note...',
                                    hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                                    prefixIcon: Icon(
                                      Icons.notes_rounded,
                                      color: isDark ? const Color(0xFF8B7FE8) : const Color(0xFF6C5CE7),
                                    ),
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF1e1e2e) : Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  maxLines: 3,
                                ),
                                
                                const SizedBox(height: 32),
                                
                                Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isDark
                                          ? [const Color(0xFF8B7FE8), const Color(0xFFB8B1FF)]
                                          : [const Color(0xFF6C5CE7), const Color(0xFFA29BFE)],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (isDark ? const Color(0xFF8B7FE8) : const Color(0xFF6C5CE7))
                                            .withOpacity(0.4),
                                        blurRadius: 16,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _isSaving ? null : _saveExpense,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: _isSaving
                                        ? const CircularProgressIndicator(color: Colors.white)
                                        : Text(
                                            'Add Expense',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white70 : Colors.grey[700],
        ),
      ),
    );
  }
}

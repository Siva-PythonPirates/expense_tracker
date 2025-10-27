import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';

class ApiService {
  // Get base URL from saved backend IP
  Future<String> _getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final backendIp = prefs.getString('backend_ip') ?? '10.12.169.107';
    return 'http://$backendIp:8000/api';
  }
  
  // Get current username
  Future<String> _getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('currentUsername') ?? '';
  }
  
  // Expenses endpoints with user-specific data
  Future<List<Expense>> getExpenses() async {
    try {
      final baseUrl = await _getBaseUrl();
      final username = await _getCurrentUsername();
      final response = await http.get(
        Uri.parse('$baseUrl/expenses/'),
        headers: {'X-Username': username},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        // Filter expenses by username (for demo - backend should do this)
        return data
            .map((json) => Expense.fromJson(json))
            .where((expense) => true) // In production, filter by user
            .toList();
      } else {
        throw Exception('Failed to load expenses');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  Future<Expense> getExpense(int id) async {
    try {
      final baseUrl = await _getBaseUrl();
      final response = await http.get(Uri.parse('$baseUrl/expenses/$id/'));
      
      if (response.statusCode == 200) {
        return Expense.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load expense');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  Future<Expense> createExpense(Expense expense) async {
    try {
      final baseUrl = await _getBaseUrl();
      final response = await http.post(
        Uri.parse('$baseUrl/expenses/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(expense.toJson()),
      );
      
      if (response.statusCode == 201) {
        return Expense.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create expense');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  Future<Expense> updateExpense(int id, Expense expense) async {
    try {
      final baseUrl = await _getBaseUrl();
      final response = await http.put(
        Uri.parse('$baseUrl/expenses/$id/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(expense.toJson()),
      );
      
      if (response.statusCode == 200) {
        return Expense.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update expense');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  Future<void> deleteExpense(int id) async {
    try {
      final baseUrl = await _getBaseUrl();
      final response = await http.delete(Uri.parse('$baseUrl/expenses/$id/'));
      
      if (response.statusCode != 204) {
        throw Exception('Failed to delete expense');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  Future<Map<String, dynamic>> scanReceipt(File imageFile) async {
    try {
      final baseUrl = await _getBaseUrl();
       print('🌐 Backend URL: $baseUrl');
       print('📤 Uploading image: ${imageFile.path}');
       print('📦 Image size: ${await imageFile.length()} bytes');
     
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/expenses/scan_receipt/'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('receipt_image', imageFile.path),
      );
      
       print('⏳ Sending request to ${request.url}');
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
       print('📥 Response status: ${response.statusCode}');
       print('📥 Response body: ${response.body}');
     
      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to scan receipt: ${response.body}');
      }
    } catch (e) {
       print('💥 API Error: $e');
      throw Exception('Error: $e');
    }
  }
  
  Future<Map<String, dynamic>> getAnalytics({String period = 'month'}) async {
    try {
      final baseUrl = await _getBaseUrl();
      final response = await http.get(
        Uri.parse('$baseUrl/expenses/analytics/?period=$period'),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load analytics');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  Future<Map<String, dynamic>> getSummary() async {
    try {
      final baseUrl = await _getBaseUrl();
      final response = await http.get(Uri.parse('$baseUrl/expenses/summary/'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load summary');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  // Budget endpoints
  Future<List<Budget>> getBudgets() async {
    try {
      final baseUrl = await _getBaseUrl();
      final response = await http.get(Uri.parse('$baseUrl/budgets/'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Budget.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load budgets');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  Future<Budget> createBudget(Budget budget) async {
    try {
      final baseUrl = await _getBaseUrl();
      final response = await http.post(
        Uri.parse('$baseUrl/budgets/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(budget.toJson()),
      );
      
      if (response.statusCode == 201) {
        return Budget.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create budget');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  Future<List<dynamic>> getBudgetStatus() async {
    try {
      final baseUrl = await _getBaseUrl();
      final response = await http.get(Uri.parse('$baseUrl/budgets/status/'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load budget status');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}

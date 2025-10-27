import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'dart:convert';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  Future<bool> register(String username, String email, String password) async {
    // Simulate API call - replace with actual backend authentication
    await Future.delayed(const Duration(seconds: 1));
    
    final prefs = await SharedPreferences.getInstance();
    
    // Check if username already exists
    final users = prefs.getStringList('users') ?? [];
    for (var userJson in users) {
      final user = json.decode(userJson);
      if (user['username'] == username) {
        return false; // Username already exists
      }
    }
    
    // Store new user
    final newUser = {
      'username': username,
      'email': email,
      'password': password, // In production, hash this!
    };
    users.add(json.encode(newUser));
    await prefs.setStringList('users', users);
    
    // Auto-login after registration
    _currentUser = User(
      username: username,
      email: email,
      profileImage: null,
    );
    _isAuthenticated = true;
    
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('currentUsername', username);
    
    notifyListeners();
    return true;
  }

  Future<bool> login(String username, String password) async {
    // Simulate API call - replace with actual backend authentication
    await Future.delayed(const Duration(seconds: 1));
    
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList('users') ?? [];
    
    // Check credentials
    for (var userJson in users) {
      final user = json.decode(userJson);
      if (user['username'] == username && user['password'] == password) {
        _currentUser = User(
          username: username,
          email: user['email'],
          profileImage: null,
        );
        _isAuthenticated = true;
        
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('currentUsername', username);
        
        notifyListeners();
        return true;
      }
    }
    
    return false;
  }

  Future<void> logout() async {
    _currentUser = null;
    _isAuthenticated = false;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('currentUsername');
    
    notifyListeners();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final username = prefs.getString('currentUsername');
    
    if (isLoggedIn && username != null) {
      // Get user data
      final users = prefs.getStringList('users') ?? [];
      for (var userJson in users) {
        final user = json.decode(userJson);
        if (user['username'] == username) {
          _currentUser = User(
            username: username,
            email: user['email'],
          );
          _isAuthenticated = true;
          notifyListeners();
          break;
        }
      }
    }
  }
}

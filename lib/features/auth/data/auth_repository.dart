import 'dart:convert';

import 'package:flutter_task_manager/core/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

// [AuthRepository] handles all direct communication with SharedPreferences for auth.
/// It acts as the "Database Driver" for the application.
class AuthRepository {
  // Generates unique IDs for new users so data keys never overlap
  final Uuid _uuid = const Uuid();

  /// Handles creating a new account.
  /// Includes a safety check to prevent multiple accounts with the same email.
  /* 
  In Dart and Flutter, Future<void> represents a promise that an operation will happen in the background and eventually finish, 
  but it won't return a specific value (like a String or Integer) when it’s done.
  */
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();

    // 1. DATA VALIDATION: Loop through all keys to check if the email is already taken.
    // We filter keys to make sure we only look at "User Profile" keys. we are excluding _tasks, _image data
    for (var key in allKeys) {
      if (key.startsWith('user_') &&
          !key.contains('_tasks') &&
          !key.contains('_image')) {
        final data = prefs.getString(key);
        if (data == null) continue;

        try {
          final decoded = jsonDecode(data);
          // Case-insensitive comparison: "Mary@me.com" is the same as "mary@me.com"
          if (decoded['email'].toString().toLowerCase() ==
              email.toLowerCase()) {
            throw Exception("Email already registered");
          }
        } catch (e) {
          // If we found a duplicate email, rethrow that specific exception
          if (e.toString().contains('Email already registered')) rethrow;
          continue;
        }
      }
    }

    // 2. If no duplicate is found, create a new unique ID and save the data
    final userId = _uuid.v4();
    final userMap = {
      'id': userId,
      'name': name,
      'email': email,
      'password': password,
    };

    await prefs.setString('user_$userId', jsonEncode(userMap));
  }

  /// Verifies credentials and creates a session.
  Future<User> login({required String email, required String password}) async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();
    Map<String, dynamic>? foundUserData;

    // 1. SEARCH: Look through storage for a JSON object matching this email.
    for (var key in allKeys) {
      // STRICT FILTER: We ignore task lists and image paths to avoid parsing errors.
      if (key.startsWith('user_') &&
          !key.endsWith('_tasks') &&
          !key.startsWith('profile_image_') &&
          key != 'current_user_id') {
        final data = prefs.getString(key);
        if (data == null) continue;

        try {
          final decoded = jsonDecode(data);

          if (decoded is Map &&
              decoded['email']?.toString().toLowerCase() ==
                  email.toLowerCase()) {
            foundUserData = decoded as Map<String, dynamic>;
            break;
          }
        } catch (e) {
          continue;
        }
      }
    }

    // 2. AUTHENTICATION: Check if the user exists and if the password matches.
    if (foundUserData == null) throw Exception('User not found.');
    if (foundUserData['password'] != password) {
      throw Exception('Incorrect password');
    }

    // 3. SESSION START: Store the user's ID as the 'current_user_id'
    final user = User.fromJson(foundUserData);
    await prefs.setString('current_user_id', user.id);

    return user;
  }

  /// Destroys the current session by removing the 'Master Key'.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
  }

  /// Checks if there is an active session on the device.
  /// This is used to automatically log the user in when they open the app.

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Retrieve the 'Master Key' (ID) of the logged-in user
    final userId = prefs.getString('current_user_id');
    if (userId == null) return null;

    // 2. Look up the full user data using that unique ID
    final userJson = prefs.getString('user_$userId');
    if (userJson == null) return null;

    // 3. Convert the saved string back into a User object
    return User.fromJson(jsonDecode(userJson));
  }
}

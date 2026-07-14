import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_task_manager/core/models/user.dart';
import 'package:flutter_task_manager/features/auth/data/auth_repository.dart';


/// The [authProvider] is a global listener.
/// It allows the UI to react whenever a user logs in or out.
final authProvider = AsyncNotifierProvider<AuthController, User?>(
  AuthController.new,
);

/// [AuthController] manages the logic for Authentication.
/// It acts as the "brain" between the UI and the Data Repository.
class AuthController extends AsyncNotifier<User?> {
  /// The [build] method is the initial state of the provider.
  /// When the app starts, it checks if a user is already saved in storage.
  @override
  Future<User?> build() async {
    return await AuthRepository().getCurrentUser();
  }

  /// Handles user registration.
  /// It doesn't update the global 'state' because we want the user
  /// to stay on the login/register flow until they officially log in.
  Future<void> register(String name, String email, String password) async {
    try {
      await AuthRepository().register(
        name: name,
        email: email,
        password: password,
      );
    } catch (e) {
      log('Registration error caught in controller: $e');
      // IMPORTANT: We rethrow the error so the RegisterPage can catch it
      // and show the red error message to the user.
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  /// Handles the Login process.
  /// This is the most critical part for ensuring multi-user security.
  Future<void> login(String email, String password) async {
    try {
      // 1. Authenticate with the repository
      final user = await AuthRepository().login(
        email: email,
        password: password,
      );

      // 3. Set the global state to the logged-in user.
      // This triggers the 'App' widget to automatically navigate to the Home screen.
      state = AsyncData(user);
    } catch (e) {
      // If login fails, we pass the error back to the UI to show an alert.
      rethrow;
    }
  }

  /// Handles the Logout process.
  Future<void> logout() async {
    // Show a loading spinner globally while logging out
    state = const AsyncValue.loading();

    // AsyncValue.guard is a safe way to perform a task and return a value.
    // If successful, it returns 'null' (meaning no user is logged in).
    state = await AsyncValue.guard(() async {
      await AuthRepository().logout();
      return null; // State becomes null, pushing user back to Login screen
    });
  }
}
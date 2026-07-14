import 'dart:convert';
import 'dart:io';

import 'package:flutter_task_manager/core/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRepository {
  Future<User> getProfile() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Identify who is logged in
    final currentUserId = prefs.getString('current_user_id');
    if (currentUserId == null) throw Exception('No user logged in');

    // 2. Fetch the raw JSON user data
    final userJson = prefs.getString('user_$currentUserId');
    if (userJson == null) throw Exception('Profile not found');

    final userMap = jsonDecode(userJson) as Map<String, dynamic>;

    // 3. DATA ISOLATION: Load the image path using a user-specific key.
    // This ensures Josh never sees Souvik's profile picture.
    final imagePath = prefs.getString('profile_image_$currentUserId');

    // 4. Combine the base user data with the image path and return the object
    return User.fromJson(userMap).copyWith(profileImagePath: imagePath);
  }

  Future<User> updateProfile(User user) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Fetch current data from disk to perform a "Safe Merge"
    final String? existingData = prefs.getString('user_${user.id}');
    Map<String, dynamic> userMap = user.toJson();

    if (existingData != null) {
      final Map<String, dynamic> existingMap = jsonDecode(existingData);

      // 2. PASSWORD PROTECTION: If the updated user object doesn't contain a password,
      // we make sure to grab the existing one so the user isn't locked out later.
      if (user.password == null) {
        userMap['password'] = existingMap['password'];
      }
    }

    // 3. Save the merged data back to the disk
    await prefs.setString('user_${user.id}', jsonEncode(userMap));
    return user;
  }

  Future<User> updateProfileImage(File imageFile) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Verify session
    final currentUserId = prefs.getString('current_user_id');
    if (currentUserId == null) throw Exception('No user logged in');

    // 2. Save the file path string (not the actual bytes) to SharedPreferences.
    // In a real app, you might upload this file to a server like Firebase Storage.
    await prefs.setString('profile_image_$currentUserId', imageFile.path);

    // 3. Return the fully refreshed profile object
    return await getProfile();
  }
}
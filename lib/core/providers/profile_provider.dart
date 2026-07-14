import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_task_manager/core/models/user.dart';
import 'package:flutter_task_manager/features/profile/data/profile_repository.dart';

/// The [profileProvider] manages the profile state of the currently logged-in user.
/// It uses [User] as the data type because it provides the name, email, and photo path.
final profileProvider = AsyncNotifierProvider<ProfileController, User>(
  ProfileController.new,
);

/// [ProfileController] handles all logic related to updating user information.
class ProfileController extends AsyncNotifier<User> {
  /// The [build] method initializes the provider.
  /// It fetches the profile data from the repository as soon as the provider is accessed.
  @override
  Future<User> build() async {
    // This will fetch data based on the 'current_user_id' stored in SharedPreferences
    return await ProfileRepository().getProfile();
  }

  /// Updates the user's textual information (Name and Email).
  Future<void> updateProfile(User user) async {
    // 1. Set state to loading so the UI can show a spinner
    state = const AsyncValue.loading();

    // 2. Execute the update and update the local state with the result
    // AsyncValue.guard catches any errors automatically during the process
    state = await AsyncValue.guard(() async {
      return await ProfileRepository().updateProfile(user);
    });
  }

  /// Specifically handles the updating of the profile picture.
  /// Takes a [File] object representing the image picked from the gallery or camera.
  Future<void> updateProfileImage(File imageFile) async {
    // Set loading state while the file path is being saved to storage
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      // The repository saves the path and returns the updated User object
      return await ProfileRepository().updateProfileImage(imageFile);
    });
  }
}
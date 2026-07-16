import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_task_manager/core/providers/profile_provider.dart';
import 'package:flutter_task_manager/features/profile/presentation/widgets/profile_image_picker.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);

    return profileState.when(
      data: (user) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              ProfileImagePicker(
                imagePath: user.profileImagePath,
                onImageSelected: (File image) {
                  ref.read(profileProvider.notifier).updateProfileImage(image);
                },
              ),

              const SizedBox(height: 30),

              _buildProfileField(
                'Name',
                user.name,
                Icons.person,
                onTap: () => _showEditDialog(context, ref, 'Name', user.name, (
                  value,
                ) {
                  // Uses copyWith to update only the name while keeping other data intact
                  ref
                      .read(profileProvider.notifier)
                      .updateProfile(user.copyWith(name: value));
                }),
              ),
              const SizedBox(height: 20),

              _buildProfileField(
                'Email',
                user.email,
                Icons.email,
                onTap: null, // Passing null hides the edit icon
              ),
              const SizedBox(height: 40),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('App Settings'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Placeholder for navigation to Settings
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),

      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error'),
            const SizedBox(height: 20),
            ElevatedButton(
              // ref.invalidate tells Riverpod to throw away the error and try build() again.
              onPressed: () => ref.invalidate(profileProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// UI HELPER: Creates a consistent look for profile data rows.
  Widget _buildProfileField(
    String label,
    String value,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(value),
        trailing: onTap != null ? const Icon(Icons.edit) : null,
        onTap: onTap,
      ),
    );
  }

  /// INTERACTION HELPER: Opens a popup dialog to edit profile information.
  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    String field,
    String currentValue,
    Function(String) onSave,
  ) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $field'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Enter new $field'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close without saving
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onSave(controller.text.trim()); // Execute the update logic
              Navigator.pop(context); // Close dialog
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'dart:developer';

import 'package:flutter_task_manager/core/models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [TaskRepository] handles the actual storage and retrieval of tasks.
/// It uses SharedPreferences to persist data on the phone's memory.
class TaskRepository {

  /// PRIVATE HELPER: This is the most important method for multi-user apps.
  /// It creates a unique key for each user (e.g., 'user_123_tasks').
  /// This ensures that User A cannot see User B's tasks.
  Future<String?> _getUserTaskKey() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('current_user_id');
    return userId != null ? 'user_${userId}_tasks' : null;
  }

  

  /// [READ]: Fetches all tasks belonging to the currently logged-in user.
  Future<List<Task>> getTasks() async {
    final key = await _getUserTaskKey();
    if (key == null) return []; // Return empty list if no user is found

    final prefs = await SharedPreferences.getInstance();
    // SharedPreferences stores lists as List<String>
    final tasksJson = prefs.getStringList(key) ?? [];

    // Map each String (JSON) back into a Task object
    return tasksJson.map((json) => Task.fromJson(jsonDecode(json))).toList();
  }

  /// PRIVATE HELPER: Saves the entire list of tasks back to disk.
  /// Since SharedPreferences doesn't allow editing a single item in a list,
  /// we have to overwrite the whole list every time something changes.
  Future<void> _saveTasks(List<Task> tasks) async {
    final key = await _getUserTaskKey();
    if (key == null) return;

    final prefs = await SharedPreferences.getInstance();
    // Convert Task objects into JSON strings for storage
    final tasksJson = tasks.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList(key, tasksJson);
  }

  /// [CREATE]: Adds a new task to the user's specific list.
  Future<void> addTask(Task task) async {
    final tasks = await getTasks(); // Get existing tasks
    tasks.add(task); // Add the new one
    await _saveTasks(tasks); // Save the updated list
  }

  /// [UPDATE]: Finds an existing task by its ID and replaces it with new data.
  Future<void> updateTask(Task updatedTask) async {
    try {
      final tasks = await getTasks();
      
      // Find the position (index) of the task we want to change
      final index = tasks.indexWhere((t) => t.id == updatedTask.id);

      if (index != -1) {
        tasks[index] = updatedTask; // Replace old task with the updated one
        await _saveTasks(tasks);
        log('Task updated successfully: ${updatedTask.id}');
      }
    } catch (e) {
      log('Error updating task: $e');
      rethrow;
    }
  }

  /// [DELETE]: Removes a task from the list using its unique ID.
  Future<void> deleteTask(String taskId) async {
    final tasks = await getTasks();
    // Keep only the tasks that DO NOT match the ID we want to delete
    tasks.removeWhere((t) => t.id == taskId);
    await _saveTasks(tasks);
  }

  /// [UPDATE]: A quick way to mark a task as Done or Not Done.
  Future<void> toggleTaskCompletion(String taskId) async {
    final tasks = await getTasks();
    final index = tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      // Create a copy of the task with the opposite 'isCompleted' value
      tasks[index] = tasks[index].copyWith(
        isCompleted: !tasks[index].isCompleted,
      );
      await _saveTasks(tasks);
    }
  }
}
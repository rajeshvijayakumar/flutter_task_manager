import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_task_manager/core/models/task.dart';
import 'package:flutter_task_manager/features/task/data/task_repository.dart';


/// The [tasksProvider] is a global listener for the list of tasks.
/// It uses an AsyncNotifier because fetching data from local storage is an asynchronous operation.
final tasksProvider = AsyncNotifierProvider<TaskController, List<Task>>(
  TaskController.new,
);

/// [TaskController] manages the business logic for all task-related actions.
class TaskController extends AsyncNotifier<List<Task>> {
  /// The [build] method defines the initial state of our task list.
  /// It is called automatically when the provider is first used.
  @override
  Future<List<Task>> build() async {
    // Fetches the specific tasks belonging to the currently logged-in user.
    return await TaskRepository().getTasks();
  }

  /// [CREATE]: Adds a new task to the user's list.
  Future<void> addTask(Task task) async {
    // 1. Set state to loading so the UI can show a progress indicator.
    state = const AsyncValue.loading();

    // 2. Use guard to safely perform the operation.
    state = await AsyncValue.guard(() async {
      // Save the task to SharedPreferences via the repository.
      await TaskRepository().addTask(task);
      // Re-fetch the updated list from storage to ensure the UI is in sync.
      return await TaskRepository().getTasks();
    });
  }

  /// [UPDATE]: Modifies an existing task (e.g., changing the title or description).
  Future<void> updateTask(Task task) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // Send the updated task object to the repository.
      await TaskRepository().updateTask(task);
      // Refresh the list.
      return await TaskRepository().getTasks();
    });
  }

  /// [DELETE]: Removes a task from storage using its unique ID.
  Future<void> deleteTask(String taskId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await TaskRepository().deleteTask(taskId);
      // Refresh the list so the deleted task disappears from the screen.
      return await TaskRepository().getTasks();
    });
  }

  /// [UPDATE]: A specialized update method to quickly flip the completion status.
  Future<void> toggleTaskCompletion(String taskId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // Tell the repository to flip the 'isCompleted' boolean for this specific ID.
      await TaskRepository().toggleTaskCompletion(taskId);
      // Refresh the list to move the task to the 'Completed' section in the UI.
      return await TaskRepository().getTasks();
    });
  }
}
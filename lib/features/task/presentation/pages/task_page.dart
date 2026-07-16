import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_task_manager/core/models/task.dart';
import 'package:flutter_task_manager/core/providers/auth_provider.dart';
import 'package:flutter_task_manager/core/providers/task_provider.dart';
import 'package:flutter_task_manager/core/providers/theme_provider.dart';
import 'package:flutter_task_manager/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter_task_manager/features/task/data/presentation/pages/edit_task_page.dart';
import 'package:flutter_task_manager/features/task/presentation/pages/add_task_page.dart';
import 'package:flutter_task_manager/features/task/presentation/widgets/task_item.dart';

class TaskPage extends ConsumerStatefulWidget {
  const TaskPage({super.key});

  @override
  ConsumerState<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends ConsumerState<TaskPage> {
  // Local state to track which tab is currently active
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    // After the very first frame is drawn, we load the user's preferred theme.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(themeProvider.notifier).loadTheme();
    });
  }

  @override
  Widget build(BuildContext context) {
    // We watch the tasks and the current theme mode.
    final tasksState = ref.watch(tasksProvider);
    final themeMode = ref.watch(
      themeProvider.select((state) => state.themeMode),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'My Tasks' : 'My Profile'),
        actions: [
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: _selectedIndex == 0 ? _buildTasksList(tasksState) : ProfilePage(),

      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddTaskPage()),
                );
              },
              child: Icon(Icons.add),
            )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,

        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },

        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // Helper Widget: Handles the Async states (Data, Loading, Error) for the task list.
  Widget _buildTasksList(AsyncValue<List<Task>> tasksState) {
    return tasksState.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return const Center(child: Text('No tasks yet. Add a new task!'));
        }
        // RefreshIndicator allows "Pull-to-refresh" functionality
        return RefreshIndicator(
          onRefresh: () => ref.refresh(tasksProvider.future),

          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: tasks.length,

            itemBuilder: (context, index) {
              final task = tasks[index];

              return TaskItem(
                task: task,
                onToggle: () {
                  ref
                      .read(tasksProvider.notifier)
                      .toggleTaskCompletion(task.id);
                },
                onEdit: () => _navigateToEditTask(context, task),
                onDelete: () => _showDeleteDialog(context, task),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => ref.invalidate(tasksProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigation logic for editing
  void _navigateToEditTask(BuildContext context, Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditTaskPage(task: task)),
    );
  }

  /// UI Helper: Confirmation before deleting a task
  void _showDeleteDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(tasksProvider.notifier).deleteTask(task.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

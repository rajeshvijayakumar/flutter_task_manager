import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_task_manager/core/models/task.dart';
import 'package:flutter_task_manager/core/providers/task_provider.dart';
import 'package:flutter_task_manager/shared/widgets/custom_button.dart';
import 'package:flutter_task_manager/shared/widgets/custom_text_field.dart';
import 'package:uuid/uuid.dart';

/// AddTaskPage provides the interface for creating a new task.
/// It uses a [ConsumerStatefulWidget] to handle local form state (like text and dates).
class AddTaskPage extends ConsumerStatefulWidget {
  const AddTaskPage({super.key});

  @override
  ConsumerState<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends ConsumerState<AddTaskPage> {
  // Controllers to capture user input
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Local state for the selected date, defaulting to "Tomorrow"
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));

  // GlobalKey used to trigger validation on all form fields
  final _formKey = GlobalKey<FormState>();

  /// Displays the Flutter system Date Picker.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(), // Prevents picking dates in the past
      lastDate: DateTime(2100),
    );

    // Update the local state if the user actually picked a new date
    if (selectedDate != null && selectedDate != _dueDate) {
      setState(() {
        _dueDate = selectedDate;
      });
    }
  }

  @override
  void dispose() {
    // Always dispose controllers to prevent memory leaks
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Custom input for the Task Title
              CustomTextField(
                controller: _titleController,
                label: 'Task Title',
                prefixIcon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Custom input for the Description (Multiple lines allowed)
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                prefixIcon: Icons.description,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // A ListTile acts as a clean row to display and edit the date
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Due Date'),
                subtitle: Text(
                  '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _selectDate(context),
                ),
              ),
              const SizedBox(height: 40),

              // Action button to save the task
              CustomButton(
                      backgroundColor: Colors.blue,
                      onPressed: _addTask,
                       child: const Text('Add Task')),
            ],
          ),
        ),
      ),
    );
  }

  /// The logic to transform form data into a Task object and save it.
  void _addTask() async {
    // 1. Check if all validators return null (meaning inputs are valid)
    if (_formKey.currentState!.validate()) {
      // 2. Instantiate a new Task model
      final task = Task(
        // Generates a unique Version 4 UUID for this specific task
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _dueDate,
        createdAt: DateTime.now(), // Sets the creation timestamp to 'Now'
      );

      // 3. Send the new task to the TaskController (and eventually the Repository)
      await ref.read(tasksProvider.notifier).addTask(task);

      // 4. Navigation: Go back to the Task List page after successful save
      // We check 'mounted' to ensure the user hasn't closed the screen during the 'await'
      if (!mounted) return;

      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }
}

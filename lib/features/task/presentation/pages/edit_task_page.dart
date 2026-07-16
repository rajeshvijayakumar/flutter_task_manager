import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_task_manager/core/models/task.dart';
import 'package:flutter_task_manager/core/providers/task_provider.dart';
import 'package:flutter_task_manager/shared/widgets/custom_button.dart';
import 'package:flutter_task_manager/shared/widgets/custom_text_field.dart';

/// EditTaskPage allows users to modify an existing task.
/// It receives the specific task object to be edited as a parameter.
class EditTaskPage extends ConsumerStatefulWidget {
  final Task task;

  const EditTaskPage({super.key, required this.task});

  @override
  ConsumerState<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends ConsumerState<EditTaskPage> {
  // Use 'late' because these will be initialized in the initState method
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _dueDate;
  late bool _isCompleted;

  final _formKey = GlobalKey<FormState>();

  /// INITIALIZATION: This is a key teaching point.
  /// We take the data from 'widget.task' and use it to fill our form fields
  /// so the user doesn't have to re-type everything.
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(
      text: widget.task.description,
    );
    _dueDate = widget.task.dueDate;
    _isCompleted = widget.task.isCompleted;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Re-uses the DatePicker logic to allow the user to change the deadline.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(
        const Duration(days: 365),
      ), // Allows picking past dates for edits
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // DELETE ACTION: Placed in the AppBar for easy access
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _showDeleteDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _titleController,
                label: 'Task Title',
                prefixIcon: Icons.title,
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Enter a title' : null,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                prefixIcon: Icons.description,
                maxLines: 4,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Enter a description'
                    : null,
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              // CHECKBOX: Allows user to manually toggle completion status
              CheckboxListTile(
                title: const Text('Completed'),
                value: _isCompleted,
                onChanged: (value) {
                  setState(() {
                    _isCompleted = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      onPressed: _updateTask,
                      child: const Text('Update Task'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// [UPDATE LOGIC]: Replaces the old task with a new version.
  void _updateTask() async {
    if (_formKey.currentState!.validate()) {
      // We use copyWith to create a new task object with the updated values.
      // Notice we use widget.task to preserve the original ID and createdAt date.
      final updatedTask = widget.task.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _dueDate,
        isCompleted: _isCompleted,
      );

      // Update the provider (which then updates the Repository and Storage)
      await ref.read(tasksProvider.notifier).updateTask(updatedTask);

      if (!mounted) return;
      if (context.mounted) {
        Navigator.pop(context); // Go back to the task list
      }
    }
  }

  /// [DELETE LOGIC]: Asks for confirmation before removing data.
  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close dialog
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Trigger the delete operation in the provider
              ref.read(tasksProvider.notifier).deleteTask(widget.task.id);

              if (context.mounted) {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Go back to the main list
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}



import 'package:flutter/material.dart';
import 'package:flutter_task_manager/core/models/task.dart';

class TaskItem extends StatelessWidget {

  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  

   const TaskItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });


  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        // CHECKBOX: Toggles the 'isCompleted' status.
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) => onToggle(),
        ),

        // TITLE: Uses conditional styling to cross out text when finished.
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            decoration: task.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: task.isCompleted ? Colors.grey : null,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // DESCRIPTION: Uses 'ellipsis' to prevent text from overflowing the card.
            Text(
              task.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: task.isCompleted ? Colors.grey : null,
              ),
            ),
            const SizedBox(height: 4),

            // DATE DISPLAY: Changes to RED if the task is overdue and not finished.
            Text(
              'Due: ${task.formattedDueDate}',
              style: TextStyle(
                fontSize: 12,
                color:
                    task.dueDate.isBefore(DateTime.now()) && !task.isCompleted
                    ? Colors.red
                    : Colors.grey,
              ),
            ),
          ],
        ),

        // OPTIONS MENU: A clean way to hide 'Edit' and 'Delete' behind three dots.
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
          onSelected: (value) {
            // Trigger the appropriate callback based on selection
            if (value == 'edit') {
              onEdit();
            } else if (value == 'delete') {
              onDelete();
            }
          },
          icon: const Icon(Icons.more_vert),
        ),
      ),
    );
  }
}
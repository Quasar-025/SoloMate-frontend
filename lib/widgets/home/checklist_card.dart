import 'package:flutter/material.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';

class ChecklistCard extends StatefulWidget {
  const ChecklistCard({super.key});

  @override
  State<ChecklistCard> createState() => _ChecklistCardState();
}

class _ChecklistCardState extends State<ChecklistCard> {
  bool _isEditing = false;
  final TextEditingController _newTaskController = TextEditingController();
  
  List<Map<String, dynamic>> _tasks = [
    {'id': '1', 'text': 'Book accommodation in Goa Hotel', 'completed': true},
    {'id': '2', 'text': 'Download offline maps', 'completed': false},
    {'id': '3', 'text': 'Research local customs', 'completed': true},
    {'id': '4', 'text': 'Breakfast', 'completed': false},
  ];

  @override
  void dispose() {
    _newTaskController.dispose();
    super.dispose();
  }

  void _toggleTask(String taskId) {
    setState(() {
      final taskIndex = _tasks.indexWhere((task) => task['id'] == taskId);
      if (taskIndex != -1) {
        _tasks[taskIndex]['completed'] = !_tasks[taskIndex]['completed'];
      }
    });
  }

  void _addNewTask() {
    if (_newTaskController.text.trim().isNotEmpty) {
      setState(() {
        _tasks.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'text': _newTaskController.text.trim(),
          'completed': false,
        });
        _newTaskController.clear();
      });
    }
  }

  void _deleteTask(String taskId) {
    setState(() {
      _tasks.removeWhere((task) => task['id'] == taskId);
    });
  }

  void _editTask(String taskId, String newText) {
    setState(() {
      final taskIndex = _tasks.indexWhere((task) => task['id'] == taskId);
      if (taskIndex != -1) {
        _tasks[taskIndex]['text'] = newText;
      }
    });
  }

  void _showEditTaskDialog(Map<String, dynamic> task) {
    final TextEditingController editController = TextEditingController(text: task['text']);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(
              hintText: 'Enter task description',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (editController.text.trim().isNotEmpty) {
                  _editTask(task['id'], editController.text.trim());
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    editController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NeuContainer(
      color: const Color(0xFFDCFD00),
      borderColor: Colors.black,
      borderWidth: 3,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Checklist",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'gilroy',
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _isEditing = !_isEditing;
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isEditing ? Icons.done : Icons.edit,
                          size: 16,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isEditing ? 'Done' : 'Edit',
                          style: const TextStyle(
                            fontSize: 12, 
                            fontWeight: FontWeight.w300,
                            fontFamily: 'gilroy',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Tasks list
            ..._tasks.map((task) => _buildChecklistItem(task)).toList(),
            
            // Add new task section (only in edit mode)
            if (_isEditing) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newTaskController,
                        decoration: const InputDecoration(
                          hintText: 'Add new task...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'gilroy',
                        ),
                        onSubmitted: (_) => _addNewTask(),
                      ),
                    ),
                    IconButton(
                      onPressed: _addNewTask,
                      icon: const Icon(Icons.add, color: Colors.black),
                      iconSize: 20,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem(Map<String, dynamic> task) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _toggleTask(task['id']),
            child: Icon(
              task['completed'] ? Icons.check_circle : Icons.circle_outlined,
              color: task['completed'] ? Colors.black : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: _isEditing ? () => _showEditTaskDialog(task) : null,
              child: Text(
                task['text'],
                style: TextStyle(
                  fontSize: 14,
                  decoration: task['completed'] ? TextDecoration.lineThrough : null,
                  color: task['completed'] ? Colors.grey : Colors.black,
                  fontFamily: 'gilroy',
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
          if (_isEditing) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _showEditTaskDialog(task),
              child: const Icon(
                Icons.edit,
                size: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _deleteTask(task['id']),
              child: const Icon(
                Icons.delete,
                size: 16,
                color: Colors.red,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'todo_bloc.dart';
import 'task_storage.dart';

void main() {
  final storage = TaskStorageService();
  runApp(MyApp(storage: storage));
}

class MyApp extends StatelessWidget {
  final TaskStorageService storage;

  const MyApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do BLoC App',
      home: BlocProvider(
        create: (_) => TodoBloc(storage),
        child: const TodoPage(),
      ),
    );
  }
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController _controller = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedCategory;

  final List<String> _categories = [
    'Work',
    'Home',
    'Spiritual',
    'Fitness',
    'Learning',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('To-Do List ✅')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // TextField / Input
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter task',
                border: OutlineInputBorder(),
              ),
            ),

            // Pick Date Button
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
              child: Text(
                _selectedDate == null
                    ? 'Pick Due Date'
                    : 'Due: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
              ),
            ),

            // Categories
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: _selectedCategory,
              hint: const Text('Select Category'),
              isExpanded: true,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              items:
                  _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
            ),

            // Add Task button
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final title = _controller.text.trim();
                if (title.isNotEmpty) {
                  context.read<TodoBloc>().add(
                    AddTask(
                      title,
                      dueDate: _selectedDate,
                      category: _selectedCategory,
                    ),
                  );
                  _controller.clear();
                  setState(() {
                    _selectedDate = null;
                    _selectedCategory = null;
                  });
                }
              },
              child: const Text('Add Task'),
            ),

            const SizedBox(height: 20),
            Expanded(
              child: BlocBuilder<TodoBloc, List<Task>>(
                builder: (context, tasks) {
                  if (tasks.isEmpty) {
                    return const Center(child: Text('No tasks yet.'));
                  }

                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return ListTile(
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration:
                                task.isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (task.dueDate != null)
                              Text(
                                'Due: ${task.dueDate!.toLocal().toString().split(' ')[0]}',
                              ),
                            if (task.category != null)
                              Text('Category: ${task.category}'),
                          ],
                        ),

                        leading: Checkbox(
                          value: task.isDone,
                          onChanged: (_) {
                            context.read<TodoBloc>().add(ToggleTask(index));
                          },
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            context.read<TodoBloc>().add(RemoveTask(index));
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

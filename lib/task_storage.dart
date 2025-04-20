import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'todo_bloc.dart';

class TaskStorageService {
  static const _key = 'tasks';

  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final taskList = tasks.map((task) => task.toMap()).toList();
    prefs.setString(_key, jsonEncode(taskList));
  }

  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString != null) {
      final List decoded = jsonDecode(jsonString);
      return decoded.map((map) => Task.fromMap(map)).toList();
    }
    return [];
  }
}

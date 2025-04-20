import 'package:flutter_bloc/flutter_bloc.dart';
import 'task_storage.dart';

class Task {
  final String title;
  final bool isDone;
  final DateTime? dueDate;
  final String? category;

  Task({required this.title, this.isDone = false, this.dueDate, this.category});

  Task toggleDone() {
    return Task(
      title: title,
      isDone: !isDone,
      dueDate: dueDate,
      category: category,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isDone': isDone,
      'dueDate': dueDate?.toIso8601String(),
      'category': category,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      title: map['title'],
      isDone: map['isDone'],
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      category: map['category'],
    );
  }
}

/// Events
abstract class TodoEvent {}

class AddTask extends TodoEvent {
  final String title;
  final DateTime? dueDate;
  final String? category;

  AddTask(this.title, {this.dueDate, this.category});
}

class RemoveTask extends TodoEvent {
  final int index;
  RemoveTask(this.index);
}

class ToggleTask extends TodoEvent {
  final int index;
  ToggleTask(this.index);
}

/// BLoC
class TodoBloc extends Bloc<TodoEvent, List<Task>> {
  final TaskStorageService storage;

  TodoBloc(this.storage) : super([]) {
    on<AddTask>((event, emit) {
      final updated = List<Task>.from(state)..add(
        Task(
          title: event.title,
          dueDate: event.dueDate,
          category: event.category,
        ),
      );
      storage.saveTasks(updated);
      emit(updated);
    });

    on<RemoveTask>((event, emit) {
      final updated = List<Task>.from(state)..removeAt(event.index);
      storage.saveTasks(updated);
      emit(updated);
    });

    on<ToggleTask>((event, emit) {
      final updated = List<Task>.from(state);
      updated[event.index] = updated[event.index].toggleDone();
      storage.saveTasks(updated);
      emit(updated);
    });

    _loadInitialTasks();
  }

  void _loadInitialTasks() async {
    final loaded = await storage.loadTasks();
    emit(loaded);
  }
}

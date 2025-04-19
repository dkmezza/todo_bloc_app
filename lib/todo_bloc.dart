import 'package:flutter_bloc/flutter_bloc.dart';

class Task {
  final String title;
  final bool isDone;

  Task({required this.title, this.isDone = false});

  // Toggle done status
  Task toggleDone() {
    return Task(title: title, isDone: !isDone);
  }
}

/// Events
abstract class TodoEvent {}

class AddTask extends TodoEvent {
  final String title;
  AddTask(this.title);
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
  TodoBloc() : super([]) {
    on<AddTask>((event, emit) {
      final updated = List<Task>.from(state);
      updated.add(Task(title: event.title));
      emit(updated);
    });

    on<RemoveTask>((event, emit) {
      final updated = List<Task>.from(state);
      updated.removeAt(event.index);
      emit(updated);
    });

    on<ToggleTask>((event, emit) {
      final updated = List<Task>.from(state);
      final toggled = updated[event.index].toggleDone();
      updated[event.index] = toggled;
      emit(updated);
    });
  }
}

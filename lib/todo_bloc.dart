import 'package:flutter_bloc/flutter_bloc.dart';

/// Events
abstract class TodoEvent {}

class AddTodo extends TodoEvent {
  final String task;
  AddTodo(this.task);
}

class RemoveTodo extends TodoEvent {
  final int index;
  RemoveTodo(this.index);
}

/// BLoC
class TodoBloc extends Bloc<TodoEvent, List<String>> {
  TodoBloc() : super([]) {
    on<AddTodo>((event, emit) {
      final updatedList = List<String>.from(state);
      updatedList.add(event.task);
      emit(updatedList);
    });

    on<RemoveTodo>((event, emit) {
      final updatedList = List<String>.from(state);
      updatedList.removeAt(event.index);
      emit(updatedList);
    });
  }
}

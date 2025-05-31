import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';

import '../model/todo/todo.dart';

class TodoController extends GetxController {
  late Box<Todo> todoBox;
  final RxList<Todo> todos = <Todo>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initHive();
    loadTodos();
    _initNotifications();
  }

  void _initHive() {
    todoBox = Hive.box<Todo>('todos');
  }

  Future<void> _initNotifications() async {
    await AwesomeNotifications().initialize(
      null, // null means using default app icon
      [
        NotificationChannel(
          channelKey: 'todo_reminders',
          channelName: 'Task Reminders',
          channelDescription: 'Notifications for task reminders',
          importance: NotificationImportance.High,
          defaultColor: Colors.deepPurple,
          ledColor: Colors.deepPurple,
          playSound: true,
          soundSource: 'resource://raw/notification_sound',
          enableVibration: true,
        )
      ],
    );
  }

  void loadTodos() {
    todos.value = List.from(todoBox.values.toList().reversed);
  }

  List<Todo> getTasksByDate(DateTime date) {
    return todos.where((todo) => isSameDay(todo.dueDate, date)).toList();
  }

  void addTodo(String task, String description, DateTime dueDate,
      TimeOfDay dueTime, List<Subtask> subtasks) {
    final newTodo = Todo(
      id: const Uuid().v4(),
      task: task,
      description: description,
      dueDate: dueDate,
      dueTime:
          "${dueTime.hour.toString().padLeft(2, '0')}:${dueTime.minute.toString().padLeft(2, '0')}",
      subtasks: subtasks,
      isCompleted: false,
    );

    todoBox.put(newTodo.id, newTodo);
    todos.insert(0, newTodo);
    _scheduleAllNotifications(newTodo);
  }

  void updateTodo(String id, String newTask, String newDescription,
      DateTime newDueDate, TimeOfDay newDueTime, List<Subtask> subtasks) {
    final index = todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      final updatedTodo = todos[index].copyWith(
        task: newTask,
        description: newDescription,
        dueDate: newDueDate,
        dueTime:
            "${newDueTime.hour.toString().padLeft(2, '0')}:${newDueTime.minute.toString().padLeft(2, '0')}",
        subtasks: subtasks,
      );
      todoBox.put(updatedTodo.id, updatedTodo);
      todos[index] = updatedTodo;
      _scheduleAllNotifications(updatedTodo);
    }
  }

  void toggleTodoCompletion(String id) {
    final index = todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      final updatedTodo =
          todos[index].copyWith(isCompleted: !todos[index].isCompleted);
      todoBox.put(updatedTodo.id, updatedTodo);
      todos[index] = updatedTodo;
    }
  }

  void toggleSubtaskCompletion(String todoId, int subtaskIndex) {
    final index = todos.indexWhere((todo) => todo.id == todoId);
    if (index != -1) {
      List<Subtask> updatedSubtasks = List.from(todos[index].subtasks);
      updatedSubtasks[subtaskIndex] = updatedSubtasks[subtaskIndex].copyWith(
        isCompleted: !updatedSubtasks[subtaskIndex].isCompleted,
      );
      final updatedTodo = todos[index].copyWith(subtasks: updatedSubtasks);
      todoBox.put(updatedTodo.id, updatedTodo);
      todos[index] = updatedTodo;
    }
  }

  Future<void> cancelNotification(int notificationId) async {
    try {
      await AwesomeNotifications().cancel(notificationId);
    } catch (e) {
      print('Error canceling notification: $e');
    }
  }

  void deleteTodo(String id) {
    final index = todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      cancelNotification(id.hashCode); // Cancel main notification
      cancelNotification("${id}_3day".hashCode); // Cancel 3 days before
      cancelNotification("${id}_1day".hashCode); // Cancel 1 day before
      cancelNotification("${id}_5hour".hashCode); // Cancel 5 hours before
      cancelNotification("${id}_1hour".hashCode); // Cancel 1 hour before
      todoBox.delete(id);
      todos.removeAt(index);
      update();
    }
  }

  void addOrUpdateTodo(Todo todo) {
    int index = todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      todos[index] = todo;
      todoBox.put(todo.id, todo);
    } else {
      todos.insert(0, todo);
      todoBox.put(todo.id, todo);
    }
    _scheduleAllNotifications(todo);
    update();
  }

  void reorderTasks(int oldIndex, int newIndex) {
    final task = todos.removeAt(oldIndex);
    todos.insert(newIndex, task);
  }

  Future<void> _scheduleAllNotifications(Todo todo) async {
    if (todo.dueTime.isEmpty) return;

    final timeParts = todo.dueTime.split(':');
    if (timeParts.length != 2) return;

    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    final scheduledTime = DateTime(
      todo.dueDate.year,
      todo.dueDate.month,
      todo.dueDate.day,
      hour,
      minute,
    );

    if (scheduledTime.isBefore(DateTime.now())) {
      return;
    }

    await _scheduleNotification(
      id: todo.id.hashCode,
      title: 'Reminder: ${todo.task}',
      body: todo.description.isNotEmpty ? todo.description : 'Task due now',
      scheduledTime: scheduledTime,
    );

    // Schedule 3 days before reminder
    final threeDaysBefore = scheduledTime.subtract(const Duration(days: 3));
    if (threeDaysBefore.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: "${todo.id}_3day".hashCode,
        title: 'Reminder: ${todo.task} (Due in 3 days)',
        body: 'Get started! ${todo.task} is due in 3 days.',
        scheduledTime: threeDaysBefore,
      );
    }

    // Schedule 1 day before reminder
    final oneDayBefore = scheduledTime.subtract(const Duration(days: 1));
    if (oneDayBefore.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: "${todo.id}_1day".hashCode,
        title: 'Reminder: ${todo.task} (Due Tomorrow)',
        body: 'Just a reminder: ${todo.task} is due tomorrow!',
        scheduledTime: oneDayBefore,
      );
    }

    // Schedule 5 hours before reminder
    final fiveHoursBefore = scheduledTime.subtract(const Duration(hours: 5));
    if (fiveHoursBefore.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: "${todo.id}_5hour".hashCode,
        title: 'Reminder: ${todo.task} (Due in 5 hours)',
        body: 'Heads up! ${todo.task} is due in 5 hours.',
        scheduledTime: fiveHoursBefore,
      );
    }

    // Schedule 1 hour before reminder
    final oneHourBefore = scheduledTime.subtract(const Duration(hours: 1));
    if (oneHourBefore.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: "${todo.id}_1hour".hashCode,
        title: 'Reminder: ${todo.task} (Due in 1 hour)',
        body: 'Final push! ${todo.task} is due in 1 hour.',
        scheduledTime: oneHourBefore,
      );
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'todo_reminders',
          title: title,
          body: body,
        ),
        schedule: NotificationCalendar.fromDate(
          date: scheduledTime,
          allowWhileIdle: true,
        ),
      );
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }
}

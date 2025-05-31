import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../../controller/todo_controller.dart';
import '../../../model/todo/todo.dart';
import 'todo_editor_feature.dart';

class TodoFeature extends StatefulWidget {
  const TodoFeature({super.key});

  @override
  State<TodoFeature> createState() => _TodoFeatureState();
}

class _TodoFeatureState extends State<TodoFeature> {
  final TodoController todoController = Get.find<TodoController>();
  DateTime _selectedDay = DateTime.now();
  final ScrollController _scrollController = ScrollController();
  DateTime _focusedDay = DateTime.now();

  // Enhanced style constants
  final _calendarBoxDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.15),
        blurRadius: 15,
        offset: const Offset(0, 6),
      ),
    ],
  );

  final _headerTextStyle = const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: Colors.deepPurple,
  );

  final _taskCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar To-Do',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.deepPurple,
            )),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
      ),
      body: Column(
        children: [
          // Enhanced Calendar Container
          Container(
            margin: const EdgeInsets.all(20),
            decoration: _calendarBoxDecoration,
            child: Column(
              children: [
                // Month Header with Navigation - Enhanced
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.08),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left,
                            size: 28, color: Colors.deepPurple),
                        onPressed: _goToPreviousMonth,
                      ),
                      GestureDetector(
                        onTap: _showDatePicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            DateFormat('MMMM yyyy').format(_focusedDay),
                            style: _headerTextStyle,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right,
                            size: 28, color: Colors.deepPurple),
                        onPressed: _goToNextMonth,
                      ),
                    ],
                  ),
                ),

                // Enhanced Calendar with better day headers and date indicators
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TableCalendar(
                    focusedDay: _focusedDay,
                    firstDay: DateTime.utc(2000, 1, 1),
                    lastDay: DateTime.utc(2100, 12, 31),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        final isToday = isSameDay(day, DateTime.now());
                        final isSelected = isSameDay(day, _selectedDay);

                        return Container(
                          margin: const EdgeInsets.all(4),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? Colors.deepPurple.withOpacity(0.3)
                                : Colors.transparent,
                            border: isToday
                                ? Border.all(color: Colors.orange, width: 2.0)
                                : null,
                          ),
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors
                                      .white // Ensure selected day text is white
                                  : isToday
                                      ? Colors
                                          .black87 // Ensure today's text is visible
                                      : Colors.grey[800],
                              fontSize: 18,
                            ),
                          ),
                        );
                      },
                      selectedBuilder: (context, day, focusedDay) {
                        return Container(
                          margin: const EdgeInsets.all(4),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.deepPurple.withOpacity(
                                0.3), // Background for selected day
                          ),
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors
                                  .white, // Ensure selected day text is white
                              fontSize: 18,
                            ),
                          ),
                        );
                      },
                      todayBuilder: (context, day, focusedDay) {
                        return Container(
                          margin: const EdgeInsets.all(4),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.orange,
                                width: 2.0), // Border for today
                            color: Colors.orange.withOpacity(
                                0.1), // Optional background for today
                          ),
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors
                                  .black87, // Ensure today's text is visible
                              fontSize: 18,
                            ),
                          ),
                        );
                      },
                    ),
                    calendarStyle: CalendarStyle(
                      todayDecoration: const BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        ),
                      ),
                      markerSize: 6,
                      markerMargin: const EdgeInsets.only(bottom: 4),
                      cellPadding: const EdgeInsets.all(10),
                      defaultTextStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      weekendTextStyle: const TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                      ),
                      outsideDaysVisible: false,
                      outsideTextStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[700],
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                      weekendStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.red,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.withOpacity(0.1),
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                    headerVisible: false,
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    },
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    eventLoader: (day) {
                      return todoController.getTasksByDate(day).isNotEmpty
                          ? [true]
                          : [];
                    },
                  ),
                ),
              ],
            ),
          ),

          // Enhanced Selected Date Header
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 20, color: Colors.deepPurple),
                const SizedBox(width: 10),
                Text(
                  DateFormat('EEEE, MMMM d').format(_selectedDay),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.deepPurple,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${todoController.getTasksByDate(_selectedDay).length} tasks',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, indent: 24, endIndent: 24),

          // Tasks List
          Expanded(
            child: _buildTaskList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onPressed: () =>
            Get.to(() => TodoEditorFeature(selectedDate: _selectedDay)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildTaskList() {
    return Obx(() {
      final tasksForSelectedDate = todoController.getTasksByDate(_selectedDay);

      if (tasksForSelectedDate.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_note, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 20),
              Text(
                'No tasks for ${DateFormat('MMMM d').format(_selectedDay)}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tap + to add a new task',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: tasksForSelectedDate.length,
        itemBuilder: (context, index) {
          return _buildTaskTile(tasksForSelectedDate[index], index);
        },
      );
    });
  }

  Widget _buildTaskTile(Todo todo, int index) {
    return Dismissible(
      key: ValueKey(todo.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        child: const Icon(Icons.check, color: Colors.green, size: 28),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete, color: Colors.red, size: 28),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          todoController.toggleTodoCompletion(todo.id);
          return false;
        } else {
          return await _confirmDelete(todo.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: _taskCardDecoration,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          leading: Checkbox(
            value: todo.isCompleted,
            onChanged: (value) => todoController.toggleTodoCompletion(todo.id),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            side: BorderSide(
              color: Colors.grey[400]!,
              width: 1.5,
            ),
            activeColor: Colors.deepPurple,
          ),
          title: Text(
            todo.task,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
              color: todo.isCompleted ? Colors.grey : Colors.black87,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (todo.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    todo.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                      decoration:
                          todo.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              if (todo.dueTime.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        todo.dueTime,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          trailing: const Icon(Icons.drag_handle, color: Colors.grey, size: 24),
          onTap: () => Get.to(() => TodoEditorFeature(todo: todo)),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(String taskId) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Task?",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("This will permanently remove the task"),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              todoController.deleteTodo(taskId);
              Navigator.pop(context, true);
            },
            child: const Text("DELETE", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

void _goToPreviousMonth() {
  setState(() {
    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    _selectedDay = _focusedDay;
  });
}

void _goToNextMonth() {
  setState(() {
    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    _selectedDay = _focusedDay;
  });
}

bool isSameMonth(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month;
}

  Future<void> _showDatePicker() async {
  final picked = await showDatePicker(
    context: context,
    initialDate: _focusedDay,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Colors.deepPurple,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
          dialogBackgroundColor: Colors.white,
          // Add this to customize the year picker
            datePickerTheme: DatePickerThemeData(
              yearStyle: const TextStyle(
                  color: Colors.deepPurple), // Style for the year text
              dayStyle: const TextStyle(
                  color: Colors.black87), // Style for the day text
              headerForegroundColor: Colors.white,
              headerBackgroundColor: Colors.deepPurple,
              rangePickerBackgroundColor: Colors.grey[100],
              rangeSelectionBackgroundColor: Colors.deepPurple.withOpacity(0.3),
              todayForegroundColor: MaterialStateProperty.all(Colors.orange),
            ),
        ),
        child: child!,
      );
    },
  );
  
  if (picked != null && !isSameMonth(picked, _focusedDay)) {
    setState(() {
      _focusedDay = picked;
      _selectedDay = picked;

      
    });
  }
}
}

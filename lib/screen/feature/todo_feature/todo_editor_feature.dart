import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../controller/todo_controller.dart';
import '../../../model/todo/todo.dart';

class TodoEditorFeature extends StatefulWidget {
  final Todo? todo;
  final DateTime? selectedDate;

  const TodoEditorFeature({super.key, this.todo, this.selectedDate});

  @override
  State<TodoEditorFeature> createState() => _TodoEditorFeatureState();
}

class _TodoEditorFeatureState extends State<TodoEditorFeature> {
  final TodoController todoController = Get.find<TodoController>();
  final TextEditingController taskController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  List<Subtask> _subtasks = [];

  // Style constants
  final _inputDecoration = InputDecoration(
    labelStyle: const TextStyle(color: Colors.deepPurple),
    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.deepPurple),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.grey.shade400),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 12),
  );

  final _sectionTitleStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.deepPurple,
  );

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    if (widget.todo != null) {
      taskController.text = widget.todo!.task;
      descriptionController.text = widget.todo!.description ?? '';
      _dueDate = widget.todo!.dueDate;
      _dueTime = _parseTimeString(widget.todo!.dueTime);
      _subtasks = widget.todo!.subtasks;
    } else {
      _dueDate = widget.selectedDate;
      _dueTime = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.todo == null ? 'New Task' : 'Edit Task'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTaskNameField(),
            const SizedBox(height: 16),
            _buildTaskDescriptionField(),
            const SizedBox(height: 24),
            _buildDueDateSelector(),
            const SizedBox(height: 16),
            _buildDueTimeSelector(),
            const SizedBox(height: 24),
            const Text('Subtasks',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                )),
            const SizedBox(height: 8),
            _buildSubtaskList(),
            _buildAddSubtaskButton(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: _saveTask,
        child: const Icon(Icons.save, color: Colors.white),
      ),
    );
  }

  Widget _buildTaskNameField() {
    return TextField(
      controller: taskController,
      style: const TextStyle(fontSize: 18),
      decoration: _inputDecoration.copyWith(
        labelText: 'Task Name',
        hintText: 'Enter task name',
      ),
    );
  }

  Widget _buildTaskDescriptionField() {
    return TextField(
      controller: descriptionController,
      style: const TextStyle(fontSize: 16),
      decoration: _inputDecoration.copyWith(
        labelText: 'Description',
        hintText: 'Enter description (optional)',
      ),
      maxLines: null,
      keyboardType: TextInputType.multiline,
    );
  }

  Widget _buildDueDateSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(Icons.calendar_today, color: Colors.deepPurple),
        title:
            const Text("Due Date", style: TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          _dueDate?.toLocal().toString().split(' ')[0] ?? 'Not set',
          style: TextStyle(
            fontSize: 14,
            color: _dueDate == null ? Colors.grey : Colors.black,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: _pickDueDate,
      ),
    );
  }

  Widget _buildDueTimeSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(Icons.access_time, color: Colors.deepPurple),
        title:
            const Text("Due Time", style: TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          _dueTime?.format(context) ?? 'Not set',
          style: TextStyle(
            fontSize: 14,
            color: _dueTime == null ? Colors.grey : Colors.black,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: _pickDueTime,
      ),
    );
  }

  Widget _buildSubtaskList() {
    return Expanded(
      child: ReorderableListView(
        padding: const EdgeInsets.only(top: 8),
        onReorder: _handleReorderSubtasks,
        children: [
          for (int i = 0; i < _subtasks.length; i++) _buildSubtaskItem(i),
        ],
      ),
    );
  }

  Widget _buildSubtaskItem(int i) {
    return Card(
      key: ValueKey(_subtasks[i].title + i.toString()),
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Dismissible(
        key: ValueKey(_subtasks[i].title),
        background: Container(
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          child: const Icon(Icons.check, color: Colors.green),
        ),
        secondaryBackground: Container(
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.red),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            setState(() => _subtasks[i].isCompleted = !_subtasks[i].isCompleted);
            return false;
          } else {
            return await _confirmDeleteSubtask(i);
          }
        },
        child: ListTile(
          leading: Checkbox(
            value: _subtasks[i].isCompleted,
            onChanged: (value) => _handleSubtaskCompletionChange(value, i),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          title: TextField(
            controller: TextEditingController(text: _subtasks[i].title),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "Subtask description",
            ),
            onChanged: (value) => _handleSubtaskTitleChange(value, i),
          ),
          trailing: const Icon(Icons.drag_handle, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildAddSubtaskButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextButton.icon(
        icon: const Icon(Icons.add, color: Colors.deepPurple),
        label: const Text("Add Subtask", style: TextStyle(color: Colors.deepPurple)),
        onPressed: _handleAddSubtask,
      ),
    );
  }

  void _pickDueDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) setState(() => _dueDate = pickedDate);
  }

  void _pickDueTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null) setState(() => _dueTime = pickedTime);
  }

  TimeOfDay? _parseTimeString(String? time) {
    if (time == null || time.isEmpty) return null;
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<bool> _confirmDeleteSubtask(int index) async {
    return await Get.defaultDialog(
          title: "Delete Subtask?",
          middleText: "Are you sure you want to delete this subtask?",
          textConfirm: "Delete",
          textCancel: "Cancel",
          confirmTextColor: Colors.white,
          onConfirm: () {
            setState(() => _subtasks.removeAt(index));
            Get.back(result: true);
          },
          onCancel: () => Get.back(result: false),
        ) ??
        false;
  }

  void _saveTask() {
    if (taskController.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Task name cannot be empty",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final newTodo = Todo(
      id: widget.todo?.id ?? const Uuid().v4(),
      task: taskController.text,
      description: descriptionController.text,
      dueDate: _dueDate ?? DateTime.now(),
      dueTime: _dueTime != null
          ? "${_dueTime!.hour.toString().padLeft(2, '0')}:${_dueTime!.minute.toString().padLeft(2, '0')}"
          : "",
      subtasks: _subtasks.where((subtask) => subtask.title.isNotEmpty).toList(),
      isCompleted: widget.todo?.isCompleted ?? false,
    );

    final todoController = Get.find<TodoController>();

    if (widget.todo != null) {
      todoController.cancelNotification(widget.todo!.id.hashCode);
      todoController.cancelNotification("${widget.todo!.id}_1day".hashCode);
      todoController.cancelNotification("${widget.todo!.id}_5hour".hashCode);
    }

    todoController.addOrUpdateTodo(newTodo);
    Get.back();
  }

  void _handleReorderSubtasks(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final subtask = _subtasks.removeAt(oldIndex);
      _subtasks.insert(newIndex, subtask);
    });
  }

  void _handleSubtaskCompletionChange(bool? value, int i) {
    setState(() => _subtasks[i].isCompleted = value!);
  }

  void _handleSubtaskTitleChange(String value, int i) {
    _subtasks[i].title = value;
  }

  void _handleAddSubtask() {
    setState(() => _subtasks.add(Subtask(title: "", isCompleted: false)));
  }
}
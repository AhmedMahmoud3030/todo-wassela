import 'package:flutter/material.dart';
import 'package:todo/services/database_helper.dart';
import 'package:todo/models/task.dart';
void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waseela todo app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TaskListScreen(),
    );
  }
}
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}
class _TaskListScreenState extends State<TaskListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Task>> _completedTasks;
  late Future<List<Task>> _pendingTasks;
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _completedTasks = DatabaseHelper().getTasksByCompletionStatus(true);
    _pendingTasks = DatabaseHelper().getTasksByCompletionStatus(false);
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              text: 'Active',
            ),
            Tab(
              text: 'Completed',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskList(_pendingTasks),
          _buildTaskList(_completedTasks),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          TextEditingController titleController = TextEditingController();
          TextEditingController descriptionController = TextEditingController();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: CustomTextFormFiled(
                            controller: titleController,
                            validatorText: 'Please enter a title',
                            labelText: 'Title',
                            maxLength: 20,
                            maxLines: 1,
                            autoFocus: true,
                            keyboardType: TextInputAction.next,
                            onFieldSubmitted: null,
                          ),
                        ),
                        Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: CustomTextFormFiled(
                              controller: descriptionController,
                              validatorText: 'Please enter a description',
                              labelText: 'Desc',
                              maxLines: 3,
                              maxLength: 100,
                              autoFocus: false,
                              keyboardType: TextInputAction.done,
                              onFieldSubmitted: (value) {
                                if (_formKey.currentState!.validate()) {
                                  final newTask = Task(
                                    title: titleController.text,
                                    description: descriptionController.text,
                                  );
                                  DatabaseHelper().insertTask(newTask);
                                  setState(() {
                                    _completedTasks = DatabaseHelper()
                                        .getTasksByCompletionStatus(true);
                                    _pendingTasks = DatabaseHelper()
                                        .getTasksByCompletionStatus(false);
                                  });
                                  Navigator.of(context).pop();
                                }
                              },
                            ),),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .05,
                          width: MediaQuery.of(context).size.width * .7,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                final newTask = Task(
                                  title: titleController.text,
                                  description: descriptionController.text,
                                );
                                DatabaseHelper().insertTask(newTask);
                                setState(() {
                                  _completedTasks = DatabaseHelper()
                                      .getTasksByCompletionStatus(true);
                                  _pendingTasks = DatabaseHelper()
                                      .getTasksByCompletionStatus(false);
                                });
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text('Add Task'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  Widget _buildTaskList(Future<List<Task>> taskList) {
    return FutureBuilder<List<Task>>(
      future: taskList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No tasks found.'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final task = snapshot.data![index];
              return ListTile(
                title: Text(task.title),
                subtitle: Text(task.description),
                trailing: _tabController.index == 0
                    ? Checkbox(
                        value: task.isCompleted,
                        onChanged: (value) {
                          setState(() {
                            task.isCompleted = value!;
                            DatabaseHelper().updateTask(task);
                            _completedTasks = DatabaseHelper()
                                .getTasksByCompletionStatus(true);
                            _pendingTasks = DatabaseHelper()
                                .getTasksByCompletionStatus(false);
                          });
                        },
                      )
                    : null,
                onLongPress: _tabController.index == 0
                    ? () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Delete Task'),
                              content: const Text(
                                'Are you sure you want to delete this task?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    DatabaseHelper().deleteTask(task.id!);
                                    setState(() {
                                      _completedTasks = DatabaseHelper()
                                          .getTasksByCompletionStatus(true);
                                      _pendingTasks = DatabaseHelper()
                                          .getTasksByCompletionStatus(false);
                                    });
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    : null,
              );
            },
          );
        }
      },
    );
  }
}
class CustomTextFormFiled extends StatelessWidget {
  const CustomTextFormFiled({
    super.key,
    required this.controller,
    required this.validatorText,
    required this.labelText,
    required this.maxLines,
    required this.maxLength,
    required this.autoFocus,
    required this.keyboardType,
    required this.onFieldSubmitted,
  });
  final TextEditingController controller;
  final String validatorText;
  final String labelText;
  final int maxLines;
  final int maxLength;
  final bool autoFocus;
  final TextInputAction keyboardType;
  final void Function(String?)? onFieldSubmitted;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onFieldSubmitted: onFieldSubmitted,
      validator: (value) {
        if (value!.isEmpty) {
          return validatorText;
        }
        return null;
      },
      textInputAction: keyboardType,
      decoration: InputDecoration(
        label: Text(labelText),
        labelStyle: TextStyle(
          color: Theme.of(context).primaryColor,
        ),
        floatingLabelStyle: const TextStyle(color: Colors.grey, fontSize: 16),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
          ),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
      maxLines: maxLines,
      maxLength: maxLength,
      autofocus: autoFocus,
      controller: controller,
    );
  }
}

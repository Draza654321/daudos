import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/task_viewmodel.dart';
import '../models/task.dart';
import '../widgets/task_card.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/task_filters.dart';

class TasksView extends StatefulWidget {
  @override
  _TasksViewState createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Tasks'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.auto_awesome),
                onPressed: () {
                  viewModel.generateAutoTasks();
                },
                tooltip: 'Generate Auto Tasks',
              ),
              IconButton(
                icon: Icon(Icons.filter_list),
                onPressed: () {
                  _showFilters(context, viewModel);
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'Today', icon: Icon(Icons.today)),
                Tab(text: 'Pending', icon: Icon(Icons.pending_actions)),
                Tab(text: 'Completed', icon: Icon(Icons.check_circle)),
                Tab(text: 'All', icon: Icon(Icons.list)),
              ],
            ),
          ),
          body: viewModel.isLoading
              ? Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Today's Tasks
                    _buildTaskList(
                      viewModel.todaysTasks,
                      'No tasks for today',
                      'Add a task or generate auto tasks to get started',
                      viewModel,
                    ),
                    
                    // Pending Tasks
                    _buildTaskList(
                      viewModel.pendingTasks,
                      'No pending tasks',
                      'Great! You\'re all caught up',
                      viewModel,
                    ),
                    
                    // Completed Tasks
                    _buildTaskList(
                      viewModel.completedTasks,
                      'No completed tasks',
                      'Complete some tasks to see them here',
                      viewModel,
                    ),
                    
                    // All Tasks
                    _buildTaskList(
                      viewModel.tasks,
                      'No tasks yet',
                      'Create your first task to get started',
                      viewModel,
                    ),
                  ],
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _showAddTaskDialog(context, viewModel);
            },
            child: Icon(Icons.add),
            tooltip: 'Add Task',
          ),
        );
      },
    );
  }

  Widget _buildTaskList(
    List<Task> tasks,
    String emptyTitle,
    String emptySubtitle,
    TaskViewModel viewModel,
  ) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              emptyTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              emptySubtitle,
              style: TextStyle(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskCard(
            task: task,
            onTap: () => _showTaskDetails(context, task, viewModel),
            onComplete: () => viewModel.completeTask(task.id),
            onEdit: () => _showEditTaskDialog(context, task, viewModel),
            onDelete: () => _showDeleteConfirmation(context, task, viewModel),
          );
        },
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, TaskViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(
        onTaskCreated: (title, description, priority, category, dueDate, estimatedMinutes) {
          viewModel.createTask(
            title: title,
            description: description,
            priority: priority,
            category: category,
            dueDate: dueDate,
            estimatedMinutes: estimatedMinutes,
          );
        },
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, Task task, TaskViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(
        task: task,
        onTaskCreated: (title, description, priority, category, dueDate, estimatedMinutes) {
          final updatedTask = task.copyWith(
            title: title,
            description: description,
            priority: priority,
            category: category,
            dueDate: dueDate,
            estimatedMinutes: estimatedMinutes,
          );
          viewModel.updateTask(updatedTask);
        },
      ),
    );
  }

  void _showTaskDetails(BuildContext context, Task task, TaskViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Task Title
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Task Details
                _buildDetailRow('Category', viewModel.getTaskCategoryIcon(task.category) + ' ' + task.category.toString().split('.').last),
                _buildDetailRow('Priority', task.priority.toString().split('.').last),
                _buildDetailRow('Status', task.status.toString().split('.').last),
                if (task.dueDate != null)
                  _buildDetailRow('Due Date', '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}'),
                if (task.estimatedMinutes != null)
                  _buildDetailRow('Estimated Time', '${task.estimatedMinutes} minutes'),
                
                SizedBox(height: 20),
                
                // Description
                if (task.description != null && task.description!.isNotEmpty) ...[
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    task.description!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(height: 20),
                ],
                
                // Actions
                Row(
                  children: [
                    if (task.status != TaskStatus.completed) ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            viewModel.completeTask(task.id);
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.check),
                          label: Text('Complete'),
                        ),
                      ),
                      SizedBox(width: 12),
                    ],
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditTaskDialog(context, task, viewModel);
                        },
                        icon: Icon(Icons.edit),
                        label: Text('Edit'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Task task, TaskViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              viewModel.deleteTask(task.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showFilters(BuildContext context, TaskViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => TaskFilters(viewModel: viewModel),
    );
  }
}


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_repository.dart';
import '../services/user_repository.dart';

class TaskViewModel extends ChangeNotifier {
  final TaskRepository _taskRepository = TaskRepository();
  final UserRepository _userRepository = UserRepository();

  List<Task> _allTasks = [];
  bool _isLoading = false;
  TaskCategory _selectedCategory = TaskCategory.work;

  // Filter and sort properties
  TaskPriority? _selectedPriorityFilter;
  TaskCategory? _selectedCategoryFilter;
  TaskStatus? _selectedStatusFilter;
  String _sortBy = 'dueDate';
  bool _sortAscending = true;

  // Getters
  List<Task> get tasks => _getFilteredAndSortedTasks();
  List<Task> get todaysTasks => _getTodaysTasks();
  List<Task> get pendingTasks => _getPendingTasks();
  List<Task> get completedTasks => _getCompletedTasks();
  bool get isLoading => _isLoading;
  TaskCategory get selectedCategory => _selectedCategory;

  // Filter getters
  TaskPriority? get selectedPriorityFilter => _selectedPriorityFilter;
  TaskCategory? get selectedCategoryFilter => _selectedCategoryFilter;
  TaskStatus? get selectedStatusFilter => _selectedStatusFilter;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;

  // Computed properties
  int get totalTasksCount => _allTasks.length;
  int get completedTasksCount => _getCompletedTasks().length;
  int get pendingTasksCount => _getPendingTasks().length;
  double get completionRate => totalTasksCount > 0 ? completedTasksCount / totalTasksCount : 0.0;

  // Initialize task data
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _userRepository.getCurrentUser();
      if (user != null) {
        await _loadTasks(user.id);
      }
    } catch (e) {
      print('Error initializing task data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load all tasks
  Future<void> _loadTasks(String userId) async {
    _allTasks = await _taskRepository.getTasksForUser(userId);
  }

  // Get filtered and sorted tasks
  List<Task> _getFilteredAndSortedTasks() {
    List<Task> filtered = List.from(_allTasks);

    // Apply filters
    if (_selectedPriorityFilter != null) {
      filtered = filtered.where((task) => task.priority == _selectedPriorityFilter).toList();
    }
    if (_selectedCategoryFilter != null) {
      filtered = filtered.where((task) => task.category == _selectedCategoryFilter).toList();
    }
    if (_selectedStatusFilter != null) {
      filtered = filtered.where((task) => task.status == _selectedStatusFilter).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      int comparison = 0;
      
      switch (_sortBy) {
        case 'dueDate':
          if (a.dueDate == null && b.dueDate == null) {
            comparison = 0;
          } else if (a.dueDate == null) {
            comparison = 1;
          } else if (b.dueDate == null) {
            comparison = -1;
          } else {
            comparison = a.dueDate!.compareTo(b.dueDate!);
          }
          break;
        case 'priority':
          comparison = a.priority.index.compareTo(b.priority.index);
          break;
        case 'createdAt':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case 'title':
          comparison = a.title.compareTo(b.title);
          break;
      }
      
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  // Get today's tasks
  List<Task> _getTodaysTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));
    
    return _allTasks.where((task) {
      if (task.dueDate == null) return false;
      final taskDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
      return taskDate == today;
    }).toList();
  }

  // Get pending tasks
  List<Task> _getPendingTasks() {
    return _allTasks.where((task) => 
      task.status == TaskStatus.pending || task.status == TaskStatus.inProgress
    ).toList();
  }

  // Get completed tasks
  List<Task> _getCompletedTasks() {
    return _allTasks.where((task) => task.status == TaskStatus.completed).toList();
  }

  // Filter methods
  void setPriorityFilter(TaskPriority? priority) {
    _selectedPriorityFilter = priority;
    notifyListeners();
  }

  void setCategoryFilter(TaskCategory? category) {
    _selectedCategoryFilter = category;
    notifyListeners();
  }

  void setStatusFilter(TaskStatus? status) {
    _selectedStatusFilter = status;
    notifyListeners();
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }

  void toggleSortOrder() {
    _sortAscending = !_sortAscending;
    notifyListeners();
  }

  void clearFilters() {
    _selectedPriorityFilter = null;
    _selectedCategoryFilter = null;
    _selectedStatusFilter = null;
    _sortBy = 'dueDate';
    _sortAscending = true;
    notifyListeners();
  }

  // Create new task
  Future<void> createTask({
    required String title,
    String? description,
    required TaskPriority priority,
    required TaskCategory category,
    DateTime? dueDate,
    int? estimatedMinutes,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _userRepository.getCurrentUser();
      if (user == null) return;

      final now = DateTime.now();
      final newTask = Task(
        id: 'task_${user.id}_${now.millisecondsSinceEpoch}',
        userId: user.id,
        title: title,
        description: description,
        priority: priority,
        category: category,
        status: TaskStatus.pending,
        isAutoGenerated: false,
        dueDate: dueDate,
        estimatedMinutes: estimatedMinutes,
        createdAt: now,
        updatedAt: now,
      );

      await _taskRepository.createTask(newTask);
      await _loadTasks(user.id);
    } catch (e) {
      print('Error creating task: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update task
  Future<void> updateTask(Task task) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedTask = task.copyWith(updatedAt: DateTime.now());
      await _taskRepository.updateTask(updatedTask);
      
      final user = await _userRepository.getCurrentUser();
      if (user != null) {
        await _loadTasks(user.id);
      }
    } catch (e) {
      print('Error updating task: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Complete task
  Future<void> completeTask(String taskId, {int? actualMinutes}) async {
    try {
      await _taskRepository.completeTask(taskId, actualMinutes: actualMinutes);
      
      final user = await _userRepository.getCurrentUser();
      if (user != null) {
        await _loadTasks(user.id);
      }
    } catch (e) {
      print('Error completing task: $e');
    }
    notifyListeners();
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _taskRepository.deleteTask(taskId);
      
      final user = await _userRepository.getCurrentUser();
      if (user != null) {
        await _loadTasks(user.id);
      }
    } catch (e) {
      print('Error deleting task: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter tasks by category
  void setSelectedCategory(TaskCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Get tasks by selected category
  List<Task> getTasksBySelectedCategory() {
    return _allTasks.where((task) => task.category == _selectedCategory).toList();
  }

  // Get tasks by priority
  List<Task> getTasksByPriority(TaskPriority priority) {
    return _allTasks.where((task) => task.priority == priority).toList();
  }

  // Get overdue tasks
  List<Task> getOverdueTasks() {
    final now = DateTime.now();
    return _allTasks.where((task) => 
      task.dueDate != null && 
      task.dueDate!.isBefore(now) && 
      task.status != TaskStatus.completed
    ).toList();
  }

  // Search tasks
  List<Task> searchTasks(String query) {
    if (query.isEmpty) return _allTasks;
    
    final lowercaseQuery = query.toLowerCase();
    return _allTasks.where((task) =>
      task.title.toLowerCase().contains(lowercaseQuery) ||
      (task.description?.toLowerCase().contains(lowercaseQuery) ?? false)
    ).toList();
  }

  // Get task priority color
  Color getTaskPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Color(0xFFEF4444); // Red
      case TaskPriority.medium:
        return Color(0xFFF59E0B); // Orange
      case TaskPriority.low:
        return Color(0xFF10B981); // Green
    }
  }

  // Get task category icon
  String getTaskCategoryIcon(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return '💼';
      case TaskCategory.personal:
        return '👤';
      case TaskCategory.health:
        return '🏥';
      case TaskCategory.learning:
        return '📚';
      case TaskCategory.finance:
        return '💰';
      case TaskCategory.social:
        return '👥';
      case TaskCategory.creative:
        return '🎨';
      case TaskCategory.maintenance:
        return '🔧';
    }
  }

  // Get task status color
  Color getTaskStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Color(0xFF6B7280); // Gray
      case TaskStatus.inProgress:
        return Color(0xFF3B82F6); // Blue
      case TaskStatus.completed:
        return Color(0xFF10B981); // Green
    }
  }

  // Generate auto tasks based on time and mood
  Future<void> generateAutoTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _userRepository.getCurrentUser();
      if (user == null) return;

      final now = DateTime.now();
      final hour = now.hour;
      
      List<Task> autoTasks = [];

      // Time-based task generation for Daud's U.S. dispatch hours (6 PM - 6 AM PKT)
      if (hour >= 18 || hour < 6) {
        // Night shift tasks
        autoTasks.addAll([
          Task(
            id: 'auto_task_${now.millisecondsSinceEpoch}_1',
            userId: user.id,
            title: 'Review dispatch performance',
            description: 'Analyze today\'s dispatch metrics and identify improvements',
            priority: TaskPriority.high,
            category: TaskCategory.work,
            status: TaskStatus.pending,
            isAutoGenerated: true,
            estimatedMinutes: 30,
            createdAt: now,
            updatedAt: now,
          ),
          Task(
            id: 'auto_task_${now.millisecondsSinceEpoch}_2',
            userId: user.id,
            title: 'Deep work session',
            description: 'Focus on priority business development',
            priority: TaskPriority.high,
            category: TaskCategory.work,
            status: TaskStatus.pending,
            isAutoGenerated: true,
            estimatedMinutes: 90,
            createdAt: now,
            updatedAt: now,
          ),
          Task(
            id: 'auto_task_${now.millisecondsSinceEpoch}_3',
            userId: user.id,
            title: 'Mind gym session',
            description: 'Complete breathing exercise and brain dump',
            priority: TaskPriority.medium,
            category: TaskCategory.health,
            status: TaskStatus.pending,
            isAutoGenerated: true,
            estimatedMinutes: 20,
            createdAt: now,
            updatedAt: now,
          ),
        ]);
      } else {
        // Day tasks (rest period)
        autoTasks.addAll([
          Task(
            id: 'auto_task_${now.millisecondsSinceEpoch}_4',
            userId: user.id,
            title: 'Plan evening work session',
            description: 'Set priorities and goals for tonight\'s dispatch work',
            priority: TaskPriority.medium,
            category: TaskCategory.personal,
            status: TaskStatus.pending,
            isAutoGenerated: true,
            estimatedMinutes: 15,
            createdAt: now,
            updatedAt: now,
          ),
          Task(
            id: 'auto_task_${now.millisecondsSinceEpoch}_5',
            userId: user.id,
            title: 'Learning sprint',
            description: 'Study new business or tech skills',
            priority: TaskPriority.medium,
            category: TaskCategory.learning,
            status: TaskStatus.pending,
            isAutoGenerated: true,
            estimatedMinutes: 45,
            createdAt: now,
            updatedAt: now,
          ),
        ]);
      }

      // Create auto tasks
      for (final task in autoTasks) {
        await _taskRepository.createTask(task);
      }

      await _loadTasks(user.id);
    } catch (e) {
      print('Error generating auto tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh task data
  Future<void> refresh() async {
    await initialize();
  }
}


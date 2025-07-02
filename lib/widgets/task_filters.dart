import 'package:flutter/material.dart';
import '../viewmodels/task_viewmodel.dart';
import '../models/task.dart';

class TaskFilters extends StatefulWidget {
  final TaskViewModel viewModel;

  const TaskFilters({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  @override
  _TaskFiltersState createState() => _TaskFiltersState();
}

class _TaskFiltersState extends State<TaskFilters> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters & Sort',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  widget.viewModel.clearFilters();
                  Navigator.pop(context);
                },
                child: Text('Clear All'),
              ),
            ],
          ),
          
          SizedBox(height: 20),
          
          // Priority Filter
          Text(
            'Priority',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip(
                'All',
                widget.viewModel.selectedPriorityFilter == null,
                () => widget.viewModel.setPriorityFilter(null),
              ),
              ...TaskPriority.values.map((priority) {
                return _buildFilterChip(
                  _getPriorityName(priority),
                  widget.viewModel.selectedPriorityFilter == priority,
                  () => widget.viewModel.setPriorityFilter(priority),
                  color: _getPriorityColor(priority),
                );
              }).toList(),
            ],
          ),
          
          SizedBox(height: 20),
          
          // Category Filter
          Text(
            'Category',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip(
                'All',
                widget.viewModel.selectedCategoryFilter == null,
                () => widget.viewModel.setCategoryFilter(null),
              ),
              ...TaskCategory.values.map((category) {
                return _buildFilterChip(
                  '${_getCategoryIcon(category)} ${_getCategoryName(category)}',
                  widget.viewModel.selectedCategoryFilter == category,
                  () => widget.viewModel.setCategoryFilter(category),
                );
              }).toList(),
            ],
          ),
          
          SizedBox(height: 20),
          
          // Status Filter
          Text(
            'Status',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip(
                'All',
                widget.viewModel.selectedStatusFilter == null,
                () => widget.viewModel.setStatusFilter(null),
              ),
              ...TaskStatus.values.map((status) {
                return _buildFilterChip(
                  _getStatusName(status),
                  widget.viewModel.selectedStatusFilter == status,
                  () => widget.viewModel.setStatusFilter(status),
                  color: _getStatusColor(status),
                );
              }).toList(),
            ],
          ),
          
          SizedBox(height: 20),
          
          // Sort Options
          Text(
            'Sort By',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Column(
            children: [
              _buildSortOption('Due Date', 'dueDate'),
              _buildSortOption('Priority', 'priority'),
              _buildSortOption('Created Date', 'createdAt'),
              _buildSortOption('Title', 'title'),
            ],
          ),
          
          SizedBox(height: 20),
          
          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap, {
    Color? color,
  }) {
    final chipColor = color ?? Theme.of(context).colorScheme.primary;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : chipColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: chipColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : chipColor,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, String value) {
    final isSelected = widget.viewModel.sortBy == value;
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      leading: Radio<String>(
        value: value,
        groupValue: widget.viewModel.sortBy,
        onChanged: (value) {
          widget.viewModel.setSortBy(value!);
          setState(() {});
        },
      ),
      trailing: isSelected
          ? IconButton(
              icon: Icon(
                widget.viewModel.sortAscending
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
              ),
              onPressed: () {
                widget.viewModel.toggleSortOrder();
                setState(() {});
              },
            )
          : null,
      onTap: () {
        widget.viewModel.setSortBy(value);
        setState(() {});
      },
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  String _getPriorityName(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.orange;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusName(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _getCategoryIcon(TaskCategory category) {
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

  String _getCategoryName(TaskCategory category) {
    return category.toString().split('.').last.replaceFirst(
      category.toString().split('.').last[0],
      category.toString().split('.').last[0].toUpperCase(),
    );
  }
}


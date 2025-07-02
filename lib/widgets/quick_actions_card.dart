import 'package:flutter/material.dart';

class QuickActionsCard extends StatelessWidget {
  final VoidCallback onMindGymTap;
  final VoidCallback onTasksTap;
  final VoidCallback onGoalsTap;
  final VoidCallback onAnalyticsTap;

  const QuickActionsCard({
    Key? key,
    required this.onMindGymTap,
    required this.onTasksTap,
    required this.onGoalsTap,
    required this.onAnalyticsTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flash_on,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Actions Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildActionButton(
                  context,
                  'Mind Gym',
                  'Start a session',
                  Icons.psychology,
                  Colors.purple,
                  onMindGymTap,
                ),
                _buildActionButton(
                  context,
                  'Add Task',
                  'Create new task',
                  Icons.add_task,
                  Colors.blue,
                  onTasksTap,
                ),
                _buildActionButton(
                  context,
                  'Goals',
                  'Track progress',
                  Icons.flag,
                  Colors.green,
                  onGoalsTap,
                ),
                _buildActionButton(
                  context,
                  'Analytics',
                  'View insights',
                  Icons.insights,
                  Colors.orange,
                  onAnalyticsTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


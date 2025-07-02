import 'package:flutter/material.dart';
import '../services/ai_recommendation_service.dart';
import '../models/task.dart';

class SmartSuggestionsCard extends StatefulWidget {
  @override
  _SmartSuggestionsCardState createState() => _SmartSuggestionsCardState();
}

class _SmartSuggestionsCardState extends State<SmartSuggestionsCard> {
  final AIRecommendationService _aiService = AIRecommendationService();
  bool _isLoading = true;
  List<Task> _suggestedTasks = [];
  BurnoutAssessment? _burnoutAssessment;
  int _suggestedFocusDuration = 25;
  TaskDifficulty _suggestedDifficulty = TaskDifficulty.medium;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final suggestions = await Future.wait([
        _aiService.suggestTasks(),
        _aiService.assessBurnout(),
        _aiService.suggestFocusSessionDuration(),
        _aiService.suggestTaskDifficulty(),
      ]);

      setState(() {
        _suggestedTasks = suggestions[0] as List<Task>;
        _burnoutAssessment = suggestions[1] as BurnoutAssessment;
        _suggestedFocusDuration = suggestions[2] as int;
        _suggestedDifficulty = suggestions[3] as TaskDifficulty;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade50,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.psychology,
                      color: Colors.purple,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Smart Suggestions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade700,
                          ),
                        ),
                        Text(
                          'AI-powered recommendations for you',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: _loadSuggestions,
                    color: Colors.purple,
                  ),
                ],
              ),
              
              SizedBox(height: 20),
              
              if (_isLoading)
                Center(
                  child: CircularProgressIndicator(
                    color: Colors.purple,
                  ),
                )
              else ...[
                // Burnout assessment
                if (_burnoutAssessment != null && _burnoutAssessment!.riskLevel != BurnoutRisk.low)
                  _buildBurnoutAlert(),
                
                SizedBox(height: 16),
                
                // Focus recommendation
                _buildFocusRecommendation(),
                
                SizedBox(height: 16),
                
                // Task difficulty recommendation
                _buildDifficultyRecommendation(),
                
                SizedBox(height: 16),
                
                // Suggested tasks
                if (_suggestedTasks.isNotEmpty)
                  _buildTaskSuggestions(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBurnoutAlert() {
    if (_burnoutAssessment == null) return Container();
    
    final assessment = _burnoutAssessment!;
    Color alertColor;
    IconData alertIcon;
    String alertTitle;

    switch (assessment.riskLevel) {
      case BurnoutRisk.high:
        alertColor = Colors.red;
        alertIcon = Icons.warning;
        alertTitle = 'High Burnout Risk Detected';
        break;
      case BurnoutRisk.medium:
        alertColor = Colors.orange;
        alertIcon = Icons.info;
        alertTitle = 'Moderate Stress Levels';
        break;
      case BurnoutRisk.low:
        alertColor = Colors.green;
        alertIcon = Icons.check_circle;
        alertTitle = 'Good Mental Health';
        break;
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alertColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: alertColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                alertIcon,
                color: alertColor,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                alertTitle,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: alertColor.shade700,
                ),
              ),
            ],
          ),
          if (assessment.recommendations.isNotEmpty) ...[
            SizedBox(height: 8),
            ...assessment.recommendations.take(2).map((rec) => Padding(
              padding: EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: alertColor)),
                  Expanded(
                    child: Text(
                      rec,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildFocusRecommendation() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timer,
            color: Colors.blue,
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Optimal Focus Session',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                Text(
                  '$_suggestedFocusDuration minutes - Based on your recent focus patterns',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_suggestedFocusDuration}m',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyRecommendation() {
    Color difficultyColor;
    String difficultyText;
    IconData difficultyIcon;

    switch (_suggestedDifficulty) {
      case TaskDifficulty.high:
        difficultyColor = Colors.red;
        difficultyText = 'High Challenge';
        difficultyIcon = Icons.trending_up;
        break;
      case TaskDifficulty.medium:
        difficultyColor = Colors.orange;
        difficultyText = 'Moderate Challenge';
        difficultyIcon = Icons.trending_flat;
        break;
      case TaskDifficulty.low:
        difficultyColor = Colors.green;
        difficultyText = 'Easy Tasks';
        difficultyIcon = Icons.trending_down;
        break;
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: difficultyColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: difficultyColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            difficultyIcon,
            color: difficultyColor,
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended Difficulty',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: difficultyColor.shade700,
                  ),
                ),
                Text(
                  '$difficultyText - Based on your energy and recent performance',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: difficultyColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              difficultyText.split(' ')[0],
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suggested Tasks',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.purple.shade700,
          ),
        ),
        SizedBox(height: 12),
        ...(_suggestedTasks.take(3).map((task) => Container(
          margin: EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: _getPriorityColor(task.priority),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text(
                        task.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                children: [
                  Icon(
                    _getCategoryIcon(task.category),
                    color: Colors.grey[500],
                    size: 16,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${task.estimatedMinutes}m',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        )).toList()),
      ],
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

  IconData _getCategoryIcon(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return Icons.work;
      case TaskCategory.personal:
        return Icons.person;
      case TaskCategory.health:
        return Icons.health_and_safety;
      case TaskCategory.learning:
        return Icons.school;
      case TaskCategory.finance:
        return Icons.attach_money;
      case TaskCategory.social:
        return Icons.people;
      case TaskCategory.creative:
        return Icons.palette;
      case TaskCategory.maintenance:
        return Icons.build;
    }
  }
}


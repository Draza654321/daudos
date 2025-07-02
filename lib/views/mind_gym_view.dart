import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/mind_gym_viewmodel.dart';
import '../models/mind_gym.dart';
import '../widgets/breathing_exercise.dart';
import '../widgets/brain_dump_widget.dart';
import '../widgets/focus_timer.dart';

class MindGymView extends StatefulWidget {
  @override
  _MindGymViewState createState() => _MindGymViewState();
}

class _MindGymViewState extends State<MindGymView> with TickerProviderStateMixin {
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
    return Consumer<MindGymViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Mind Gym'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(icon: Icon(Icons.air), text: 'Breathe'),
                Tab(icon: Icon(Icons.psychology), text: 'Brain Dump'),
                Tab(icon: Icon(Icons.timer), text: 'Focus'),
                Tab(icon: Icon(Icons.insights), text: 'Stats'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Breathing Exercise Tab
              BreathingExercise(),
              
              // Brain Dump Tab
              BrainDumpWidget(),
              
              // Focus Timer Tab
              FocusTimer(),
              
              // Stats Tab
              _buildStatsTab(viewModel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsTab(MindGymViewModel viewModel) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mind Gym Statistics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          
          // Stats cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Sessions',
                  '12',
                  Icons.psychology,
                  Colors.purple,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Minutes',
                  '180',
                  Icons.timer,
                  Colors.blue,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Streak',
                  '5 days',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Focus Score',
                  '85%',
                  Icons.target,
                  Colors.green,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 30),
          
          Text(
            'Recent Activities',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: 16),
          
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return _buildActivityItem(
                  'Breathing Exercise',
                  '5 minutes ago',
                  Icons.air,
                  Colors.blue,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


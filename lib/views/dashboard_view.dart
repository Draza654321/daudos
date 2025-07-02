import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../viewmodels/mood_viewmodel.dart';
import '../widgets/mood_selector.dart';
import '../widgets/win_meter.dart';
import '../widgets/motivational_quote_card.dart';
import '../widgets/daily_stats_card.dart';
import '../widgets/quick_actions_card.dart';
import '../widgets/smart_suggestions_card.dart';
import 'analytics_view.dart';

class DashboardView extends StatefulWidget {
  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<DashboardViewModel, MoodViewModel>(
        builder: (context, dashboardViewModel, moodViewModel, child) {
          if (dashboardViewModel.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await dashboardViewModel.refresh();
              await moodViewModel.refresh();
            },
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: CustomScrollView(
                    slivers: [
                      // App Bar
                      SliverAppBar(
                        expandedHeight: 120,
                        floating: false,
                        pinned: true,
                        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                        elevation: 0,
                        flexibleSpace: FlexibleSpaceBar(
                          title: Text(
                            dashboardViewModel.greetingMessage,
                            style: TextStyle(
                              color: dashboardViewModel.getGreetingColor(),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          titlePadding: EdgeInsets.only(left: 16, bottom: 16),
                        ),
                        actions: [
                          IconButton(
                            icon: Icon(Icons.analytics_outlined),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AnalyticsView(),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.notifications_outlined),
                            onPressed: () {
                              // TODO: Show notifications
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.account_circle_outlined),
                            onPressed: () {
                              // TODO: Show profile
                            },
                          ),
                        ],
                      ),

                      // Content
                      SliverPadding(
                        padding: EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // Motivational Quote
                            MotivationalQuoteCard(
                              quote: dashboardViewModel.motivationalQuote,
                              onRefresh: () => dashboardViewModel.refresh(),
                            ),
                            
                            SizedBox(height: 16),
                            
                            // Mood Check-in
                            if (!moodViewModel.hasCheckedInToday)
                              _buildMoodCheckInCard(context, moodViewModel, dashboardViewModel)
                            else
                              _buildMoodDisplayCard(context, moodViewModel),
                            
                            SizedBox(height: 16),
                            
                            // Win Meter
                            WinMeter(
                              progress: dashboardViewModel.winMeterProgress,
                              color: dashboardViewModel.getWinMeterColor(),
                              title: 'Today\'s Win Meter',
                              subtitle: '${(dashboardViewModel.winMeterProgress * 100).toInt()}% Complete',
                            ),
                            
                            SizedBox(height: 16),
                            
                            // Daily Stats
                            DailyStatsCard(
                              tasksCompleted: dashboardViewModel.completedTasksCount,
                              totalTasks: dashboardViewModel.totalTasksCount,
                              habitsCompleted: dashboardViewModel.completedHabitsCount,
                              totalHabits: dashboardViewModel.totalHabitsCount,
                              moodScore: dashboardViewModel.averageMoodScore,
                            ),
                            
                            SizedBox(height: 16),
                            
                            // Quick Actions
                            QuickActionsCard(
                              onMindGymTap: () {
                                // TODO: Navigate to Mind Gym
                              },
                              onTasksTap: () {
                                // TODO: Navigate to Tasks
                              },
                              onGoalsTap: () {
                                // TODO: Navigate to Goals
                              },
                              onAnalyticsTap: () {
                                // TODO: Show analytics
                              },
                            ),
                            
                            SizedBox(height: 16),
                            
                            // Smart Suggestions
                            SmartSuggestionsCard(),
                            
                            SizedBox(height: 100), // Bottom padding for navigation
                          ]),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMoodCheckInCard(BuildContext context, MoodViewModel moodViewModel, DashboardViewModel dashboardViewModel) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.mood,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'How are you feeling?',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Check in with your mood to get personalized insights and suggestions.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            MoodSelector(
              onMoodSelected: (clarity, focus, energy, notes) async {
                await moodViewModel.checkInMood(
                  clarity: clarity,
                  focus: focus,
                  energy: energy,
                  notes: notes,
                );
                if (moodViewModel.currentMood != null) {
                  await dashboardViewModel.updateMood(moodViewModel.currentMood!);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodDisplayCard(BuildContext context, MoodViewModel moodViewModel) {
    final mood = moodViewModel.currentMood!;
    final avgScore = mood.averageScore;
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      moodViewModel.getMoodEmoji(avgScore),
                      style: TextStyle(fontSize: 24),
                    ),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today\'s Mood',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          moodViewModel.getMoodDescription(avgScore),
                          style: TextStyle(
                            color: moodViewModel.getMoodColor(avgScore),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Show mood update dialog
                  },
                  child: Text('Update'),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                _buildMoodIndicator('Clarity', mood.clarity, Colors.blue),
                SizedBox(width: 16),
                _buildMoodIndicator('Focus', mood.focus, Colors.green),
                SizedBox(width: 16),
                _buildMoodIndicator('Energy', mood.energy, Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodIndicator(String label, int value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4),
          LinearProgressIndicator(
            value: value / 5.0,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          SizedBox(height: 2),
          Text(
            '$value/5',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}


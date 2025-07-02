import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';
import 'dashboard_view.dart';
import 'mind_gym_view.dart';
import 'tasks_view.dart';
import 'goals_habits_view.dart';
import 'settings_view.dart';

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    DashboardView(),
    MindGymView(),
    TasksView(),
    GoalsHabitsView(),
    SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, settingsViewModel, child) {
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Theme.of(context).cardTheme.color,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              selectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 11,
              ),
              items: [
                BottomNavigationBarItem(
                  icon: _buildNavIcon(Icons.dashboard_rounded, 0),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIcon(Icons.psychology_rounded, 1),
                  label: 'Mind Gym',
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIcon(Icons.task_alt_rounded, 2),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIcon(Icons.track_changes_rounded, 3),
                  label: 'Goals',
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIcon(Icons.settings_rounded, 4),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    final isSelected = _currentIndex == index;
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      padding: EdgeInsets.all(isSelected ? 8 : 4),
      decoration: BoxDecoration(
        color: isSelected 
          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
          : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: isSelected ? 28 : 24,
      ),
    );
  }
}


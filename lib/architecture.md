# DaudOS App Architecture

## Architecture Pattern: MVVM (Model-View-ViewModel)

### Overview
DaudOS follows the MVVM architectural pattern with Provider for state management, ensuring clean separation of concerns and testability.

### Directory Structure
```
lib/
├── models/           # Data models and entities
├── services/         # Business logic and data services
├── viewmodels/       # ViewModels for state management
├── views/           # UI screens and pages
├── widgets/         # Reusable UI components
├── utils/           # Utility functions and helpers
└── main.dart        # App entry point
```

### Core Components

#### 1. Models (Data Layer)
- **User**: User profile and preferences
- **Mood**: Daily mood and energy tracking
- **Task**: Task management with categories and priorities
- **Habit**: Habit tracking with power/struggle types
- **Goal**: Long-term goals with milestones
- **MindGym**: Mind gym sessions and brain dump entries
- **Settings**: App configuration and preferences
- **Analytics**: Daily and weekly analytics data

#### 2. Services (Business Logic Layer)
- **DatabaseService**: Local SQLite database operations
- **FirebaseService**: Cloud sync and backup
- **AnalyticsService**: Data analysis and reporting
- **NotificationService**: Local notifications
- **TTSService**: Text-to-speech functionality
- **MotivationService**: Motivation engine logic
- **TaskGenerationService**: AI-based task generation

#### 3. ViewModels (Presentation Logic Layer)
- **DashboardViewModel**: Dashboard state and logic
- **MindGymViewModel**: Mind gym session management
- **TaskViewModel**: Task CRUD operations
- **HabitViewModel**: Habit tracking logic
- **GoalViewModel**: Goal management
- **SettingsViewModel**: App settings management
- **AnalyticsViewModel**: Analytics data processing

#### 4. Views (UI Layer)
- **DashboardView**: Main dashboard screen
- **MindGymView**: Mind gym activities
- **TaskView**: Task management interface
- **HabitView**: Habit tracking interface
- **GoalView**: Goal management interface
- **SettingsView**: App settings

#### 5. Widgets (Reusable Components)
- **MoodSelector**: Mood rating widget
- **WinMeter**: Progress visualization
- **BreathingGuide**: Breathing exercise animation
- **StreakCounter**: Streak visualization
- **ProgressChart**: Analytics charts

### State Management
- **Provider**: Primary state management solution
- **ChangeNotifier**: For ViewModels
- **Consumer/Selector**: For UI updates

### Data Flow
1. **View** triggers user actions
2. **ViewModel** processes business logic
3. **Service** handles data operations
4. **Model** represents data structure
5. **View** updates based on ViewModel state

### Offline-First Strategy
1. **Local Database**: SQLite for primary data storage
2. **Sync Queue**: Queue operations for later sync
3. **Conflict Resolution**: Last-write-wins strategy
4. **Background Sync**: Periodic Firebase sync when online

### Key Features Implementation

#### Motivation Engine
- Mood-aware UI adjustments
- TTS motivational prompts
- Achievement system
- Streak tracking

#### Smart Task Generation
- Time-of-day awareness
- Mood-based difficulty adjustment
- Category balancing
- Workload optimization

#### Analytics System
- Real-time data collection
- Weekly/monthly reports
- Trend analysis
- Performance insights

### Security
- Optional PIN/biometric lock
- Encrypted local storage
- Secure Firebase authentication
- Data privacy compliance

### Performance
- Lazy loading for large datasets
- Efficient database queries
- Image caching
- Background processing for heavy operations


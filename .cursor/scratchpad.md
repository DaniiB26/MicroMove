## Background and Motivation
MicroMove is an iOS app that promotes "exercise snacking" - the concept of incorporating short, frequent movements into daily routines. The app aims to make fitness more accessible by breaking down exercise into manageable micro-workouts that can be done anywhere, anytime. This approach helps users build sustainable healthy habits without the pressure of long workout sessions.

## Key Challenges and Analysis
1. **Background Activity Management**
   - iOS background execution limitations
   - Battery efficiency considerations
   - User privacy and data handling

2. **Data Persistence**
   - Offline-first architecture
   - SwiftData implementation
   - Data synchronization and conflict resolution

3. **User Experience**
   - Minimalist, distraction-free interface
   - Intuitive exercise guidance
   - Responsive and performant UI

4. **Notification System**
   - Smart timing algorithms
   - User preference management
   - Do Not Disturb integration

## High-Level Task Breakdown

### Phase 1: Foundation and Data Layer
- [X] Task 1: Project Setup and Basic Architecture
  - ✅ Success Criteria
    - Xcode project created with SwiftUI    - done
    - Basic folder structure established    - done
    - SwiftData models defined              - done
  - 🎯 Learning Goal
    - Understanding iOS app architecture
    - SwiftUI project structure
    - SwiftData basics
  - 📘 Educator Notes
    - MVVM architecture overview
    - SwiftData vs CoreData comparison
    - SwiftUI app lifecycle

- [X] Task 2: Exercise Data Model and Storage
  - ✅ Success Criteria
    - Exercise model with all required fields
    - SwiftData persistence layer
    - CRUD operations implemented
  - 🎯 Learning Goal
    - SwiftData model design
    - Data persistence patterns
    - Type-safe data handling
  - 📘 Educator Notes
    - SwiftData schema design
    - Data modeling best practices
    - CRUD operations in SwiftData

### Phase 2: Core Features
- [X] Task 3: Exercise Library Implementation
  - ✅ Success Criteria
    - Exercise list view with categories
    - Filter functionality
    - Exercise detail view
  - 🎯 Learning Goal
    - SwiftUI list and navigation
    - Data filtering and sorting
    - View composition
  - 📘 Educator Notes
    - SwiftUI List and ForEach
    - Navigation patterns
    - View modifiers and styling

- [X] Task 4: Activity Detection System
  - ✅ Success Criteria
    - Background activity monitoring
    - Customizable reminder rules
    - Time-based triggers
  - 🎯 Learning Goal
    - iOS background processing
    - Notification scheduling
    - State management
  - 📘 Educator Notes
    - Background tasks in iOS
    - UserNotifications framework
    - State management patterns

### Phase 3: Progress Tracking
- [ ] Task 5: Progress Tracking Implementation
  - ✅ Success Criteria
    - Daily movement logging
    - Visual history display
    - Streak calculation
  - 🎯 Learning Goal
    - Data aggregation
    - Chart implementation
    - Date handling
  - 📘 Educator Notes
    - Swift Charts
    - Date calculations
    - Data visualization

- [ ] Task 6: Achievement System
  - ✅ Success Criteria
    - Achievement definitions
    - Progress tracking
    - Achievement notifications
  - 🎯 Learning Goal
    - Event handling
    - State observation
    - User feedback
  - 📘 Educator Notes
    - Observer pattern
    - User feedback patterns
    - Achievement design

### Phase 4: Polish and Testing
- [ ] Task 7: UI Polish and Animations
  - ✅ Success Criteria
    - Smooth transitions
    - Loading states
    - Error handling
  - 🎯 Learning Goal
    - SwiftUI animations
    - Error handling patterns
    - Loading state management
  - 📘 Educator Notes
    - Animation APIs
    - Error handling best practices
    - Loading state patterns

- [ ] Task 8: Testing and Optimization
  - ✅ Success Criteria
    - Unit tests for core logic
    - UI tests for critical flows
    - Performance optimization
  - 🎯 Learning Goal
    - Testing strategies
    - Performance profiling
    - Debug techniques
  - 📘 Educator Notes
    - XCTest framework
    - Performance testing
    - Debug tools

## Project Status Board
- [X] Task 1: Project Setup and Basic Architecture
- [X] Task 2: Exercise Data Model and Storage
- [X] Task 3: Exercise Library Implementation
- [X] Task 4: Activity Detection System
- [ ] Task 5: Progress Tracking Implementation
- [ ] Task 6: Achievement System
- [ ] Task 7: UI Polish and Animations
- [ ] Task 8: Testing and Optimization

- [x] Fix Activity Log not updating in real time
- [x] Implement timer functionality for exercises

## Executor's Feedback or Assistance Requests
> Task 1 completed.
> - Created a new Xcode project using SwiftUI template.
> - Established a clear folder structure: Models, Views, ViewModels, Services, Utils, and Assets.xcassets.
> - Added initial SwiftData models: Exercise, ActivityLog, Progress, Achievement, UserPreferences, WorkoutSession, and supporting enums in ExerciseTypes.swift.
> - Ensured all models use Codable enums and default values for SwiftData compatibility.
> - Verified the app builds and runs, and the models compile without errors.
> - No blockers encountered during setup.

> Task 2 completed.
> - Implemented the Exercise model with all required fields and enums conforming to Codable.
> - Set up SwiftData persistence for Exercise.
> - Implemented CRUD operations in ExercisesViewModel (add, fetch, update, delete).
> - Verified by adding, updating, and deleting exercises in the app; all operations work as expected.
> - No blockers encountered.

> Task 3 completed.
> - Implemented ExerciseListView with filtering by type and sorting by duration (ascending/descending).
> - Added ExerciseDetailView and ExerciseRowView for clear navigation and display.
> - Used ExercisesViewModel to manage state, filtering, and sorting logic.
> - Verified that exercises can be filtered and sorted, and details are shown correctly.
> - Added accessibility improvements and documentation comments.
> - No blockers encountered.

> Fixed two issues:
> 1. ActivityLogViewModel.addActivityLog now saves the modelContext after inserting a log, ensuring persistence.
> 2. ActivityListView now calls viewModel.fetchActivityLogs() in .onAppear, so the list refreshes when the view appears (like AchievementListView).
> 
> This should make new activity logs appear immediately after being triggered, without needing to restart the app.

> Implemented complete timer functionality:
> 1. ExerciseDetailView now uses @State showTimer and navigationDestination to navigate to TimerView
> 2. TimerView shows countdown timer with MM:SS format, exercise info, and cancel button
> 3. When timer completes, it logs the exercise completion and navigates back automatically
> 4. Timer properly cleans up on view disappear to prevent memory leaks
> 5. Added proper initialization to convert exercise duration from minutes to seconds

> Task 4 completed.
> - Integrated ActivityMonitor into ContentView using @StateObject for ActivityLogViewModel and UserPreferencesViewModel.
> - ActivityMonitor is initialized onAppear, requests notification permission, and checks/schedules reminders.
> - Added a "Test Reminder" button in the toolbar menu to manually trigger ActivityMonitor's checkAndScheduleReminder for testing.
> - All ViewModels are now shared across the app for consistent state.
> - Manual test: Run the app, open the menu, and tap "Test Reminder". You should receive a local notification if outside quiet hours and the inactivity interval is met.
> - If you do not receive a notification, check iOS notification permissions and quiet hour settings in preferences.
> - No blockers encountered.

> Task 4 completed.
> - Implemented complete Activity Detection System with smart notification scheduling.
> - ActivityMonitor handles quiet hours (including midnight spanning), inactivity detection, and user preferences.
> - Notifications start from reminder time or immediately if past reminder time, then repeat every interval.
> - After exercise activity, notification cycle resets from that activity point.
> - Added AppDelegate for foreground notification display and proper permission handling.
> - All core requirements met: background monitoring, customizable rules, time-based triggers.
> - Ready to proceed to Task 5: Progress Tracking Implementation.

## Lessons
> - Setting up a clear folder structure early helps keep the project organized and maintainable.
> - SwiftData models require enums to conform to Codable and use raw value types for persistence.
> - Using MVVM architecture from the start makes it easier to scale and test the app.
> - Documenting each model and property improves clarity for future development.
> - Initializing models with sensible default values reduces boilerplate and errors.
> - Combining filtering and sorting logic in the ViewModel keeps the UI code clean and maintainable.
> - Accessibility and documentation are important for usability and future development.

## Background and Motivation
> The Activity Detection System is a core feature that enables MicroMove to gently nudge users to move when they've been inactive, making the app proactive and supportive. By leveraging ActivityLog and UserPreferences, the app can track user activity, respect their preferences (like quiet hours), and deliver smart, timely reminders. This helps users build sustainable movement habits without being intrusive.

## Key Challenges and Analysis
1. **iOS Background Execution**
   - iOS restricts background tasks for battery and privacy reasons.
   - Need to use allowed APIs (e.g., background fetch, notifications) and work within system limits.
2. **User Privacy and Control**
   - All activity tracking must be transparent and user-controlled.
   - UserPreferences must allow opt-in/out, quiet hours, and custom reminder intervals.
3. **Data Logging and Analysis**
   - ActivityLog must accurately record relevant events (app opens, reminders, exercise completions, etc.).
   - Data must be aggregated for streaks, reminders, and analytics.
4. **Notification Scheduling**
   - Reminders should only fire when appropriate (not during quiet hours, not too frequently).
   - Must handle edge cases (e.g., user disables notifications, changes preferences).

## High-Level Task Breakdown
- [X] Task 4.1: Define Activity Types and Logging Events
  - ✅ Success Criteria: All relevant user and app events are clearly defined and logged to ActivityLog.
  - 🎯 Learning Goal: Understand event modeling and logging in SwiftData.
  - 📘 Educator Notes: Examples of event enums, best practices for logging, and a micro-exercise to log a custom event.

- [X] Task 4.2: Implement User Preferences for Reminders and Quiet Hours
  - ✅ Success Criteria: User can set reminder interval, enable/disable reminders, and configure quiet hours in the UI.
  - 🎯 Learning Goal: Learn about user settings, state persistence, and UI binding.
  - 📘 Educator Notes: How to use @Published and SwiftData for settings, and a sample UI for preferences.

- [X] Task 4.3: Background Activity Monitoring and Trigger Logic
  - ✅ Success Criteria: App detects inactivity (using ActivityLog) and schedules reminders according to user preferences.
  - 🎯 Learning Goal: Explore background processing, notification scheduling, and logic for inactivity detection.
  - 📘 Educator Notes: iOS background task patterns, UserNotifications, and a code snippet for scheduling a local notification.

- [X] Task 4.4: Notification Delivery and User Feedback
  - ✅ Success Criteria: Reminders are delivered only when appropriate, and user actions are logged in ActivityLog.
  - 🎯 Learning Goal: Understand notification delivery, user interaction logging, and feedback loops.
  - 📘 Educator Notes: Handling notification permissions, logging user responses, and a micro-exercise to simulate a reminder event.

## Project Status Board
- [X] Task 1: Project Setup and Basic Architecture
- [X] Task 2: Exercise Data Model and Storage
- [X] Task 3: Exercise Library Implementation
- [X] Task 4: Activity Detection System
- [ ] Task 5: Progress Tracking Implementation
- [ ] Task 6: Achievement System
- [ ] Task 7: UI Polish and Animations
- [ ] Task 8: Testing and Optimization

## Executor's Feedback or Assistance Requests
> Task 4 completed.
> - Integrated ActivityMonitor into ContentView using @StateObject for ActivityLogViewModel and UserPreferencesViewModel.
> - ActivityMonitor is initialized onAppear, requests notification permission, and checks/schedules reminders.
> - Added a "Test Reminder" button in the toolbar menu to manually trigger ActivityMonitor's checkAndScheduleReminder for testing.
> - All ViewModels are now shared across the app for consistent state.
> - Manual test: Run the app, open the menu, and tap "Test Reminder". You should receive a local notification if outside quiet hours and the inactivity interval is met.
> - If you do not receive a notification, check iOS notification permissions and quiet hour settings in preferences.
> - No blockers encountered.

> Task 4 completed.
> - Implemented complete Activity Detection System with smart notification scheduling.
> - ActivityMonitor handles quiet hours (including midnight spanning), inactivity detection, and user preferences.
> - Notifications start from reminder time or immediately if past reminder time, then repeat every interval.
> - After exercise activity, notification cycle resets from that activity point.
> - Added AppDelegate for foreground notification display and proper permission handling.
> - All core requirements met: background monitoring, customizable rules, time-based triggers.
> - Ready to proceed to Task 5: Progress Tracking Implementation.

## Lessons
> - Planning for background activity and user preferences is essential for a respectful, effective reminder system.
> - Clear event modeling in ActivityLog enables powerful analytics and smarter reminders.

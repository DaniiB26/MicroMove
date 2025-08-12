## Background and Motivation
MicroMove is an iOS app that promotes "exercise snacking" - the concept of incorporating short, frequent movements into daily routines. The app aims to make fitness more accessible by breaking down exercise into manageable micro-workouts that can be done anywhere, anytime. This approach helps users build sustainable healthy habits without the pressure of long workout sessions.
MicroMove encourages users to incorporate short bursts of exercise into their daily lives. By adding user personalization (profiles, goals), intelligent scheduling (routines and triggers), adaptive feedback, and richer analytics, the app becomes a more effective habit-forming tool while maintaining its offline, privacy-first philosophy.

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

## Key Challenges and Analysis
1. **Personalization**
   - Designing a local user profile system that influences recommendations
   - Mapping profile attributes (e.g., fitness level) to suggestion logic

2. **Routine & Trigger System**
   - Managing multiple trigger types in one routine
   - Handling background execution limits for different triggers (e.g., inactivity, device state)

3. **Adaptive Feedback**
   - Creating a rating system that meaningfully influences future suggestions
   - Balancing between user control and automation

4. **Data & Privacy**
   - Storing all data locally with SwiftData
   - Explicit permission requests for HealthKit/motion data

5. **Analytics & Motivation**
   - Designing visual summaries that encourage long-term engagement
   - Implementing habit formation tracking without excessive complexity


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
- [X] Task 5: Progress Tracking Implementation
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

- [X] Task 6: Achievement System
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
- [ ] Task 7: Testing and Optimization
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

- [ ] Task 8: UI Polish and Animations
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


### Phase 5: Personalization
- [ ] **Task 9: User Profile System**
  - ✅ Success Criteria:
    - User can set/edit name, fitness level, and fitness goals
    - Profile data persists locally
    - Profile influences exercise suggestions and reminders
  - 🎯 Learning Goal:
    - Local data persistence patterns
    - Binding data to UI for live updates
  - 📘 Educator Notes:
    - SwiftData entity relationships
    - Using `@AppStorage` vs SwiftData for user settings
    - MVVM binding with SwiftUI forms

### Phase 6: Routine Builder
- [ ] **Task 10: Exercise Inventory & Routine Creation**
  - ✅ Success Criteria:
    - User can select exercises to add to a personal routine
    - Multiple trigger types can be assigned
    - Routines can be activated/deactivated/deleted
  - 🎯 Learning Goal:
    - Complex model design (Routine with multiple triggers)
    - Building multi-step forms in SwiftUI
  - 📘 Educator Notes:
    - One-to-many and many-to-many relationships in SwiftData
    - SwiftUI navigation flows for creation wizards

- [ ] **Task 11: Trigger Engine Implementation**
  - ✅ Success Criteria:
    - Supports recurring time-based, inactivity, HealthKit, device state, and home automation triggers
    - Executes routines based on trigger events
  - 🎯 Learning Goal:
    - Background processing strategies
    - Integration with HealthKit and motion APIs
  - 📘 Educator Notes:
    - `UNUserNotificationCenter` for scheduled triggers
    - HealthKit integration basics
    - Handling background task expiration

### Phase 7: Social & Motivation
- [ ] **Task 12: Achievements Sharing**
  - ✅ Success Criteria:
    - Achievements can be shared via iOS share sheet
    - Share includes title, badge, and context
  - 🎯 Learning Goal:
    - Share sheet integration
    - Dynamic image/text composition
  - 📘 Educator Notes:
    - `UIActivityViewController` usage
    - Rendering SwiftUI views as images

### Phase 8: Adaptive Feedback
- [ ] **Task 13: Exercise Rating & Adaptation**
  - ✅ Success Criteria:
    - User can rate completed exercises
    - Weekly check-in prompts to adjust goals
    - Suggestion algorithm adapts to ratings
  - 🎯 Learning Goal:
    - Collecting and storing feedback data
    - Building adaptive recommendation logic
  - 📘 Educator Notes:
    - Decision-making algorithms
    - Using SwiftData fetch requests with predicates for filtering suggestions

### Phase 9: Advanced Analytics
- [ ] **Task 14: Progress & Habit Formation Tracking**
  - ✅ Success Criteria:
    - Daily/weekly summaries with visual history
    - Habit streak calculations (e.g., 3x/week for 4 weeks)
    - Motivational feedback based on progress
  - 🎯 Learning Goal:
    - Advanced date handling and grouping
    - Data visualization patterns in SwiftUI
  - 📘 Educator Notes:
    - Swift Charts advanced customization
    - DateComponents and Calendar math



## Project Status Board
- [X] Task 1: Project Setup and Basic Architecture
- [X] Task 2: Exercise Data Model and Storage
- [X] Task 3: Exercise Library Implementation
- [X] Task 4: Activity Detection System
- [X] Task 5: Progress Tracking Implementation
- [X] Task 6: Achievement System
- [ ] Task 7: Testing and Optimization
- [ ] Task 8: UI Polish and Animations
- [ ] Task 9: User Profile System
- [ ] Task 10: Exercise Inventory & Routine Creation
- [ ] Task 11: Trigger Engine Implementation
- [ ] Task 12: Achievements Sharing
- [ ] Task 13: Exercise Rating & Adaptation
- [ ] Task 14: Progress & Habit Formation Tracking

---

### 🛠️ Executor's Feedback & Assistance Requests
> **Task 1:**
> - Project created, folder structure set, models added, app builds. No blockers.
>
> **Task 2:**
> - Exercise model, persistence, CRUD all work. No blockers.
>
> **Task 3:**
> - ExerciseListView with filtering/sorting, detail views, accessibility, docs. No blockers.
>
> **Fixes:**
> - ActivityLogViewModel now saves after insert; ActivityListView refreshes onAppear. Logs update in real time.
>
> - Timer: ExerciseDetailView launches TimerView, logs completion, cleans up, and converts duration. Works as expected.
>
> **Task 4:**
> - ActivityMonitor integrated, requests notification permission, schedules reminders, "Test Reminder" button added. ViewModels shared. Manual test: notifications work if outside quiet hours and interval met. No blockers.
> - Complete Activity Detection: Handles quiet hours (including midnight), inactivity, user prefs. Notifications repeat, reset after activity. AppDelegate for foreground banners. All requirements met.
>
> **Task 5:**
> - ProgressViewModel refactored to use WorkoutSession only. Daily/weekly/monthly stats, streaks, active days. ProgressView shows stats, streaks, calendar, and session details. Manual/automated tests pass. No blockers. Ready for Task 6.
>
> **Task 6:**
> - Achievement system implemented: definitions, progress tracking, and notifications. Achievements are unlocked based on streaks, total exercises, and total minutes. ProgressViewModel observes workout data and updates achievements. Banner notification appears when an achievement is unlocked. Manual and automated tests confirm correct unlocking and UI feedback. No blockers. Ready for UI polish.

---

### 💡 Lessons Learned
- Early folder structure = maintainable codebase
- SwiftData enums: Codable, raw values for persistence
- MVVM from start = scalable, testable
- Documenting models/properties aids future dev
- Sensible model defaults reduce errors
- Filtering/sorting in ViewModel keeps UI clean
- Accessibility & docs matter
- **Activity Detection:** Plan for background/quiet hours, model events clearly for analytics
- **Progress Tracking:**
  - Aggregating from WorkoutSession (one per day) simplifies logic, future-proofs
  - Calendar/date math is key for streaks/stats
  - Removing old Progress model reduced complexity
  - UI feedback (animations, cards) boosts engagement
  - Simulated data/testing catches edge cases
  - Documenting logic helps onboarding
- **Achievement System:**
  - Used observer pattern to react to progress changes and unlock achievements in real time
  - Banner feedback for unlocked achievements increases user motivation
  - Grouping/sorting achievements in UI improves clarity
  - Manual and automated tests caught edge cases (e.g., unlocking multiple achievements at once)
  - Documenting achievement logic helps future expansion

---
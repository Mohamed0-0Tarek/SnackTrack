# SnackTrack — Team Study Guide

Each member must know their own files **in depth** and understand how they connect to other members' work.

---

# 1. Juwairia — Authentication & Onboarding

## Files She Must Know (In Study Order)

### 1.1 `lib/models/user_model.dart` (119 lines)
**What it is**: The data model for a user profile.

**Key concepts**:
- Fields: `id`, `name`, `email`, `avatarUrl`, `token`, `activeStreak`, `entries`, `bio`, `age`, `weight`, `height`, `objective`
- Hive annotations (`@HiveType(typeId: 0)`, `@HiveField`) — enables local caching via StorageService
- `fromJson()` / `toJson()` — Firestore serialization
- `copyWith()` — immutable updates (used after onboarding saves profile data)

**Doctor may ask**: "Why does UserModel extend HiveObject?" → So it can be cached locally in Hive for instant reads on app start, before Firestore fetch completes.

---

### 1.2 `lib/services/firebase_auth_service.dart` (250 lines)
**What it is**: All Firebase Auth operations — sign in, sign up, Google sign-in, password reset, account deletion.

**Key concepts**:
- `authStateChanges` — stream that fires on cold start, sign-in, sign-out. This is how the app knows if someone is logged in.
- `currentUser` — synchronous getter for the current Firebase user (useful for one-off UID reads)
- `fetchUserProfile(user)` — reads `users/{uid}` from Firestore, returns `UserModel`. Falls back to building a minimal profile from Firebase Auth if Firestore doc is missing.
- `signIn(email, password)` → Firebase Auth `signInWithEmailAndPassword()` → `fetchUserProfile()`
- `signUp(name, email, password)` → `createUserWithEmailAndPassword()` → `updateDisplayName()` → Firestore `users/{uid}.set(initialData)` → `fetchUserProfile()`
- `signInWithGoogle()` → Google Sign-In → `GoogleAuthProvider.credential()` → `signInWithCredential()` → checks if Firestore doc exists, creates if first-time
- `deleteAccount()` → deletes ALL subcollections (meals, weights, water, conversations, recipes, notifications) → deletes settings → deletes root doc → `user.delete()`
- `_handleAuthException()` — maps Firebase error codes to user-friendly messages

**Firestore paths used**:
- `users/{uid}` — read (profile), write (initial data), delete (account deletion)
- `users/{uid}/settings/preferences` — delete (account deletion)
- `users/{uid}/meals` — delete (account deletion)
- `users/{uid}/weights` — delete (account deletion)
- `users/{uid}/conversations/{id}/messages` — delete (account deletion)
- `users/{uid}/recipes` — delete (account deletion)
- `users/{uid}/notifications` — delete (account deletion)

**Doctor may ask**: "What happens if the Firestore doc is missing after signup?" → `fetchUserProfile()` builds a minimal profile from Firebase Auth data (displayName, email, photoURL) so the app doesn't crash. Onboarding will fill in the rest.

---

### 1.3 `lib/controllers/auth_controller.dart` (252 lines)
**What it is**: App-wide auth state. Bridges FirebaseAuthService to the rest of the app.

**Key concepts**:
- `user` — the current `UserModel?`. Set automatically by `_listenToAuthChanges()`.
- `isInitialized` — becomes `true` after the first `authStateChanges` event. GoRouter redirect waits on this before routing.
- `_listenToAuthChanges()` — subscribes to `FirebaseAuthService.authStateChanges` once in constructor. On cold start, Firebase persists its own session, so `user` is restored automatically.
- `_scheduleNotifyListeners()` — uses `addPostFrameCallback` to batch notifications and avoid setState-during-build errors.
- `signIn()` → `authService.signIn()` → sets `user` → `_listenToAuthChanges` also fires (idempotent)
- `signUp()` → `authService.signUp()` → sets `user`
- `signInWithGoogle()` → `authService.signInWithGoogle()` → sets `user`
- `logout()` → `authService.signOut()` → `user` cleared by listener automatically
- `deleteAccount()` → `authService.deleteAccount()` → `StorageService.clearAll()`
- `changePassword()` → `authService.reauthenticate()` → `authService.changePassword()`
- `synchronizeOnboardingProfile()` → Firestore `users/{uid}.update()` → creates first weight entry → `user.copyWith()`

**Doctor may ask**: "Why does signIn() set user directly AND rely on the authStateChanges listener?" → Setting it directly means the UI doesn't wait an extra stream tick before navigating. The listener also fires but it's idempotent (sets the same value).

---

### 1.4 `lib/views/auth/sign_in_screen.dart` (221 lines)
**What it is**: The login screen UI.

**Key concepts**:
- Contains `LoginForm` widget (in `widgets/login_form.dart`)
- "Create account" link → `context.push(AppRoutes.signUp)`
- Feature cards below the form (Quant Insight, Biometric Lock, AI Forecasting) — marketing copy
- Theme conventions: `colorScheme`, `textTheme`, `cardColor`, `dividerColor`, brightness checks

---

### 1.5 `lib/views/auth/sign_up_screen.dart` (441 lines)
**What it is**: The registration screen with form validation.

**Key concepts**:
- Form fields: name, email, password, confirm password
- Form validation: empty checks, email format, password min length 6, password match
- `_agreedTerms` checkbox — must be checked to enable submit
- On submit: `context.read<AuthController>().signUp(name, email, password)` → on success: `context.go(AppRoutes.onboard)`
- Google sign-in button: `auth.signInWithGoogle()` → on success: `router.go(AppRoutes.main)`
- Error handling: catches exception, shows SnackBar with cleaned error message
- Reusable widgets: `InputField`, `FieldLabel`, `GradientButton`, `SocialButton` (in `widgets/` folder)

**Doctor may ask**: "What's the difference between `context.go()` and `context.push()`?" → `go()` replaces the navigation stack (no back button), `push()` adds to the stack (back button visible). After signup, `go()` is used to prevent going back to the signup screen.

---

### 1.6 `lib/views/onboarding/onboarding_screen.dart` (592 lines)
**What it is**: 4-step profile setup wizard (Step 02 of 04).

**Key concepts**:
- `_Objective` enum: `weightLoss`, `muscleGain`, `maintenance`
- Sliders for: age (16-80), weight (40-150 kg), height (140-220 cm)
- On submit: `authController.synchronizeOnboardingProfile(age, weight, height, objective)` → `context.go('/main')`
- Objective string mapping: `weightLoss` → "loss weight", `muscleGain` → "build muscle", `maintenance` → "maintenance"
- Progress bar shows step 2/4
- `_AiInsightBox` — static AI insight text (not a real AI call)

**Known issue**: The objective string "loss weight" should be "lose weight" — typo in the code at line 51.

**Doctor may ask**: "What data is saved during onboarding?" → age, weight, height, objective are saved to Firestore `users/{uid}` and a first weight entry is created in `users/{uid}/weights` for chart continuity.

---

## Dependency Chain for Juwairia

```
FirebaseAuthService (Firebase Auth + Firestore)
    ↓ provides
AuthController (app-wide auth state)
    ↓ provides
SignInScreen, SignUpScreen, OnboardingScreen (UI)
    ↓ after onboarding
GoRouter redirect → /dashboard (rest of app)
```

**Critical point**: Every other member's services call `_requireUid()` which depends on Juwairia's auth being initialized first. If auth isn't ready, those services throw exceptions.

---

## Quick Reference — Juwairia's Files

| File | Lines | Role |
|------|-------|------|
| `user_model.dart` | 119 | User data model + Hive + Firestore |
| `firebase_auth_service.dart` | 250 | All Firebase Auth operations |
| `auth_controller.dart` | 252 | App-wide auth state management |
| `sign_in_screen.dart` | 221 | Login UI |
| `sign_up_screen.dart` | 441 | Registration UI with validation |
| `onboarding_screen.dart` | 592 | Profile setup wizard |

**Total**: ~1,875 lines across 6 files

---
---

# 2. Fatma — Meal Logging & Analysis

## Files She Must Know (In Study Order)

### 2.1 `lib/models/meal_model.dart` (134 lines)
**What it is**: The data model for a single meal.

**Key concepts**:
- Fields: `id`, `name`, `type`, `calories`, `protein`, `carbs`, `fat`, `loggedAt`, `vitamins`, `minerals`, `notes`, `analyzedBy`
- `fromFirestore(DocumentSnapshot doc)` — reads from Firestore, handles `Timestamp` type
- `toFirestoreMap()` — writes to Firestore, uses `FieldValue.serverTimestamp()` for new writes
- `fromJson()`/`toJson()` — legacy REST format (kept for compatibility)

**Doctor may ask**: "What's the difference between `fromFirestore` and `fromJson`?" → Firestore uses `Timestamp` objects, not ISO date strings.

---

### 2.2 `lib/services/ai_service.dart` (291 lines)
**What it is**: Calls Google Gemini API for meal analysis, chat, recipe generation.

**Key concepts**:
- `_callModel(prompt)` — core method: POSTs to Gemini, handles JSON parsing with fallback
- `analyzeMeal(description)` — prompt asks for `{name, calories, protein, carbs, fat, vitamins, minerals, notes}`
- API key via `--dart-define=GEMINI_API_KEY=...` (not hardcoded)
- Response cleaning: strips markdown fences, fallback JSON extraction between first `{` and last `}`
- `responseMimeType: 'application/json'` in generationConfig

**Doctor may ask**: "What happens if Gemini returns invalid JSON?" → Fallback parser finds first `{` and last `}` substring and retries parse.

---

### 2.3 `lib/services/meal_service.dart` (277 lines)
**What it is**: Firestore CRUD for meals.

**Key concepts**:
- `_requireUid()` — auth guard, throws if no signed-in user
- `saveMeal(meal)` — writes to Firestore, falls back to Hive queue on offline
- `_saveOffline(meal)` — generates localId, queues in Hive
- `syncPendingMeals()` — drains Hive queue to Firestore when back online
- `watchTodaysMeals()` — real-time Firestore stream (Dashboard uses this)
- `getMealHistory()` — paginated fetch with `startAfterDocument`
- `getMealsBetween(start, end)` — date range query for weekly reports
- `getRecentDistinctMealNames()` — feeds "quick favorites"

**Firestore path**: `users/{uid}/meals/{mealId}`

---

### 2.4 `lib/controllers/meal_controller.dart` (235 lines)
**What it is**: Bridge between UI and services.

**Key concepts**:
- Takes BOTH `MealService` and `AiService` (separation of concerns)
- `analyzeMeal(description)` → `AiService.analyzeMeal()` → sets `analyzedMeal`
- `saveMeal()` → `MealService.saveMeal()` → fire-and-forget `_trySync()`
- `loadHistory()` → `MealService.getMealHistory()`
- `filteredHistory` — computed getter, filters by `HistoryFilter` (today/week/month) + search query
- `groupedHistory` — groups meals by date label (Today, Yesterday, etc.)
- `deleteMeal()`, `updateMeal()` — CRUD operations
- `getQuickFavorites()` — returns recent distinct meal names

---

### 2.5 `lib/views/meal_logging/add_meal_screen.dart` (709 lines)
**What it is**: Screen where users choose how to log a meal.

**Key concepts**:
- 4 input methods: text, photo (coming soon), barcode (coming soon), voice
- Text input: bottom sheet with TextField → `controller.analyzeMeal(description)` → navigate to MealAnalysisScreen
- Voice input: `VoiceInputService` (speech-to-text) → same analysis flow
- "Quick Log Favorites": loads real recent meal names from Firestore
- Tapping favorite re-runs AI analysis (intentional — only name is cached, not full nutrition data)

---

### 2.6 `lib/views/meal_logging/meal_analysis_screen.dart` (891 lines)
**What it is**: Shows AI analysis results before saving.

**Key concepts**:
- **Health Score Card**: `_computeHealthScore()` — 0-100 score comparing meal macros to 1/3 of daily goals
- **Macro Grid**: calories, protein, carbs, fat with progress bars
- **Vitamins/Minerals**: micronutrients as % of daily value
- **Meal Type Selector**: breakfast/lunch/dinner/snack chips
- **Portion Adjuster**: multiplier (0.5, 1.0, 2.0, etc.) — creates new MealModel with adjusted values
- **Log to Diary Button**: `controller.saveMeal()` → navigate back

**Health score formula** (line 791-809):
```
expectedCal = goalCalories / 3
component(actual, expected) = max(0, 100 - |actual - expected| / expected * 100)
score = average of (calScore, proteinScore, carbsScore, fatScore)
```

---

### 2.7 `lib/views/history/meal_history_screen.dart` (388 lines)
**What it is**: Calendar + list view of past meals.

**Key concepts**:
- Uses `HistoryController` (separate from `MealController`)
- Calendar view with dots on days that have meals
- List view grouped by date
- Search by meal name, filter by meal type

---

## Dependency Chain for Fatma

```
Juwairia's Auth (FirebaseAuthService)
    ↓ provides uid
Fatma's MealService (_requireUid())
    ↓ provides meals
Fatma's MealController (MealService + AiService)
    ↓ provides state
Fatma's Screens (AddMealScreen, MealAnalysisScreen, MealHistoryScreen)
```

---

## Quick Reference — Fatma's Files

| File | Lines | Role |
|------|-------|------|
| `meal_model.dart` | 134 | Data model + Firestore serialization |
| `ai_service.dart` | 291 | Gemini API calls (6 prompts) |
| `meal_service.dart` | 277 | Firestore CRUD + offline queue |
| `meal_controller.dart` | 235 | State management for meals |
| `add_meal_screen.dart` | 709 | Text/voice input + quick favorites |
| `meal_analysis_screen.dart` | 891 | Analysis results + health score |
| `meal_history_screen.dart` | 388 | Calendar + search + filter |

**Total**: ~2,725 lines across 7 files

---
---

# 3. Abdel — Dashboard & Data Visualization

## Files He Must Know (In Study Order)

### 3.1 `lib/models/daily_summary_model.dart`
**What it is**: Aggregated daily nutrition data.

**Key concepts**:
- Fields: `date`, `totalCalories`, `calorieGoal`, `exerciseCalories`, `totalProtein`, `totalCarbs`, `totalFat`, `proteinGoal`, `carbsGoal`, `fatGoal`, `meals`
- Computed getters: `calorieProgress`, `proteinProgress`, `carbsProgress`, `fatProgress` (actual/goal)
- Used by DashboardController to expose today's summary

---

### 3.2 `lib/controllers/dashboard_controller.dart` (152 lines)
**What it is**: Loads and exposes the daily nutritional summary.

**Key concepts**:
- Takes `MealService` and `AiService` in constructor
- `loadSummary(settings)` — calls `MealService.getDailySummary()`, re-applies goals from `SettingController`
- `loadDietaryTip()` — calls `AiService.getDietaryTip()` once ≥2 meals logged, caches result
- `loadActiveStreak()` — fetches last 500 meals, counts consecutive days with meals
- `summary` — the current `DailySummaryModel?`
- `dietaryTip` — AI tip string (null until loaded)
- `activeStreak` — streak count (null until loaded)

**Key design decision**: `loadSummary()` takes `SettingController` as parameter (not held as field) — stays decoupled, always uses current goal values.

---

### 3.3 `lib/views/dashboard/dashboard_screen.dart` (291 lines)
**What it is**: The main home screen.

**Key concepts**:
- Loads data in `initState` via `addPostFrameCallback`
- Three states: loading (LoadingOverlay), error (retry button), data ( SingleChildScrollView)
- Components in order:
  1. Active streak indicator (fire icon + "X-day streak")
  2. `CalorieRingWidget` — circular progress for calories
  3. `MacroCard` row — protein, carbs, fats with progress bars
  4. `WaterTrackerWidget` — water intake with bottom sheet for logging
  5. `SmartAnalysisCard` — AI dietary tip (or placeholder if <2 meals)
  6. "Daily Log" header + `DailyLogItem` list (timeline of today's meals)

**Data flow**:
```
DashboardScreen.initState()
  → DashboardController.loadSummary(settings)
  → MealService.getDailySummary(DateTime.now())
  → Firestore: users/{uid}/meals.where('loggedAt', >= startOfDay)
  → summary = DailySummaryModel
  → If meals >= 2: loadDietaryTip()
  → loadActiveStreak()
```

---

### 3.4 `lib/views/dashboard/widgets/calorie_ring_widget.dart`
**What it is**: Circular calorie progress ring.

**Key concepts**:
- CustomPainter for the ring arc
- Shows consumed vs goal calories
- Color changes based on progress (green → yellow → red)

---

### 3.5 `lib/views/dashboard/widgets/macro_card.dart`
**What it is**: Protein/carbs/fat progress cards.

**Key concepts**:
- Shows label, current value, progress bar
- Color-coded per macro type

---

### 3.6 `lib/views/dashboard/widgets/smart_analysis_card.dart`
**What it is**: AI dietary tip card.

**Key concepts**:
- Displays `dietaryTip` from DashboardController
- Shows placeholder text if tip not yet loaded
- Loading state while AI call is in progress

---

### 3.7 `lib/views/dashboard/widgets/water_tracker_widget.dart`
**What it is**: Water intake tracker.

**Key concepts**:
- Shows current ml / goal ml
- Tap to log water (opens bottom sheet with amount options)
- Uses `WaterController` (separate controller)

---

### 3.8 `lib/views/dashboard/widgets/daily_log_item.dart`
**What it is**: Individual meal entry in the daily log timeline.

**Key concepts**:
- Shows meal type icon, food name, calories, logged time
- Timeline connector line between items
- `isLast` flag removes the connector for the final item

---

## Dependency Chain for Abdel

```
Juwairia's Auth (provides uid)
    ↓
Fatma's MealService (provides getDailySummary, watchTodaysMeals)
    ↓
Ahmed's SettingController (provides goalCalories, goalProtein, etc.)
    ↓
Abdel's DashboardController (combines all above)
    ↓
Abdel's DashboardScreen + widgets (UI)
```

**Critical point**: Abdel depends on BOTH Fatma's meals AND Ahmed's settings. If either is missing, the dashboard shows incorrect data.

---

## Quick Reference — Abdel's Files

| File | Lines | Role |
|------|-------|------|
| `daily_summary_model.dart` | ~80 | Aggregated daily data model |
| `dashboard_controller.dart` | 152 | Loads summary, tip, streak |
| `dashboard_screen.dart` | 291 | Main home screen |
| `calorie_ring_widget.dart` | ~150 | Circular calorie progress |
| `macro_card.dart` | ~100 | Protein/carbs/fat cards |
| `smart_analysis_card.dart` | ~60 | AI dietary tip card |
| `water_tracker_widget.dart` | ~120 | Water intake tracker |
| `daily_log_item.dart` | ~80 | Meal entry timeline item |

**Total**: ~1,033 lines across 8 files

---
---

# 4. Tarek — Weekly Reports & AI Chat

## Files He Must Know (In Study Order)

### 4.1 `lib/services/weekly_report_service.dart` (124 lines)
**What it is**: Fetches and aggregates 7 days of meal data.

**Key concepts**:
- `DailyAggregate` class: date, totalCalories, totalProtein, totalCarbs, totalFat, mealCount
- `WeeklyReport` class: days (list of 7 DailyAggregate), allMeals (flattened)
- Computed getters: `avgCalories`, `totalProtein`, `totalCarbs`, `totalFat`, `macroPercentages`, `dailyCalories`, `topMealByCalories`
- `getWeeklyReport()` — Firestore query: `users/{uid}/meals.where('loggedAt', >= 6 days ago).orderBy('loggedAt')`
- Groups meals by calendar day, builds one aggregate per day (including empty days for charts)

**Macro percentage formula**: `(protein*4) : (carbs*4) : (fat*9)` → normalized to 0-1 (calorie-based)

---

### 4.2 `lib/controllers/weekly_report_controller.dart` (55 lines)
**What it is**: Bridges WeeklyReportService and AiService to the UI.

**Key concepts**:
- `loadReport()` — calls `_reportService.getWeeklyReport()`, then `_loadOracleCard()`
- `_loadOracleCard()` — calls `_aiService.getWeeklyOracleVerdict(report)` → sets `oracleGrade`, `oracleSummary`, `oracleRecs`
- `report` — the `WeeklyReport?` object
- `oracleGrade` — letter grade string (e.g., "B+")
- `oracleSummary` — one-sentence metabolic overview
- `oracleRecs` — list of 3 recommendation strings

---

### 4.3 `lib/views/reports/weekly_report_screen.dart` (149 lines)
**What it is**: Weekly report UI with charts and AI verdict.

**Key concepts**:
- Loads data in `initState` via `addPostFrameCallback`
- Components:
  1. `Header` — title
  2. `CaloricFluxCard` — 7-day calorie bar chart (real data)
  3. `MacroIntegrityCard` — macro donut chart (real percentages)
  4. `OracleCard` — AI health grade + summary + recommendations
  5. `StatsGrid` — average calories
  6. `WeightCard` — latest weight, change, trend (from WeightController)
  7. `ViewSummaryButton`
- `_dayLabels()` — generates MON-SUN labels based on current weekday

---

### 4.4 `lib/services/ai_service.dart` (291 lines — shared with Fatma)
**What Tarek specifically uses**:
- `chat(history)` — sends conversation history to Gemini, returns reply
- `generateRecipe(prompt)` — returns `RecipeModel`
- `getHabitInsights(weeklyMeals)` — returns 3 habit observations
- `getWeeklyOracleVerdict(report)` — returns `{grade, summary, recommendations}`

---

### 4.5 `lib/controllers/ai_controller.dart` (215 lines)
**What it is**: Manages AI coach chat, recipe generation, habit insights.

**Key concepts**:
- `_requireUid()` — auth guard
- `_conversationsRef(uid)` — `users/{uid}/conversations` collection
- `loadConversation()` — fetches most recent conversation from Firestore, loads messages subcollection
- `sendMessage(text)` — adds user message to local list → `AiService.chat(last 10 messages)` → adds assistant message → persists both to Firestore
- `_persistMessages()` — batch write to `conversations/{convId}/messages/{msgId}` + update `updatedAt`
- `clearChat()` — clears messages, creates new conversation doc
- `generateRecipe(prompt)` — `AiService.generateRecipe()` → saves to `users/{uid}/recipes`
- `loadHabitInsights(weeklyMeals)` — `AiService.getHabitInsights()`

**Firestore paths**:
- `users/{uid}/conversations/{convId}` — conversation documents
- `users/{uid}/conversations/{convId}/messages/{msgId}` — messages subcollection
- `users/{uid}/recipes/{recipeId}` — saved recipes

---

### 4.6 `lib/views/ai/chat_screen.dart`
**What it is**: AI coach chat interface.

**Key concepts**:
- Chat bubbles (user right, assistant left)
- Text input field with send button
- Loading indicator while AI responds
- Conversation history loaded from Firestore on screen open

---

## Dependency Chain for Tarek

```
Juwairia's Auth (provides uid)
    ↓
Fatma's MealService (provides meals for reports)
    ↓
Tarek's WeeklyReportService (aggregates 7 days)
    ↓
Tarek's WeeklyReportController (report + AI oracle)
    ↓
Tarek's WeeklyReportScreen (UI)

 ALSO:

Fatma's AiService (Gemini API)
    ↓
Tarek's AiController (chat + recipes + insights)
    ↓
Tarek's ChatScreen, RecipeListScreen (UI)
```

---

## Quick Reference — Tarek's Files

| File | Lines | Role |
|------|-------|------|
| `weekly_report_service.dart` | 124 | 7-day data aggregation |
| `weekly_report_controller.dart` | 55 | Report + AI oracle state |
| `weekly_report_screen.dart` | 149 | Report UI with charts |
| `ai_controller.dart` | 215 | Chat, recipes, insights |
| `ai_service.dart` (his parts) | ~100 | chat(), generateRecipe(), getWeeklyOracleVerdict() |

**Total**: ~643 lines (Tarek's primary files)

---
---

# 5. Ahmed — Profile, Settings & System Architecture

## Files He Must Know (In Study Order)

### 5.1 `lib/models/settings_model.dart` (112 lines)
**What it is**: All user-configurable settings.

**Key concepts**:
- Hive annotations (`@HiveType(typeId: 1)`, `@HiveField`) — 15 fields
- Fields: `darkMode`, `notifFrequency`, `incognito`, `goalCalories`, `goalProtein`, `goalCarbs`, `goalFat`, `goalWaterMl`, `textSize`, `highContrast`, `voiceSensitivity`, `adaptiveAssist`, `anonymousAnalytics`, `geoTracking`, `aiTrainingModel`
- Defaults: goalCalories=2000, goalProtein=150, goalCarbs=250, goalFat=65, goalWaterMl=2000
- `fromJson()` / `toJson()` — Firestore serialization

---

### 5.2 `lib/services/storage_service.dart` (123 lines)
**What it is**: Typed Hive local storage.

**Key concepts**:
- 5 Hive boxes: `user_box`, `settings_box`, `meal_cache`, `offline_queue`, `meal_reminders`
- Static methods — all methods are static, called directly (not instantiated)
- `init()` — opens all boxes, called once in `main.dart` after Hive init
- `saveUser()` / `getUser()` — UserModel cache
- `saveSettings()` / `getSettings()` — SettingsModel cache
- `queueOfflineMeal()` / `getPendingMeals()` / `removePendingMeal()` — offline meal queue
- `saveReminderTimes()` / `getReminderTimes()` — meal reminder persistence
- `clearAll()` — wipes all boxes (used on logout)

---

### 5.3 `lib/controllers/setting_controller.dart` (280 lines)
**What it is**: App-wide settings with dual persistence (Hive + Firestore).

**Key concepts**:
- Constructor calls `loadSettings()` — loads from Hive first, then reconciles with Firestore
- `loadSettings()` — Hive (instant) → Firestore (background) → if remote differs, apply remote + update Hive
- Every setter: `_value = newValue` → `notifyListeners()` → `_persist()`
- `_persist()` — writes to Hive (always succeeds) + writes to Firestore (may fail)
- `_applyModel(model)` — applies all fields from a SettingsModel to in-memory state
- `_currentModel()` — builds SettingsModel from current in-memory state
- Firestore path: `users/{uid}/settings/preferences`

**Doctor may ask**: "What happens if Firestore write fails?" → Hive write still succeeds. Error message shown. On next app load, Hive value used immediately. Next successful sync reconciles.

---

### 5.4 `lib/views/settings/settings_screen.dart` (885 lines)
**What it is**: Full settings screen with all toggles and navigation.

**Key concepts**:
- Premium card (marketing)
- Theme toggle (dark mode) via `SettingController.setDarkMode()`
- Goal editing (calories, protein, carbs, fat)
- Meal reminders section
- Accessibility settings (text size, high contrast, adaptive assist)
- Privacy settings (analytics, geo tracking, AI training)
- Account section (profile, logout, delete account)
- Navigation to sub-screens (accessibility, privacy, support)

---

### 5.5 `lib/views/profile/profile_screen.dart` (483 lines)
**What it is**: User profile with stats and edit capability.

**Key concepts**:
- Avatar: loads from `profile.avatarUrl` (network image), falls back to asset
- Stats: total meals (from `ProfileController`), active streak (from `DashboardController`), member since
- Edit mode: bottom sheet to edit name and bio via `ProfileController.updateProfile()`
- Navigation: GoRouter routes to settings, accessibility, privacy, support
- Uses `ProfileController` (separate controller for profile data)

---

### 5.6 `firestore.rules` (13 lines)
**What it is**: Security rules for Firestore.

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;
    }
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

**Key principles**:
- User isolation: each user can only access their own `users/{uid}/` subtree
- No anonymous access: all requests require Firebase Auth token
- Default deny: catch-all rule denies all other access

---

### 5.7 `lib/app.dart` (GoRouter + Provider setup)
**What it is**: App configuration — routing and dependency injection.

**Key concepts**:
- `MultiProvider` — all controllers created here
- `GoRouter` — all routes defined here
- Redirect logic: checks `AuthController.isInitialized`, `isLoggedIn`, `isOnboarded`
- `ShellRoute` — bottom navigation shell (MainScreen)

---

## Dependency Chain for Ahmed

```
Juwairia's Auth (provides uid)
    ↓
Ahmed's StorageService (Hive local cache)
    ↓
Ahmed's SettingController (dual persistence)
    ↓
Ahmed's SettingsScreen, ProfileScreen (UI)
    ↓
Abdel's Dashboard (reads goals from SettingController)
```

**Critical point**: Ahmed's settings are read by Abdel's dashboard (for goal values) and by Fatma's meal analysis screen (for health score calculation). Settings must be initialized before those features work correctly.

---

## Quick Reference — Ahmed's Files

| File | Lines | Role |
|------|-------|------|
| `settings_model.dart` | 112 | Settings data model + Hive |
| `storage_service.dart` | 123 | Typed Hive local storage |
| `setting_controller.dart` | 280 | Dual persistence settings |
| `settings_screen.dart` | 885 | Full settings UI |
| `profile_screen.dart` | 483 | User profile + stats |
| `firestore.rules` | 13 | Security rules |
| `app.dart` | ~200 | GoRouter + Provider setup |

**Total**: ~2,096 lines across 7 files

---
---

# Cross-Member Dependencies Summary

```
Juwairia (Auth)
  │
  ├──→ Fatma (MealService._requireUid())
  │       │
  │       ├──→ Abdel (DashboardController uses MealService)
  │       │
  │       └──→ Tarek (WeeklyReportService uses MealService)
  │
  └──→ Ahmed (SettingController._requireUid())
          │
          └──→ Abdel (DashboardController uses SettingController for goals)
```

**Who reviews whose code**:
| Reviewer | Reviews | Why |
|----------|---------|-----|
| Ahmed | Juwairia's auth | Settings depend on auth |
| Fatma | Juwairia's auth | Meals depend on auth |
| Abdel | Fatma's meals + Ahmed's settings | Dashboard depends on both |
| Tarek | Fatma's meals | Reports depend on meals |
| Juwairia | Ahmed's settings | Auth flow uses settings |

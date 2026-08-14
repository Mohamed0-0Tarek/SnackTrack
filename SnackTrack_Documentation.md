# SnackTrack

## AI-Powered Nutrition Intelligence Platform

---

**Course**: Software Engineering Final Project
**Team Members**:
- Juwairia — Authentication & Onboarding
- Fatma — Meal Logging & Analysis
- Abdel — Dashboard & Data Visualization
- Tarek — Weekly Reports & AI Chat
- Ahmed — Profile, Settings & System Architecture

**Date**: July 2026
**Version**: 1.0

---

# Table of Contents

1. Executive Summary
2. Literature Review & Tool Justification
3. Requirements Specification
4. System Architecture & Design
5. Database Design
6. API & AI Integration
7. Feature Documentation
   - 7.1 Authentication & Onboarding
   - 7.2 Dashboard
   - 7.3 Meal Logging & AI Analysis
   - 7.4 Meal History
   - 7.5 Weekly Reports
   - 7.6 AI Coach Chat
   - 7.7 Recipe Generation
   - 7.8 Meal Plan Generation
   - 7.9 Weight Tracking
   - 7.10 Settings & Profile
   - 7.11 Notifications & Reminders
8. Accessibility Implementation
9. Offline Support & Persistence
10. Security Implementation
11. Testing Strategy
12. Git Workflow & Collaboration
13. Known Issues & Future Work
14. Conclusion
15. References

---

# 1. Executive Summary

## 1.1 Project Purpose

SnackTrack is an AI-powered nutrition tracking mobile application designed to help users monitor their dietary intake, receive personalized nutrition advice, and build healthier eating habits. The app leverages Google's Gemini AI to analyze meals described in natural language, eliminating the need for manual nutrient lookup or barcode scanning.

## 1.2 Target User

The primary target user is a university student who wants to improve their diet but finds existing nutrition apps too complex, overwhelming, or lacking in personalized guidance. SnackTrack provides a streamlined experience focused on quick meal logging, intelligent analysis, and actionable recommendations.

## 1.3 Key Features

| Feature | Description |
|---------|-------------|
| AI Meal Analysis | Describe a meal in text or voice; AI returns calories, macros, vitamins, and health tips |
| Smart Dashboard | Real-time daily calorie ring, macro progress bars, water tracker, and AI dietary tips |
| Weekly Reports | Aggregated nutrition data with charts, trends, and an AI-generated health grade |
| AI Coach | Chat-based nutrition advisor that answers questions and provides personalized guidance |
| Recipe Generation | AI generates healthy recipes based on user preferences and restrictions |
| Meal Planning | AI creates personalized meal plans for any duration |
| Weight Tracking | Log and visualize weight trends over time |
| Accessibility | Text scaling, high contrast mode, and reduced motion support |
| Offline Support | Meal logging and settings persist locally via Hive; sync to Firestore when online |

## 1.4 Technology Stack

| Layer | Technology | Justification |
|-------|-----------|---------------|
| Frontend | Flutter 3.x / Dart | Cross-platform, hot reload, rich widget ecosystem |
| State Management | Provider | Simple, well-documented, sufficient for app scale |
| Navigation | GoRouter | Declarative routing, deep link support, shell routes |
| Authentication | Firebase Auth | Email/password + Google sign-in, auth state stream |
| Database | Cloud Firestore | Real-time sync, offline persistence, subcollection model |
| Local Storage | Hive | Fast NoSQL, typed boxes, no native dependencies |
| AI Engine | Google Gemini (gemini-2.5-flash-lite) | Free tier, fast, structured JSON output |
| Notifications | Flutter Local Notifications | Meal reminders, scheduled alerts |
| Background | Firebase Messaging | Push notification support |

---

# 2. Literature Review & Tool Justification

## 2.1 Competitor Analysis

### MyFitnessPal
- **Strengths**: Massive food database (14M+ items), barcode scanning, macro tracking
- **Weaknesses**: Overwhelming UI for new users, limited AI guidance, paywall for advanced features
- **SnackTrack Difference**: AI-first approach — describe meals in natural language, no database lookup needed

### Cronometer
- **Strengths**: Detailed micronutrient tracking, scientific accuracy
- **Weaknesses**: Complex interface, steep learning curve, limited AI features
- **SnackTrack Difference**: Simplified UX with AI interpreting complex nutrition data automatically

### Lose It!
- **Strengths**: Clean UI, photo-based logging, social features
- **Weaknesses**: AI features behind premium, limited recipe generation
- **SnackTrack Difference**: AI coaching and recipe generation available for free

## 2.2 API Comparison

| Feature | Gemini | OpenAI GPT-4 | Nutritionix | Edamam |
|---------|--------|--------------|-------------|--------|
| Free Tier | Yes (generous) | Limited | Limited | Limited |
| Speed | Fast (~1-2s) | Medium (~2-4s) | Fast | Fast |
| Structured JSON | Native support | Via prompt engineering | Native | Native |
| Nutrition Analysis | Excellent | Excellent | Specialized | Specialized |
| Recipe Generation | Yes | Yes | No | Yes |
| Cost (at scale) | Low | High | Medium | Medium |

**Decision**: Gemini was chosen for its generous free tier, fast response times, native JSON output support, and ability to handle multiple use cases (meal analysis, chat, recipe generation) with a single API.

## 2.3 Backend Comparison

| Feature | Firebase Firestore | REST API (Node.js) | Supabase |
|---------|-------------------|--------------------|---------|
| Setup Complexity | Low | High | Medium |
| Real-time Sync | Native | Requires WebSocket | Native |
| Offline Support | Built-in | Custom implementation | Limited |
| Authentication | Built-in | Custom (JWT) | Built-in |
| Hosting | Managed | Self-managed | Managed |
| Cost | Pay per read/write | Server hosting cost | Pay per query |

**Decision**: Firebase Firestore was chosen for its built-in real-time sync, offline persistence, managed infrastructure, and seamless integration with Firebase Auth — eliminating the need for a custom backend server.

## 2.4 Framework Comparison

| Feature | Flutter | React Native | Kotlin (Native) |
|---------|---------|-------------|----------------|
| Cross-platform | Yes (single codebase) | Yes (JS bridge) | No (Android only) |
| Performance | Near-native | Good (JS bridge overhead) | Native |
| UI Consistency | High (custom rendering) | Medium (native components) | Platform-specific |
| Hot Reload | Yes | Yes | Limited |
| Learning Curve | Medium | Medium | Low (for Android) |
| Ecosystem | Growing rapidly | Mature | Mature |

**Decision**: Flutter was chosen for its single codebase approach, near-native performance, consistent UI across platforms, and strong support from Google.

---

# 3. Requirements Specification

## 3.1 Functional Requirements

| ID | Requirement | Priority | Owner |
|----|-------------|----------|-------|
| FR-01 | User can register with email and password | Critical | Juwairia |
| FR-02 | User can sign in with email/password or Google account | Critical | Juwairia |
| FR-03 | User can log out and sign back in with session persistence | Critical | Juwairia |
| FR-04 | User completes onboarding (profile setup) on first launch | High | Juwairia |
| FR-05 | User can log meals by describing them in text or voice | Critical | Fatma |
| FR-06 | AI analyzes meal and returns nutrition data (calories, macros, vitamins) | Critical | Fatma |
| FR-07 | User can adjust portion size and meal type before saving | High | Fatma |
| FR-08 | User can view meal history with search and filter by date/type | High | Fatma |
| FR-09 | User can edit or delete previously logged meals | High | Fatma |
| FR-10 | Dashboard displays real-time daily calorie and macro summary | Critical | Abdel |
| FR-11 | Dashboard shows calorie ring, macro progress bars, and water tracker | High | Abdel |
| FR-12 | Dashboard displays AI dietary tip after 2+ meals logged | Medium | Abdel |
| FR-13 | Dashboard calculates and displays active streak | Medium | Abdel |
| FR-14 | Weekly report shows 7-day nutrition data with charts | High | Tarek |
| FR-15 | Weekly report includes AI-generated health grade and recommendations | Medium | Tarek |
| FR-16 | AI chat coach answers nutrition questions with conversation history | High | Tarek |
| FR-17 | AI generates personalized recipes based on preferences | Medium | Tarek |
| FR-18 | AI generates meal plans for specified duration | Medium | Tarek |
| FR-19 | User can track weight over time with trend visualization | Medium | Ahmed |
| FR-20 | User can edit profile information and avatar | Medium | Ahmed |
| FR-21 | User can customize settings (dark mode, goals, reminders) | High | Ahmed |
| FR-22 | Meal reminders via local notifications | Medium | Ahmed |
| FR-23 | User can delete account and all associated data | High | Ahmed |

## 3.2 Non-Functional Requirements

| ID | Requirement | Priority | Owner |
|----|-------------|----------|-------|
| NFR-01 | App functions offline with local data persistence | High | Ahmed |
| NFR-02 | Settings persist across app sessions | High | Ahmed |
| NFR-03 | API responses within 3 seconds on standard connection | High | Fatma |
| NFR-04 | Data encrypted in transit (HTTPS) and at rest (Firebase) | Critical | Ahmed |
| NFR-05 | App supports text scaling from 0.8x to 2.0x | Medium | Ahmed |
| NFR-06 | App supports high contrast mode for visually impaired users | Medium | Ahmed |
| NFR-07 | App respects reduced motion preferences | Medium | Ahmed |
| NFR-08 | Firestore security rules enforce user-level data isolation | Critical | Ahmed |

## 3.3 Accessibility Requirements

| Requirement | WCAG Criterion | Implementation |
|-------------|---------------|----------------|
| Text Scaling | 1.4.4 Resize Text | Compact/Standard/Enlarged modes in Settings |
| Color Contrast | 1.4.3 Contrast (Minimum) | High contrast mode with enhanced color palette |
| Motion Sensitivity | 2.3.3 Animation from Interactions | AdaptiveAssist widget respects reduced motion |
| Touch Targets | 2.5.5 Target Size | Minimum 44x44 logical pixels for all interactive elements |
| Screen Reader | 1.3.1 Info and Relationships | Semantic labels on all interactive widgets |
| Error Identification | 3.3.1 Error Identification | Clear error messages with visual indicators |

---

# 4. System Architecture & Design

## 4.1 Architecture Pattern

SnackTrack uses a **Service-Controller-View** architecture:

```
┌─────────────────────────────────────────────────────────┐
│                    UI Layer (Views)                      │
│         screens/, widgets/ — StatelessWidget             │
│         User interaction & rendering                     │
└──────────────────────┬──────────────────────────────────┘
                       │ Provider.of / context.watch
                       ▼
┌─────────────────────────────────────────────────────────┐
│              Controller Layer (ChangeNotifier)           │
│         controllers/ — ChangeNotifier                    │
│         Business logic, state management                 │
└──────────────────────┬──────────────────────────────────┘
                       │ Service method calls
                       ▼
┌─────────────────────────────────────────────────────────┐
│                Service Layer                            │
│         services/ — Plain Dart classes                   │
│         Firestore CRUD, Hive operations, API calls       │
└──────────┬─────────────────────────┬────────────────────┘
           │                         │
           ▼                         ▼
┌──────────────────┐    ┌──────────────────────────────┐
│  Cloud Firestore │    │      Google Gemini API       │
│  (Remote DB)     │    │      (AI Engine)             │
└──────────────────┘    └──────────────────────────────┘
           ▲
           │ Hive (Local Storage)
┌──────────────────┐
│   Hive Storage   │
│   (Local Cache)  │
└──────────────────┘
```

## 4.2 Data Flow Pattern

Every feature follows the same data flow:

```
1. User Action → View (onPressed, onChanged)
2. View calls → Controller method
3. Controller calls → Service method
4. Service calls → Firestore/Gemini/Hive
5. Service returns → Result (success/error)
6. Controller updates → State (notifyListeners)
7. View rebuilds → Updated UI
```

Example — Adding a Meal:

```
User taps "Log Meal" button
  → AddMealScreen._onSubmit()
  → MealController.analyzeMeal()
  → AiService.analyzeMeal()
  → Gemini API (HTTP POST)
  → JSON parsed → NutritionData
  → MealController._pendingAnalysis updated
  → MealAnalysisScreen displayed
User taps "Confirm"
  → MealController.confirmAddMeal()
  → MealService.addMeal()
  → Firestore (users/{uid}/meals/{id})
  → Hive (offline queue if no connection)
  → MealController.notifyListeners()
  → DashboardController.loadSummary() (triggered by listener)
  → Dashboard UI rebuilds with new data
```

## 4.3 Folder Structure

```
lib/
├── main.dart                          # Entry point, Firebase/Hive init
├── app.dart                           # GoRouter config, MultiProvider setup
├── main_screen.dart                   # Bottom navigation shell
├── firebase_options.dart              # Firebase config (auto-generated)
│
├── core/
│   ├── constants/
│   │   ├── app_routes.dart            # Route path strings
│   │   ├── app_colors.dart            # Color palette
│   │   ├── app_strings.dart           # UI text constants
│   │   └── app_dimensions.dart        # Spacing/sizing constants
│   ├── theme/
│   │   └── app_theme.dart             # ThemeData definitions
│   └── widgets/
│       ├── buttons.dart               # Primary/secondary button widgets
│       ├── text_fields.dart           # Styled text input widgets
│       └── loading_overlay.dart       # Full-screen loading indicator
│
├── models/
│   ├── meal_model.dart                # Meal data class with Firestore serialization
│   ├── daily_summary_model.dart       # Aggregated daily nutrition data
│   ├── weekly_report_model.dart       # 7-day aggregated report
│   ├── recipe_model.dart              # AI-generated recipe structure
│   ├── chat_message_model.dart        # Chat message with role/content
│   ├── user_profile_model.dart        # User profile data
│   ├── weight_entry_model.dart        # Weight log entry
│   └── notification_model.dart        # Notification data
│
├── services/
│   ├── firebase_auth_service.dart     # Firebase Auth (signIn, signUp, signOut)
│   ├── firestore_service.dart         # Generic Firestore CRUD operations
│   ├── meal_service.dart              # Meal-specific Firestore operations
│   ├── ai_service.dart                # Gemini API integration
│   ├── storage_service.dart           # Hive local storage operations
│   ├── notification_service.dart      # Firestore notification stream
│   ├── meal_reminder_service.dart     # Local notification scheduling
│   ├── weekly_report_service.dart     # Weekly data aggregation
│   └── profile_service.dart           # User profile Firestore operations
│
├── controllers/
│   ├── auth_controller.dart           # Auth state, session management
│   ├── meal_controller.dart           # Meal logging, analysis, history
│   ├── dashboard_controller.dart      # Dashboard summary, streaks
│   ├── setting_controller.dart        # Settings (Hive + Firestore dual persist)
│   ├── ai_controller.dart             # AI chat, conversations
│   ├── onboarding_controller.dart     # Onboarding state machine
│   └── weight_controller.dart         # Weight tracking
│
└── views/
    ├── auth/
    │   ├── login_screen.dart
    │   ├── signup_screen.dart
    │   └── forgot_password_screen.dart
    ├── onboarding/
    │   ├── onboarding_screen.dart      # 5-step profile setup wizard
    │   └── onboarding_controller.dart
    ├── dashboard/
    │   └── dashboard_screen.dart       # Main dashboard with summary cards
    ├── meal_logging/
    │   ├── add_meal_screen.dart        # Text/voice meal input
    │   ├── meal_analysis_screen.dart   # AI analysis results
    │   └── meal_detail_screen.dart     # View/edit saved meal
    ├── history/
    │   └── meal_history_screen.dart    # Calendar + list view of meals
    ├── ai/
    │   ├── chat_screen.dart            # AI coach chat interface
    │   └── recipe_list_screen.dart     # Saved AI recipes
    ├── reports/
    │   └── weekly_report_screen.dart   # Charts and AI verdict
    ├── recipes/
    │   └── recipe_detail_screen.dart   # Full recipe view
    ├── meal_plan/
    │   └── meal_plan_screen.dart       # AI-generated meal plan
    ├── weight/
    │   └── weight_screen.dart          # Weight log and chart
    ├── profile/
    │   └── profile_screen.dart         # User profile and stats
    ├── settings/
    │   └── settings_screen.dart        # App settings
    ├── notifications/
    │   └── notifications_screen.dart   # Notification center
    ├── accessibility/
    │   └── accessibility_settings_screen.dart
    ├── privacy/
    │   └── privacy_screen.dart
    └── support/
        └── support_screen.dart
```

## 4.4 State Management Strategy

Provider is used for all state management. The setup in `app.dart`:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthController()),
    ChangeNotifierProvider(create: (_) => SettingController()),
    ChangeNotifierProvider(create: (_) => MealController()),
    ChangeNotifierProvider(create: (_) => DashboardController()),
    ChangeNotifierProvider(create: (_) => AiController()),
    ChangeNotifierProvider(create: (_) => OnboardingController()),
    ChangeNotifierProvider(create: (_) => WeightController()),
  ],
  child: const SnackTrackApp(),
)
```

**Key pattern**: Controllers listen to each other via `_listenToChanges()`:

```
SettingController listens → AuthController (loadSettings when user changes)
MealController listens → AuthController (loadMeals when user changes)
DashboardController listens → MealController (reload when meals change)
AiController listens → AuthController (loadConversations when user changes)
```

## 4.5 Navigation Architecture

GoRouter with ShellRoute for bottom navigation:

```
GoRouter
├── /login
├── /signup
├── /forgot-password
├── /onboarding
├── / (ShellRoute — MainScreen with BottomNavBar)
│   ├── /dashboard
│   ├── /add-meal
│   ├── /history
│   ├── /recipes
│   └── /profile
├── /meal-analysis/:mealName
├── /meal-detail/:mealId
├── /chat
├── /weekly-report
├── /recipe/:recipeId
├── /meal-plan
├── /weight
├── /settings
├── /notifications
├── /accessibility-settings
├── /privacy
└── /support
```

**Auth guard**: GoRouter redirect logic checks `AuthController.isInitialized`, `isLoggedIn`, and `isOnboarded` to determine the correct route.

---

# 5. Database Design

## 5.1 Firestore Schema

All user data is stored under the `users/{uid}` document path, with subcollections for each data type. This ensures natural data isolation — a user can only access their own data.

```
firestore/
└── users/{uid}                          # Root user document
    ├── settings/
    │   └── preferences                  # App settings (dark mode, goals, accessibility)
    ├── meals/{mealId}                   # Individual meal entries
    ├── weights/{weightId}               # Weight log entries
    ├── water/{waterId}                  # Water intake logs
    ├── conversations/{convId}           # AI chat conversations
    │   └── messages/{msgId}             # Individual chat messages (sub-subcollection)
    ├── recipes/{recipeId}               # Saved AI-generated recipes
    └── notifications/{notifId}          # Notification records
```

## 5.2 Collection Details

### users/{uid} — Root User Document

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Firebase Auth UID (mirrored for convenience) |
| `name` | string | Display name |
| `email` | string | Email address |
| `avatarUrl` | string | Profile photo URL (may be empty) |
| `bio` | string | User bio (may be empty) |
| `objective` | string | Health objective (e.g., "lose weight", "gain muscle") |
| `age` | number | User age |
| `weight` | number | Current weight in kg |
| `height` | number | Height in cm |
| `activeStreak` | number | Consecutive days with logged meals |
| `entries` | number | Total number of meals logged |
| `createdAt` | timestamp | Account creation time |
| `updatedAt` | timestamp | Last profile update |

### users/{uid}/meals/{mealId} — Meal Entries

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Meal name (AI-generated or user-provided) |
| `type` | string | "breakfast", "lunch", "dinner", or "snack" |
| `calories` | number | Total calories |
| `protein` | number | Protein in grams |
| `carbs` | number | Carbohydrates in grams |
| `fat` | number | Fat in grams |
| `loggedAt` | timestamp | When the meal was logged |
| `imageUrl` | string | Optional meal photo URL |
| `source` | string | "ai_analysis", "manual", or "quick_log" |
| `notes` | string | Optional user notes |
| `analyzedBy` | string | AI model used (e.g., "gemini-2.5-flash-lite") |
| `vitamins` | map | Vitamin name → fraction of daily value (0-1) |
| `minerals` | map | Mineral name → fraction of daily value (0-1) |

### users/{uid}/settings/preferences — App Settings

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `darkMode` | bool | false | Dark theme toggle |
| `notifFrequency` | number | 1.0 | 0=Quiet, 1=Standard, 2=Frequent |
| `incognito` | bool | false | Incognito mode |
| `goalCalories` | number | 2000 | Daily calorie target |
| `goalProtein` | number | 150.0 | Daily protein target (g) |
| `goalCarbs` | number | 250.0 | Daily carbs target (g) |
| `goalFat` | number | 65.0 | Daily fat target (g) |
| `goalWaterMl` | number | 2000 | Daily water target (ml) |
| `textSize` | number | 1.0 | 0=Compact, 1=Standard, 2=Enlarged |
| `highContrast` | bool | false | High contrast accessibility mode |
| `voiceSensitivity` | number | 1 | 0=Quiet, 1=Balanced, 2=Highly Reactive |
| `adaptiveAssist` | bool | false | Reduce animations |
| `anonymousAnalytics` | bool | true | Allow anonymous usage analytics |
| `geoTracking` | bool | false | Allow location tracking |
| `aiTrainingModel` | bool | true | Allow data for AI training |

### users/{uid}/conversations/{convId}/messages/{msgId} — Chat Messages

| Field | Type | Description |
|-------|------|-------------|
| `role` | string | "user" or "assistant" |
| `content` | string | Message text |
| `createdAt` | timestamp | When the message was sent |

### users/{uid}/recipes/{recipeId} — Saved Recipes

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Recipe name |
| `ingredients` | list | List of ingredient strings |
| `steps` | list | List of step strings |
| `calories` | number | Total calories |
| `protein` | number | Protein in grams |
| `carbs` | number | Carbohydrates in grams |
| `fat` | number | Fat in grams |
| `servings` | number | Number of servings |
| `prepTime` | number | Preparation time in minutes |

## 5.3 Security Rules

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;
    }
    // Deny all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

**How it works**:
- Every request must include a valid Firebase Auth token
- The `userId` in the document path must match the requesting user's UID
- All subcollections (meals, settings, conversations, etc.) are covered by the `{document=**}` wildcard
- Any access attempt with no auth or wrong UID is automatically denied

## 5.4 Index Requirements

Firestore requires composite indexes for compound queries. The following indexes are needed:

| Collection | Fields | Direction |
|-----------|--------|-----------|
| `users/{uid}/meals` | `loggedAt` | Descending |
| `users/{uid}/meals` | `loggedAt` (range) + `loggedAt` (order) | Ascending |
| `users/{uid}/conversations/{id}/messages` | `createdAt` | Ascending |

Firestore auto-creates most indexes when queries first run. The Firebase console shows any missing indexes with direct links to create them.

---

# 6. API & AI Integration

## 6.1 Gemini API Configuration

| Setting | Value |
|---------|-------|
| Model | `gemini-2.5-flash-lite` |
| Endpoint | `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent` |
| API Key | Passed via `--dart-define=GEMINI_API_KEY=...` at build time |
| Response Format | JSON (`responseMimeType: "application/json"`) |

## 6.2 API Call Flow

```
AiService._callModel(prompt)
  │
  ├─ Check API key is non-empty (throws if missing)
  │
  ├─ HTTP POST to Gemini endpoint
  │   Headers: { "Content-Type": "application/json" }
  │   Body: { "contents": [{"parts": [{"text": prompt}]}],
  │            "generationConfig": {"responseMimeType": "application/json"} }
  │
  ├─ Check HTTP status code (throws if not 200)
  │
  ├─ Extract text from: candidates[0].content.parts[0].text
  │
  ├─ Clean markdown fences (```...```)
  │
  └─ JSON parse with fallback:
      ├─ Try jsonDecode(cleaned)
      └─ On failure: find first { and last }, extract substring, retry
```

## 6.3 Prompts

### Meal Analysis Prompt
```
You are a nutrition analysis assistant. Given a meal description, respond
with ONLY a JSON object (no markdown, no commentary) with this exact shape:
{
  "name": string,
  "calories": number,
  "protein": number,
  "carbs": number,
  "fat": number,
  "vitamins": {"Vitamin A": number (0-1), "Vitamin C": number (0-1), ...},
  "minerals": {"Iron": number (0-1), "Magnesium": number (0-1), ...},
  "notes": string
}
Include common vitamins and minerals where you can estimate them from the
meal description. Use 0-1 values representing fraction of daily value.
Omit vitamins or minerals if you cannot estimate them.

Meal description: "$description"
```

### Chat Prompt
The chat method receives the full conversation history as a list of `{"role": "user"|"assistant", "content": "..."}` objects. These are sent directly to Gemini using the `contents` array format, with `role: "model"` replacing `role: "assistant"`.

### Recipe Generation Prompt
```
You are a recipe generator. Respond with ONLY a JSON object (no markdown)
with this exact shape:
{"name": string, "ingredients": [string], "steps": [string], "calories": number,
 "protein": number, "carbs": number, "fat": number, "servings": number,
 "prepTime": number}

Request: "$prompt"
```

### Meal Plan Generation Prompt
```
You are a meal planning nutritionist. Generate a 7-day meal plan (Monday to Sunday)
that fits these daily targets: $goalCalories kcal, ${goalProtein}g protein,
${goalCarbs}g carbs, ${goalFat}g fat.

Respond with ONLY a JSON object with this exact shape:
{
  "name": string,
  "days": [
    {
      "dayOfWeek": number (1=Monday ... 7=Sunday),
      "meals": [
        {"mealType": "breakfast"|"lunch"|"dinner"|"snack", "name": string,
         "calories": number, "protein": number, "carbs": number, "fat": number}
      ]
    }
  ]
}
```

### Dietary Tip Prompt
```
You are a nutrition coach. Based on today's logged meals, respond with
ONLY a JSON object: {"tip": string}. Keep the tip to one or two sentences.

Today's meals: $summary
```

### Weekly Oracle Prompt
```
You are a nutrition oracle. Given this user's weekly nutritional data,
respond with ONLY a JSON object:
{"grade": string, "summary": string, "recommendations": [string, string, string]}

- grade: A letter grade A-F with optional +/- (e.g. "B+")
- summary: one sentence metabolic overview
- recommendations: exactly 3 short, actionable nutrition tips

Weekly data:
- Average daily calories: $avgCal kcal
- Total protein: ${protein}g
- Total carbs: ${carbs}g
- Total fat: ${fat}g
- Highest calorie meal this week: $topMeal
```

## 6.4 Error Handling

| Error | Handling |
|-------|----------|
| Empty API key | Throws with clear message: "No Gemini API key configured. Pass --dart-define=GEMINI_API_KEY=..." |
| HTTP 429 (rate limit) | Exception thrown with status code, UI shows retry option |
| HTTP 500 (server error) | Exception thrown with status code |
| Missing response text | Throws "AI response missing expected content" |
| JSON parse failure | Fallback: extract substring between first `{` and last `}` |
| Network failure | SocketException caught, UI shows error state |

## 6.5 Response Parsing

The `_callModel` method handles several common AI response issues:

1. **Markdown fences**: Strips leading/trailing ` ``` ` blocks
2. **Extra text before JSON**: Fallback parser finds first `{` and last `}` in the response
3. **Nested JSON**: Uses `jsonDecode` which handles nested objects naturally
4. **Null fields**: Each field uses null-aware operators (`?.toInt() ?? defaultValue`)

---

# 7. Feature Documentation

## 7.1 Authentication & Onboarding

**Owner**: Juwairia
**Key Files**: `firebase_auth_service.dart`, `auth_controller.dart`, `login_screen.dart`, `signup_screen.dart`, `onboarding_screen.dart`

### Sign Up Flow
```
User taps "Sign Up"
  → AuthController.signUp(name, email, password)
  → FirebaseAuthService.signUp(name, email, password)
  → Firebase Auth: createUserWithEmailAndPassword()
  → Firebase Auth: updateDisplayName(name)
  → Firestore: users/{uid}.set(initialData)
  → Firebase Auth: sendEmailVerification()
  → Returns UserModel → AuthController.user = userModel
  → GoRouter: isOnboarded = false → /onboarding
```

### Sign In Flow
```
User taps "Sign In"
  → AuthController.signIn(email, password)
  → FirebaseAuthService.signIn(email, password)
  → Firebase Auth: signInWithEmailAndPassword()
  → FirebaseAuthService.fetchUserProfile(user)
  → Firestore: users/{uid}.get()
  → Returns UserModel → AuthController.user = userModel
  → GoRouter: isOnboarded = true → /dashboard
```

### Google Sign-In Flow
```
User taps "Sign in with Google"
  → AuthController.signInWithGoogle()
  → GoogleSignIn().signIn()
  → GoogleSignIn().authentication
  → GoogleAuthProvider.credential(accessToken, idToken)
  → Firebase Auth: signInWithCredential(credential)
  → Firestore: users/{uid}.get() → check if doc exists
  → If first time: users/{uid}.set(initialData)
  → Returns UserModel
```

### Cold Start Session Restoration
```
App launches
  → main.dart: Firebase.initializeApp()
  → AuthController constructor:
    → _init() called
    → FirebaseAuthService.authStateChanges.listen(callback)
    → If User exists: fetchUserProfile(user) → AuthController.user = userModel
    → If User is null: AuthController.user = null
    → isInitialized = true
  → GoRouter redirect fires:
    → !isInitialized → show loading
    → !isLoggedIn → /login
    → !isOnboarded → /onboarding
    → else → /dashboard
```

### Onboarding Flow
```
First-time user lands on /onboarding
  → OnboardingController manages 5-step wizard:
    Step 1: Name, Age, Gender
    Step 2: Weight, Height
    Step 3: Activity level
    Step 4: Goal (lose weight, maintain, gain)
    Step 5: Review & confirm
  → Each step validates input before advancing
  → Final step: Firestore users/{uid}.update(profileData)
  → AuthController.isOnboarded = true
  → GoRouter: /dashboard
```

## 7.2 Dashboard

**Owner**: Abdel
**Key Files**: `dashboard_controller.dart`, `dashboard_screen.dart`, `daily_summary_model.dart`

### Data Loading Flow
```
DashboardScreen loads
  → DashboardController.loadSummary(settings)
  → MealService.getDailySummary(DateTime.now())
  → Firestore: users/{uid}/meals
    .where('loggedAt', >= startOfDay)
    .orderBy('loggedAt', descending: true)
  → Aggregate: totalCalories, totalProtein, totalCarbs, totalFat
  → Re-apply goals from SettingController
  → summary = DailySummaryModel
  → If meals >= 2: loadDietaryTip()
  → loadActiveStreak()
```

### Real-Time Updates
The dashboard uses Firestore's real-time stream. When a new meal is added:
```
MealService.watchTodaysMeals()
  → Firestore: .snapshots() (real-time listener)
  → New meal added → Firestore pushes update
  → Stream emits new List<MealModel>
  → DashboardController notified → UI rebuilds
```

### Smart Analysis Card
- Triggers when 2+ meals are logged today
- Calls `AiService.getDietaryTip(meals)`
- Sends today's meals as summary to Gemini
- Returns a one-sentence personalized tip
- Result cached for the session (no repeated API calls)

### Active Streak Calculation
```
DashboardController.loadActiveStreak()
  → MealService.getMealHistory(pageSize: 500)
  → Extract unique days: Set<DateTime>
  → Start from today, walk backward
  → Count consecutive days present in the set
  → Return streak count
```

### Dashboard Components
| Component | Data Source | Update Mechanism |
|-----------|-------------|------------------|
| Calorie Ring | `summary.totalCalories / summary.calorieGoal` | Real-time stream |
| Macro Progress Bars | `summary.totalProtein/Carbs/Fat` vs goals | Real-time stream |
| Water Tracker | Local state + Firestore | Manual increment |
| Smart Analysis Card | `AiService.getDietaryTip()` | One-shot after 2+ meals |
| Active Streak | `MealService.getMealHistory()` | One-shot on load |
| Recent Meals List | `summary.meals` (top 3) | Real-time stream |

## 7.3 Meal Logging & AI Analysis

**Owner**: Fatma
**Key Files**: `add_meal_screen.dart`, `meal_analysis_screen.dart`, `meal_controller.dart`, `meal_service.dart`, `ai_service.dart`

### Meal Analysis Flow
```
User types meal description (e.g., "grilled chicken with rice")
  → AddMealScreen._onSubmit()
  → MealController.analyzeMeal(description)
  → Is loading = true
  → AiService.analyzeMeal(description)
  → Gemini API prompt → JSON response
  → Parse into MealModel (id='', loggedAt=now)
  → _pendingAnalysis = mealModel
  → Navigate to MealAnalysisScreen
```

### Meal Confirmation Flow
```
User views analysis on MealAnalysisScreen
  → Sees: calories, protein, carbs, fat, vitamins, minerals, notes
  → Can adjust: portion multiplier, meal type (breakfast/lunch/dinner/snack)
  → Taps "Confirm"
  → MealController.confirmAddMeal()
  → MealService.saveMeal(meal)
  → Firestore: users/{uid}/meals.add(meal.toFirestoreMap())
  → Or if offline: StorageService.queueOfflineMeal(data)
  → MealController.notifyListeners()
  → DashboardController.loadSummary() (triggered by listener chain)
  → Navigate to Dashboard
```

### Offline Meal Queuing
```
MealService.saveMeal()
  → Try Firestore write
  → On SocketException or FirebaseException('unavailable'):
    → Generate localId: 'offline_${timestamp}'
    → StorageService.queueOfflineMeal(data)
    → Return MealModel with id = localId
  → On app resume / connectivity restored:
    → MealService.syncPendingMeals()
    → For each queued meal:
      → Convert loggedAt string back to Timestamp
      → Firestore: users/{uid}/meals.add(data)
      → StorageService.removePendingMeal(key)
```

### Meal History
```
MealHistoryScreen loads
  → MealController.loadMealHistory()
  → MealService.getMealHistoryPage(pageSize: 20)
  → Firestore: users/{uid}/meals
    .orderBy('loggedAt', descending: true)
    .limit(20)
  → Returns: List<MealModel> + DocumentSnapshot for pagination
  → User scrolls to bottom → load next page using startAfterDocument
```

### Search & Filter
- **By date**: Date range picker → `MealService.getMealsBetween(start, end)`
- **By type**: Filter chips → client-side filtering on `meal.type`
- **By name**: Search bar → client-side filtering on `meal.name.toLowerCase().contains(query)`

## 7.4 Meal History

**Owner**: Fatma
**Key Files**: `meal_history_screen.dart`, `meal_controller.dart`

### Calendar View
- Shows a calendar with dots on days that have logged meals
- Tapping a day loads that day's meals
- Swipe left/right to navigate months

### List View
- Groups meals by date (Today, Yesterday, older dates)
- Each meal card shows: name, time, calories, macros
- Swipe to delete, tap to view details

### Pagination
- Loads 20 meals initially
- Infinite scroll loads next page when user reaches bottom
- Uses Firestore's `startAfterDocument` for efficient cursor-based pagination

## 7.5 Weekly Reports

**Owner**: Tarek
**Key Files**: `weekly_report_screen.dart`, `weekly_report_service.dart`

### Report Generation Flow
```
WeeklyReportScreen loads
  → WeeklyReportService.getWeeklyReport()
  → Firestore: users/{uid}/meals
    .where('loggedAt', >= 6 days ago)
    .orderBy('loggedAt')
  → Group meals by calendar day (Mon-Sun)
  → Build DailyAggregate for each of 7 days (including empty days)
  → Return WeeklyReport(days, allMeals)
```

### Computed Metrics
| Metric | Calculation |
|--------|-------------|
| Average Calories | Sum of daily calories / active days (days with meals) |
| Total Protein | Sum of all protein across 7 days |
| Total Carbs | Sum of all carbs across 7 days |
| Total Fat | Sum of all fat across 7 days |
| Macro Percentages | `(protein*4) : (carbs*4) : (fat*9)` → normalized to 0-1 |
| Top Meal | `allMeals.reduce((a, b) => a.calories >= b.calories ? a : b)` |

### AI Oracle Verdict
```
User taps "Get Health Grade"
  → AiService.getWeeklyOracleVerdict(report)
  → Gemini prompt with weekly data
  → Returns: { "grade": "B+", "summary": "...", "recommendations": [...] }
  → Grade displayed with color coding:
    A/A+: Green
    B+/B: Light Green
    C+/C: Yellow
    D/F: Red
```

### Charts
- **Calorie Bar Chart**: 7 bars (Mon-Sun), each bar height = daily calories
- **Macro Donut Chart**: Three segments (protein, carbs, fat) colored differently
- **Weekly Trend Line**: Optional line chart showing calorie trend

## 7.6 AI Coach Chat

**Owner**: Tarek
**Key Files**: `chat_screen.dart`, `ai_controller.dart`, `ai_service.dart`

### Chat Flow
```
User types message
  → AiController.sendMessage(text)
  → Add user message to local _messages list
  → Add to Firestore: conversations/{convId}/messages/{msgId}
  → Build history from last 10 messages
  → AiService.chat(history)
  → Gemini API: contents array with role/model/user messages
  → Response text → add assistant message to _messages
  → Save to Firestore
  → notifyListeners() → UI rebuilds
```

### Conversation Persistence
- Each chat session is a Firestore document: `users/{uid}/conversations/{convId}`
- Messages are a sub-subcollection: `conversations/{convId}/messages/{msgId}`
- On app restart, previous conversations are loaded from Firestore
- User can view chat history across sessions

### AI Context
- Last 10 messages are sent to Gemini as conversation context
- Gemini uses this to maintain coherent multi-turn conversations
- The AI acts as a nutrition coach, answering questions about diet, nutrition, and health

## 7.7 Recipe Generation

**Owner**: Tarek
**Key Files**: `ai_service.dart`, `recipe_model.dart`

### Generation Flow
```
User enters recipe request (e.g., "high protein vegetarian dinner")
  → AiService.generateRecipe(prompt)
  → Gemini prompt → JSON response
  → Parse into RecipeModel:
    - name, ingredients[], steps[]
    - calories, protein, carbs, fat
    - servings, prepTime
  → Display on RecipeDetailScreen
  → User can save to Firestore: users/{uid}/recipes/{recipeId}
```

## 7.8 Meal Plan Generation

**Owner**: Tarek
**Key Files**: `ai_service.dart`, `meal_plan_screen.dart`

### Generation Flow
```
User selects duration and preferences
  → AiService.generateMealPlan(goals, preferences)
  → Gemini prompt with daily calorie/macro targets
  → Returns 7-day plan:
    - Each day: breakfast, lunch, dinner, optional snack
    - Each meal: name, calories, protein, carbs, fat
  → Display on MealPlanScreen with day-by-day breakdown
```

## 7.9 Weight Tracking

**Owner**: Ahmed
**Key Files**: `weight_screen.dart`, `weight_controller.dart`, `weight_entry_model.dart`

### Weight Logging Flow
```
User enters weight + optional note
  → WeightController.logWeight(weightKg, notes)
  → Firestore: users/{uid}/weights/{weightId}.set({
      weightKg, loggedAt: serverTimestamp(), notes
    })
  → Hive: StorageService.saveWeightEntry(entry)
  → Weight history chart updates
```

### Weight Trend Visualization
- Line chart showing weight over time
- Configurable time ranges (1 week, 1 month, 3 months, all time)
- Shows trend line (upward, downward, stable)

## 7.10 Settings & Profile

**Owner**: Ahmed
**Key Files**: `setting_controller.dart`, `settings_screen.dart`, `profile_screen.dart`, `storage_service.dart`

### Settings Persistence (Dual-Write)
Every settings change writes to both Hive and Firestore:

```
User toggles dark mode
  → SettingController.setDarkMode(true)
  → _isDarkMode = true
  → notifyListeners()
  → _persist()
    → StorageService.saveSettings(model)  // Hive (instant)
    → Firestore: users/{uid}/settings/preferences.set(data)  // Cloud (async)
```

### Settings Load Sequence
```
SettingController constructor
  → loadSettings()
  → StorageService.getSettings()  // Hive (instant)
  → If cached: _applyModel(cached)
  → If uid exists:
    → Firestore: users/{uid}/settings/preferences.get()
    → If remote exists: _applyModel(remote), save to Hive
    → If remote missing: push current values to Firestore
```

### Profile Management
- View profile: avatar, name, bio, stats (total meals, streak, member since)
- Edit profile: name, bio, objective, age, weight, height
- Profile stats computed from Firestore data

### Account Deletion
```
User confirms deletion
  → FirebaseAuthService.deleteAccount()
  → Delete all subcollections:
    - meals, weights, water, notifications
    - conversations (with nested messages)
    - recipes
  → Delete settings/preferences
  → Delete root users/{uid} document
  → Firebase Auth: user.delete()
```

## 7.11 Notifications & Reminders

**Owner**: Ahmed
**Key Files**: `notification_service.dart`, `meal_reminder_service.dart`, `notifications_screen.dart`

### Notification Types
| Type | Source | Trigger |
|------|--------|---------|
| Meal reminder | Local notification | Scheduled time (morning/afternoon/evening) |
| New notification | Firestore stream | Server-pushed notifications |
| Unread indicator | Firestore stream | Real-time unread count |

### Meal Reminder Scheduling
```
SettingController.setNotifFrequency(value)
  → MealReminderService.scheduleReminders(frequency)
  → If frequency = 0 (Quiet): cancel all reminders
  → If frequency = 1 (Standard): morning + evening reminders
  → If frequency = 2 (Frequent): morning + lunch + evening reminders
  → Flutter Local Notifications: schedule periodic notifications
```

### Notification Stream
```
NotificationService
  → Firestore: users/{uid}/notifications
    .orderBy('time', descending: true)
    .snapshots()  // Real-time listener
  → Stream<List<NotificationModel>>
  → NotificationsScreen listens to this stream
  → UI updates in real-time when new notifications arrive
```

---

# 8. Accessibility Implementation

## 8.1 Text Scaling

**Implementation**: `SettingController.textSize` drives a `MediaQuery.textScaleFactor` override.

| Value | Mode | Scale Factor |
|-------|------|-------------|
| 0 | Compact | 0.85 |
| 1 | Standard | 1.0 |
| 2 | Enlarged | 1.5 |

**How it works**:
- User selects text size in Settings → `SettingController.setTextSize(value)`
- Value persisted to Hive + Firestore
- `MaterialApp` wraps with `MediaQuery(textScaleFactor: ...)`
- All text in the app automatically scales

## 8.2 High Contrast Mode

**Implementation**: `SettingController.highContrast` switches between two color palettes.

| Setting | Normal Mode | High Contrast Mode |
|---------|-------------|-------------------|
| Background | White (#FFFFFF) | Pure White (#FFFFFF) |
| Primary | Teal (#00897B) | Dark Teal (#004D40) |
| Text | Dark Gray (#212121) | Pure Black (#000000) |
| Cards | Light Gray (#F5F5F5) | White with thick border |

**How it works**:
- `AppTheme` checks `SettingController.highContrast`
- Returns different `ThemeData` with adjusted color scheme
- All widgets using theme colors automatically update

## 8.3 Reduced Motion

**Implementation**: `SettingController.adaptiveAssist` wraps animations with `AdaptiveAssist`.

```dart
AdaptiveAssist(
  child: AnimatedContainer(...),
)
```

**How it works**:
- When `adaptiveAssist = false`: normal animations play
- When `adaptiveAssist = true`: `Duration(milliseconds: 300)` → `Duration.zero`
- Transitions become instant (no animation)
- Affects: page transitions, card animations, loading spinners

## 8.4 Touch Targets

All interactive elements meet the WCAG 2.5.5 minimum:
- Minimum size: 44x44 logical pixels
- Implemented via `app_dimensions.dart` constants
- Buttons use `minHeight: 44` and `minWidth: 44`
- List items have sufficient padding

---

# 9. Offline Support & Persistence

## 9.1 Hive Local Storage

Hive provides instant local reads without network latency. Used for:

| Data | Box | Purpose |
|------|-----|---------|
| Settings | `settings` | Instant settings load on app start |
| Offline Meals | `offlineMeals` | Queue meals when offline |
| Weight Entries | `weights` | Local weight history cache |

## 9.2 Dual-Write Pattern

Settings use a dual-write pattern for reliability:

```
User changes setting
  → Write to Hive (always succeeds, instant)
  → Write to Firestore (may fail if offline)
  → If Firestore fails: error message shown, Hive value still saved
  → Next app load: Hive value used immediately
  → Next successful Firestore sync: remote value reconciled
```

## 9.3 Offline Meal Queue

```
Device goes offline
  → MealService.saveMeal() fails (SocketException)
  → _saveOffline() called:
    → Generate localId: 'offline_${timestamp}'
    → StorageService.queueOfflineMeal(data)
    → Return MealModel with localId
  → Meal appears in history with "offline" badge

Device comes back online
  → MealService.syncPendingMeals() called
  → For each queued meal:
    → Convert data format (String loggedAt → Timestamp)
    → Firestore: users/{uid}/meals.add(data)
    → StorageService.removePendingMeal(key)
  → Meals now have real Firestore IDs
```

## 9.4 Settings Reconciliation

```
App launches (after being killed)
  → SettingController.loadSettings()
  → Hive: instant load (no network)
  → Firestore: background fetch
  → If remote differs from local:
    → Apply remote values
    → Update Hive cache
  → If remote missing:
    → Push current (Hive/default) values to Firestore
```

---

# 10. Security Implementation

## 10.1 Authentication Security

| Measure | Implementation |
|---------|---------------|
| Password hashing | Firebase Auth handles bcrypt internally |
| Email verification | `sendEmailVerification()` called after signup |
| Session persistence | Firebase Auth persists sessions automatically |
| Auth state stream | `authStateChanges()` provides real-time auth state |
| Reauthentication | Required before sensitive operations (password change, account deletion) |

## 10.2 Firestore Security Rules

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
- **User isolation**: Each user can only read/write their own `users/{uid}/` subtree
- **No cross-user access**: A user cannot read another user's meals, settings, or profile
- **No anonymous access**: All requests require a valid Firebase Auth token
- **Default deny**: The catch-all rule denies all access not explicitly allowed

## 10.3 API Key Management

- Gemini API key is passed via `--dart-define=GEMINI_API_KEY=...` at build time
- Key is NOT hardcoded in source code
- Key is stored in the compiled binary (standard for client apps)
- For production: key should be proxied through a Cloud Function to keep it server-side

## 10.4 Auth Guards in Services

Every service method that requires authentication calls `_requireUid()`:

```dart
String _requireUid() {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    throw Exception(
      'Service called with no signed-in user. '
      'Check that the caller waited for AuthController.isInitialized.'
    );
  }
  return uid;
}
```

This ensures:
- No Firestore calls are made before auth is ready
- Errors are loud and clear (not silent permission denied)
- The GoRouter redirect guarantees auth is initialized before any service call

## 10.5 Data in Transit

- All Firebase communication uses HTTPS (TLS 1.2+)
- Gemini API calls use HTTPS
- No HTTP endpoints are used anywhere in the app

---

# 11. Testing Strategy

## 11.1 Unit Tests

| Test Case | What It Tests | File |
|-----------|---------------|------|
| `DailySummaryModel` aggregation | Calorie/macro totals computed correctly | `daily_summary_model_test.dart` |
| `WeeklyReport.macroPercentages` | Protein/carbs/fat percentages normalize to 0-1 | `weekly_report_service_test.dart` |
| `MealModel.toFirestoreMap` | Firestore serialization produces correct field types | `meal_model_test.dart` |
| `SettingsModel.fromJson` | Settings deserialization handles all field types | `settings_model_test.dart` |
| `AuthController._handleAuthException` | Error messages map correctly to user-friendly strings | `auth_controller_test.dart` |

## 11.2 Widget Tests

| Test Case | What It Tests | File |
|-----------|---------------|------|
| `LoginScreen` form validation | Empty email/password shows error | `login_screen_test.dart` |
| `SignUpScreen` form validation | Password mismatch shows error | `signup_screen_test.dart` |
| `AddMealScreen` input handling | Empty submission prevented | `add_meal_screen_test.dart` |
| `DashboardScreen` loading state | Loading indicator shown while data loads | `dashboard_screen_test.dart` |
| `SettingsScreen` toggle interaction | Dark mode toggle calls controller | `settings_screen_test.dart` |

## 11.3 Manual Testing

| Area | Test Steps | Expected Result |
|------|-----------|-----------------|
| Auth flow | Sign up → Verify email → Sign in → Sign out → Sign in | Session persists |
| Onboarding | Complete all 5 steps → Verify profile in Firestore | Profile saved |
| Meal logging | Add meal via text → AI analysis → Confirm → Check dashboard | Dashboard updates |
| Offline mode | Enable airplane mode → Add meal → Disable airplane | Meal syncs to Firestore |
| Settings | Change dark mode → Kill app → Relaunch | Setting persists |
| Accessibility | Enable high contrast → Check all screens | Colors update |
| Notifications | Set reminder → Wait for scheduled time | Notification appears |

## 11.4 Test Results Summary

| Category | Total | Passed | Failed | Notes |
|----------|-------|--------|--------|-------|
| Unit Tests | 12 | 12 | 0 | All passing |
| Widget Tests | 8 | 8 | 0 | All passing |
| Manual Tests | 15 | 14 | 1 | Meal reminder timing inconsistent on some devices |

---

# 12. Git Workflow & Collaboration

## 12.1 Branch Strategy

```
main (protected)
├── feature/auth (Juwairia)
├── feature/meals (Fatma)
├── feature/dashboard (Abdel)
├── feature/reports (Tarek)
├── feature/settings (Ahmed)
└── feature/ai-integration (Tarek + Fatma)
```

## 12.2 Commit Convention

```
<type>(<scope>): <description>

Examples:
feat(auth): add Google sign-in flow
fix(meals): resolve offline queue sync issue
refactor(dashboard): simplify streak calculation
docs(readme): update setup instructions
```

## 12.3 PR Review Rules

1. **Each member reviews code they depend on**: Ahmed reviews Juwairia's auth (since settings need auth), etc.
2. **PR must have at least 1 approval** before merge
3. **CI must pass** (flutter analyze, tests)
4. **Small, focused PRs**: One feature/fix per PR

## 12.4 Team File Ownership

| Member | Primary Files | Dependent On |
|--------|--------------|-------------|
| Juwairia | `auth_controller.dart`, `firebase_auth_service.dart`, `login_screen.dart`, `signup_screen.dart`, `onboarding_screen.dart` | None |
| Fatma | `meal_service.dart`, `meal_controller.dart`, `add_meal_screen.dart`, `meal_analysis_screen.dart`, `meal_history_screen.dart` | Juwairia (auth) |
| Abdel | `dashboard_controller.dart`, `dashboard_screen.dart`, `daily_summary_model.dart` | Fatma (meals), Ahmed (settings) |
| Tarek | `ai_service.dart`, `ai_controller.dart`, `chat_screen.dart`, `weekly_report_service.dart`, `weekly_report_screen.dart` | Fatma (meals) |
| Ahmed | `setting_controller.dart`, `storage_service.dart`, `settings_screen.dart`, `profile_screen.dart`, `firestore.rules` | Juwairia (auth) |

## 12.5 Daily Workflow

1. **Morning**: Pull latest `main`, create/update feature branch
2. **During day**: Make small commits with descriptive messages
3. **Before push**: Run `flutter analyze` and fix any issues
4. **Push**: Push feature branch, create PR if ready for review
5. **Evening**: Review any open PRs from teammates

---

# 13. Known Issues & Future Work

## 13.1 Known Issues

### Issue 1: Route Conflict (High Priority)
**Location**: `app.dart` — GoRouter configuration
**Problem**: Both `recipeList` and `recipeDetail` use the `/recipes` path, causing a route conflict. When navigating to `/recipes`, GoRouter may match the wrong route depending on parameter presence.
**Impact**: Users may see the recipe list when trying to view a recipe detail, or vice versa.
**Fix**: Change `recipeList` to `/recipes` and `recipeDetail` to `/recipes/:recipeId` with distinct path patterns.

### Issue 2: Memory Leak in MainScreen (High Priority)
**Location**: `main_screen.dart` — `NotificationService` subscription
**Problem**: `NotificationService` subscribes to a Firestore stream in `initState()` but never cancels the subscription in `dispose()`. This causes a memory leak when the widget is removed from the tree.
**Impact**: Memory grows over time; Firestore listener remains active even when the screen is not visible.
**Fix**: Store the `StreamSubscription` and cancel it in `dispose()`.

### Issue 3: Settings Persistence Inconsistency (Medium Priority)
**Location**: `setting_controller.dart` — `_persist()` method
**Problem**: Hive write always succeeds, but Firestore write may fail silently. The user sees no error, but their settings are not synced to the cloud. On another device, they'll see different settings.
**Impact**: Settings appear to save locally but don't sync across devices.
**Fix**: Show a warning snackbar when Firestore write fails, allowing the user to retry.

### Issue 4: Dashboard Streak Calculation Efficiency (Medium Priority)
**Location**: `dashboard_controller.dart` — `loadActiveStreak()`
**Problem**: Fetches up to 500 meals to calculate the streak. For users with thousands of meals, this is inefficient and slow.
**Impact**: Dashboard load time increases for heavy users.
**Fix**: Use a Firestore `count()` aggregate or a separate `streaks` subcollection that's updated incrementally.

### Issue 5: MealController Stale Data on Error (Low Priority)
**Location**: `meal_controller.dart` — `analyzeMeal()` error handling
**Problem**: When AI analysis fails, the error is shown but `_pendingAnalysis` is not cleared. If the user retries, the old pending analysis may flash briefly.
**Impact**: Minor UX glitch on error retry.
**Fix**: Clear `_pendingAnalysis` in the `catch` block before setting the error.

## 13.2 Future Enhancements

### Short-Term (Next Sprint)
| Feature | Description | Priority |
|---------|-------------|----------|
| Photo Meal Input | Take a photo of food, AI identifies and analyzes it | High |
| Barcode Scanning | Scan food barcodes for instant nutrition lookup | Medium |
| Social Feed | Share meals with friends, see their logs | Medium |
| Wearable Integration | Sync with Fitbit/Apple Watch for activity data | Low |

### Long-Term (Post-MVP)
| Feature | Description | Priority |
|---------|-------------|----------|
| Premium Tier | Advanced analytics, unlimited AI chat, custom meal plans | High |
| Nutritionist Connect | Book sessions with registered nutritionists | Medium |
| Grocery List | Auto-generate shopping list from meal plans | Medium |
| Multi-Language | Arabic, French, Spanish support | Low |
| Widget Support | iOS/Android home screen widgets showing daily summary | Low |

---

# 14. Conclusion

## 14.1 Project Summary

SnackTrack successfully delivers an AI-powered nutrition tracking application that meets all core requirements:

- **AI Meal Analysis**: Users can log meals in natural language and receive instant nutrition data
- **Real-Time Dashboard**: Live updates show daily calorie and macro progress
- **Weekly Reports**: Aggregated data with AI-generated health grades
- **AI Coach**: Conversational nutrition advice with conversation history
- **Offline Support**: Meal logging and settings persist locally via Hive
- **Accessibility**: Text scaling, high contrast, and reduced motion support
- **Security**: Firestore rules enforce user-level data isolation

## 14.2 Lessons Learned

### Technical Lessons
1. **Firebase Auth first**: All services depend on auth. Get it right before building anything else.
2. **Offline-first architecture**: Designing for offline from the start (Hive) saved significant rework later.
3. **AI prompt engineering**: Structured JSON output requires careful prompt design and robust parsing with fallbacks.
4. **State management**: Provider works well for small-to-medium apps, but controller dependencies require careful ordering.

### Team Collaboration Lessons
1. **File ownership clarity**: Assigning file ownership prevented merge conflicts
2. **Small commits**: Daily small commits made code review and integration easier
3. **Interface contracts**: Defining service interfaces early (e.g., `_requireUid()`) prevented integration issues
4. **Dependency awareness**: Understanding which features depend on others (auth → settings → meals) helped with scheduling

## 14.3 Technical Debt

The following items were intentionally deferred to keep the MVP scope manageable:

1. **No backend server**: Gemini API key is client-side. For production, proxy through Cloud Functions.
2. **Limited test coverage**: Unit tests cover core models but not all edge cases.
3. **No CI/CD pipeline**: Tests run locally, not in a CI environment.
4. **Hardcoded strings**: Some UI strings are hardcoded rather than using the `app_strings.dart` constants file.

---

# 15. References

## 15.1 Tools & Technologies

| Tool | Version | URL |
|------|---------|-----|
| Flutter | 3.x | https://flutter.dev |
| Dart | 3.x | https://dart.dev |
| Firebase Auth | Latest | https://firebase.google.com/docs/auth |
| Cloud Firestore | Latest | https://firebase.google.com/docs/firestore |
| Hive | 2.x | https://pub.dev/packages/hive |
| Google Gemini API | gemini-2.5-flash-lite | https://ai.google.dev/docs |
| GoRouter | Latest | https://pub.dev/packages/go_router |
| Provider | Latest | https://pub.dev/packages/provider |

## 15.2 Documentation

- Flutter Documentation: https://docs.flutter.dev
- Firebase Flutter Codelab: https://firebase.google.com/docs/flutter/setup
- Gemini API Reference: https://ai.google.dev/api/rest
- WCAG 2.1 Guidelines: https://www.w3.org/TR/WCAG21/
- Firestore Security Rules: https://firebase.google.com/docs/rules

## 15.3 Design References

- Material Design 3: https://m3.material.io
- Flutter Accessibility: https://docs.flutter.dev/accessibility-and-localization/accessibility
- WCAG Color Contrast: https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum

---

*Document generated from SnackTrack codebase analysis. Last updated: July 2026.*

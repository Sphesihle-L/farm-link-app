# FarmLink 

FarmLink is a mobile application designed to bridge the gap between farmers looking for temporary extra hands during harvesting/planting seasons, and local community members seeking short-term employment.

## Features
*   **Role-Based Access:** Users can sign up and log in as either a **Worker** (looking for work) or a **Farmer** (looking to hire).
*   **For Farmers:** 
    *   Post detailed job listings (dates, pay, requirements).
    *   Preview job posts before publishing.
    *   View a dashboard with stats (open jobs, total applicants).
    *   Review applicants and select/decline workers.
*   **For Workers:**
    *   Browse nearby available jobs.
    *   View full job details and apply.
    *   Track application statuses (Pending, Selected, Declined).
*   **Profiles:** Both roles have a customizable profile hub with quick links to edit their details, skills, and preferences.

## 🛠️ Tech Stack
*   **Framework:** Flutter (Dart)
*   **State Management:** Provider
*   **Local Database (Prototype):** `shared_preferences` (Stores data locally in the browser via Local Storage for testing).
*   **Architecture:** Service Pattern. The UI is completely decoupled from the database using a `DataService` interface, making it easy to swap to a cloud database (like Firebase or Supabase) in the future without rewriting the UI.

##  Project Structure
```text
lib/
│
├── models/          # Data blueprints (AppUser, Job, JobApplication)
├── services/        # Database logic (DataService interface & LocalDataService)
├── theme.dart       # Global colors, typography, and UI styling
│
└── screens/         # All app screens grouped by feature
    ├── auth/        # Login, Register, Account Type
    ├── farmer/      # Farmer Dashboard, Post Job, Job Preview
    ├── worker/      # Worker Dashboard, Job Details
    └── shared/      # Splash Screen, Profile, Edit Profile

    ##  Used Commands
    flutter clean
    flutter pub get
    flutter run -d web-server --web-port 5555

R for hot reload
h list all available interactive commands
d Detach (Terminate "flutter run" but leave application running")
c Clear the Screen
q Quit (terminates the application on the device).

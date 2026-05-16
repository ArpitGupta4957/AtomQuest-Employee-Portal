<div align="center">

# 🚀 AtomQuest HRMS – Set Goals. Track Progress. Drive Performance.

**A production-grade, role-based performance management portal for modern teams.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev/)
[![Provider](https://img.shields.io/badge/State-Provider-6.1.2-8E44AD)](https://pub.dev/packages/provider)
[![Supabase](https://img.shields.io/badge/Supabase-Postgres-3FCF8E?logo=supabase&logoColor=white)](https://supabase.com/)
[![Material 3](https://img.shields.io/badge/Design-Material%203-6750A4?logo=materialdesign&logoColor=white)](https://m3.material.io/)
![Flutter CI](https://github.com/<YOUR_USERNAME>/<YOUR_REPO_NAME>/actions/workflows/flutter.yml/badge.svg)

*Role-based Dashboards • Real-time Sync • OKR Tracking • BRD-Compliant Formulas • Analytics*

</div>

---

## 🎯 Overview

AtomQuest is a clean-architecture Flutter application designed for organizations to seamlessly manage employee goals, quarterly check-ins, and performance reviews. Built specifically to eliminate manual tracking methods, the portal provides distinct, secure user journeys for Employees, Managers, and Admins. With robust real-time PostgreSQL synchronization and an intuitive, premium interface, AtomQuest brings total clarity and accountability to the performance lifecycle.

---

## 🏗️ App Architecture

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Flutter App UI                                │
│   Splash → Login ─┬→ Role Selection (Demo)                                 │
│                   │                                                        │
│                   ├→ Employee Shell ─┬→ Dashboard & Notifications          │
│                   │                  ├→ Goal Creation (Strict Constraints) │
│                   │                  └→ Quarterly Check-ins                │
│                   │                                                        │
│                   ├→ Manager Shell ──┬→ Team Overview Dashboard            │
│                   │                  ├→ Check-in Reviews & Feedback        │
│                   │                  └→ Goal Approval / Inline Editing     │
│                   │                                                        │
│                   └→ Admin Shell ────┬→ Organization Analytics (fl_chart)  │
│                                      └→ Shared Goal Rollouts (Top-down)    │
└──────────────────────────────────┬────────────────────────────────────────┘
                                   │
                     Provider State Layer
              (AuthProvider, GoalProvider, NotificationProvider)
                                   │
                   ┌───────────────┼───────────────┐
                   │               │               │
             AuthRepository  GoalRepository  NotificationRepository
             (Auth / Users)  (CRUD / Audit)   (Realtime WebSockets)
                   │               │               │
                   └───────────────┼───────────────┘
                                   │
                             Supabase DB
              (PostgreSQL + RLS Policies + Enums + Audit Logs)
```

---

## ✨ Features

### 🔐 Multi-Role & Demo Mode
- **Three Distinct Journeys:** Securely routed shells for Employees, Managers, and Admins.
- **One-Click Demo Mode:** Easily bypass authentication to test all 3 organizational roles seamlessly during presentations.

### 🎯 Strict Goal Engineering
- **Real-time Validation:** Enforces business logic (e.g., exactly 100% total weightage, min 10% per individual goal, max 8 goals).
- **BRD-Compliant UoM Formulas:** Progress automatically calculated based on Numeric, Percentage, Timeline, and Zero-Based matrices.
- **Top-Down OKRs:** Admins can push shared organizational goals down to specific departments.

### 📈 Quarterly Check-ins & Approvals
- **Scheduled Windows:** UI enforcement restricting check-in submissions to specific months (Q1=July, Q2=Oct, etc).
- **Manager Workflows:** Dedicated interfaces for managers to approve/reject goals, dynamically edit weightages inline, and leave structured feedback on check-ins.
- **Status Tracking:** Dropdowns for explicit tracking states (Not Started, On Track, Completed).

### 📊 Analytics & Reporting
- **Interactive Dashboards:** Utilizes `fl_chart` for dynamic bar charts visualizing department-wide completion rates.
- **CSV Export:** Mock-ready one-click download buttons for Achievement Reports.
- **Live Notifications:** WebSockets listen to database `INSERT` events to alert users of approvals and check-in reminders instantly.

### 🛡️ Enterprise Security & Data Integrity
- **Audit Trails:** Repository automatically writes to an `audit_logs` table tracking who created, approved, or edited specific goals.
- **Row Level Security (RLS):** Supabase policies strictly prevent employees from viewing cross-department data unless authorized.
- **Secret Management:** `.env` integration keeping API keys securely out of version control.

---

## 🛠️ Technology Stack

| Category | Technology |
|---|---|
| **Framework** | Flutter (latest stable, null-safe) |
| **State Management** | Provider (ChangeNotifier) |
| **Backend / DB** | Supabase (`supabase_flutter` for Auth, DB, Realtime) |
| **Data Visualization** | `fl_chart` |
| **Routing** | `go_router` (Nested ShellRoutes) |
| **Design System** | Custom Material 3 (AppColors, AppTypography, AppSpacing) |

---

## 📁 Project Structure

```text
lib/
 ├── main.dart                              # App entry point + DotEnv Init
 ├── core/
 │   ├── models/                            # Domain entities (Goal, User, Enums)
 │   ├── providers/                         # State Management layer
 │   ├── repositories/                      # Data access layer (Supabase calls)
 │   ├── routing/                           # go_router configuration
 │   ├── services/                          # Supabase initialization
 │   └── theme/                             # Design System tokens
 ├── features/
 │   ├── auth/                              # Login & Role Selection
 │   ├── employee/                          # Employee dashboards and forms
 │   ├── manager/                           # Manager team overviews
 │   ├── admin/                             # Analytics and org charts
 │   └── splash/                            # Loading screen
 └── shared_widgets.dart                    # Reusable KPI cards, Status Chips
```

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (latest stable)
- A Supabase Project (If using the live database instead of Demo Mode)

### 1) Install dependencies

```bash
flutter pub get
```

### 2) Configure Environment

Create a `.env` file in the root of the project with your Supabase credentials:

```text
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

### 3) Seed the Database (Optional)

If you are setting up a fresh Supabase instance, run the provided SQL scripts in your Supabase SQL Editor:
1. Run `supabase_schema.sql` to build tables, Enums, and RLS policies.
2. Run `supabase_seed_data.sql` to populate dummy departments, users, and goals.

### 4) Run app

```bash
flutter run
```

---

## 🧪 Quality Checks

```bash
flutter analyze    # Static analysis — 0 errors ✅
flutter test       # Core app initialization logic
```

---

<div align="center">

**Built for modern teams.**

Made with ❤️ using Flutter & Supabase

</div>

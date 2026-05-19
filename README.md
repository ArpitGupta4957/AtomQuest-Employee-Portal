<div align="center">

<img src="assets/icons/app_icon.png" alt="AtomQuest Logo" width="80" />

# AtomQuest — Employee Goal Setting & Tracking Portal

### AtomQuest Hackathon 1.0 Submission

**A production-grade, role-based performance management portal built with Flutter & Supabase.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![Supabase](https://img.shields.io/badge/Backend-Supabase-3FCF8E?logo=supabase&logoColor=white)](https://supabase.com/)
[![Provider](https://img.shields.io/badge/State-Provider_6.1-8E44AD)](https://pub.dev/packages/provider)
[![go_router](https://img.shields.io/badge/Routing-go__router_14-FF6B35)](https://pub.dev/packages/go_router)
[![Material 3](https://img.shields.io/badge/Design-Material_3-6750A4?logo=materialdesign&logoColor=white)](https://m3.material.io/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

*Role-Based Dashboards · Real-Time Sync · OKR Tracking · BRD-Compliant Formulas · Audit Trails · CSV Export*

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Live Demo](#-live-demo)
- [Demo Credentials](#-demo-credentials)
- [Features by Role](#-features-by-role)
- [BRD Compliance Checklist](#-brd-compliance-checklist)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Database Schema](#-database-schema)
- [Quick Start](#-quick-start)
- [Environment Setup](#-environment-setup)
- [Deployment](#-deployment)
- [Quality & Testing](#-quality--testing)

---

## 🎯 Overview

AtomQuest is a **full-stack, multi-tenant Goal Setting & Tracking Portal** built to solve the core pain points of fragmented, spreadsheet-driven performance management. The system supports the **complete OKR lifecycle** — from goal creation and manager approval, through quarterly check-ins with Planned vs. Actual tracking, to real-time completion analytics and exportable reports.

The application is fully BRD-compliant with the **AtomQuest Hackathon 1.0** problem statement, implementing all Phase 1 (Goal Creation & Approval) and Phase 2 (Achievement Tracking & Quarterly Check-ins) requirements.

---

## 🌐 Live Demo

> **Deployed URL:** `https://atom-quest-employee-portal.vercel.app`

The portal is accessible in any modern web browser. No installation required.

---

## 🔑 Demo Credentials

Three accounts are pre-seeded in the database, one for each role.

> **Password for all accounts:** `demo1234`

| Role | Email | Access |
|---|---|---|
| 👤 **Employee** | `employee@atomberg.com` | Goal creation, quarterly check-ins, progress tracking |
| 👔 **Manager (L1)** | `manager@atomberg.com` | Team dashboard, goal approvals, check-in reviews |
| 🛡️ **Admin / HR** | `admin@atomberg.com` | Full org analytics, cycle management, audit trails, reports |

> 💡 **Tip:** Log in with the Manager account first and approve the Employee's submitted goals to see the full end-to-end workflow.

---

## ✨ Features by Role

### 👤 Employee

| Feature | Details |
|---|---|
| **Goal Creation** | Create up to 8 goals per cycle with Thrust Area, Title, Description, UoM Type, Target & Weightage |
| **Weightage Validation** | Real-time enforcement: total must equal 100%, minimum 10% per goal, maximum 8 goals |
| **Submit for Approval** | One-click submission workflow to send goals to L1 Manager |
| **Goal Locking** | Approved goals become read-only; edits require Admin unlock |
| **Quarterly Check-ins** | Log actual achievement, select status (Not Started / On Track / Completed), add self-notes |
| **Progress Scoring** | BRD-formula auto-calculation based on UoM Type (Numeric, %, Timeline, Zero-Based) |
| **Notifications** | Real-time alerts for goal approvals, rejections, and check-in reminders |
| **Dashboard** | Personal KPI cards: active goals, overall completion %, current focus widget |

### 👔 Manager (L1)

| Feature | Details |
|---|---|
| **Team Dashboard** | KPI cards for pending approvals, team average completion %, and total active members |
| **Pending Approvals** | List of all team-submitted goals awaiting review with detailed goal metadata |
| **Goal Review Screen** | Inline weightage slider editing, manager feedback text field, Approve / Request Changes actions |
| **Team Overview** | Grouped employee cards with expandable goal-level rows showing planned target, approval status, and Q check-in history |
| **Check-in Review** | Quarter selector, Planned vs. Actual comparison table, structured comment field saved back to Supabase |
| **Audit Logging** | All approval/rejection actions are automatically logged to the audit trail |

### 🛡️ Admin / HR

| Feature | Details |
|---|---|
| **Admin Dashboard** | Quick-action grid with one-click access to all 6 admin modules |
| **Cycle Management** | Configure performance cycle windows (Goal Setting, Q1–Q4 check-in dates) and toggle cycle status |
| **Org Hierarchy** | View and manage user-to-manager reporting lines; assign/reassign managers |
| **Audit Trail** | Full searchable log of all system events: goal created, edited, approved, rejected, unlocked |
| **Goal Unlock** | Override approved/locked goals back to `In Progress` with mandatory reason logging |
| **Organization Analytics** | Live pie chart (goal status distribution) + per-employee check-in completion table powered by real Supabase data |
| **Achievement Report (CSV)** | Export Planned Target vs. Actual Achievement for all employees with one click |
| **Shared Goals** | Push a departmental KPI to multiple employees; recipients adjust only weightage |

---

## ✅ BRD Compliance Checklist

### Phase 1 — Goal Creation & Approval

| Requirement | Status |
|---|---|
| Employee creates goals with Thrust Area, UoM, Target, Weightage | ✅ Implemented |
| Total weightage must equal 100% | ✅ Enforced (real-time validation) |
| Minimum weightage per goal: 10% | ✅ Enforced |
| Maximum goals per employee: 8 | ✅ Enforced |
| Manager (L1) approval workflow with inline editing | ✅ Implemented |
| Goals locked after approval | ✅ Implemented |
| Admin can unlock goals with audit trail | ✅ Implemented |
| Shared goals pushed by Admin/Manager | ✅ Implemented |
| Recipients adjust weightage only (title/target read-only) | ✅ Implemented |

### Phase 2 — Achievement Tracking & Quarterly Check-ins

| Requirement | Status |
|---|---|
| Quarterly achievement input per goal | ✅ Implemented |
| Status per goal: Not Started / On Track / Completed | ✅ Implemented |
| Manager check-in module with Planned vs. Actual view | ✅ Implemented |
| Structured manager check-in comment | ✅ Implemented (saved to DB) |
| BRD progress formula: Min (Numeric/%) | ✅ `Achievement ÷ Target` |
| BRD progress formula: Max (Numeric/%) | ✅ `Target ÷ Achievement` |
| BRD progress formula: Timeline | ✅ Date-based completion % |
| BRD progress formula: Zero-Based | ✅ `If 0 → 100%, else 0%` |

### Reporting & Governance

| Requirement | Status |
|---|---|
| Achievement Report (CSV Export) | ✅ Implemented |
| Completion Dashboard (real-time) | ✅ Implemented |
| Audit Trail (who changed what, when) | ✅ Implemented |
| Cycle Management | ✅ Implemented |
| Org Hierarchy Management | ✅ Implemented |

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                         Flutter Web App                          │
│                                                                  │
│  Splash → Login ──┬→ Employee Shell                              │
│                   │   ├─ Dashboard (KPI + Focus Widget)          │
│                   │   ├─ My Goals (Create / Edit / Submit)       │
│                   │   ├─ Goal Detail (Progress + Check-ins)      │
│                   │   └─ Quarterly Check-in Form                 │
│                   │                                              │
│                   ├→ Manager Shell                               │
│                   │   ├─ Dashboard (Pending Approvals)           │
│                   │   ├─ Team Overview (Planned vs Actual)       │
│                   │   └─ Goal Approval Screen                    │
│                   │                                              │
│                   └→ Admin Shell                                 │
│                       ├─ Dashboard (Quick Actions Grid)          │
│                       ├─ Cycle Management                        │
│                       ├─ Org Hierarchy                           │
│                       ├─ Audit Trail                             │
│                       ├─ Goal Unlock                             │
│                       ├─ Achievement Report (CSV)                │
│                       ├─ Organization Analytics                  │
│                       └─ Shared Goal Management                  │
└──────────────────────────────┬───────────────────────────────────┘
                               │
              ┌────────────────▼────────────────┐
              │      Provider State Layer         │
              │  AuthProvider · GoalProvider      │
              │  NotificationProvider             │
              └────────────────┬────────────────┘
                               │
          ┌────────────────────┼────────────────────┐
          │                    │                     │
   AuthRepository        GoalRepository     NotificationRepository
   (Auth / Users)        (CRUD / Audit)     (Realtime WebSockets)
          │                    │                     │
          └────────────────────┼────────────────────┘
                               │
                    ┌──────────▼──────────┐
                    │     Supabase         │
                    │  PostgreSQL + RLS    │
                    │  Realtime Engine     │
                    │  Audit Logs Table    │
                    └─────────────────────┘
```

---

## 🛠️ Tech Stack

| Category | Technology | Version |
|---|---|---|
| **Framework** | Flutter | 3.x (Stable) |
| **Language** | Dart | 3.x (Null-safe) |
| **State Management** | Provider | 6.1.2 |
| **Routing** | go_router (Nested ShellRoutes) | 14.8.1 |
| **Backend & Auth** | Supabase (PostgreSQL + Auth + Realtime) | 2.5.4 |
| **Charts** | fl_chart | 0.70.2 |
| **Typography** | Google Fonts | 6.2.1 |
| **Date Formatting** | intl | 0.20.2 |
| **UUID Generation** | uuid | 4.5.1 |
| **Responsive Layout** | responsive_framework | 1.5.1 |
| **Environment** | flutter_dotenv | 5.1.0 |
| **Design System** | Custom Material 3 (AppColors, AppTypography, AppSpacing) | — |
| **Hosting** | Vercel | — |

---

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point — DotEnv + Supabase init
│
├── core/
│   ├── models/
│   │   ├── enums.dart                 # All app enums: UserRole, GoalStatus, UoMType, Quarter, ThrustArea
│   │   └── models.dart                # Domain entities: Goal, User, QuarterlyCheckIn, SharedGoal
│   │
│   ├── providers/
│   │   ├── auth_provider.dart         # Auth state, login, logout, role resolution
│   │   ├── goal_provider.dart         # Goal CRUD, optimistic UI, weightage calculations
│   │   └── notification_provider.dart # Realtime notification feed
│   │
│   ├── repositories/
│   │   ├── auth_repository.dart       # Supabase Auth + user profile fetching
│   │   └── goal_repository.dart       # All goal DB operations + audit log writes
│   │
│   ├── routing/
│   │   └── app_router.dart            # go_router config: ShellRoutes per role + redirect guards
│   │
│   ├── services/
│   │   └── supabase_service.dart      # Singleton Supabase client wrapper
│   │
│   ├── theme/
│   │   ├── app_colors.dart            # Full Material 3 color token system
│   │   ├── app_typography.dart        # Type scale (headlineLg → bodySm)
│   │   └── app_spacing.dart           # Spacing constants + breakpoints
│   │
│   ├── utils/
│   │   ├── csv_downloader.dart        # Conditional export bridge (web vs mobile)
│   │   ├── csv_downloader_web.dart    # dart:html CSV download (web only)
│   │   └── csv_downloader_stub.dart   # No-op stub (Android/iOS/desktop)
│   │
│   └── widgets/
│       └── shared_widgets.dart        # KpiCard, StatusChip, AppProgressBar, UserAvatar, EmptyStateWidget
│
├── features/
│   ├── splash/
│   │   └── splash_screen.dart         # Animated loading screen with auth redirect
│   │
│   ├── auth/
│   │   └── login_screen.dart          # Email/password login — routes to correct shell by role
│   │
│   ├── employee/
│   │   ├── employee_shell.dart        # Sidebar (desktop) + Bottom Nav (mobile)
│   │   └── screens/
│   │       ├── employee_dashboard.dart    # KPI cards, current focus, progress ring
│   │       ├── my_goals_screen.dart       # Goal list with filter, search, weightage meter
│   │       ├── create_goal_screen.dart    # Strict goal form with real-time validation
│   │       ├── goal_detail_screen.dart    # Individual goal with check-in history
│   │       ├── quarterly_checkin_screen.dart  # Achievement input form
│   │       ├── notifications_screen.dart  # Realtime notification feed
│   │       └── profile_screen.dart        # User profile + role display
│   │
│   ├── manager/
│   │   ├── manager_shell.dart         # Sidebar (desktop) + Bottom Nav (mobile)
│   │   └── screens/
│   │       ├── manager_dashboard.dart     # Pending approvals + team KPIs (live DB data)
│   │       ├── team_overview_screen.dart  # Expandable employee cards + check-in review
│   │       └── goal_approval_screen.dart  # Inline weightage edit, approve/reject
│   │
│   └── admin/
│       ├── admin_shell.dart           # Full sidebar navigation with all 6 modules
│       └── screens/
│           ├── admin_dashboard.dart            # Quick-actions grid landing page
│           ├── cycle_management_screen.dart    # Performance cycle configuration
│           ├── org_hierarchy_screen.dart       # User-to-manager assignment
│           ├── audit_trail_screen.dart         # Searchable audit event log
│           ├── goal_unlock_screen.dart         # Override approved goal status
│           ├── achievement_report_screen.dart  # CSV export (Planned vs Actual)
│           ├── organization_analytics_screen.dart  # Live pie chart + completion table
│           └── shared_goal_management_screen.dart  # Top-down OKR distribution
```

---

## 🗄️ Database Schema

The Supabase PostgreSQL database uses the following core tables:

| Table | Purpose |
|---|---|
| `users` | Employee profiles, role, department, manager assignment |
| `departments` | Department definitions |
| `goals` | All employee goals with status, UoM, target, weightage |
| `quarterly_checkins` | Per-quarter achievement entries (achievement, notes, manager_comment) |
| `shared_goals` | Top-down OKR templates pushed by Admin/Manager |
| `shared_goal_assignments` | Links shared goals to individual employees |
| `audit_logs` | Immutable event log: action, goal_id, user_id, old/new value, timestamp |
| `performance_cycles` | Cycle windows: open date, close date, status |
| `notifications` | In-app notification records with read status |

**Row Level Security (RLS)** is enabled on all tables. Employees can only read/write their own records; Managers can read their team's records; Admins have full access.

---

## 🚀 Quick Start

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.0 (stable channel)
- A [Supabase](https://supabase.com) project (free tier is sufficient)
- Chrome browser (for Flutter Web development)

### 1. Clone the repository

```bash
git clone https://github.com/ArpitGupta4957/AtomQuest-Employee-Portal.git
cd AtomQuest-Employee-Portal
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure environment

Create a `.env` file in the project root:

```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

> ⚠️ The `.env` file is listed in `.gitignore` and must never be committed to version control.

### 4. Set up the database

In your Supabase dashboard → SQL Editor, run these scripts in order:

```
1. supabase_schema.sql              # Creates all tables, enums, RLS policies
2. supabase_seed_data_dynamic.sql   # Inserts demo users, goals, and check-ins
```

### 5. Run the app

```bash
# Web (recommended for full feature access)
flutter run -d chrome

# Android
flutter run -d android

# Any connected device
flutter run
```

---

## 🌍 Environment Setup

### Supabase RLS Policies

The app requires the following RLS policies to be active (created by the schema SQL):

- **Employees** — Read/write own goals and check-ins only
- **Managers** — Read goals of team members (where `manager_id = auth.uid()`)
- **Admins** — Full read/write access to all tables
- **Audit Logs** — Append-only (insert allowed for all authenticated users, no delete)

### Auth Configuration

In your Supabase project:
1. Go to **Authentication → Providers → Email** and ensure it is enabled.
2. Disable "Confirm email" for demo/hackathon use (optional).

---

## 📦 Deployment

### Deploy to Vercel (Recommended)

The project is pre-configured for Vercel with `vercel.json` handling SPA routing for GoRouter.

**Step 1:** Build the web release

```bash
flutter build web --release
```

**Step 2:** Commit the build output

```bash
git add -f build/web/
git add vercel.json
git commit -m "chore: build web for deployment"
git push
```

**Step 3:** Configure Vercel

| Setting | Value |
|---|---|
| **Framework Preset** | Other |
| **Root Directory** | `./` |
| **Build Command** | `exit 0` |
| **Output Directory** | `build/web` |

Click **Deploy** → your app is live at `https://your-project.vercel.app` ✅

### Deploy to Firebase Hosting

```bash
npm install -g firebase-tools
firebase login
firebase init hosting       # Set public dir: build/web, SPA: Yes
flutter build web --release
firebase deploy
```

---

## 🧪 Quality & Testing

```bash
# Static analysis
flutter analyze

# Run tests
flutter test

# Build release APK (split by ABI)
flutter build apk --split-per-abi

# Build release web
flutter build web --release
```

### Known Platform Notes

- **CSV Export** uses `dart:html` and is **web-only** by design (the Admin portal is browser-deployed). A conditional import stub (`csv_downloader_stub.dart`) ensures the Android/APK build compiles cleanly.
- **Realtime Notifications** use Supabase WebSockets — requires an active internet connection.

---

## 📊 Evaluation Criteria Coverage

| # | Criterion | What We Built |
|---|---|---|
| 1 | **Portal Functionality** | Full end-to-end: Employee creates → Manager approves → Employee checks-in → Manager reviews → Admin exports |
| 2 | **BRD Adherence** | All Phase 1 & Phase 2 requirements implemented with correct validation rules |
| 3 | **User Friendliness** | Role-specific shells, responsive layout (desktop sidebar + mobile bottom nav), empty states, loading indicators, helpful snackbars |
| 4 | **Bug-Free** | Zero overflow errors, properly typed models (no `dynamic` anti-patterns), cross-platform conditional imports |
| 5 | **Good-to-Have Features** | Analytics module with live fl_chart, audit trail, real-time notifications via Supabase WebSockets |
| 6 | **Cost Optimisation** | Supabase free tier, Vercel free tier, Provider (no heavy state library overhead), tree-shaken icon fonts (99%+ reduction) |

---

<div align="center">

**Built with ❤️ for AtomQuest Hackathon 1.0**

Made using Flutter & Supabase

</div>

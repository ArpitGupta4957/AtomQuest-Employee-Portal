import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../models/enums.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';

import '../../features/employee/employee_shell.dart';
import '../../features/employee/screens/employee_dashboard.dart';
import '../../features/employee/screens/my_goals_screen.dart';
import '../../features/employee/screens/create_goal_screen.dart';
import '../../features/employee/screens/goal_detail_screen.dart';
import '../../features/employee/screens/quarterly_checkin_screen.dart';
import '../../features/employee/screens/notifications_screen.dart';
import '../../features/employee/screens/profile_screen.dart';
import '../../features/manager/manager_shell.dart';
import '../../features/manager/screens/manager_dashboard.dart';
import '../../features/manager/screens/team_overview_screen.dart';
import '../../features/manager/screens/goal_approval_screen.dart';
import '../../features/admin/admin_shell.dart';
import '../../features/admin/screens/admin_dashboard.dart';
import '../../features/admin/screens/shared_goal_management_screen.dart';
import '../../features/admin/screens/organization_analytics_screen.dart';

/// GoRouter configuration with role-based routing.
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter router(AuthProvider authProvider) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/splash',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isAuth = authProvider.isAuthenticated;
        final isLoggingIn = state.matchedLocation == '/login';
        final isSplash = state.matchedLocation == '/splash';
        if (isSplash) return null;
        if (!isAuth && !isLoggingIn) return '/login';
        if (isAuth && isLoggingIn) {
          switch (authProvider.currentRole) {
            case UserRole.employee:
              return '/employee';
            case UserRole.manager:
              return '/manager';
            case UserRole.admin:
              return '/admin';
            default:
              return '/login';
          }
        }
        return null;
      },
      routes: [
        // ── Splash ──
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),

        // ── Auth ──
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),


        // ── Employee Module ──
        ShellRoute(
          builder: (context, state, child) => EmployeeShell(child: child),
          routes: [
            GoRoute(
              path: '/employee',
              builder: (context, state) => const EmployeeDashboard(),
              routes: [
                GoRoute(
                  path: 'goals',
                  builder: (context, state) => const MyGoalsScreen(),
                ),
                GoRoute(
                  path: 'goals/create',
                  builder: (context, state) => const CreateGoalScreen(),
                ),
                GoRoute(
                  path: 'goals/:id',
                  builder: (context, state) =>
                      GoalDetailScreen(goalId: state.pathParameters['id']!),
                ),
                GoRoute(
                  path: 'goals/:id/checkin',
                  builder: (context, state) => QuarterlyCheckinScreen(
                    goalId: state.pathParameters['id']!,
                  ),
                ),
                GoRoute(
                  path: 'notifications',
                  builder: (context, state) => const NotificationsScreen(),
                ),
                GoRoute(
                  path: 'profile',
                  builder: (context, state) => const ProfileScreen(),
                ),
              ],
            ),
          ],
        ),

        // ── Manager Module ──
        ShellRoute(
          builder: (context, state, child) => ManagerShell(child: child),
          routes: [
            GoRoute(
              path: '/manager',
              builder: (context, state) => const ManagerDashboard(),
              routes: [
                GoRoute(
                  path: 'team',
                  builder: (context, state) => const TeamOverviewScreen(),
                ),
                GoRoute(
                  path: 'approval/:id',
                  builder: (context, state) =>
                      GoalApprovalScreen(goalId: state.pathParameters['id']!),
                ),
                GoRoute(
                  path: 'notifications',
                  builder: (context, state) => const NotificationsScreen(),
                ),
                GoRoute(
                  path: 'profile',
                  builder: (context, state) => const ProfileScreen(),
                ),
              ],
            ),
          ],
        ),

        // ── Admin Module ──
        ShellRoute(
          builder: (context, state, child) => AdminShell(child: child),
          routes: [
            GoRoute(
              path: '/admin',
              builder: (context, state) => const AdminDashboard(),
              routes: [
                GoRoute(
                  path: 'shared-goals',
                  builder: (context, state) =>
                      const SharedGoalManagementScreen(),
                ),
                GoRoute(
                  path: 'analytics',
                  builder: (context, state) =>
                      const OrganizationAnalyticsScreen(),
                ),
                GoRoute(
                  path: 'notifications',
                  builder: (context, state) => const NotificationsScreen(),
                ),
                GoRoute(
                  path: 'profile',
                  builder: (context, state) => const ProfileScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

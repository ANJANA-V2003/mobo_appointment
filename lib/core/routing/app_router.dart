import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';

import 'package:mobo_appointment_project/core/routing/app_routes.dart';

import 'package:mobo_appointment_project/features/dashboard/dashboard_screen.dart';
import 'package:mobo_appointment_project/features/dashboard/dashboard_tab_screen.dart';

import 'package:mobo_appointment_project/features/get_started/get_started_screen.dart';
import 'package:mobo_appointment_project/features/login/screens/login_screen_credentials_page.dart';
import 'package:mobo_appointment_project/features/login/screens/login_screen_server_page.dart';
import 'package:mobo_appointment_project/features/profile/screens/profile_screen.dart';
import 'package:mobo_appointment_project/features/settings/screens/settings_screen.dart';
import 'package:mobo_appointment_project/features/splash/splash_screen.dart';

// Manager navigation items
final List<BottomNavigationBarItem> managerItems = [
  const BottomNavigationBarItem(
    icon: HugeIcon(icon: HugeIconsStrokeRounded.dashboardSquare02),
    label: 'Dashboard',
  ),
  const BottomNavigationBarItem(
    icon: HugeIcon(icon: HugeIconsStrokeRounded.contact01),
    label: 'Customers',
  ),
  const BottomNavigationBarItem(
    icon: HugeIcon(icon: HugeIconsStrokeRounded.calendarDays),
    label: 'Appointments',
  ),
  const BottomNavigationBarItem(
    icon: HugeIcon(icon: HugeIconsStrokeRounded.userGroup02),
    label: 'Staff',
  ),
  const BottomNavigationBarItem(
    icon: HugeIcon(icon: HugeIconsStrokeRounded.user02),
    label: 'Profile',
  ),
];

// Staff navigation items
final List<BottomNavigationBarItem> staffItems = [
  const BottomNavigationBarItem(
    icon: HugeIcon(icon: HugeIconsStrokeRounded.dashboardSquare02),
    label: 'Dashboard',
  ),
  const BottomNavigationBarItem(
    icon: HugeIcon(icon: HugeIconsStrokeRounded.calendar04),
    label: 'Calendar',
  ),
  const BottomNavigationBarItem(
    icon: HugeIcon(icon: HugeIconsStrokeRounded.calendarDays),
    label: 'Appointments',
  ),
  const BottomNavigationBarItem(
    icon: HugeIcon(icon: HugeIconsStrokeRounded.contact01),
    label: 'Customers',
  ),
  const BottomNavigationBarItem(
    icon: HugeIcon(icon: HugeIconsStrokeRounded.user02),
    label: 'Profile',
  ),
];

// // Customer navigation items
// final List<BottomNavigationBarItem> customerItems = [
//   const BottomNavigationBarItem(
//     icon: HugeIcon(icon: HugeIconsStrokeRounded.home03),
//     label: 'Home',
//   ),
//   const BottomNavigationBarItem(
//     icon: HugeIcon(icon: HugeIconsStrokeRounded.appointment02),
//     label: 'Book',
//   ),
//   const BottomNavigationBarItem(
//     icon: HugeIcon(icon: HugeIconsStrokeRounded.calendarDays),
//     label: 'My Bookings',
//   ),
//   const BottomNavigationBarItem(
//     icon: HugeIcon(icon: HugeIconsStrokeRounded.user02),
//     label: 'Profile',
//   ),
// ];

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',

  routes: [
    GoRoute(
      path: '/splash',
      name: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    GoRoute(
      path: '/get-started',
      name: AppRoutes.getStarted,
      builder: (context, state) => const GetStartedScreen(),
    ),

    GoRoute(
      path: '/server-login',
      name: AppRoutes.serverLogin,
      builder: (context, state) => const LoginScreenServerPage(),
    ),

    GoRoute(
      path: '/credential-login',
      name: AppRoutes.credentialLogin,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;

        return LoginScreenCredentialsPage(
          serverUrl: extra['serverUrl'] as String,
          database: extra['database'] as String,
        );
      },
    ),

    GoRoute(
      path: '/profile',
      name: AppRoutes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),

    GoRoute(
      path: '/settings',
      name: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),


    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return DashboardScreen(
          navigationShell: navigationShell,
          title: 'Manager',
          items: managerItems,
        );
      },

      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/manager/dashboard',
              name: AppRoutes.dashboard,
              builder: (context, state) =>
                  const DashboardTabScreen(title: 'Manager Dashboard'),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/manager/appointments',
              builder: (context, state) =>
                  const DashboardTabScreen(title: 'Customers'),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/manager/staff',
              builder: (context, state) =>
                  const DashboardTabScreen(title: 'Appointments'),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/manager/customers',
              builder: (context, state) =>
                  const DashboardTabScreen(title: 'Staff'),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/manager/profile',
              builder: (context, state) =>
                  const DashboardTabScreen(title: 'Profile'),
            ),
          ],
        ),
      ],
    ),

    // STAFF NAVIGATION
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return DashboardScreen(
          navigationShell: navigationShell,
          title: 'Staff',
          items: staffItems,
        );
      },

      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/staff/dashboard',
              builder: (context, state) =>
                  const DashboardTabScreen(title: 'Staff Dashboard'),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/staff/appointments',
              builder: (context, state) =>
                  const DashboardTabScreen(title: 'Calendar'),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/staff/calendar',
              builder: (context, state) =>
                  const DashboardTabScreen(title: 'Appointments'),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/staff/customers',
              builder: (context, state) =>
                  const DashboardTabScreen(title: 'Customers'),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/staff/profile',
              builder: (context, state) =>
                  const DashboardTabScreen(title: 'Profile'),
            ),
          ],
        ),
      ],
    ),

    // CUSTOMER NAVIGATION
    // StatefulShellRoute.indexedStack(
    //   builder: (context, state, navigationShell) {
    //     return DashboardScreen(
    //       navigationShell: navigationShell,
    //       title: 'Customer',
    //       items: customerItems,
    //     );
    //   },
    //
    //   branches: [
    //     StatefulShellBranch(
    //       routes: [
    //         GoRoute(
    //           path: '/customer/home',
    //           builder: (context, state) =>
    //               const DashboardTabScreen(title: 'Home'),
    //         ),
    //       ],
    //     ),
    //
    //     StatefulShellBranch(
    //       routes: [
    //         GoRoute(
    //           path: '/customer/book',
    //           builder: (context, state) =>
    //               const DashboardTabScreen(title: 'Book Appointment'),
    //         ),
    //       ],
    //     ),
    //
    //     StatefulShellBranch(
    //       routes: [
    //         GoRoute(
    //           path: '/customer/bookings',
    //           builder: (context, state) =>
    //               const DashboardTabScreen(title: 'My Bookings'),
    //         ),
    //       ],
    //     ),
    //
    //     StatefulShellBranch(
    //       routes: [
    //         GoRoute(
    //           path: '/customer/profile',
    //           builder: (context, state) =>
    //               const DashboardTabScreen(title: 'Profile'),
    //         ),
    //       ],
    //     ),
    //   ],
    // ),
  ],
);

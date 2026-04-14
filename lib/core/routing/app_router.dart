import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/customers/presentation/pages/customers_page.dart';
import '../../features/customers/presentation/pages/create_customer_page.dart';
import '../../features/customers/presentation/pages/customer_details_page.dart';
import '../../features/debts/presentation/pages/debts_page.dart';
import '../../features/debts/presentation/pages/create_debt_page.dart';
import '../../features/debts/presentation/pages/debt_details_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/analytics/presentation/pages/analytics_page.dart';
import '../../features/associations/presentation/pages/associations_page.dart';
import '../../features/associations/presentation/pages/association_details_page.dart';
import '../../features/guarantors/presentation/pages/guarantors_page.dart';
import '../../features/guarantors/presentation/pages/guarantor_details_page.dart';
import '../../features/reminders/presentation/pages/reminders_page.dart';
import '../../features/owner/presentation/pages/owner_page.dart';
import '../../features/subscriptions/presentation/pages/subscriptions_page.dart';
import '../layout/main_layout.dart';
import '../network/auth_notifier.dart';
import 'app_routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      final isLoggedIn = authNotifier.valueOrNull?.isLoggedIn ?? false;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.forgotPassword ||
          state.matchedLocation == AppRoutes.resetPassword;

      if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;
      if (isLoggedIn && isAuthRoute) return AppRoutes.dashboard;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) => const ResetPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.owner,
        builder: (context, state) => const OwnerPage(),
      ),
      GoRoute(
        path: AppRoutes.subscriptions,
        builder: (context, state) => const SubscriptionsPage(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.customers,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CustomersPage(),
            ),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const CreateCustomerPage(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => CustomerDetailsPage(
                  customerId: state.pathParameters['id'] ?? '',
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.debts,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DebtsPage(),
            ),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const CreateDebtPage(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => DebtDetailsPage(
                  debtId: state.pathParameters['id'] ?? '',
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.analytics,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AnalyticsPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.associations,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AssociationsPage(),
            ),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => AssociationDetailsPage(
                  associationId: state.pathParameters['id'] ?? '',
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.guarantors,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: GuarantorsPage(),
            ),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => GuarantorDetailsPage(
                  guarantorId: state.pathParameters['id'] ?? '',
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.reminders,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: RemindersPage(),
            ),
          ),
        ],
      ),
    ],
  );
});

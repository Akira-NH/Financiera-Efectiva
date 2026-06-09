import 'package:flutter/material.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/credits/presentation/credits_screen.dart';
import '../../features/credits/presentation/loan_detail_screen.dart';
import '../../features/credits/presentation/payment_schedule_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/operations/presentation/operation_confirmation_screen.dart';
import '../../features/operations/presentation/operation_history_screen.dart';
import '../../features/operations/presentation/payment_screen.dart';
import '../../features/operations/presentation/transfer_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/security_screen.dart';
import '../../features/profile/presentation/settings_screen.dart';
import '../../features/savings/presentation/account_statement_screen.dart';
import '../../features/savings/presentation/savings_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import 'route_names.dart';

class AppRouter {
  const AppRouter._();

  static Map<String, WidgetBuilder> get routes => {
    RouteNames.splash: (_) => const SplashScreen(),
    RouteNames.login: (_) => const LoginScreen(),
    RouteNames.register: (_) => const RegisterScreen(),
    RouteNames.forgotPassword: (_) => const ForgotPasswordScreen(),
    RouteNames.dashboard: (_) => const DashboardScreen(),
    RouteNames.savings: (_) => const SavingsScreen(),
    RouteNames.accountStatement: (_) => const AccountStatementScreen(),
    RouteNames.credits: (_) => const CreditsScreen(),
    RouteNames.loanDetail: (_) => const LoanDetailScreen(),
    RouteNames.paymentSchedule: (_) => const PaymentScheduleScreen(),
    RouteNames.transfer: (_) => const TransferScreen(),
    RouteNames.payment: (_) => const PaymentScreen(),
    RouteNames.operationConfirmation: (_) =>
        const OperationConfirmationScreen(),
    RouteNames.operationHistory: (_) => const OperationHistoryScreen(),
    RouteNames.profile: (_) => const ProfileScreen(),
    RouteNames.editProfile: (_) => const EditProfileScreen(),
    RouteNames.settings: (_) => const SettingsScreen(),
    RouteNames.security: (_) => const SecurityScreen(),
  };
}

import 'package:get/get.dart';
import '../presentation/auth/bindings/auth_binding.dart';
import '../presentation/auth/views/login_view.dart';
import '../presentation/auth/views/signup_view.dart';
import '../presentation/auth/views/forgot_password_view.dart';
import '../presentation/home/bindings/home_binding.dart';
import '../presentation/dashboard/bindings/dashboard_binding.dart';
import '../presentation/settings/bindings/settings_binding.dart';
import '../presentation/transaction/bindings/transaction_form_binding.dart';
import '../presentation/transaction/views/transaction_form_view.dart';
import '../presentation/splash/views/splash_view.dart';
import '../presentation/main/views/main_layout_view.dart';
import '../presentation/main/bindings/main_layout_binding.dart';

part 'app_routes.dart';

class AppPages {
  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.signup,
      page: () => const SignupView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const MainLayoutView(),
      bindings: [
        MainLayoutBinding(),
        HomeBinding(),
        DashboardBinding(),
        SettingsBinding(),
      ],
    ),
    GetPage(
      name: Routes.addTransaction,
      page: () => const TransactionFormView(),
      binding: TransactionFormBinding(),
    ),
    GetPage(
      name: Routes.editTransaction,
      page: () => const TransactionFormView(),
      binding: TransactionFormBinding(),
    ),
  ];
}

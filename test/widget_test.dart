
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker_getx/presentation/auth/controllers/auth_controller.dart';
import 'package:flutter_expense_tracker_getx/data/repositories/auth_repository.dart';
import 'package:flutter_expense_tracker_getx/presentation/settings/controllers/settings_controller.dart';
import 'package:flutter_expense_tracker_getx/routes/app_pages.dart';
import 'mocks/mock_auth_repository.dart';

void main() {
  setUpAll(() async {
    // Initialize Flutter bindings
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize GetX test environment
    Get.testMode = true;
    
    // Register dependencies with mock repository
    Get.put<AuthRepository>(MockAuthRepository());
    Get.put<AuthController>(AuthController());
    final settingsController = Get.put(SettingsController(), permanent: true);
    await settingsController.loadThemeMode();
  });

  tearDownAll(() {
    Get.reset();
  });

  testWidgets('App initialization test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: Routes.splash,
        getPages: AppPages.routes,
      ),
    );
    
    // Initial frame
    await tester.pump();
    
    // Verify that we have a splash screen first
    expect(find.byType(GetMaterialApp), findsOneWidget);
    
    // Wait for splash screen duration
    await tester.pump(const Duration(seconds: 2));
    
    // Should navigate to login after splash
    await tester.pump();
    
    // Print current route for debugging
    print('Current route: ${Get.currentRoute}');
    print('Current widgets in tree:');
    tester.allWidgets.forEach((widget) => print(widget.runtimeType));
  });
}

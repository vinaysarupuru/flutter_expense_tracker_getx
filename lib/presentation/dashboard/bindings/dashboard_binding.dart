import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DashboardController());
    // Get.lazyPut<DashboardController>(
    //   () => DashboardController(),
    // );
  }
}

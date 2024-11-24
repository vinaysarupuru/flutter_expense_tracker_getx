import 'package:get/get.dart';
import '../controllers/transaction_form_controller.dart';

class TransactionFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransactionFormController>(
      () => TransactionFormController(),
    );
  }
}

import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../domain/models/user_model.dart';
import '../../../routes/app_pages.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  Future<void> checkAuthStatus() async {
    if (isLoading.value) return;
    
    isLoading.value = true;
    try {
      currentUser.value = await _authRepository.getCurrentUser();
     
      if (currentUser.value != null) {
        Get.offAllNamed(Routes.home);
      } else {
        Get.offAllNamed(Routes.login);
      }
    } catch (e) {
      error.value = 'Error checking auth status';
      Get.offAllNamed(Routes.login);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    error.value = '';
    
    try {
      final user = await _authRepository.login(email, password);
      if (user != null) {
        currentUser.value = user;
        Get.offAllNamed(Routes.home);
      } else {
        error.value = 'Invalid email or password';
      }
    } catch (e) {
      error.value = 'Error during login';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signup(String name, String email, String password) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      error.value = 'All fields are required';
      return;
    }

    isLoading.value = true;
    error.value = '';

    try {
      final user = await _authRepository.signup(name, email, password);
      currentUser.value = user;
      Get.offAllNamed(Routes.home);
    } catch (e) {
      if (e.toString().contains('Email already exists')) {
        error.value = 'Email is already registered';
      } else {
        error.value = 'Error during signup. Please try again.';
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword(String email) async {
    isLoading.value = true;
    error.value = '';
    
    try {
      // Generate a temporary password
      String tempPassword = DateTime.now().millisecondsSinceEpoch.toString();
      final success = await _authRepository.resetPassword(email, tempPassword);
      
      if (success) {
        // In a real app, you would send this password via email
        Get.snackbar(
          'Success',
          'Password reset successful. Temporary password: $tempPassword',
          duration: const Duration(seconds: 10),
        );
        Get.toNamed(Routes.login);
      } else {
        error.value = 'Email not found';
      }
    } catch (e) {
      error.value = 'Error resetting password';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    isLoading.value = true;
    try {
      await _authRepository.logout();
      currentUser.value = null;
      Get.offAllNamed(Routes.login);
    } catch (e) {
      error.value = 'Error during logout';
      // print('Error during logout: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

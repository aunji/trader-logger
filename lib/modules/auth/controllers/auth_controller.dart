import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/routing/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _repo;

  AuthController(this._repo);

  final Rxn<User> user = Rxn<User>();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = RxString('');

  @override
  void onInit() {
    super.onInit();
    // Bind user stream to reactive variable
    user.bindStream(_repo.authStateChanges());

    // Navigate based on auth state
    ever(user, _handleAuthStateChanged);
  }

  /// Handle auth state changes
  void _handleAuthStateChanged(User? user) {
    if (user == null) {
      // Only navigate if not already on login page
      if (Get.currentRoute != AppRoutes.login) {
        Get.offAllNamed(AppRoutes.login);
      }
    } else {
      // Only navigate if not already on trade list page
      if (Get.currentRoute != AppRoutes.tradeList) {
        Get.offAllNamed(AppRoutes.tradeList);
      }
    }
  }

  /// Sign in with email and password
  Future<void> login(String email, String password) async {
    try {
      errorMessage.value = '';
      isLoading.value = true;

      await _repo.signIn(email, password);

      Get.snackbar(
        'Success',
        'Logged in successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Register new user
  Future<void> register(String email, String password) async {
    try {
      errorMessage.value = '';
      isLoading.value = true;

      await _repo.register(email, password);

      Get.snackbar(
        'Success',
        'Account created successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Sign out
  Future<void> logout() async {
    try {
      await _repo.signOut();
      Get.snackbar(
        'Success',
        'Logged out successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to log out: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/trade.dart';
import '../../../data/models/trade_image.dart';
import '../../../data/repositories/trade_repository.dart';
import '../../../core/routing/app_routes.dart';

class TradeDetailController extends GetxController {
  final TradeRepository _repo;

  TradeDetailController(this._repo);

  final Rxn<Trade> trade = Rxn<Trade>();
  final RxList<TradeImage> images = <TradeImage>[].obs;
  final RxBool isLoading = false.obs;
  final postMortemController = TextEditingController();

  @override
  void onClose() {
    postMortemController.dispose();
    super.onClose();
  }

  /// Load trade and its images
  Future<void> loadTrade(String tradeId) async {
    try {
      isLoading.value = true;

      final loadedTrade = await _repo.getTrade(tradeId);
      trade.value = loadedTrade;

      if (loadedTrade.postMortem != null) {
        postMortemController.text = loadedTrade.postMortem!;
      }

      final loadedImages = await _repo.getTradeImages(tradeId);
      images.value = loadedImages;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load trade: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Add or update post-mortem analysis
  Future<void> savePostMortem() async {
    if (trade.value == null) return;

    try {
      isLoading.value = true;

      final updatedTrade = trade.value!.copyWith(
        postMortem: postMortemController.text.trim(),
      );

      await _repo.updateTrade(updatedTrade);
      trade.value = updatedTrade;

      Get.snackbar('Success', 'Post-mortem saved successfully');
      Get.back(); // Close dialog
    } catch (e) {
      Get.snackbar('Error', 'Failed to save post-mortem: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete the trade
  Future<void> deleteTrade() async {
    if (trade.value == null) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Trade'),
        content: const Text('Are you sure you want to delete this trade? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      isLoading.value = true;
      await _repo.deleteTrade(trade.value!.id);

      Get.snackbar('Success', 'Trade deleted successfully');
      Get.offAllNamed(AppRoutes.tradeList);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete trade: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigate to edit trade
  void editTrade() {
    if (trade.value == null) return;
    Get.toNamed(AppRoutes.tradeForm, arguments: trade.value!.id);
  }
}

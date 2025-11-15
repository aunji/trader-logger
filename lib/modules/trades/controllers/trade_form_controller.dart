import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/trade.dart';
import '../../../data/repositories/trade_repository.dart';
import '../../../core/routing/app_routes.dart';

class TradeFormController extends GetxController {
  final TradeRepository _repo;

  TradeFormController(this._repo);

  // Form controllers
  final symbolController = TextEditingController();
  final entryPriceController = TextEditingController();
  final tpPriceController = TextEditingController();
  final lotController = TextEditingController();
  final reasonController = TextEditingController();
  final profitController = TextEditingController();

  // Reactive variables
  final Rx<TradeDirection> direction = TradeDirection.buy.obs;
  final Rx<TradeSession> session = TradeSession.asia.obs;
  final RxList<String> selectedTags = <String>[].obs;
  final RxList<XFile> selectedImages = <XFile>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString editingTradeId = RxnString();

  // Available tags
  final List<String> availableTags = [
    'FOMO',
    'Discipline',
    'System A',
    'System B',
    'News',
    'Scalp',
    'Swing',
    'Patience',
    'Rushed',
    'Revenge Trade',
  ];

  final ImagePicker _picker = ImagePicker();

  @override
  void onClose() {
    symbolController.dispose();
    entryPriceController.dispose();
    tpPriceController.dispose();
    lotController.dispose();
    reasonController.dispose();
    profitController.dispose();
    super.onClose();
  }

  /// Load trade for editing
  Future<void> loadTradeForEdit(String tradeId) async {
    try {
      isLoading.value = true;
      editingTradeId.value = tradeId;

      final trade = await _repo.getTrade(tradeId);

      symbolController.text = trade.symbol;
      direction.value = trade.direction;
      entryPriceController.text = trade.entryPrice.toString();
      tpPriceController.text = trade.tpPrice.toString();
      lotController.text = trade.lot.toString();
      session.value = trade.session;
      reasonController.text = trade.reason;
      selectedTags.value = trade.tags;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load trade: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Pick images from gallery
  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      selectedImages.addAll(images);
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick images: $e');
    }
  }

  /// Remove an image from selection
  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  /// Toggle tag selection
  void toggleTag(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
  }

  /// Validate form
  bool _validateForm() {
    if (symbolController.text.isEmpty) {
      Get.snackbar('Error', 'Symbol is required');
      return false;
    }
    if (entryPriceController.text.isEmpty) {
      Get.snackbar('Error', 'Entry price is required');
      return false;
    }
    if (tpPriceController.text.isEmpty) {
      Get.snackbar('Error', 'TP price is required');
      return false;
    }
    if (lotController.text.isEmpty) {
      Get.snackbar('Error', 'Lot size is required');
      return false;
    }
    if (reasonController.text.isEmpty) {
      Get.snackbar('Error', 'Entry reason is required');
      return false;
    }
    return true;
  }

  /// Save trade as OPEN
  Future<void> saveOpenTrade() async {
    if (!_validateForm()) return;

    try {
      isLoading.value = true;

      final tradeId = editingTradeId.value ?? DateTime.now().millisecondsSinceEpoch.toString();

      final trade = Trade(
        id: tradeId,
        userId: _repo.userId,
        symbol: symbolController.text.trim().toUpperCase(),
        direction: direction.value,
        entryPrice: double.parse(entryPriceController.text),
        tpPrice: double.parse(tpPriceController.text),
        lot: double.parse(lotController.text),
        session: session.value,
        reason: reasonController.text.trim(),
        tags: selectedTags.toList(),
        createdAt: DateTime.now(),
      );

      if (editingTradeId.value != null) {
        await _repo.updateTrade(trade);
      } else {
        await _repo.createTrade(trade);
      }

      // Upload images
      for (var imageFile in selectedImages) {
        await _repo.uploadTradeImage(
          tradeId: tradeId,
          file: imageFile,
        );
      }

      Get.snackbar('Success', 'Trade saved successfully');
      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save trade: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Save trade as CLOSED with result
  Future<void> saveClosedTrade(TradeResult result) async {
    if (!_validateForm()) return;

    if (profitController.text.isEmpty) {
      Get.snackbar('Error', 'Profit/Loss is required for closed trades');
      return;
    }

    try {
      isLoading.value = true;

      final tradeId = editingTradeId.value ?? DateTime.now().millisecondsSinceEpoch.toString();

      final trade = Trade(
        id: tradeId,
        userId: _repo.userId,
        symbol: symbolController.text.trim().toUpperCase(),
        direction: direction.value,
        entryPrice: double.parse(entryPriceController.text),
        tpPrice: double.parse(tpPriceController.text),
        lot: double.parse(lotController.text),
        session: session.value,
        result: result,
        profitUsd: double.parse(profitController.text),
        reason: reasonController.text.trim(),
        tags: selectedTags.toList(),
        createdAt: DateTime.now(),
        closedAt: DateTime.now(),
      );

      if (editingTradeId.value != null) {
        await _repo.updateTrade(trade);
      } else {
        await _repo.createTrade(trade);
      }

      // Upload images
      for (var imageFile in selectedImages) {
        await _repo.uploadTradeImage(
          tradeId: tradeId,
          file: imageFile,
        );
      }

      Get.snackbar('Success', 'Trade saved successfully');
      Get.offAllNamed(AppRoutes.tradeList);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save trade: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

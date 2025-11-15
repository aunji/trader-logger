import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/trade_form_controller.dart';
import '../../../data/models/trade.dart';

class TradeFormPage extends GetView<TradeFormController> {
  const TradeFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if editing existing trade
    final tradeId = Get.arguments as String?;
    if (tradeId != null) {
      controller.loadTradeForEdit(tradeId);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(tradeId != null ? 'Edit Trade' : 'New Trade'),
      ),
      body: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSymbolField(),
                  const SizedBox(height: 16),
                  _buildDirectionToggle(),
                  const SizedBox(height: 16),
                  _buildPriceFields(),
                  const SizedBox(height: 16),
                  _buildLotField(),
                  const SizedBox(height: 16),
                  _buildSessionDropdown(),
                  const SizedBox(height: 16),
                  _buildReasonField(),
                  const SizedBox(height: 16),
                  _buildTagsSection(),
                  const SizedBox(height: 16),
                  _buildImageSection(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                ],
              ),
            )),
    );
  }

  Widget _buildSymbolField() {
    return TextField(
      controller: controller.symbolController,
      decoration: const InputDecoration(
        labelText: 'Symbol',
        hintText: 'e.g., XAUUSD, EURUSD',
        border: OutlineInputBorder(),
      ),
      textCapitalization: TextCapitalization.characters,
    );
  }

  Widget _buildDirectionToggle() {
    return Obx(() => Row(
          children: [
            const Text('Direction: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ToggleButtons(
                isSelected: [
                  controller.direction.value == TradeDirection.buy,
                  controller.direction.value == TradeDirection.sell,
                ],
                onPressed: (index) {
                  controller.direction.value = index == 0 ? TradeDirection.buy : TradeDirection.sell;
                },
                children: const [
                  Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('BUY')),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('SELL')),
                ],
              ),
            ),
          ],
        ));
  }

  Widget _buildPriceFields() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller.entryPriceController,
            decoration: const InputDecoration(
              labelText: 'Entry Price',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: controller.tpPriceController,
            decoration: const InputDecoration(
              labelText: 'TP Price',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
      ],
    );
  }

  Widget _buildLotField() {
    return TextField(
      controller: controller.lotController,
      decoration: const InputDecoration(
        labelText: 'Lot Size',
        border: OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }

  Widget _buildSessionDropdown() {
    return Obx(() => DropdownButtonFormField<TradeSession>(
          value: controller.session.value,
          decoration: const InputDecoration(
            labelText: 'Session',
            border: OutlineInputBorder(),
          ),
          items: TradeSession.values
              .map((session) => DropdownMenuItem(
                    value: session,
                    child: Text(session.name.toUpperCase()),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) controller.session.value = value;
          },
        ));
  }

  Widget _buildReasonField() {
    return TextField(
      controller: controller.reasonController,
      decoration: const InputDecoration(
        labelText: 'Entry Reason',
        hintText: 'Why did you take this trade?',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tags:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Obx(() => Wrap(
              spacing: 8,
              children: controller.availableTags
                  .map((tag) => FilterChip(
                        label: Text(tag),
                        selected: controller.selectedTags.contains(tag),
                        onSelected: (selected) => controller.toggleTag(tag),
                      ))
                  .toList(),
            )),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Chart Screenshots:', style: TextStyle(fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: controller.pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Add Images'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() => controller.selectedImages.isEmpty
            ? const Text('No images selected')
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: controller.selectedImages.length,
                itemBuilder: (context, index) {
                  final image = controller.selectedImages[index];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        File(image.path),
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => controller.removeImage(index),
                        ),
                      ),
                    ],
                  );
                },
              )),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: controller.saveOpenTrade,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            backgroundColor: Colors.blue,
          ),
          child: const Text('Save as OPEN'),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showProfitDialog(TradeResult.win),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.green,
                ),
                child: const Text('Save as WIN'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showProfitDialog(TradeResult.loss),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.red,
                ),
                child: const Text('Save as LOSS'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            controller.profitController.text = '0';
            controller.saveClosedTrade(TradeResult.be);
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            backgroundColor: Colors.orange,
          ),
          child: const Text('Save as BREAK EVEN'),
        ),
      ],
    );
  }

  void _showProfitDialog(TradeResult result) {
    Get.dialog(
      AlertDialog(
        title: Text('Enter ${result.name.toUpperCase()} Amount'),
        content: TextField(
          controller: controller.profitController,
          decoration: const InputDecoration(
            labelText: 'Profit/Loss (USD)',
            prefixText: '\$',
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.saveClosedTrade(result);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

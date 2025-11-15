import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/trade_detail_controller.dart';
import '../../../data/models/trade.dart';

class TradeDetailPage extends GetView<TradeDetailController> {
  const TradeDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tradeId = Get.arguments as String;
    controller.loadTrade(tradeId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trade Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: controller.editTrade,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: controller.deleteTrade,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final trade = controller.trade.value;
        if (trade == null) {
          return const Center(child: Text('Trade not found'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(trade),
              const Divider(height: 32),
              _buildPriceInfo(trade),
              const Divider(height: 32),
              _buildReason(trade),
              const Divider(height: 32),
              _buildTags(trade),
              const Divider(height: 32),
              _buildImages(),
              const Divider(height: 32),
              _buildPostMortem(trade),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader(Trade trade) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  trade.symbol,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: trade.direction == TradeDirection.buy ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    trade.direction.name.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Lot: ${trade.lot}'),
            Text('Session: ${trade.session.name.toUpperCase()}'),
            Text('Created: ${dateFormat.format(trade.createdAt)}'),
            if (trade.closedAt != null) Text('Closed: ${dateFormat.format(trade.closedAt!)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceInfo(Trade trade) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Price Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Entry Price: ${trade.entryPrice}'),
            Text('TP Price: ${trade.tpPrice}'),
            if (trade.result != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Result: '),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getResultColor(trade.result!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      trade.result!.name.toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
            if (trade.profitUsd != null)
              Text(
                'Profit/Loss: \$${trade.profitUsd!.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: trade.profitUsd! >= 0 ? Colors.green : Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReason(Trade trade) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Entry Reason', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(trade.reason),
          ],
        ),
      ),
    );
  }

  Widget _buildTags(Trade trade) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tags', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: trade.tags
                  .map((tag) => Chip(
                        label: Text(tag),
                        backgroundColor: Colors.blue.shade100,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImages() {
    return Obx(() {
      final images = controller.images;

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Chart Screenshots', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              images.isEmpty
                  ? const Text('No images')
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        final image = images[index];
                        return GestureDetector(
                          onTap: () => _showFullImage(image.imageUrl),
                          child: Image.network(
                            image.imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(child: CircularProgressIndicator());
                            },
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPostMortem(Trade trade) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Post-Mortem Analysis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: _showPostMortemDialog,
                  child: Text(trade.postMortem == null ? 'Add' : 'Edit'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(trade.postMortem ?? 'No post-mortem analysis yet'),
          ],
        ),
      ),
    );
  }

  void _showFullImage(String imageUrl) {
    Get.dialog(
      Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(imageUrl),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPostMortemDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Post-Mortem Analysis'),
        content: TextField(
          controller: controller.postMortemController,
          decoration: const InputDecoration(
            hintText: 'What did you learn from this trade?',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: controller.savePostMortem,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Color _getResultColor(TradeResult result) {
    switch (result) {
      case TradeResult.win:
        return Colors.green;
      case TradeResult.loss:
        return Colors.red;
      case TradeResult.be:
        return Colors.orange;
    }
  }
}

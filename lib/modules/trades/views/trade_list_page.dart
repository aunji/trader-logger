import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/trade_list_controller.dart';
import '../../../modules/auth/controllers/auth_controller.dart';
import '../../../data/models/trade.dart';
import '../../../core/routing/app_routes.dart';

class TradeListPage extends GetView<TradeListController> {
  const TradeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zentry Trade Logger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => Get.toNamed(AppRoutes.tradeReport),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              final authController = Get.find<AuthController>();
              authController.logout();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.tradeForm),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(child: _buildTradeList()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filter by Result:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Obx(() => Wrap(
                spacing: 8,
                children: ['ALL', 'OPEN', 'WIN', 'LOSS', 'BE']
                    .map((result) => FilterChip(
                          label: Text(result),
                          selected: controller.filterResult.value == result,
                          onSelected: (selected) {
                            controller.setFilterResult(result);
                          },
                        ))
                    .toList(),
              )),
          const SizedBox(height: 8),
          const Text('Filter by Session:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Obx(() => DropdownButton<TradeSession?>(
                value: controller.filterSession.value,
                hint: const Text('All Sessions'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Sessions')),
                  ...TradeSession.values.map((session) => DropdownMenuItem(
                        value: session,
                        child: Text(session.name.toUpperCase()),
                      )),
                ],
                onChanged: controller.setFilterSession,
              )),
        ],
      ),
    );
  }

  Widget _buildTradeList() {
    return Obx(() {
      final trades = controller.filteredTrades;

      if (trades.isEmpty) {
        return const Center(
          child: Text('No trades found. Add your first trade!'),
        );
      }

      return ListView.builder(
        itemCount: trades.length,
        itemBuilder: (context, index) {
          final trade = trades[index];
          return _buildTradeCard(trade);
        },
      );
    });
  }

  Widget _buildTradeCard(Trade trade) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: () => Get.toNamed(AppRoutes.tradeDetail, arguments: trade.id),
        leading: CircleAvatar(
          backgroundColor: trade.direction == TradeDirection.buy ? Colors.green : Colors.red,
          child: Text(
            trade.direction == TradeDirection.buy ? 'B' : 'S',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          '${trade.symbol} ${trade.lot} lots',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Entry: ${trade.entryPrice} → TP: ${trade.tpPrice}'),
            Text('Session: ${trade.session.name.toUpperCase()}'),
            Text(dateFormat.format(trade.createdAt)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (trade.result != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getResultColor(trade.result!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  trade.result!.name.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            if (trade.profitUsd != null)
              Text(
                '\$${trade.profitUsd!.toStringAsFixed(2)}',
                style: TextStyle(
                  color: trade.profitUsd! >= 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
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

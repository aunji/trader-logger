import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/trade_report_controller.dart';

class TradeReportPage extends GetView<TradeReportController> {
  const TradeReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trade Report & Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateRangeFilter(),
            const SizedBox(height: 16),
            _buildBasicStats(),
            const SizedBox(height: 16),
            _buildProfitStats(),
            const SizedBox(height: 16),
            _buildTagAnalytics(),
            const SizedBox(height: 16),
            _buildSessionAnalytics(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeFilter() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Date Range', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['today', 'week', 'month', 'all']
                  .map((range) => ChoiceChip(
                        label: Text(range.toUpperCase()),
                        selected: false,
                        onSelected: (selected) {
                          if (selected) controller.setDateRange(range);
                        },
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicStats() {
    return Obx(() => Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('Total Trades', controller.totalTrades.value.toString(), Colors.blue),
                    _buildStatCard('Wins', controller.totalWins.value.toString(), Colors.green),
                    _buildStatCard('Losses', controller.totalLosses.value.toString(), Colors.red),
                    _buildStatCard('BE', controller.totalBE.value.toString(), Colors.orange),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      const Text('Win Rate', style: TextStyle(fontSize: 16)),
                      Text(
                        '${controller.winRate.value.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: controller.winRate.value >= 50 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfitStats() {
    return Obx(() => Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Profit/Loss', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildProfitRow('Total P/L', controller.totalProfit.value),
                const Divider(),
                _buildProfitRow('Avg Win', controller.avgWin.value, isPositive: true),
                _buildProfitRow('Avg Loss', controller.avgLoss.value, isPositive: false),
              ],
            ),
          ),
        ));
  }

  Widget _buildProfitRow(String label, double value, {bool? isPositive}) {
    Color color;
    if (isPositive == null) {
      color = value >= 0 ? Colors.green : Colors.red;
    } else {
      color = isPositive ? Colors.green : Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagAnalytics() {
    return Obx(() {
      final tagCounts = controller.tagCounts;
      final tagWinRates = controller.tagWinRates;

      if (tagCounts.isEmpty) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('No tag data available'),
          ),
        );
      }

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tag Performance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...tagCounts.entries.map((entry) {
                final tag = entry.key;
                final count = entry.value;
                final winRate = tagWinRates[tag] ?? 0.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(tag),
                      ),
                      Expanded(
                        child: Text('$count trades', style: const TextStyle(fontSize: 12)),
                      ),
                      Expanded(
                        child: Text(
                          '${winRate.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: winRate >= 50 ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSessionAnalytics() {
    return Obx(() {
      final sessionCounts = controller.sessionCounts;
      final sessionWinRates = controller.sessionWinRates;

      if (sessionCounts.isEmpty) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('No session data available'),
          ),
        );
      }

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Session Performance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...sessionCounts.entries.map((entry) {
                final session = entry.key;
                final count = entry.value;
                final winRate = sessionWinRates[session] ?? 0.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(session.toUpperCase()),
                      ),
                      Expanded(
                        child: Text('$count trades', style: const TextStyle(fontSize: 12)),
                      ),
                      Expanded(
                        child: Text(
                          '${winRate.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: winRate >= 50 ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      );
    });
  }
}

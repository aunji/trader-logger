import 'package:get/get.dart';
import '../../../data/models/trade.dart';
import '../../../data/repositories/trade_repository.dart';

class TradeReportController extends GetxController {
  final TradeRepository _repo;

  TradeReportController(this._repo);

  final RxList<Trade> allTrades = <Trade>[].obs;
  final RxList<Trade> filteredTrades = <Trade>[].obs;
  final RxBool isLoading = false.obs;

  // Date range filter
  final Rxn<DateTime> startDate = Rxn<DateTime>();
  final Rxn<DateTime> endDate = Rxn<DateTime>();

  // Analytics data
  final RxInt totalTrades = 0.obs;
  final RxInt totalWins = 0.obs;
  final RxInt totalLosses = 0.obs;
  final RxInt totalBE = 0.obs;
  final RxDouble winRate = 0.0.obs;
  final RxDouble totalProfit = 0.0.obs;
  final RxDouble avgWin = 0.0.obs;
  final RxDouble avgLoss = 0.0.obs;

  // Behavior analytics
  final RxMap<String, int> tagCounts = <String, int>{}.obs;
  final RxMap<String, double> tagWinRates = <String, double>{}.obs;
  final RxMap<String, int> sessionCounts = <String, int>{}.obs;
  final RxMap<String, double> sessionWinRates = <String, double>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _listenTrades();
    setDateRange('month');
  }

  /// Listen to trades from repository
  void _listenTrades() {
    allTrades.bindStream(_repo.watchTrades());
    ever(allTrades, (_) => _calculateAnalytics());
    ever(startDate, (_) => _filterByDate());
    ever(endDate, (_) => _filterByDate());
  }

  /// Set predefined date range
  void setDateRange(String range) {
    final now = DateTime.now();
    switch (range) {
      case 'today':
        startDate.value = DateTime(now.year, now.month, now.day);
        endDate.value = now;
        break;
      case 'week':
        startDate.value = now.subtract(const Duration(days: 7));
        endDate.value = now;
        break;
      case 'month':
        startDate.value = DateTime(now.year, now.month - 1, now.day);
        endDate.value = now;
        break;
      case 'all':
        startDate.value = null;
        endDate.value = null;
        break;
    }
  }

  /// Filter trades by date range
  void _filterByDate() {
    if (startDate.value == null || endDate.value == null) {
      filteredTrades.value = allTrades;
    } else {
      filteredTrades.value = allTrades.where((trade) {
        return trade.createdAt.isAfter(startDate.value!) &&
            trade.createdAt.isBefore(endDate.value!);
      }).toList();
    }
    _calculateAnalytics();
  }

  /// Calculate all analytics
  void _calculateAnalytics() {
    final trades = filteredTrades.isEmpty ? allTrades : filteredTrades;

    // Basic stats
    totalTrades.value = trades.length;
    totalWins.value = trades.where((t) => t.result == TradeResult.win).length;
    totalLosses.value = trades.where((t) => t.result == TradeResult.loss).length;
    totalBE.value = trades.where((t) => t.result == TradeResult.be).length;

    // Win rate
    final closedTrades = trades.where((t) => t.result != null).length;
    winRate.value = closedTrades > 0 ? (totalWins.value / closedTrades * 100) : 0.0;

    // Profit calculation
    totalProfit.value = trades
        .where((t) => t.profitUsd != null)
        .fold(0.0, (sum, t) => sum + t.profitUsd!);

    // Average win/loss
    final wins = trades.where((t) => t.result == TradeResult.win && t.profitUsd != null);
    avgWin.value = wins.isNotEmpty
        ? wins.fold(0.0, (sum, t) => sum + t.profitUsd!) / wins.length
        : 0.0;

    final losses = trades.where((t) => t.result == TradeResult.loss && t.profitUsd != null);
    avgLoss.value = losses.isNotEmpty
        ? losses.fold(0.0, (sum, t) => sum + t.profitUsd!) / losses.length
        : 0.0;

    // Tag analytics
    _calculateTagStats(trades);

    // Session analytics
    _calculateSessionStats(trades);
  }

  /// Calculate tag-based statistics
  void _calculateTagStats(List<Trade> trades) {
    final Map<String, int> counts = {};
    final Map<String, int> wins = {};

    for (var trade in trades) {
      for (var tag in trade.tags) {
        counts[tag] = (counts[tag] ?? 0) + 1;
        if (trade.result == TradeResult.win) {
          wins[tag] = (wins[tag] ?? 0) + 1;
        }
      }
    }

    tagCounts.value = counts;

    final Map<String, double> winRates = {};
    for (var tag in counts.keys) {
      final totalWithTag = counts[tag]!;
      final winsWithTag = wins[tag] ?? 0;
      winRates[tag] = totalWithTag > 0 ? (winsWithTag / totalWithTag * 100) : 0.0;
    }

    tagWinRates.value = winRates;
  }

  /// Calculate session-based statistics
  void _calculateSessionStats(List<Trade> trades) {
    final Map<String, int> counts = {};
    final Map<String, int> wins = {};

    for (var trade in trades) {
      final sessionName = trade.session.name;
      counts[sessionName] = (counts[sessionName] ?? 0) + 1;
      if (trade.result == TradeResult.win) {
        wins[sessionName] = (wins[sessionName] ?? 0) + 1;
      }
    }

    sessionCounts.value = counts;

    final Map<String, double> winRates = {};
    for (var session in counts.keys) {
      final totalInSession = counts[session]!;
      final winsInSession = wins[session] ?? 0;
      winRates[session] = totalInSession > 0 ? (winsInSession / totalInSession * 100) : 0.0;
    }

    sessionWinRates.value = winRates;
  }
}

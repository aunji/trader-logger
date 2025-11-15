import 'package:get/get.dart';
import '../../../data/models/trade.dart';
import '../../../data/repositories/trade_repository.dart';

class TradeListController extends GetxController {
  final TradeRepository _repo;

  TradeListController(this._repo);

  final RxList<Trade> trades = <Trade>[].obs;
  final RxList<Trade> filteredTrades = <Trade>[].obs;
  final RxBool isLoading = false.obs;
  final RxString filterResult = 'ALL'.obs; // ALL / WIN / LOSS / BE / OPEN
  final Rxn<TradeSession> filterSession = Rxn<TradeSession>();

  @override
  void onInit() {
    super.onInit();
    _listenTrades();
  }

  /// Listen to trades stream from repository
  void _listenTrades() {
    trades.bindStream(_repo.watchTrades());
    ever(trades, (_) => _applyFilters());
    ever(filterResult, (_) => _applyFilters());
    ever(filterSession, (_) => _applyFilters());
  }

  /// Apply filters to trade list
  void _applyFilters() {
    var result = List<Trade>.from(trades);

    // Filter by result
    if (filterResult.value != 'ALL') {
      if (filterResult.value == 'OPEN') {
        result = result.where((trade) => trade.result == null).toList();
      } else {
        final resultEnum = TradeResult.values.firstWhere(
          (e) => e.name.toUpperCase() == filterResult.value,
        );
        result = result.where((trade) => trade.result == resultEnum).toList();
      }
    }

    // Filter by session
    if (filterSession.value != null) {
      result = result
          .where((trade) => trade.session == filterSession.value)
          .toList();
    }

    filteredTrades.value = result;
  }

  /// Set result filter
  void setFilterResult(String value) {
    filterResult.value = value;
  }

  /// Set session filter
  void setFilterSession(TradeSession? value) {
    filterSession.value = value;
  }

  /// Clear all filters
  void clearFilters() {
    filterResult.value = 'ALL';
    filterSession.value = null;
  }
}

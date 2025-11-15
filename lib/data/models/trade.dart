import 'package:cloud_firestore/cloud_firestore.dart';

enum TradeDirection { buy, sell }

enum TradeSession { asia, london, newYork, custom }

enum TradeResult { win, loss, be }

class Trade {
  final String id;
  final String userId;
  final String symbol;
  final TradeDirection direction;
  final double entryPrice;
  final double tpPrice;
  final double lot;
  final TradeSession session;

  final TradeResult? result; // null = open trade
  final double? profitUsd; // P/L in USD
  final String reason; // entry reason
  final String? postMortem; // after-trade self-analysis
  final List<String> tags; // behavior tags like "FOMO", "System A", etc.

  final DateTime createdAt;
  final DateTime? closedAt;

  Trade({
    required this.id,
    required this.userId,
    required this.symbol,
    required this.direction,
    required this.entryPrice,
    required this.tpPrice,
    required this.lot,
    required this.session,
    this.result,
    this.profitUsd,
    required this.reason,
    this.postMortem,
    required this.tags,
    required this.createdAt,
    this.closedAt,
  });

  /// Convert Trade object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'symbol': symbol,
      'direction': direction.name,
      'entryPrice': entryPrice,
      'tpPrice': tpPrice,
      'lot': lot,
      'session': session.name,
      'result': result?.name,
      'profitUsd': profitUsd,
      'reason': reason,
      'postMortem': postMortem,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'closedAt': closedAt?.toIso8601String(),
    };
  }

  /// Create Trade object from Firestore DocumentSnapshot
  factory Trade.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Trade(
      id: doc.id,
      userId: data['userId'] as String,
      symbol: data['symbol'] as String,
      direction: TradeDirection.values
          .firstWhere((e) => e.name == data['direction']),
      entryPrice: (data['entryPrice'] as num).toDouble(),
      tpPrice: (data['tpPrice'] as num).toDouble(),
      lot: (data['lot'] as num).toDouble(),
      session:
          TradeSession.values.firstWhere((e) => e.name == data['session']),
      result: data['result'] != null
          ? TradeResult.values.firstWhere((e) => e.name == data['result'])
          : null,
      profitUsd: data['profitUsd'] != null
          ? (data['profitUsd'] as num).toDouble()
          : null,
      reason: data['reason'] as String,
      postMortem: data['postMortem'] as String?,
      tags: List<String>.from(data['tags'] as List),
      createdAt: DateTime.parse(data['createdAt'] as String),
      closedAt: data['closedAt'] != null
          ? DateTime.parse(data['closedAt'] as String)
          : null,
    );
  }

  /// Create a copy of Trade with modified fields
  Trade copyWith({
    String? id,
    String? userId,
    String? symbol,
    TradeDirection? direction,
    double? entryPrice,
    double? tpPrice,
    double? lot,
    TradeSession? session,
    TradeResult? result,
    double? profitUsd,
    String? reason,
    String? postMortem,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? closedAt,
  }) {
    return Trade(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      symbol: symbol ?? this.symbol,
      direction: direction ?? this.direction,
      entryPrice: entryPrice ?? this.entryPrice,
      tpPrice: tpPrice ?? this.tpPrice,
      lot: lot ?? this.lot,
      session: session ?? this.session,
      result: result ?? this.result,
      profitUsd: profitUsd ?? this.profitUsd,
      reason: reason ?? this.reason,
      postMortem: postMortem ?? this.postMortem,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      closedAt: closedAt ?? this.closedAt,
    );
  }
}

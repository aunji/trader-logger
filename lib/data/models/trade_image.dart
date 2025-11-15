import 'package:cloud_firestore/cloud_firestore.dart';

class TradeImage {
  final String id; // Firestore document ID
  final String tradeId;
  final String imageUrl; // secure_url from Cloudinary
  final String? publicId; // public_id from Cloudinary for deletion
  final String? timeframe; // e.g., "H1", "M15", "M5"
  final String? note; // optional note about the image
  final DateTime createdAt;

  TradeImage({
    required this.id,
    required this.tradeId,
    required this.imageUrl,
    this.publicId,
    this.timeframe,
    this.note,
    required this.createdAt,
  });

  /// Convert TradeImage to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'tradeId': tradeId,
      'imageUrl': imageUrl,
      'publicId': publicId,
      'timeframe': timeframe,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create TradeImage from Firestore DocumentSnapshot
  factory TradeImage.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TradeImage(
      id: doc.id,
      tradeId: data['tradeId'] as String,
      imageUrl: data['imageUrl'] as String,
      publicId: data['publicId'] as String?,
      timeframe: data['timeframe'] as String?,
      note: data['note'] as String?,
      createdAt: DateTime.parse(data['createdAt'] as String),
    );
  }
}

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../models/trade.dart';
import '../models/trade_image.dart';
import '../services/cloudinary_service.dart';

/// Repository for Trade and TradeImage data operations
class TradeRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final CloudinaryService _cloudinaryService;

  TradeRepository({
    required this.firestore,
    required this.auth,
    CloudinaryService? cloudinaryService,
  }) : _cloudinaryService = cloudinaryService ?? CloudinaryService();

  /// Get current user ID
  String get userId {
    final user = auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  /// Stream of all trades for current user
  Stream<List<Trade>> watchTrades() {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('trades')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Trade.fromDoc(doc)).toList());
  }

  /// Get a single trade by ID
  Future<Trade> getTrade(String tradeId) async {
    final doc = await firestore
        .collection('users')
        .doc(userId)
        .collection('trades')
        .doc(tradeId)
        .get();

    if (!doc.exists) {
      throw Exception('Trade not found');
    }

    return Trade.fromDoc(doc);
  }

  /// Create a new trade
  Future<void> createTrade(Trade trade) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('trades')
        .doc(trade.id)
        .set(trade.toMap());
  }

  /// Update an existing trade
  Future<void> updateTrade(Trade trade) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('trades')
        .doc(trade.id)
        .update(trade.toMap());
  }

  /// Delete a trade and all its images
  Future<void> deleteTrade(String tradeId) async {
    final batch = firestore.batch();

    // Delete all trade images from Firestore
    final imagesSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('trades')
        .doc(tradeId)
        .collection('images')
        .get();

    for (var doc in imagesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Delete the trade document
    batch.delete(
      firestore
          .collection('users')
          .doc(userId)
          .collection('trades')
          .doc(tradeId),
    );

    await batch.commit();
  }

  /// Get all images for a specific trade
  Future<List<TradeImage>> getTradeImages(String tradeId) async {
    final snapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('trades')
        .doc(tradeId)
        .collection('images')
        .orderBy('createdAt')
        .get();

    return snapshot.docs.map((doc) => TradeImage.fromDoc(doc)).toList();
  }

  /// Upload a trade image to Cloudinary and save metadata to Firestore
  Future<TradeImage> uploadTradeImage({
    required String tradeId,
    required XFile file,
    String? timeframe,
    String? note,
  }) async {
    // 1. Compress image
    final tempDir = await getTemporaryDirectory();
    final targetPath =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: 75,
      minWidth: 1080,
    );

    final imageFile = File(compressedFile?.path ?? file.path);

    // 2. Upload to Cloudinary
    final folder = 'trade-logger/$userId/$tradeId';
    final result = await _cloudinaryService.uploadImage(imageFile, folder: folder);

    final secureUrl = result['secure_url'] as String;
    final publicId = result['public_id'] as String;

    // 3. Save metadata to Firestore
    final docRef = firestore
        .collection('users')
        .doc(userId)
        .collection('trades')
        .doc(tradeId)
        .collection('images')
        .doc();

    final tradeImage = TradeImage(
      id: docRef.id,
      tradeId: tradeId,
      imageUrl: secureUrl,
      publicId: publicId,
      timeframe: timeframe,
      note: note,
      createdAt: DateTime.now(),
    );

    await docRef.set(tradeImage.toMap());

    return tradeImage;
  }

  /// Delete a trade image from Firestore
  /// Note: The image file remains in Cloudinary (cleanup can be done later)
  Future<void> deleteTradeImage({
    required String tradeId,
    required String imageId,
  }) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('trades')
        .doc(tradeId)
        .collection('images')
        .doc(imageId)
        .delete();
  }
}

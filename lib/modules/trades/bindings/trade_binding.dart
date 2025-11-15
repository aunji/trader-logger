import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../data/repositories/trade_repository.dart';
import '../controllers/trade_list_controller.dart';
import '../controllers/trade_form_controller.dart';
import '../controllers/trade_detail_controller.dart';
import '../controllers/trade_report_controller.dart';

class TradeBinding extends Bindings {
  @override
  void dependencies() {
    // Repository
    Get.lazyPut<TradeRepository>(
      () => TradeRepository(
        firestore: FirebaseFirestore.instance,
        auth: FirebaseAuth.instance,
      ),
    );

    // Controllers
    Get.lazyPut<TradeListController>(
      () => TradeListController(Get.find()),
    );
    Get.lazyPut<TradeFormController>(
      () => TradeFormController(Get.find()),
    );
    Get.lazyPut<TradeDetailController>(
      () => TradeDetailController(Get.find()),
    );
    Get.lazyPut<TradeReportController>(
      () => TradeReportController(Get.find()),
    );
  }
}

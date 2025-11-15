import 'package:get/get.dart';
import 'app_routes.dart';
import '../../modules/auth/views/login_page.dart';
import '../../modules/auth/views/register_page.dart';
import '../../modules/auth/bindings/auth_binding.dart';
import '../../modules/trades/views/trade_list_page.dart';
import '../../modules/trades/views/trade_form_page.dart';
import '../../modules/trades/views/trade_detail_page.dart';
import '../../modules/trades/views/trade_report_page.dart';
import '../../modules/trades/bindings/trade_binding.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.tradeList,
      page: () => const TradeListPage(),
      bindings: [
        AuthBinding(),
        TradeBinding(),
      ],
    ),
    GetPage(
      name: AppRoutes.tradeForm,
      page: () => const TradeFormPage(),
      binding: TradeBinding(),
    ),
    GetPage(
      name: AppRoutes.tradeDetail,
      page: () => const TradeDetailPage(),
      binding: TradeBinding(),
    ),
    GetPage(
      name: AppRoutes.tradeReport,
      page: () => const TradeReportPage(),
      binding: TradeBinding(),
    ),
  ];
}

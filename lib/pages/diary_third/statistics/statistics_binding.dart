import 'package:get/get.dart';

import 'statistics_logic.dart';

class StatisticsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StatisticsLogic());
  }
}


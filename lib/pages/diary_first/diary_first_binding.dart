import 'package:get/get.dart';

import 'diary_first_logic.dart';

class DiaryFirstBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DiaryFirstLogic());
  }
}
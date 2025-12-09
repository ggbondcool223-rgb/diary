import 'package:get/get.dart';

import 'diary_second_logic.dart';

class DiarySecondBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DiarySecondLogic());
  }
}
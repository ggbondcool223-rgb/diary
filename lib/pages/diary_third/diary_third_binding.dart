import 'package:get/get.dart';

import 'diary_third_logic.dart';

class DiaryThirdBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DiaryThirdLogic());
  }
}
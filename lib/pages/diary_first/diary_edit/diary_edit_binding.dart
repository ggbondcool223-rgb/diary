import 'package:get/get.dart';

import 'diary_edit_logic.dart';

class DiaryEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DiaryEditLogic());
  }
}
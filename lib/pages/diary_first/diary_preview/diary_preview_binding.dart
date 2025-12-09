import 'package:get/get.dart';

import 'diary_preview_logic.dart';

class DiaryPreviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DiaryPreviewLogic());
  }
}
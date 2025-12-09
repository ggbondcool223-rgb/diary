import 'package:get/get.dart';

import 'diary_trans_logic.dart';

class DiaryTransBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      DiaryTransLogic(),
      permanent: true,
    );
  }
}

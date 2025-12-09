import 'package:diary/pages/diary_first/diary_first_logic.dart';
import 'package:diary/pages/diary_second/diary_second_logic.dart';
import 'package:get/get.dart';

import '../diary_third/diary_third_logic.dart';
import 'diary_tab_logic.dart';

class DiaryTabBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DiaryTabLogic());
    Get.lazyPut(() => DiaryFirstLogic());
    Get.lazyPut(() => DiarySecondLogic());
    Get.lazyPut(() => DiaryThirdLogic());
  }
}